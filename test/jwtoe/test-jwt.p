USING Progress.Lang.*.
USING Core.jwtoe.Jwt.
USING Core.jwtoe.JwtBuilder.
USING Core.jwtoe.JwtError.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.

DEFINE INPUT PARAMETER poRequest    AS OpenEdge.Web.IWebRequest NO-UNDO.
DEFINE INPUT PARAMETER oJson        AS JsonObject NO-UNDO.


DEF VAR cJwtToken AS CHAR NO-UNDO.

/* ## Create JWT token */
cJwtToken = Jwt:builder()
            :setAudience("audience siapa")
            :setIssuer("issuer siapa")
            :setSubject("subject apa pula")
            :setClaim("key claim", "yang bener")
            :setExpiresInSeconds(60)
            :signWithHS256Key("mySecretKey")
            :compact().
            
oJson:Add('test1', cJwtToken).
oJson:Add('kokushima','alamakar').


/* ## Validate JWT token   */
DO ON ERROR UNDO, THROW:
    Jwt:parseBuilder()
       :setSigningKeyHS256("mySecretKey")
       :parseClaimsJws(cJwtToken).
    
    // here you are sure that token was valid
    
    CATCH e AS JwtError:
        MESSAGE e:GetMessageNum(1) SKIP e:GetMessage(1) VIEW-AS ALERT-BOX TITLE "JWT error".
    END CATCH.
END.

/* ## Using values from the received JWT token */
DEF VAR oClaims AS JsonObject NO-UNDO.
DEF VAR cReceivedToken AS CHAR NO-UNDO.
        
DO ON ERROR UNDO, THROW:
    oClaims = Jwt:parseBuilder()
                 :setSigningKeyHS256("mySecretKey")
                 :parseClaimsJws(cJwtToken).
    
    // here you are sure that token was valid
    MESSAGE oClaims:GetCharacter("iss").
    MESSAGE oClaims:GetCharacter("aud").
    MESSAGE oClaims:GetCharacter("sub").
    MESSAGE oClaims:GetCharacter("key claim").
    
    CATCH e AS JwtError:
        MESSAGE e:GetMessageNum(1) SKIP e:GetMessage(1) VIEW-AS ALERT-BOX TITLE "JWT error".
    END CATCH.
END.




