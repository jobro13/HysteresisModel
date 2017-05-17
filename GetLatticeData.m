function Lattice = GetLatticeData(fname )
%GETLATTICEDATA Returns a Lattice cell:
% Lattice{t} returns the lattice matrix at time t (this is the t-th saved
% lattice in the file)
% Lattice Cells are used to pass to other functions, for example, to
% visualizing functions.

Lattice = {};

% Get lattice size from file.
M = csvread(fname, 0,0, [0,0,0,2]);
X = M[1];
Y = M[2];
Z = M[3];

D = csvread(fname,1,0);

for r = 1:size(D,1)
    Lattice{r} = zeros(X,Y,Z);
    i = 0;
    for x=1:X
        for y=1:Y
            for z=1:Z
               i = i +1;
               Lattice{r}(x,y,z) = D(i);
            end
        end
    end
end


end

