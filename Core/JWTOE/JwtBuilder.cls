 
 /*------------------------------------------------------------------------
    File        : JwtBuilder
    Purpose     : 
    Syntax      : 
    Description : JSON Web Token builder for Progress OpenEdge
    Author(s)   : Valdemar SinkieviÄ� (valdemar@bpm-id.com)
    Created     : Mon May 10 09:41:37 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.JsonObject FROM PROPATH.
USING Core.jwtoe.JwtBuilder FROM PROPATH.
USING Core.jwtoe.HS256 FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.jwtoe.JwtBuilder: 
    DEF VAR oHeader AS JsonObject NO-UNDO.
    DEF VAR oPayload AS JsonObject NO-UNDO.
    DEF VAR cHS256key AS CHAR NO-UNDO.

    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    CONSTRUCTOR PUBLIC JwtBuilder (  ):
        SUPER ().
        oHeader = NEW JsonObject(). 
        oPayload = NEW JsonObject().
    //    oJsonHeaderObject:Add("typ", "JWT").
    END CONSTRUCTOR.
    
    METHOD PUBLIC JwtBuilder setSubject (pcSubject AS CHAR): 
        oPayload:Add("sub", pcSubject).
        RETURN THIS-OBJECT.
    END METHOD.

    METHOD PUBLIC JwtBuilder setIssuer (pcIssuer AS CHAR): 
        oPayload:Add("iss", pcIssuer).
        RETURN THIS-OBJECT.
    END METHOD.
    
    METHOD PUBLIC JwtBuilder setAudience (pcAudience AS CHAR): 
        oPayload:Add("aud", pcAudience).
        RETURN THIS-OBJECT.
    END METHOD. 

    METHOD PUBLIC JwtBuilder setClaim(pcKey AS CHAR, pcValue AS CHAR): 
        oPayload:Add(pcKey, pcValue).
        RETURN THIS-OBJECT.
    END METHOD.
    
    METHOD PUBLIC JwtBuilder setExpiresInSeconds(piSeconds AS INT): 
        oPayload:Add("exp", _getCurrentTime() + piSeconds).
        RETURN THIS-OBJECT.
    END METHOD.
    
    METHOD PROTECTED INT64 _getCurrentTime():
        DEFINE VARIABLE vDateOrDateTime AS DATETIME NO-UNDO INITIAL 1/1/1970.
        
        RETURN INTERVAL(DATETIME-TZ(TODAY, MTIME),vDateOrDateTime, "seconds" ) - TIMEZONE * 60.
    END METHOD.
    
    METHOD PUBLIC CHARACTER compact ():
        DEF VAR cToken AS CHAR NO-UNDO.
        
        cToken = HS256:signWithKey(oHeader, oPayload, cHS256key).
        DELETE OBJECT(oHeader).
        DELETE OBJECT(oPayload).
        RETURN cToken.
    END METHOD.
    
    METHOD PUBLIC JwtBuilder signWithHS256Key (pcKey AS CHAR):
        oHeader:Add("alg", "HS256").
        cHS256key = pcKey.
        RETURN THIS-OBJECT.
    END METHOD.
END CLASS.