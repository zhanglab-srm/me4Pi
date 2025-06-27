function result = CalPhaseZSinPoly(lp, z)

ret = CalPhaseZPoly(lp, z);
result = [sin(ret) cos(ret)];


end