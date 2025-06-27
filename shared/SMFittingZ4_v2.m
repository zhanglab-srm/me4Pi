function [fitresult, smInfo] = SMFittingZ4_v2(imgbuf1, imgbuf2,imgbuf3, imgbuf4, tlz, locmaxc, opt)
% [fitresult, smInfo] = SMFittingZ4(imgbuf1, imgbuf2,imgbuf3, imgbuf4, detfile, opt)
% fitresult: [x y wx wy int1 int2 int3 int4 bkg1 bkg2 bkg3 bkg4]
%            [1 2  3  4  5    6    7    8    9    10   11    12]
%
% smInfo: [x y frame ptn phase1  md1  idx   ptn_demix]
%         [1 2   3    4    5      6   7         8    ]

%% subimg
% [subimgbuf, subimginfo, subsum] = makeSubimg4(imgbuf1, imgbuf2, imgbuf3, imgbuf4, detectResult, opt.subimgsize);
[subims1,t,l]=cMakeSubregions(locmaxc(:,2),locmaxc(:,1),locmaxc(:,3),opt.subimgsize,single(permute(imgbuf1,[1 2 3])));
[subims2,t,l]=cMakeSubregions(locmaxc(:,2),locmaxc(:,1),locmaxc(:,3),opt.subimgsize,single(permute(imgbuf2,[1 2 3])));
[subims3,t,l]=cMakeSubregions(locmaxc(:,2),locmaxc(:,1),locmaxc(:,3),opt.subimgsize,single(permute(imgbuf3,[1 2 3])));
subims4=subims3;
subsum=subims1+subims2+subims3;
N=length(t);
subimgbuf=zeros(opt.subimgsize,opt.subimgsize,4,N);
subimgbuf(:,:,1,:)=subims1;
subimgbuf(:,:,2,:)=subims2;
subimgbuf(:,:,3,:)=subims3;
subimgbuf(:,:,4,:)=subims4;

%% fitting sub images
%result:    [x y wx wy int1 int2 int3 int4 bkg1 bkg2 bkg3 bkg4 exitflag]
%           [1 2  3  4  5    6    7     8    9    10   11   12    13]
% fitresult = fit3Gauss_mp(subimgbuf);
[fitresult, states] = fitGauss4GPU_new(subimgbuf);

r=(size(subsum,1)-1)/2;
[P,CRLB,LL]=mleFit_LM(single(subsum),4,100,1.5,0,1,0);
llr=-2*LL;
crlb=sqrt((CRLB(:,1)+CRLB(:,2))/2);
cy=P(:,1)+tlz(:,1);
cx=P(:,2)+tlz(:,2);
mask1=abs(P(:,1)-r)<2 & abs(P(:,2)-r)<2;

%% post process
%smInfo
%[x y frame int p1 md1]
%
phase0 = 120/180*pi;

subimgcnt = size(subimgbuf, 4);
phasedata = zeros(subimgcnt, 4); %[phase1 md1 amp1 offset1]
for m=1:subimgcnt
    intlist = fitresult(m,5:7);
    [phase1, amp1, offset1] = MyCalPhase3_new(intlist(1:3), phase0);
    phasedata(m,:) = [phase1, amp1/offset1, amp1, offset1];
end

subimginfo = locmaxc;
smInfo = zeros(subimgcnt, 11); 
%[x y frame ptn phase1  md1  idx   crlb llr sx sy]
%[1 2   3    4    5      6   7       8   9  10 11]
% smInfo(:,1) = fitresult(:,1) + subimginfo(:,1);
% smInfo(:,2) = fitresult(:,2) + subimginfo(:,2);
smInfo(:,1) = cx;
smInfo(:,2) = cy;
smInfo(:,3) = subimginfo(:,3);
smInfo(:,4) = P(:,3);
smInfo(:,5:6) = phasedata(:,1:2);
smInfo(:,7) = 1:subimgcnt;
smInfo(:,8) = crlb;
smInfo(:,9) = llr;
smInfo(:,10) = P(:,5);
smInfo(:,11) = P(:,6);

% smInfo(:,12) = cspline.z;

intlist=fitresult(:,5:12);
mask7=all(intlist>0,2);

% mask1 = abs(fitresult(:,1))<2 & abs(fitresult(:,2))<2;
mask2 = fitresult(:,3)>0.5 & fitresult(:,3)<4.5 & fitresult(:,4)>0.5 & fitresult(:,4)<4.5;
mask3 = smInfo(:,4)>opt.photon & smInfo(:,4)<10^6;
mask4 = smInfo(:,6)>opt.md & smInfo(:,6)<1.3;   % modulation contrast
mask5 = smInfo(:,8)<opt.crlb & smInfo(:,8)>0;     % crlb
mask6 = smInfo(:,9)<opt.llr;                                % llr
smInfomask = mask1 & mask2 & mask3 & mask4 & mask5 & mask6 & mask7;
smInfo = smInfo(smInfomask, :);
disp(sprintf('SMFitting: mask: %0.2f%% (%d/%d)', sum(smInfomask)/len(smInfomask)*100, sum(smInfomask), len(smInfomask)));