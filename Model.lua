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
	local sumof=0; 
	local numof=0;
	for _,Temperature in pairs(paramlist) do 
		self:SetModelParam(Temperature);
		sumof=self.Lattice:GetM();
		numof=1;
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
					sumof = sumof +self.Lattice:GetM();
					numof=numof+1;
				end;
			end 
		end 
		table.insert(Results, sumof/numof)
		index=index+1;

		if self.Callback then self.Callback(index,#self.TemperatureList) end;
	end
	return Results;
end 

return Model