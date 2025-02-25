USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

DEFINE TEMP-TABLE ttxuser LIKE xtools.xuser.

DEFINE VARIABLE ix AS INTEGER NO-UNDO.

FOR EACH xtools.xuser WHERE chuserid BEGINS  poRequest:URI:GetQueryValue('chuserid'):
    IF ix > 10 THEN LEAVE. ELSE ix = ix + 1.
    CREATE ttxuser.
    BUFFER-COPY xtools.xuser TO ttxuser.    
END.

MESSAGE 123
VIEW-AS ALERT-BOX.

oJson:READ(TEMP-TABLE ttxuser:HANDLE).

