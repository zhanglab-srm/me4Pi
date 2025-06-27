function resultz = PhaseZCorrection(z,lp,destlp, polyorder)
if nargin<3 || isempty(destlp) 
    destlp = [-0.0255 0.5];
end

if nargin<4 || isempty(polyorder) 
    polyorder = 5;
end
z=z./1000;

tz = z*lp(1)+lp(2)+z.^polyorder*lp(3);
tz0 = checkPhase(destlp(2)*lp(1)+lp(2)+destlp(2).^polyorder*lp(3)); %tz|z=0.5

resultz = (tz+tz0-0.5)./destlp(1);
