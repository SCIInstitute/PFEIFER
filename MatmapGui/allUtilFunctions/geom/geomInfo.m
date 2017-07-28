function geomInfo(GEOMindices,fieldname)
% FUNCTION geomInfo([GEOMindices],[fieldname])
%
% DESCRIPTION
% This function displays the fields of all the GEOM-structures 
% specified. The fieldname is specified by fieldname.
% This function is used to display the information on screen
%
% INPUT
% GEOMindices   Indices of the files involved
%               default: all timeseries
% fieldname     Name of field you want to list
%               default: 'name'
%
% OUTPUT
% On the screen a list of the requested contents of the fields is displayed
%
% SEE ALSO geomSet geomGet geomDeal

global GEOM;

format long;

if nargin == 0,
    GEOMindices = [1:length(GEOM)];
    fieldname = 'name';
end

if nargin == 1,
    fieldname = 'name';
end

if ischar(GEOMindices),
    fieldname = GEOMindices;
    GEOMindices = [1:length(GEOM)];
end    

for p = GEOMindices,
   if p > length(GEOM),
       fprintf(1,'%d  : EMPTY\n',p);
   else
       if isfield(GEOM{p},fieldname),
           fieldcont = getfield(GEOM{p},fieldname);
           if isempty(fieldcont), fieldcont = sprintf('EMPTY\n'); end
           fprintf(1,'%d  :',p); disp(fieldcont);
       else
           if isempty(GEOM{p}),
               fprintf(1,'%d  : EMPTY\n',p) ;
           else 
               fprintf(1,'%d  : NOT SPECIFIED\n',p);
           end    
       end
   end
end
