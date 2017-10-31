% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


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

for p=TSindices
    
    
    if isfield(TS{p},'fids')
        remove = [];
        for q=1:length(TS{p}.fids)
            TS{p}.fids(q).value = TS{p}.fids(q).value + shift;
            index = find((TS{p}.fids(q).value < 1)|(TS{p}.fids(q).value > TS{p}.numframes));
            if ~isempty(index)
                fprintf(1,'WARNING: fiducial %d is out of range\n',index);
                fprintf(1,'Removing fiducial\n');
                remove = [remove q];				% denote which ones to get rid of
            end							% so I do not change my loop
        end
        if ~isempty(remove)
            TS{p}.fids(remove) = [];				% now remove them all at once
        end  
        
    end
    
end

return