 
 /*------------------------------------------------------------------------
    File        : JwtException
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : vsink_000
    Created     : Mon May 10 15:00:52 EEST 2021
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS Core.jwtoe.JwtError INHERITS AppError FINAL: 
        
    CONSTRUCTOR PUBLIC JwtError ( INPUT pcReturnValue AS CHARACTER ):
        SUPER (INPUT pcReturnValue).
        
    END CONSTRUCTOR.

        
    CONSTRUCTOR PUBLIC JwtError ( INPUT pcErrorMessage AS CHARACTER, INPUT piMessageNum AS INTEGER ):
        SUPER (INPUT pcErrorMessage, INPUT piMessageNum).
        
    END CONSTRUCTOR.

        
    CONSTRUCTOR PUBLIC JwtError (  ):
        SUPER ().
        
    END CONSTRUCTOR.
    
END CLASS.