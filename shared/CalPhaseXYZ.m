function result = CalPhaseXYZ(lp, xdata)
%lp: (theta, cycle, phase)
cycle = lp(1);
phase = lp(2);
px = lp(3);
py = lp(4);
% pxx = lp(5);
% pxy = lp(6);
% pyy = lp(7);

ret = xdata(:,3) * cycle + phase + ...
    xdata(:,1).*px + xdata(:,2).*py;
%     xdata(:,1).*xdata(:,1).*pxx + xdata(:,1).*xdata(:,2).*pxy + xdata(:,2).*xdata(:,2).*pyy;

result = checkPhase(ret);
end