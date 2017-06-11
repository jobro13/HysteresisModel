local Model = {};

local Plotter = require 'Plotter'

Model.Lattice = nil;

function Model:New()
	local obj = {};
	setmetatable(obj, {__index=self})
	return obj
end

-- 
function Model:Run(PList, SweepMode)
	local index = next(PList)
	local DataOut = {};


	if SweepMode == "Cycle" then 
		for i = 1, #PList[index] do 
			-- Set vars.
			for ParamName, Params in pairs(PList) do 
				self.Lattice[ParamName] = Params[i];

			end 
			local rep = true;
			while rep do 
				rep=false;
			-- Sweep over grain.
				for _, Grain in pairs(self.Lattice.Grains) do 
					--print(self.Lattice:GetDeltaU(Grain))
					if self.Lattice:GetDeltaU(Grain) < 0 then 
						Grain.Spin = -Grain.Spin;
						rep=true;
					end 
				end
			end
		--	self.Lattice:Show() 
		--	print(self.Lattice:GetM(), PList.ExternalField[i])
		--	self.Lattice:Dump("tmp.lat")
		
			local Measure = self:Measure(self.Lattice);

			for ParamName, Data in pairs(PList) do 
				if not DataOut[ParamName]then 
					DataOut[ParamName] = {};
				end 
				local xValue = Data[i]; 
				
				for index, yValue in pairs(Measure) do 
					if not (DataOut[ParamName][index]) then 
						DataOut[ParamName][index] = {x = {}, y = {}};
					end 
					table.insert(DataOut[ParamName][index].x, xValue);
					table.insert(DataOut[ParamName][index].y, yValue);
				end 
			end 

		end 
	--	self.Lattice:ToAnim("tmp.lat", "out.gif",4,5,1)

		-- Plot this data.

		for xLabel, Contents in pairs(DataOut) do 
			for yLabel, Data in pairs(Contents) do 
				local NewPlot = Plotter:New();
				NewPlot:SetData("xlabel", xLabel, true) -- Create a new plot. 
				NewPlot:SetData("ylabel", yLabel);
				NewPlot:SetData("xdata", Data.x);
				NewPlot:SetData("ydata", Data.y);
				NewPlot:SetData("title", yLabel .. " vs " .. xLabel)
				NewPlot:Plot(yLabel.."vs"..xLabel..".png")
			end 
		end 

	elseif SweepMode == "Metropolis" then  

	end


end 


return Model 