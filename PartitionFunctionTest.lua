local Lattice = require 'Lattice'
local DataSet = require 'DataSet'

local MyLattice = Lattice:new()
-- Set parameters.
local Tc = 2*MyLattice.J / (math.log(1+math.sqrt(2)));
MyLattice.Temperature=1;
MyLattice.ExternalField = 2.2;

local x,y,z = 5,5,1;
MyLattice:init(x,y,z)

local t = MyLattice.Temperature;
local k = 1;
local config = {};
local maxn = x*y*z;
local tot = 2^maxn;
for i =1, maxn do 
	config[i] = 1;
end 
local function iter(p_arr)
	local p_arr = p_arr;
	local switch=false;
	for i,v in ipairs(p_arr) do 
		if v == 1 then
			switch=true;
			for ind=i,1,-1 do 
				if ind==i then
					p_arr[ind]=-1;
				else
					p_arr[ind]=1;
				end
			end 
			return p_arr, switch
		end 
	end 
	return p_arr, switch 
end

local function dump(l)
	local i = 0;
	for tx = 1,x do 
		for ty = 1,y do 
			for tz = 1,z do 
				i = i +1;
				MyLattice:SetSpin(tx,ty,tz,l[i])
			end 
		end
	end 
end 

local function GetU()
	local U = 0;
	for tx = 1,x do 
		for ty = 1,y do 
			for tz = 1,z do 
				U = U + MyLattice:GetEnergyAt(tx,ty,tz);
			end 
		end 
	end 
	return U
end 

local go = true;
local Z = 0;

local M  = {};
local Ud = {};

--local MData = {};
local UData = {};
local MData = {};

local cur = 0;

while go do
	-- write lattice. 
	cur = cur + 1;
	if cur % 10000 == 0 then 
		print(cur/tot,tot)
	end
	dump(config)
	local U = GetU();
	-- Add to partition function:
	local Add = math.exp(-U/(k*t));
	Z = Z + Add;


	local Mag = MyLattice:GetM();

	if not Ud[U] then 
		Ud[U] = Add;
	else
		Ud[U] = Ud[U] + Add;
	end

	if not M[Mag] then 
		M[Mag] = Add;
	else
		M[Mag] = M[Mag]+Add;
	end


	if not MData[Mag] then 
		MData[Mag] = {};
	else
		if not MData[Mag][U] then 
			MData[Mag][U] = true 
			if not UData[Mag] then 
				UData[Mag] = {U};
			else
				table.insert(UData[Mag],U)
			end 
		end
	end

--	MData[Mag] = 1;


	config,go = iter(config);
end 

local xval = {};
local yval = {};
for i,v in pairs(M) do 
	table.insert(xval, i);
	table.insert(yval, v/Z)
end 

local Out = DataSet:new();

Out:Add(xval, yval, 'Probability Magnetization', 1)


local xval = {};
local yval = {};
for i,v in pairs(Ud) do 
	table.insert(xval, i);
	table.insert(yval, v/Z)
end 

Out:Add(xval, yval, 'Probability Energy', 2)

local MDataX = {};
local UDataY = {};

for i,v in pairs(UData) do 
	for ind, val in pairs(v) do 
		table.insert(MDataX,i)
		table.insert(UDataY,val)
	end 
end


Out:Add(MDataX, UDataY, 'Magnetization vs Energy',3)

Out:Write()