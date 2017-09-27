# bin

The binary manipulation library make file management a simple task.</br>
Rewrite done for the most part: Checkout BinRewrite.md to view changes
Basic usage:
```lua
require("bin")
print("TEST - 1")
test=bin.new("I am a string in a bin")
print(test)
print("TEST - 2: Writing a test file to disk")
test2=bin.freshStream("newFileToStreamWriteTo.dat",false)
test2:addBlock(1234,4)
test2:addBlock("Hello",5)
test2:addBlock(true) -- always 1 and a lua type
test2:addBlock({1,2,3,4,5}) -- depends and is a lua type
test2:close()
print("test 2 done")
print("TEST - 3: reading the file we wrote to disk")
test3=bin.load("newFileToStreamWriteTo.dat") -- binary file
nL,nB=test3:getBlock("n",4) -- reads the first 4 bytes as a number
-- litte endian, big endian
print(nL,nB)
str=test3:getBlock("s",5)
print(str)
bool=test3:getBlock("b")
print(bool)
tab=test3:getBlock("t")
print(tab)
```
# Output
```
TEST - 1
I am a string in a bin
TEST - 2: Writing a test file to disk
test 2 done
TEST - 3: reading the file we wrote to disk
1234	3523477504
Hello
true
table: 0x001e3f40
```
#Updates/Changes
Version 5.0.1
-------------
Cleaned up files within the bin folder
Added:
+ bin:toDataBuffer()
[Converts a binobj to a data buffer]
+ bin:slide(n)
[changes the value of the characters by n, if n>255 it will wrap back around to 0]

Note: While streamable files can handle massive files without an issue, converting a massive file to a databuffer will probably throw a memory error!

Example:
```lua
t=bin.new("Hello")
print(t)
t:slide(50)
print(t)
t:slide(-50)
print(t)
--~ t2=bin.stream("test.dat",false) -- make sure you have this file first than test the code
--~ tt=t2:toDataBuffer()
--~ print(tt[1])
```
Notes:
------
# The bin library **had** all of these features, a lot has been stripped use the BinRewrite for info on what stayed!

Note: Examples of everything in action wll be made eventually...</br>
nil					 = log(data,name,fmt)  -- data is the text that you want to log to a file, the name argument only needs to be called with the first log. It tells where to log to. If name is used again it will change the location of the log file.</br>
string,string,string = bin.getLuaVersion() -- returns PUC/JIT,major,minor</br>

Constructors
------------
binobj		=	bin.load(filename,s,r)						-- creates binobj from file in s and r nil then reads entire file but if not s is the start point of reading and r is either the #to read after s or from s to '#' (like string.sub())</br>
binobj		=	bin.new(string data)						-- creates binobj from a string</br>
binobj		=	bin.stream(file,lock)						-- creates a streamable binobj lock is defult to true if locked file is read only</br>
binobj		=	bin.newTempFile(data)						-- creates a tempfile in stream mode</br>
bitobj		=	bits.new(n)									-- creates bitobj from a number</br>
vfs			=	bin.newVFS()								-- creates a new virtual file system 	--Beta</br>
vfs			=	bin.loadVFS(path)							-- loads a saved .lvfs file				--Beta</br>
buf			=	bin:newDataBuffer(s)						-- creates a databuffer</br>
binobj		=	bin.bufferToBin(b)							-- converts a buffer object to a bin object</br>
buf			=	bin.binToBuffer(b)							-- converts a bin object to a buffer obj</br>
buf			=	bin:getDataBuffer(a,b)						-- gets a speical buffer that opperates on a streamed file. It works just like a regular data buffer</br>
blockWriter =	bin.newNamedBlock(indexSize)				-- returns a block writer object index size is the size of the index where labels and pointers are stored</br>
blockWriter =	bin.newStreamedNamedBlock(indexSize,path)	-- returns a streamed version of the above path is the path to write the file</br>
blockReader =	bin.loadNamedBlock(path)					-- returns a block reader object, path is where the file is located</br>
blockHandler=	bin.namedBlockManager(arg)					-- returns a block handler object, if arg is a string it will loade a named block file, if its a number or nil it will create a nambed block object</br>

Note: the blockWriter that isn't streamed needs to have tofile(path) called on it to write it to a file</br>
Note: the streamed blockWriter must have the close method used when you are done writing to it!</br>

