local Lattice = {}

math.randomseed(os.time())

local gd 

Lattice.ExternalField=0; -- This is the external field strength.
Lattice.J = 1;

function Lattice:new()
	return setmetatable({}, {__index=self,__gc=self.Destroy})
end

-- Call this function to finalize the lattice. Do this at end of a simulation, or when unloading the lattice.
function Lattice:Destroy()
	if self.HasLatticeFile then 
		self.HasLatticeFile:flush()
		self.HasLatticeFile:close()
	end
end 

local function csvread(fname) 
	local out = {};
	for line in io.lines(fname) do 
		local t = {};
		table.insert(out,t)
		for match in string.gmatch(line,"[^,%s]+") do 
			table.insert(t,tonumber(match));
		end 
	end 
	return out;
end 

function Lattice:ToAnim(latfile_in, gif_out,pxsize,zdepth)
	if not gd then 
		gd = assert(require 'gd', 'GD is not installed')
	end 

	local pxsize=pxsize or 1;

	local data_in = csvread(latfile_in);
	local sof = data_in[1];
	local x,y,z = sof[1], sof[2], sof[3];

	-- specify which layer.
	local use_z = zdepth or 1;

	local im = gd.create(x*pxsize,y*pxsize);

	local sp_up_color = im:colorAllocate(0,0,0);
	local sp_down_color = im:colorAllocate(255,255,255);

	local fp = io.open(gif_out, "w")
	fp:write(im:gifAnimBeginStr(true, 0))

	local tscale = #data_in - 1;

	local tim = gd.createPalette(x*pxsize,y*pxsize);
  	tim:paletteCopy(im);

	for i = 1, tscale do 
		print(i/tscale)
		local mydata = data_in[i+1];
		local index = 0;
		for tx = 1,x do
			for ty = 1,y do 
				for tz = 1,z do  
					index=index+1;
					if tz == use_z then
						local spin = mydata[index];
					--	print(spin)
						local mycolor = ((spin == 1) and sp_up_color) or sp_down_color;
						if pxsize == 1 then 
							tim:setPixel(tx,ty,mycolor);
						else 
							for dx = tx*pxsize - pxsize + 1, (tx+1)*pxsize+pxsize-2 do 
								for dy =  ty*pxsize - pxsize + 1,(ty+1)*pxsize+pxsize-2 do 
									tim:setPixel(dx,dy,mycolor)
								end 
							end 
						end
					end 
				end 
			end 
		end 
  		fp:write(tim:gifAnimAddStr(false, 0, 0, 5, gd.DISPOSAL_NONE));
	end 
	fp:write(gd.gifAnimEndStr())
	fp:close()
end 

Lattice:ToAnim('Lattice.lat', 'out_test.gif',2)


function Lattice:GetRandomLatticeSite()
	local xmax = self.x;
	local ymax = self.y;
	local zmax = self.z;

	local x,y,z = math.floor(math.random()*xmax)+1,math.floor(math.random()*ymax)+1,math.floor(math.random()*zmax)+1;
	return x,y,z 
end 

-- Well this actually works as a clear too... Ok then.
function Lattice:init(x,y,z)
	self.HasLatticeFile = false;

	self.x = x;
	self.y = y;
	self.z = z;

	self.Grid = {};

	for xindex=1,x do 
		self.Grid[xindex]={};
		for yindex=1,y do 
			self.Grid[xindex][yindex]={};
			for zindex=1,z do 
				if math.random() > 0.5 then
					self.Grid[xindex][yindex][zindex]=1;
				else 
					self.Grid[xindex][yindex][zindex]=-1;
				end
			end
		end
	end
end

function Lattice:SetSpin(x,y,z,sptype)
	self.Grid[x][y][z] = sptype;
end 

function Lattice:GetNeighbours(x,y,z)
	local list = {};
	local mx,my,mz=self.x,self.y,self.z;

	if x+1 <= mx then
		table.insert(list, {x+1,y,z})
	else 
		table.insert(list, {1,y,z})
	end 
	if y+1 <= my then
		table.insert(list, {x,y+1,z})
	else 
		table.insert(list, {x,1,z})
	end 
	if mz ~= 1 then 
		if z+1 <= mz then
			table.insert(list, {x,y,z+1})
		else 
			table.insert(list, {z,y,1})
		end 
	end

	if x-1 >= 1 then
		table.insert(list, {x-1,y,z})
	else 
		table.insert(list, {mx,y,z})
	end 
	if y-1 >= 1 then
		table.insert(list, {x,y-1,z})
	else 
		table.insert(list, {x,my,z})
	end 
	if mz ~= 1 then 
		if z-1 >= 1 then
			table.insert(list, {x,y,z-1})
		else 
			table.insert(list, {z,y,mz})
		end
	end  
	return list
end 


local U_formation_insulator = 0;
local U_formation_metal = 0; 
local U_slope_insulator=0;
local U_slope_metal=0;

local U_Interaction_Amplitude =1;

