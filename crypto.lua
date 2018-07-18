package.path="?/init.lua;"..package.path
require("bin")
local bits = bin.bits
for i=0,255 do
	print(bits.new(i))
end
