/* getCustomersByBranch */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

DEFINE VARIABLE ix AS INTEGER NO-UNDO.

DEFINE TEMP-TABLE ttcusmastr
    FIELD custype LIKE cusmastr.custype
    FIELD cusno   LIKE cusmastr.cusno
    FIELD cusnam  LIKE cusmastr.cusnam.
 
    
/* Object Input Parameter */
DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.
    
DEFINE VARIABLE cbrc     AS CHARACTER NO-UNDO.
DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.  
            
ix = 0.
cbrc = poRequest:URI:GetQueryValue('brc').           
oJsonArr   = NEW JsonArray().
    
FOR EACH engpop WHERE engpop.cusno BEGINS cbrc NO-LOCK BREAK BY engpop.cusno:
    IF FIRST-OF(engpop.cusno) THEN 
    DO:
        CREATE ttCusmastr.
        ASSIGN 
            ttCusmastr.cusno = engpop.cusno.
              
        FOR FIRST cusmastr WHERE cusmastr.cusno = engpop.cusno NO-LOCK :
            ASSIGN 
                ttCusmastr.cusnam  = cusmastr.cusnam
                ttCusmastr.custype = cusmastr.custype.
        END.
    END.
END.
    
oJsonArr:READ(TEMP-TABLE ttCusmastr:HANDLE).
oJson:Add('data', oJsonArr).

