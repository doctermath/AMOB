USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.Utilities.Base64Url: 
    /* BASE64URL DECODER */
    METHOD PUBLIC LONGCHAR Decode (INPUT base64url AS LONGCHAR):
        DEFINE VARIABLE base64      AS LONGCHAR NO-UNDO.
        DEFINE VARIABLE memptrValue AS MEMPTR   NO-UNDO.
        DEFINE VARIABLE result      AS LONGCHAR NO-UNDO.

        /* Replace URL-safe characters */
        base64 = REPLACE(REPLACE(REPLACE(base64url, "_", "/"), "-", "+"), "=", "").

        /* Add padding if necessary */
        DO WHILE (LENGTH(base64) MOD 4) <> 0:
            base64 = base64 + "=".
        END.

        /* Decode the Base64 string */
        memptrValue = BASE64-DECODE(base64).

        /* Convert MEMPTR to CHARACTER */
        result = GET-STRING(memptrValue, 1).

        /* Clean up */
        SET-SIZE(memptrValue) = 0.

        RETURN result.   
    END METHOD.
    
    /* BASE64URL ENCODER */
    METHOD PUBLIC LONGCHAR Encode (INPUT rawString AS LONGCHAR):
        DEFINE VARIABLE memptrValue AS MEMPTR   NO-UNDO.
        DEFINE VARIABLE base64Value AS LONGCHAR NO-UNDO.

        /* Convert the raw string to a MEMPTR */
        SET-SIZE(memptrValue) = LENGTH(rawString) + 1.
        PUT-STRING(memptrValue, 1) = rawString.

        /* Encode the MEMPTR to Base64 */
        base64Value = BASE64-ENCODE(memptrValue).

        /* Base64Url encode */
        base64Value = REPLACE(REPLACE(REPLACE(base64Value, "=", ""), "/", "_"), "+", "-").

        /* Clean up */
        SET-SIZE(memptrValue) = 0.

        RETURN base64Value.
    END METHOD.

END CLASS.