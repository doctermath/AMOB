USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE VARIABLE ix AS INTEGER NO-UNDO.

oJson:Add('status', "Ran From Main.p").
oJson:Add('message', 'stay away from me').

    