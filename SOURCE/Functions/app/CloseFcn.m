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




function CloseFcn(~)
%callback function for the 'close' buttons.
global SCRIPTDATA PROCESSINGDATA FIDSDISPLAY SLICEDISPLAY TS

%%%% save setting
try
    if ~isempty(SCRIPTDATA.SCRIPTFILE)
     saveSettings
     disp('Saved SETTINGS before closing PFEIFER')
    else
     disp('PFEIFER closed without saving SETTINGS')
    end
catch
    %do nothing
end

%%%% delete all gui figures
delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS')); 
delete(findobj(allchild(0),'tag','SLICEDISPLAY'));
delete(findobj(allchild(0),'tag','FIDSDISPLAY'));

%%%% delete all waitbars
waitObjs = findall(0,'type','figure','tag','waitbar');
delete(waitObjs);

%%%% delete all error dialog windows
errordlgObjs = findall(0,'type','figure','tag','Msgbox_Error Dialog');
delete(errordlgObjs);

%%%% clear globals
clear global FIDSDISPLAY SLICEDISPLAY TS
end