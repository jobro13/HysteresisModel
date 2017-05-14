function result = GetU(neighbour_up, neighbour_down, self, field,J)
%GETU Summary of this function goes here
%   Detailed explanation goes here

Uint = 2*(neighbour_up-neighbour_down)*self*J;
Ufield = 2*field * self;
result = Uint + Ufield;

end

