USING OpenEdge.Web.WebResponseWriter.
USING Progress.Json.ObjectModel.JsonObject.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.Master.Handler: 
    DEFINE VARIABLE oWriter   AS OpenEdge.Web.WebResponseWriter  NO-UNDO.
    
    /* Get Env Value by Variable Name */
    METHOD PUBLIC VOID jsonResponse(INPUT ojson AS JsonObject, INPUT oResponse AS OpenEdge.Web.WebResponse):
        oResponse:Entity      = ojson.
        oResponse:ContentType = 'application/json'.       
        sendResponse(oResponse).      
    END METHOD.
    
    METHOD PUBLIC VOID sendResponse(INPUT oResponse AS OpenEdge.Web.WebResponse):
        oWriter = NEW WebResponseWriter(oResponse).
        oWriter:Open().
        oWriter:Close().        
    END METHOD.
    
END CLASS.