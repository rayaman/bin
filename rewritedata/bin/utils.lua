function table.flip(t)
	local tt={}
	for i,v in pairs(t) do
		tt[v]=i
	end
	return tt
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
function io.mkFile(filename,data,tp)
	if not(tp) then tp='wb' end
	if not(data) then data='' end
	file = io.open(filename, tp)
	if file==nil then return end
	file:write(data)
	file:close()
end
function io.getWorkingDir()
	return io.popen'cd':read'*l'
end
function io.getAllItems(dir)
	local t=os.capture("cd \""..dir.."\" & dir /a-d | find",true):lines()
	return t
end
function os._getOS()
	if package.config:sub(1,1)=='\\' then
		return 'windows'
	else
		return 'unix'
	end
end
function os.getOS(t)
	if not t then
		return os._getOS()
	end
	if os._getOS()=='unix' then
		fh,err = io.popen('uname -o 2>/dev/null','r')
		if fh then
			osname = fh:read()
		end
		if osname then return osname end
	end
	local winver='Unknown Version'
	local a,b,c=os.capture('ver'):match('(%d+).(%d+).(%d+)')
	local win=a..'.'..b..'.'..c
	if type(t)=='string' then
		win=t
	end
	if win=='4.00.950' then
		winver='95'
	elseif win=='4.00.1111' then
		winver='95 OSR2'
	elseif win=='4.00.1381' then
		winver='NT 4.0'
	elseif win=='4.10.1998' then
		winver='98'
	elseif win=='4.10.2222' then
		winver='98 SE'
	elseif win=='4.90.3000' then
		winver='ME'
	elseif win=='5.00.2195' then
		winver='2000'
	elseif win=='5.1.2600' then
		winver='XP'
	elseif win=='5.2.3790' then
		winver='Server 2003'
	elseif win=='6.0.6000' then
		winver='Vista/Windows Server 2008'
	elseif win=='6.0.6002' then
		winver='Vista SP2'
	elseif win=='6.1.7600' then
		winver='7/Windows Server 2008 R2'
	elseif win=='6.1.7601' then
		winver='7 SP1/Windows Server 2008 R2 SP1'
	elseif win=='6.2.9200' then
		winver='8/Windows Server 2012'
	elseif win=='6.3.9600' then
		winver='8.1/Windows Server 2012'
	elseif win=='6.4.9841' then
		winver='10 Technical Preview 1'
	elseif win=='6.4.9860' then
		winver='10 Technical Preview 2'
	elseif win=='6.4.9879' then
		winver='10 Technical Preview 3'
	elseif win=='10.0.9926' then
		winver='10 Technical Preview 4'
	end
	return 'Windows '..winver
end
function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end
function io.scanDir(directory)
	directory=directory or io.getDir()
    local i, t, popen = 0, {}, io.popen
	if os.getOS()=='unix' then
		for filename in popen('ls -a "'..directory..'"'):lines() do
			i = i + 1
			t[i] = filename
		end
	else
		for filename in popen('dir "'..directory..'" /b'):lines() do
			i = i + 1
			t[i] = filename
		end
	end
    return t
end
function io.getDir(dir)
	if not dir then return io.getWorkingDir() end
	if os.getOS()=='unix' then
		return os.capture('cd '..dir..' ; cd')
	else
		return os.capture('cd '..dir..' & cd')
	end
end
function string.split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = '(.-)' .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= '' then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end
function io.fileExists(path)
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
function io.getDirectories(dir,l)
	if dir then
		dir=dir..'\\'
	else
		dir=''
	end
	local temp2=io.scanDir(dir)
	for i=#temp2,1,-1 do
		if io.fileExists(dir..temp2[i]) then
			table.remove(temp2,i)
		elseif l then
			temp2[i]=dir..temp2[i]
		end
	end
	return temp2
end
function io.getFiles(dir,l)
	if dir then
		dir=dir..'\\'
	else
		dir=''
	end
	local temp2=io.scanDir(dir)
	for i=#temp2,1,-1 do
		if io.dirExists(dir..temp2[i]) then
			table.remove(temp2,i)
		elseif l then
			temp2[i]=dir..temp2[i]
		end
	end
	return temp2
end
function io.readFile(file)
    local f = io.open(file, 'rb')
    local content = f:read('*all')
    f:close()
    return content
end
function table.print(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep('  ', indent) .. k .. ': '
		if type(v) == 'table' then
			print(formatting)
			table.print(v, indent+1)
		else
			print(formatting .. tostring(v))
		end
	end
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
function io.getFullName(name)
	local temp=name or arg[0]
	if string.find(temp,'\\',1,true) or string.find(temp,'/',1,true) then
		temp=string.reverse(temp)
		a,b=string.find(temp,'\\',1,true)
		if not(a) or not(b) then
			a,b=string.find(temp,'/',1,true)
		end
		return string.reverse(string.sub(temp,1,b-1))
	end
	return temp
end
function io.getName(file)
	local name=io.getFullName(file)
	name=string.reverse(name)
	a,b=string.find(name,'.',1,true)
	name=string.sub(name,a+1,-1)
	return string.reverse(name)
end
function io.getPathName(path)
	return path:sub(1,#path-#io.getFullName(path))
end
function table.merge(t1, t2)
    for k,v in pairs(t2) do
    	if type(v) == 'table' then
    		if type(t1[k] or false) == 'table' then
    			table.merge(t1[k] or {}, t2[k] or {})
    		else
    			t1[k] = v
    		end
    	else
    		t1[k] = v
    	end
    end
    return t1
end
function io.splitPath(str)
   return string.split(str,'[\\/]+')
end
function io.pathToTable(path)
	local p=io.splitPath(path)
	local temp={}
	temp[p[1]]={}
	local last=temp[p[1]]
	for i=2,#p do
		snd=last
		last[p[i]]={}
		last=last[p[i]]
	end
	return temp,last,snd
end
function io.parseDir(dir,t)
	io.tempFiles={}
	function _p(dir)
		local dirs=io.getDirectories(dir,true)
		local files=io.getFiles(dir,true)
		for i=1,#files do
			p,l,s=io.pathToTable(files[i])
			if t then
				s[io.getFullName(files[i])]=io.readFile(files[i])
			else
				s[io.getFullName(files[i])]=io.open(files[i],'r+')
			end
			table.merge(io.tempFiles,p)
		end
		for i=1,#dirs do
			table.merge(io.tempFiles,io.pathToTable(dirs[i]))
			_p(dirs[i],t)
		end
	end
	_p(dir)
	return io.tempFiles
end
function io.parsedir(dir,f)
	io.tempFiles={}
	function _p(dir,f)
		local dirs=io.getDirectories(dir,true)
		local files=io.getFiles(dir,true)
		for i=1,#files do
			if not f then
				table.insert(io.tempFiles,files[i])
			else
				f(files[i])
			end
		end
		for i=1,#dirs do
			_p(dirs[i],f)
		end
	end
	_p(dir,f)
	return io.tempFiles
end
