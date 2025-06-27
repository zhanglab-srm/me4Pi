function result = CalPhaseZPoly(lp, z)
%lp: (theta, cycle, phase)
cycle = lp(1);
phase = lp(2);
cycle2 = lp(3);


ret = z * cycle + phase + z.^5 * cycle2;
result = checkPhase(ret);
end