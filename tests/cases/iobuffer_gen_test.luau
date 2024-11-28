
-- Generic test for IOBuffers.
--!native

local IOBuffer = require(game.ReplicatedStorage.buffstruct.IOBuffer)

return function ()
	-- TEST: Function sanity check
	local Sample = "Strawberry Fields Forever!"
	local Stream = IOBuffer.fromString(Sample)
	
	local Result = ""
	for _ = 1, #Sample do
			Result ..= Stream:readString(1)
	end
	-- * Print should always match the sample string.
	print(Result)
end