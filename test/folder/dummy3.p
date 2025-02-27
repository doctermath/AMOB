USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.

oJson:Add('biji', 'jambu').

/*DEFINE TEMP-TABLE ttempmas LIKE empmas.                             */
/*FOR EACH  empmas WHERE empno = poRequest:URI:GetQueryValue('empno'):*/
/*    CREATE ttempmas.                                                */
/*    BUFFER-COPY empmas TO ttempmas.                                 */
/*END.                                                                */
/*                                                                    */
/*oJson:READ(TEMP-TABLE ttEmpmas:HANDLE).                             */
