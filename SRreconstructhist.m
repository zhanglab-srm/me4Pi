function [srhistim]=SRreconstructhist(sz,zm,xtotf,ytotf,equal)
%[imtot]=SRreconstructhist(sz,zm,xtotf,ytotf)
maxblob=250000;
maxk=ceil(size(xtotf,1)/maxblob);
if nargin<5
    equal=0;
end
imszzm=ceil(sz*zm);
imtemp=zeros(imszzm,imszzm);
for ii=1:1:maxk
    bst=(ii-1)*maxblob+1;
    if ii==maxk
        bed=size(xtotf,1);
    else
        bed=(ii)*maxblob;
    end
    
    xresult2=xtotf(bst:bed);
    yresult2=ytotf(bst:bed);
        
    SRim=cHistRecon(single(imszzm),single(imszzm),single(xresult2.*zm),single(yresult2.*zm),equal);
    if ii==1
        imtemp=SRim;
    else
        imtemp=imtemp+SRim;
    end
end
srhistim=imtemp;
