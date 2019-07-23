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



function runScriptFile(scriptdata_file,processingdata_file)

global SCRIPTDATA PROCESSINGDATA

mainFigure = findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU');
settingsFigure = findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS');


% s_success = loadSCRIPTDATA(scriptdata_file);
% if s_success==0
%     return
% end
% PFEIFER('updateFigure',settingsFigure)
% PFEIFER('updateFigure',mainFigure)
% 
% 
% 
% p_success = loadPROCESSINGDATA(processingdata_file);
% if p_success==0
%     return
% end
% PFEIFER('updateFigure',settingsFigure)
% PFEIFER('updateFigure',mainFigure)

executeCallback(settingsFigure,'DATAFILE',processingdata_file)
executeCallback(settingsFigure,'SCRIPTFILE',scriptdata_file)

runScript
end



