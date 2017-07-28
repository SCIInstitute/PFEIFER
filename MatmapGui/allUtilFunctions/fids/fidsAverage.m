function TSindexmap = fidsAverage(TSindices,startframe,endframe)
% FUNCTION TSindexmap = fidsAverage(TSindices,startframe,endframe)
%
% THIS FUNCTION HAS BECOME OBSOLETE/ IT IS STILL HERE FOR COMPATIBILITY
% USE fidsIntegralMap INSTEAD
%
% DESCRIPTION
%  This function averages over a number of frames in the timeseries dataset.
%  It starts at framestart and ends at frameend. The framestart and frameend
%  may be real-numbers in which case they are rounded to the nearest frame
%
% INPUT 
%  TSindices    the data or Datasets that need integration
%  startframe   the frame for the integration to start, cellarray for multiple timeseries
%  endframe     the frame at which to end, cellarray for multiple timeseries
%
% OUTPUT
%  TSindexmap	an index to where the map is stored. In case multiple TS series
%             	were supplied, each integral map is stored in a frame of the output
%              	The frames are sorted in the way they are supplied in the vector
%	       	The leadinformation is taken from the first TS and the other TSs are
%              	assumed to be equal to the first one, in respect to the lead ordering
%
% SEE fidsIntegrate

global TS;

%%
% check validity of request
% the question is whether all maps have the same number of channels.
% If not the program cannot join the integralmaps
%%

if length(TSindices) > 1,								% Check the dimension of the first timeseries against
    for q = TSindices(2:end),								% all the other timeseries
        if size(TS{TSindices(1)}.potvals,1) ~= size(TS{q}.potvals,1),
            msgError('Maps cannot be merged together, the number of leads is not equal');
        end
    end
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

%%
% In order to be flexible in respect to future version, support multiple ways of 
% entering the fiducials for more timeseries
%  1) Allow the fiducials to be scalars for a single timeseries. In case of more than
%     one timeseries just apply the same scalar value to all timeseries.
%  2) Allow the fiducials to be stored in an array. In this case the size of the array
%     should match the number of timeseries
%  3) Allow the fiducials to be entered in a cellarray, with one cell for each entry
%     This kind of fiducials can store both local and global ones
% At the moment I only allow global fiducials for the computation 
%

%%
% Internally everything is translated to the cellarray version as this one is the most flexible

if isnumeric(startframe),								% Conversion process
    if ~isempty(find(isfinite(startframe)==0)),						% check whether they are all finite
        msgError('Not each startframe is defined',5);					% non-finite ones indicate some fiducials
    end											% are not present

    if size(startframe,1) > 1,								% in case the user switched the matrix dimensions
        if size(startframe,1) ~= TS{TSindices}.numleads,
            startframe = startframe';
        end    
    end
    
    if size(startframe,2) == 1,								% Start with translating the scalar case
        startframe = startframe*ones(1,length(TSindices));
    end    
    
    if length(TSindices) ~= size(startframe,2),						% apparently the dimensions do not match
        msgError('The number of entries in startframe does not match the number of timeseries',5); return
    end
    
    temp = startframe; 									% I do not want to overwrite my data
    startframe = {};									% empty this one
    for p=1:length(TSindices), startframe{p} = temp(p,:); end     			% put a scalar in each cell
end											% This must be it for the moment

if isnumeric(endframe),									% Conversion process
    if ~isempty(find(isfinite(endframe)==0)),						% check whether they are all finite
        msgError('Not each endframe is defined',5);					% non-finite ones indicate some fiducials
    end											% are not present
    
    if size(endframe,1) > 1,								% in case the user switched the matrix dimensions
        if size(endframe,1) ~= TS{TSindices}.numleads,
            endframe = endframe';
        end    
    end
    
   if size(endframe,2) == 1,								% Start with translating the scalar case
        endframe = endframe*ones(1,length(TSindices));
    end    	
    
    if length(TSindices) ~= size(endframe,2),						% apparently the dimensions do not match
        msgError('The number of entries in startframe does not match the number of timeseries',5); return
    end
    
    temp = endframe; 									% I do not want to overwrite my data
    endframe = {};									% empty this one
    for p=1:length(TSindices), endframe{p} = temp(p,:); end     				% put a scalar in each cell
