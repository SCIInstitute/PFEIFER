function TS = fidsUpdateFids(TSindices,leadmap,framemap)
% FUNCTION fidsUpdateFids(TSindices,leadmap,[framemap])
%       or fidsUpdateFids(TSindices,options)
%       or data = fidsUpdateFids(data,options)
%
% DESCRIPTION
% This function checks the integrity of the fiducials.
% Only allowing global (length=1) or local fiducial (length=numleads)
% On other configurations the function will fail. As well remapping 
% options are build in and the fiducials will be corrected for this.
% In case no TSDF-data is loaded, the function will check whether only 
% two lengths of fiducias are present, assuming local fiducials to
% have a length other than one, but all need to be the same as they 
% correspond to the same dataset.
% In case of frame renumbering the fiducials will be checked. Any fiducials
% that are out of range will be removed as integrals based on them will not
% be valid. The latter check is only performed in case a number of frames is
% specified, so you will be allowed to load fidsets only
%
% INPUT
% TSindices   The indices of the timeseries to be inspected
% leadmap     The mapping vector used to remap the leads
% framemap    The mapping vector used to remap the frames
%
% OUTPUT 
% The updated fiducials are stored back in the fidset/fids fields of
% the TS global.
%
% OPTIONS
% .framemap   The framemap
% .leadmap    The leadmap
%
% SEE ALSO - 


% This function checks the lengths of the fiducial sets and compares
% them to the sets in the tsdf files

if ~iscell(TSindices),
    global TS;
else
    TS = TSindices;
    TSindices = 1:length(TS);
end

if nargin == 2,
    framemap = [];
end    

if nargin < 2,
    msgError('You need to specify a TSindex, a leadmap and a framemap',5);
end     

% From the io functions it is easier to pass the options array directly
% Hence in case the options array is put on the leadmap field, it is
% translated by the following algorithm

if isstruct(leadmap),
   options = leadmap;
   framemap = [];
   leadmap = [];
   if isfield(options,'framemap'), framemap = options.framemap; end
   if isfield(options,'leadmap'), leadmap = options.leadmap; end
end   


% main loop go through all timeseries that are stored in TSindices
   
for p=TSindices,

    if ~isfield(TS{p},'fids'),
        continue;						% Go to next timeseries
    end    

    fids = TS{p}.fids;						% Easier to work with
    fidset = TS{p}.fidset;

    for q=1:length(fids),					% Find out all about the lengths of the fiducial sets
        fidslen(q) = length(fids(q).value);
    end

    %%
    % If in options a leadmap was given the channels are remapped,
    % so I have to correct the local fiducials as well
    
    if ~isempty(leadmap),
        index = find(fidslen > 1);					% the local ones are selected only
        if ~isempty(index),
            for q=index,
                if max(leadmap) > length(fids(q).value),		% check whether the indices are not out of range
                    msgError('leadmap not compatible with fiducials',5);
                    continue;
                end 
                fids(q).value = fids(q).value(leadmap);			% remap the data 
              end    
        end
        
        for q=1:length(fids),						% Recompute the lengths after filtering
            fidslen(q) = length(fids(q).value);
        end
        
    end    
    
    if ~isfield(TS{p},'numleads'),
        
        % In this case just assume the largest fiducial vector to determine the length
        TS{p}.numleads = max(fidslen);

    end
    
    index = find((fidslen ~= 1)&(fidslen ~= TS{p}.numleads));	% test whether everything is OK
    
    if ~isempty(index),						% We have got a problem			
        for q=index,
            fprintf(1,'WARNING: timeseries %d /fiducial %d does not have a valid number of leads\n',p,q);
        end
        fprintf(1,'Removing all these incompatible fidsets\n');
    
       %%
       % NOTE
       % In the original structure in the TSDFC-file all fiducial of one set have the same length, so if one fails my
       % check they all fail. So I better remove the fidset entry as well, since all entries in the fidset have the same
       % problem. In fidset the function creates empty cells and in fids the unwanted entries are discarded

       for q=index,
           if fids(index).fidset > 0,
                fidset{fids(index).fidset} = [];
           end   
       end
       fids(index) = [];

    end
    
    %%
    % In case of remapping the frames, we have to adjust the fiducials as well since they are denoted in frame number
    % 
    
    if ~isempty(framemap),
        yy = 1:length(framemap);
        xx = framemap;
        
        %%
        % NOTE
        % You can do kind of remapping, even some non-linear ones
        % This function just interpolates between old and new values
        
        for q=1:length(fids),
            fids(q).value = interp1(xx,yy,fids(q).value,'linear');
        end    
    end
    
    %%
    % One final check: are the fiducials within range of the frames specified?
    
    if isfield(TS{p},'numframes'),				% otherwise do not check
         remove = [];
         for q=1:length(fids),
            index = find((fids(q).value < 1)|(fids(q).value > TS{p}.numframes));
            if ~isempty(index),
                fprintf(1,'WARNING: fiducial %s is out of range\n',q);
                fprintf(1,'Removing fiducial\n');
                remove = [remove q];				% denote which ones to get rid of
            end							% so I do not change my loop
         end
         if ~isempty(remove),
                fids(remove) = [];				% now remove them all at once
         end
    end            
        
    TS{p}.fids = fids;
    TS{p}.fidset = fidset;
 end   
 
 return