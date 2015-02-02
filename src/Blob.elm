module Blob where
{-| https://developer.mozilla.org/en-US/docs/Web/API/Blob
-}

type Data
    = ArrayData (List Data)
    | ArrayBufferData
    | StringData String
    | BlobData Blob


blob : Data -> Blob


{-| Get the size of a blob in bytes.
-}
size : Blob -> Int


{-| Get the MIME type of the data stored in the `Blob` if that information
is available.
-}
mimeType : Blob -> Maybe String


slice : Int -> Int -> Maybe String -> Blob -> Blob