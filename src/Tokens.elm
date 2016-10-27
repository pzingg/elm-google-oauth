module Tokens exposing (newToken)

import Basics exposing (truncate)
import Char
import Random exposing (Generator, initialSeed, step, list, int, map)
import String exposing (fromList)
import Time exposing (Time)


alphanumeric : Generator Char
alphanumeric =
    map (\n ->
        if n < 10 then
            Char.fromCode (n + 48)
        else if n < 36 then
            Char.fromCode (n + 55)
        else
            Char.fromCode (n + 61)) (int 0 61)


string : Int -> Generator Char -> Generator String
string stringLength charGenerator =
  map fromList (list stringLength charGenerator)


an40 : Generator String
an40 = string 40 alphanumeric


newToken : Time -> String
newToken time =
    let
        seed = initialSeed <| (truncate time)
    in
        step an40 seed
            |> fst
