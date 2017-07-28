function TSmapindex = fidsIntST80(TSindices)
% FUNCTION TSmapindex = fidsIntST80(TSindices)
% OR       TSmapdata = fidsIntST80(TSdata)
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
 
        framestart = fidsFindFids(TSindices(p),'qrsoff');
        st80 = framestart(:,1)+80;
        startframe = st80-4;
        endframe = st80+4;
        TSmapindex = fidsIntegralMap(TSmapindex,TSindices(p),startframe(:,1),endframe(:,1),'average');
 
    end
    global TS;
    TS{TSmapindex}.newfileext = '_int_s80t';
    TS{TSmapindex}.audit = ['|ST80 integration ' TS{TSmapindex}.audit ];
    TS{TSmapindex}.label = 'ST80 Integralmap';
end
    
if iscell(TSindices),
    TSmapindex = 'data';
    for p = 1:length(TSindices),
 
        framestart = fidsFindFids(TSindices{p},'qrsoff');
        st80 = framestart(:,1)+80;
        startframe = st80-4;
        endframe = st80+4;
        
        TSmapindex = fidsIntegralMap(TSmapindex,TSindices{p},startframe(:,1),endframe(:,1),'average');
 
    end
    TSmapindex.newfileext = '_int_st80';
    TSmapindex.audit = ['|ST80 integration ' TS{TSmapindex}.audit ];
    TSmapindex.label = 'ST80 Integralmap';
end    
    
if isstruct(TSindices),
    TSmapindex = 'data';
 
    framestart = fidsFindFids(TSindices,'qrsoff');
    st80 = framestart(:,1)+80;
    startframe = st80-4;
    endframe = st80+4;
 
    TSmapindex = fidsIntegralMap(TSmapindex,TSindices{p},startframe(:,1),endframe(:,1),'average');
    TSmapindex.newfileext = '_int_st80';
    TSmapindex.audit = ['|ST80 integration ' TS{TSmapindex}.audit ];
    TSmapindex.label = 'ST80 Integralmap';
end    


    
return