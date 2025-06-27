function [fitresult, states] = fitGauss4GPU_new(subimgbuf, initstd)
%
%NEW 4 Gaussian fitting: x, y, wx, wy, int1-3, bkg1-3 use 3 Gaussian fitting
%
% fitting sub images with 3 Gaussian model
%result:    [x y wx wy int1 int2 int3 bkg1 bkg2 bkg3 exitflag]
%           [1 2  3  4  5    6    7     8    9    10   11   ]
% fitresult Gauss4
%result:    [x y wx wy int1 int2 int3 int4 bkg1 bkg2 bkg3 bkg4 exitflag]
%           [1 2  3  4  5    6    7    8    9    10   11   12    13]
if nargin<2
    [fitresult1, states1] = fitGauss3GPU(subimgbuf(:,:,1:3,:));
    [fitresult2, states] = fitGauss4GPU(subimgbuf);
else
    [fitresult1, states1] = fitGauss3GPU(subimgbuf(:,:,1:3,:), initstd);
    [fitresult2, states] = fitGauss4GPU(subimgbuf, initstd);
end
    fitresult = fitresult2;
    fitresult(:,1:7) = fitresult1(:,1:7);
    fitresult(:,9:11) = fitresult1(:,8:10);
end