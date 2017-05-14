Model = require 'Model'
Lattice = require 'Lattice'
DataSet = require 'DataSet'

MyLattice = Lattice:new();
MyLattice:init(20,20,20);

MyLattice.Temperature = 10;--100;



MyModel = Model:new(MyLattice);
-- Sweeps of whole lattice per step.
MyModel.Sweeps = 100;

MyModel.Callback = function(step, nsteps)
--print(step/nsteps);
end


Results = {};
Results_T = {};

function MyModel:SetModelParam(para)
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



sweeps=1
MyLattice.J = 1;
Tc = 2*MyLattice.J / (math.log(1+math.sqrt(2)));

TcOffset = 0.5;

TempSweep1 = linspace(1,100,Tc-1);
TempSweep1 = {0,1,2,3,4}
local Field = 0.01;
FieldSweep1 = linspace(Field,#TempSweep1, -Field);
FieldSweep1 = {0,0,0,0,0}
TempSweep2 = linspace((Tc-1),100,1);
TempSweep2 = {4,4,4,4,4,4.01,4.01,4.01,4.01,4.01,4.01,4.01,4.01,4.01,4.01}
FieldSweep2 = linspace(-Field,#TempSweep1, Field);
FieldSweep2 = {Field,Field,Field,Field,Field,Field*5,Field*5,Field*5,Field*5,Field*5,Field*500,Field*5,Field*5,Field*5,Field*5}
if #FieldSweep2 ~= #TempSweep2 then 
	print(#FieldSweep2)
	print(#TempSweep2)
	error('fail')
end
local Inputs = {
		{Temperature = TempSweep1; Field = FieldSweep1};
		{Temperature = TempSweep2, Field = FieldSweep2}
	}

for i = 1, sweeps do
	for i,v in pairs(Inputs) do 
		runsim(v)
	end 
end 

--runsim(linspace(TLow,TStep,THigh))

local MyData = DataSet:new();

local data_index=0;

Legends = {};

for i,v in pairs(Results) do 
	local M = v;
	local X = Results_T[i];
	print(#M)


	for Legend, Data in pairs(X) do 
		if not Legends[Legend] then 
			data_index = data_index+1;
			Legends[Legend] = data_index;
		end
		print(#Data)
		MyData:Add(Data, M, Legend, Legends[Legend])
	end 
end 


MyData:Write()
