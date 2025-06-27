function [ims,qds]=me4Pi_readdcimg(filename,center,sz)

files=dir(filename);
if numel(files)>1
    error('Multiple files with the same assigned name are detected');
elseif numel(files)==0
    error('No file detected');
end

% [im,totalframes] = dcimgmatlab(0,filename);
% ims = single(zeros(size(im,1),size(im,2),totalframes));

obj=dcimgReaderMatlab(filename);
ims=single(zeros(obj.metadata.num_rows,obj.metadata.num_columns,obj.metadata.num_frames));
totalframes=obj.metadata.num_frames;

cutflag=0;
qds=[];
if nargin>1
    cutflag=1;
end

for ii=1:1:totalframes
%         ims(:,:,ii) = dcimgmatlab(ii-1,filename)';
    ims(:,:,ii) = getSpecificFrames(obj, ii)';
end

clear mex
