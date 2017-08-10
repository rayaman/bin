bin={}
bin.Version={5,0,0}
bin.stage='stable'
bin.data=''
bin.t='bin'
bin.__index = bin
bin.__tostring=function(self) return self:getData() end
bin.__len=function(self) return self:getlength() end
bin.lastBlockSize=0
bin.streams={}
-- Helpers
function bin.getVersion()
	return bin.Version[1]..'.'..bin.Version[2]..'.'..bin.Version[3]
end
require("bin.utils")
if jit then
	bit=require("bit")
elseif bit32 then
	bit=bit32
else
	bit=require("bin.no_jit_bit")
end
base64=require("bin.base64")
base91=require("bin.base91")
bin.lzw=require("bin.lzw") -- A WIP
bits=require("bin.bits")
infinabits=require("bin.infinabits") -- like the bits library but works past 32 bits for 32bit lua and 64 bits for 64 bit lua.
bin.md5=require("bin.md5")
randomGen=require("bin.random")
function bin.setBitsInterface(int)
	bin.defualtBit=int or bits
end
bin.setBitsInterface()
function bin.normalizeData(data) -- unified function to allow for all types to string
	if type(data)=="string" then return data end
	if type(data)=="table" then
		if data.Type=="bin" or data.Type=="streamable" or data.Type=="buffer" then
			return data:getData()
		elseif data.Type=="bits" or data.Type=="infinabits" then
			return data:toSbytes()
		elseif data.Type=="sink" then
			-- LATER
		else
			return ""
		end
	elseif type(data)=="userdata" then
		if tostring(data):sub(1,4)=="file" then
			local cur=data:seek("cur")
			data:seek("set",0)
			local dat=data:read("*a")
			data:seek("set",cur)
			return dat
		else
			error("File handles are the only userdata that can be used!")
		end
	end
end
function bin.resolveType(tab) -- used in getblock for auto object creation. Internal method
	if tab.Type then
		if tab.Type=="bin" then
			return bin.new(tab.data)
		elseif tab.Type=="streamable" then
			if bin.fileExist(tab.file) then return nil,"Cannot load the stream file, source file does not exist!" end
			return bin.stream(tab.file,tab.lock)
		elseif tab.Type=="buffer" then
			local buf=bin.newDataBuffer(tab.size)
			buf[1]=tab:getData()
			return buf
		elseif tab.Type=="bits" then
			local b=bits.new("")
			b.data=tab.data
			return b
		elseif tab.Type=="infinabits" then
			local b=infinabits.new("")
			b.data=tab.data
			return b
		elseif tab.Type=="sink" then
			return bin.newSync(tab.data)
		end
	else return tab end
end
function bin.fileExist(path)
	g=io.open(path or '','r')
	if path =='' then
		p='empty path'
		return nil
	end
	if g~=nil and true or false then
		p=(g~=nil and true or false)
	end
	if g~=nil then
		io.close(g)
	else
		return false
	end
	return p
end
function bin.toHex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end
function bin.fromHex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end
function bin.toBase64(s)
	return base64.encode(s)
end
function bin.fromBase64(s)
	return base64.decode(s)
end
function bin.toBase91(s)
	return base91.encode(s)
end
function bin.fromBase91(s)
	return base91.decode(s)
end
-- Constructors
function bin.new(data)
	data=bin.normalizeData(data)
	local c = {}
    setmetatable(c, bin)
	c.data=data
	c.Type="bin"
	c.t="bin"
	c.pos=1
	c.stream=false
	return c
end
function bin.newFromBase64(data)
	return bin.new(bin.fromBase64(data))
end
function bin.newFromBase91(data)
	return bin.new(bin.fromBase91(data))
end
function bin.newFromHex(data)
	return bin.new(bin.fromHex(data))
end
function bin.load(path)
	if type(path) ~= "string" then error("Path must be a string!") end
	local f = io.open(path, 'rb')
	local content = f:read('*a')
	f:close()
	return bin.new(content)
end
function bin.stream(file,l)
	if not(l==false) then l=true end
	local c=bin.new()
	c.Type="streamable"
	c.t="streamable"
	if bin.streams[file]~=nil then
		c.file=file
		c.lock = l
		c.workingfile=bin.streams[file][1].workingfile
		bin.streams[file][2]=bin.streams[file][2]+1
		c.stream=true
		return c
	end
	if bin.fileExist(file) then
		c.file=file
		c.lock = l
		c.workingfile=io.open(file,'rb+')
	else
		c.file=file
		c.lock = l
		c.workingfile=io.open(file,'w')
		io.close(c.workingfile)
		c.workingfile=io.open(file,'rb+')
	end
	c.stream=true
	bin.streams[file]={c,1}
	return c
