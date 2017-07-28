function values = fidsGetAllGlobalFids(TSindex,type)
% function values = fidsGetAllGlobalFids(TSindices,type)
%
% THIS FUNCTION IS OBSOLETE AND WILL BE DELETED USE fidsFindFids INSTEAD
%
% DESCRIPTION
%  Get global fiducials out of the fids information in the TS-structure. The function
%  returns only the first fiducial that meets the specification in "type" and "fidset"
%  It returns a vector in which each element represents a fiducial in the fids structure
%  of the succesive TSindices. Note that type and fidset may be entered as strings,
%  specifying the type (see fidsType) or the label of the fidset respectively. 
%
% INPUT
%  TSindex	The indices to the timeseries. In vectorised mode, the function
%           will only read the first fiducial from each timeseries.
%  type		The  type of fiducial your are looking for.
%		    This can be either a string or a number specifying the type
%
% OUTPUT
%  values	numeric array containing the first entry that matches the input
%               parameters, or NaN if none is found 
%
% SEE ALSO fidsGetLocalFids, fidsGetFids, fidsType 

if nargin < 2,
    error('Two input arguments are required');
end    

if ischar(type),						% Translate the fiducial type from a hardcoded list
    type = fidsType(type); % translate the string input
end

if length(type) > 1,						% Sorry but at this time only one type is allowed
    msgError('Cannot deal with more than one type');
end

global TS;

if nargin == 2,							% if fidset is not specified, just look through all of them
    fidset = [];
end
							% second counter for the matrix to be returned							
p = TSindex;
values = [];
    
if ~isfield(TS{p},'fids'),
    return;						% continue to the next one
end

fids = TS{p}.fids;
    
index = find([fids.type] == type);
if isempty(index), return; end	     	% No match found continue to next one
fids = fids(index);						% Throw away all non-interesting fiducials
    
for q =1:length(fids),
    if length(fids(q).value) == 1,				% Check whether it islocal
        values(:,q) = fids(q).value; 		
    end
end


return