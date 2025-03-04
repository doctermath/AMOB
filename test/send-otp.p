USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE VARIABLE script AS CHARACTER NO-UNDO.
DEFINE VARIABLE result AS CHARACTER NO-UNDO.

ASSIGN script = "python " + ENTRY(1, PROPATH) + "/python/mail/send-otp.py " + 
    poRequest:URI:GetQueryValue('otp') + " " + 
    poRequest:URI:GetQueryValue('recipient').

INPUT THROUGH VALUE(script) NO-ECHO.
IMPORT UNFORMATTED result.
INPUT CLOSE.

oJson:Add('succeed', TRUE).
oJson:Add('script', script).
oJson:Add('result', result).