-- High temperature, Low temperature state temperatures;
local THigh = 360;
local TLow = 300;

local EnergyMultiplier = 1;--THigh/10;

-- Energy difference between both states.
local Energy_Delta_Transition = 120;

local U_slope_insulator = Energy_Delta_Transition / (THigh-TLow);
local U_slope_metal = Energy_Delta_Transition / (TLow - THigh);


local U_formation_insulator = -U_slope_insulator*TLow;
local U_formation_metal = -U_slope_metal*THigh;



local function U_intern(state,Temperature)
	if state == 1 then 
		-- Insulating
		return U_formation_insulator + U_slope_insulator * Temperature;
	elseif state == -1 then 
		-- Conducting
		return U_formation_metal + U_slope_metal * Temperature;
	end 
end 
--print(U_intern(1,TLow))
assert(U_intern(1,TLow) == 0, '1');
assert(U_intern(-1,TLow) == Energy_Delta_Transition,'2');
assert(U_intern(1,THigh)==Energy_Delta_Transition,'3');
assert(U_intern(-1,THigh)==0,'4')



function Lattice:GetEnergyAt(x,y,z,targ, flip)
	local Current = (targ or self.Grid[x][y][z]) * ((flip and -1) or 1); 

	local Uinteract = 0;
	for _,Neighbour in pairs(self:GetNeighbours(x,y,z)) do 
		Uinteract = Uinteract - Current*self.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]]*U_Interaction_Amplitude;
	end

	--local Uint=U_intern(Current,self.Temperature);
	Uint=-Current*self.ExternalField;
	--print(Uinteract, Uint)
	-- All terms are negative.
	--print("state " .. Current .. " intern " .. Uint .. " interact " .. Uinteract)
	--error('trace')
	return (Uinteract+Uint)*EnergyMultiplier--, Uinteract*EnergyMultiplier,Uint*EnergyMultiplier;
end 

function Lattice:GetDeltaU(x,y,z,targ)
	--local UNew,UinteractNew,UintNew = self:GetEnergyAt(x,y,z,targ,true)
	--local UOld,UinteractOld,UintOld = self:GetEnergyAt(x,y,z,(targ and -targ),false)
	--local dU = UNew-UOld;

	local STATE = self.Grid[x][y][z];
	local NEIGHBOUR_SUM = 0;
	for _,Neighbour in pairs(self:GetNeighbours(x,y,z)) do 
		NEIGHBOUR_SUM = NEIGHBOUR_SUM + self.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]];
	end 

	local dU = 2*STATE*NEIGHBOUR_SUM*self.J + 2 * STATE * self.ExternalField;
	--print(dU,self.Temperature)
	return dU;
	--[[local UNew,UinteractNew,UintNew = self:GetEnergyAt(x,y,z,targ,true)
	local UOld,UinteractOld,UintOld = self:GetEnergyAt(x,y,z,(targ and -targ),false)
	local dU = UNew-UOld;

	local dUinteract = UinteractNew-UinteractOld;
	local dUint = UintNew-UintOld;
	return dU,dUinteract,dUint;--]]
	--[=[local Current = targ or self.Grid[x][y][z];

	local sum = 0;

	for _,Neighbour in pairs(self:GetNeighbours(x,y,z)) do 
		sum = sum + self.Grid[Neighbour[1]][Neighbour[2]][Neighbour[3]];
	end 

	return sum*Current*2 + self.ExternalField*Current;
	--]=]
end 

-- Dump the lattice in the filename.
function Lattice:Dump(fname) 
	local fhandle
	if not self.HasLatticeFile then 
		-- open new file 
		self.HasLatticeFile = io.open(fname, 'w')
		fhandle = self.HasLatticeFile
		-- First row of Lattice is the size
		fhandle:write(self.x .. ", " .. self.y .. ", "..  self.z .. "\n")
	else
		fhandle = self.HasLatticeFile;
	end 

	local out_t = {};
	for x = 1, self.x do 
		for y = 1, self.y do 
			for z = 1,self.z do 
				table.insert(out_t,self.Grid[x][y][z])
			end 
		end 
	end 

	fhandle:write(table.concat(out_t, ", ").."\n")
	--fhandle:flush();
	--fhandle:close()
end 

function Lattice:GetU()
	local sum = 0;
	
	for x=1,self.x do
		for y=1,self.y do
			for z=1,self.z do
				sum=sum+self:GetEnergyAt(x,y,z);
			end
		end
	end
	return sum;
end

function Lattice:GetM()

	local sum = 0;
	for x=1,self.x do
		for y=1,self.y do
			for z=1,self.z do
				sum = sum + self.Grid[x][y][z];
			end
		end
	end
	return sum;
end

--[[function Lattice:GetM()
	local Energy,Uinteract,Uint = self:GetDeltaU(1,1,1,1)
	return math.exp(-Uint/self.Temperature),math.exp(-Uinteract/self.Temperature)
end --]]


return Lattice