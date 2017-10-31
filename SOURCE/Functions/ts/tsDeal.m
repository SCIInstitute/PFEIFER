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


function tsDeal(TSindices,fieldname,contents)

%sets TS{indices}.(fieldname)=contents     just ONE fieldname is given. if
%length(contents)=1, all TS get that value on field. If
%length(contents)=length(TSindices), then  TS{i}.(fieldname)=contents(i) for all i in 1:len(indices) 


% FUNCTION tsDeal(TSindices,fieldname,contents)
%
% DESCRIPTION
% This function sets the fields of all the timeseries specified by the
% TSindices array and puts the contents in the field specified by fieldname.
% In this case contents is a cell array specifying the contents for each 
% field individually. If the dimension of the contents array is one the 
% field INSIDE this cellarray is put in each timeseries. 
%
%
% INPUT
% TSindices     Indices of the files involved
% fieldname     Name of field you want to list
% contents    	 cellarray containing the new values 
%
% OUTPUT -
%
% NOTE
% The contents has too be specified as a cell array, in order to avoid confusion.
% For instance if you want to put a cell array in the TS structure, be sure to
% put it again within a cell array as the top cell array structure will be broken
% up into pieces. For direct access of the fields without this cell array thing
% use tsSet()
%
% SEE ALSO tsInfo tsGet tsSet

global TS;

if ~iscell(contents)
    contents = {[contents]};
end

if (length(TSindices)~=length(contents))&&(length(contents)~=1)
    msgError('contents needs to be of the same dimension as the TSindices',5);
end
    
% if only one cell is supplied apply them to all
% otherwise set the fields one to one

q = 1;
for p = TSindices
   if p <= length(TS)
      if length(contents)> 1
         TS{p}.(fieldname)=contents{q};
      else
         TS{p}.(fieldname)=contents{1};
      end
   end
   q = q+ 1;
end

return