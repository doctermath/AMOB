FUNCTION hell RETURNS LOGICAL
    (INPUT cMessage AS CHARACTER):
    DEFINE VARIABLE cLogFile AS CHARACTER NO-UNDO.
    DEFINE VARIABLE hFile    AS HANDLE    NO-UNDO.

    /* Path to the log file on the desktop */
    cLogFile = SUBSTITUTE("C:/Users/Yordan/Desktop/Hellstad/logfile.log").

    /* Create or append to the log file */
    OUTPUT TO VALUE(cLogFile) APPEND.

    PUT UNFORMATTED STRING(cMessage) SKIP.    
    /*PUT UNFORMATTED STRING(STRING(TODAY) + " " + STRING(TIME, "HH:MM:SS") + " - " + cMessage) SKIP.*/
    
    OUTPUT CLOSE.

    RETURN TRUE.
END FUNCTION.

FUNCTION GenerateAlias RETURNS CHARACTER (INPUT cFullName AS CHARACTER):
    DEFINE VARIABLE cWord           AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cAlias          AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE cThird          AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE ix              AS INTEGER     NO-UNDO.
    DEFINE VARIABLE iPrevWordLen    AS INTEGER     NO-UNDO.
    DEFINE VARIABLE lNamePicked     AS LOGICAL     NO-UNDO.
  
    /* Replace Period with space and prevent double space */
    cFullName = REPLACE(cFullName, ".", " ").
    REPEAT WHILE INDEX(cFullName, "  ") > 0:
        cFullName = REPLACE(cFullName, "  ", " ").
    END.

    /* Name with single quote - Delete the quote*/
    cFullName = REPLACE(cFullName, "'", "").

    /* Name with title - Delete the title (after comma) */
    IF INDEX(cFullName, ",") > 0 THEN
    cFullName = SUBSTRING(cFullName, 1, INDEX(cFullName, ",") - 1).

    /* Loop Words in names */
    REPEAT ix = 1 TO NUM-ENTRIES(cFullName, ' '):
        cWord = ENTRY(ix, cFullName, ' ').

        /* For First Word */
        IF ix = 1 THEN DO:

            /* Name with Muhammad Prefix - Abbreviate to M. */
            IF LOOKUP(cWord,
                "MOCH," +
                "MOCHAMAD," +
                "MOCHAMMAD," +
                "MOH," +
                "MHD," +
                "MOHAMAD," +
                "MOHAMMAD," +
                "MUCHAMAD," +
                "MUCHAMMAD," +
                "MUH," +
                "MUHAMAD," +
                "MUHAMMAD"
                )         
                > 0 THEN
                cWord = 'M.'.

            /* Name with FX Prefix - Delete Prefix */
            ELSE IF cWord = "FX" THEN
                cWord = ''.

            /* Name with Abdul prefix - Abbreviate to A. */
            ELSE IF LOOKUP(cWord,
                "ABB," +
                "ABDUL"
                )         
                > 0 THEN
                cWord = 'A.'.

            /* if first word has more than 2 letter, then pick that word */
            ELSE IF LENGTH(cWord) > 2 THEN
                lNamePicked = TRUE.
        END.

        /* Second and More Words */
        ELSE DO:
            /* Preassign Third Word if available and prevent error */
            ASSIGN cThird = ENTRY(3, cFullName, ' ') NO-ERROR.

            /* Check if Name has 2 word, then dont abbreviate */
            IF cThird <> '' AND lNamePicked AND LENGTH(cWord) > 1 THEN
                cWord = SUBSTRING(cWord, 1, 1) + '.'.

            /* if second word has more than 2 letter, then make it the pronouced name */
            ELSE IF LENGTH(cWord) > 2 THEN 
                lNamePicked = TRUE.
        END.

        /* add period to abbreviated word */
        IF LENGTH(cWord) = 1 THEN
            cWord = cWord + '.'.

        /* add space around pronouced word */
        IF iPrevWordLen > 2 OR LENGTH(cWord) > 2 THEN
            ASSIGN cWord = " " + cWord.

        /* assign the alias with generated word */
        cAlias = cAlias + cWord.

        /* remember previous word length for next loop */
        iPrevWordLen = LENGTH(TRIM(cWord)).
    END.

    RETURN TRIM(cAlias).
END.

DEFINE VARIABLE ix AS INTEGER     NO-UNDO.
hell("empno;fullname;alias").
FOR EACH empmas NO-LOCK WHERE 
    outdate = ? and LOOKUP(substr(empno,1,1), 'X,S') = 0 
    /*AND 
    empnam MATCHES "*MUHAMMAD TAUFIQ D*"*/
    /*empnam MATCHES "*WISHNU*" OR 
    empnam MATCHES "*SETYOWATI*" OR
    empnam MATCHES "FX*" OR
    empnam MATCHES "*ANGGRAINI*" OR
    empnam MATCHES "*DALEM*" OR
    empnam MATCHES "*AFIFAH*" OR
    empnam MATCHES "*AGUNG*WIB*" OR 
    empnam MATCHES "*KURNIA*SANDI*" OR
    empnam MATCHES "*ATTAR AL*" OR
    empnam MATCHES "*HAFID RAHMAN*" OR
    empnam MATCHES "*BAY LA*" OR
    empnam MATCHES "*ABDULLAH*B*" OR TRUE*/
    :
    ix = ix + 1.
    IF ix > 10000 THEN LEAVE.
    hell(STRING(empmas.empno) + ';' + empmas.empnam + ";" + GenerateAlias(empmas.empnam)).
END.
