local gp = require 'lgnuplot'

local Plotter = {};

function Plotter:New();
	return setmetatable({gp = gp{}, DBins = {}}, {__index=self});-- __newindex = self.Set});
end 

local valid = {
	xlabel = true;
	ylabel = true;

}

function Plotter:Set(index, value)
	gp[index]=value;
end 

function Plotter:SetData(dname, data, new_dbin)

	if not self.DBins then 
		self.DBins = {};
	end 

	local using 
	if new_dbin or #self.DBins == 0 then 
		table.insert(self.DBins, {});	
		using = self.DBins[#self.DBins] 
	else
		using = self.DBins[#self.DBins]
	end;

	if dname == "xdata" then 
		if not using[1] then using[1] = {} end ;
		using[1][1] = data;
	elseif dname == "ydata" then 
		if not using[1] then using[1] = {} end ;
		using[1][2] = data;
	else
		using[dname] = data;
	end  
end 

function Plotter:Plot(fname)
	self.gp.width = self.gp.width or 640;
	self.gp.height = self.gp.height or 480;
	self.gp.xlabel = self.gp.xlabel or "X axis";
	self.gp.ylabel = self.gp.ylabel or "Y axis";
	self.gp.key = self.gp.key or "top left";
	self.gp.terminal = self.gp.terminal or "png"

	-- build data.
	local d = {} 
	for _, data in pairs(self.DBins or {}) do 
		if not data.using then
			data.using = {1,2}
		end 
		if not data.with then data.with = "linespoints" end
		if not data.title then data.title = "Title" end
		print(data)

		for ind, val in pairs(data) do print(ind, val) if type(val) == "table" then for i,v in pairs(val) do print("\t", i,v) end end end 

		table.insert(d, gp.array(data));
	end 
	self.gp.data = d;

	self.gp:plot(fname)
end 

return Plotter 