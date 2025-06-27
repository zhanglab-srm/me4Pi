function result = CalPhaseXYZSin(lp, xdata)
% fit phase plane with x,y,z, x-y in 1 order
% lp: (cycle, phase, x,y,xx,xy,yy)
% phase = lp(1)*z + lp(2) + lp(3)*x + lp(4)*y + lp5*x^2 + lp6*xy + lp7*y^2
%
ret = CalPhaseXYZ(lp, xdata);
result = [sin(ret) cos(ret)];


end