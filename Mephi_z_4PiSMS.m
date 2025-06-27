function [zest zerr zmask]=Mephi_z_4PiSMS(zangresult,mtcresult,tresult,fnum,mephiBin,stopval,centermtc,freq, imgpath_prefix)
% setup
stopval0=stopval;
msz=256; 
srange=[0.4 0.6];
maxangle=0.2;
lambda=680;
Nmedia=1.33;
sigma=5;

fnum = fnum*mephiBin;
segnum=ceil((max(tresult))/fnum);
zest=[];
zerr=[];
zmask=[];
h=figure(4);

ii =1;
while ii<=segnum
    st=(ii-1)*fnum;
    if ii==segnum
        ed=max(tresult);
    else
        ed=(ii)*fnum-1;
    end
    
    maskt=tresult>=st&tresult<=ed;
    mtc_seg=mtcresult(maskt);
    zang_seg=zangresult(maskt);
    [dmap]=build_dmap(mtc_seg,zang_seg,msz,sigma);
    dmap=dmap/max(dmap(:));
    dipshow(h,dmap,'lin');
    hold on
    [mephi_ini,cpeak]=find_mephi_ini(dmap,srange,msz);
    
try
    if stopval0==0
        [mephi,uwmephi,mephipp]=find_mephi(dmap,mephi_ini,maxangle,srange,0);
        I=mephi(:,3);
        N=length(I);
        xx=(1:N)';
        inis=[max(I), length(I)/2, 5];
        [c]=fit1dgaussian(I,xx,inis);
        figure(6);plot(xx,I,'b-'); hold on
        Fy = c(1).* exp(-(xx-c(2)).^2./2./c(3)./c(3))+c(4);
        plot(xx,Fy,'r-');hold off
        if c(2)<N/2
            stopval=max(I(min(round(c(2)+2*c(3)),N)),Fy(min(round(c(2)+2*c(3)),N)));
        else
            stopval=max(I(max(round(c(2)-2*c(3)),1)),Fy(max(round(c(2)-2*c(3)),1)));
        end
        stopval
        stopval=min(stopval,0.20);
        stopval=max(stopval,0.05);       
    end
    [mephi,uwmephi,mephipp]=find_mephi(dmap,mephi_ini,maxangle,srange,stopval);
catch
    keyboard
end
    [zest_f,zerr_f,mephimask]=mephi_zest(mephipp,uwmephi,mtc_seg,zang_seg,lambda,Nmedia,centermtc,freq);

    zest=cat(1,zest,zest_f(:));
    zerr=cat(1,zerr,zerr_f(:));
    zmask=cat(1,zmask,mephimask(:));
    
    mep1=(mephi(:,1)+pi).*msz./2./pi;
    mep2=(mephi(:,2)+pi).*msz./2./pi;
    figure(4);scatter(mep1,mep2,'r')

%     figure; hold on;plot(-mtc_seg,zang_seg,'b.'); axis([-pi pi -pi pi]);
%     scatter(-mephi(:,1),mephi(:,2),'r'); axis square

    %% added 0329, for saving dmap with circles
%     if mod(ii,10)==1
%         saveas(gcf, [imgpath_prefix '_dmap_addtional_' num2str(ii) '.png'])
%     end
%     hold off
%     pause(eps)
    ii = ii+1;   
end
  