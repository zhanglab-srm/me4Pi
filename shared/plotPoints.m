function plotPoints(x,y, msize)
%shortcut to plot with marker size
%
    if nargin<3
        msize=0.1;
    end
    plot(x,y,'.','markersize',msize);
end