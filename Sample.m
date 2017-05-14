
function Sample()

Field = -1;
J = 1; % coupling
Tc = (2*J)/(log(1+sqrt(2)));
Temperature = (Tc-0.1):0.001:(Tc+0.1);

Field = linspace(Field,-Field,length(Temperature));



Neighbours = 4;

Data = [];

function data(spin)
    Tindex=0;
for T = Temperature;
    Tindex=Tindex+1;
    for index=0:(Neighbours)
        U = GetU(index,Neighbours-index,spin,Field(Tindex),J);
  
        chance = exp(-U/T);
        if chance > 1
            chance = 1;
        end
        if index==0
            if T==Temperature(1)
                Data(index+1,1) = chance;
            else
                Data(index+1,end+1) = chance;
            end
        else
            if T == Temperature(1)
                Data(index+1,1) = chance;
            else
                Data(index+1, end) = chance;
            end
        end
    end
end
end


figure
hold on
title('Flip from down to up')
legend_data = {};

for i=1:(Neighbours+1)
    legend_data{i} = strcat(num2str(i-1), ' neighbours up and,', num2str(Neighbours-i+1), ' neighbours down');
end

data(-1)
rows = size(Data,1);
for row = 1:rows
    plot(Temperature, Data(row,:));
end
legend(legend_data)

dump=Data;

Data=[];
figure
hold on

data(1)
title('Flip from up to down')
rows = size(Data,1);
for row = 1:rows
    plot(Temperature, Data(row,:));
end

legend(legend_data)

end