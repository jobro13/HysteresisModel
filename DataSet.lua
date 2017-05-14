local DataSet = {};

DataSet.Filename = 'RESULTS.csv';

function DataSet:new()
	return setmetatable({Plots = {}}, {__index=self})
end 

-- First x data then y data.
function DataSet:Add(DataX,DataY, DataName, PlotNumber )
	if not self.Plots[PlotNumber] then 
		self.Plots[PlotNumber] = {Data = {}, DataName = {}};
	end 

	table.insert(self.Plots[PlotNumber].Data, DataX)
	table.insert(self.Plots[PlotNumber].Data, DataY)
	table.insert(self.Plots[PlotNumber].DataName,DataName)

end 



function DataSet:Write()
	local str = table.concat(self.DataNames, '\n');
	for i,v in pairs(self.Data) do 
		str = str .. table.concat(v,",") .. "\n";
	end 
	local file = io.open(self.Filename, 'w')
	file:write(str)
	file:flush();
	file:close()
end 

function DataSet:Write()
	local str = "";
	for i, DataList in pairs(self.Plots) do 
		--print('index', i)
		for index, DataName in pairs(DataList.DataName) do 
			str = str .. DataName .. "\n"
		end
		str  = str .. "Data:\n"
		for index, Data in pairs(DataList.Data) do 
			str = str .. table.concat(Data,",") .. "\n"
		end 
	end 
	local file = io.open(self.Filename,'w')
	file:write(str)
	file:flush()
	file:close()
end 



return DataSet 