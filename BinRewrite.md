# Bin Rewrite Progress!
My vision for the bin library is to provide great and consistant support for binary minipulation... The old version was not consistant with how I wanted things to work. Great things to come!
**Note: A lot breaks**
Progress: [==========90%======== -] All that is left is the virtual file system stuff! Everything else is all good!
A lot of useless and unneeded functions have been removed while adding some more useful ones!
### List of new methods
- [x] bin.newFromBase64(data) -- returns a bin object from base64 data
- [x] bin.newFromBase91(data) -- returns a bin object from base91 data
- [x] bin.newFromHex(data) -- returns a bin object from hex data
- [x] bin:read(n) -- works just like normal read on a file for both stream/bin files
- [x] bin:sub(a,b) -- works like string.sub() but for bin objects
- [x] bin:seekSet(n) -- sets the seek position on the file
- [x] bin.toBase64(s) -- returns a base64 encoded string from the input string
- [x] bin.fromBase64(s) -- converts the base64 data back into its original string
- [x] bin.toBase91(s) -- returns a base91 encoded string from the input string
- [x] bin.fromBase91(s) -- converts the base91 data back into its original string
- [x] bin.getnumber(num,len,fmt,func) -- turns num into a binary string, len is what to fit it into, 4 bytes, 5+ bytes. fmt is either %e for little endian or %E for big endian defualts to %E 
- [x] New infinabits! Works like bits, but supports numbers up to infinity
- [x] bin.registerBlock(t,funcG,funcA) -- allows you to add custom block commands, I implemented the table block command using this feature, look at extrablocks.lua in the bin folder
- [x] binobj:getMD5Hash() -- returns the md5 hash of the bin file
- [x] bin.getBitsInNum(x) -- returns the number of bits needed to store a number

### List of converted methods and their status
- [x] log(data,name,fmt)
~~bin.getLuaVersion()~~
- [x] bin.load(filename,s,r) -- loads a file into memory as a virtual file
- [x] bin.new(data) -- Does not accept b64 or hex data anymore! Use new methods for that ^^^ -- creats a new virtual file
- [x] bin.stream(file,lock) -- opens a file in updating mode. Works just like a binobj
- [x] bin.newTempFile(data) -- creates a streamed file usine lua's io.tmpfile() so its removed when the program is done
- [x] bin:getSize(fmt) -- gets the size of the string fmt is how you want to format it. left empte returns number of bites as a lua number supports lua formats! And also I added the %b format for base64
- [x] binobj:getData(a,b,fmt) -- returns the data of the object as a string, supports %x(hex), %X(HEX) and %b(base64)
- [x] bits.new(n) -- creats a bits objects. This library is all about numbers and manipulation at the bit level
- [ ] bin.newVFS() -- soon
- [x] bin:tackE(data) -- tacks data onto the end of a file
- [x] binobj:tofile(path) -- binobj to a file on the disk. Does not work with stream files! Might allow it to rename stream files at a future point
- [ ] bin.loadVFS(path) -- soon
- [x] bin:newDataBuffer(size,fill) -- creates a buffer object. Buffers allow fast and easy byte manipulation
~~bin.bufferToBin(b)~~
~~bin.binToBuffer(b)~~
~~bin:getDataBuffer(a,b)~~
~~bin.newNamedBlock(indexSize)~~
~~bin.newStreamedNamedBlock(indexSize,path)~~
~~bin.loadNamedBlock(path)~~
~~bin.namedBlockManager(arg)~~
- [x] bin.randomName(n,ext) -- returns a random filesystem safe string, can add an extension to be created with it as well
~~bin.NumtoHEX(n)~~
~~bin.HEXtoBin(s)~~
~~bin.HEXtoStr(s)~~
- [x] bin.tohex(s) -- converts a string into hex
- [x] bin.fromhex(s) -- takes hex data and turns it into a string
- [x] bin.endianflop(data) -- swaps between big/little endian
- [x] bin.getVersion() -- returns the libraries version as a string
~~bin.escapeStr(str)~~
~~bin.ToStr(tab)~~
~~bin.packLLIB(name,tab,ext)~~
~~bin.unpackLLIB(name,exe,todir,over,ext)~~
~~bin.fileExist(path)~~ NOW io.fileExists(path)
~~bin.closeto(a,b,v)~~
~~bin.textToBinary(txt)~~
~~bin.decodeBits(bindata)~~
- [x] bin.trimNul(s) -- removes the nul character from the end of a string
~~bin.getIndexSize(tab)~~
- [x] bits.numToBytes(n,fit,func) -- converts a number into a string, helper function for bin.getnumber(num,len,fmt,func), allows for more control
~~binobj:clone()~~
~~binobj:compare(other binobj,diff)~~
- [x] binobj:sub(a,b) -- works like string.sub, but for binobjs
- [x] binobj:tonumber(a,b)
~~binobj:getbyte(n)~~
~~binobj:tobits(i)~~
~~binobj:getHEX(a,b)~~
~~binobj:scan(s,n,f)~~
~~binobj:streamData(a,b)~~
~~binobj:streamread(a,b)~~
- [x] binobj:canStreamWrite() -- returns true if a a binobj can be streamed written to
- [x] bitobj:conv(n)
- [x] bitobj:tobytes()
- [x] bitobj:tonumber()
- [x] bitobj:isover()
- [x] binobj:getHash(n) -- returns a fast, but insecure hash
~~blockReader:getBlock(name)~~
~~binobj:setEndOfFile(n)~~
~~binobj:reverse()~~
- [x] binobj:flipbits() -- filps the bits in the binobj
~~binobj:segment(a,b)~~
~~binobj:insert(a,i)~~
~~binobj:parseN(n)~~
~~binobj:getlength()~~ -- now is getSize()
~~binobj:shift(n)~~
~~binobj:delete(a,b)~~
- [x] binobj:encrypt(seed) -- encrypts a file
- [x] binobj:decrypt(seed) -- decrypts a file
~~binobj:shuffle()~~
~~binobj:mutate(a,i)~~
~~binobj:merge(o)~~ -- binobj:tackE(data) does this so there is no need for merge
~~binobj:parseA(n,a,t)~~
~~binobj:getHEX(a,b)~~
~~binobj:cryptM()~~
- [x] binobj:addBlock(d,fit,fmt) -- adds a block to the bin obj
- [x] binobj:getBlock(t,n) -- gets the block from a binobj
- [x] binobj:setSeek(n) -- **starts at 1 not 0**
~~binobj:morph(a,b,d)~~
~~binobj:fill(n,d)~~
~~binobj:fillrandom(n)~~
~~binobj:shiftbits(n)~~
~~binobj:shiftbit(n,i)~~
~~binobj:streamwrite(d,n)~~
~~binobj:open()~~
- [x] binobj:close() -- closes a streamed file
~~binobj:wipe()~~
~~binobj:tackB(d)~~
- [x] binobj:tackE(d,fit,updateseek) -- adds data onto the end of the file
~~binobj:parse(n,f)~~
~~binobj:flipbit(i)~~
~~binobj:gsub()~~
~~blockWriter:addNamedBlock(name,value)~~
~~bitobj:add(i)~~
~~bitobj:sub(i)~~
~~bitobj:multi(i)~~
~~bitobj:div(i)~~
- [x] bitobj:flipbits() -- flips the bits of a bitobj
- [x] bitobj:getBin() -- returns the binobj of the bit data