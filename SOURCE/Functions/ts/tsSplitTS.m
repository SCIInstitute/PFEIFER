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


function newindices = tsSplitTS(TSindex, channels)

% FUNCTION [newTSindices1,newTSindices2,...] = tsSplitTS(indices,channels)

   count = length(channels);
    global TS;
    newindices = tsNew(count);
    for p=1:count
      toBeCleared=[];
      TS{newindices(p)} = TS{TSindex};
      TS{newindices(p)}.potvals = TS{newindices(p)}.potvals(channels{p},:);
      TS{newindices(p)}.leadinfo = TS{newindices(p)}.leadinfo(channels{p});
      TS{newindices(p)}.numleads = length(channels{p});
      if isfield(TS{newindices(p)},'fids')
          for r=1:length(TS{newindices(p)}.fids)
              if length(TS{newindices(p)}.fids(r).value) > 1
                  if isempty(find(0==ismember(channels{p},1:length(TS{newindices(p)}.fids(r).value)), 1))
                      TS{newindices(p)}.fids(r).value = TS{newindices(p)}.fids(r).value(channels{p});
                  else
                      toBeCleared=[toBeCleared r];
                  end
              end
          end
          TS{newindices(p)}.fids(toBeCleared)=[];
      end    
    end

end
    

