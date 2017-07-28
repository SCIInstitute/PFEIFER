function fidsShiftFids(TSindices,shift)

% FUNCTION fidsShiftFids(TSindices,shift)
%
% DESCRIPTION 
% This function shifts all the fiducials in a TS set.
% This operation is for instance necessary when slicing
% data.
%
% INPUT
% TSindices      The indices to the TS structure
% shift          The shift in the fiducial value
%
% OUTPUT
% -
%
% SEE ALSO


global TS;

for p=TSindices,
    
    
    if isfield(TS{p},'fids'),
        remove = [];
        for q=1:length(TS{p}.fids),
            TS{p}.fids(q).value = TS{p}.fids(q).value + shift;
            index = find((TS{p}.fids(q).value < 1)|(TS{p}.fids(q).value > TS{p}.numframes));
            if ~isempty(index),
                fprintf(1,'WARNING: fiducial %d is out of range\n',index);
                fprintf(1,'Removing fiducial\n');
                remove = [remove q];				% denote which ones to get rid of
            end							% so I do not change my loop
        end
        if ~isempty(remove),
            TS{p}.fids(remove) = [];				% now remove them all at once
        end  
        
    end
    
end

return