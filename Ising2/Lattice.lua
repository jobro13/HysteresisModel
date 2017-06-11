local Lattice = {}

local gd 

Lattice.ExternalField=0; -- This is the external field strength.
Lattice.J = 1;
Lattice.Temperature = 0;

function Lattice:New()
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

function Lattice:ToAnim(latfile_in, gif_out,pxsize,delay, zdepth)
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
						local mycolor = ((spin == -1) and sp_up_color) or sp_down_color;
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
  		fp:write(tim:gifAnimAddStr(false, 0, 0, delay or 5, gd.DISPOSAL_NONE));
	end 
	fp:write(gd.gifAnimEndStr())
	fp:close()
end 

--Lattice:ToAnim('Lattice.lat', 'out_test.gif',2)


function Lattice:GetRandomLatticeSite()
	local xmax = self.x;
	local ymax = self.y;
	local zmax = self.z;

	local x,y,z = math.floor(math.random()*xmax)+1,math.floor(math.random()*ymax)+1,math.floor(math.random()*zmax)+1;
	return x,y,z 
end 

-- Well this actually works as a clear too... Ok then.
function Lattice:Init(x,y,z)
	self.HasLatticeFile = false;

	self.x = x;
	self.y = y;
	self.z = z;

	self.Grid = {};

	local TotIndex = 0;

	for xindex=1,x do 
		self.Grid[xindex]={};
		for yindex=1,y do 
			self.Grid[xindex][yindex]={};
			for zindex=1,z do 
				TotIndex = TotIndex+1;
				self.Grid[xindex][yindex][zindex] = {Spin = -1, Index=TotIndex};
			end
		end
	end

	self:InitNeighbours()
	self:InitGrains()
end

function Lattice:InitNeighbours()
	local x,y,z = self.x, self.y, self.z
	for xi = 1,x do 
		for yi = 1,y do 
			for zi = 1,z do 
				local Grain = self.Grid[xi][yi][zi];
				local NList = {};
				for i,coord in pairs(self:GetNeighbours(xi,yi,zi)) do 
					local OGrain = self.Grid[coord[1]][coord[2]][coord[3]];
					table.insert(NList, OGrain)
				end
				Grain.Neighbours = NList;
			end 
		end 
	end 
end 

function Lattice:InitGrains()
	local Grains = {};
	local x,y,z = self.x, self.y, self.z	
	for xi = 1, x do 
		for yi = 1, y do 
			for zi = 1, z do 
				table.insert(Grains, self.Grid[xi][yi][zi])
			end 
		end 
	end
	self.Grains=Grains;
end 

-- This is the Box Muller transform.
local function randn(variance, mean)

    return  math.sqrt(-2 * variance * math.log(math.random())) *
            math.cos(2 * variance * math.pi * math.random()) + mean
end 

function Lattice:InitRandomField(variance, mean)
	-- Now we can loop over Grains.
	for _, Grain in pairs(self.Grains) do 
		Grain.LocalField = randn(variance,mean);
	end
end 

-- This can be optimized by immediately setting the neighbour bond too
function Lattice:InitRandomBond(variance, mean)
	for _, Grain in pairs(self.Grains) do 
		-- Loop over all neighbours..
		Grain.Bonds = {};
		for N_Index, Neighbour in pairs(Grain.Neighbours) do 
			-- Figure out if Neighbour already has this one..
			local My_Index 
			for i, Check in pairs(Neighbour.Neighbours) do 
				if Check == Grain then 
					My_Index = i;
					break 
				end 
			end 
			if Neighbour.Bonds and Neighbour.Bonds[My_Index] then 
				Grain.Bonds[N_Index] = Neighbour.Bonds[My_Index]
			else 
				Grain.Bonds[N_Index] = randn(variance,mean)
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

function Lattice:GetU()

end

function Lattice:GetDeltaU(Grain)
	local Neighbours = Grain.Neighbours;
	
	-- Calculate the current energy and multiply it with 4. See notes.	
	local spin = Grain.Spin
	local b_energ = 0;
	local h_energ = 0;
	for i, Neighbour in pairs(Neighbours) do 
		-- Calculate the bond energy.
		local J = self.J
		if Grain.Bonds then 
			J = Grain.Bonds[i]
		end 
		b_energ = b_energ - 2*spin*Neighbour.Spin * (J);
	end 
	local EffField = (Grain.LocalField or 0) + self.ExternalField;
	local FieldEnergy = -EffField*spin;
	local UOld = b_energ + FieldEnergy;
	local dU = -UOld*2;
	return dU
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
				table.insert(out_t,self.Grid[x][y][z].Spin)
			end 
		end 
	end 

	fhandle:write(table.concat(out_t, ", ").."\n")
	--fhandle:flush();
	--fhandle:close()
end 

function Lattice:GetU()
	local sum = 0;
	error('disabled')
	
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
	for _,Grain in pairs(self.Grains) do 
		sum = sum + Grain.Spin;
	end 
	return sum;
end

function Lattice:Show(z)
	local z = z or 1;
	for xi = 1,self.x do 
		for yi = 1,self.y do 
			local Grain = self.Grid[xi][yi][z];
			local p = (Grain.Spin == 1 and "X") or ".";
			io.write(p);
		end 
		io.write("\n")
	end 
end 

--[[function Lattice:GetM()
	local Energy,Uinteract,Uint = self:GetDeltaU(1,1,1,1)
	return math.exp(-Uint/self.Temperature),math.exp(-Uinteract/self.Temperature)
end --]]


return Lattice