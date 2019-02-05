bin={}
bin.Version={6,0,0}
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
function table.print(tbl, indent)
	if not indent then indent = 0 end
		for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			table.print(v, indent+1)
		elseif type(v) == 'boolean' then
			print(formatting .. tostring(v))
		else
			print(formatting .. tostring(v))
		end
	end
end
function table.flip(t)
	local tt={}
	for i,v in pairs(t) do
		tt[v]=i
	end
	return tt
end
function toFraction(n)
	local w,p=math.modf(n)
	if p~=0 then
		p=tonumber(tostring(p):sub(3))
	end
	return w,p
end
function io.cleanName(name)
	name=name:gsub("\\","")
	name=name:gsub("/","")
	name=name:gsub(":","")
	name=name:gsub("*","")
	name=name:gsub("%?","")
	name=name:gsub("\"","''")
	name=name:gsub("<","")
	name=name:gsub(">","")
	name=name:gsub("|","")
	return name
end
function math.numfix(n,x)
	local str=tostring(n)
	if #str<x then
		str=('0'):rep(x-#str)..str
	end
	return str
end
function bin.stripFileName(path)
	path=path:gsub("\\","/")
	local npath=path:reverse()
	a=npath:find("/",1,true)
	npath=npath:sub(a)
	npath=npath:reverse()
	return npath
end
function bin._trim(str)
	return str:match'^()%s*$' and '' or str:match'^%s*(.*%S)'
end
function io.dirExists(strFolderName)
	strFolderName = strFolderName or io.getDir()
	local fileHandle, strError = io.open(strFolderName..'\\*.*','r')
	if fileHandle ~= nil then
		io.close(fileHandle)
		return true
	else
		if string.match(strError,'No such file or directory') then
			return false
		else
			return true
		end
	end
end
function bin.fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end
function bin.randomName(n,ext)
	n=n or math.random(7,15)
	if ext then
		a,b=ext:find('.',1,true)
		if a and b then
			ext=ext:sub(2)
		end
	end
	local str,h = '',0
	strings = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','1','2','3','4','5','6','7','8','9','0','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'}
	for i=1,n do
		h = math.random(1,#strings)
		str = str..''..strings[h]
	end
	return str..'.'..(ext or 'tmp')
end
function bin.trimNul(str)
	return str:match("(.-)[%z]*$")
end
function io.mkDir(dirname)
	os.execute('mkdir "' .. dirname..'"')
end
function string.lines(str)
	local t = {}
	local function helper(line) table.insert(t, line) return '' end
	helper((str:gsub('(.-)\r?\n', helper)))
	return t
end
function log(data,name,fmt)
	if name then
		name=io.cleanName(name)
	end
	if not bin.logger then
		bin.logger = bin.stream(name or 'lua.log',false)
	elseif bin.logger and name then
		bin.logger:close()
		bin.logger = bin.stream(name or 'lua.log',false)
	end
	local d=os.date('*t',os.time())
	bin.logger:tackE((fmt or '['..math.numfix(d.month,2)..'-'..math.numfix(d.day,2)..'-'..d.year..'|'..math.numfix(d.hour,2)..':'..math.numfix(d.min,2)..':'..math.numfix(d.sec,2)..']\t')..data..'\r\n')
end
function table.max(t)
    if #t == 0 then return end
    local value = t[1]
    for i = 2, #t do
        if (value < t[i]) then
            value = t[i]
        end
    end
    return value
end

local bit
if jit then
	bit=require("bit")
elseif bit32 then
	bit=bit32
else
	bit=require("bin.numbers.no_jit_bit")
end
bin.lzw=require("bin.compressors.lzw") -- A WIP
local bits={}
bin.bits = bits
bits.data=''
bits.t='bits'
bits.Type='bits'
bits.__index = bits
bits.__tostring=function(self) return self.data end
bits.__len=function(self) return (#self.data)/8 end
local floor,insert = math.floor, table.insert
function bits.newBitBuffer(n)
	--
end
function bits.newConverter(bitsIn,bitsOut)
	local c={}
	--
end
function basen(n,b)
    if not b or b == 10 then return tostring(n) end
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    local sign = ""
    if n < 0 then
        sign = "-"
    n = -n
    end
    repeat
        local d = n % b + 1
        n = n / b
        insert(t, 1, digits:sub(d,d))
    until n == 0
    return sign .. table.concat(t,"")
end
bits.ref={}
function bits.newByte(d)
	local c={}
	if type(d)=="string" then
		if #d>1 or #d<1 then
			error("A byte must be one character!")
		else
			c.data=string.byte(d)
		end
	elseif type(d)=="number" then
		if d>255 or d<0 then
			error("A byte must be between 0 and 255!")
		else
			c.data=d
		end
	else
		error("cannot use type "..type(d).." as an argument! Takes only strings or numbers!")
	end
	c.__index=function(self,k)
		if k>=0 and k<9 then
			if self.data==0 then
				return 0
			elseif self.data==255 then
				return 1
			else
				return bits.ref[self.data][k]
			end
		end
	end
	c.__tostring=function(self)
		return bits.ref[tostring(self.data)]
	end
	setmetatable(c,c)
	return c
end
function bits.newByteArray(s)
	local c={}
	if type(s)~="string" then
		error("Must be a string type or bin/buffer type")
	elseif type(s)=="table" then
		if s.t=="sink" or s.t=="buffer" or s.t=="bin" then
			local data=s:getData()
			for i=1,#data do
				c[#c+1]=bits.newByte(data:sub(i,i))
			end
		else
			error("Must be a string type or bin/buffer type")
		end
	else
		for i=1,#s do
			c[#c+1]=bits.newByte(s:sub(i,i))
		end
	end
	return c
end
function bits.new(n,binary)
	local temp={}
	temp.t="bits"
	temp.Type="bits"
	if type(n)=="string" then
		if binary then
			temp.data=n:match("[10]+")
		else
			local t={}
			for i=#n,1,-1 do
				table.insert(t,bits:conv(string.byte(n,i)))
			end
			temp.data=table.concat(t)
		end
	elseif type(n)=="number" or type(n)=="table" then
		temp.data=basen(n,2)
	end
	if #temp.data%8~=0 then
		temp.data=string.rep('0',8-#temp.data%8)..temp.data
	end
	setmetatable(temp, bits)
	return temp
end
for i=0,255 do
	local d=bits.new(i).data
	bits.ref[i]={d:match("(%d)(%d)(%d)(%d)(%d)(%d)(%d)(%d)")}
	bits.ref[tostring(i)]=d
	bits.ref[d]=i
	bits.ref["\255"..string.char(i)]=d
end
function bits.numToBytes(n,fit,func)
	local num=string.reverse(bits.new(n):toSbytes())
	local ref={["num"]=num,["fit"]=fit}
	if fit then
		if fit<#num then
			if func then
				print("Warning: attempting to store a number that takes up more space than allotted! Using provided method!")
				func(ref)
			else
				print("Warning: attempting to store a number that takes up more space than allotted!")
			end
			return ref.num:sub(1,ref.fit)
		elseif fit==#num then
			return string.reverse(num)
		else
			return string.reverse(string.rep("\0",fit-#num)..num)
		end
	else
		return string.reverse(num)
	end
end
function bits:conv(n)
	local tab={}
	while n>=1 do
		table.insert(tab,n%2)
		n=math.floor(n/2)
	end
	local str=string.reverse(table.concat(tab))
	if #str%8~=0 or #str==0 then
		str=string.rep('0',8-#str%8)..str
	end
	return str
end
function bits:tonumber(s,e)
	if s==0 then
		return tonumber(self.data,2)
	end
	s=s or 1
	return tonumber(string.sub(self.data,(8*(s-1))+1,8*s),2) or error('Bounds!')
end
function bits:isover()
	return #self.data>8
end
function bits:flipbits()
	tab={}
	for i=1,#self.data do
		if string.sub(self.data,i,i)=='1' then
			table.insert(tab,'0')
		else
			table.insert(tab,'1')
		end
	end
	self.data=table.concat(tab)
end
function bits:tobytes()
	local tab={}
	for i=self:getbytes(),1,-1 do
		table.insert(tab,string.char(self:tonumber(i)))
	end
	return bin.new(table.concat(tab))
end
function bits:toSbytes()
	local tab={}
	for i=self:getbytes(),1,-1 do
		table.insert(tab,string.char(self:tonumber(i)))
	end
	return table.concat(tab)
end
function bits:getBin()
	return self.data
end
function bits:getbytes()
	return #self.data/8
end
local binNum=require("bin.numbers.BigNum")
local infinabits={}
bin.infinabits = infinabits
infinabits.data=''
infinabits.t='infinabits'
infinabits.Type='infinabits'
infinabits.__index = infinabits
infinabits.__tostring=function(self) return self.data end
infinabits.__len=function(self) return (#self.data)/8 end
local floor,insert = math.floor, table.insert
function basen(n,b)
    n=BigNum.new(n)
    if not b or b == 10 then return tostring(n) end
    local digits = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local t = {}
    local sign = ""
    if n < BigNum.new(0) then
        sign = "-"
    n = -n
    end
    repeat
        local d = tonumber(tostring(n % b)) + 1
        n = n / b
        insert(t, 1, digits:sub(d,d))
    until n == BigNum.new(0)
    return sign .. table.concat(t,"")
end
function base2to10(num)
	local n=BigNum.new(0)
	for i = #num-1,0,-1 do
		nn=BigNum.new(num:sub(i+1,i+1))*(BigNum.new(2)^((#num-i)-1))
		n=n+nn
	end
	return n
end
function infinabits.newBitBuffer(n)
	-- WIP
end
function infinabits.newConverter(bitsIn,bitsOut)
	local c={}
	-- WIP
end
infinabits.ref={}
function infinabits.newByte(d)-- WIP
	local c={}
	if type(d)=="string" then
		if #d>1 or #d<1 then
			error("A byte must be one character!")
		else
			c.data=string.byte(d)
		end
	elseif type(d)=="number" then
		if d>255 or d<0 then
			error("A byte must be between 0 and 255!")
		else
			c.data=d
		end
	else
		error("cannot use type "..type(d).." as an argument! Takes only strings or numbers!")
	end
	c.__index=function(self,k)
		if k>=0 and k<9 then
			if self.data==0 then
				return 0
			elseif self.data==255 then
				return 1
			else
				return infinabits.ref[self.data][k]
			end
		end
	end
	c.__tostring=function(self)
		return infinabits.ref[tostring(self.data)]
	end
	setmetatable(c,c)
	return c
end
function infinabits.newByteArray(s)-- WIP
	local c={}
	if type(s)~="string" then
		error("Must be a string type or bin/buffer type")
	elseif type(s)=="table" then
		if s.t=="sink" or s.t=="buffer" or s.t=="bin" then
			local data=s:getData()
			for i=1,#data do
				c[#c+1]=infinabits.newByte(data:sub(i,i))
			end
		else
			error("Must be a string type or bin/buffer type")
		end
	else
		for i=1,#s do
			c[#c+1]=infinabits.newByte(s:sub(i,i))
		end
	end
	return c
end
function infinabits.new(n,binary)
	local temp={}
	temp.t="infinabits"
	temp.Type="infinabits"
	if type(n)=="string" then
		if binary then
			temp.data=n:match("[10]+")
		else
			local t={}
			for i=#n,1,-1 do
				table.insert(t,infinabits:conv(string.byte(n,i)))
			end
			temp.data=table.concat(t)
		end
	elseif type(n)=="number" or type(n)=="table" then
		temp.data=basen(tostring(n),2)
	end
	if #temp.data%8~=0 then
		temp.data=string.rep('0',8-#temp.data%8)..temp.data
	end
	setmetatable(temp, infinabits)
	return temp
end
for i=0,255 do
	local d=infinabits.new(i).data
	infinabits.ref[i]={d:match("(%d)(%d)(%d)(%d)(%d)(%d)(%d)(%d)")}
	infinabits.ref[tostring(i)]=d
	infinabits.ref[d]=i
	infinabits.ref["\255"..string.char(i)]=d
end
function infinabits.numToBytes(n,fit,func)
	local num=string.reverse(infinabits.new(BigNum.new(n)):toSbytes())
	local ref={["num"]=num,["fit"]=fit}
	if fit then
		if fit<#num then
			if func then
				print("Warning: attempting to store a number that takes up more space than allotted! Using provided method!")
				func(ref)
			else
				print("Warning: attempting to store a number that takes up more space than allotted!")
			end
			return ref.num:sub(1,ref.fit)
		elseif fit==#num then
			return string.reverse(num)
		else
			return string.reverse(string.rep("\0",fit-#num)..num)
		end
	else
		return string.reverse(num)
	end
end
function infinabits.numToBytes(n,fit,fmt,func)
	if fmt=="%e" then
		local num=string.reverse(infinabits.new(BigNum.new(n)):toSbytes())
		local ref={["num"]=num,["fit"]=fit}
		if fit then
			if fit<#num then
				if func then
					print("Warning: attempting to store a number that takes up more space than allotted! Using provided method!")
					func(ref)
				else
					print("Warning: attempting to store a number that takes up more space than allotted!")
				end
				return ref.num:sub(1,ref.fit)
			elseif fit==#num then
				return num
			else
				return string.rep("\0",fit-#num)..num
			end
		else
			return num
		end

	else
		local num=string.reverse(infinabits.new(BigNum.new(n)):toSbytes())
		local ref={["num"]=num,["fit"]=fit}
		if fit then
			if fit<#num then
				if func then
					print("Warning: attempting to store a number that takes up more space than allotted! Using provided method!")
					func(ref)
				else
					print("Warning: attempting to store a number that takes up more space than allotted!")
				end
				return ref.num:sub(1,ref.fit)
			elseif fit==#num then
				return string.reverse(num)
			else
				return string.reverse(string.rep("\0",fit-#num)..num)
			end
		else
			return string.reverse(num)
		end
	end
end
function infinabits:conv(n)
	local tab={}
	local one=BigNum.new(1)
	local n=BigNum.new(n)
	while n>=one do
		table.insert(tab,tonumber(tostring(n%2)))
		n=n/2
	end
	local str=string.reverse(table.concat(tab))
	if #str%8~=0 or #str==0 then
		str=string.rep('0',8-#str%8)..str
	end
	return str
end
function infinabits:tonumber(s)
	if s==0 then
		return tonumber(self.data,2)
	end
	s=s or 1
	return tonumber(tostring(base2to10(string.sub(self.data,(8*(s-1))+1,8*s)))) or error('Bounds!')
end
function infinabits:isover()
	return #self.data>8
end
function infinabits:flipbits()
	tab={}
	local s=self.data
	s=s:gsub("1","_")
	s=s:gsub("0","1")
	s=s:gsub("_","0")
	self.data=s
end
function infinabits:tobytes()
	local tab={}
	for i=self:getbytes(),1,-1 do
		table.insert(tab,string.char(self:tonumber(i)))
	end
	return bin.new(table.concat(tab))
end
function infinabits:toSbytes()
	local tab={}
	for i=self:getbytes(),1,-1 do
		table.insert(tab,string.char(self:tonumber(i)))
	end
	return table.concat(tab)
end
function infinabits:getBin()
	return self.data
end
function infinabits:getbytes()
	return #self.data/8
end
local randomGen=require("bin.numbers.random")
function bin.setBitsInterface(int)
	bin.defualtBit=int or infinabits
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
		else -- maybe a type from another library
			return tab
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
	local str=bin.normalizeData(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end
function bin.fromHex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
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
function bin.newStreamFileObject(file)
	local c=bin.new()
	c.Type="streamable"
	c.t="streamable"
	c.file="FILE_OBJECT"
	c.lock = false
	c.workingfile=file
	c.stream=true
	return c
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
function bin:slide(n)
	local s=self:getSize()
	local buf=bin.newDataBuffer(s)
	buf:fillBuffer(1,self:getData())
	for i=1,s do
		nn=buf[i]+n
		if nn>255 then
			nn=nn%256
		elseif nn<0 then
			nn=256-math.abs(nn)
		end
		buf[i]=nn
	end
	self:setSeek(1)
	self:write(buf:getData())
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
	if bin.registerBlocks[fmt] then
		self:tackE(bin.registerBlocks[fmt][2](d,fit,fmt,self,bin.registerBlocks[fmt][2]))
	elseif type(d)=="number" then
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
	for i=1,c.size do
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
function bin:toDataBuffer()
	local s=self:getSize()
	-- if self:canStreamWrite() then
		-- return self:newDataBufferFromStream(0,s)
	-- end
	local buf=bin.newDataBuffer(s)
	local data=self:read(512)
	local i=1
	while data~=nil do
		buf[i]=data
		data=self:read(512)
		i=i+512
	end
	return buf
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
-- Use with small files!
function bin:gsub(...)
	local data=self:getData()
	local pos=self:getSeek()
	self:setSeek(1)
	self:write((data:gsub(...)) or data)
	self:setSeek(loc)
end
function bin:gmatch(pat)
	return self:getData():gmatch(pat)
end
function bin:match(pat)
	return self:getData():match(pat)
end
function bin:trim()
	local data=self:getData()
	local pos=self:getSeek()
	self:setSeek(1)
	self:write(data:match'^()%s*$' and '' or data:match'^%s*(.*%S)')
	self:setSeek(loc)
end
function bin:lines()
	local t = {}
	local function helper(line) table.insert(t, line) return '' end
	helper((self:getData():gsub('(.-)\r?\n', helper)))
	return t
end
function bin._lines(str)
	local t = {}
	local function helper(line) table.insert(t, line) return '' end
	helper((str:gsub('(.-)\r?\n', helper)))
	return t
end
function bin:wipe()
	if self:canStreamWrite() then
		self:close()
		local c=bin.freshStream(self.file)
		self.workingfile=c.workingfile
	else
		self.data=""
	end
	self:setSeek(1)
end
function bin:fullTrim(empty)
	local t=self:lines()
	for i=#t,1,-1 do
		t[i]=bin._trim(t[i])
		if empty then
			if t[i]=="" then
				table.remove(t,i)
			end
		end
	end
	self:wipe()
	self:write(table.concat(t,"\n"))
end
local __CURRENTVERSION=2
bin.registerBlock("t",function(SIZE_OR_NIL,ref)
	local header=ref:read(3)
	if not header:match("(LT.)") then error("Not a valid table struct!") end
	if bin.defualtBit.new(header:sub(3,3)):tonumber(1)>__CURRENTVERSION then error("Incompatible Version of LuaTable!") end
	local len=ref:getBlock("n",4) -- hehe lets make life easier
	local tab={}
	local ind
	local n=0
	while true do
		local _dat=ref:read(2)
		if _dat==nil then break end
		local it,dt=_dat:match("(.)(.)")
		n=n+2
		if it=="N" then -- get the index stuff out of the way first
			ind=ref:getBlock("n",4)
			n=n+4
		else
			indL=ref:getBlock("n",1)
			n=n+1+indL
			ind=ref:read(indL)
		end
		if dt=="N" then
			tab[ind]=ref:getBlock("d")
			n=n+8
		elseif dt=="I" then
			tab[ind]=math.huge
			ref:getBlock("n",4)
			n=n+4
		elseif dt=="i" then
			tab[ind]=-math.huge
			ref:getBlock("n",4)
			n=n+4
		elseif dt=="S" then
			local nn=ref:getBlock("n",4)
			tab[ind]=ref:read(nn)
			n=n+4+nn
		elseif dt=="B" then
			tab[ind]=({["\255"]=true,["\0"]=false})[ref:read(1)]
			n=n+1
		elseif dt=="F" then
			local nn=ref:getBlock("n",4)
			tab[ind]=loadstring(ref:read(nn))
			n=n+4+nn
		elseif dt=="T" then
			local cur=ref:getSeek()
			local size=ref:getBlock("n",4)
			ref:setSeek(cur)
			ref:read(4)
			if size==7 then
				tab[ind]={}
				ref:read(7)
				n=n+11
			else
				local data=bin.new(ref:read(size))
				local dat=data:getBlock("t")
				if dat.__RECURSIVE then
					tab[ind]=tab
				else
					tab[ind]=dat
				end
				n=n+data:getSize()+4
			end
		end
		if n==len then break end
	end
	return bin.resolveType(tab)
end,function(d,fit,fmt,self,rec,tabsaw)
	-- INGORE FIT WE ARE CREATING A STRUCT!!!
	-- fmt will apply to all numbers
	local __rem=nil
	if not tabsaw then rem=true end
	local tabsaw=tabsaw or {}
	if rem then
		table.insert(tabsaw,d)
	end
	local bData={}
	for i,v in pairs(d) do -- this is for tables, all but userdata is fine. Depending on where you are using lua functions may or may not work
		local tp=type(v):sub(1,1):upper() -- uppercase of datatype
		if type(i)=="number" then -- Lets handle indexies
			if v==math.huge then
				tp="I"
				v=0
			elseif v==-math.huge then
				tp="i"
				v=0
			end
			table.insert(bData,"N"..tp..bin.defualtBit.numToBytes(i,4)) -- number index?
		elseif type(i)=="string" then
			if #i>255 then error("A string index cannot be larger than 255 bytes!") end
			table.insert(bData,"S"..tp..bin.defualtBit.numToBytes(#i,1)..i) -- string index?
		else
			error("Only numbers and strings can be a table index!") -- throw error?
		end
		if type(v)=="number" then
			-- How do we handle number data
			local temp=bin.new()
			temp:addBlock(v,nil,"d")
			table.insert(bData,temp.data)
		elseif type(v)=="string" then
			-- Lets work on strings
			table.insert(bData,bin.defualtBit.numToBytes(#v,4)) -- add length of string
			table.insert(bData,v) -- add string
		elseif type(v)=="boolean" then -- bools are easy :D
			table.insert(bData,({[true]="\255",[false]="\0"})[v])
		elseif type(v)=="function" then -- should we allow this? why not...
			local dump=string.dump(v)
			table.insert(bData,bin.defualtBit.numToBytes(#dump,4)) -- add length of dumped string
			table.insert(bData,dump) -- add it
		elseif type(v)=="table" then -- tables...
			if tabsaw[1]==v then
				v={__RECURSIVE=i}
			else
				tabsaw[i]=v
			end
			local data=rec(v,nil,"t",self,rec,tabsaw)
			table.insert(bData,bin.defualtBit.numToBytes(#data,4)) -- add length of string
			table.insert(bData,data) -- add string
		end
	end
	local data=table.concat(bData)
	return "LT"..string.char(__CURRENTVERSION)..bin.defualtBit.numToBytes(#data,4)..data
end)
bin.registerBlock("b",function(SIZE_OR_NIL,ref)
	return ({["\255"]=true,["\0"]=false})[ref:read(1)]
end,function(d)
	return ({[true]="\255",[false]="\0"})[d]
end)
bin.registerBlock("f",function(SIZE_OR_NIL,ref)
	local nn=ref:getBlock("n",4)
	return loadstring(ref:read(nn))
end,function(d)
	local dump=string.dump(d)
	return bin.defualtBit.numToBytes(#dump,4)..dump
end)
bin.registerBlock("d",function(SIZE_OR_NIL,ref)
	local w,p=ref:getBlock("n",4),ref:getBlock("n",4)
	p=tonumber("0."..tostring(p))
	return w+p
end,function(d,fit,fmt,self,rec,tabsaw)
	local w,p = toFraction(d)
	local temp=bin.new()
	temp:addBlock(w,4)
	temp:addBlock(p,4)
	return temp.data
end)
if love then
	function bin.load(file,s,r)
		content, size = love.filesystem.read(file)
		local temp=bin.new(content)
		temp.filepath=file
		return temp
	end
	function bin.fileExists(name)
		return love.filesystem.getInfo(name)
	end
	function bin:tofile(filename)
		if not(filename) or self.Stream then return nil end
		love.filesystem.write(filename,self.data)
	end
	function bin.loadS(path,s,r)
		local path = love.filesystem.getSaveDirectory( ).."\\"..path
		if type(path) ~= "string" then error("Path must be a string!") end
		local f = io.open(path, 'rb')
		local content = f:read('*a')
		f:close()
		return bin.new(content)
	end
	function bin:tofileS(filename)
		if self.stream then return end
		local filename = love.filesystem.getSaveDirectory( ).."\\"..filename
		print(#self.data,filename)
		if not filename then error("Must include a filename to save as!") end
		file = io.open(filename, "wb")
		file:write(self.data)
		file:close()
	end
	function bin.stream(file)
		return bin.newStreamFileObject(love.filesystem.newFile(file))
	end
	function bin:getSize(fmt)
		local len=0
		if self.stream then
			local len=self.workingfile:getSize()
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
	function bin:getSeek()
		if self.stream then
			return self.workingfile:tell()+1
		else
			return self.pos
		end
	end
	function bin:setSeek(n)
		if self.stream then
			self.workingfile:seek(n-1)
		else
			self.pos=n
		end
	end
	function bin:seek(n)
		if self.stream then
			self.workingfile:seek(n)
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
	function bin:close()
		self.workingfile:close()
	end
end
return bin