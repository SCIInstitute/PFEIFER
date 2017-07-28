function TSindexmap = fidsMIntegrate(TSindices,startframe,endframe)
% FUNCTION TSindexmap = fidsMIntegrate(TSindex,startframe,endframe)
% 
% FUNCTION HAS BECOME OBSOLETE, USE fidsIntegralMap INSTEAD
%
% DESCRIPTION
% This function integrates over all leads in the in the timeseries dataset.
% It starts at framestart and ends at frameend. The framestart and frameend
% may be real-numbers in which case they are rounded to the nearest frame.
% In this function start and end can be vectors specifying multiple
% integrals
%
% INPUT 
% TSindices     the data or Datasets that need integration
% startframe    the frame for the integration to start, cellarray for multiple timeseries
% endframe      the frame at which to end, cellarray for multiple timeseries
%
% OUTPUT
% TSindexmap	an index to where the map is stored. In case multiple TS series
%             	were supplied, each integral map is stored in a frame of the output
%              	The frames are sorted in the way they are supplied in the vector
%	       	The leadinformation is taken from the first TS and the other TSs are
%              	assumed to be equal to the first one, in respect to the lead ordering
%
% SEE ALSO fidsIntQRS fidsIntST fidsIntSTT fidsIntST80 fidsIntQRST

global TS;

%%
% check validity of request
% the question is whether all maps have the same number of channels.
% If not the program cannot join the integralmaps
%%

if length(TSindices) > 1,								% Check the dimension of the first timeseries against
    msgError('This function only works on one map',5);
    return;
end            

%%
% Although the map differs from the timeseries data, we can store the data in the same
% structure. Hence reserve one TS structure
%

TSindexmap = tsInitNew(1); 								% Init a new map, we just need one new timeseries/map

%%
% Do some security checks on whether the data is of the right size
% In case the start and end are scalars make them valid for each timeseries
% hence the vecotr will have the same value for each timeseries
%

if ~isnumeric(startframe),
    msgError('Start frame must be a numeric vector',5);
    return;
end

if ~isempty(find(isfinite(startframe)==0)),						% check whether they are all finite
    msgError('Not each startframe is defined/Fiducial is missing',5);		% non-finite ones indicate some fiducials
    return
end											% are not present

if ~isnumeric(endframe),									% Conversion process
    msgError('Start frame must be a numeric vector',5);
    return;
end
  
if ~isempty(find(isfinite(endframe)==0)),						% check whether they are all finite
    msgError('Not each endframe is defined/Fiducial is missing',5);			% non-finite ones indicate some fiducials
    return
end											% are not present
    
%%
% a final check

if (length(startframe) ~= length(endframe)),
    msgError('The dimensions of startframe and endframe should be equal',5);
    return
end

%%
% Generate data on the integral for storing in the tsdf-file
% This includes labels/audit/geometry file etc
% It removes all fiducials since an integralmap does not have fiducials
%    

TS{TSindexmap}.label = sprintf('Integralmap');						% A neutral label
TS{TSindexmap}.geomfile = TS{TSindices(1)}.geomfile;					% Geometry still applies of course
TS{TSindexmap}.geom = TS{TSindices(1)}.geom;

audit = '|MATLAB Integralmap(files='; 							% Generate a new audit string for this one
for q = TSindices, audit = [audit sprintf('%s;',TS{q}.filename)]; end
audit = [audit ')'];
TS{TSindexmap}.audit = audit;				

if ~isempty(TS{TSindexmap}.expid) TS{TSindexmap}.expid = sprintf('EXPID First file: %s',TS{TSindices(1)}.expid); end
TS{TSindexmap}.filename = TS{TSindices(1)}.filename;
TS{TSindexmap}.newfileext = TS{TSindices(1)}.newfileext;

TS{TSindexmap}.numleads = TS{TSindices(1)}.numleads;					% leadinformation still applies, so copy it
TS{TSindexmap}.leadinfo = TS{TSindices(1)}.leadinfo;

% Have to add proper unit conversion
TS{TSindexmap}.unit = 'mVms';								% Assume a unit

intmapnum = 0;
numleads = TS{TSindexmap}.numleads;

%%
% The algorithm first determines which frames are within the integration interval
% All indices are use and fed into the trapezium rule integration process

    fm = 1:TS{TSindices(1)}.numframes;
    starttime = startframe; endtime = endframe;			% get the begin and end of the integration

    scale = 1;										% scaling factor for adjusting the units
    switch(TS{TSindices(1)}.unit)
    case 'V'
        scale = 1000;									% if want mVms per we have to multiply by 1000
    case 'uV'
        scale = 0.001;									% idem for microvolts
    case 'mV'
        scale = 1;									% no change of course, but we do not end up in otherwise
    otherwise
        warning('Could not set an output unit, as none is defined in the fileformat. Unit is assumed to be ONE!');
    end   
    
    if length(starttime) ~= length(endtime),
        msgError('Start frame and end frame vector sizes should be equal',5);
        return;
    end
    
    for q=1:length(starttime)
        index = find((fm >= round(starttime(q)))&(fm <=round(endtime(q))));
        TS{TSindexmap}.potvals(1:numleads,q) = sum(TS{TSindices(1)}.potvals(:,index),2); % the actual integration
    end    

    TS{TSindexmap}.framemap = [1:intmapnum];						% set the frame information
    TS{TSindexmap}.numframes = intmapnum;							% to be compatible

return