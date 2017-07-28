function tsSet(TSindices,fieldname,contents)
% FUNCTION tsSet(TSindices,fieldname,contents)
%
% DESCRIPTION
% This function sets the fields of all the TS series 
% specified and puts the contents in there. 
%
% INPUT
% TSindices     Indices of the files involved
% fieldname     Name of field you want to list
% contents    	 field containing the new values 
%
% SEE ALSO tsInfo tsGet tsDeal

global TS;

for p = TSindices,
   if p <= length(TS),
      TS{p} = setfield(TS{p},fieldname,contents);
   end
end

return 