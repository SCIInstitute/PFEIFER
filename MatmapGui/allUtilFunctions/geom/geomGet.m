function contents = geomGet(GEOMindices,fieldname)
% FUNCTION contents = geomGet(GEOMindices,fieldname)
%
% DESCRIPTION
% This function gets the fields of all the GEOM structures
% specified and puts them in a cellarray. If the field
% is not present an empty array will be given for this
% index. The same will be applied for indices that are 
% out of range.
%
% INPUT
% GEOMindices   Indices of the files involved
% fieldname     Name of field you want to list
%
% OUTPUT
% contents    	 Cellarray containing the values of the 
%                fields
%
% SEE ALSO geomInfo geomSet geomDeal

global GEOM;

contents = {};
q = 1;

% if the field not exist just put an empty array
% the same applies to an index to large

for p = GEOMindices,
   if p <= length(GEOM),
      if isfield(GEOM{p},fieldname),
           contents{q} = getfield(GEOM{p},fieldname);
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