end
function bin.newTempFile()
	local c=bin.new()
	c.file=file
	c.lock = false
	c.workingfile=io.tmpfile()
	c.stream=true
	return c
end
function bin.freshStream(file)
	bin.new():tofile(file)
	return bin.stream(file,false)
end
-- Core Methods
function bin:canStreamWrite()
	return (self.stream and not(self.lock))
end
function bin:getSeek()
	if self.stream then
		return self.workingfile:seek("cur")+1
	else
		return self.pos
	end
end
function bin:setSeek(n)
	if self.stream then
		self.workingfile:seek("set",n-1)
	else
		self.pos=n
	end
end
function bin:seek(n)
	if self.stream then
		if not n then return self.workingfile:seek("cur") end
		local cur=self.workingfile:seek("cur")
		self.workingfile:seek("set",cur+n)
	else
		if not n then return self.pos end
		if #self.data-(self.pos-1)<n then
			print(n-((#self.data)-(self.pos-1)))
			self:write(string.rep("\0",n-((#self.data)-(self.pos-1))))
			return
		end
		self.pos=self.pos+n
	end
end
function bin:read(n)
	if self.stream then
		return self.workingfile:read(n)
	else
		local data=self.data:sub(self.pos,self.pos+n-1)
		self.pos=self.pos+n
		if data=="" then return end
		return data
	end
end
function bin:write(data,size)
	local data=bin.normalizeData(data)
	local dsize=#data
	local size=tonumber(size or dsize)
	if dsize>size then
		data = data:sub(1,size)
	elseif dsize<size then
		data=data..string.rep("\0",size-dsize)
	end
	if self:canStreamWrite() then
		self.workingfile:write(data)
	elseif self.Type=="bin" then
		local tab={}
		if self.pos==1 then
			tab={data,self.data:sub(self.pos+size)}
		else
			tab={self.data:sub(1,self.pos-1),data,self.data:sub(self.pos+size)}
		end
		self.pos=self.pos+size
		self.data=table.concat(tab)
	else
		error("Attempted to write to a locked file!")
	end
end
function bin:sub(a,b)
	local data=""
	if self.stream then
		local cur=self.workingfile:seek("cur")
		self.workingfile:seek("set",a-1)
		data=self.workingfile:read(b-(a-1))
		self.workingfile:seek("set",cur)
	else
		data=self.data:sub(a,b)
	end
	return data
end
function bin:getData(a,b,fmt)
	local data=""
	if a or b then
		data=self:sub(a,b)
	else
		if self.stream then
			local cur=self.workingfile:seek("cur")
			self.workingfile:seek("set",0)
			data=self.workingfile:read("*a")
			self.workingfile:seek("set",cur)
		else
			data=self.data
		end
	end
	if fmt=="%x" or fmt=="hex" then
		return bin.toHex(data):lower()
	elseif fmt=="%X" or fmt=="HEX" then
		return bin.toHex(data)
	elseif fmt=="%b" or fmt=="b64" then
		return bin.toB64(data)
	elseif fmt then
		return bin.new(data):getBlock(fmt,#data)
	end
	return data
end
function bin:getSize(fmt)
	local len=0
	if self.stream then
		local cur=self.workingfile:seek("cur")
		len=self.workingfile:seek("end")
		self.workingfile:seek("set",cur)
	else
		len=#self.data
	end
	if fmt=="%b" then
		return bin.toB64()
	elseif fmt then
		return string.format(fmt, len)
	else
		return len
	end
end
function bin:tackE(data,size,h)
	local data=bin.normalizeData(data)
	local cur=self:getSize()
	self:setSeek(self:getSize()+1)
	self:write(data,size)
	if h then
		self:setSeek(cur+1)
	end
end
function bin:tonumber(a,b)
	local temp={}
	if a then
		temp.data=self:sub(a,b)
	else
		temp=self
	end
	local l,r=0,0
	local g=#temp.data
	for i=1,g do
		r=r+(256^(g-i))*string.byte(string.sub(temp.data,i,i))
		l=l+(256^(i-1))*string.byte(string.sub(temp.data,i,i))
	end
	return r,l
end
function bin.endianflop(data)
	return string.reverse(data)
end
function bin:tofile(name)
	if self.stream then return end
	if not name then error("Must include a filename to save as!") end
	file = io.open(name, "wb")
	file:write(self.data)
	file:close()
end
function bin:close()
	if self.stream then
		if bin.streams[self.file][2]==1 then
			bin.streams[self.file]=nil
			self.workingfile:close()
		else
			bin.streams[self.file][2]=bin.streams[self.file][2]-1
			self.workingfile=io.tmpfile()
			self.workingfile:close()
		end
	end
end
function bin:getBlock(t,n)
	local data=""
	if not n then
		if bin.registerBlocks[t] then
			return bin.registerBlocks[t][1](nil,self)
		else
			error("Unknown format! Cannot read from file: "..tostring(t))
		end
	else
		if t=="n" or t=="%e" or t=="%E" then
			data=self:read(n)
			local numB=bin.defualtBit.new(data)
			local numL=bin.defualtBit.new(string.reverse(data))
			local little=numL:tonumber(0)
			local big=numB:tonumber(0)
			if t=="%E" then
				return big
			elseif t=="%X" then
				return bin.toHex(data):upper()
			elseif t=="%x" then
				return bin.toHex(data):lower()
			elseif t=="%b" then
				return bin.toB64(data)
			elseif t=="%e" then
				return little
			end
			return big,little
		elseif t=="s" then
			return self:read(n)
		elseif bin.registerBlocks[t] then
			return bin.registerBlocks[t][1](n,self)
		else
			error("Unknown format! Cannot read from file: "..tostring(t))
		end
	end
end
function bin:addBlock(d,fit,fmt)
	if not fmt then fmt=type(d):sub(1,1) end
	if type(d)=="number" then
		local data=bin.defualtBit.numToBytes(d,fit or 4,fmt,function()
			error("Overflow! Space allotted for number is smaller than the number takes up. Increase the fit!")
		end)
		self:tackE(data)
	elseif type(d)=="string" then
		local data=d:sub(1,fit or -1)
		if #data<(fit or #data) then
			data=data..string.rep("\0",fit-#data)
		end
		self:tackE(data)
	elseif bin.registerBlocks[fmt] then
		self:tackE(bin.registerBlocks[fmt][2](d,fit,fmt,self,bin.registerBlocks[fmt][2]))
	end
end
bin.registerBlocks={}
function bin.registerBlock(t,funcG,funcA)
	bin.registerBlocks[t]={funcG,funcA}
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
function bin:newDataBufferFromStream(pos,size,fill) -- fills with \0 or nul or with what you enter IF the nothing exists inside the bin file.
	local s=self:getSize()
	if not self.stream then error("Can only created a streamed buffer on a streamable file!") end
	if s==0 then
		self:write(string.rep("\0",pos+size))
	end
	self:setSeek(1)
	local c=bin.newDataBuffer(size,fill)
	rawset(c,"pos",pos)
	rawset(c,"size",size)
	rawset(c,"fill",fill)
	rawset(c,"bin",self)
	rawset(c,"sync",function(self)
		local cur=self.bin:getSeek()
		self.bin:setSeek(self.pos)
		self.bin:write(self:getData(),size)
		self.bin:setSeek(cur)
	end)
	c:fillBuffer(1,self:sub(pos,pos+size))
	function c:fillBuffer(a,data)
		local len=#data
		if len==1 then
			self.data[a]=data
			self:sync()
		else
			local i=a-1
			for d in data:gmatch(".") do
				i=i+1
				if i>c.size then
					self:sync()
					return #data-i+a
				end
				self.data[i]=d
			end
			self:sync()
			return #data-i+(a-1)
		end
	end
	return c
end
function bin:getMD5Hash()
	self:setSeek(1)
	local len=self:getSize()
	local md5=bin.md5.new()
	local SIZE=2048
	if len>SIZE then
		local dat=self:read(SIZE)
		while dat~=nil do
			md5:update(dat)
			dat=self:read(SIZE)
		end
		return bin.md5.tohex(md5:finish()):upper()
	else
		return bin.md5.sumhexa(self:getData()):upper()
	end
end
function bin:getHash()
	if self:getSize()==0 then
		return "NaN"
	end
	n=32
	local rand = randomGen:newND(1,self:getSize(),self:getSize())
	local h,g={},0
	for i=1,n do
		g=rand:nextInt()
		table.insert(h,bin.toHex(self:sub(g,g)))
	end
	return table.concat(h,'')
end
function bin:flipbits()
	if self:canStreamWrite() then
		self:setSeek(1)
		for i=1,self:getSize() do
			self:write(string.char(255-string.byte(self:sub(i,i))))
		end
	else
		local temp={}
		for i=1,#self.data do
			table.insert(temp,string.char(255-string.byte(string.sub(self.data,i,i))))
		end
		self.data=table.concat(temp,'')
	end
end
function bin:encrypt()
	self:flipbits()
end
function bin:decrypt()
	self:flipbits()
end
require("bin.extraBlocks") -- registered blocks that you can use
