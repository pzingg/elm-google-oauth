module Decoders exposing(..)

import Json.Decode as JD exposing ((:=))
import Types exposing(OAuthToken)


decodeOAuthToken : JD.Decoder OAuthToken
decodeOAuthToken =
  JD.object5
    OAuthToken
    ("accessToken" := JD.string)
    ("idTokenRaw" := JD.string)
    ("expiresIn" := JD.float)
    ("tokenType" := JD.string)
    ("refreshToken" := JD.maybe JD.string)
