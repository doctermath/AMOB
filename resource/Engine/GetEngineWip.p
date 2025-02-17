/* getEngineWip */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

/* Object Input Parameter */
DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.
    
DEFINE VARIABLE ccusno         AS CHARACTER  NO-UNDO.
DEFINE VARIABLE iJobStat       AS INTEGER NO-UNDO.
DEFINE VARIABLE oJsonJobm      AS JsonObject NO-UNDO.
DEFINE VARIABLE oJsonArr       AS JsonArray  NO-UNDO. 

DEFINE VARIABLE oJsonJobser    AS JsonObject NO-UNDO.
DEFINE VARIABLE oJsonArrJobser AS JsonArray  NO-UNDO.
         
DEFINE VARIABLE oJsonJobseg    AS JsonObject NO-UNDO.  
DEFINE VARIABLE oJsonArrJobseg AS JsonArray  NO-UNDO.

MESSAGE '123 run from yordanxx'
    VIEW-AS ALERT-BOX INFO BUTTONS OK.
    
ccusno = poRequest:URI:GetQueryValue('cusno').
oJsonArr = NEW JsonArray().
    
/* Retrieving Data */
FOR EACH jobm WHERE jobm.cusno = ccusno NO-LOCK:
    oJsonJobm = NEW JsonObject().
    FIND FIRST brctable WHERE brctable.code = jobm.brc NO-LOCK NO-ERROR.
    
    iJobStat = 0.
    
    IF jobm.jobno <> '' THEN
        iJobStat = 2.
        
    IF jobm.jobno <> '' AND jobm.refno <> '' OR jobm.refnosi <> '' THEN
        iJobStat = 4.

    oJsonJobm:Add('Job No', SUBSTITUTE("&1-&2/&3/&4/&5",
        jobm.jobtype,
        SUBSTRING(jobm.jobno,3,4),
        jobm.agency,
        brctable.code,
        YEAR(jobm.jobdat)
        )) NO-ERROR.
        
    oJsonJobm:Add('Ref No. Parts', jobm.refno) NO-ERROR.
    oJsonJobm:Add('Ref No Service', jobm.refnosi) NO-ERROR. 
    oJsonJobm:Add('Open Date', jobm.jobdat) NO-ERROR.
    oJsonJobm:Add('Closing Date', jobm.duedat) NO-ERROR.
             
    /* Job Status */
    oJsonJobm:Add('Job Status', iJobStat) NO-ERROR.

    /* Adding to Array */
    oJsonArr:Add(oJsonJobm).
END.
    
oJson:Add('data', oJsonArr).





