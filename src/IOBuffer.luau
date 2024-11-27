
--[=[
	buffstruct/IOBuffer
	An IOBuffer implementation, akin to JS's IOBuffer implementation.
	Supports little and big endian read and write.
	
	* Floats are currently not supported.

	Author:						@AnotherSubatomo (GitHub)
	File Creation:				25/11/2024 - 11:30 AM
	SPDX-License-Identifier:	MIT
]=]

--!native

-- Out of bounds message
local OOB_MSG = "Buffer access is out of bounds."
local cxt = function (msg : string) return "@IOBuffer: "..msg end

local bfr = buffer
local readu8 = buffer.readu8
local writeu8 = buffer.writeu8

-- * BIT32 ONLY; The overhead of this function is still not determined
function swapEndianness32(n: number, bytesize: number) : number
	return bit32.rshift(bit32.byteswap(n), (4 - bytesize) * 8)
end

local Buffer = {}
Buffer.__index = Buffer

export type IOBuffer = typeof(Buffer) & {
	src: buffer,	-- internal buffer to read from and write to
	pos: number,	-- access offset
	len: number,	-- length of the buffer
	ceil: number,	-- upper limit of buffer access
	floor: number	-- lower limit of buffer access
}

-- Creates a new empty IOBuffer.
function Buffer.create(size: number) : IOBuffer
	local self = setmetatable({}, Buffer)
	self.src = bfr.create(size)
	self.len = size
	self.pos = 0
	self._mark = 0
	self.floor = 0
	self.ceil = self.len
	return self
end

-- Creates an IOBuffer whose internal buffer is the given Luau buffer.
function Buffer.fromLuauBuffer(b: buffer) : IOBuffer
	local self = setmetatable({}, Buffer)
	self.src = b
	self.len = bfr.len(b)
	self.pos = 0
	self._mark = 0
	self.floor = 0
	self.ceil = self.len
	return self
end

-- Creates an IOBuffer based on the given string.
function Buffer.fromString(str: string) : IOBuffer
	local self = setmetatable({}, Buffer)
	self.src = bfr.fromstring(str)
	self.len = bfr.len(self.src)
	self.pos = 0
	self._mark = 0
	self.floor = 0
	self.ceil = self.len
	return self
end

-- [INTERNAL] Makes sure that the offset is within the buffer's upper and lower bounds.
function Buffer:__assertWithinBounds(offset: number)
	assert(offset < self.ceil and offset >= self.floor, cxt(OOB_MSG))
end

-- Creates an IOBuffer with the same internal buffer as the IOBuffer
-- it was derived from, whose access is limited within the given bounds.
function Buffer:derive(lower: number?, upper: number?) : IOBuffer
	local floor = lower or self.pos
	local ceil = upper or self.ceil
	self:__assertWithinBounds(floor)
	self:__assertWithinBounds(ceil)
	local newself : IOBuffer = setmetatable({}, Buffer)
	newself.src = self.src
	newself.len = ceil - floor
	newself.pos = floor
	newself._mark = floor
	newself.floor = floor
	newself.ceil = ceil
	return newself
end

-- Checks whether the size after the current offset being accessed is within the buffer's bounds.
function Buffer:available(bytesize: number) : boolean
	local offset = self.pos + bytesize
	return offset < self.ceil and offset >= self.floor
end

-- Skips the given amount of bytes.
function Buffer:skip(n: number)
	self:__assertWithinBounds(self.pos + n)
	self.pos += n
end

-- Sets the current byte offset to the given.
function Buffer:seek(offset: number)
	self:__assertWithinBounds(offset)
	self.pos = offset
end

-- Store the current pointer offset.
function Buffer:mark()
	self._mark = self.pos
end

-- Move the pointer back to the last pointer offset.
function Buffer:rewind()
	self.pos = self._mark
end

-- ----------[=[ READ FUNCTIONS ]=]----------
function Buffer:readu8() : number
	local value = readu8(self.src, self.pos)
	self.pos += 1
	return value
end

function Buffer:readString(count: number) : string
	local value = bfr.readstring(self.src, self.pos, count)
	self.pos += count
	return value
end

function Buffer:readArray(count: number) : {number}
	local value = {}
	for _ = 1, count do table.insert(value, self:readu8()) end
	return value
end

-- # UINT / INT little endian methods
function Buffer:readu16LE() : number
	local value = bfr.readu16(self.src, self.pos)
	self.pos += 2
	return value
end

function Buffer:readu32LE() : number
	local value = bfr.readu32(self.src, self.pos)
	self.pos += 4
	return value
end

function Buffer:readi16LE() : number
	local value = bfr.readi16(self.src, self.pos)
	self.pos += 2
	return value
end

function Buffer:readi32LE() : number
	local value = bfr.readi32(self.src, self.pos)
	self.pos += 4
	return value
end

-- # UINT / INT big endian methods
function Buffer:readu16BE() : number
	return swapEndianness32(self:readu16LE(), 2)
end

function Buffer:readu32BE() : number
	return swapEndianness32(self:readu32LE(), 4)
end
function Buffer:readi16BE() : number
	return swapEndianness32(self:readi16LE(), 2)
end

function Buffer:readi32BE() : number
	return swapEndianness32(self:readi32LE(), 4)
end

-- ----------[=[ WRITE FUNCTIONS ]=]----------
function Buffer:writeu8(value: number)
	writeu8(self.src, self.pos, value)
	self.pos += 1
end

function Buffer:writeString(value: number) : string
	bfr.writestring(self.src, self.pos, value)
	self.pos += #value
end

function Buffer:writeArray(array: number) : {number}
	for value in array do self:writeu8(value) end
end

-- # UINT / INT little endian methods
function Buffer:writeu16LE(value: number) : number
	bfr.writeu16(self.src, self.pos, value)
	self.pos += 2
end

function Buffer:writeu32LE(value: number) : number
	bfr.writeu32(self.src, self.pos, value)
	self.pos += 4
end

function Buffer:writei16LE(value: number) : number
	bfr.writei16(self.src, self.pos, value)
	self.pos += 2
end

function Buffer:writei32LE(value: number) : number
	bfr.writei32(self.src, self.pos, value)
	self.pos += 4
end

-- # UINT / INT big endian methods
function Buffer:writeu16BE(value: number) : number
	self:writeu16LE(swapEndianness32(value, 2))
end

function Buffer:writeu32BE(value: number) : number
	self:writeu32LE(swapEndianness32(value, 4))
end

function Buffer:writei16BE(value: number) : number
	self:writei16LE(swapEndianness32(value, 2))
end

function Buffer:writei32BE(value: number) : number
	self:writei32LE(swapEndianness32(value, 4))
end

return Buffer