
--!native
--!strict

-- * Path to 'cases' to test
local cases = script.cases

local TESTS = {
	{ true , cases.numarrays_gen_test } ;
	{ true , cases.iobuffer_gen_test } ;
	{ true , cases.iobitbuffer_gen_test };
}

for _, test : { boolean | ModuleScript } in TESTS do
	if not test[1] then continue end
	local testFunc = require(test[2])
	local success, reason = pcall(function() testFunc() end)

	reason = success and '' or 'Reason: '..reason
	local cheer = success and 'successful!' or 'failed.'
	warn(`Test on {test[2].Name} {cheer} {reason}`)
end