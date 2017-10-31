
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




function selectSplitfiles(varargin)
if nargin > 0 && ischar(varargin{1})    % if callback is called
    feval(varargin{1},varargin{2:end});
    return
end

handle=FileSplitting;
setUpDisplay(handle)

end


function setUpDisplay(guiFigureObj)
% set up all objects of the  split display

global SCRIPTDATA
files2split=SCRIPTDATA.FILES2SPLIT;

%%%% set up the listbox
obj=findobj(allchild(guiFigureObj),'tag','SPLITFILELISTBOX');
cellarray = SCRIPTDATA.('ACQLISTBOX');
if ~isempty(cellarray) 
    values = intersect(SCRIPTDATA.ACQFILENUMBER,files2split);
    if length(cellarray) == 1   % make sure maxValue is not 1, even if there is only one file in directory. If listboxObj.Max == 1, it is not possible to have 'nothing' selected..
        maxVal=3;
    else
        maxVal = length(cellarray);
    end
    set(obj,'string',cellarray,'max',maxVal,'value',values,'enable','on');
else
    set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
end

%%%% set up 'selected files'

obj=findobj(allchild(guiFigureObj),'tag','FILES2SPLIT');
set(obj,'string',mynum2str(files2split));

%%%% set up 'select label containing'
obj=findobj(allchild(guiFigureObj),'tag','SPLITFILECONTAIN');
obj.String=SCRIPTDATA.SPLITFILECONTAIN;

%%%% output directory
obj=findobj(allchild(guiFigureObj),'tag','SPLITDIR');
set(obj,'string',SCRIPTDATA.SPLITDIR);


%%%% split interval
obj=findobj(allchild(guiFigureObj),'tag','SPLITINTERVAL');
obj.String=num2str(SCRIPTDATA.SPLITINTERVAL);


%%%% calibrate splitfiles
obj=findobj(allchild(guiFigureObj),'tag','CALIBRATE_SPLIT');
set(obj,'value',SCRIPTDATA.CALIBRATE_SPLIT);

end

%%%%%%%%%%%%%%%%%%%%%%%% callback functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function setValues(cbObj)
global SCRIPTDATA

%%%% first check input
switch cbObj.Tag
    case 'SPLITDIR'
        if ~exist(cbObj.String,'dir')
            errordlg('Specified folder doesn''t exist.')
            setUpDisplay(cbObj.Parent);
            return
        end
    case 'SPLITINTERVAL'
        if isnan(str2double(cbObj.String))
            errordlg('Invalid Input. Input must be a number!')
            setUpDisplay(cbObj.Parent);
            return
        end
end

%%%% now set SCRIPTDATA with new user input
switch cbObj.Tag
    case {'CALIBRATE_SPLIT'}
        SCRIPTDATA.(cbObj.Tag) = cbObj.Value;
    case {'SPLITFILECONTAIN','SPLITDIR'}
        SCRIPTDATA.(cbObj.Tag)=cbObj.String;
    case {'FILES2SPLIT'}
        SCRIPTDATA.(cbObj.Tag)=mystr2num(cbObj.String);
    case {'SPLITFILELISTBOX'}
        SCRIPTDATA.FILES2SPLIT=cbObj.Value;
    case {'SPLITINTERVAL'}
        SCRIPTDATA.(cbObj.Tag)=str2double(cbObj.String);
end
setUpDisplay(cbObj.Parent)
end

function selectAll_callback(handle)
global SCRIPTDATA

SCRIPTDATA.FILES2SPLIT=SCRIPTDATA.ACQFILENUMBER;
setUpDisplay(handle.Parent)
end

function clearSelection_callback(handle)
global SCRIPTDATA
SCRIPTDATA.FILES2SPLIT=[];
setUpDisplay(handle.Parent)
end


function selectLabel_callback(handle)
global SCRIPTDATA
pat = SCRIPTDATA.SPLITFILECONTAIN;
sel = [];
for p=1:length(SCRIPTDATA.ACQINFO)
    if ~isempty(strfind(SCRIPTDATA.ACQINFO{p},pat))
       sel(end+1)=SCRIPTDATA.ACQFILENUMBER(p); 
    end
end
SCRIPTDATA.FILES2SPLIT= sel;

setUpDisplay(handle.Parent)
end

function Browse(cbObj)
disp('ja')
global SCRIPTDATA

pathstring  = uigetdir(pwd,'SELECT DIRECTORY');
if (pathstring == 0), return; end
SCRIPTDATA.SPLITDIR=pathstring;

setUpDisplay(cbObj.Parent);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% the main 'split files' callback %%%%%%%%%%%%%%%%%%%%
function splitFiles(handle)
% callback to 'Split Files'


%%%% get all necessary inputs. If you plan to use this function outside of PFEIFER, this (and 'frames', see getFrames function) is all you need to change:
global SCRIPTDATA
inputdir=SCRIPTDATA.ACQDIR;
outputdir=SCRIPTDATA.SPLITDIR;
allInputFiles=SCRIPTDATA.ACQFILENAME; %cell array of all files that are converted into .mat files, not just the ones to be splitted
calfile=SCRIPTDATA.CALIBRATIONFILE;  % path to .cal8 file
DO_CALIBRATION=SCRIPTDATA.CALIBRATE_SPLIT;  % do you want to calibrate files as you convert them into .mat files?
idx2beSplitted=SCRIPTDATA.FILES2SPLIT;  % indices of the files in allInputFiles, that will be splitted..
intervalLength=SCRIPTDATA.SAMPLEFREQ*SCRIPTDATA.SPLITINTERVAL;

