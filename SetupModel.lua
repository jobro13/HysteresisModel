local TERM_HOME_STR = io.popen("tput home"):read();
local SHOW = true;


os.execute"tput clear"

Model = require 'Model'
Lattice = require 'Lattice'
DataSet = require 'DataSet'

MyLattice = Lattice:new();
MyLattice:init(10,10,1);

MyLattice.Temperature = 1;--100;



MyModel = Model:new(MyLattice);
-- Sweeps of whole lattice per step.
MyModel.Sweeps = 100;

MyModel.Callback = function(step, nsteps)
--print(step/nsteps);
end


Results = {};
Results_T = {};

function MyModel:SetModelParam(para)
	if show then io.write(TERM_HOME_STR) end;
	if para.Temperature then 
		self.Lattice.Temperature = para.Temperature;-- para.Temperature 
	end 
	if para.Field then 

		self.Lattice.ExternalField = para.Field--para.Field ;
	end 
	if show then 
	for x = 1,MyLattice.x do 
	for y = 1,MyLattice.y do 
		if MyLattice.Grid[x][y][1] == -1 then 
			io.write("X")
		else 
			io.write(" ")
		end 
	end 
	io.write("\n")
	end
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

local function runsim(tsteps,nodata)

	MyModel.TemperatureList = tsteps;
	Out=MyModel:Run(tsteps);
	if not nodata then 
		table.insert(Results,Out)
		table.insert(Results_T, tsteps)
	end
end 

local function tjoin(t,t2)
	for i,v in pairs(t2) do 
		table.insert(t,v)
	end 
end 

sweeps=1
MyLattice.J = 1;
Tc = 2*MyLattice.J / (math.log(1+math.sqrt(2)));
--Tc = 4.5
--[[
TcOffset = 0.5;

TempSweep1 = linspace(1,100,Tc-1);
TempSweep1 = {0}
local Field = 2.35;
FieldSweep1 = linspace(Field,#TempSweep1, -Field);
FieldSweep1 = {-100}
TempSweep2 = linspace((Tc-1),100,1);
TempSweep2 = {4,4,4,4,4}--,4.01,4.01,4.01,4.01,4.01,4.01,4.01,4.01,4.01,4.01}
FieldSweep2 = linspace(-Field,#TempSweep1, Field);
FieldSweep2 = {Field,Field,Field,Field,Field} --Field*5,Field*5,Field*5,Field*5,Field*5,Field*5000,Field*5,Field*5,Field*5,Field*5}
TempSweep2  = {};
FieldSweep2 = {};
for i = 1,20 do 
	table.insert(TempSweep2, 1);
	table.insert(FieldSweep2, Field)
end 

if #FieldSweep2 ~= #TempSweep2 then 
	print(#FieldSweep2)
	print(#TempSweep2)
	error('fail')
end
--]]

local Field = 0
local Num = 200;

Tstart = 0;
Tend = 3;



local TempSweep1 = linspace(Tstart,Num,Tend);
local TempSweep2 = linspace(Tend,Num,Tstart);
local FieldSweep1 = linspace(Field, Num, -Field*1.25);
local FieldSweep2 = linspace(-Field*1.25,Num,Field);

--[[

local TempSweep1 = linspace(0,Num,Tc+0.1);
local TempSweep2 = linspace((Tc+0.1),Num,0)

local FieldSweep1 = linspace(0,Num,0);
local FieldSweep2 = FieldSweep1;



TempSweep1 = {0,0,0,1,2}
FieldSweep1 = {100,100,100,0,0}

tjoin(TempSweep1, linspace(4,1,4))
tjoin(FieldSweep1, linspace(0,1,0))

TempSweep2 = linspace(4, Num,4);
-- -0.09 -0.11
FieldSweep2 = linspace(-0.095, Num, -0.095)
--]]
local Inputs = {
		{Temperature = TempSweep1; Field = FieldSweep1};
		{Temperature = TempSweep2, Field = FieldSweep2}
	}


-- Setup lattice.

runsim({Temperature = {0,0,0}, Field = {10000, 10000, 10000}}, true)


for i = 1, sweeps do
	for i,v in pairs(Inputs) do 
		runsim(v)
	end 
end 

--runsim(linspace(TLow,TStep,THigh))

local MyData = DataSet:new();

local data_index=1;

Legends = {Time=1};

local time_offset=0;
local time_num = 0;

for i,v in pairs(Results) do 
	local M = v;
	local X = Results_T[i];
	print(#M)


	for Legend, Data in pairs(X) do 
		if not Legends[Legend] then 
			data_index = data_index+1;
			Legends[Legend] = data_index;
		end
		if Legend == "Temperature" then 
			local Time = {};
			local MTime = {};
			for ind, val in pairs(Data) do 
				table.insert(Time, #Time+time_offset);
				table.insert(MTime,M[ind])
			end
			time_num = time_num + 1;
			MyData:Add(Time,MTime,"Time of dataset " .. time_num , 1)
			time_offset = time_offset + #Time 
		end 
		print(#Data)
		MyData:Add(Data, M, Legend, Legends[Legend])
	end 
end 

for x = 1,MyLattice.x do 
	for y = 1,MyLattice.y do 
		if MyLattice.Grid[x][y][1] == -1 then 
			io.write("X")
		else 
			io.write(" ")
		end 
	end 
	io.write("\n")
end


-- Also add TIME data.

--MyData:Add(Time, MTime, "Time",1)

MyData:Write()

MyLattice:Dump("Lattice.lat")
