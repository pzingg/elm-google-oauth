module Decoders exposing(..)

import Json.Decode as JD exposing ((:=))
import Types exposing(OAuthToken)


decodeOAuthToken : JD.Decoder OAuthToken
decodeOAuthToken =
  JD.object5
    OAuthToken
    ("access_token" := JD.string)
    ("id_token" := JD.string)
    ("expires_in" := JD.int)
    ("token_type" := JD.string)
    (JD.maybe ("refresh_token" := JD.string))
