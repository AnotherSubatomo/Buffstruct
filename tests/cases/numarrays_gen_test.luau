
-- Generic test for number arrays.
--!native

local NumberArrays = require(game.ReplicatedStorage.buffstruct.NumberArrays)

return function ()
	-- TEST: Function sanity check
	local Sample = "Strawberry Fields Forever!"
	local Transform = {utf8.codepoint(Sample, 1, #Sample)}
	
	for _, ArrayConstructor in NumberArrays do
		local Array = ArrayConstructor(Transform)
		local Result = ""
		for i = 1, #Transform do
			Result ..= utf8.char(Array[i])
		end
		-- * Print should always match the sample string,
		-- no matter the array constructor.
		print(Result)
	end
end