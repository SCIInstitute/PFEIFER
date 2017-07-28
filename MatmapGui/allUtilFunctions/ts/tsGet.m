function contents = tsGet(TSindices,fieldname)
% FUNCTION contents = tsGet(TSindices,fieldname)
%
% DESCRIPTION
% This function gets the fields of all the TS series 
% specified and puts them in a cellarray. If the field
% is not present an empty array will be given for this
% index. The same will be applied for indices that are 
% out of range.
%
% INPUT
% TSindices     Indices of the files involved
% fieldname     Name of field you want to list
%
% OUTPUT
% contents    	 Cellarray containing the values of the 
%                fields
%
% SEE ALSO tsInfo tsSet tsDeal

global TS;

contents = {};
q = 1;

% if the field not exist just put an empty array
% the same applies to an index to large

for p = TSindices,
   if p <= length(TS),
      if isfield(TS{p},fieldname),
           contents{q} = getfield(TS{p},fieldname);
           q = q+ 1; 
       else
           contents{q} = [];
           q = q + 1;
       end
   else
       contents{q} = [];
       q = q + 1;
   end
end

return