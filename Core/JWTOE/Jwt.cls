 
 /*------------------------------------------------------------------------
    File        : Jwt
    Purpose     : 
    Syntax      : 
    Description : JSON Wet Token builder for Progress OpenEdge
    Author(s)   : Valdemar SinkieviÄ�
    Created     : Mon May 10 09:39:44 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Core.jwtoe.JwtBuilder FROM PROPATH.
USING Core.jwtoe.JwtParser FROM PROPATH.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.jwtoe.Jwt: 
    
    METHOD STATIC PUBLIC JwtBuilder builder ():
        RETURN NEW JwtBuilder().
    END METHOD.
    
    METHOD STATIC PUBLIC JwtParser parseBuilder():
        RETURN NEW JwtParser().
    END METHOD.

END CLASS.