
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Web.IWebRequest FROM PROPATH.
USING OpenEdge.Web.WebResponse FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS Core.Security.Auth:
    /* Inherited Variable from Parent Class */
    DEFINE PRIVATE VARIABLE poRequest         AS IWebRequest              NO-UNDO.
    DEFINE PRIVATE VARIABLE oJson             AS JsonObject               NO-UNDO.
    DEFINE PRIVATE VARIABLE oResponse         AS WebResponse              NO-UNDO.
    
    /* Utilities Object */
    DEFINE PRIVATE VARIABLE oBase64Url        AS Core.Utilities.Base64Url NO-UNDO.
    DEFINE PRIVATE VARIABLE oEnv              AS Core.Utilities.Env       NO-UNDO.
    
    /* Auth Variable for storing authentication data */
    DEFINE PRIVATE VARIABLE cBasicCredential  AS CHARACTER                NO-UNDO.
    DEFINE PRIVATE VARIABLE cBasicUsername    AS CHARACTER                NO-UNDO.
    DEFINE PRIVATE VARIABLE cBasicPassword    AS CHARACTER                NO-UNDO.
   
    /* Bearer Variable for storing beaere information */
    DEFINE PRIVATE VARIABLE cBearerCredential AS CHARACTER                NO-UNDO.
    DEFINE PRIVATE VARIABLE cBearerUsername   AS CHARACTER                NO-UNDO.
    DEFINE PRIVATE VARIABLE cBearerToken      AS CHARACTER                NO-UNDO.
    DEFINE PRIVATE VARIABLE cAgent            AS CHARACTER                NO-UNDO.
    
    /* Other Variables */
    DEFINE PRIVATE VARIABLE iBearerExpire     AS INTEGER                  NO-UNDO.
    
    /* Blank Constructor */
    CONSTRUCTOR PUBLIC Auth():
        InitUtilities().         
    END CONSTRUCTOR.
    
    /* Inherit Parent Object Constructor */
    CONSTRUCTOR PUBLIC Auth(INPUT poRequest AS IWebRequest, INPUT ojson AS JsonObject, INPUT oResponse AS WebResponse):
        ASSIGN
            THIS-OBJECT:poRequest = poRequest
            THIS-OBJECT:ojson     = ojson
            THIS-OBJECT:oResponse = oResponse.
            
        InitUtilities().
    END CONSTRUCTOR.
    
    METHOD PRIVATE VOID InitUtilities():
        oBase64Url = NEW Core.Utilities.Base64Url().
        oEnv = NEW Core.Utilities.Env(). 
    END METHOD.


    /* BASIC AUTH LOGIN 
    ==================================================================================== */
    METHOD PUBLIC VOID Login():
        ASSIGN cAgent = poRequest:GetHeader('User-Agent'):VALUE.
        
        MESSAGE 
            "ContextNames: " poRequest:ContextNames SKIP
            "DefaultCookieDomain: " poRequest:DefaultCookieDomain SKIP
            "DefaultCookiePath: " poRequest:DefaultCookiePath SKIP
            "LocalAddress: " poRequest:LocalAddress SKIP
            "LocalHost: " poRequest:LocalHost SKIP
            "LocalPort: " STRING(poRequest:LocalPort) SKIP
            "PathInfo: " poRequest:PathInfo SKIP
            "PathParameterNames: " poRequest:PathParameterNames SKIP
            "RemoteAddress: " poRequest:RemoteAddress SKIP
            "RemoteHost: " poRequest:RemoteHost SKIP
            "RemotePort: " STRING(poRequest:RemotePort) SKIP
            "RemoteUser: " poRequest:RemoteUser SKIP
            "ResolvedTransportPath: " poRequest:ResolvedTransportPath SKIP
            "ServerSoftware: " poRequest:ServerSoftware SKIP
            "TransportPath: " poRequest:TransportPath SKIP
            "UriTemplate: " poRequest:UriTemplate SKIP
            "WebAppPath: " poRequest:WebAppPath 
            VIEW-AS ALERT-BOX.
        
        /* Just for logging on server */
        MESSAGE "BEGIN LOGIN".
        
        setBasicCredential().
        
        /* Find user credential to database */
        /* Use exclusive lock because yuserd need to be updated */
        MESSAGE "CHECKING USER" cBasicUsername "IN USER DATABASE".
        FIND FIRST xtools.xuser WHERE xtools.xuser.chUserid = cBasicUsername NO-LOCK NO-ERROR.
        IF AVAILABLE xtools.xuser THEN 
        DO:
            MESSAGE "USERNAME FOUND".
            IF xtools.xuser.chPasswordFix = cBasicPassword THEN 
            DO:
                MESSAGE "PASSWORD CORRECT".
                
                /* generate token and expiry */
                FIND FIRST usrtoken WHERE 
                    usrtoken.usersid  = cBasicUsername AND
                    usrtoken.type     = cAgent
                    EXCLUSIVE-LOCK NO-ERROR.
                    
                IF NOT AVAILABLE usrtoken THEN DO:
                    CREATE usrtoken.
                END.
                
                ASSIGN
                    usrtoken.usersid = cBasicUsername
                    usrtoken.type    = cAgent
                    usrtoken.token   = genToken()
                    usrtoken.expiry  = genExpire()
                    usrtoken.uiddat  = NOW
                    usrtoken.ip      = poRequest:RemoteHost
                    .
                
                /* send response */
                oJson:Add('success', TRUE).
                oJson:Add('message', 'Login Successful').  
                oJson:Add('username', xtools.xuser.chUserid).
                oJson:Add('token', usrtoken.token).
                oJson:Add('expire', usrtoken.expiry).  
            END.
                
            ELSE 
            DO:
                MESSAGE "PASSWORD INCORRECT".
                /* send unauthorized message */
                oResponse:StatusCode = 401.
                oJson:Add('success', FALSE).
                oJson:Add('message', 'Wrong Password').
            END.
        END.
        
        /* account not exists */
        ELSE 
        DO:
            MESSAGE "ACCOUNT NOT EXIST".
            /* send account not exitst message */
            oResponse:StatusCode = 401.
            oJson:Add('success', FALSE).
            oJson:Add('message', 'Account not exits').
        END.
        
        RELEASE xtools.xuser NO-ERROR.
        RELEASE usrtoken NO-ERROR.
        MESSAGE "END LOGIN".
    END METHOD. 
    
    
    /* BASIC AUTH REGISTER 
    ==================================================================================== */
    METHOD PUBLIC VOID Register():
        DEFINE VARIABLE iLastUserId AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cRole       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cCusno      AS CHARACTER NO-UNDO.
        
        MESSAGE "BEGIN REGISTER".
        
        setBasicCredential().
        
        /* Check if account already exists on database */
        FIND FIRST xtools.xuser WHERE xtools.xuser.chUserid = cBasicUsername NO-LOCK NO-ERROR.
        IF AVAILABLE xtools.xuser THEN 
        DO:
            MESSAGE "USERNAME EXIST".
            oResponse:StatusCode = 401.
            oJson:Add('success', FALSE).
            oJson:Add('message', 'Username already exist').    
        END.
        
        /* create new account credential on database */
        ELSE 
        DO:
            MESSAGE "USERNAME NOT EXIST, CREATING ACCOUNT" cBasicUsername.         
            CREATE xtools.xuser.
            ASSIGN
                xtools.xuser.chUserid = cBasicUsername
                xtools.xuser.chPasswordFix = cBasicPassword.
                
            oJson:Add('success', TRUE).
            oJson:Add('message', 'Username ' + cBasicUsername + ' successfully created with ID: ' + STRING(xtools.xuser.chUserid)).
        END.
        RELEASE xtools.xuser NO-ERROR.
        MESSAGE "END REGISTER".
    END METHOD.
    
    /* BEARER AUTH LOGOUT
    ==================================================================================== */
    /* Delete Database Token and Expiry_Epoch of a user */
    METHOD PUBLIC VOID Logout():
        MESSAGE "BEGIN LOGOUT".
        setBearerCredential().
        
        ASSIGN cAgent = poRequest:GetHeader('User-Agent'):VALUE.
            
        FIND FIRST usrtoken WHERE 
            usrtoken.usersid = cBearerUsername AND 
            usrtoken.type = cAgent
            EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE usrtoken THEN 
        DO:
            MESSAGE "LOGGING OUT FOR USER" usrtoken.usersid.
            DELETE usrtoken.
                    
            oResponse:StatusCode = 200.
            oJson:Add('success', TRUE).
            oJson:Add('message', 'Logout Successful').
        END.
        
        ELSE 
        DO:
            MESSAGE "LOGOUT FAILED, CREDENTIAL IS INVALID".
            oResponse:StatusCode = 400.
            oJson:Add('success', FALSE).
            oJson:Add('message', 'Credential invalid').
        END. 
        MESSAGE "END LOGOUT".
    END METHOD.
    
    /* VALIDATE BEARER TOKEN 
    ==================================================================================== */
    /* Validate token used by user to retrive resource ================= */
    METHOD PUBLIC LOGICAL ValidateToken():
        MESSAGE "BEGIN VALIDATE TOKEN".
        setBearerCredential().
            
        FIND FIRST usrtoken WHERE usrtoken.usersid = cBearerUsername NO-LOCK NO-ERROR.
        IF AVAILABLE usrtoken THEN 
        DO:
            MESSAGE "VALIDATING TOKEN FOR USER" usrtoken.usersid.
            IF usrtoken.token = cBearerToken AND usrtoken.expiry > NOW THEN DO:
                MESSAGE "VALIDATE SUCCESSFULL".
                RETURN TRUE.
            END.
            ELSE DO:
                MESSAGE "VALIDATE UNSUCCESSFULL, TOKEN IS INVALID".
                RETURN FALSE.    
            END.
        END.
        ELSE 
        DO:
            MESSAGE "NO USERNAME FOUND FOR " cBearerUsername VIEW-AS ALERT-BOX.
            RETURN FALSE.
        END. 
        RELEASE usrtoken.    
        MESSAGE "END VALIDATE TOKEN".
    END METHOD. 
    
    /* VALIDATE API KEY 
    ==================================================================================== */
    /* Validate API KEY ================= */ /* TODO : API KEY FOR USER IS SAVED ON DATABSE NOT IN DOT ENV */
    METHOD PRIVATE LOGICAL ValidateApiKey():
        /*DEFINE VARIABLE cApiKey AS CHARACTER NO-UNDO.
        
        MESSAGE "BEGIN VALIDATE API KEY".
        
        cApiKey = GetHeaderValue('Progress-Api-Key').
        cApiKey = oBase64Url:Decode(cApiKey).
        
        IF cApiKey = oEnv:GetValue("API_KEY") THEN DO:
            MESSAGE "API KEY IS VALID".
            RETURN TRUE.
        END.
            
        ELSE DO:
            MESSAGE "API KEY IS INVALID".
            RETURN FALSE.
        END.
        
        MESSAGE "END VALIDATE API KEY". */
    END METHOD.
    
    /* SET BASIC CREDENTIAL 
    ==================================================================================== */
    METHOD PRIVATE VOID SetBasicCredential():
        ASSIGN
            cBasicCredential = poRequest:GetHeader('Progress-Basic-Auth'):VALUE
            cBasicCredential = oBase64Url:Decode(cBasicCredential)      
            cBasicUsername   = ENTRY(1, cBasicCredential, ":")
            cBasicPassword   = ENTRY(2, cBasicCredential, ":")
            cBasicPassword   = Rehash(cBasicPassword)
            NO-ERROR.
            
    END METHOD.

    /* SET BEARER CREDENTIAL 
    ==================================================================================== */
    /* retrieve Credential from Bearer Auth Header =================*/
    METHOD PUBLIC VOID SetBearerCredential():
        ASSIGN 
            cBearerCredential = poRequest:GetHeader('Progress-Bearer-Auth'):VALUE
            cBearerCredential = oBase64Url:Decode(cBearerCredential)
            cBearerUsername   = ENTRY(1, cBearerCredential, ":")
            cBearerToken      = ENTRY(2, cBearerCredential, ":")
            NO-ERROR.
        
    END METHOD.
    
    /* GETBEARERUSERNAME 
    ==================================================================================== */
    METHOD PUBLIC CHARACTER GetBearerUsername():
        RETURN cBearerUsername.            
    END METHOD. 
    
    /* GETBEAREREXPIRE 
    ==================================================================================== */
    METHOD PUBLIC INTEGER GetBearerExpire():
        RETURN iBearerExpire.            
    END METHOD. 
    
    
    /* REHASH 
    ==================================================================================== */ 
    /* For hashing + salting retrieved password before stored 
     * to database, salt key is exclusive in .env file on every server */
    METHOD PRIVATE CHARACTER Rehash(INPUT ipKey AS CHARACTER):
        DEFINE VARIABLE hash_key AS CHARACTER NO-UNDO.
        
        ASSIGN hash_key = oEnv:GetValue("PHANTOM_KEY").
        
        IF hash_key = ? THEN DO:
            MESSAGE 'FATAL - HASH KEY WITH NULL VALUE IS PROHIBITED'.
            STOP.
        END.
        
        RETURN 
            STRING(
                HEX-ENCODE(
                    MESSAGE-DIGEST("HMAC-SHA-256", ipKey, hash_key)
            )).
             
    END METHOD.  
     
    /* GENERATE TOKEN FOR SUCCEFFUL LOGIN
    ==================================================================================== */
    METHOD PUBLIC LONGCHAR GenToken():
        SECURITY-POLICY:SYMMETRIC-ENCRYPTION-ALGORITHM = "AES_CBC_192".
        RETURN HEX-ENCODE(GENERATE-RANDOM-KEY).    
    END METHOD. 
    
    
    /* GENERATE EXPIRE TIME FOR TOKEN 
    ==================================================================================== */
    /* datetime + expire time in seconds */
    METHOD PUBLIC DATETIME GenExpire ():
        DEFINE VARIABLE currentDateTime AS DATETIME NO-UNDO.
        ASSIGN currentDateTime = NOW.
        
        
        RETURN DATETIME(ADD-INTERVAL(currentDateTime, 30, 'days')). /* 30 Days */
    END METHOD.
       
    
END CLASS.