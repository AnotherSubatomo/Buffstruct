
-- Generic test for IOBuffers.
--!native

local IOBitBuffer = require(game.ReplicatedStorage.buffstruct.IOBitBuffer)

return function ()
	-- TEST: Function sanity check
	local Sample = "Strawberry Fields Forever!"
	local Stream = IOBitBuffer.fromString(Sample)
	
	local Result = ""
	
	for _ = 1, #Sample do
			Result ..= utf8.char(Stream:readBits(8))
	end
	-- * Print should always match the sample string.
	print(Result)
end