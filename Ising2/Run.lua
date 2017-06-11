local Lattice = require 'Lattice'
local MyLattice = Lattice:New();

--math.randomseed(os.time())

local Model = require 'Model';
Model = Model:New();
Model.Lattice = MyLattice;

MyLattice:Init(100,100,1);
MyLattice:InitRandomField(8,0);

function Model:Measure(Lattice)
	-- Return a table where [ylabel] = measuredpoint.
	local Out = {};

	Out.M = Lattice:GetM();

	return Out;
end 






local function linspace(startn,num,endn)
	local step = (endn-startn) / (num-1);
	local out = {}

	for i = 1, num do 
		local val = startn + (i-1)*step 
		table.insert(out, val) 
	end 
	return out
end ;

local function tjoin(t1, t2)
	local out = {};
	for i,v in pairs(t1) do
		table.insert(out,v)
	end 
	for i,v in pairs(t2) do 
		table.insert(out,v)
	end 
	return out ;
end 


local Field = linspace(-8,100,8);
local Field2 = linspace(8,100,-8);

local Field = tjoin(Field,Field2);


local Params = {
	ExternalField = Field;
}

Model:Run(Params, 'Cycle');



