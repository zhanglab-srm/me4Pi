%% load and reg images
clear
clc

mainfolder = 'G:\20250120';
filefolder = [mainfolder,'\','Cell01'];
files = dir([filefolder,'\','*.dcimg']);
mat_out_path = [mainfolder, '\', 'zcaliData_', datestr(now,'yyyymmdd'), '.mat'];

%%
Im=[];
for i=1:length(files)
    filestr=[filefolder,'\',files(i).name];
    [Im(:,:,i),~] = me4Pi_readdcimg(filestr);
end

%%
% Im=FastTiff(filestr);
% Im=Im(:,:,91:450);
sz = size(Im,1);
imglen = size(Im,3);
step = 10;   %nm
zlist = (1:imglen)*step;
zlist = zlist';

%% get one beads
figure('Position',[800 100 1200 1200]);
imagesc(mean(Im,3));

tp = ginput(1);
hold on
plot(tp(1), tp(2),'r+');
hold off

windowsize = 21;
halfWindowSize = (windowsize-1)/2;
cx = round(tp(1));
cy = round(tp(2));
cxs = cx - halfWindowSize;
cxe = cx + halfWindowSize;
cys = cy - halfWindowSize;
cye = cy + halfWindowSize;
imgbuf_all = Im(cys:cye,cxs:cxe,:);

[P,CRLB,LL] = mleFit_LM(single(imgbuf_all),4,50,2,0,1,0);
P=double(P);

%% post process of astigmatism 
% with wx-wy
% wxlist = P(:,5);
% wylist = P(:,6);

%%
wxlist = P(:,5);
wylist = P(:,6);
wxyrlist = wxlist-wylist;

zcali_N = 3;
zcali_pz2w = polyfit (zlist, wxyrlist, zcali_N);
zcali_pw2z = polyfit (wxyrlist, zlist, zcali_N);
wxyrfit = polyval(zcali_pz2w, zlist);
zfit = polyval(zcali_pw2z, wxyrlist);
% wxyrfit = zlist*a(1) + a(2);

% with wx and wy
zrange = [min(zlist)-100, max(zlist)+100]; %range of z
zcali_wxy_N = 3;
zcali_pz2wx = polyfit (zlist, wxlist, zcali_wxy_N);
zcali_pz2wy = polyfit (zlist, wylist, zcali_wxy_N);
wxfit = polyval(zcali_pz2wx, zlist);
wyfit = polyval(zcali_pz2wy, zlist);
retz = fitZwithWXY(double(wxlist), double(wylist), double(zcali_pz2wx), double(zcali_pz2wy), zrange);

figure(2)
subplot(3,1,1);
plot(zlist,wxlist, 'b.');
hold on
plot(zlist,wylist, 'g.');
plot(zlist,wxfit, 'b');
plot(zlist,wyfit, 'g');
hold off
title('wx and wy vs Z')

subplot(3,1,2);
plot(zlist, retz, '.');
hold on
plot(zlist,zlist);
hold off

title('Z vs retz')

subplot(3,1,3);
histogram(zlist - retz);
title('Z - retz')

%% save to 
pcycle = 210;
save(mat_out_path,'zcali_N', 'zcali_pz2w', 'zcali_pw2z', 'zlist', 'zrange', ...
        'zcali_wxy_N', 'zcali_pz2wx', 'zcali_pz2wy', 'wxlist', 'wylist','pcycle');