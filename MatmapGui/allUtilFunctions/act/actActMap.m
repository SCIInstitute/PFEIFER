function TSmapindex = actActMap(TSindices,fidtype,fidset)
% FUNCTION TSmapindex = actActMap(TSindices,[fidtype],[fidset])
%
% DESCRIPTION
% This function generates an activation/recovery map in a new timeseries dataset (TS-structure).
% By specifying the fiducial type, the functtion selects the first fiducialset 
% that meets the description and then puts the map in a new timeseries. In order to produce a map
% the function looks for locally defined % *S "Activation Time" and
% "Reference Time" fiducials. In case these are not available the function
% will fail. The Activation Map 'pot' value is then the difference between
% the Activation Time and Refernece Time. *S % By default the function
% will look for activation fiducials. However specifying another
% type will generate a map of that fiducial.
% When specifying multiple indices, the function puts them all in one timeseries, each frame
% representing an activation map. You can use this functionality to make maps of multiple recordings
% that follow each other chronologically.
%
% INPUT 
% TSindices    the data or Datasets that need integration
% fidtype      the fiducialtype wanted, see FidsType for definitions (activation map by default)
%              A string describing the type can be passed as well (see fidsType)
% fidset       only from these sets the map will be generated
%              (can be a string specifying the label of the fitset)	
%
% OUTPUT
% TSindexmap   an index to where the map is stored. In case multiple TS series
%              were supplied, each integral map is stored in a frame of the output
%              The frames are sorted in the way they are supplied in the vector
%              The leadinformation is taken from the first TS and the other TSs are
%              assumed to be equal to the first one, in respect to the lead ordering
%
% SEE ALSO fidsType

global TS;

if nargin < 2,
    fidtype = 'act';		% lets make an activation map
end

if nargin < 3,
    fidset = [];
end    

if isempty(fidtype),
    fidtype = 'act';
end    

for p=1:length(TSindices),				% determine scaling for each timeseries
    scale(p) = 1;
    if isfield(TS{TSindices(p)},'samplefrequency'),
        scale(p) = 1000/TS{TSindices(p)}.samplefrequency;
    else
        fprintf('WARNING: Some samplefrequencies are not assigned. Assuming a frequency of 1000Hz\n');
    end    
end

matrix = fidsGetLocalFids(TSindices,fidtype,fidset);

% %%%%%%%%%%%%% Changes Made by Shibaji will be indicated by % *S %%%%%%%%%%%%%%%%%%%%%%%

refmatrix = fidsGetGlobalFids(TSindices,'ref');% ,fidset);   % *S getting the Reference fiducial

keyboard
if nnz(isnan(matrix)),					% just checking whether everything is ok
    for q=1:size(matrix,2),
        if ~isempty(find(isnan(matrix(:,q)), 1)),
            disp(sprintf('WARNING: FILE %s, %d activation times are not assigned (BAD LEADS?)',TS{TSindices(q)}.filename,length(find(isnan(matrix(:,q))))));
        end
    end   
end    
  
if nnz(isnan(refmatrix)),					% just checking whether everything is ok
    for q=1:size(refmatrix,2),
        if ~isempty(find(isnan(refmatrix(:,q)), 1)),
            disp(sprintf('WARNING: FILE %s, %d reference times are not assigned (BAD LEADS?)',TS{TSindices(q)}.filename,length(find(isnan(refmatrix(:,q))))));
        end
    end   
end    
 

scalematrix = ones(size(matrix,1),1)*scale;		% Build a scale matrix for proper scaling
matrix = scalematrix.*matrix;	                        % Scale each element
refmatrix = scalematrix.*refmatrix;                     % *S Scale Reference fiducial

clear scalematrix;					% Clear up some memory

TSmapindex = tsInitNew(1);  	% map index

%%
% Generate the map

TS{TSmapindex}.potvals = matrix-refmatrix;              % *S Activation Map  = Activation Time - Reference Time
TS{TSmapindex}.numleads = size(TS{TSmapindex}.potvals,1);
TS{TSmapindex}.numframes = size(TS{TSmapindex}.potvals,2);
TS{TSmapindex}.leadinfo = uint32(zeros(TS{TSmapindex}.numleads,1));

%%
% Copy some data from the first file in the list

if isfield(TS,'leadinfo'), TS{TSmapindex}.leadinfo = TS{TSindices(1)}.leadinfo; end
if isfield(TS,'geom'), TS{Tsmapindex}.geom = TS{TSindices(1)}.geom; end
if isfield(TS,'geomfile') TS{Tsmapindex}.geomfile = TS{TSindices(1)}.geomfile; end
if isfield(TS,'expid'), if ~isempty(TS{TSindexmap}.expid), TS{TSindexmap}.expid = sprintf('EXPID First file: %s',TS{TSindices(1)}.expid); end; end


TS{TSmapindex}.label = 'Activation map';
TS{TSmapindex}.newfileext = '_act';
TS{TSmapindex}.unit = 'ms';

audit = '|MATLAB Activationmap(files='; % Generate a new audit string for this one
for q = TSindices, audit = [audit sprintf('%s;',TS{q}.filename)]; end
audit = [audit ')'];
TS{TSmapindex}.audit = audit;	

return
