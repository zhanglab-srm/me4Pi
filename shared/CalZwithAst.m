function [zdata, zrange] = CalZwithAst(wxlist, wylist, calidata)
%Calculate Z value with wx and wy with astigmatism
%zdata = CalZwithAst(wxlist, wylist, calidata)
%calidata: mat file path, default: ..\zcaliData.mat
%
    if nargin<3
        calidata = 'zcaliData.mat';
    end
    databuf = load(calidata);
    % wxyrlist = wxlist-wylist;
    % zdata = polyval(databuf.zcali_pw2z, wxyrlist);
    zrange = databuf.zrange;
    zrange_ext = zrange;
    zrange_ext(1) = zrange_ext(1)-200;
    zrange_ext(2) = zrange_ext(2)+200;
    zdata = fitZwithWXY(wxlist, wylist,databuf.zcali_pz2wx, databuf.zcali_pz2wy, zrange_ext, 1);
end