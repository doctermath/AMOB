/* GET Handler
 * For Routing HTTP GET Method to corresponding procedure 
 * ======================================================================= */
 
USING Progress.Json.ObjectModel.JsonObject.
USING OpenEdge.Web.IWebRequest.

DEFINE INPUT  PARAMETER aa  AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER bb  AS CHARACTER   NO-UNDO.
DEFINE INPUT  PARAMETER poRequest   AS IWebRequest NO-UNDO.
DEFINE INPUT  PARAMETER oJson       AS JsonObject  NO-UNDO.
DEFINE OUTPUT PARAMETER lNoResource AS LOGICAL   NO-UNDO.

IF aa = 'GUEST' THEN DO:
    CASE bb:
        WHEN 'xxx' THEN 
            RUN resource/getEmployeeData.p (INPUT poRequest, INPUT oJson).
        
        OTHERWISE ASSIGN lNoResource = TRUE.  
    END CASE.
END.

ELSE IF aa = 'USER' THEN DO:
    CASE bb:
        WHEN 'xxx' THEN 
        RUN resource/getEmployeeData.p (INPUT poRequest, INPUT oJson).
        
        OTHERWISE ASSIGN lNoResource = TRUE.  
    END CASE.
END.