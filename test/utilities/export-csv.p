USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.  

DEFINE VARIABLE ix          AS INTEGER   NO-UNDO.
DEFINE VARIABLE iRowCount   AS INTEGER   NO-UNDO.  
DEFINE VARIABLE cTableName  AS CHARACTER NO-UNDO. 
DEFINE VARIABLE cOutputPath AS CHARACTER NO-UNDO. 
DEFINE VARIABLE script      AS CHARACTER NO-UNDO.
DEFINE VARIABLE result      AS CHARACTER NO-UNDO.
DEFINE VARIABLE hTable      AS HANDLE    NO-UNDO.
DEFINE VARIABLE hSource     AS HANDLE    NO-UNDO.
DEFINE VARIABLE hTarget     AS HANDLE    NO-UNDO.
DEFINE VARIABLE hQuery      AS HANDLE    NO-UNDO.

ASSIGN 
    iRowCount   = INTEGER(poRequest:URI:GetQueryValue('row-count'))
    cTableName  = poRequest:URI:GetQueryValue('table')
    cOutputPath = poRequest:URI:GetQueryValue('path').

/* Create Dynamic Temp-Table based on target table passed from parameter */
CREATE TEMP-TABLE hTable.
hTable:CREATE-LIKE(cTableName).
hTable:TEMP-TABLE-PREPARE("data").
hTarget = hTable:DEFAULT-BUFFER-HANDLE.
    
/* Create target table buffer */
CREATE BUFFER hSource FOR TABLE cTableName.
  
/* Prepare Query the target table */
CREATE QUERY hQuery.
hQuery:ADD-BUFFER(hSource).
hQuery:QUERY-PREPARE('FOR EACH ' + hSource:NAME + ' NO-LOCK').
hQuery:QUERY-OPEN().

DO ix = 1 TO iRowCount:
    hQuery:GET-NEXT().
    IF hQuery:QUERY-OFF-END THEN DO:
        MESSAGE "Retrived" ix "Records".
        LEAVE.
    END.
    hTarget:BUFFER-CREATE().  
    hTarget:BUFFER-COPY(hSource).
END.

hQuery:QUERY-CLOSE().

DEFINE VARIABLE jsonPath AS CHARACTER NO-UNDO.
DEFINE VARIABLE excelPath AS CHARACTER NO-UNDO.

ASSIGN 
    jsonPath = cOutputPath + cTableName + '.json'
    excelPath = cOutputPath + cTableName + '.xlsx'.

hTarget:WRITE-JSON('file', jsonPath).

ASSIGN script = "python " + ENTRY(1, PROPATH) + "/python/json/json2excel.py " + 
    jsonPath + " " + excelPath.

INPUT THROUGH VALUE(script) NO-ECHO.
IMPORT UNFORMATTED result.
INPUT CLOSE.

oJson:Add('result', result).
