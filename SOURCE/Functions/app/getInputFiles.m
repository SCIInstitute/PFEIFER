% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


function getInputFiles
% this function finds all files in SCRIPTDATA.ACQDIR (the input directory) and updates the following fields of SCRIPTDATA accordingly:
% - SCRIPTDATA.ACQFILENUMBER     double array of the form [1:NumberOfFilesDisplayedInListbox]
% - SCRIPTDATA.ACQLISTBOX        cellarray with strings for the listbox
% - SCRIPTDATA.ACQFILENAME       cellarray with all filenames in ACQDIR
% - SCRIPTDATA.ACQINFO           cellarray with a label for each file
% - SCRIPTDATA.ACQFILES          double array of selected files in the listbox in main menu gui figure

global SCRIPTDATA TS;

if isempty(SCRIPTDATA.ACQDIR), return, end  % if no input directory selected so far, just return

%%%% create a cell array with all the filenames in the listbox, that are at the moment selected. This is needed to select them again in case they are also in the new input dir
oldfilenames = {};
if ~isempty(SCRIPTDATA.ACQFILES)
    for p=1:length(SCRIPTDATA.ACQFILES)
        if SCRIPTDATA.ACQFILES(p) <= length(SCRIPTDATA.ACQFILENAME)
            oldfilenames{end+1} = SCRIPTDATA.ACQFILENAME{SCRIPTDATA.ACQFILES(p)};
        end
    end
end
%oldfilenames is now  cellarray with filenamestrings of only the
%selected files in listbox, eg {'Run0005.mat','Run0012.mat' }, not of all files in dir





%%%% change into SCRIPTDATA.ACQDIR,if it exists and is not empty
olddir = pwd;
if isempty(SCRIPTDATA.ACQDIR)
    errordlg('input directory doesn''t exist. No files loaded..')
    return
else
    cd(SCRIPTDATA.ACQDIR)
end


%%%% set up a cell array filenames with all the filenames in folder
filenames = {};
exts = commalist(SCRIPTDATA.ACQEXT);  % create cellarray with all the allowed file extensions specified by the user
for p=1:length(exts)
    d = dir(sprintf('*%s',exts{p}));
    for q= 1:length(d)
        filenames{end+1} = d(q).name;
    end
end
% filenames is cellarray with all the filenames of files in folder, e.g. {'Ran0001.ac2'    'Ru0009.ac2'}

%%%% get rid of files that don't belong here, also sort files
filenames(strncmp('._',filenames,2))=[];  % necessary to get rid of weird ghost files on server
filenames = sort(filenames);


%%%% initialize/clear old entries
SCRIPTDATA.ACQFILENUMBER = [];
SCRIPTDATA.ACQLISTBOX= {};
SCRIPTDATA.ACQFILENAME = {};
SCRIPTDATA.ACQINFO = {};
SCRIPTDATA.ACQFILES = [];

if isempty(filenames)
    cd(olddir)
    return
end
h = waitbar(0,'INDEXING AND READING FILES','Tag','waitbar'); drawnow;
nFiles=length(filenames);
for p = 1:nFiles  
    
    %%%% load filename in various ways, depending if .mat .ac2..
    %%%% with/without 'ts_info...,  adds ts_info if its missing
    clear ts ts_info
    [~,~,ext]=fileparts(filenames{p});
    if strcmp(ext,'.mat')
        warning('off','all')  % supress warning, if 'ts_info' not in mat
        load(filenames{p},'ts_info')
        warning('on','all')
        if exist('ts_info','var')
            ts=ts_info;

        else  % if no 'ts_info', load ts, but append 'ts_info' to mat file
            load(filenames{p},'ts')
            if ~exist('ts','var')
                msg=sprintf('The file %s in the input directory does not contain a ''ts'' or ''ts_info'' structure. Aborting file loading..',filenames{p});
                errordlg(msg)
                return
            end

            % create and append ts_info to .mat file
            fn=fieldnames(ts);
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts_info.(fn{q})=ts.(fn{q});
            end   
            save(filenames{p},'ts_info','-append')  
        end
    elseif strcmp(ext,'.ac2')
        index=ioReadTS(filenames{p});
        ts=TS{index};
        TS{index}=[];
    else
        msg=sprintf('The file %s cannot be loaded, since it''s not a .mat or .ac2 file. Aborting file loading...',filenames{p});
        errordlg(msg)
        return
    end
    
    
    %%%% update/check ts.filename and ts_info.filename
    ts.filename = filenames{p};


    if ~isfield(ts,'time'), ts.time = 'none'; end
    if ~isfield(ts,'label'), ts.label = 'no label'; end
    if ~isfield(ts,'filename')
        errordlg(sprintf('Problems occured reading file %s. This file does not have the filename field.  Aborting to load files...',filenames{p}));
        return
    end
    
    ts.label=myStrTrim(ts.label); %necessary, because original strings have weird whitespaces that are not recognized as whitespaces.. really weird!
    SCRIPTDATA.ACQFILENUMBER(p) = p;      

    %%%% find out which rungroup p belongs to
    rungroup='';
    for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
        if ismember(p, SCRIPTDATA.RUNGROUPFILES{rungroupIdx})
            rungroup=SCRIPTDATA.RUNGROUPNAMES{rungroupIdx};
            break
        end
    end

    ts.time=myStrTrim(ts.time);   % use of myStrTrim for the same reason as above..     

    SCRIPTDATA.ACQLISTBOX{p} = sprintf('%04d %20s %10s %10s %20s',SCRIPTDATA.ACQFILENUMBER(p),ts.filename,rungroup, ts.time,ts.label);
    SCRIPTDATA.ACQFILENAME{p} = ts.filename;
    SCRIPTDATA.ACQINFO{p} = ts.label;
    if isgraphics(h), waitbar(p/nFiles,h); end
end

[~,~,SCRIPTDATA.ACQFILES] = intersect(oldfilenames,SCRIPTDATA.ACQFILENAME);
SCRIPTDATA.ACQFILES = sort(SCRIPTDATA.ACQFILES);



if isgraphics(h), waitbar(1,h); end
drawnow;
if isgraphics(h), delete(h); end
cd(olddir);

end
