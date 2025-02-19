USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

FIND FIRST empmas WHERE empno = poRequest:URI:GetQueryValue('empno') NO-ERROR.

DEFINE TEMP-TABLE ttempmas LIKE empmas
    FIELD aaa AS CHAR.


CREATE ttempmas.
BUFFER-COPY empmas TO ttempmas.

oJson:READ(TEMP-TABLE ttEmpmas:HANDLE).
