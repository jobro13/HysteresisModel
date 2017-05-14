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
		--print("There are " .. NumFlip .. " neighbours DOWN, target is DOWN, chance is " .. chance)
		table.insert(out.FlipDown, chance)


		Test:SetSpin(2,2,1,-1)
		local U = Test:GetDeltaU(2,2,1);

		local chance = math.exp(-U/Test.Temperature);
		if chance > 1 then
			chance =1;
		end

		--print("There are " .. NumFlip .. " neighbours DOWN, target is UP, chance is " .. chance)
		table.insert(out.FlipUp, chance)

	end 


	return out;
end 

local function stepspace(startn, step, endn)
	local out = {};
	for i=startn,endn,step do 
		table.insert(out,i)
	end 
	return out;
end 

local function linspace(startn,num,endn)
	local step = (endn-startn) / (num-1);
	local out = {}

	for i = 1, num do 
		local val = startn + (i-1)*step 
		table.insert(out, val) 
	end 
	return out
end 


Test.J = 1;

Tc = 2*Test.J / (math.log(1+math.sqrt(2)));


TempSweep = stepspace(Tc-0.1,0.001,Tc+0.1);

local Field = -1;

FieldSweep = linspace(Field,#TempSweep, -Field);

DUp = {};
DDown = {};

--TempSweep = {1}

for i,Temperature in pairs(TempSweep) do 
	local LeField = FieldSweep[i];
	Test.Temperature = Temperature;
	Test.ExternalField = LeField;

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