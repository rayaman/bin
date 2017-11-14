function bubbleSort(A)
  local itemCount=#A
  local hasChanged
  repeat
	for i=1,#A do
		io.write(string.char(A[i]))
	end
	io.write("\n")
    hasChanged = false
    itemCount=itemCount - 1
    for i = 1, itemCount do
      if A[i] > A[i + 1] then
        A[i], A[i + 1] = A[i + 1], A[i]
        hasChanged = true
      end
    end
  until hasChanged == false
end
reflist={"A","S","S","I","G","N","M","E","N","T"}
list={}
list2={}
for i,v in pairs(reflist) do
	list[#list+1]=string.byte(v)
	list2[#list2+1]=string.byte(v)
end
function SelectionSort(f)
    for k = 1, #f-1 do
		for i=1,#f do
			io.write(string.char(f[i]))
		end
		io.write("\n")
        local idx = k
        for i = k+1, #f do
            if f[i] < f[idx] then
                idx = i
            end
        end
        f[k], f[idx] = f[idx], f[k]
    end
end
print("Bubble Sort")
bubbleSort(list)
print("Selection Sort")
SelectionSort(list2)
