function ioReadFids(varargin)
% FUNCTION ioReadFids([TSindex],filenames,options)
%
% DESCRIPTION
% This function reads the fiducials from a TSDFC-file and
% from FIDS-files. Even fiducials stored within a TSDF-file are
% processed. The fiducials from external files are read and stored
% in the fids/fidset fields. All the fields will be renumber properly.
%
%
% INPUT
% TSindex        Which timeseries need to be processed
% filenames      What is the filename array (cellarray)
% options        WHich options are specified
%
% OUTPUT -
%
% SEE ALSO ioReadTS

[files,TSindex] = ioiInputParameters(varargin);

if length(files.tsdf) > 1,
    msgError('This function only processes one tsdf-file',3);
end

%%
% Obtain the tsdffilename as key for the container file
% Specifying a tsdffile overrules the name given in the TS-structure
    
global TS;    
numts = 1;

% normally the function only works for one timeseries

if ~isempty(TSindex),							% Read the number of tseries to process
    numts = length(TSindex);
end

for r=1:numts,

    tsdfkey =[];
    
    if ~isempty(TSindex),
        if isfield(TS{TSindex(r)},'filename'),
            tsdfkey = utilFileParts(TS{TSindex(r)}.filename); 		% remove pathname and number extension
        end
    end									% key is only the filename

    if ~isempty(files.tsdf),
        tsdfkey = utilFileParts(files.tsdf{1});	  	  		% remove pathname and number extension
    end

    fids = [];								% clear these structures
    fidset = {};							
    
    % If some old set is still there
    % Put it on front of the list
    
    if (~isempty(TSindex) & (nargout == 0))
        if isfield(TS{TSindex(r)},'fids'),
            fids = TS{TSindex(r)}.fids;
            fidset = TS{TSindex(r)}.fidset;
        end
    end    
    
    %%
    % Add container files first
    % Scan through all container files and add them all
    % recompute the fidset numbers 


    if ~isempty(tsdfkey),
        for p = 1:length(files.tsdfc),
            if mexIsKeyTSDFC(files.tsdfc{p},tsdfkey),
                [f,fi] = mexReadTSDFC(files.tsdfc{p},tsdfkey);
                for q=1:length(f), f(q).fidset = f(q).fidset + length(fidset); end
                fids = [fids f]; 
                fidset = [fidset fi];
            end    
        end
    end
  
    %%
    % Add the fids files. In order to be sure that the fids file corresponds to the
    % timeseries data the filename base should be the same. Ohterwise ignore the
    % fidsfile  

    [dummy,tsdfname] = fileparts(tsdfkey);				% remove the extension .tsdf
    for p = 1:length(files.fids),
        [dummy,fidsname] = fileparts(files.fids{p});		
        if strcmp(fidsname,tsdfname) == 1,				% only when the name corresponds, we are using this fids file
            [f,fi] = ioReadFidsFile(files.fids{p});
            for q=1:length(f), f(q).fidset = f(q).fidset + length(fidset); end
            fids = [fids f]; fidset = [fidset fi];
         end   
    end

   if ~isempty(fids),
            
       TS{TSindex(r)}.fids = fids;
       TS{TSindex(r)}.fidset = fidset;
            
    end
end
    
return
    
