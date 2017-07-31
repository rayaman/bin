-- Well Its finally time for that massive rewrite that has been long awaited for
-- We need to keep things thread safe or the rewrite would have been in vain... Also this will ensure that all features are working perfectly
bin={}
bin.Version={5,0,0}
bin.stage='stable'
bin.data=''
bin.t='bin'
bin.__index = bin
bin.__tostring=function(self) return self:getData() end
bin.__len=function(self) return self:getlength() end
bits={}
bits.data=''
bits.t='bits'
bits.__index = bits
bits.__tostring=function(self) return self.data end
bits.__len=function(self) return (#self.data)/8 end
bin.lastBlockSize=0
bin.streams={} -- FIX FOR THREADING!!!
-- Helpers
if jit then
	bit=require("bit")
elseif bit32 then
	bit=bit32
else
	bit=require("bin.no_jit_bit")
end
require("bin.utils")
local base64=require("bin.base64")
local base91=require("bin.base91")
bits=require("bin.bits")
function bin.normalizeData(data) -- unified function to allow
	if type(data)=="string" then return data end
	if type(data)=="table" then
		if data.Type=="bin" or data.Type=="streamable"  then
			return data:getData()
		elseif data.Type=="bits" then
			return data:toSbytes()
		elseif data.Type=="buffer" then
			-- LATER
		elseif data.Type=="sink" then
			-- LATER
		else
			error("I do not know how to handle this data!")
		end
	elseif type(data)=="userdata" then
		if tostring(data):sub(1,4)=="file" then
			local cur=data:seek("cur")
			data:seek("set",0)
			local dat=data:read("*a")
			data:seek("set",cur)
			return dat
		end
	end
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
	data=tostring(data or "")
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
function bin.freshStream(file)
	bin.new():tofile(file)
	return bin.stream(file,false)
end
-- Core Methods
function bin:canStreamWrite()
	return (self.stream and not(self.lock))
end
function bin:seekSet(n)
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
function bin:getData(fmt)
	local data=""
	if self.stream then
		local cur=self.workingfile:seek("cur")
		self.workingfile:seek("set",0)
		data=self.workingfile:read("*a")
		self.workingfile:seek("set",cur)
	else
		data=self.data
	end
	if fmt=="%x" or fmt=="hex" then
		return bin.toHex(data):lower()
	elseif fmt=="%X" or fmt=="HEX" then
		return bin.toHex(data)
	elseif fmt=="%b" or fmt=="b64" then
		return bin.toB64(data)
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
		--return bin.toB64() -- LATER
	elseif fmt then
		return string.format(fmt, len)
	else
		return len
	end
end
function bin:tackE(data,size,h)
	local data=bin.normalizeData(data)
	local cur=self:getSize()
	self:seekSet(self:getSize()+1)
	self:write(data,size)
	if h then
		self:seekSet(cur+1)
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
function bin.getnumber(num,len,fmt,func)
	local num=bits.numToBytes(num,len,func)
	if fmt=="%B" then
		return bin.endianflop(num)
	end
	return num
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
