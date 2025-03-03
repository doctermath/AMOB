 
 /*------------------------------------------------------------------------
    File        : JwtParser
    Purpose     : Used to verify received JWT token
    Syntax      : 
    Description : 
    Author(s)   : Valdemar SinkieviÄ� (valdemar@bpm-id.com)
    Created     : Mon May 10 11:20:17 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING Core.jwtoe.JwtParser FROM PROPATH.
USING Core.jwtoe.JwtError FROM PROPATH.
USING Core.jwtoe.HS256 FROM PROPATH.
USING Progress.Json.ObjectModel.ObjectModelParser FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.jwtoe.JwtParser: 
    DEF VAR cSigningKey AS CHAR NO-UNDO.
    
    DEF PROTECTED STATIC VAR jsonParser AS ObjectModelParser NO-UNDO.
    
    METHOD PUBLIC JwtParser setSigningKeyHS256 (pcSecretKey AS CHAR):
        IF pcSecretKey = ? OR pcSecretKey = ""
        THEN UNDO, THROW NEW JwtError("Key was not provided!", 2).
        
        cSigningKey = pcSecretKey. 
        RETURN THIS-OBJECT.
    END METHOD. 
    
    METHOD PUBLIC JsonObject parseClaimsJws (pcReceivedToken AS CHAR):
        DEF VAR claims AS JsonObject NO-UNDO.
        DEF VAR cDataToSign AS CHAR NO-UNDO.
        DEF VAR cPayloadJson AS CHAR NO-UNDO.
        DEF VAR iValidUntilTime AS INT64 NO-UNDO.
     //   def var cReceivedSignature as char no-undo.
        
        IF pcReceivedToken = ? OR pcReceivedToken = ""
        THEN UNDO, THROW NEW JwtError("JWT token was not provided!", 1).
        
        IF NUM-ENTRIES(pcReceivedToken, ".") <> 3
        THEN UNDO, THROW NEW JwtError("Wrong JWT token format!", 3).
        
        cDataToSign = subst("&1.&2", ENTRY(1, pcReceivedToken, "."), ENTRY(2, pcReceivedToken, ".")).
   //     cReceivedSignature = entry(3, pcReceivedToken, ".").
        
        IF pcReceivedToken <> HS256:signWithKey(cDataToSign, cSigningKey)
        THEN UNDO, THROW NEW JwtError("Wrong signature!", 4).

        IF Core.jwtoe.JwtParser:jsonParser = ?
        THEN Core.jwtoe.JwtParser:jsonParser = NEW ObjectModelParser().
        
        cPayloadJson = HS256:base64UrlDecode(ENTRY(2, pcReceivedToken, ".")).
        claims = CAST(Core.jwtoe.JwtParser:jsonParser:parse(cPayloadJson), JsonObject).
        
        IF claims:Has("exp")
        THEN DO:
            iValidUntilTime = claims:GetInt64("exp").
            IF  iValidUntilTime <> ? AND iValidUntilTime < _getCurrentTime()
            THEN UNDO, THROW NEW JwtError("Token expired!", 5).
        END.
        RETURN claims.
    END.

    METHOD PROTECTED INT64 _getCurrentTime():
        DEFINE VARIABLE vDateOrDateTime AS DATETIME NO-UNDO INITIAL 1/1/1970.
        
        RETURN INTERVAL(DATETIME-TZ(TODAY, MTIME),vDateOrDateTime, "seconds" ) - TIMEZONE * 60.
    END METHOD.
END CLASS.