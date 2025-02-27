/* ** */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
    
/* Object Input Parameter */
DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.
DEFINE INPUT PARAMETER oAuth        AS Core.Security.Auth NO-UNDO.

DEFINE VARIABLE ix AS INTEGER NO-UNDO.
DEFINE VARIABLE iy AS INTEGER NO-UNDO.

DEFINE TEMP-TABLE ttjobm LIKE jobm.

FOR EACH jobm:
    ix = ix + 1.
    IF ix > 100 THEN LEAVE.
    CREATE ttjobm.
    BUFFER-COPY jobm TO ttjobm.
END.

DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.

oJsonArr = NEW JsonArray().
TEMP-TABLE ttjobm:WRITE-JSON ('JsonArray', oJsonArr, TRUE).
    

oJson:Add('name', oAuth:GetBearerUsername()).
oJson:Add('history', 'kaps').
oJson:add('data', oJsonArr).
    

