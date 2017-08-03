package.path="?/init.lua;"..package.path
require("bin")
--~ test=bin.new()
--~ test:addBlock({
--~ 	test=134534,
--~ 	23452,
--~ 	65723,
--~ 	45744,
--~ 	523463,
--~ 	test2=6234562,
--~ 	test3="HELLO WORLD!",
--~ 	test4=true,
--~ 	test5=false,
--~ 	test6={a=1,b=2,3,4},
--~ 	test6={c=1345,d=2345,3567,4789,{1,true,false,"HI"},c={1,2,3,"HI2"}},
--~ 	test7=function() print("Hello World!") end
--~ },nil,"t")
--~ test:addBlock(1234,4)
--~ test:tofile("test.dat")
--~ test2=bin.load("test.dat")
--~ t=test2:getBlock("t")
--~ table.print(t)
--~ print("-----")
--~ print(test2:getBlock("n",4))

--~ print("bfType:",test:getBlock("s",2))
--~ print("bfSize:",test:getBlock("%E",4))
--~ print("bfReserved1:",test:getBlock("%E",2))
--~ print("bfReserved2:",test:getBlock("%E",2))
--~ print("bfOffBits:",test:getBlock("%E",4))
--~ print("biSize:",test:getBlock("%E",4))
--~ print("biWidth:",test:getBlock("%E",4))
--~ print("biHeight:",test:getBlock("%E",4))
--~ print("biPlanes:",test:getBlock("%E",2))
--~ print("biBitCount:",test:getBlock("%E",2))
--~ print("biCompression:",test:getBlock("%E",4))
--~ print("biSizeImage:",test:getBlock("%E",4))
--~ print("biXPelsPerMeter:",test:getBlock("%E",4))
--~ print("biYPelsPerMeter:",test:getBlock("%E",4))
--~ print("biClrUsed:",test:getBlock("%E",4))
--~ print("biClrImportant:",test:getBlock("%E",4))

-- allocate space in a file and work with it directly. No need to worry about seeking and such!
function bin:newDataBufferFromBin(size,fill) -- fills with \0 or nul or with what you enter IF the nothing exists inside the bin file.
	--
end
function bin.newDataBuffer(size,fill) -- fills with \0 or nul or with what you enter
	local c={}
	local fill=fill or "\0"
	c.data={self=c}
	c.Type="buffer"
	c.size=size or 0 -- 0 means an infinite buffer, sometimes useful
	for i=1,size do
		c.data[i]=fill
	end
	local mt={
		__index=function(t,k)
			if type(k)=="number" then
				local data=t.data[k]
				if data then
					return string.byte(data)
				else
					error("Index out of range!")
				end
			elseif type(k)=="string" then
				local num=tonumber(k)
				if num then
					local data=t.data[num]
					if data then
						return data
					else
						error("Index out of range!")
					end
				else
					error("Only number-strings and numbers can be indexed!")
				end
			else
				error("Only number-strings and numbers can be indexed!")
			end
		end,
		__newindex=function(t,k,v)
			if type(k)~="number" then error("Can only set a buffers data with a numeric index!") end
			local data=""
			if type(v)=="string" then
				data=v
			elseif type(v)=="number" then
				data=string.char(v)
			else
				-- try to normalize the data of type v
				data=bin.normalizeData(v)
			end
			t:fillBuffer(k,data)
		end,
		__tostring=function(t)
			return t:getData()
		end,
	}
	function c:fillBuffer(a,data)
		local len=#data
		if len==1 then
			self.data[a]=data
		else
			local i=a-1
			for d in data:gmatch(".") do
				i=i+1
				if i>c.size then
					return #data-i+a
				end
				self.data[i]=d
			end
			return #data-i+(a-1)
		end
	end
	function c:getData(a,b,fmt) -- LATER
		local dat=bin.new(table.concat(self.data,"",a,b))
		local n=dat:getSize()
		return dat:getBlock(fmt or "s",n)
	end
	function c:getSize()
		return #self:getData()
	end
	setmetatable(c,mt)
	return c
end
test=bin.newDataBuffer(16)
test[1]=bits.numToBytes(1234,2,"%E")
test[5]=bin.new("Hello")
test[10]=24
print(test:getData(1,4,"n"))
print(test["5"])
print(test["6"])
print(test["7"])
print(test["8"])
print(test["9"])
print(test[10])
print(test)
print(test:getSize())
