function [resultp, lp, resnormx] = fitPhaseXYZ(x,y,z,p,lp0)
%   fitPhaseXY
% fit phase plane with x,y,z, x-y in 1 order
% lp: (cycle, phase, x,y)
% phase = lp(1)*z + lp(2) + lp(3)*x + lp(4)*y

    if nargin <5
        lp0 = [-0.020,0];
    end
    
    initpar = [lp0(1), lp0(2),0,0];

    options = optimset('Display','off','MaxFunEvals',1000,'MaxIter',100,'TolFun',1e-5,'LargeScale','on');
    [lpx,resnormx,~,~]=lsqcurvefit(@(xp, xdata)CalPhaseXYZSin(xp, xdata), ...
        initpar,[x,y,z],[sin(p) cos(p)],[],[],options);

    lp = lpx;

    resultp = CalPhaseXYZ(lp, [x,y,z]);
    
end