end											% This must be it for the moment

%%
% a final check

if (length(startframe) ~= length(TSindices))|(length(startframe)~=length(endframe)),
    msgError('The dimensions of startframe and endframe do not match the number of timeseries',5);
end

%%
% Generate data on the integral for storing in the tsdf-file
% This includes labels/audit/geometry file etc
% It removes all fiducials since an integralmap does not have fiducials
%    

TS{TSindexmap}.label = sprintf('Averagemap');						% A neutral label
TS{TSindexmap}.geomfile = TS{TSindices(1)}.geomfile;					% Geometry still applies of course
TS{TSindexmap}.geom = TS{TSindices(1)}.geom;

audit = '|MATLAB Averagemap(files='; 							% Generate a new audit string for this one
for q = TSindices, audit = [audit sprintf('%s;',TS{q}.filename)]; end
audit = [audit ')'];
TS{TSindexmap}.audit = audit;				

if ~isempty(TS{TSindexmap}.expid) TS{TSindexmap}.expid = sprintf('EXPID First file: %s',TS{TSindices(1)}.expid); end
TS{TSindexmap}.filename = TS{TSindices(1)}.filename;
TS{TSindexmap}.newfileext = '_avr';							

TS{TSindexmap}.numleads = TS{TSindices(1)}.numleads;					% leadinformation still applies, so copy it
TS{TSindexmap}.leadinfo = TS{TSindices(1)}.leadinfo;

% Have to add proper unit conversion
TS{TSindexmap}.unit = 'mV';								% Assume a unit

intmapnum = 0;
numleads = TS{TSindexmap}.numleads;

% Do a couple of things
% 1) determine which frames are within the interval
% 2) Use these as start and end points
% 3) Determine the unit in case of scaling
% 4) Use trapezium rule for integration

% FUTURE
% add interpolation at start and end

%%
% The algorithm first determines which frames are within the integration interval
% All indices are use and fed into the trapezium rule integration process


for p = TSindices,
    intmapnum = intmapnum + 1; 

    fm = 1:TS{p}.numframes;
    starttime = startframe{intmapnum}; endtime = endframe{intmapnum};			% get the begin and end of the integration

    scale = 1;										% scaling factor for adjusting the units
    switch(TS{p}.unit)
    case 'V'
        scale = 1000;									% set scaling
    case 'uV'
        scale = 0.001;									% idem for microvolts
    case 'mV'
        scale = 1;									% no change of course, but we do not end up in otherwise
    otherwise
        warning('Could not set an output unit, as none is defined in the fileformat. Unit is assumed to be ONE!');
    end   
    
    if (length(starttime) > 1)|(length(endtime) > 1),					% Check the dimensions of the fiducials

        % Do channelwise integration
        % Since local fiducials are specified, one has to do it channel by channel
        
        if length(starttime) == 1, starttime = starttime*ones(numleads,1);  end		% If not equal the fiducials are not OK
        if length(endtime) == 1, endtime = endtime*ones(numleads,1); end
        if (length(starttime) ~= numleads)|(length(endtime)~=numleads), 
            msgError('fiducials sizes are not equal to the number of leads',5);
            return;
        else
            for q=1:numleads,
                index = find((fm >= round(starttime(q)))&(fm <=round(endtime(q))));
                TS{TSindexmap}.potvals(q,intmapnum) = mean(TS{p}.potvals(q,index),2); % the actual integration
            end
        end
    else
        index = find((fm >= round(starttime))&(fm <=round(endtime)));
        TS{TSindexmap}.potvals(1:numleads,intmapnum) = mean(TS{p}.potvals(:,index),2); % the actual integration
    end    

end
    
TS{TSindexmap}.framemap = [1:intmapnum];						% set the frame information
TS{TSindexmap}.numframes = intmapnum;							% to be compatible

return

