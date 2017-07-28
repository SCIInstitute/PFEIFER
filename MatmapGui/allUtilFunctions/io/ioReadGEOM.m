function geomindices = ioReadGEOM(varargin)
% FUNCTION geomindices = ioReadGEOM(filenames)
%
% DESCRIPTION
% This function will add a set of geometry (.fac/.pts/.channels) to the GEOM-structure
%
% INPUT
% filenames      The filenames of the geometry files that you want to load. In case multiple
%                datasets are specified first specify the .geom or .fac file then the .pts 
%                and .channels files. To specify a certain surface in a geom file use the
%                file.geom@<number> notation to only retrieve that surface.
%
% OUTPUT
% geomindices    Indices in the GEOM structure specifying where the data is stored
%
% SEE ALSO
% ioWriteGEOM

global GEOM;


% get my parameters
[files,indices,options]  = ioiInputParameters(varargin);

geomfiles = files.geom;

geomset= {};
currentset = 0;

% sorting out the files
% in order for proper functioning they need to be
% specified in a certain order being, 
% first the geom or fac file and than
% the channels and the pts files
% after that a new geomset can be defined by
% a new geom or fac file.

channelsfile = [];
isgeom = 0;

for p=1:length(geomfiles),

    filename = utilStripNumber(geomfiles{p});
    [pn,fn,ext] = fileparts(filename);
    
    switch ext,
    case {'.channels'}
        channelsfile = geomfiles{p};
    
    case {'.geom'}
        currentset = currentset + 1;   % a new set
        newset = {};
        newset{1} = geomfiles{p};
        if ~isempty(channelsfile),
           newset{2} = channelsfile;
        end 
        geomset{currentset} = newset;
        channelsfile = [];
        isgeom = 1;
    case {'.fac'}    
        currentset = currentset + 1;   % a new set
        newset = {};
        newset{1} = geomfiles{p};
        if ~isempty(channelsfile),
           newset{2} = channelsfile;
        end 
        geomset{currentset} = newset;
        channelsfile = [];     
        isgeom = 0;   
    case {'.pts'}
        if isgeom,
            continue;
        end
        if currentset == 0,
            warning(sprintf('Please specify the %s-file after the .geom or .fac file for which it is intended, ignoring %s\n',ext,geomfiles{p}));
        else
            set = geomset{currentset};
            set{end+1} = geomfiles{p};
            geomset{currentset} = set;
        end
        channelsfile = [];
    end             
end

if ~isempty(channelsfile),                      % add any pending channels file to the last set if it has no channelsfile attached
    lastset = geomset{end};
    [d1,d2,ext] = fileparts(lastset{1});
    if strcmp(ext,'.channels') == 0,
        lastset{end+1} = channelsfile;
        geomset{end} = lastset;
    end
end    

geomindices = [];

for p=1:length(geomset),
    set = geomset{p};
    for q=1:length(set),
    
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
            
            for r=1:length(newGEOM), 
                if isempty(newGEOM{r}.name),
                    newGEOM{r}.name = fn;
                end
                newGEOM{r}.channels = []; 
            end
            
        
        case '.fac'
            newGEOM{1}.filename = filename;
            newGEOM{1}.name = fn;
            newGEOM{1}.pts = [];
            newGEOM{1}.cpts = [];
            newGEOM{1}.fac = ioReadFac(filename);
            newGEOM{1}.cfac = [];
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
        if ~isempty(newGEOM{r}.cpts),
            firstcpts = newGEOM{r}.cpts(1);
            if (firstcpts.dim == 1)
                if (nnz(firstcpts.cdata-round(firstcpts.cdata)) == 0) & (max(firstcpts.cdata) >  10),
                    newGEOM{r}.channels = firstcpts.cdata;
                    fprintf(1,'Assuming conductivity data of %s to be a channels file!!\n',newGEOM{r}.filename);
                end
            end    
        end
        GEOM{newindices(r)} = newGEOM{r};
    end 
    
    geomindices = [geomindices newindices];   
end

return