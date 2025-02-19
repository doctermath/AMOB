USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.
DEFINE VARIABLE oEnv AS Core.Utilities.Env NO-UNDO.

oEnv = NEW Core.Utilities.Env().

oJson:Add('PHANTOM_KEY',  oEnv:getValue('PHANTOM_KEY') ).
oJson:Add('APP',  oEnv:getValue('APP') ).
oJson:Add('LIST',  oEnv:getVariables() ).
oJson:Add('kacau', 'Balau').