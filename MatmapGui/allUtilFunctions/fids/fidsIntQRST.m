function TSmapindex = fidsIntQRST(TSindices)
% FUNCTION TSmapindex = fidsIntQRST(TSindices)
% OR       TSmapdata = fidsIntQRST(TSdata)
%
% DESCRIPTION
% This function integrates the timeseries indicated in the TSindices vector
% and puts them all in a new map. The new maps will be put in one new 
% timeseries entry in which each frame represents a integralmap. The maps
% are in the order of which the indices are read. Normally using ioReadTS
% the files are sorted in alphabetical order if you use wildcards. 
%
% INPUT
% TSindices    The indices in the TS-structure
% TSdata       Direct input of the Timeseries data (no index)
%
% OUTPUT
% TSmapindex   The index on where to find the newly generated map
% TSmapdata    Direct output of the integralmap
%
% NOTE
% If multiple QRS/T starts and endings are defined only the first one is used
%
% SEE ALSO fidsIntST fidsIntSTT fidsIntST80 fidsIntQRS fidsIntQRST
 
% Get starting and ending from fiducials 
 

 
 if isnumeric(TSindices),
    TSmapindex = [];
    for p = 1:length(TSindices),
 
        framestart = fidsFindFids(TSindices(p),'qrson');
        frameend = fidsFindFids(TSindices(p),'toff');
 
        TSmapindex = fidsIntegralMap(TSmapindex,TSindices(p),framestart(:,1),frameend(:,1));
 
    end
    global TS;
    TS{TSmapindex}.newfileext = '_int_qrst';
    TS{TSmapindex}.audit = ['|QRST integration ' TS{TSmapindex}.audit ];
    TS{TSmapindex}.label = 'QRST Integralmap';
end
    
if iscell(TSindices),
    TSmapindex = 'data';
    for p = 1:length(TSindices),
 
        framestart = fidsFindFids(TSindices{p},'qrson');
        frameend = fidsFindFids(TSindices{p},'toff');
 
        TSmapindex = fidsIntegralMap(TSmapindex,TSindices{p},framestart(:,1),frameend(:,1));
 
    end
    TSmapindex.newfileext = '_int_qrst';
    TSmapindex.audit = ['|QRST integration ' TS{TSmapindex}.audit ];
    TSmapindex.label = 'QRST Integralmap';
end    
    
if isstruct(TSindices),
    TSmapindex = 'data';
 
    framestart = fidsFindFids(TSindices,'qrson');
    frameend = fidsFindFids(TSindices,'toff');
 
    TSmapindex = fidsIntegralMap(TSmapindex,TSindices{p},framestart(:,1),frameend(:,1));
    TSmapindex.newfileext = '_int_qrst';
    TSmapindex.audit = ['|QRST integration ' TS{TSmapindex}.audit ];
    TSmapindex.label = 'QRST Integralmap';
end    


    
return