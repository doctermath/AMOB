USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.
DEFINE VARIABLE oJson2 AS JsonObject NO-UNDO.

oJsonArr = NEW JsonArray().

DEFINE VARIABLE cbrcnam  AS CHARACTER.
DEFINE VARIABLE cagcnam  AS CHARACTER.
DEFINE VARIABLE ccusnam  AS CHARACTER.
DEFINE VARIABLE calamat  AS CHARACTER.
DEFINE VARIABLE cbus1    AS CHARACTER FORMAT 'x(5)'.
DEFINE VARIABLE cbus2    AS CHARACTER FORMAT 'x(5)'.
DEFINE VARIABLE cbus1ket AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE cbus2ket AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE ccondes  AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE cname    AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE cbrname  AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE ccountry AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE capldes  AS CHARACTER FORMAT 'x(55)'.
DEFINE VARIABLE corig    AS CHARACTER FORMAT 'x(55)'.

FOR EACH engpop WHERE uiddat >= 01/01/2000 BY agc BY brc:
    
    MESSAGE "Processing" engpop.serno.

    cagcnam = ''.
    FIND FIRST masag WHERE masag.agency = engpop.agc NO-LOCK NO-ERROR.
    IF AVAILABLE masag THEN cagcnam = masag.des.

    ASSIGN 
        ccusnam  = '' 
        cbus1    = '' 
        cbus2    = '' 
        cbus1ket = '' 
        cbus2ket = ''.
        
    FIND FIRST cusmas WHERE cusmas.cusno = engpop.cusno NO-LOCK NO-ERROR.
    IF AVAILABLE cusmas THEN ASSIGN ccusnam = cusmas.cusnam
            calamat = cusmas.addr1 + ' ' + cusmas.addr2
            cbus1   = cusmas.bus[1]
            cbus2   = cusmas.bus[2].
            
    FIND FIRST cusothm WHERE cusothm.cusno = engpop.cusno NO-LOCK NO-ERROR.
    IF AVAILABLE cusothm THEN ASSIGN ccusnam = cusothm.cusnam
            ccusnam = cusothm.cusnam
            calamat = cusothm.addr1 + ' ' + cusothm.addr2
            cbus1   = cusothm.bus.
                                      
    FIND FIRST bus WHERE bus.code = cbus1 NO-LOCK NO-ERROR.
    IF AVAILABLE bus THEN cbus1ket = bus.des.

    FIND FIRST bus WHERE bus.code = cbus2 NO-LOCK NO-ERROR.
    IF AVAILABLE bus THEN cbus2ket = bus.des.

    ccondes = ''.
    FIND FIRST cond WHERE cond.cond = engpop.cond NO-LOCK NO-ERROR.
    IF AVAILABLE cond THEN ccondes = cond.des.

    cname = ''.
    FIND FIRST oem WHERE oem.code = engpop.oem NO-LOCK NO-ERROR.
    IF AVAILABLE oem THEN cname = oem.des.

    cbrname = ''.
    FIND FIRST brand WHERE brand.code = engpop.oembrand NO-LOCK NO-ERROR.
    IF AVAILABLE brand THEN cbrname = brand.des.

    ccountry = ''.
    FIND FIRST country WHERE country.code = engpop.oemcountry NO-LOCK NO-ERROR.
    IF AVAILABLE country THEN ccountry = country.name.

    capldes = ''.
    FIND FIRST apl WHERE apl.apl = engpop.apl NO-LOCK NO-ERROR.
    IF AVAILABLE apl THEN capldes = apl.des.

    cbrcnam = ''.
    FIND FIRST brctable WHERE brctable.code = engpop.brc NO-LOCK NO-ERROR.
    IF AVAILABLE brctable THEN cbrcnam = brctable.nam.

    corig = ''.
    FIND FIRST cfoforg WHERE cfoforg.country = engpop.country NO-LOCK NO-ERROR.
    IF AVAILABLE cfoforg THEN corig = cfoforg.des.

    /* Add to Json Object */
    oJson2 = NEW JsonObject().
    oJson2:Add("agency", engpop.agc).
    oJson2:Add("agency name", cagcnam).
    oJson2:Add("Eng/Mch S/N", engpop.serno).
    oJson2:Add("Eng/Mch Model", engpop.prdno).
    oJson2:Add("year made", engpop.yrmade).
    oJson2:Add("Mch/Eng S/N", engpop.engno).
    oJson2:Add("Mch/Eng Model", engpop.engmod).
    oJson2:Add("comp code", engpop.compcode).
    oJson2:Add("job site", engpop.brcloc).
    oJson2:Add("job site location name", engpop.location).
    oJson2:Add("delivery date", engpop.deldat).
    oJson2:Add("mch mpdel", engpop.oemprdno).
    oJson2:Add("mch s/n", engpop.oemserno).
    oJson2:Add("rated HP", engpop.rathp).
    oJson2:Add("rated kwh", engpop.ratkwh).
    oJson2:Add("rated kva", engpop.ratkva).
    oJson2:Add("alternator", engpop.altern).
    oJson2:Add("alternator s/n", engpop.alternsn).
    oJson2:Add("attachment", engpop.attm).
    oJson2:Add("attachment s/n", engpop.attsn).
    oJson2:Add("daily op", engpop.dailyopr).
    oJson2:Add("current smr", engpop.cursmr).
    oJson2:Add("prev smr", engpop.prvsmr).
    oJson2:Add("lastrep dat", engpop.lstrepair).
    oJson2:Add("smr at repair", engpop.smratrep).
    oJson2:Add("prevchgdat", engpop.prvchdat).
    oJson2:Add("repair date", engpop.repairdat).
    oJson2:Add("config no", engpop.configno).
    oJson2:Add("cpl", engpop.cpl).
    oJson2:Add("nei no", engpop.neino).
    oJson2:Add("nei date", engpop.neidat).
    oJson2:Add("shop no", engpop.shopno).
    oJson2:Add("warranty", engpop.warper).
    oJson2:Add("transmission", engpop.transm).
    oJson2:Add("op weight", engpop.opweight).
    oJson2:Add("mast type", engpop.mast).
    oJson2:Add("fork length", engpop.fork).
    oJson2:Add("bucket type", engpop.buckett).
    oJson2:Add("bucket capacity", engpop.bucketc).
    oJson2:Add("tire front", engpop.tiref).
    oJson2:Add("tire rear", engpop.tirer).
    oJson2:Add("boom type", engpop.boomt).
    oJson2:Add("boom capacity", engpop.boomc).
    oJson2:Add("note", engpop.note).
    oJson2:Add("branch", engpop.brc).
    oJson2:Add("branch name", cbrcnam).
    oJson2:Add("original country", engpop.country).
    oJson2:Add("orig country des", corig).
    oJson2:Add("customer no", engpop.cusno).
    oJson2:Add("customer name", ccusnam).
    oJson2:Add("alamat", calamat).
    oJson2:Add("bus mrkt", cbus1).
    oJson2:Add("bus mrkt des", cbus1ket).
    oJson2:Add("bus part", cbus2).
    oJson2:Add("bus part des", cbus2ket).
    oJson2:Add("condition", engpop.cond).
    oJson2:Add("condition des", ccondes).
    oJson2:Add("distributor", engpop.oem).
    oJson2:Add("distributor name", cname).
    oJson2:Add("brand", engpop.oembrand).
    oJson2:Add("brand name", cbrname).
    oJson2:Add("oemcountry", engpop.oemcountry).
    oJson2:Add("country name", ccountry).
    oJson2:Add("application", engpop.apl).
    oJson2:Add("application des", capldes).
    oJson2:Add("uid", engpop.uid).
    oJson2:Add("uid dat", engpop.uiddat).
    oJsonArr:Add(oJson2).

END.

oJson:Add('data', oJsonArr).
