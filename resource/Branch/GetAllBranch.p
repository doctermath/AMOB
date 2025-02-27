/* get list of company branches */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE TEMP-TABLE ttBrctable 
    FIELD brc LIKE brctable.brc
    FIELD nam LIKE brctable.nam
    FIELD code LIKE brctable.code
    FIELD addr LIKE brctable.addr
    FIELD city LIKE brctable.city
    FIELD statbranch LIKE brctable.statbranch
    FIELD ncode LIKE brctable.ncode
    FIELD act LIKE brctable.act
    .
    
DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.

FOR EACH brctable:
    CREATE ttBrctable.
    BUFFER-COPY brctable TO ttBrctable.
END.

oJsonArr = NEW JsonArray().
TEMP-TABLE ttBrctable:WRITE-JSON("JsonArray", oJsonArr).

oJson:Add('data', oJsonArr).
