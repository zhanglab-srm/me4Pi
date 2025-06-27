function filelist = getFileList(filepath)
% filelist = getFileList(filepath)
% get file list of a imge series
% file name like: spool.tif, spool_X2.tif ..
%
fileprefix = filepath(1:end-4);
filecnt = 1;
while(1)
    tfilecnt = filecnt+1;
    tfilename = sprintf('%s_X%d.tif',fileprefix,tfilecnt); 
    if exist(tfilename, 'file')
        filecnt = tfilecnt;
    else
        break;
    end
end

filelist = cell(filecnt,1);
filelist{1} = filepath;
for m=2:filecnt
    filelist{m} = sprintf('%s_X%d.tif',fileprefix,m); 
end

end