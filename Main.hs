module Main where

import           Foreign
import           Foreign.C.Types
import           Foreign.Storable
import           Foreign.C.String
import           Data.Word
import           Debug.Trace (trace)
    
data MyStruct = MyStruct {
    num :: Word32,
    str :: String
} deriving Show

numOffset = 0
strOffset =  numOffset + 8 -- NOT: sizeOf (0 :: Word32)
bufOffset =  strOffset + sizeOf (nullPtr :: CString)

instance Storable MyStruct where
    sizeOf _ = bufOffset + 64
    alignment _ = 8
    peek p = do
        buf <- peekByteOff p strOffset :: IO CString
        MyStruct 
         <$> peek (castPtr p)
         <*> peekCAString buf
    poke p x = do
        initMyStruct p
        pokeByteOff p numOffset (num x)
        withCStringLen (str x) $ \(p',l) -> copyBytes bufPtr p' (l+1)
        where bufPtr = castPtr $ plusPtr p bufOffset :: CString

foreign import ccall unsafe "./mystruct.h f"
    __f :: Ptr MyStruct -> IO ()

initMyStruct :: Ptr MyStruct -> IO ()
initMyStruct p = do
    let strPtr = castPtr $ plusPtr p strOffset :: Ptr CString
        buf = castPtr $ plusPtr p bufOffset :: CString
    poke buf 0
    poke strPtr buf
      
f :: MyStruct -> IO MyStruct
f ms = with ms $ \p -> initMyStruct p >>  __f p >> peek p

main :: IO ()
main = do
    let myStruct = MyStruct 1 "12345"
    print myStruct
    newStruct <- f myStruct
    print newStruct
