USING Progress.Json.ObjectModel.JsonObject.

DEFINE INPUT  PARAMETER poRequest AS OpenEdge.Web.IWebRequest NO-UNDO.

/* Variable and Object Declaration 
======================================================== */ 
DEFINE VARIABLE oResponse AS OpenEdge.Web.WebResponse NO-UNDO.
DEFINE VARIABLE mHandler  AS Core.Master.Handler      NO-UNDO.
DEFINE VARIABLE oAuth     AS Core.Security.Auth       NO-UNDO.
DEFINE VARIABLE oJson     AS JsonObject               NO-UNDO.
DEFINE VARIABLE cUri      AS CHARACTER                NO-UNDO.
    
ASSIGN 
    oResponse            = NEW OpenEdge.Web.WebResponse()
    mHandler             = NEW Core.Master.Handler()
    oJson                = NEW JsonObject()
    oAuth                = NEW Core.Security.Auth(INPUT poRequest, INPUT ojson, oResponse)

    oResponse:StatusCode = 200
    .

/* URL Routing 
======================================================== */  
cUri = RIGHT-TRIM(poRequest:UriTemplate, '/':u).

/* Authentication (PAS128AUTH) */
IF cUri = '/auth/~{param~}' THEN DO:
    CASE poRequest:GetPathParameter("param"):
        WHEN 'login' THEN 
            oAuth:Login().
        WHEN 'register' THEN 
            oAuth:Register().
        WHEN 'logout' THEN 
            IF oAuth:ValidateToken() THEN 
                oAuth:Logout().
    END CASE.
END.

/* Resources */
ELSE DO:
    /* Check Validation */
    IF oAuth:ValidateToken() THEN DO:
        CASE cUri:
            /* PAS128INT */
            WHEN '/get-employee-data' THEN
            RUN resource/getEmployeeData.p (INPUT poRequest, INPUT oJson).
            
            WHEN '/run/~{script~}' THEN
            RUN VALUE('resource/' + poRequest:GetPathParameter("script") + '.p') (INPUT poRequest, INPUT oJson).
        
            WHEN '/pas128int' THEN 
                oJson:Add('hello', 'cursor').                    
    
            /* PAS128EXT */
            WHEN '/pas128ext' THEN 
                oJson:Add('hello', 'slack').  
                
            /* PAS128PRO */          
            WHEN '/pas128pro' THEN 
                oJson:Add('hello', 'everyday').
    
        END CASE.
    END.
    
    /* If Unvalidated */
    ELSE DO:
        oResponse:StatusCode = 401. 
        oJson:Add('success', FALSE).
        oJson:Add('message', 'Invalid Credential').   
    END.    
END.

/* Response Content 
======================================================== */   
mHandler:jsonResponse(INPUT oJson, INPUT oResponse).   

