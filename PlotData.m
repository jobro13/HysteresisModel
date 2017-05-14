function  PlotData( fname )
close all;
%Plot data from a lua-generated data file. The data file is generated with DataSet.lua
%The format is as following: 
% xlabel1 
% ylabel1 
% xlabel2 
% ylabel2
% Data:
% ... data x1 ..
% ... data y1 ..
% ... data x2 ..
% ... data y2 ..
% xlabel3 
% ylabel3
% ... data x3
% ... data y3 ..

if nargin < 1
    fname = 'RESULTS.csv';
end

C = textread(fname, '%s','delimiter', '\n');

linenum=0;
legendd={};
mode = 'legend';
data_plotx = [];
data_ploty = [];
target = 'x';

for current_line = 1:size(C,1)
    line = C{current_line};
    if not(strcmp('Data:',line));
        if strcmp(mode, 'legend')
            legendd{end+1} = line;
            linenum=linenum+1;
        else
            % Track how many lines were read.
            linenum = linenum-0.5;
            
            data_ = strsplit(line, ',');
           
            whos a
            data = [];
            length(data_)

            for i = 1:length(data_) 
                %mystr = strjoin(data_(i));
                
                data = [data, str2double(data_{i})];
    
            end
          
            
            if strcmp(target, 'x')
                insert = size(data_plotx,1)+1;
             
                data_plotx = data;
            else
                insert = size(data_plotx,1)+1;
     
                plot(data_plotx, data);
                data_plotx=[];
            end
            if strcmp(target, 'x');
                target = 'y';
            else
                target = 'x';
            end
            if linenum==0 

          
                legend(legendd)
                mode = 'legend';
                target = 'x';
                data_plotx = [];
                data_ploty = [];
                legendd = {};
            end
        end
    else
        mode = 'csvread';
        figure;
        hold on;
    end
end

end

