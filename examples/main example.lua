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
print(nL,nB)
str=test3:getBlock("s",5)
print(str)
bool=test3:getBlock("b")
print(bool)
tab=test3:getBlock("t")
print(tab)
