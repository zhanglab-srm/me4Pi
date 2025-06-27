function resultp = PhaseXYCorrection(p, lp, x, y, pos0)
if nargin<5
    pos0 = [0 0];
end
cycle = lp(1);
phase = lp(2);
px = lp(3);
py = lp(4);

p0 = pos0(1)*px+pos0(2)*py;
dp = x*px+y*py-p0;

resultp = p - dp;