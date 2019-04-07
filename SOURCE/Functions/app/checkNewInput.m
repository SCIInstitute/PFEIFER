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


function   success = checkNewInput(handle, tag)
success = 0;
global SCRIPTDATA
switch tag
    case {'ACQDIR', 'MATODIR'}
        pathstring=handle.String;
        if ~exist(pathstring,'dir')
            errordlg('Specified path doesn''t exist.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
    case {'CALIBRATIONFILE', 'RUNGROUPMAPPINGFILE'}
        pathstring=handle.String;
        if ~exist(pathstring,'file') && ~isempty(pathstring)
            errordlg('Specified file doesn''t exist.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
    case 'GROUPNAME'
        newGroupName=handle.String;
        existingGroups=SCRIPTDATA.GROUPNAME{SCRIPTDATA.RUNGROUPSELECT};

        existingGroups(SCRIPTDATA.GROUPSELECT)=[];
        if ~isempty(find(ismember(existingGroups,newGroupName), 1))
            errordlg('A group with the same groupname already exists.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
        if isempty(newGroupName)
            errordlg('Group name mustn''t be empty.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
end 
success = 1;
end
