function selectSplitfiles(varargin)
if nargin > 0 && ischar(varargin{1})    % if callback is called
    feval(varargin{1},varargin{2:end});
    return
end

handle=winSelectSplitting;
setUpDisplay(handle)

end


function setUpDisplay(handle)
% set up all objects of the  split display

global ScriptData
files2split=ScriptData.FILES2SPLIT;

%%%% set up the listbox
obj=findobj(allchild(handle),'tag','SPLITFILELISTBOX');
cellarray = ScriptData.('ACQLISTBOX');
if ~isempty(cellarray) 
    values = intersect(ScriptData.ACQFILENUMBER,files2split);
    set(obj,'string',cellarray,'max',length(cellarray),'value',values,'enable','on');
else
    set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
end

%%%% set up 'selected files'

obj=findobj(allchild(handle),'tag','FILES2SPLIT');
set(obj,'string',mynum2str(files2split));

%%%% set up 'select label containing'
obj=findobj(allchild(handle),'tag','SPLITFILECONTAIN');
obj.String=ScriptData.SPLITFILECONTAIN;

%%%% output directory
obj=findobj(allchild(handle),'tag','SPLITDIR');
set(obj,'string',ScriptData.SPLITDIR);


%%%% split interval
obj=findobj(allchild(handle),'tag','SPLITINTERVAL');
obj.String=num2str(ScriptData.SPLITINTERVAL);


%%%% calibrate splitfiles
obj=findobj(allchild(handle),'tag','CALIBRATE_SPLIT');
set(obj,'value',ScriptData.CALIBRATE_SPLIT);

end

%%%%%%%%%%%%%%%%%%%%%%%% callback functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function setValues(handle)
global ScriptData

%%%% first check input
switch handle.Tag
    case 'SPLITDIR'
        if ~exist(ScriptData.SPLITDIR,'dir')
            errordlg('Specified folder doesn''t exist.')
            setUpDisplay(handle.Parent);
            return
        end
    case 'SPLITINTERVAL'
        if isnan(str2double(handle.String))
            errordlg('Invalid Input. Input must be a number!')
            setUpDisplay(handle.Parent);
            return
        end
end

%%%% now set ScriptData with new user input
switch handle.Tag
    case {'CALIBRATE_SPLIT'}
        ScriptData.(handle.Tag) = handle.Value;
    case {'SPLITFILECONTAIN','SPLITDIR'}
        ScriptData.(handle.Tag)=handle.String;
    case {'FILES2SPLIT'}
        ScriptData.(handle.Tag)=mystr2num(handle.String);
    case {'SPLITFILELISTBOX'}
        ScriptData.FILES2SPLIT=handle.Value;
    case {'SPLITINTERVAL'}
        ScriptData.(handle.Tag)=str2double(handle.String);
end
setUpDisplay(handle.Parent)
end

function selectAll_callback(handle)
global ScriptData

ScriptData.FILES2SPLIT=ScriptData.ACQFILENUMBER;
setUpDisplay(handle.Parent)
end

function clearSelection_callback(handle)
global ScriptData
ScriptData.FILES2SPLIT=[];
setUpDisplay(handle.Parent)
end


function selectLabel_callback(handle)
global ScriptData
pat = ScriptData.SPLITFILECONTAIN;
sel = [];
for p=1:length(ScriptData.ACQINFO)
    if ~isempty(strfind(ScriptData.ACQINFO{p},pat))
       sel(end+1)=ScriptData.ACQFILENUMBER(p); 
    end
end
ScriptData.FILES2SPLIT= sel;

setUpDisplay(handle.Parent)
end

function Browse(handle)
disp('ja')
global ScriptData

pathstring  = uigetdir(pwd,'SELECT DIRECTORY');
if (pathstring == 0), return; end
ScriptData.SPLITDIR=pathstring;

setUpDisplay(handle);
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
    str
    vec = eval(['[' str ']']);
end


