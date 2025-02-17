/* getEngineDetails */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

DEFINE TEMP-TABLE ttEnghis LIKE enghis
    FIELD jobtype LIKE jobm.jobtype.
    
/* Object Input Parameter */
DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.
DEFINE VARIABLE cserno   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cagc     AS CHARACTER NO-UNDO.

cserno = poRequest:URI:GetQueryValue('serno').
cagc = poRequest:URI:GetQueryValue('agc').

FOR FIRST engpop WHERE engpop.serno = cserno AND engpop.agc = cagc NO-LOCK:
    
    FIND FIRST invmastr WHERE engpop.prdno = invmastr.prd-no NO-LOCK NO-ERROR.
    IF AVAILABLE invmastr THEN 
        oJson:Add("brand", invmastr.brand).
    ELSE 
        oJson:Add("brand", "Not Available").
    
    FIND FIRST brctable WHERE brctable.code = engpop.brcloc NO-LOCK NO-ERROR.
    IF AVAILABLE brctable THEN 
        oJson:Add("brcnam", brctable.nam).
    ELSE 
        oJson:Add("brcnam", "Not Available").
    
    FIND FIRST cusmastr WHERE cusmastr.cusno = engpop.cusno NO-LOCK NO-ERROR.
    IF AVAILABLE cusmastr THEN 
        oJson:Add("cusnam", cusmastr.cusnam).
    ELSE 
        oJson:Add("cusnam", "Not Available").
    
    FIND FIRST masag WHERE masag.agency = engpop.agc NO-LOCK NO-ERROR.
    IF AVAILABLE masag THEN 
        oJson:Add("desc_agn", masag.desc_agn).
    ELSE 
        oJson:Add("desc_agn", "Not Available").

END.

     
FOR EACH enghis WHERE enghis.serno = cserno AND enghis.agency = cagc NO-LOCK:
    CREATE ttEnghis.
    BUFFER-COPY enghis TO ttEnghis.
    
    FIND FIRST jobm WHERE jobm.jobno = enghis.jobno AND jobm.agency = enghis.agency NO-LOCK NO-ERROR.
    IF AVAILABLE jobm THEN 
    DO:
        ASSIGN ttEnghis.jobtype = jobm.jobtype.    
    END.
    ELSE DO:
        ASSIGN 
            ttEnghis.jobtype = "Not Available".
    END.   
END.


oJsonArr = NEW JsonArray().
oJsonArr:Read(TEMP-TABLE ttEnghis:HANDLE).
oJson:Add('history', oJsonArr).
    

