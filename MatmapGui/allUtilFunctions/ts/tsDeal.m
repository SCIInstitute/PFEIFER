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