function [imgbuf1, imgbuf2b, imgbuf3b, imgbuf4b] = ...
    dupRegImages4(imgpath, matfile, outfile_prefix)

if nargin<2 || isempty(matfile)
    matfile = '..\PreProcess\RegInfo.mat';
end
if ischar(imgpath) %check if RegInfo.mat exist in the image path
    tpos = strfind(imgpath, '\');
    folderpath = imgpath(1:tpos(end));
    matfile_check = [folderpath 'RegInfo.mat'];
    if exist(matfile_check,'file')
        matfile = matfile_check;
        disp('RegInfo.mat exist.');
    else %if not exist, copy the RegInfo to the image path
        copyfile(matfile, matfile_check);
        disp('copy RegInfo.mat.');
    end
end
%% load parameters
temp = load(matfile);
roibuf = temp.roibuf;
tform2 = temp.tform2;
tform3 = temp.tform3;
tform4 = temp.tform4;

%% Load Images
if ischar(imgpath)
    imgbuf = LoadTiff16bit(imgpath);
else
    imgbuf = imgpath;
end
s = size(imgbuf);

imglen = size(imgbuf, 3);

%% make sub-images
imgbuf1 = imgbuf(roibuf(1,2):roibuf(1,4), roibuf(1,1):roibuf(1,3),:);
imgbuf2 = imgbuf(roibuf(2,2):roibuf(2,4), roibuf(2,1):roibuf(2,3),:);
imgbuf3 = imgbuf(roibuf(3,2):roibuf(3,4), roibuf(3,1):roibuf(3,3),:);
imgbuf4 = imgbuf(roibuf(4,2):roibuf(4,4), roibuf(4,1):roibuf(4,3),:);

clear imgbuf
%% Tranform images
% xdata = [1 size(imgbuf1,2)];
% ydata = [1 size(imgbuf1,1)];
imref = imref2d(size(imgbuf2(:,:,1)));

imgbuf2b = imwarp(imgbuf2, tform2,'OutputView',imref);
imgbuf3b = imwarp(imgbuf3, tform3,'OutputView',imref);
imgbuf4b = imwarp(imgbuf4, tform4,'OutputView',imref);

% imgbuf2b = zeros(size(imgbuf2));
% for m=1:imglen
% %     img2b = imwarp(img2, tform2,'OutputView',imref2d(size(img1)));
% %     imgbuf2b(:,:,m) = imtransform(imgbuf2(:,:,m), tform2,'XData',xdata,'YData',ydata);
%     imgbuf2b(:,:,m) = imwarp(imgbuf2(:,:,m), tform2,'OutputView',imref);
% end
% 
% imgbuf3b = zeros(size(imgbuf3));
% for m=1:imglen
% %     imgbuf3b(:,:,m) = imtransform(imgbuf3(:,:,m), tform3,'XData',xdata,'YData',ydata);
%     imgbuf3b(:,:,m) = imwarp(imgbuf3(:,:,m), tform3,'OutputView',imref);
% end

%% save images
if nargin >=3
    tiffwrite(imgbuf1, [outfile_prefix '1.tif']);
    tiffwrite(imgbuf2b, [outfile_prefix '2.tif']);
    tiffwrite(imgbuf3b, [outfile_prefix '3.tif']);
    tiffwrite(imgbuf4b, [outfile_prefix '4.tif']);
    tiffwrite(imgbuf1+imgbuf2b+imgbuf3b, [outfile_prefix 'sum.tif']);
end
