function [result, dyeList] = calDemix(intlist1, intlist2)
% classify dyes with demixing text3 method, using two hard threshold to
% determin the AF647 and CF660
    intmin = 10;
    demixdata = load('.\demix_647_660.mat');
    thresholdList = demixdata.thresholdList;
    dyeList = demixdata.dyeList;
    
    intdiff = log10(intlist1) - log10(intlist2);
    
    result=zeros(size(intlist1));
    result(intdiff<thresholdList(1)) = 1;
    result(intdiff>thresholdList(2)) = 2;
    result(intdiff>=thresholdList(1) & intdiff<=thresholdList(2)) = 0;
    result(intlist1<intmin | intlist2<intmin) = 0;
    
end