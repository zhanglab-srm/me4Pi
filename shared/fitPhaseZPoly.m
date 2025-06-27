function [resultp, resultz, dz, lp, resnormx, dp] = fitPhaseZPoly(z,p,lp0)
%   fitPhaseZ
%   solve the equation: p = z*lp(1) + lp(2)
%     z = zdata(tm);
%     p = smInfo(tm,5);
    if nargin <3 || isempty(lp0)    %use default parameter
        lp0 = [-0.02, 0,0,0,0];
    end

    options = optimset('Display','off','MaxFunEvals',2000,'MaxIter',1000,'TolFun',1e-9,'LargeScale','on');
    [lpx,resnormx,~,~]=lsqcurvefit(@(xp, xdata)CalPhaseZSinPoly(xp, xdata), ...
        lp0,z,[sin(p) cos(p)],[],[],options);

    lp = lpx;
    lp(2) = checkPhase(lp(2));

    resultp = CalPhaseZPoly(lp, z);
    dp = checkPhase(p-resultp); %diff of phase
%     dp(dp<-pi) = dp(dp<-pi) + 2*pi;
%     dp(dp>pi) = dp(dp>pi) - 2*pi;

    dz = dp/lp(1);
    resultz = z + dz; % correction with phase

end