function geomDeal(GEOMindices,fieldname,contents)
% FUNCTION geomDeal(GEOMindices,fieldname,contents)
%
% DESCRIPTION
% This function sets the fields of all the geometries specified by the
% GEOMindices array and puts the contents in the field specified by fieldname.
% In this case contents is a cell array specifying the contents for each 
% field individually. If the dimension of the contents array is one the 
% field INSIDE this cellarray is put in each timeseries. 
%
%
% INPUT
% GEOMindices     Indices of the files involved
% fieldname       Name of field you want to list
% contents        cellarray containing the new values 
%
% OUTPUT -
%
% NOTE
% The contents has to be specified as a cell array, in order to avoid confusion.
% For instance if you want to put a cell array in the TS structure, be sure to
% put it again within a cell array as the top cell array structure will be broken
% up into pieces. For direct access of the fields without this cell array thing
% use geomSet()
%
% SEE ALSO geomInfo geomGet geomSet

global GEOM;

if ~iscell(contents),
    msgError('contents needs to be a cell array',5);
end

if (length(GEOMindices)~=length(contents))&(length(contents)~=1),
    msgError('contents needs to be of the same dimension as the GEOMindices',5);
end
    
% if only one cell is supplied apply them to all
% otherwise set the fields one to one

q = 1;
for p = GEOMindices,
   if p <= length(GEOM),
      if length(contents)> 1,
         GEOM{p} = setfield(GEOM{p},fieldname,contents{q});
      else
         GEOM{1} = setfield(GEOM{1},fieldname,contents{q});
      end
   end
   q = q+ 1;
end

return