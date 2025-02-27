USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.Utilities.Env: 
    DEFINE PRIVATE VARIABLE cLine         AS CHARACTER NO-UNDO.
    DEFINE PRIVATE VARIABLE cEnvPath      AS CHARACTER NO-UNDO.
    DEFINE PRIVATE VARIABLE cListVariable AS CHARACTER NO-UNDO.
    
    /* Constructor */
    CONSTRUCTOR PUBLIC Env():
        ASSIGN cEnvPath = ENTRY(1, PROPATH) + '/.env'.
        IF SEARCH(cEnvPath) = ? THEN DO:
            MESSAGE "FATAL - DOT ENV FILE NOT EXISTS ON" cEnvPath ", RAISING ERROR 408".
            STOP.
        END.
    END CONSTRUCTOR.
    
    /* Print Env Path */
    METHOD PUBLIC VOID PrintEnvPath():
        MESSAGE '123 Env Path : ' cEnvPath.        
    END METHOD.
        
    /* Get Env Value by Variable Name */
    METHOD PUBLIC CHARACTER GetValue (INPUT cVariable AS CHARACTER):
        INPUT FROM VALUE(cEnvPath).       
        REPEAT:
            IMPORT UNFORMATTED cLine.
            
            IF cLine BEGINS ' ' OR cLine BEGINS '#' OR cLine = '' THEN NEXT.
            
            IF ENTRY(1, cLine, "=") = cVariable THEN
                RETURN TRIM(ENTRY(2, cLine, "="), CHR(34)).
        END.
        
        INPUT CLOSE.
        RETURN ?.
        
    END METHOD.
        
    /* Get List of Env Variable Names */
    METHOD PUBLIC CHARACTER getVariables():
        INPUT FROM VALUE(cEnvPath).
        
        REPEAT:
            IMPORT UNFORMATTED cLine.
            IF cLine BEGINS ' ' OR cLine BEGINS '#' OR cLine = '' THEN NEXT.
            
            ASSIGN cListVariable = cListVariable + ENTRY(1, cLine, "=") + CHR(1). 
        END.
        
        IF cListVariable <> "" THEN
            RETURN RIGHT-TRIM(cListVariable, CHR(1)).
        ELSE 
            RETURN ?.
        INPUT CLOSE.
            
    END METHOD.
    
END CLASS.