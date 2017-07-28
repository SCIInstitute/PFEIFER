function values = fidsGetFids(TSindices,type,fidset)
% function values = fidsGetFids(TSindices,type,[fidset])
%
% THIS FUNCTION IS OBSOLETE AND WILL BE DELETED USE fidsFindFids INSTEAD
%
% DESCRIPTION
% Get the fiducials out of the fids information in the TS-structure. The function supports
% both local and global fiducials. In order to support both, this function returns a cell
% array (whereas fidsGetLocalFids and fidsGetGlobalFids, return just a matrix). This function
% gets the first one that meets the condition. In order to get all fiducials use fidsGetAllFids.
%
%
% INPUT
% TSindices	The indices to the timeseries. In vectorised mode, the function
%               will only read the first fiducial from each timeseries.
% type		The  type of fiducial your are looking for.
%		This can be either a string or a number specifying the type
% fidset	The fiducial sets that should be examined
%
% OUTPUT
% values	Cell array containing the first entry that matches the input
%               parameters in case of multiple timeseries and all that match in
%               case of single timeseries
%
% SEE ALSO fidsGetLocalFids fidsGetGlobalFids fidsgetAllFids

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
    
values = {};
for p = 1:length(TSindices),
    if ~isfield(TS{TSindices(p)},'fids'),			% No fiducials loaded in this timeseries
        values{p} = []; continue; 
    end
        
    fids = TS{TSindices(p)}.fids;				% OK, there are fiducials
    index = find([fids.type] == type);				% Find me the right type of fiducials
    if isempty(index), 						% Oh noo, I cannot find any of this fiducial type
        values{p} = []; continue; 
    end
        
    fids = fids(index);						% Throw away all non-interesting fiducials
    if ~isempty(fidset)
        index2  = [];						% check for a certain fiducialset
        for q=fidset, index2 = [index2 find([fids.fidset] == q)]; end
        if isempty(index2),
            values{p} = []; continue;
        end 	
        fids = fids(index2);					% Throw away again non interesting fiducials
    end    
    values{p} = fids(1).value;					% we got a fiducial, just select the first one
end

return