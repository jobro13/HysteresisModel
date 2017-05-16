
Model = require 'Model'
Lattice = require 'Lattice'
DataSet = require 'DataSet'

MyLattice = Lattice:new();
MyLattice:init(10,10,10);

MyLattice.Temperature = 1;--100;



MyModel = Model:new(MyLattice);
-- Sweeps of whole lattice per step.
MyModel.Sweeps = 10;

MyModel.Callback = function(step, nsteps)
--print(step/nsteps);
end


Results = {};
Results_T = {};

LatticeVolume = {};
TSwitch = {};

local Current_Time = 0;
local Offset = 5; -- This is the lenght of TempSweep1, which takes care of Lattice initial conditions.

function MyModel:SetModelParam(para, m)
	Current_Time = Current_Time + 1;
	if m < 0 and Current_Time > Offset then 
		local v = self.Lattice.x * self.Lattice.y*self.Lattice.z;
		table.insert(LatticeVolume, v)
		table.insert(TSwitch, Current_Time-Offset);
		print("LatticeVolume: " .. v .. " TSwitch: " .. (Current_Time-Offset))
		return true
	end 

	if para.Temperature then 
		self.Lattice.Temperature = para.Temperature;-- para.Temperature 
	end 
	if para.Field then 
		self.Lattice.ExternalField = para.Field--para.Field ;
	end 



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

local function runsim(tsteps)

	MyModel.TemperatureList = tsteps;
	Out=MyModel:Run(tsteps);
	table.insert(Results,Out)
	table.insert(Results_T, tsteps)
end 

local function tjoin(t,t2)
	for i,v in pairs(t2) do 
		table.insert(t,v)
	end 
end 

sweeps=10
SizeMin = 1;
SizeMax = 20;
MyLattice.J = 1;

local Field = 1
local Num = 20000;

Tstart = 2.66;
Tend = 2.72;


TempSweep1 = {0,0,0,1,2}
FieldSweep1 = {100,100,100,0,0}

tjoin(TempSweep1, linspace(4,1,4))
tjoin(FieldSweep1, linspace(0,1,0))

TempSweep2 = linspace(4, Num,4);
-- -0.09 -0.11
FieldSweep2 = linspace(-0.095, Num, -0.095)

local Inputs = {
		{Temperature = TempSweep1; Field = FieldSweep1};
		{Temperature = TempSweep2, Field = FieldSweep2}
}



for n = SizeMin, SizeMax do 

for i = 1, sweeps do
	-- Reset lattice.
	MyLattice:init(n,n,n);
	for i,v in pairs(Inputs) do 
		Current_Time = 0;
		runsim(v)
	end 
end 

end
--runsim(linspace(TLow,TStep,THigh))

MyData = DataSet:new();
MyData:Add(LatticeVolume, TSwitch, "Lattice Volume", 1)

local gem = {};
local t  = {}
for i,v in pairs(LatticeVolume) do
	if not t[v] then 
		t[v] = {TSwitch[i]}
	else 
		table.insert(t[v],TSwitch[i])
	end  

end 

local LVal = {};
local GVal = {}

for i,v in pairs(t) do 
	local tot = 0;
	local n = 0;
	for ind, val in pairs(v) do 
		tot = tot + val;
		n = n + 1;
	end 
	table.insert(LVal, i);
	table.insert(GVal, tot/n)
end 

MyData:Add(LVal,GVal,"Average switch time", 2)


-- Also add TIME data.

--MyData:Add(Time, MTime, "Time",1)

MyData:Write()
