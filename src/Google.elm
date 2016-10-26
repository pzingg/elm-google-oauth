module Google exposing (..)


{-| Hardcoded for now, but could be found from Discovery service
-}

authorizationEndpoint : String
authorizationEndpoint = "https://accounts.google.com/o/oauth2/v2/auth"

tokenEndpoint : String
tokenEndpoint = "https://www.googleapis.com/oauth2/v4/token"

userinfoEndpoint : String
userinfoEndpoint =  "https://www.googleapis.com/oauth2/v3/userinfo"

revocationEndpoint : String
revocationEndpoint = "https://accounts.google.com/o/oauth2/revoke"

jwksUri : String
jwksUri = "https://www.googleapis.com/oauth2/v3/certs"
