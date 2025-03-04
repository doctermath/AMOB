/* GET Handler
 * For Routing HTTP GET Method to corresponding procedure 
 * ======================================================================= */
 
USING Progress.Json.ObjectModel.JsonObject.
USING OpenEdge.Web.IWebRequest.

DEFINE INPUT  PARAMETER cUser       AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER cUri        AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER poRequest   AS IWebRequest NO-UNDO.
DEFINE INPUT  PARAMETER oJson       AS JsonObject  NO-UNDO.
DEFINE OUTPUT PARAMETER lNoResource AS LOGICAL     NO-UNDO.

IF cUser = 'PUBLIC' THEN DO:
    CASE cUri:
        WHEN '/get-employee-data' THEN 
            RUN resource/getEmployeeData.p (INPUT poRequest, INPUT oJson).
        
        OTHERWISE ASSIGN lNoResource = TRUE.  
    END CASE.
END.

ELSE IF cUser = 'VALIDATE' THEN DO:
    CASE cUri:
        WHEN '/get-employee-data' THEN
            RUN resource/getEmployeeData.p (INPUT poRequest, INPUT oJson).

        WHEN '/gdmdcall' THEN 
            RUN pasbg/precalc/program/getDemandCall.p(poRequest, oJson).
    
        WHEN '/getengpop' THEN 
            RUN resource/engines/getengpop.p (poRequest, oJson). 
        
        OTHERWISE ASSIGN lNoResource = TRUE.  
    END CASE.
END.