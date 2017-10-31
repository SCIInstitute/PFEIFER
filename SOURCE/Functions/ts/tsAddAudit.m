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


function TSindices = tsAddAudit(TSindices,addaudit)
% FUNCTION      tsAddAudit(TSindices,addaudit)
%          TS = tsAddAudit(TS,addaudit)
%
% DESCRIPTION
% This function adds a string to the end of the audit string.
%
% INPUT
% TSindices/TS    The timeseries need to have their audit string altered
% addaudit        The string to append at the end
%
% OUTPUT
% TS		  In case of directly entered data, the new data is returned
%
% SEE ALSO

    % In case the data is entered directly and not through the TS system

    if addaudit(1) ~= '|'
        addaudit = ['|' addaudit];
    end
    
    if iscell(TSindices)
        for q=1:length(TSindices)
            TSindices{q}.audit = [TSindices{q}.audit addaudit];
        end
    end
    if isstruct(TSindices)
        TSindices.audit = [TSindices.audit addaudit];
    end
    if isnumeric(TSindices)
        global TS;
        for p=TSindices(:)'
            if p<=length(TS)
                TS{p}.audit = [TS{p}.audit addaudit];
            end
        end
    end



