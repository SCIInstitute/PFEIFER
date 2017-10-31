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


function TSmapindices = fidsIntAll(TSindices)
% FUNCTION TSmapindices = fidsIntAll(TSindices)
%
% DESCRIPTION
% This function integrates the timeseries indicated in the TSindices vector
% and puts them all in a new map. The new maps will be put in one new 
% timeseries entry in which each frame represents a integralmap. The maps
% are in the order of which the indices are read. Normally using ioReadTS
% the files are sorted in alphabetical order if you use wildcards. 
%
% INPUT
% TSindices    The indices in the TS-structure
%
% OUTPUT
% TSmapindices   The index on where to find the newly generated maps
%
% NOTE
% If multiple QRS/T starts and endings are defined only the first one is used
%
% SEE ALSO fidsIntST fidsIntSTT fidsIntST80 fidsIntQRS fidsIntQRST
 
% Get starting and ending from fiducials 
global TS
for q=1:length(TSindices)
    index = [];
    audit = '|';
    startframe = fidsFindGlobalFids(TSindices(q),'qrson');
    endframe = fidsFindGlobalFids(TSindices(q),'qrsoff');
    if (~isempty(startframe)) && (~isempty(endframe))
        if (isfinite(startframe(1)) && isfinite(endframe(1)))
            index = fidsIntegralMap(index,TSindices(q),startframe(1),endframe(1));
            audit = [audit 'QRS/'];
        end
    end
    

    startframe = fidsGetGlobalFids(TSindices(q),'qrson');
    endframe = fidsGetGlobalFids(TSindices(q),'toff');
    if (~isempty(startframe)) && (~isempty(endframe))
        if (isfinite(startframe(1)) && isfinite(endframe(1)))
            index = fidsIntegralMap(index,TSindices(q),startframe(1),endframe(1));
            audit = [audit 'QRST/'];
        end
    end
    

    startframe = fidsGetGlobalFids(TSindices(q),'qrsoff');
    endframe = fidsGetGlobalFids(TSindices(q),'toff');
    if (~isempty(startframe)) && (~isempty(endframe))
        if (isfinite(startframe(1)) && isfinite(endframe(1)))     
            endframe = startframe + (3/8)*(endframe-startframe);
            index = fidsIntegralMap(index,TSindices(q),startframe(1),endframe(1));
            audit = [audit 'ST/'];
        end
    end
    
    
    qrsoff = fidsGetGlobalFids(TSindices(q),'qrsoff'); 
    if ~isempty(qrsoff)
        st80 = qrsoff(1)+80;
        startframe = st80-4;   
        endframe = st80+4;
        
        withinRange=1;
        if endframe >= TS{TSindices(q)}.numframes
            withinRange=0;
        end
        
        if (isfinite(startframe(1)) && isfinite(endframe(1))) && withinRange
            index = fidsIntegralMap(index,TSindices(q),startframe(1),endframe(1),'average');
            audit = [audit 'ST80/'];
        end
    end
    
    
    
    startframe = fidsGetGlobalFids(TSindices(q),'qrsoff');
    endframe = fidsGetGlobalFids(TSindices(q),'toff');
    
    
    
    if (~isempty(startframe)) && (~isempty(endframe))
        if (isfinite(startframe(1)) && isfinite(endframe(1)))
            index = fidsIntegralMap(index,TSindices(q),startframe(1),endframe(1));
            audit = [audit 'STT/'];
        end
    end

    
    if ~isempty(index)
        TSmapindices(q) = index;
     
         % now just change some of the text fields
        TS{TSmapindices(q)}.newfileext = '-itg';
        TS{TSmapindices(q)}.audit = [ TS{TSmapindices(q)}.audit audit ' integration'];
        TS{TSmapindices(q)}.label = [TS{TSmapindices(q)}.label audit ' Integralmap'];   
    else
        TSmapindices = [];
    end
end

return
