function geomindices = ioReadGEOM(varargin)
% FUNCTION geomindices = ioReadGEOM(filenames)
%
% DESCRIPTION
% This function will add a set of geometry (fac/pts/channels) to the GEOM-structure
%
% INPUT
%
% OUTPUT
%
% SEE ALSO

global GEOM;


% get my parameters
[files,indices,options]  = ioiInputParameters(varargin);

geomfiles = files.geom;

geomset= {}
currentset = 0;

% sorting out the files
% in order for proper functioning they need to be
% specified in a certain order being, 
% first the geom or fac file and than
% the channels and the pts files
% after that a new geomset can be defined by
% a new geom or fac file.

for p=1:length(geomfiles),

    filename = utilStripNumber(geomfiles{p});
    [pn,fn,ext] = fileparts(filename);
    
    switch ext,
    case {'.geom','.fac'}
        currentset = currentset + 1;   % a new set
        newset{1} = geomfiles{p};
        geomset{currentset} = newset;
    case {'.channels','.pts'}
        if currentset == 0,
            warning(sprintf('Please specify the %s-file after the .geom or .fac file for which it is intended, ignoring %s\n',ext,geomfiles{p}));
        else
            set = geomset{currentset};
            set{end+1} = geomfiles{p};
            geomset{currentset} = set;
        end
    end             
end

geomindices = [];

for p=1:length(geomset)
    set = geomset{p};
    for q=1:length(set).
    
        [filename,number] = utilStripNumber(set{q});
        [pn,fn,ext] = fileparts(filename);
    
        switch ext,
        case '.geom'
            if ~isempty(number),
                newGEOM = mexReadGEOM(filename,number);
            else
                newGEOM = mexReadGEOM(filename);
            end
            if ~isempty(indices)
                if max(indices) > length(newGEOM),
                    msgError(sprintf('The indices you specified are out of range of file : %s',filename));
                end
                newGEOM = newGEOM(indices);
            end        
            
            for r=1:length(newGEOM), newGEOM{r}.channels = []; end
        
        case '.fac'
            newGEOM{1}.filename = filename;
            newGEOM{1}.pts = [];
            newGEOM{1}.cpts = [];
            newGEOM{1}.tri = ioReadFac(filename);
            newGEOM{1}.ctri = [];
            newGEOM{1}.channels = [];
        case '.pts'
            for r=1:length(newGEOM), newGEOM{r}.pts = ioReadPts(filename); end
        case '.channels'    
            for r=1:length(newGEOM), newGEOM{r}.channels = ioReadMap(filename); end
        end
    end
    
    for r=1:length(newGEOM),
        if isempty(newGEOM{r}.pts),
            filename = utilStripNumber(newGEOM{r}.filename);
            [pn,fn,ext] = fileparts(filename);
            newfilename = fullfile(pn,[fn '.pts']);
            if exist(newfilename,'file'),
                newGEOM{r}.pts = ioReadPts(newfilename);
            end
         end       
    end
    
    newindices = geomNew(length(newGEOM));
    for r=1:length(newGEOM),
        GEOM{newindices(r)} = newGEOM{r};
    end 
    
    geomindices = [geomindices newindices];   
end

return