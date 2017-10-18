
function selectRungroupFiles(varargin)
if nargin > 0 && ischar(varargin{1})    % if callback is called
    feval(varargin{1},varargin{2:end});
    return
end

handle=SelectRungroupFiles;
setUpDisplay(handle)

waitfor(handle)
end


function setUpDisplay(handle)
% set up all objects of the display
global ScriptData
rungroupselection=ScriptData.RUNGROUPSELECT;



%%%% set up the listbox
obj=findobj(allchild(handle),'tag','RUNGROUPLISTBOX');
cellarray = ScriptData.('ACQLISTBOX');
if ~isempty(cellarray) 
    values = intersect(ScriptData.ACQFILENUMBER,ScriptData.RUNGROUPFILES{rungroupselection});
    set(obj,'string',cellarray,'max',length(cellarray),'value',values,'enable','on');
else
    set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
end



%%%% set up the title
obj=findobj(allchild(handle),'tag','RUNGROUPTITLE');
title=sprintf('Select Files For The Rungroup ''%s''.',ScriptData.RUNGROUPNAMES{rungroupselection});
set(obj,'string',title)

%%%% set up 'selected files'

obj=findobj(allchild(handle),'tag','RGFILESELECTION');
set(obj,'string',mynum2str(ScriptData.RUNGROUPFILES{rungroupselection}));




%%%% set up 'select label containing'
obj=findobj(allchild(handle),'tag','RUNGROUPFILECONTAIN');
set(obj,'string',ScriptData.RUNGROUPFILECONTAIN{rungroupselection});


end


%%%%%%%%%%%%%%%%%%%%%%%% callback functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function rungrouplistbox_Callback(handle)
global ScriptData
ScriptData.RUNGROUPFILES{ScriptData.RUNGROUPSELECT}=get(handle,'value');
parent=get(handle,'parent');
setUpDisplay(parent)
end


function selectAll_callback(handle)
global ScriptData

ScriptData.RUNGROUPFILES{ScriptData.RUNGROUPSELECT}=ScriptData.ACQFILENUMBER;

parent=get(handle,'parent');
setUpDisplay(parent)
end

function clearSelection_callback(handle)
global ScriptData

ScriptData.RUNGROUPFILES{ScriptData.RUNGROUPSELECT}=[];

parent=get(handle,'parent');
setUpDisplay(parent)
end


function selectLabel_callback(handle)
global ScriptData
pat = ScriptData.RUNGROUPFILECONTAIN{ScriptData.RUNGROUPSELECT};
sel = [];
for p=1:length(ScriptData.ACQINFO)
    if ~isempty(strfind(ScriptData.ACQINFO{p},pat)), sel = [sel ScriptData.ACQFILENUMBER(p)]; end
end
ScriptData.RUNGROUPFILES{ScriptData.RUNGROUPSELECT} = sel;


parent=get(handle,'parent');
setUpDisplay(parent)
end

function labelEditText_callback(handle)
global ScriptData
ScriptData.RUNGROUPFILECONTAIN{ScriptData.RUNGROUPSELECT}=get(handle,'string');
parent=get(handle,'parent');
setUpDisplay(parent)
end

function selectedFiles_callback(handle)
global ScriptData

ScriptData.RUNGROUPFILES{ScriptData.RUNGROUPSELECT}=mystr2num(get(handle,'string'));

parent=get(handle,'parent');
setUpDisplay(parent)
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