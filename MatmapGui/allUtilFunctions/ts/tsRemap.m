function tsRemap(TSindices,leadmap,framemap)
% FUNCTION tsRemap(TSindices,leadmap,[framemap])
%       or tsRemap(TSindices,options)
%
% DESCRIPTION
% This function remaps the timeseries data and selectes a certain
% amount of frames or leads. Both can be supplied as a 'map', this map
% is no more than a vector in which the numbers refer to the indices
% of the frames and maps. Only those referred to in the 'map'-vector 
% will be used in the updated timeseries. THis vector can be used as
% well to establish the order in which channels/frames have to be ordered.
%
% INPUT
% TSindices       The indices to the timeseries structures that need to
%                 be remappped
% leadmap         A vector specifying which leads to use in the updated 
%                 timeseries. To specify all, just put an empty array;
% framemap        A vector specifying which frames to use in the updated
%                 timeseries. To specify all, just put an empty array;
%
% OUTPUT
% The TS timeseries will be altered and the number of leads and frames will
% be adjusted. Fiducials are taken care of as well.
%
% OPTIONS
% .framemap    The framemap
% .leadmap   The leadmap
%
% SEE ALSO - 

global TS;

if nargin == 2,
    framemap = [];
end    

if nargin < 2,
    msgError('You need to specify a TSindex, a leadmap and a framemap',5);
end    

% From the io-functions it is easier to pass the options array directly
% Hence in case the options array is put on the leadmap field, it is
% translated by the following algorithm

if isstruct(leadmap),
   options = leadmap;
   framemap = [];
   leadmap = [];
   if isfield(options,'framemap'), framemap = options.framemap; end
   if isfield(options,'leadmap'), leadmap = options.leadmap; end
end   

for p=TSindices,

    if isempty(leadmap),
        leadmap = [1:size(TS{p}.potvals,1)];
    end
    if isempty(framemap),
        framemap = [1:size(TS{p}.potvals,2)];
    end
    
    if ~isfield(TS{p},'potvals'),
            warning(sprintf('No timeseries data is stored in timeseries %d, skipping this one',p));
            continue;
    end        
            
    if (size(TS{p}.potvals,1) < max(leadmap))|(size(TS{p}.potvals,2) < max(framemap)),
            warning(sprintf('The number of frames/leads in timeseries %d is smaller than in the leadmap/framemap, skipping this one',p));
            continue;
    end        

    % Slice the data and get only the frames and leads you want
                                                  
    TS{p}.potvals = TS{p}.potvals(leadmap,framemap);
    TS{p}.numleads = size(TS{p}.potvals,1);
    TS{p}.numframes = size(TS{p}.potvals,2);
    TS{p}.leadinfo = TS{p}.leadinfo(leadmap);
                  
    % reorder and update the fiducials as well
    
    fidsUpdateFids(p,leadmap,framemap);    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % In case some new fields need reordering as well %
    % Put the reorder/update algorithms here          %
    % vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
