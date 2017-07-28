function writemap(filename,map)

% function writemap(filename,map)
%
% file name of the mux or mapping file
% map the actual mapping file generated
%
% the function automatically adds the mapping extension
% unless you specify a .mux extension
%
% see: generatemap
%
% JG Stinstra 2020

[pn,fn,ext] = fileparts(filename);

% add the correct extension
switch ext
case 'mapping'
case 'mux'
otherwise
    filename = fullfile(pn,[fn '.mapping']);
end
    

FID = fopen(filename,'w');

if FID == 0,
    err = sprintf('I am sorry but I could not open file : %s',filename);
    error(err);
end

% sort them as 8 at a row
p = [1:8];

fprintf(FID,'%d channels\n',length(map));
for k=1:floor(length(map)/8),
    fprintf(FID,'% 4d ',map(((k-1)*8)+p));
    fprintf(FID,'\n');
end

% Do the last row as well it is not completely full

if (8*floor(length(map)/8)) ~= length(map),
    for k = ((8*floor(length(map)/8))+1):length(map),
        fprintf(FID,'% 4d ',map(k));

    end
    fprintf(FID,'\n');
end
    
fclose(FID);

return