%%%% start here, first check input:
if isempty(outputdir)
    errordlg('No output dir for matfiles given.')
    return
elseif DO_CALIBRATION && isempty(calfile)
    errordlg('No calfile for calibration provided.')
    return
elseif isempty(SCRIPTDATA.SPLITINTERVAL)
    errordlg('The length of a splitted file was not given.')
    return
end


%%%% set up stuff
clear global TS  % just to be sure
global TS


h=waitbar(0,'loading & splitting files..');

fileCount = 1;
%%%% read in, split and save files
for p=1:length(allInputFiles)
    TS={};
    
    %%%% load file
    olddir=cd(inputdir);
    if DO_CALIBRATION
        TSindex=ioReadTS(allInputFiles{p},calfile);
    else
        TSindex=ioReadTS(allInputFiles{p});
    end
    cd(olddir);
    
  
    %%%% split the file
    if ismember(p, idx2beSplitted)  % if file should be splitted
        %%%% determine where file is to be splitted;
        nFrames = TS{TSindex}.numframes;
        nSplitIntervals = ceil(nFrames/intervalLength);  % file will be splitted into nSplitIntervals files
        
        for interval = 1:nSplitIntervals-1
            %%%% set up the new ts structure
            fn=fieldnames(TS{TSindex});
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts.(fn{q})=TS{TSindex}.(fn{q});
            end   
            ts.numframes = intervalLength;
            ts.origin = [TS{TSindex}.filename '_' sprintf('%03d',interval)];
            ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];  % the new filename          
            fileCount = fileCount + 1; 
            
            
            %%%%% put potvals in new ts and delte them in old ts
            ts.potvals = TS{TSindex}.potvals(:,1:intervalLength);  
            TS{TSindex}.potvals(:,1:intervalLength) = [];
            
            
            %%%% get ts_info
            fn=fieldnames(ts);
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts_info.(fn{q})=ts.(fn{q});
            end   
            
            %%%% save the new ts and ts_info and clear them   
            fname=fullfile(outputdir,ts.filename);
            save(fname,'ts','ts_info','-v6')
            fprintf('SAVING FILE: %s\n',ts.filename)
            clear ts ts_info
            
            if isgraphics(h), waitbar(((p-1)+interval/nSplitIntervals)/length(allInputFiles),h), end
        end
        
        %%%%% now also save the last part of old ts (which has length < intervalLength)
        nRemindingFrames = size(TS{TSindex}.potvals,2);
        
        if nRemindingFrames > 300  % if there are enough reminding frames so it makes sense to save them..
            %%%% set up new ts structure
            fn=fieldnames(TS{TSindex});
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts.(fn{q})=TS{TSindex}.(fn{q});
            end
            
            %%%% set up ts.potvals, origin and filename
            ts.potvals =  TS{TSindex}.potvals;
            ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];  % the new filename          
            fileCount = fileCount + 1;
            ts.origin = [TS{TSindex}.filename '_' sprintf('%03d',nSplitIntervals)];
           
            TS{TSindex} = 1; % free memory
            
            %%%% get ts_info
            fn=fieldnames(ts);
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts_info.(fn{q})=ts.(fn{q});
            end 
            
            
            %%%% save the new ts and ts_info and clear them   
            fname=fullfile(outputdir,ts.filename);
            save(fname,'ts','ts_info','-v6')
            fprintf('SAVING FILE: %s\n',ts.filename)
            clear ts ts_info
        end
    else  % if file is not to be splitted;
        ts=TS{TSindex};
        ts.origin =  ts.filename;
        TS{TSindex} = 1; % free memory
        ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];
        fileCount = fileCount + 1;
        

        %get ts_info
        fn=fieldnames(ts);
        for q=1:length(fn)
            if strcmp(fn{q},'potvals'), continue, end
            ts_info.(fn{q})=ts.(fn{q});
        end
        
        fname=fullfile(outputdir,ts.filename);
        save(fname,'ts','ts_info','-v6')
        fprintf('SAVING FILE: %s\n',ts.filename)
        clear ts ts_info
    end
    if isgraphics(h), waitbar(p/length(allInputFiles),h), end
end
clear global TS
clear ts ts_info
if isgraphics(handle), delete(handle), end
if isgraphics(h), delete(h), end
end


%%%%%%%%%%%%%%%%%%%%%%%% utility functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = mynum2str(vec)
    % converts arrays in strings
    % also outputs special format for the listboxedit, like [1:5]
    if length(vec) == 1
        str = num2str(vec);
    else
        if nnz(vec-round(vec)) > 0
            str = num2str(vec);
        else
            vec = sort(vec);
            str = '';
            ind = 1;
            len = length(vec);
            while (ind <= len)
                if (len-ind) > 0
                     step = vec(ind+1)-vec(ind);
                     k = 1;
                     while (k+ind+1 <= len)
                         if vec(ind+k+1)-vec(ind+k) == step
                             k = k + 1;
                         else
                             break;
                         end
                     end
                     if k > 1
                         if step == 1
                            str = [str sprintf('%d:%d ',vec(ind),vec(ind+k))]; ind = ind + k+1;
                        else
                            str = [str sprintf('%d:%d:%d ',vec(ind),step,vec(ind+k))]; ind = ind + k+1;
                        end
                     else
                         str = [str sprintf('%d ',vec(ind))]; ind = ind + 1;
                     end
                 else
                     for p = ind:len
                         str = [str sprintf('%d ',vec(p))]; ind = len + 1;
                     end
                 end
             end
         end
     end
end

function vec = mystr2num(str)
    vec = eval(['[' str ']']);
end