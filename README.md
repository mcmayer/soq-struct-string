# struct-string

Suppose you have a C-struct 

```c
typedef struct {
  uint32_t num;
  char*    str;
} MyStruct;
```

and a function `f` that does some operation on it. The `char* num` has to be allocated a sufficient buffer before calling `f`:

```C
char buf[64];	//somehow you know 64 is enough
MyStruct s = {1, buf};
f(buf);
```

The question is how to write a Haskell FFI for this kind of C API. Start with

```haskell
data MyStruct = MyStruct {
    num :: Word32,
    str :: String
} deriving Show
```

and write a `Storable` instance. My idea is to allocate 64 bytes at the end which will serve as buffer for the string:

```haskell
instance Storable MyStruct where
    sizeOf _ = 8{-alignment!-} + sizeOf (nullPtr :: CString) + 64{-buffer-}
    alignment _ = 8
```

`poke` has to change the pointer in `str` to point to the allocated buffer and then the Haskell string has to be copied into it:

```haskell
    poke p x = do
        pokeByteOff p 0 (num x)
        poke strPtr bufPtr
        withCStringLen (str x) $ \(p',l) -> copyBytes bufPtr p' (l+1) -- +1? not sure
        where strPtr = castPtr $ plusPtr p 8 :: Ptr CString
              bufPtr = castPtr $ plusPtr p 16 :: CString
              
```

`peek` is then straightforward:

```haskell
    peek p = MyStruct 
         <$> peek (castPtr p)
         <*> peekCAString (castPtr $ plusPtr p 16)
```

