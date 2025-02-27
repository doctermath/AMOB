/* getEnginesByCusno */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

DEFINE TEMP-TABLE ttEngpop 
    FIELD serno LIKE engpop.serno
    FIELD agc   LIKE engpop.agc
    FIELD uiddat LIKE engpop.uiddat.
  
/* Object Input Parameter */
DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.
        
DEFINE VARIABLE ccusno   AS CHARACTER NO-UNDO.
DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.
            
ccusno = poRequest:URI:GetQueryValue('cusno').
oJsonArr = NEW JsonArray().
            
FOR EACH engpop WHERE engpop.cusno = ccusno NO-LOCK BREAK BY engpop.serno BY engpop.agc:
    IF FIRST-OF(engpop.agc) THEN 
    DO:
        CREATE ttEngpop.
        ASSIGN
            ttEngpop.serno = engpop.serno
            ttEngpop.agc   = engpop.agc
            ttEngpop.uiddat   = engpop.uiddat.
    END.
END.
    
oJsonArr:read(TEMP-TABLE ttEngpop:HANDLE).
ojson:Add('data', oJsonArr).
    
