%%
clc
currentfolder='E:\me4Pi\20250218\new\Cell08\';
filename='Cell08_v7';
mask=vutarall<300 & vutaraI>1000 & vutaracrlb<0.10;
pixelsz=117;
currx=vutarax(mask)/pixelsz;
curry=vutaray(mask)/pixelsz;
currzresult=vutaraz(mask);
currt=vutarat(mask);
num_images=6000;
crlbxyz=vutaracrlb(mask);
crlbxyz(:,2)=crlbxyz(:,1);
driftstr=[currentfolder,filename,'.mat'];
[xout,yout,zout,shifts]=W4PiSMS_driftcorrection_DME(currx,curry,currzresult,currt,num_images,pixelsz,crlbxyz,driftstr,2,1);

%%
vutarax=xout;
vutaray=yout;
vutaraz=zout;
vutarat=vutarat(mask);
vutaraI=vutaraI(mask);
vutarall=vutarall(mask);
vutarabg=vutarabg(mask);
vutaracrlb=vutaracrlb(mask);
vutaramdc=vutaramdc(mask);
vutarazerr=vutarazerr(mask);
[flag]=W4PiSMS2vutarav2(currentfolder,[filename '_ll'],1,{vutarax},{vutaray},{vutaraz},{floor(vutarat/100)},{vutaraI},{vutaracrlb},{vutarall},{vutarabg},{vutaramdc},{vutarazerr});

str=[currentfolder,filename,'_DCresult.mat'];
save(str,'vutarax','vutaray','vutaraz','vutarat','vutaraI','vutarall','vutarabg','vutaracrlb','vutaramdc','vutarazerr','shifts','mask');


