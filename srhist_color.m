function [rch gch bch]=srhist_color(sz,zm,xtot,ytot,ttot,segnum,colorstring)
% [rch gch bch]=srhist_color(sz,zm,xtot,ytot,ttot,segnum,colorstring)
if nargin<7
    colorstring='jet';
end
ttot=ttot(1:size(xtot,1));
eval(['a=colormap(' colorstring '(segnum));']);
% close all
incre=floor((max(ttot)-min(ttot)+1)/segnum);
for ii=1:1:segnum
    tst=(ii-1)*incre+min(ttot);
    if ii==segnum
        ted=max(ttot);
    else
        ted=ii*incre++min(ttot);
    end
    
    mask=ttot>=tst&ttot<=ted;
    xtmp=xtot(mask);
    ytmp=ytot(mask);
    
    tmpim=SRreconstructhist(sz,zm,xtmp,ytmp);
    tmpim=double(tmpim);
    if ii==1
        rch=a(ii,1)*tmpim;
        gch=a(ii,2)*tmpim;
        bch=a(ii,3)*tmpim;
    else
        rch=rch+a(ii,1)*tmpim;
        gch=gch+a(ii,2)*tmpim;
        bch=bch+a(ii,3)*tmpim;
    end
end
