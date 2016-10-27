module Routers.Utils exposing (hash2list, list2hash)

import String exposing (uncons, split)

import Http exposing (uriDecode, uriEncode)


{-| Remove the character from the string if it is the first character -}
removeInitial : Char -> String -> String
removeInitial initial original =
    case uncons original of
        Just (first, rest) ->
            if first == initial
                then rest
                else original

        _ ->
            original


{-| Remove initial characters from the string, as many as there are.
So, for "#!/", remove # if is first, then ! if it is next, etc.
-}
removeInitialSequence : String -> String -> String
removeInitialSequence initial original =
    String.foldl removeInitial original initial


{-| Takes a string from the location's hash, and normalize it to a list of strings
that were separated by a slash.
-}
hash2list : String -> String -> List String
hash2list prefix =
    removeInitialSequence prefix >> split "/" >> List.map uriDecode


{-| The opposite of normalizeHash ... takes a list and turns it into a hash -}
list2hash : String -> List String -> String
list2hash prefix list =
    prefix ++ String.join "/" (List.map uriEncode list)
