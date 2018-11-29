module Main where

import           Foreign
import           Foreign.C.Types
import           Foreign.Storable
import           Foreign.C.String
import           Data.Word
import           Debug.Trace (trace)
    
data MyStruct2 = MyStruct2 {
    num :: Word32,
    str :: String
} deriving Show

#include "mystruct.h"

instance Storable MyStruct2 where
    sizeOf _ = {#sizeof MyStruct #}
    alignment _ = 4
    peek p = FtProgramData
        <$> liftM fromIntegral ({#get MyStruct->num #} p)
        <*> liftM fromIntegral ({#get MyStruct->str #} p)
 
    poke p x = do
        {#set MyStruct.num #} p (fromIntegral $ num x)
        {#set MyStruct.str #} p (fromIntegral $ str x)
