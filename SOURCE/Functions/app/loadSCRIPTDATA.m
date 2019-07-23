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

function success = loadSCRIPTDATA(pathString)
% update SCRIPTDATA accourding to SCRIPTDATA in pathString
% if pathString is wrong, issue error
% basically just like load(pathString), but checks content of pathString and converst to new SCRIPTDATA format
success = 1;    
global SCRIPTDATA;
oldPROCESSINGDATAPath =SCRIPTDATA.DATAFILE;

%%%% check the file if it looks like a SCRIPTDATA file, if it is wrong, simply return
[~, ~, ext]=fileparts(pathString);
if ~strcmp('.mat',ext)
    errordlg('Not a  ''.mat'' file.')
    success = 0;
    return
else
    metastruct=load(pathString);
    fn=fieldnames(metastruct);

    if length(fn) ~=1
        errordlg('loaded SCRIPTDATA.mat file contains not just one variable')
        success = 0;
        return
    else
        newSCRIPTDATA=metastruct.(fn{1});
        necFields = get_necFields;
        for p=1:3:length(necFields)
            if ~isfield(newSCRIPTDATA, necFields{p})
                errormsg = sprintf('The choosen file doesn''t seem to be a SCRIPTDATA file. \n It doesn''t have the %s field.', necFields{p});
                errordlg(errormsg);
                success = 0;
                return
            end
        end
    end
end
    
%%%%  change the global, convert newFormat if necessary
SCRIPTDATA =  newSCRIPTDATA;
old2newSCRIPTDATA



%%%% check all paths and make them empty, if they don't exist.
pathTags = {'ACQDIR','MATODIR','CALIBRATIONFILE'};
for p=1:length(pathTags)
    pathTag= pathTags{p};
    path = SCRIPTDATA.(pathTag);
    if ~exist(path,'dir') && ~exist(path,'file')
        SCRIPTDATA.(pathTag) = '';
    end
end
% same for mapping files
for p=1:length(SCRIPTDATA.RUNGROUPMAPPINGFILE)
    if ~exist(SCRIPTDATA.RUNGROUPMAPPINGFILE{p},'file')
        SCRIPTDATA.RUNGROUPMAPPINGFILE{p} = '';
    end
end
% reset output files 
outTags = {'OUTFILENAME', 'ARIFILENAME', 'ITGFILENAME'};
for p=1:length(outTags)
    SCRIPTDATA.(outTags{p})={};
end







SCRIPTDATA.DATAFILE =  oldPROCESSINGDATAPath;
end
