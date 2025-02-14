
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


    /* Login With Basic Auth ================= */
    METHOD PUBLIC VOID Login():
        /* Just for logging on server */
        MESSAGE "BEGIN LOGIN".
        
        setBasicCredential().
        
        /* Find user credential to database */
        /* Use exclusive lock because yuserd need to be updated */
        MESSAGE "CHECKING USER" cBasicUsername "IN USER DATABASE".
        FIND FIRST yusers WHERE yusers.username = cBasicUsername EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE yusers THEN 
        DO:
            MESSAGE "USERNAME FOUND".
            IF yusers.password = cBasicPassword THEN 
            DO:
                MESSAGE "PASSWORD CORRECT".
                /* generate token and expiry */
                ASSIGN
                    yusers.token        = genToken()
                    yusers.expiry_epoch = genExpire()
                    .
                
                /* send response */
                oJson:Add('success', TRUE).
                oJson:Add('message', 'Login Successful').  
                oJson:Add('username', yusers.username).
                oJson:Add('role', yusers.role).
                oJson:Add('cusno', yusers.cusno).
                oJson:Add('token', yusers.token).
                oJson:Add('expire', yusers.expiry_epoch).  
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
        
        RELEASE yusers NO-ERROR.
        MESSAGE "END LOGIN".
    END METHOD. 
    
    
    /* Register an account to database ================= */
    METHOD PUBLIC VOID Register():
        DEFINE VARIABLE iLastUserId AS INTEGER   NO-UNDO.
        DEFINE VARIABLE cRole       AS CHARACTER NO-UNDO.
        DEFINE VARIABLE cCusno      AS CHARACTER NO-UNDO.
        
        MESSAGE "BEGIN REGISTER".
        
        setBasicCredential().
        
        cRole = poRequest:URI:GetQueryValue('role').
        cCusno = poRequest:URI:GetQueryValue('cusno').
        
        /* Check if account already exists on database */
        FIND FIRST yusers WHERE yusers.username = cBasicUsername NO-LOCK NO-ERROR.
        IF AVAILABLE yusers THEN 
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
            FIND LAST yusers NO-LOCK NO-ERROR.
            IF AVAILABLE yusers THEN ASSIGN 
                    iLastUserId = yusers.id.
            ELSE 
                iLastUserId = 0.
                        
            CREATE yusers.
            ASSIGN
                yusers.id       = iLastUserId + 1
                yusers.username = cBasicUsername
                yusers.password = cBasicPassword
                yusers.role     = cRole.
            IF (cRole = "customer") THEN
                ASSIGN yusers.cusno = cCusno.
            ELSE
                ASSIGN yusers.cusno = "Not Available".
                
            oJson:Add('success', TRUE).
            oJson:Add('message', 'Username ' + cBasicUsername + ' successfully created with ID: ' + STRING(yusers.id)).
        END.
        RELEASE yusers NO-ERROR.
        MESSAGE "END REGISTER".
    END METHOD.
    
    
    /* Delete Database Token and Expiry_Epoch of a user ================= */
    METHOD PUBLIC VOID Logout():
        MESSAGE "BEGIN LOGOUT".
        setBearerCredential().
            
        FIND FIRST yusers WHERE 
            yusers.username = cBearerUsername AND 
            yusers.token = cBearerToken AND 
            yusers.expiry_epoch > GetCurrentEpoch()
            EXCLUSIVE-LOCK NO-ERROR.
        IF AVAILABLE yusers THEN 
        DO:
            MESSAGE "LOGGING OUT FOR USER" yusers.username.
            ASSIGN
                yusers.token        = ""
                yusers.expiry_epoch = 0.
                    
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
    
    
    /* Validate token used by user to retrive resource ================= */
    METHOD PUBLIC LOGICAL ValidateToken():
        MESSAGE "BEGIN VALIDATE TOKEN".
        setBearerCredential().
            
        FIND FIRST yusers WHERE yusers.username = cBearerUsername NO-LOCK NO-ERROR.
        IF AVAILABLE yusers THEN 
        DO:
            MESSAGE "VALIDATING TOKEN FOR USER" yusers.username.
            IF yusers.token = cBearerToken AND yusers.expiry_epoch > GetCurrentEpoch() THEN DO:
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
        MESSAGE "END VALIDATE TOKEN".
    END METHOD. 
    
    /* Validate API KEY ================= */
    METHOD PRIVATE LOGICAL ValidateApiKey():
        DEFINE VARIABLE cApiKey AS CHARACTER NO-UNDO.
        
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
        
        MESSAGE "END VALIDATE API KEY". 
    END METHOD.
    
    
    /* Get Header value sent by client ================= */
    METHOD PRIVATE CHARACTER GetHeaderValue(INPUT cHeader AS CHARACTER):
        RETURN 
            ENTRY(2, STRING(poRequest:GetHeader(cHeader)), " ").
    END METHOD. 
    
    
    /* retrive Credential from Basic Auth Header ================= */
    METHOD PRIVATE VOID SetBasicCredential():
        ASSIGN
            cBasicCredential = GetHeaderValue('Progress-Basic-Auth')
            cBasicCredential = oBase64Url:Decode(cBasicCredential)      
            cBasicUsername   = ENTRY(1, cBasicCredential, ":")
            cBasicPassword   = ENTRY(2, cBasicCredential, ":")
            cBasicPassword   = Rehash(cBasicPassword)
            NO-ERROR.
            
    END METHOD.

    /* retrieve Credential from Bearer Auth Header =================*/
    METHOD PUBLIC VOID SetBearerCredential():
        ASSIGN 
            cBearerCredential = GetHeaderValue('Progress-Bearer-Auth')
            cBearerCredential = oBase64Url:Decode(cBearerCredential)
            cBearerUsername   = ENTRY(1, cBearerCredential, ":")
            cBearerToken      = ENTRY(2, cBearerCredential, ":")
            NO-ERROR.
        
    END METHOD.
    
    
    METHOD PUBLIC CHARACTER GetBearerUsername():
        RETURN cBearerUsername.            
    END METHOD. 
    
    
    METHOD PUBLIC INTEGER GetBearerExpire():
        RETURN iBearerExpire.            
    END METHOD. 
    
     
    /* For hashing + salting retrieved password before stored =================
     * to database, salt key is exclusive in .env file on every server */
    METHOD PRIVATE CHARACTER Rehash(INPUT ipKey AS CHARACTER):
        RETURN 
            STRING(
            HEX-ENCODE(
            MESSAGE-DIGEST("HMAC-SHA-256", ipKey, oEnv:GetValue("PHANTOM_KEY"))
            )).
             
    END METHOD.  
     
    /* generate token on successful login ================= */
    METHOD PUBLIC CHARACTER GenToken():
        DEFINE VARIABLE token AS CHARACTER NO-UNDO.
        DEFINE VARIABLE ix   AS INTEGER   NO-UNDO.

        /* Generate a 32-character long token */
        DO ix = 1 TO 32:
            token = token + CHR(RANDOM(97, 122)). /* Append random lowercase letter */
        END.

        RETURN token.     
    END METHOD. 
    
    
    /* get current time in linux epoch format ================= */
    METHOD PUBLIC INT64 GetCurrentEpoch():
        DEFINE VARIABLE datetime AS DATETIME NO-UNDO.
        DEFINE VARIABLE epoch    AS INT64    NO-UNDO.
        
        datetime = DATETIME(1,1,1970,0,0,0,0).
        epoch = INTERVAL ( NOW, datetime , "seconds" ).
    
        RETURN epoch.
    END METHOD.
    
    /* generate expire time for token expiration ================= */
    /* Epoch time + expire time in seconds */
    METHOD PUBLIC INT64 GenExpire ():
        RETURN GetCurrentEpoch() + (30 * 24 * 60 * 60).
    END METHOD.
       
    
END CLASS.