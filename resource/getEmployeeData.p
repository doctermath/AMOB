USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE VARIABLE ix AS INTEGER NO-UNDO.
DEFINE VARIABLE oJsonArr AS JsonArray NO-UNDO.

oJsonArr = NEW JsonArray().

DEFINE TEMP-TABLE ttdata LIKE empmas.

FOR EACH empmas WHERE empmas.outdate = ? NO-LOCK:
    IF ix > 10 THEN LEAVE. ELSE ix = ix + 1.
    CREATE ttdata.
    BUFFER-COPY empmas TO ttdata.
END.
    
oJsonArr:READ(TEMP-TABLE ttdata:HANDLE).
ojson:add('data', oJsonArr).