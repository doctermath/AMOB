
BLOCK-LEVEL ON ERROR UNDO, THROW.

USING OpenEdge.Web.WebHandler FROM PROPATH.
USING OpenEdge.Web.WebResponseWriter FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

CLASS superHandler INHERITS WebHandler: 
    
    /* Private variable definitions */
    DEFINE PRIVATE VARIABLE oAuth     AS Core.Security.Auth       NO-UNDO.
    DEFINE PRIVATE VARIABLE oAccount  AS Core.Security.Account    NO-UNDO.
    DEFINE PRIVATE VARIABLE oEnv      AS Core.Utilities.Env       NO-UNDO.
    DEFINE PRIVATE VARIABLE oResponse AS OpenEdge.Web.WebResponse NO-UNDO.
    DEFINE PRIVATE VARIABLE oJson     AS JsonObject               NO-UNDO.
    
    DEFINE PRIVATE VARIABLE cUri      AS CHARACTER                NO-UNDO.
    DEFINE PRIVATE VARIABLE lValidUri AS LOGICAL                  NO-UNDO.
    
    METHOD OVERRIDE PROTECTED INTEGER HandleNotAllowedMethod( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT ALLOWED").
    END METHOD.

    METHOD OVERRIDE PROTECTED INTEGER HandleNotImplemented( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
        UNDO, THROW NEW Progress.Lang.AppError("METHOD NOT IMPLEMENTED").
    END METHOD.

    /* Get Method */
    METHOD OVERRIDE PROTECTED INTEGER HandleGet( INPUT poRequest AS OpenEdge.Web.IWebRequest ):
          
        /* Object Declarations  */      
        ASSIGN 
            oResponse            = NEW OpenEdge.Web.WebResponse()
            oJson                = NEW JsonObject()
            oAuth                = NEW Core.Security.Auth(poRequest, oJson, oResponse)
            oAccount             = NEW Core.Security.Account(oAuth, poRequest, oJson, oResponse)
            oResponse:StatusCode = 200
            .
        
        IF oAuth:ValidateToken() THEN 
        DO:
            /* URI Conditioning */
            cUri = RIGHT-TRIM(poRequest:UriTemplate, '/':u).
            CASE cUri:
                /* Customer Services */
                WHEN '/pas128ext' THEN 
                    DO:
                        MESSAGE ENTRY(1, PROPATH)
                            VIEW-AS ALERT-BOX.
                        oJson:Add('hello', 'cursor').                    
                    END.
            
    
            END CASE.
        END.
           
        /* unauthorized */    
        ELSE 
        DO:
            oResponse:StatusCode = 401. 
            oJson:Add('success', FALSE).
            oJson:Add('message', 'Invalid Credential').   
        END.

        /* Response Content
        ================================================================= */           
        ASSIGN 
            oResponse:Entity      = ojson
            oResponse:ContentType = 'application/json'.
           
        sendResponse(oResponse).
        RETURN 0.
        
    END METHOD. 
    
    
    /* Response Writer */
    METHOD PROTECTED VOID sendResponse(INPUT oResponse AS OpenEdge.Web.WebResponse):
        DEFINE VARIABLE oWriter AS OpenEdge.Web.WebResponseWriter NO-UNDO.
           
        oWriter = NEW WebResponseWriter(oResponse).
            
        oWriter:Open().
        oWriter:Close().
        
    END METHOD.
    
END CLASS.