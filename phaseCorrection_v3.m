function [currzang_cor, lp, doXYcorr] = phaseCorrection_v3(currx,curry,currzang,currzfresult,currI,currcrlb,currt,num_images,lp0,doXYcorr)

%% step1 phase tilt correction
%   XY + Z + p -> XY-drift ->Pcorr1
mask = currt<(num_images*12) & currI>2000 & currcrlb<0.06 & currx>12 & currx<180 & curry>12 & curry<180 ;
zd = double(currzfresult(mask));
pd = double(currzang(mask));
xd = double(currx(mask));
yd = double(curry(mask));

if lp0==0
    [resultp, lp, resnormx] = fitPhaseXYZ(xd,yd,zd,pd,[0.2,1,0,0]);
else
    lp=lp0;
end

% pd_corr = checkPhase(PhaseXYCorrection(pd, lp, xd, yd, [0 0]));
% resultp_corr = checkPhase(PhaseXYCorrection(resultp, lp, xd, yd, [0 0]));
pdata_corr1 = checkPhase(PhaseXYCorrection(currzang, lp, currx, curry, [0 0]));

% corr value threshold
maxXYcorr = 6;
[xx, yy] = meshgrid(1:192,1:192);
ret = PhaseXYCorrection(zeros(size(xx)), lp, xx, yy, [0 0]);
corrvalue = max(ret(:)) - min(ret(:))
if corrvalue > maxXYcorr
    disp('XY corr value too large, ingore XY correlation!');
    lp = [0.2,1,0,0];
    pdata_corr1 = currzang;
    doXYcorr = 0;
end
currzang_cor = pdata_corr1;

figure_flag = 1;
if figure_flag>0
    figure(3);
%     set(gcf,'position',[150,0,1200,800]);
%     subplot(2,2,1);
    imagesc(ret)
    colorbar
    if doXYcorr>0
        title('step1: XY corr');
    else
        title('step1: XY corr (SKIPPED)');
    end
end

%% step2 Z_ast nonlinear correction
%   Zpoly + Pcorr1 -> Zcorr1

% [resultp, resultz, dz, lp2, resnormx] = fitPhaseZPoly(zd/1000,pd,[-20,0,0]);
% 
% zdata_start=-100;
% zdata=currzfresult;
% resultz = PhaseZCorrection(zd,lp2) - PhaseZCorrection(zdata_start,lp2);
% zdata_corr1 = PhaseZCorrection(zdata,lp2) - PhaseZCorrection(zdata_start,lp2);
% 
% if figure_flag>0
%     ttm = rand(size(zd))<0.3; %limit the points
%     subplot(2,2,2);
%     plotPoints(zd(ttm),pd(ttm))
%     hold on
%     plotPoints(zd(ttm),resultp(ttm))
%     hold off
%     title('step2: Zast - Phase corr');
% end


end

