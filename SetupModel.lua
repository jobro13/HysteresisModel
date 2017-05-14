Model = require 'Model'
Lattice = require 'Lattice'

MyLattice = Lattice:new();
MyLattice:init(10,10,1);

MyLattice.Temperature = 150;--100;



MyModel = Model:new(MyLattice);
-- Sweeps of whole lattice per step.
MyModel.Sweeps = 100;

MyModel.Callback = function(step, nsteps)
print(step/nsteps);
end


Results = {};
Results_T = {};

function MyModel:SetModelParam(para)

	self.Lattice.ExternalField = para
end

local function linspace(startn, step, endn)
	local out = {};
	for i=startn,endn,step do 
		table.insert(out,i)
	end 
	return out;
end 

local function runsim(tsteps)

	MyModel.TemperatureList = tsteps;
	Out=MyModel:Run(tsteps);
	table.insert(Results,Out)
	table.insert(Results_T, tsteps)
end 

TLow = -1.2;
TStep = 0.02;
THigh = 1.2;

ltoh=true;
sweeps=1;

for i = 1, sweeps*2 do
	local low,step,high
	if ltoh then 
		low = TLow;
		step=TStep;
		high=THigh;
	else 
		low=THigh;
		step = -TStep;
		high=TLow;
	end 
	ltoh=not(ltoh);
	runsim(linspace(low,step,high))
end 

--runsim(linspace(TLow,TStep,THigh))





local OUTFILE = io.open('RESULTS.csv', 'w');
for i=1,#Results do
	M_result = Results[i];
	T_result = Results_T[i];
	str_write1 = table.concat(M_result, ',')
	str_write2 = table.concat(T_result, ',')
	OUTFILE:write(str_write1.."\n")
	OUTFILE:write(str_write2.."\n")
end 

OUTFILE:flush()
OUTFILE:close()

