clear
clc
close all

mainfolder = 'E:\me4Pi_test';
filebase='Cell08';
filefolder = [mainfolder,'\',filebase];
filelist = dir([filefolder,'\', '*.dcimg']);
zcaliData = 'E:\me4Pi_test\zcaliData_20250120.mat';
imgpath_prefix = [filefolder,'\',filebase];
ztype=1; % 1 for rose-z, 0 for astz

%% make opt
opt = [];
opt.detThreshold = 4;
opt.substractBkg = 0;           %substrack background
opt.subimgsize = 11;
opt.offset = 400;
opt.gain = 0.24;
opt.llr = 350;                  % log-likelihood ratio
opt.crlb = 0.10;                % crlb
opt.photon = 1000;              % minimun photon 
opt.md = 0.6;                   % modulation contrast

%% Process files and save fitting results
filenumber = len(filelist);
cframe = 0;
cidx = 0;
fitresult = [];
smInfo = [];
for m=1:filenumber
    filename = filelist(m).name;
    disp(['Processing File: ', filename]);
    filestr = [filefolder,'\',filename];
    % filestr = filelist;
    [fitresult_tmp,smInfo_tmp,num_images]=ProcessImgFile4b_v3(filestr, m, opt, imgpath_prefix);

        % change frame, idx
    smInfo_tmp(:,3) = smInfo_tmp(:,3) + cframe;
    smInfo_tmp(:,7) = smInfo_tmp(:,7) + cidx;
    
    % merge results
    fitresult = cat(1, fitresult, fitresult_tmp);
    smInfo = cat(1, smInfo, smInfo_tmp);

    cframe = cframe + num_images;
    cidx = cidx + size(fitresult_tmp, 1);
end

%% calculate Z data with Astigmatizm
[zdata, zrange] = CalZwithAst(smInfo(:,10), smInfo(:,11),zcaliData);

%% save the results
isMultiColor = 0; % a flag of multi color
save([imgpath_prefix '_fitresult.mat'], ...
    'filename','fitresult','smInfo','opt','filelist','isMultiColor', ...
    'zdata','zrange' ...
    ,'-v7.3');

%% display smInfo
mask = smInfo(:,7);
figure(2);
subplot(2,2,1);
hist(smInfo(:,4),100);
title(sprintf('Photons, %d, %d', round(mean(smInfo(:,4))), round(median(smInfo(:,4)))));

subplot(2,2,2);
hist(smInfo(:,6),100);
title(sprintf('MD mean:%0.3f, std = %0.3f',mean(smInfo(:,6)), std(smInfo(:,6))));

subplot(2,2,3);
hist(fitresult(mask,3)./fitresult(mask,4),100);
title('wxyRatio');

subplot(2,2,4);
hist(zdata,100);
title('z');

str=strcat([filefolder,'\'],filebase,'_fitresult.jpg');
saveas(gcf, str);

%% do post processing
% fit phase plane for resultz
stopval1=0.05; %dmap
num_images=1000;
run_FitWholeImageTestPoly_v2
    
% save result to file
save([imgpath_prefix '_fitZresult.mat'], 'filename','smInfo_new','smInfo_final');

%% Drift correction
finalx = smInfo_final(:,1);
finaly = smInfo_final(:,2);
finalz = smInfo_final(:,12);
astz = smInfo_final(:,14);

driftstr=[imgpath_prefix,'_drift.mat'];
num_images=1000;
pixelsz=117;
crlbout=smInfo_final(:,8);
crlbout(:,2)=crlbout(:,1);
[xout2,yout2,zout2,shifts]=W4PiSMS_driftcorrection_DME(smInfo_final(:,1),smInfo_final(:,2),finalz,smInfo_final(:,3),num_images,pixelsz,crlbout,driftstr,2,10);

%% save file
N=length(xout2);
vutarax=xout2;
vutaray=yout2;
vutaraz=-zout2;
vutarat=smInfo_final(:,3);
vutaraI=smInfo_final(:,4);
vutaracrlb=smInfo_final(:,8);
vutarall=smInfo_final(:,9);
vutarabg=zeros(N,1);
vutaramdc=smInfo_final(:,6);
vutarazerr=smInfo_final(:,13);
[flag]=W4PiSMS2vutarav2([filefolder,'\'],filebase,1,{vutarax},{vutaray},{vutaraz},{floor(vutarat/100)},{vutaraI},{vutaracrlb},{vutarall},{vutarabg},{vutaramdc},{vutarazerr});
str=strcat([filefolder,'\'],filebase,'_DCresult.mat');
save(str,'vutarax','vutaray','vutaraz','vutarat','vutaraI','vutarall','vutarabg','vutaracrlb','vutaramdc','vutarazerr','shifts');

%% output images
sz=192;
zm=12;
histim=cHistRecon(sz*zm,sz*zm,yout2/10,xout2/10,0);
gaussim=gaussf(histim,[1 1]);
str1=strcat([filefolder,'\'],filebase,'_dot_dc_',num2str(zm),'.tif');
str2=strcat([filefolder,'\'],filebase,'_gauss_dc_',num2str(zm),'.tif');
dipsetpref('FileWriteWarning','off')
writeim(histim,str1,'tiff',1);
writeim(gaussim,str2,'tiff',1);

% 3D stack image
bin=50;
zm=4;
zout2=zout2-min(zout2);
segnum=ceil(max(zout2)/bin);
Im=single(zeros(ceil(sz*zm),ceil(sz*zm),segnum));
for i=1:segnum
    st=bin*(i-1);
    et=bin*i;
    id=zout2>st & zout2<et;
    xnew=xout2(id);
    ynew=yout2(id);
    Im(:,:,i)=cHistRecon(sz*zm,sz*zm,ynew/20,xnew/20,0);
end
gaussim=gaussf(Im,[0.5 0.5 0]);
gaussim=dip_array(gaussim);
gaussim=uint16(gaussim/max(gaussim(:))*65535);

str2=strcat([filefolder,'\'],filebase,'_gauss_3D_dc_',num2str(zm),'.tif');
tiffwrite(gaussim,str2);

% color coded image
zm=12;
[rch,gch,bch]=srhist_color(sz,zm,yout2/pixelsz,xout2/pixelsz,max(zout2)-zout2,segnum);
rchsm=gaussf(rch,1);
gchsm=gaussf(gch,1);
bchsm=gaussf(bch,1);
max_chsm=max([ceil(max(rchsm)),ceil(max(gchsm)),ceil(max(bchsm))]);
max_chsm=min(max_chsm,255);
rchsmst=imstretch_linear(rchsm,0,max_chsm,0,1000);
gchsmst=imstretch_linear(gchsm,0,max_chsm,0,1000);
bchsmst=imstretch_linear(bchsm,0,max_chsm,0,1000);
colorim=joinchannels('RGB',rchsmst,gchsmst,bchsmst);
str3=strcat([filefolder,'\'],filebase,'_3D_colorim_dc_',num2str(zm),'.tif');
writeim(colorim,str3,'TIFF');
