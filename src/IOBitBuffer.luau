
--[=[
	buffstruct/IOBitBuffer
	Akin to IOBuffer, but instead of working on a per
	byte basis, it works with the constituent bits.

	Author:                     @AnotherSubatomo (GitHub)
	File Creation:              26/11/2024 - 11:30 AM
	SPDX-License-Identifier:    MIT
]=]

--!native

local ERRORS = {
	"End of buffer access reached." ;
	"Tried to limit buffer access but the lower limit is >= the upper limit." ;
	"Could not create bitstream; 'SegmentSize' + 'ByteOffset' must be lesser than the buffer length." ;
}

local blen = buffer.len
local argue = function (cond: any, msg: string)
	return assert(cond, "@IOBitBuffer: "..msg)
end

local BitBuffer = {}
BitBuffer.__index = BitBuffer

-- [INTERNAL]
-- Creates a new BitBuffer and returns it.
function BitBuffer._new(src: buffer, byte_offset: number?, segment_size: number?)
	byte_offset = byte_offset or 0
	local buff_len = blen(src)
	local extent = segment_size or buff_len - byte_offset
	argue(byte_offset + extent <= buff_len, ERRORS[3])

	local self = setmetatable({}, BitBuffer)
	self._src = src
	self._pos = byte_offset * 8				-- @ current read position in bits
	self._floor = self._pos
	self._mark = self._pos
	self._ceil = self._pos + extent * 8		-- @ buffer read length limit in bits
	return self
end

-- Creates a new empty BitBuffer.
function BitBuffer.create(bytesize: buffer)
	local buff = buffer.create(bytesize)
	return BitBuffer._new(buff, 0, blen(buff))
end

-- Creates a new BitBuffer whose internal buffer is the given Luau buffer.
function BitBuffer.fromLuauBuffer(src: buffer)
	return BitBuffer._new(src, 0, blen(src))
end

-- Creates a new BitBuffer whose internal buffer's content is the given string.
function BitBuffer.fromString(src: string)
	local buff = buffer.fromstring(src)
	return BitBuffer._new(buff, 0, blen(buff))
end

-- Sets the bounds of the buffer access to the given.
-- * Returns the same BitBuffer to allow chaining of mehtods.
function BitBuffer:limit(lower_in_bytes: number, upper_in_bytes: number)
	argue(lower_in_bytes < upper_in_bytes, ERRORS[2])
	local floor = math.max(self._pos, lower_in_bytes * 8)
	local ceil = math.min(self._ceil, upper_in_bytes * 8)

	self._mark = floor ~= self._pos and floor or self._mark
	self._pos = floor
	self._ceil = ceil
	return self
end

-- Store the current pointer offset.
function BitBuffer:mark()
	self._mark = self._pos
end

-- Move the pointer back to the last pointer offset.
function BitBuffer:rewind()
	self._pos = self._mark
end

-- Reads the given amount of bits and returns a `uint` equivalent.
function BitBuffer:readBits(n : number?) : number
	n = n or 1
	argue( self._pos + n <= self._ceil , ERRORS[1] )
	local value = 0

	while n > 0 do
		local byte_index = self._pos // 8
		local bit_index = self._pos % 8

		local n_is_long = n > 8 - bit_index
		local bits_to_read = n_is_long and 8 - bit_index or n
		n -= bits_to_read

		local byte = buffer.readu8(self._src, byte_index)
		local bits = bit32.extract(byte, bit_index, bits_to_read)

		value = bit32.lshift(value, bits_to_read) + bits
		
		self._pos += bits_to_read
	end

    return value
end

-- Reads and returns a single UTF-8 character.
function BitBuffer:readUtf8() : string
	return utf8.char(self:readBits(8))
end

-- Returns a string whose characters' codepoints are a byte worth.
function BitBuffer:readString(count : number) : string
	local result = ""
	for _ = 1, count do
		result ..= self:readUtf8()
	end
	return result
end

-- Returns an array of numbers whose values are between 0 and 2^bitdepth.
function BitBuffer:readArray(count: number, bitdepth: number?) : {number}
	bitdepth = bitdepth or 8
	local result = {}
	for _ = 1, count do
		table.insert(result, self:readBits(bitdepth))
	end
	return result
end

-- Returns a buffer of equivalent byte content and length.
function BitBuffer:readBuffer(len : number) : buffer
	local result = buffer.create(len)
	for offset = 0, len - 1 do
		buffer.writeu8(result, offset, self:readBits(8))
	end
	return result
end

-- Reads a bit and returns an equivalent boolean value.
function BitBuffer:readFlag() : boolean
	return self:readBits() == 1
end

-- Skips the amount of bits specified.
function BitBuffer:skipBits(n : number?)
	n = n or 1
	argue( self._pos + n <= self._ceil , ERRORS[1] )
	self._pos += n
end

-- Aligns to the *next* byte, possibly skipping some bits.
function BitBuffer:byteAlign()
	local excess = self._pos % 8
	if excess == 0 then return end
	self._pos += 8 - excess
end

-- Disposes the BitBuffer object and returns the internal buffer.
function BitBuffer:close() : buffer
	local buff = self._src
	setmetatable(self, nil)
	self._src = nil
	self._pos = nil
	self._floor = nil
	self._ceil = nil
	self._mark = nil
	self = nil
	return buff
end

return BitBuffer