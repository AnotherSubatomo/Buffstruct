
--[=[
	buffstruct/NumberArrays
	JS's signed-sized-arrays reimplemented in pure Luau with buffers.
	Author:						@AnotherSubatomo (GitHub)
	File Creation:				27/11/2024 - 1:00 PM
	SPDX-License-Identifier:	MIT
]=]

--!native

export type PossibleTypes = string | table | number

local function assertNumber(v: number?)
	assert(typeof(v) == 'number', "Buffer access index / value must be a number.")
end

-- * We might be using a table internally to interface
-- with the buffer, but it is still much more memory
-- efficient than ordinary table arrays as: 1) the interfaces
-- are reuseable metatables; 2) we won't have to deal with
-- Luau's table grow vector.
local Uint8_mt = {
	__index = function(self, k)
		assertNumber(k)
		local i = k-1
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readu8(self.__src, i) or nil
	end,

	__newindex = function(self, k, v)
		assertNumber(k); assertNumber(v);
		local i = k-1
		buffer.writeu8(self.__src, i, v)
	end
}

local Uint16_mt = {
	__index = function(self, k)
		assertNumber(k)
		local i = (k-1) * 2
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readu16(self.__src, i) or nil
	end,

	__newindex = function(self, k, v)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 2
		buffer.writeu16(self.__src, i, v)
	end
}

local Uint32_mt = {
	__index = function(self, k)
		assertNumber(k)
		local i = (k-1) * 4
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readu32(self.__src, i) or nil
	end,

	__newindex = function(self, k, v)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 4
		buffer.writeu32(self.__src, i, v)
	end
}

local Int8_mt = {
	__index = function(self, k)
		assertNumber(k)
		local i = k-1
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readi8(self.__src, i) or nil
	end,

	__newindex = function(self, k, v)
		assertNumber(k); assertNumber(v);
		local i = k-1
		buffer.writei8(self.__src, i, v)
	end
}

local Int16_mt = {
	__index = function(self, k)
		assertNumber(k)
		local i = (k-1) * 2
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readi16(self.__src, i) or nil
	end,

	__newindex = function(self, k, v)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 2
		buffer.writei16(self.__src, i, v)
	end
}

local Int32_mt = {
	__index = function(self, k)
		assertNumber(k)
		local i = (k-1) * 4
		local valid = i < self.__lim and i >= 0
		return valid and buffer.readi32(self.__src, i) or nil
	end,

	__newindex = function(self, k, v)
		assertNumber(k); assertNumber(v);
		local i = (k-1) * 4
		buffer.writei32(self.__src, i, v)
	end
}

-- Array constructor functions
function Uint8Array(v: PossibleTypes)
	local vtype, src = typeof(v)
	if vtype == 'number' then src = buffer.create(v)
	elseif vtype == 'string' then src = buffer.fromstring(v)
	elseif vtype == 'table' then
		src = buffer.create(#v)
		for i = 0, #v-1 do buffer.writeu8(src, i, v[i+1]) end
	end
	return setmetatable({
			__src = src,
			__lim = buffer.len(src)
	}, Uint8_mt)
end

function Uint16Array(v: PossibleTypes)
	local vtype, src = typeof(v)
	if vtype == 'number' then src = buffer.create(v)
	elseif vtype == 'string' then src = buffer.fromstring(v)
	elseif vtype == 'table' then
		src = buffer.create(#v*2)
		for i = 0, #v-1 do buffer.writeu16(src, i*2, v[i+1]) end
	end
	return setmetatable({
			__src = src,
			__lim = buffer.len(src) / 2
	}, Uint16_mt)
end

function Uint32Array(v: PossibleTypes)
	local vtype, src = typeof(v)
	if vtype == 'number' then src = buffer.create(v)
	elseif vtype == 'string' then src = buffer.fromstring(v)
	elseif vtype == 'table' then
		src = buffer.create(#v*4)
		for i = 0, #v-1 do buffer.writeu32(src, i*4, v[i+1]) end
	end
	return setmetatable({
			__src = src,
			__lim = buffer.len(src) / 4
	}, Uint32_mt)
end

function Int8Array(v: PossibleTypes)
	local vtype, src = typeof(v)
	if vtype == 'number' then src = buffer.create(v)
	elseif vtype == 'string' then src = buffer.fromstring(v)
	elseif vtype == 'table' then
		src = buffer.create(#v)
		for i = 0, #v-1 do buffer.writei8(src, i, v[i+1]) end
	end
	return setmetatable({
			__src = src,
			__lim = buffer.len(src)
	}, Int8_mt)
end

function Int16Array(v: PossibleTypes)
	local vtype, src = typeof(v)
	if vtype == 'number' then src = buffer.create(v)
	elseif vtype == 'string' then src = buffer.fromstring(v)
	elseif vtype == 'table' then
		src = buffer.create(#v*2)
		for i = 0, #v-1 do buffer.writei16(src, i*2, v[i+1]) end
	end
	return setmetatable({
			__src = src,
			__lim = buffer.len(src) / 2
	}, Int16_mt)
end

function Int32Array(v: PossibleTypes)
	local vtype, src = typeof(v)
	if vtype == 'number' then src = buffer.create(v)
	elseif vtype == 'string' then src = buffer.fromstring(v)
	elseif vtype == 'table' then
		src = buffer.create(#v*4)
		for i = 0, #v-1 do buffer.writei32(src, i*4, v[i+1]) end
	end
	return setmetatable({
			__src = src,
			__lim = buffer.len(src) / 4
	}, Int32_mt)
end

return {
	Uint8Array = Uint8Array ;
	Uint16Array = Uint16Array ;
	Uint32Array = Uint32Array ;

	Int8Array = Int8Array ;
	Int16Array = Int16Array ;
	Int32Array = Int32Array ;
}