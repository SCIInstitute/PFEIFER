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

function success = loadPROCESSINGDATA(pathString)
% update PROCESSINGDATA accourding to SCRIPTDATA in pathString
% if pathString is wrong, issue error
% basically just like load(pathString), but issues error if not a correct PROCESSINGDATA
success = 1;    

%%%% check the file if it looks like a PROCESSINGDATA file, if it is wrong, simply return
global PROCESSINGDATA
[~, ~, ext]=fileparts(pathString);
if ~strcmp('.mat',ext)
    errordlg('Not a  ''.mat'' file. File not loaded..')
    success = 0;
    return
else
    metastruct=load(pathString);
    fn=fieldnames(metastruct);

    if length(fn) ~=1
        errordlg('loaded PROCESSINGDATA.mat file contains not just one variable. File not loaded..')
        success = 0;
        return
    else
        newPROCESSINGDATA=metastruct.(fn{1});
        necFields = {'SELFRAMES', 'FILENAME'};
        for p=1:3:length(necFields)
            if ~isfield(newPROCESSINGDATA, necFields{p})
                errormsg = sprintf('The chosen file doesn''t seem to be a SCRIPTDATA file. \n It doesn''t have the %s field. File not loaded..', necFields{p});
                errordlg(errormsg);
                success = 0;
                return
            end
        end
    end
end
    
%%%%  change the global, convert newFormat if necessary
PROCESSINGDATA =  newPROCESSINGDATA;
end