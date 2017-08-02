package.path="?/init.lua;"..package.path
require("bin")
test=bin.new(bin.getnumber(12345,4,"%B"))
print(test:tonumber())
