DEF VAR cbrcnam AS CHAR.
DEF VAR cagcnam AS CHAR.
DEF VAR ccusnam AS CHAR.
DEF VAR calamat AS CHAR.
DEF VAR cbus1 AS CHAR FORM 'x(5)'.
DEF VAR cbus2 AS CHAR FORM 'x(5)'.
DEF VAR cbus1ket AS CHAR FORM 'x(55)'.
DEF VAR cbus2ket AS CHAR FORM 'x(55)'.
DEF VAR ccondes AS CHAR FORM 'x(55)'.
DEF VAR cname AS CHAR FORM 'x(55)'.
DEF VAR cbrname AS CHAR FORM 'x(55)'.
DEF VAR ccountry AS CHAR FORM 'x(55)'.
DEF VAR capldes AS CHAR FORM 'x(55)'.
DEF VAR corig AS CHAR FORM 'x(55)'.

OUTPUT to "C:\Users\User\Desktop\aaa.txt".
PUT UNFORM 'agency|agency name|Eng/Mch S/N|Eng/Mch Model|year made|Mch/Eng S/N|Mch/Eng Model|comp code|job site|job site location name|delivery date|mch mpdel|mch s/n|rated HP|rated kwh|rated kva|alternator|alternator s/n|attachment|attachment s/n|daily op|current smr|prev smr|lastrep dat|smr at repair|prevchgdat|repair date|config no|cpl|nei no|nei date|shop no|warranty|transmission|op weight|mast type|fork length|bucket type|bucket capacity|tire front|tire rear|boom type|boom capacity|note|branch|branch name|original country|orig country des|customer no|customer~  name|alamat|bus mrkt|bus mrkt des|bus part|bus part des|condition|condition des|distributor|distributor name|brand|brand name|oemcountry|country name|application|application des|uid|uid dat' SKIP. 

FOR EACH engpop WHERE uiddat >= 01/01/2000 BY agc BY brc:

cagcnam = ''.
FIND FIRST masag WHERE masag.agency = engpop.agc NO-LOCK NO-ERROR.
IF AVAIL masag THEN cagcnam = masag.des.

ASSIGN ccusnam = '' cbus1 = '' cbus2 = '' cbus1ket = '' cbus2ket = ''.
FIND FIRST cusmas WHERE cusmas.cusno = engpop.cusno NO-LOCK NO-ERROR.
IF AVAIL cusmas THEN ASSIGN ccusnam = cusmas.cusnam
                            calamat = cusmas.addr1 + ' ' + cusmas.addr2
                            cbus1 = cusmas.bus[1]
                            cbus2 = cusmas.bus[2].
FIND FIRST cusothm WHERE cusothm.cusno = engpop.cusno NO-LOCK NO-ERROR.
IF AVAIL cusothm THEN ASSIGN ccusnam = cusothm.cusnam
                             ccusnam = cusothm.cusnam
                             calamat = cusothm.addr1 + ' ' + cusothm.addr2
                             cbus1 = cusothm.bus.
                                      
FIND FIRST bus WHERE bus.code = cbus1 NO-LOCK NO-ERROR.
IF AVAIL bus THEN cbus1ket = bus.des.

FIND FIRST bus WHERE bus.code = cbus2 NO-LOCK NO-ERROR.
IF AVAIL bus THEN cbus2ket = bus.des.

ccondes = ''.
FIND FIRST cond WHERE cond.cond = engpop.cond NO-LOCK NO-ERROR.
IF AVAIL cond THEN ccondes = cond.des.

cname = ''.
FIND FIRST oem WHERE oem.code = engpop.oem NO-LOCK NO-ERROR.
IF AVAIL oem THEN cname = oem.des.

cbrname = ''.
FIND FIRST brand WHERE brand.code = engpop.oembrand NO-LOCK NO-ERROR.
IF AVAIL brand THEN cbrname = brand.des.

ccountry = ''.
FIND FIRST country WHERE country.code = engpop.oemcountry NO-LOCK NO-ERROR.
IF AVAIL country THEN ccountry = country.name.

capldes = ''.
FIND FIRST apl WHERE apl.apl = engpop.apl NO-LOCK NO-ERROR.
IF AVAIL apl THEN capldes = apl.des.

cbrcnam = ''.
FIND FIRST brctable WHERE brctable.code = engpop.brc NO-LOCK NO-ERROR.
IF AVAIL brctable THEN cbrcnam = brctable.nam.

corig = ''.
FIND FIRST cfoforg WHERE cfoforg.country = engpop.country NO-LOCK NO-ERROR.
IF AVAIL cfoforg THEN corig = cfoforg.des.

PUT UNFORM "'" + engpop.agc "|" cagcnam "|" "'" + engpop.serno "|" engpop.prdno "|" engpop.yrmade "|" "'" + engpop.engno "|" engpop.engmod "|" engpop.compcode "|" engpop.brcloc "|" engpop.location "|" engpop.deldat "|" engpop.oemprdno "|" "'" + engpop.oemserno "|" engpop.rathp "|" engpop.ratkwh "|" engpop.ratkva "|" engpop.altern "|" engpop.alternsn "|" engpop.attm "|" engpop.attsn "|" engpop.dailyopr "|" engpop.cursmr "|" engpop.prvsmr "|" engpop.lstrepair "|" engpop.smratrep "|" engpop.prvchdat "|" engpop.repairdat "|" engpop.configno "|" engpop.cpl "|" engpop.neino "|" engpop.neidat "|" engpop.shopno "|" engpop.warper "|" engpop.transm "|" engpop.opweight "|" engpop.mast "|" engpop.fork "|" engpop.buckett "|" engpop.bucketc "|" engpop.tiref "|" engpop.tirer "|" engpop.boomt "|" engpop.boomc "|" engpop.note "|" engpop.brc "|" cbrcnam "|" engpop.country "|" corig "|" engpop.cusno "|" ccusnam "|" calamat "|" cbus1 "|" cbus1ket "|" cbus2 "|" cbus2ket '|' engpop.cond "|" ccondes "|" engpop.oem "|" cname "|" engpop.oembrand "|" cbrname "|" engpop.oemcountry "|" ccountry "|" engpop.apl "|" capldes "|" engpop.uid "|" engpop.uiddat SKIP.

END.

OUTPUT close.
