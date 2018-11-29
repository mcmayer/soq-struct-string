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
strOffset =  numOffset + sizeOf (0 :: Word32)
bufOffset =  strOffset + sizeOf (nullPtr :: CString)

instance Storable MyStruct where
    sizeOf _ = bufOffset + 64
    alignment _ = 4
    peek p = MyStruct 
         <$> peek (castPtr p)
         <*> peekCAString (trace ("strPtr="++show strPtr) strPtr)
         where strPtr = castPtr (plusPtr p strOffset) :: CString
    poke p x = do
        pokeByteOff (trace ("poke p "++show p) p) numOffset (num x)
        pokeByteOff p strOffset bufPtr
        withCStringLen (str x) $ \(p',l) -> copyBytes bufPtr p' (l+1)
        s <- peekCAString bufPtr
        print $ "s=" ++ show s
        where bufPtr = castPtr $ plusPtr p bufOffset :: CString

foreign import ccall unsafe "./mystruct.h f"
    __f :: Ptr MyStruct -> IO ()
      
f :: MyStruct -> IO MyStruct
f ms = with ms $ \p -> __f p >> peek p

main :: IO ()
main = do
    let myStruct = MyStruct 1 "0123456789"
    with myStruct $ \p -> do
        print p
        m <- peek p
        print m
--    print myStruct
--    newStruct <- f myStruct
--    print newStruct
    return ()
