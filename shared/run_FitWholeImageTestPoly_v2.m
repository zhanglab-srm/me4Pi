%%
sx = smInfo(:,10);
sy = smInfo(:,11);
mtc = (sx.^3./sy-sy.^3./sx)./40*2*pi;
mtc = mtc-mean(mtc);
ix = abs(mtc)<(3*pi);
mtc = mtc/std(mtc(ix,:))*pi/4;

maskmtc = mtc<pi & mtc>-pi & (sx+sy)<6;

%%
doXYcorr=1;
if doXYcorr
    str=[imgpath_prefix,'_pmap.mat'];
    if exist(str,'file')
        load(str);
        lp0=lp;
    else
        lp0=0;
    end
    currx=smInfo(maskmtc,1);
    curry=smInfo(maskmtc,2);
    currzang=smInfo(maskmtc,5);
    currzfresult=mtc(maskmtc);
    currt=smInfo(maskmtc,3);
    currI=smInfo(maskmtc,4);
    currcrlb=smInfo(maskmtc,8);
    [currzang_cor,lp,doXYcorr] = phaseCorrection_v3(currx,curry,currzang,currzfresult,currI,currcrlb,currt,num_images,lp0,doXYcorr);
    save(str,'lp');
end

%%
smInfo_new=smInfo(maskmtc,:);
smInfo_new(:,12:13)=0;
smInfo_new(:,14)=zdata(maskmtc,:);
% smInfo_new(:,15)=smInfo(maskmtc,12);
tresult=smInfo_new(:,3); 
mtcresult=mtc(maskmtc);
if doXYcorr
    zangresult=currzang_cor; 
else
    zangresult=smInfo_new(:,5); 
end

%%
segnum=ceil((max(tresult))/num_images);
zest=[];
zerr=[];
zmask=[];
Dmap0=[];
Dmap=[];
for ii=1:1:segnum
%     close all
    st=(ii-1)*num_images;
    if ii==segnum
        ed=max(tresult);
    else
        ed=(ii)*num_images-1;
    end
    maskt=tresult>=st&tresult<=ed;
    mtc_seg=mtcresult(maskt);
    zang_seg=zangresult(maskt);
    [dmap]=build_dmap(mtc_seg,zang_seg,256,5);
    Dmap(:,:,ii)=dmap/max(dmap(:));
end
str=[imgpath_prefix,'_dmap.tif'];
tiffwrite(Dmap*10000,str);

%%
centermtc=[];
P=load(zcaliData);
freq=2*pi/P.pcycle;  
currzang=zangresult;
currmtc=mtcresult;
currt=tresult;
mephiBin=1;
[currzresult,z_err,mephimask]=Mephi_z_4PiSMS(currzang,currmtc,currt,num_images,mephiBin,stopval1,centermtc,freq, imgpath_prefix);
maskzerr=z_err<60;
maskall=maskzerr&(mephimask>0)&abs(currzresult)<700;
smInfo_new(:,12)=currzresult;
smInfo_new(:,13)=z_err;
smInfo_final=smInfo_new(maskall,:);
