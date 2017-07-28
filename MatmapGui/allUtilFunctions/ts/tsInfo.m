function tsInfo(TSindices,fieldname)
% FUNCTION tsInfo([TSindices],[fieldname])
%
% DESCRIPTION
% This function displays the fields of all the TS series 
% specified. The fieldname is specified by fieldname.
% This function is used to display the information on screen
%
% INPUT
% TSindices     Indices of the files involved
%               default: all timeseries
% fieldname     Name of field you want to list
%               default: 'label'
%
% OUTPUT
% On the screen a list of the requested contents of the fields is displayed
%
% SEE ALSO tsSet tsGet tsDeal

global TS;

format long;

if nargin == 0,
    TSindices = [1:length(TS)];
    fieldname = 'label';
end

if nargin == 1,
    fieldname = 'label';
end

if ischar(TSindices),
    fieldname = TSindices;
    TSindices = [1:length(TS)];
end    

for p = TSindices,
   if p > length(TS),
       fprintf(1,'%d  : EMPTY\n',p);
   else
       if isfield(TS{p},fieldname),
           fieldcont = getfield(TS{p},fieldname);
           fprintf(1,'%d  :',p); disp(fieldcont);
       else
           if isempty(TS{p}),
               fprintf(1,'%d  : EMPTY\n',p) ;
           else 
               fprintf(1,'%d  : NOT SPECIFIED\n',p);
           end    
       end
   end
end
