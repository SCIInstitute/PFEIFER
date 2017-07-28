function values = fidsGetLocalFids(TSindices,type,fidset)
% function values = fidsGetLocalFids(TSindices,type,[fidset])
%
% THIS FUNCTION IS OBSOLETE AND WILL BE DELETED USE fidsFindFids INSTEAD
%
% DESCRIPTION
%  Get local fiducials out of the fids information in the TS-structure. The function
%  returns only the first fiducial vector that meets the specification in "type" and "fidset"
%  It returns a matrix in which each element represents a fiducial in the fids structure
%  of the succesive TSindices. Note that type and fidset may be entered as strings,
%  specifying the type (see fidsType) or the label of the fidset respectively. 
%  To classify as a localset the number of leads should equal the number of entries in the
%  fids array.
%
% INPUT
%  TSindices	The indices to the timeseries. In vectorised mode, the function
%               will only read the first fiducial from each timeseries.
%  type		The  type of fiducial your are looking for.
%		This can be either a string or a number specifying the type
%  fidset	The fiducial sets that should be examined or label of the fidset.
%
% OUTPUT
%  values	numeric matrix containing the first entry that matches the input
%               parameters, or a NaN-vecotr if none is found. 
%
% SEE ALSO fidsGetGlobalFids, fidsGetFids, fidsType 


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

%%
% NOTE
% First check is to see whether all timeseries got the same number of channels
% If not, then the given instruction does not make sense

numleads = TS{TSindices(1)}.numleads;				% We need this one to decide what is local


if length(TSindices) > 1,
    for p=TSindices(2:end),
        if TS{p}.numleads ~= numleads,
            msgError('The number of leads should be equal in all timeseries in order to get local fiducial matrix',5)
        end
    end    
end

values = NaN*ones(numleads,length(TSindices));			% initialise an empty array

r = 0;								% second counter for the matrix to be returned							
for p = TSindices,
    r = r + 1;
    
    if ~isfield(TS{p},'fids'),
        continue;						% continue to the next one
    end

    fids = TS{p}.fids;
    
    index = find([fids.type] == type);
    if isempty(index), continue; end				% No match found continue to next one
    fids = fids(index);						% Throw away all non-interesting fiducials
    
    if ~isempty(fidset),
        if ischar(fidset),					% find the corresponding number
            for q=1:length(fidset),
                if strcmp(lower(fidset),lower(TS{p}.fidset{q}.label)) == 1,
                    fidset = q; break;				% found the one we want so get the number
                end    
            end
            if ischar(fidset), continue; end;			% No we did not find her
         end   
    
        index2  = [];						% check for a certain fiducialset
        for q=fidset, index2 = [index2 find([fids.fidset] == q)]; end
       
        if isempty(index2), continue; end;			% No we found no matching fiducial in this class 
        fids = fids(index2);					% Throw away again non interesting fiducials
    end
    
    
    for q =1:length(fids),
        if length(fids(q).value) == numleads,			% Check whether it islocal
             values(:,r) = fids(q).value; break;		% This should be the first one
         end
    end

end    

return