/* POST Handler
 * For Routing HTTP POST Method to corresponding procedure 
 * ======================================================================= */
 
USING Progress.Json.ObjectModel.JsonObject.
USING OpenEdge.Web.IWebRequest.

DEFINE INPUT  PARAMETER cUser       AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER cUri        AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER poRequest   AS IWebRequest NO-UNDO.
DEFINE INPUT  PARAMETER oJson       AS JsonObject  NO-UNDO.
DEFINE OUTPUT PARAMETER lNoResource AS LOGICAL   NO-UNDO.

IF cUser = 'PUBLIC' THEN 
DO:
    CASE cUri:
        WHEN '/x' THEN 
        RUN x.p (INPUT poRequest, INPUT oJson).
        
        OTHERWISE 
        ASSIGN 
            lNoResource = TRUE.  
    END CASE.
END.

ELSE IF cUser = 'VALIDATE' THEN DO:
    CASE cUri:
        WHEN '/postdmdcall' THEN 
            RUN pasbg/precalc/program/postDemandCall.p (poRequest, oJson).

        OTHERWISE 
        ASSIGN 
            lNoResource = TRUE.  
    END CASE.
END.