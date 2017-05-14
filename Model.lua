local Model = {};

Model.TemperatureList = {};
Model.Sweeps = {};
Model.Lattice = nil;

function Model:new(Lattice)
	assert(Lattice, 'Input a lattice')
	return setmetatable({Lattice=Lattice},{__index=self})
end 

-- USER defined function.
function Model:SetModelParam()
	error("SetParam function is undefined")
end 

function Model:Run(paramlist) 
	local Volume = self.Lattice.x*self.Lattice.y*self.Lattice.z;

	local Results = {};

	local index=0;
	local test 
	for i,v in pairs(paramlist) do 
		test = i 
		break 
	end 

	for i = 1, #paramlist[test] do 
		local input = {} 
		for ind, val in pairs(paramlist) do 
			input[ind] = val[i]
		end 
		self:SetModelParam(input);
		for Sweep=1,self.Sweeps*Volume do 
			local tx,ty,tz = self.Lattice:GetRandomLatticeSite();
			DeltaU = self.Lattice:GetDeltaU(tx,ty,tz);
			--print("Flip energy: " .. DeltaU .. " at External field: " .. Temperature)
			if DeltaU < 0 then
				self.Lattice:SetSpin(tx,ty,tz,-self.Lattice.Grid[tx][ty][tz])
			else 
				--print(DeltaU, self.Lattice.Temperature)
				if math.random() < math.exp(-DeltaU/self.Lattice.Temperature) then
					self.Lattice:SetSpin(tx,ty,tz,-self.Lattice.Grid[tx][ty][tz])
				end;
			end 
		end 
		local sumof=self.Lattice:GetM();
		table.insert(Results, sumof)
		index=index+1;

		if self.Callback then self.Callback(index,#paramlist) end;
	end
	return Results;
end 

return Model