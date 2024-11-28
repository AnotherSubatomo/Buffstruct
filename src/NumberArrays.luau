
--[=[
	buffstruct/NumberArrays
	JS's signed-sized-arrays reimplemented in pure Luau with buffers.
	
	Author:                     @AnotherSubatomo (GitHub)
	File Creation:              27/11/2024 - 1:00 PM
	SPDX-License-Identifier:    MIT
]=]

--!native
--!strict

export type PossibleTypes = string | number | {number}
type IntTypes = 'u8' | 'u16' | 'u32' | 'i8' | 'i16' | 'i32' | 'f32' | 'f64'
type Writer = (buffer, number, number) -> ()

local WRITERS : {[IntTypes]: Writer} = {
	u8 = buffer.writeu8,
	u16 = buffer.writeu16,
	u32 = buffer.writeu32,
	i8 = buffer.writei8,
	i16 = buffer.writei16,
	i32 = buffer.writei32,
	f32 = buffer.writef32,
	f64 = buffer.writef64
}

local BYTESIZE : {[IntTypes]: number} = {
	u8 = 1, u16 = 2, u32 = 4, f32 = 4,
	i8 = 1, i16 = 2, i32 = 4, f64 = 8
}

local function turnToBuffer(v: PossibleTypes, type: IntTypes) : buffer
	local vtype: string, src: buffer? = typeof(v), nil
	local writer: Writer, readsize: number = WRITERS[type], BYTESIZE[type]

	if vtype == 'number' then src = buffer.create(v :: number)
	elseif vtype == 'string' then src = buffer.fromstring(v :: string)
	elseif vtype == 'table' then
		v = v :: {number}
		src = buffer.create((#v)*readsize)
		for i = 0, (#v)-1 do writer(src, i*readsize, v[i+1]) end
	end

	return src :: buffer
end

local function assertNumber(v: number?)
	assert(typeof(v) == 'number', "Buffer access index / value must be a number.")
end

-- * We might be using a table internally to interface
-- with the buffer, but it is still much more memory
-- efficient than ordinary table arrays as: 1) the interfaces
-- are reuseable metatables; 2) we won't have to deal with
-- Luau's table grow vector.
local Uint8_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = k-1
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readu8(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = k-1
		buffer.writeu8(self.__src, i, v)
	end
}

local Uint16_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = (k-1) * 2
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readu16(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 2
		buffer.writeu16(self.__src, i, v)
	end
}

local Uint32_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = (k-1) * 4
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readu32(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 4
		buffer.writeu32(self.__src, i, v)
	end
}

local Int8_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = k-1
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readi8(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = k-1
		buffer.writei8(self.__src, i, v)
	end
}

local Int16_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = (k-1) * 2
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readi16(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 2
		buffer.writei16(self.__src, i, v)
	end
}

local Int32_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = (k-1) * 4
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readi32(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 4
		buffer.writei32(self.__src, i, v)
	end
}

local Float32_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = (k-1) * 4
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readf32(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 4
		buffer.writef32(self.__src, i, v)
	end
}

local Float64_mt = {
	__index = function(self, k: number)
		assertNumber(k)
		local i = (k-1) * 8
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readf64(self.__src, i) or nil
	end,

	__newindex = function(self, k: number, v: number)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 8
		buffer.writef64(self.__src, i, v)
	end
}

-- Array constructor functions
function Uint8Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'u8')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Uint8_mt)
end

function Uint16Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'u16')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Uint16_mt)
end

function Uint32Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'u32')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Uint32_mt)
end

function Int8Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'i8')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Int8_mt)
end

function Int16Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'i16')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Int16_mt)
end

function Int32Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'i32')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Int32_mt)
end

function Float32Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'f32')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Float32_mt)
end

function Float64Array(v: PossibleTypes)
	local src = turnToBuffer(v, 'f64')
	return setmetatable({
		__src = src,
		__lim = buffer.len(src)
	}, Float64_mt)
end

return {
	Uint8Array = Uint8Array ;
	Uint16Array = Uint16Array ;
	Uint32Array = Uint32Array ;

	Int8Array = Int8Array ;
	Int16Array = Int16Array ;
	Int32Array = Int32Array ;
	
	Float32Array = Float32Array ;
	Float64Array = Float64Array ;
}