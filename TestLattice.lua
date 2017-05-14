-- Test lattice. 

local Lattice = require('Lattice');
local DataSet = require('DataSet')

local Test = Lattice:new();
Test:init(3,3,1);

local function reset()
for x = 1, 3 do 
	for y = 1, 3 do 
		Test:SetSpin(x,y,1,1);
	end
end
end 

Neighbours = {{2,1,1}, {2,3,1},{1,2,1}, {3,2,1}};

local Results = {};


function GetResults()
	local out = {FlipUp = {}, FlipDown = {}};
	for NumFlip=0,#Neighbours do 
		reset();
		for i = 0, NumFlip do 
			if i ~= 0 then 
				local Target = Neighbours[i];
				Test:SetSpin(Target[1],Target[2],Target[3],-1)
			end 
		end 

		Test:SetSpin(2,2,1,1)
		local U = Test:GetDeltaU(2,2,1);

		local chance = math.exp(-U/Test.Temperature);
		if chance > 1 then
			chance =1;
		end
		print("There are " .. NumFlip .. " neighbours DOWN, target is DOWN, chance is " .. chance)
		table.insert(out.FlipDown, chance)


		Test:SetSpin(2,2,1,-1)
		local U = Test:GetDeltaU(2,2,1);

		local chance = math.exp(-U/Test.Temperature);
		if chance > 1 then
			chance =1;
		end

		print("There are " .. NumFlip .. " neighbours DOWN, target is UP, chance is " .. chance)
		table.insert(out.FlipUp, chance)

	end 


	return out;
end 

local function linspace(startn, step, endn)
	local out = {};
	for i=startn,endn,step do 
		table.insert(out,i)
	end 
	return out;
end 

TempSweep = linspace(1,0.1,6);
FieldSweep = linspace(1,0.1,6);

DUp = {};
DDown = {};

--TempSweep = {1}

for i,Temperature in pairs(TempSweep) do 
	Field = FieldSweep[i];
	Test.Temperature = Temperature;
	Test.ExternalField = 0;

	local Out = GetResults();

	for i,v in pairs(Out.FlipUp) do 
		if not DUp[i] then 
			DUp[i] = {};
		end 
		table.insert(DUp[i],v);
	end 

	for i,v in pairs(Out.FlipDown) do 
		if not DDown[i] then 
			DDown[i] = {};
		end 
		table.insert(DDown[i],v);
	end 
end 

local MyData = DataSet:new()

for row, Data in pairs(DDown) do 
	MyData:Add(TempSweep, Data,'Target: DOWN Neighbours DOWN: ' .. (row-1), 1)
end 

for row, Data in pairs(DUp) do 
	MyData:Add(TempSweep, Data,'Target: UP Neighbours UP: ' .. (#Neighbours-(row-1)), 2)
end 

MyData:Write()