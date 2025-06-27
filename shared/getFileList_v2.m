function filelist = getFileList_v2(filepath)
% filelist = getFileList(filepath)
% get file list of a imge series
% file name like: cell01.dcimg ..
%
fileprefix = filepath(1:end-5);
filecnt = 1;
while(1)
    tfilecnt = filecnt+1;
    tfilename = sprintf('%s_X%d.dcimg',fileprefix,tfilecnt); 
    if exist(tfilename, 'file')
        filecnt = tfilecnt;
    else
        break;
    end
end

filelist = cell(filecnt,1);
filelist{1} = filepath;
for m=2:filecnt
    filelist{m} = sprintf('%s_X%d.dcimg',fileprefix,m); 
end

end