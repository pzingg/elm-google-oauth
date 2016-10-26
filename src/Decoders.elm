module Decoders exposing(..)

import Json.Decode as JD exposing ((:=))
import Types exposing(OAuthToken, UserInfo)


decodeOAuthToken : JD.Decoder OAuthToken
decodeOAuthToken =
  JD.object5
    OAuthToken
    ("access_token" := JD.string)
    ("id_token" := JD.string)
    ("expires_in" := JD.int)
    ("token_type" := JD.string)
    (JD.maybe ("refresh_token" := JD.string))


decodeUserInfo : JD.Decoder UserInfo
decodeUserInfo =
  JD.object4
    UserInfo
    (JD.maybe ("name" := JD.string))
    (JD.maybe ("given_name" := JD.string))
    (JD.maybe ("family_name" := JD.string))
    ("email" := JD.string)
