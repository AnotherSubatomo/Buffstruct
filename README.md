<div align="center">

# Buffstruct
Common data structures reimplemented with Luau buffers for better memory management.

![Last Commit](https://img.shields.io/github/last-commit/AnotherSubatomo/Buffstruct/main
) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

</div>

---

### Usage
The following will discuss and explain the structure and how to use them.

#### Number Arrays
Number arrays are <u>static arrays that only holds numerical values that fit the *type* (*uint8*, *int8*, *uint16*, etc.) they describe.</u>

Number arrays are incredibly (and only) useful when they are being used to work with large data streams with a determinable byte length.

The static and type-strict nature of the structure is what's leveraged for performance, as by doing so, we can allow just the right amount of memory the array structure needs. It is unlike regular Lua tables, which will have to grow it's buffers in a geometric sequence, often times allocating way more memory that we need it to be.

You can make a new number array like the following:
```lua
local NumberArrays = require("path/NumberArrays")
local Uint8Array = NumberArrays.Uint8Array

local Sample = Uint8Array("Hello!")
```

Here's the exciting part — and one of the things that (I think) really make these arrays special — is how you can access them like how you would with regular tables!
```lua
-- ...
local Sample = Uint8Array("Hello!")
print(utf8.char(Sample[1])) --> "H"

Sample[2] = utf8.codepoint("a")
print(utf8.char(Sample[2])) --> "a"
```

Isn't that nuts?! You get to keep the table-like interaction but also made it more memory-efficient!

* *but in this case, the overhead of the internal table might actually outweight the efficiency of buffers because the input is relatively small; the overhead does become negligible on bigger inputs though*

Oh, and attempts of accessing indexes that are outside the buffer's bounds will only return `nil`, just like how regular tables do.
```lua
-- ...
print(Sample[10]) --> nil
```

#### IOBuffer

The IOBuffer is an object that allows you to stream your data, automatically managing the byte offset as you read and write. This object provides little and big endian, reading and writing functions. *Floats are currently not supported.*

IOBuffers are incredibly (and only) useful in scenarios that require efficient, intermediate storage for sequential read/write operations such as codecs and network operations.

You can make a new IOBuffer by doing the following:
```lua
local IOBuffer = require("path/IOBuffer")

local Sample = IOBuffer.fromString("Strawberry Fields Forever!")
```

and... y'know what, I'll just let the code sample speak for itself.
```lua
-- ...
print(Sample:readu8())      --> 83; the codepoint of "S"
print(Sample:readString(2)) --> "tr"
print(Sample:readArray(2))  --> { 97 , 119 }; the codepoints of "a" and "w" respectively
Sample:skip(6)
print(Sample:readString(6)) --> "Fields"
-- ...
```

This object has a lot more methods, which you can learn more about (and even better) just by reading the source code.

---

## Getting Started
To build the place from scratch, use:

```bash
rojo build -o "Buffstruct.rbxlx"
```

Next, open `Buffstruct.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help, check out [the Rojo documentation](https://rojo.space/docs).