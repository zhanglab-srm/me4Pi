function [fitresult, smInfo,num_images]=ProcessImgFile4b_v3(filename, filenumber, opt, imgpath_prefix)
    
    % temp = strfind(filename,'\');
    % imgpath = filename(1:temp(end));
    % 
    % imgpath_prefix = filename(1:end-6);
    % 
    %% check if result exist
    % if autoskip >0 && exist([imgpath_prefix '_fitting.mat'], 'file')
    %     return;
    % end
    % 
    %% duplicate and registration of images
    % Im = FastTiff(filename);
    [Im,~] = me4Pi_readdcimg(filename);
    Im = (Im-opt.offset)*opt.gain;

    N = size(Im,3);
    id=1:3:N;
    imgbuf1 = Im(:,:,id);
    id=2:3:N;
    imgbuf2b = Im(:,:,id);
    id=3:3:N;
    imgbuf3b = Im(:,:,id);
    imgbuf4b = imgbuf3b;
    num_images = N/3;
    
    %% detection
%     imgfilename_sum = [filename(1:end-4) '_outsum.tif'];
    imgbuf_sum = imgbuf1 + imgbuf2b + imgbuf3b;
    [subims,tlz,locmaxc]=single_molecue_detection(imgbuf_sum,opt.detThreshold,opt.subimgsize);

    f=100;
    id=locmaxc(:,3)==f-1;
    V=locmaxc(id,:)+1;
    close all
    figure;imshow(imgbuf_sum(:,:,f),[],'InitialMagnification',250);hold on;plot(V(:,1),V(:,2),'bo');pause(1)

    % detectResult = SMDetection(imgbuf_sum, detThreshold, opt.subimgsize, [], [imgpath_prefix '_Detection.mat']);

    if filenumber==1
        imgfilename_sum = [imgpath_prefix,'_outsum.tif'];
        if ~exist(imgfilename_sum,"file")
            tiffwrite(uint16(imgbuf_sum),imgfilename_sum,[1 3000]);
        end
    end

    %% fitting
    % imglist{3} = [imgpath_prefix '_out3.tif'];

    % fitresult: [x y wx wy int1 int2 int3 int4 bkg1 bkg2 bkg3 bkg4]
    %            [1 2  3  4  5    6    7    8    9    10   11    12]
    %
    % smInfo: [x y frame ptn phase1  md1  idx   ptn_demix]
    %         [1 2   3    4    5      6   7         8    ]
    [fitresult, smInfo] = SMFittingZ4_v2(imgbuf1, imgbuf2b, imgbuf3b, imgbuf4b, tlz, locmaxc, opt);

%     [fitresult2, smInfo2] = SMFittingZ4(imgbuf1+imgbuf2b+imgbuf3b, imgbuf4b, imgbuf1+imgbuf2b+imgbuf3b, detectResult, opt);
   
    %% save fitting results
    % isMultiColor = 0; % a flag of multi color
    % imgsize = size(imgbuf1);
    % fitfilepath = [imgpath_prefix '_fitting.mat'];
    % save(fitfilepath, 'fitresult', 'smInfo', 'filename', 'isMultiColor', 'imgsize');
end