Helpers
-------
string	=	bin.randomName(n,ext)					-- creates a random file name if n and ext is nil then a random length is used, and '.tmp' extension is added</br>
string	=	bin.NumtoHEX(n)							-- turns number into hex</br>
binobj	=	bin.HEXtoBin(s)*D						-- turns hex data into binobj</br>
string	=	bin.HEXtoStr(s)*D						-- turns hex data into string/text</br>
string	=	bin.tohex(s)							-- turns string to hex</br>
string	=	bin.fromhex(s)							-- turns hex to string</br>
string	=	bin.endianflop(data)					-- flips the high order bits to the low order bits and viseversa</br>
string	=	bin.getVersion()						-- returns the version as a string</br>
string	=	bin.escapeStr(str)						-- system function that turns functions into easy light</br>
string	=	bin.ToStr(tab)							-- turns a table into a string (even functions are dumped; used to create compact data files)</br>
nil		=	bin.packLLIB(name,tab,ext)				-- turns a bunch of 'files' into 1 file tab is a table of file names, ext is extension if nil .llib is used Note: Currently does not support directories within .llib</br>
nil		=	bin.unpackLLIB(name,exe,todir,over,ext)	-- takes that file and makes the files Note: if exe is true and a .lua file is in the .llib archive than it is ran after extraction ext is extension if nil .llib is used</br>
boolean	=	bin.fileExist(path)						-- returns true if the file exist false otherwise</br>
boolean\*=	bin.closeto(a,b,v)						-- test data to see how close it is (a,b=tested data v=#difference (v must be <=255))</br>
String	=	bin.textToBinary(txt)					-- turns text into binary data 10101010's</br>
binobj	=	bin.decodeBits(bindata)					-- turns binary data into text</br>
string	=	bin.trimNul(s)							-- terminates string at the nul char</br>
number	=	bin.getIndexSize(tab)					-- used to get the index size of labels given to a named block</br>
string	=	bits.numToBytes(num,occ)				-- returns the number in base256 string data, occ is the space the number will take up</br>

Assessors
---------
nil\*\*\*	=	binobj:tofile(filename)					-- writes binobj data as a file</br>
binobj\*	=	binobj:clone()							-- clones and returns a binobj</br>
number\*	=	binobj:compare(other binobj,diff)		-- returns 0-100 % of simularity based on diff factor (diff must be <=255)</br>
string	=	binobj:sub(a,b)							-- returns string data like segment but dosen't alter the binobject</br>
num,num	=	binobj:tonumber(a,b)					-- converts from a-b (if a and b are nil it uses the entire binobj) into a base 10 number so 'AXG' in data becomes 4675649 returns big,little endian</br>
number	=	binobj:getbyte(n)						-- gets byte at location and converts to base 10 number</br>
bitobj	=	binobj:tobits(i)						-- returns the 8bits of data as a bitobj Ex: if value of byte was a 5 it returns a bitobj with a value of: '00000101'</br>
string	=	binobj:getHEX(a,b)						-- gets the HEX data from 'a' to 'b' if both a,b are nil returns entire file as hex</br>
a,b		=	binobj:scan(s,n,f)						-- searches a binobj for 's'; n is where to start looking, 'f' is weather or not to flip the string data entered 's'</br>
string	=	binobj:streamData(a,b)					-- reads data from a to b or a can be a data handle... I will explain this and more in offical documentation</br>
string#	=	binobj:streamread(a,b)					-- reads data from a stream object between a and b (note: while other functions start at 1 for both stream and non stream 0 is the starting point for this one)</br>
boolean	=	binobj:canStreamWrite()					-- returns true if the binobj is streamable and isn't locked</br>
string	=	bitobj:conv(n)							-- converts number to binary bits (system used)</br>
binobj	=	bitobj:tobytes()						-- converts bit obj into a string byte (0-255)</br>
number	=	bitobj:tonumber()						-- converts '10101010' to a number</br>
boolean	=	bitobj:isover()							-- returns true if the bits exceed 8 bits false if 8 or less</br>
string	=	bitobj:getBin()							-- returns the binary 10100100's of the data as a string</br>
string	=	binobj:getHash(n)						-- returns a Hash of a file (This is my own method of hashing btw) n is the length you want the hash to be</br>
string	=	binobj:getData()						-- returns the bin object as a string</br>
depends =	blockReader:getBlock(name)				-- returns the value associated with the name, values can be any lua data except userdata</br>

Mutators (Changes affect the actual object or if streaming the actual file) bin:remove()</br>
--------</br>
nil		=	binobj:setEndOfFile(n)	-- sets the end of a file</br>
nil		=	binobj:reverse() 		-- reverses binobj data ex: hello --> olleh</br>
nil		=	binobj:flipbits() 		-- flips the binary bits</br>
nil\*\* 	=	binobj:segment(a,b)		-- gets a segment of the binobj data works just like string.sub(a,b) without str</br>
nil\*	=	binobj:insert(a,i)		-- inserts i (string or number(converts into string)) in position a</br>
nil\*	=	binobj:parseN(n)		-- removes ever (nth) byte of data</br>
nil 	=	binobj:getlength()		-- gets length or size of binary data</br>
nil\*	=	binobj:shift(n)			-- shift the binary data by n positive --> negitive <--</br>
nil\*	=	binobj:delete(a,b)		-- deletes part of a binobj data Usage: binobj:delete(1) deletes at pos 1 binobj:delete(1,10) deletes from 1 to 10, binobj:delete('string') removes all instances of 'string' from the object</br>
nil\*	=	binobj:encrypt(seed)	-- encrypts data using a seed, seed may be left blank</br>
nil\*	=	binobj:decrypt(seed)	-- decrypts data encrypted with encrypt(seed)</br>
nil\*	=	binobj:shuffle()		-- Shuffles the data randomly Note: there is no way to get it back!!! If original is needed clone beforehand</br>
nil\*\*	=	binobj:mutate(a,i)		-- changes position a's value to i</br>
nil		=	binobj:merge(o,t)		-- o is the binobj you are merging if t is true it merges the new data to the left of the binobj EX: b:merge(o,true) b='yo' o='data' output: b='datayo' b:merge(o) b='yo' o='data' output: b='yodata'</br>
nil\*	=	binobj:parseA(n,a,t)	-- n is every byte where you add, a is the data you are adding, t is true or false true before false after</br>
nil		=	binobj:getHEX(a,b)		-- returns the HEX of the bytes between a,b inclusive</br>
nil		=	binobj:cryptM()			-- a mirrorable encryptor/decryptor</br>
nil		=	binobj:addBlock(d,n)	-- adds a block of data to a binobj s is size d is data e is a bool if true then encrypts string values. if data is larger than 'n' then data is lost. n is the size of bytes the data is Note: n is no longer needed but you must use getBlock(type) to get it back</br>
nil		=	binobj:getBlock(t,n)	-- gets block of code by type</br>
nil		=	binobj:seek(n)			-- used with getBlock EX below with all 3</br>
nil\*	=	binobj:morph(a,b,d)		-- changes data between point a and b, inclusive, to d</br>
nil		=	binobj:fill(n,d)		-- fills binobj with data 'd' for n</br>
nil		=	binobj:fillrandom(n)	-- fills binobj with random data for n</br>
nil		=	binobj:shiftbits(n)		-- shifts all bits by n amount</br>
nil		=	binobj:shiftbit(n,i)	-- shifts a bit ai index i by n</br>
nil#	=	binobj:streamwrite(d,n)	-- writes to the streamable binobj d data n position</br>
nil#	=	binobj:open()			-- opens the streamable binobj</br>
nil#	=	binobj:close()			-- closes the streamable binobj</br>
nil		=	binobj:wipe()			-- erases all data in the file</br>
nil\*	=	binobj:tackB(d)			-- adds data to the beginning of a file</br>
nil		=	binobj:tackE(d)			-- adds data to the end of a file</br>
nil		=	binobj:parse(n,f)		-- loops through each byte calling function 'f' with the args(i,binobj,data at i)</br>
nil		=	binobj:flipbit(i)		-- flips the binary bit at position i</br>
nil\*	=	binobj:gsub()			-- just like string:gsub(), but mutates self</br>
nil		=	blockWriter:addNamedBlock(name,value) -- writes a named block to the file with name 'name' and the value 'value'</br>
</br>
Note: numbers are written in Big-endian use bin.endianflop(d) to filp to Little-endian</br>
</br>
Note: binobj:tonumber() returns big,little endian so if printing do: b,l=binobj:tonumber() print(l) print(b)</br>
</br>
nil		=	bitobj:add(i)		-- adds i to the bitobj i can be a number (base 10) or a bitobj</br>
nil		=	bitobj:sub(i)		-- subs i to the bitobj i can be a number (base 10) or a bitobj</br>
nil		=	bitobj:multi(i)		-- multiplys i to the bitobj i can be a number (base 10) or a bitobj</br>
nil		=	bitobj:div(i)		-- divides i to the bitobj i can be a number (base 10) or a bitobj</br>
nil		=	bitobj:flipbits()	-- filps the bits 1 --> 0, 0 --> 1</br>
string	=	bitobj:getBin()		-- returns 1's & 0's of the bitobj</br>

\# stream objects only</br>
\* not compatible with stream files</br>
\*\* works but do not use with large files or it works to some degree</br>
\*\*\* in stream objects all changes are made directly to the file, so there is no need to do tofile()</br>


# Discord
For real-time assistance with my libraries! A place where you can ask questions and get help with any of my libraries</br>
https://discord.gg/U8UspuA</br>
