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


function [index, success] = ioReadMAT(varargin)
% load .mat into TS, remap if mapfile is there.. no calibration!! this needs
% to be done earlier.

index='dummy value';

%%%% process input: identify mapping/cal/mat-file
mapping='';
matfile='';
for p=1:nargin
    [~,~,ext]=fileparts(varargin{p});
    switch ext
        case '.mat'
            matfile=varargin{p};
        case '.mapping'
            mapping=varargin{p};
    end
end

metadata=load(matfile);

if ~isempty(mapping)
    leadmap = ioReadMapping(mapping);
    
    if length(leadmap)~=size(metadata.ts.potvals,1)
        msg=sprintf('The mapping file and the file %s are not compatible',matfile);
        errordlg(msg)
        success = 0;
        return
    end
    
    metadata.ts.potvals=metadata.ts.potvals(leadmap,:);   % remap leads
    metadata.ts.audit=[metadata.ts.audit sprintf('|mappingfile=%s',mapping) ];
end


global TS
index=tsNew(1);
TS{index}=metadata.ts;

success = 1;










