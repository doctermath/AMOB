 
 /*------------------------------------------------------------------------
    File        : HS256
    Purpose     : 
    Syntax      : 
    Description : 

based on (https://knowledgebase.progress.com/articles/Knowledge/000043232):        
/* Simple HMAC function Overview                                                */
/* Developer: James Bowen                                                       */
/* Date:      13/06/2011                                                        */
/* References: http://www.ietf.org/rfc/rfc2104.txt                              */
/*             http://the.jhu.edu/upe/member_sites/zarfoss/HMAC-big.jpg         */
/*             http://en.wikipedia.org/wiki/HMAC                                */
/*             http://www.cryptostuff.com/crypto/index.php?title=hmac           */
/* HMAC is a hash based MAC algorithm defined in RFC 2104. It can use any       */
/* hash function (such as MD5, SHA1 etc). HMAC also requires a user             */
/* supplied secret key, which is a string of bytes of any length upto 64 bytes. */
        
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.jwtoe.HS256: 
    METHOD PUBLIC STATIC CHARACTER signWithKey( INPUT poHeader AS JsonObject, INPUT poPayload AS JsonObject, INPUT pcSecret AS CHAR ):
        DEF VAR cEncodedHeader AS CHAR NO-UNDO.
        DEF VAR cEncodedPayload AS CHAR NO-UNDO.
        DEF VAR cSignData AS CHAR NO-UNDO.
        DEF VAR cSignature AS CHAR NO-UNDO.
        
        cEncodedHeader = base64urlEncode(poHeader:GetJsonText()).
        cEncodedPayload = base64urlEncode(poPayload:GetJsonText()).
        cSignData = subst("&1.&2", cEncodedHeader, cEncodedPayload).
        
        RETURN signWithKey(cSignData, pcSecret).
    END METHOD.
    
    METHOD PUBLIC STATIC CHARACTER signWithKey ( INPUT pcDataToSign AS CHAR, INPUT pcSecret AS CHAR): 
        DEF VAR cSignature AS CHAR NO-UNDO.
        
        cSignature = base64ToBase64Url(hmacBase64('SHA-256', pcSecret, pcDataToSign)).
        
        RETURN pcDataToSign + "." + cSignature.
    END METHOD.
    
     METHOD PRIVATE STATIC INT _binaryXOR (INPUT intOperand1 AS INTEGER, INPUT intOperand2 AS INTEGER):
        DEFINE VARIABLE iByteLoop  AS INTEGER NO-UNDO.
        DEFINE VARIABLE iXOResult  AS INTEGER NO-UNDO.
        DEFINE VARIABLE lFirstBit  AS LOGICAL NO-UNDO.
        DEFINE VARIABLE lSecondBit AS LOGICAL NO-UNDO.
    
        iXOResult = 0.
    
        /*spin through each byte of each char*/
        DO iByteLoop = 0 TO 7: /* as processing a single byte character */
    
            /*find state (true / false) of each integer's byte*/
            ASSIGN
                lFirstBit  = GET-BITS(intOperand1,iByteLoop + 1,1) = 1
                lSecondBit = GET-BITS(intOperand2,iByteLoop + 1,1) = 1.
    
            /* XOR each bit*/
            IF (lFirstBit AND NOT lSecondBit) OR
                (lSecondBit AND NOT lFirstBit) THEN
                iXOResult = iXOResult + EXP(2, iByteLoop).
        END.
     
        RETURN iXOResult.
    END METHOD. /*End function of BinaryXOR */

    METHOD PUBLIC STATIC CHAR hmacBase64 (INPUT pcSHA AS CHARACTER, INPUT pcKey AS CHARACTER, INPUT pcData AS CHARACTER):
        DEFINE VARIABLE mKeyOpad       AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE mKeyIpad       AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE mData          AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE mKey           AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE mInnerCombined AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE mOuterCombined AS MEMPTR    NO-UNDO.
        DEFINE VARIABLE iBytePos       AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iOpad          AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iIpad          AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iKey           AS INTEGER   NO-UNDO.
        DEFINE VARIABLE iTimeTaken     AS INTEGER   NO-UNDO.
        DEFINE VARIABLE rRawDataSHA    AS RAW       NO-UNDO.
        DEFINE VARIABLE cHMACSHA       AS CHARACTER NO-UNDO.
        
        &SCOPED-DEFINE xiBlockSize  64
        
        SET-SIZE(mKey)     = 0.
        SET-SIZE(mKeyOpad) = 0.
        SET-SIZE(mKeyIpad) = 0.
        SET-SIZE(mKey)     = {&xiBlockSize}.
        SET-SIZE(mKeyOpad) = {&xiBlockSize}.
        SET-SIZE(mKeyIpad) = {&xiBlockSize}.
        
        DO iBytePos = 1 TO {&xiBlockSize}:
            PUT-BYTES(mKey,     iBytePos) = HEX-DECODE("00":U).  /* 64 bytes of zeros 0x00*/
            PUT-BYTES(mKeyOpad, iBytePos) = HEX-DECODE("5C":U).  /* 64 bytes of 0x5C (92 dec,  "/" ascii) */
            PUT-BYTES(mKeyIpad, iBytePos) = HEX-DECODE("36":U).  /* 64 bytes of 0x36 (54 dec, "6" ascii)*/
        END.
        
        /* correction by Valery A.Eliseev */
        IF LENGTH(pcKey) > {&xiBlockSize} THEN 
        DO:
            set-size(mData) = LENGTH(pcKey).
            put-string(mData, 1, LENGTH(pcKey)) = pcKey.
            rRawDataSHA = SHA1-DIGEST(mData).
            PUT-BYTES(mKey, 1) = rRawDataSHA.
        END.
        ELSE
            /* end of correction */
        
            PUT-STRING(mKey, 1, LENGTH(pckey))  = pcKey. 
        
        DO iBytePos = 1 TO {&xiBlockSize}:
          
            ASSIGN
                iKey  = GET-BYTE(mKey,     iBytePos)
                iOpad = GET-BYTE(mKeyOpad, iBytePos)
                iIpad = GET-BYTE(mKeyIpad, iBytePos).
          
            /* The inner key, mKeyIpad is formed from mKey by XORing each byte with 0x36.. */
            PUT-BYTE(mKeyIpad, iBytePos) = _binaryXOR(INPUT iKey, 
                INPUT iIpad).
        
            /* The inner key, mKeyOpad is formed from mKey by XORing each byte with 0x5C. */
            PUT-BYTE(mKeyOpad, iBytePos) = _binaryXOR(INPUT iKey, 
                INPUT iOpad).
        
        END.
        
        SET-SIZE(mKey)  = 0.
        SET-SIZE(mData) = 0.
        SET-SIZE(mData) = LENGTH(pcData).
        PUT-STRING(mData,1,LENGTH(pcData)) = pcData.
        
        
        /* Inner Loop*/
        SET-SIZE(mInnerCombined)      = GET-SIZE(mKeyIpad) + GET-SIZE(mData).
        
        PUT-BYTES(mInnerCombined, 1)  = mKeyIpad.
        SET-SIZE(mKeyIpad) = 0.
        
        /*Append the data the end of the block size.*/
        PUT-BYTES(mInnerCombined, {&xiBlockSize} + 1) = mData.
        
        /* Deallocates any memory. */
        SET-SIZE(mData) = 0.
        
        /* Get the results of the SHA Digest.*/
        CASE pcSHA:
            WHEN 'SHA1' THEN
                ASSIGN
                    rRawDataSHA = SHA1-DIGEST(mInnerCombined).
            WHEN 'SHA-256' THEN
                ASSIGN
                    rRawDataSHA = MESSAGE-DIGEST('SHA-256', mInnerCombined).
            OTHERWISE 
            ASSIGN
                rRawDataSHA = SHA1-DIGEST(mInnerCombined).
        END CASE.
                                         
        /* Deallocates any memory. */
        SET-SIZE(mInnerCombined) = 0.
        
        /* Outer Loop calculation for SHA*/
        SET-SIZE(mOuterCombined)                      = 0.
        SET-SIZE(mOuterCombined)                      = GET-SIZE(mKeyOpad) + LENGTH(rRawDataSHA,'RAW':U).
        PUT-BYTES(mOuterCombined, 1)                  = mKeyOpad.
        PUT-BYTES(mOuterCombined, {&xiBlockSize} + 1) = rRawDataSHA.
        
        /* SHA*/
        CASE pcSHA:
            WHEN 'SHA1' THEN
                ASSIGN
                    rRawDataSHA = SHA1-DIGEST(mOuterCombined).
            WHEN 'SHA-256' THEN
                ASSIGN
                    rRawDataSHA = MESSAGE-DIGEST('SHA-256', mOuterCombined).
            OTHERWISE 
            ASSIGN
                rRawDataSHA = SHA1-DIGEST(mOuterCombined).
        END CASE.
        
        /* Deallocates any memory. */
        SET-SIZE(mKeyOpad)       = 0.
        SET-SIZE(mOuterCombined) = 0.
        
        /* Convert the raw binary results into a human readable BASE-64 value.*/
        cHMACSHA = BASE64-ENCODE(rRawDataSHA).
    /*    cHMACSHA = HEX-ENCODE(rRawDataSHA).*/
        
        
        &UNDEFINE xiBlockSize
        RETURN cHMACSHA.
        
        FINALLY:
            set-size(mKeyOpad      ) = 0.
            set-size(mKeyIpad      ) = 0.
            set-size(mData         ) = 0.
            set-size(mKey          ) = 0.
            set-size(mInnerCombined) = 0.
            set-size(mOuterCombined) = 0.
        END FINALLY.
    END METHOD. /** End Of Function HMACSHA1-BASE64 */
        
    METHOD PUBLIC STATIC CHAR base64urlEncode ( INPUT cString AS LONGCHAR ):
        DEF VAR cEncoded AS CHAR NO-UNDO.
        DEF VAR mAuth AS MEMPTR NO-UNDO.
        
        COPY-LOB FROM cString TO mAuth.
        cEncoded = BASE64-ENCODE(mAuth).
          
        RETURN base64ToBase64Url(cEncoded).
        
        FINALLY:
            set-size(mAuth) = 0.            
        END FINALLY.
    END METHOD.
    
    METHOD PUBLIC STATIC CHAR base64UrlDecode ( INPUT cBase64Url AS LONGCHAR ):
        DEF VAR cDecoded AS LONGCHAR NO-UNDO.
        DEF VAR mAuth AS MEMPTR NO-UNDO.
        DEF VAR cBase64 AS CHAR NO-UNDO.
        
        cBase64 = base64UrlToBase64(cBase64Url).
        mAuth = BASE64-DECODE(cBase64).
        COPY-LOB FROM mAuth TO cDecoded.
        
        RETURN STRING(cDecoded).
        
        FINALLY:
            set-size(mAuth) = 0.            
        END FINALLY.
    END METHOD.
    
    METHOD PUBLIC STATIC CHAR base64ToBase64Url ( INPUT cBase64 AS CHAR ):
        cBase64 = TRIM(TRIM(cBase64, "="), "=").
        cBase64 = REPLACE(cBase64, "+", "-").
        cBase64 = REPLACE(cBase64, "/", "_").
    
        RETURN cBase64.
    END METHOD.
    
    METHOD PUBLIC STATIC CHAR base64UrlToBase64 ( INPUT cBase64Url AS LONGCHAR ):
        DEF VAR i AS INT NO-UNDO.
        cBase64Url = REPLACE(cBase64Url, "-", "+").
        cBase64Url = REPLACE(cBase64Url, "_", "/").
        
        DO i = 0 TO 3:
           IF LENGTH(cBase64Url) MOD 4 <> 0
           THEN cBase64Url = cBase64Url + "=".
           ELSE LEAVE.
        END.    
            
        RETURN STRING(cBase64Url).
    END METHOD.

END CLASS.