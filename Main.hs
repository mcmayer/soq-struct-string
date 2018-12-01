module Main where

import           Foreign
import           Foreign.C.Types
import           Foreign.Storable
import           Foreign.C.String
import           Data.Word
import           Debug.Trace (trace)
import           Control.Monad (forM_)
import           Data.Traversable

{-
    Note: In the real world use c2hs or c2hsc or binding-dsl or similar instead of hard-coding 
    alignment and offsets!
-}

bufLen = 64 :: Int

data MyStruct = MyStruct {
    num :: Word32,
    str :: String
} deriving Show

numOffset = 0
strOffset =  numOffset + 8 -- NOT: sizeOf (0 :: Word32)
bufOffset =  strOffset + sizeOf (nullPtr :: CString)

instance Storable MyStruct where
    sizeOf _ = bufOffset + bufLen
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
      
f :: IO MyStruct
f = alloca $ \p -> initMyStruct p >> __f p >> peek p

main :: IO ()
main = 
    print =<< last <$> sequence (replicate 1000 f)
