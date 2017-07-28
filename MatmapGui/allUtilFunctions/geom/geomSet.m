function geomSet(GEOMindices,fieldname,contents)
% FUNCTION geomSet(GEOMindices,fieldname,contents)
%
% DESCRIPTION
% This function sets the fields of all the GEOM-structures 
% specified and puts the contents in there. 
%
% INPUT
% GEOMindices    Indices of the files involved
% fieldname      Name of field you want to list
% contents    	 field containing the new values 
%
% SEE ALSO geomInfo geomGet geomDeal

global GEOM;

for p = GEOMindices,
   if p <= length(GEOM),
      GEOM{p} = setfield(GEOM{p},fieldname,contents);
   end
end

return 