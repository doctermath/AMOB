/* Handler Gate
 * For Routing HTTP Method to corresponding handler procedure 
 * ======================================================================= */
 
USING Progress.Json.ObjectModel.JsonObject.
USING OpenEdge.Web.IWebRequest.

DEFINE INPUT  PARAMETER httpMethod AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER poRequest  AS IWebRequest NO-UNDO.

/* Variable and Object Declaration 
======================================================== */ 
DEFINE VARIABLE oResponse   AS OpenEdge.Web.WebResponse NO-UNDO.
DEFINE VARIABLE mHandler    AS Core.Master.Handler      NO-UNDO.
DEFINE VARIABLE oAuth       AS Core.Security.Auth       NO-UNDO.
DEFINE VARIABLE oEnv        AS Core.Utilities.Env       NO-UNDO.
DEFINE VARIABLE oJson       AS JsonObject               NO-UNDO.
DEFINE VARIABLE cUri        AS CHARACTER                NO-UNDO.
DEFINE VARIABLE cHandler    AS CHARACTER                NO-UNDO.
DEFINE VARIABLE lNoResource AS LOGICAL                  NO-UNDO.

ASSIGN 
    oResponse            = NEW OpenEdge.Web.WebResponse()
    mHandler             = NEW Core.Master.Handler()
    oJson                = NEW JsonObject()
    oAuth                = NEW Core.Security.Auth(INPUT poRequest, INPUT ojson, oResponse)
    oEnv                 = NEW Core.Utilities.Env()
    oResponse:StatusCode = 200.
    
/* Handler Method Selection 
======================================================== */      
CASE httpMethod:
    WHEN 'GET'    THEN ASSIGN cHandler = 'handlers/getHandler.p'.
    WHEN 'POST'   THEN ASSIGN cHandler = 'handlers/postHandler.p'.
    WHEN 'PUT'    THEN ASSIGN cHandler = 'handlers/putHandler.p'.
    WHEN 'DELETE' THEN ASSIGN cHandler = 'handlers/deleteHandler.p'.
END CASE.

/* URL Routing 
======================================================== */  
cUri = RIGHT-TRIM(poRequest:PathInfo, '/').

/* Authentication */
IF cUri BEGINS '/auth/' THEN 
DO:
    CASE SUBSTRING (cUri, 6):
        WHEN '/login' THEN 
            oAuth:Login().
        WHEN '/register' THEN 
            oAuth:Register().
        WHEN '/logout' THEN 
            IF oAuth:ValidateToken() THEN 
                oAuth:Logout().
        OTHERWISE 
        DO:
            oResponse:StatusCode = 400.
            oJson:Add('success', FALSE).
            oJson:Add('message', 'Invalid Authentication Parameter').
        END.
    END CASE.
END.

/* Testing Procedure, only available in developtment enviroments */
ELSE IF cUri BEGINS '/test/' THEN 
    IF oEnv:GetValue('APP_ENV') = 'development' THEN 
        RUN VALUE (SUBSTRING(cUri, 2) + '.p') (INPUT poRequest, INPUT oJson).
    ELSE STOP.

/* Guest Procedure, available for guest that able to request resource without authentication */
ELSE IF cUri BEGINS '/guest/' THEN 
DO:
    RUN VALUE(cHandler) (
        INPUT  "GUEST",
        INPUT  SUBSTRING (cUri, 7), 
        INPUT  poRequest, 
        INPUT  oJson, 
        OUTPUT lNoResource).
        
    IF lNoResource THEN DO:
        oResponse:StatusCode = 404.
        oJson:Add('success', FALSE).
        oJson:Add('message', 'Guest Resource Not Found').
    END.
END.

/* Resources */
ELSE DO:
    /* Check Validation */
    IF oAuth:ValidateToken() THEN DO:
        RUN VALUE(cHandler) (
            INPUT  "VALIDATE",
            INPUT  cUri, 
            INPUT  poRequest, 
            INPUT  oJson, 
            OUTPUT lNoResource).
        
        IF lNoResource THEN DO:
            oResponse:StatusCode = 404.
            oJson:Add('success', FALSE).
            oJson:Add('message', 'Resource Not Found').
        END.
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

 