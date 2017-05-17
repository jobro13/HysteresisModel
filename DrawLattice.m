function  DrawLattice(Lattice,Z )
% 2d drawing. Z chooses a row.

if Lattice.SkipDraw
    return
end

if nargin < 2
    Z = 1;
end

clf;
hold on



for x=1:size(Lattice,1)
    for y = 1:size(Lattice,2)

        Spin = Lattice(x,y,Z);
        if Spin == 1
            FC = [0,0,0];
        else
            FC = [1,1,1];
        end
        rectangle('Position',[x-1,y-1,1,1],'FaceColor',FC,'LineStyle','none');
    end
end
       
axis([0 Lattice.SizeOf(1) 0 Lattice.SizeOf(2)]);
axis off;
pbaspect([1 1 1])
drawnow;
end

