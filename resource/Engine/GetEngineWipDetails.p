/* getEngineWip */

BLOCK-LEVEL ON ERROR UNDO, THROW.

USING Core.Utilities.Env.
USING Progress.Json.ObjectModel.JsonArray FROM PROPATH.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

/* Object Input Parameter */
DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.
    
    


DEFINE VARIABLE oo AS Core.Utilities.Env NO-UNDO.
oo = NEW Core.Utilities.Env().

oJson:Add('hhx', 123123).
oJson:Add('meteor', oo:GetValue('PHANTOM_KEY')).





