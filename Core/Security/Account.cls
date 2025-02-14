
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Web.IWebRequest FROM PROPATH.
USING OpenEdge.Web.WebResponse FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS Core.Security.Account:
    DEFINE PRIVATE VARIABLE poRequest AS IWebRequest        NO-UNDO.
    DEFINE PRIVATE VARIABLE oJson     AS JsonObject         NO-UNDO.
    DEFINE PRIVATE VARIABLE oResponse AS WebResponse        NO-UNDO.
    DEFINE PRIVATE VARIABLE oAuth     AS Core.Security.Auth NO-UNDO.
     
    /* Constructor */
    CONSTRUCTOR PUBLIC Account(
        INPUT oAuth     AS Core.Security.Auth,
        INPUT poRequest AS IWebRequest, 
        INPUT ojson     AS JsonObject, 
        INPUT oResponse AS WebResponse):
        
        ASSIGN 
            THIS-OBJECT:oAuth     = oAuth
            THIS-OBJECT:poRequest = poRequest
            THIS-OBJECT:oJson     = oJson
            THIS-OBJECT:oResponse = oResponse
            .
                        
    END CONSTRUCTOR.
    
    METHOD PUBLIC VOID GetProfile():
         
        oJson:Add('username', oAuth:GetBearerUsername()). 
        oJson:Add('expire', oAuth:GetBearerExpire()).
        oJson:Add('test', 'test').    
    END METHOD.
    
END CLASS.