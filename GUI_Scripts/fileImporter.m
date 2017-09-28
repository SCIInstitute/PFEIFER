
function fileImporter(varargin)
%%%% check if it is a callback call
if nargin && ischar(varargin{1})
    feval(varargin{1},varargin{2:end});
    return
end


%%%% initialize global FILEIMPORT
clear global FILEIMPORT
global FILEIMPORT
FILEIMPORT.JUST_ONE_VAR = 0;
FILEIMPORT.VARIABLENAME = '';
FILEIMPORT.IS_STRUCT = 0;
FILEIMPORT.FIELDNAME = '';
FILEIMPORT.INPUTDIR = '';
FILEIMPORT.OUTPUTDIR = '';
FILEIMPORT.DO_TRANSPOSE = 0;
FILEIMPORT.SELECTED_FILES=[];
FILEIMPORT.FILENAMES = {};
FILEIMPORT.PATTERN = '';      % the pattern used to retrieve potvals

%%%% open gui figure
fig_handle=winFileImporter;
FILEIMPORT.FIGURE=fig_handle;

%%%% disable stuff at the beginning
toBeDisabled={'VARIABLENAME', 'FIELDNAME', 'DO_TRANSPOSE', 'FILE_LISTBOX' };
for p=1:length(toBeDisabled)
    obj = findobj(allchild(fig_handle),'tag',toBeDisabled{p});
    obj.Enable = 'off';
end




%%%%%%%%%%%%%%% callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function INPUTDIR_Callback(cbobj, ~,~)
% callback to input directory edit text
global FILEIMPORT


%%%% retrieve pathstring and check if its correct
path = cbobj.String;
if exist(path,'dir')
    FILEIMPORT.INPUTDIR = path;
else
    cbobj.String = FILEIMPORT.INPUTDIR;
    errordlg('Input directory doesn''t exist.')
    return
end

%%%% if pathstring is correct, deal with input path
dealWithInputPath


function browse(~,~,mode)
% callback to browse input and output directory

global FILEIMPORT

path=uigetdir(pwd,sprintf('Choose %s directory',mode));
if path == 0, return, end    % if user cancels folder selection

if strcmp(mode,'input')
    FILEIMPORT.INPUTDIR = path;
    editTextObj=findobj(allchild(FILEIMPORT.FIGURE),'tag','INPUTDIR');
    editTextObj.String=path;
    dealWithInputPath
else
    FILEIMPORT.OUTPUTDIR = path;
    editTextObj=findobj(allchild(FILEIMPORT.FIGURE),'tag','OUTPUTDIR');
    editTextObj.String=path;
end


function checkoutSelectedFile(listbox_obj,~)
% callback to file listbox,   gets also called when input dir is changed
% load and investigate the selected File and set up all buttons accourding to selected file
% selectedFile is filename string
global FILEIMPORT

selectedFileName=FILEIMPORT.FILENAMES{listbox_obj.Value(1)}; % if multiple files are selected, pick the first one for evaluation
variable_popup_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag','VARIABLENAME');
variable_popup_obj.Enable = 'on';
variable_popup_obj.Value = 1;


file_data = load(fullfile(FILEIMPORT.INPUTDIR, selectedFileName));
FILEIMPORT.FILE_DATA = file_data;
variableNames=fieldnames(file_data);
FILEIMPORT.VARIABLENAME = variableNames{1};

%%%% set up the 'variable' popup menu
if length(variableNames) > 1
    FILEIMPORT.JUST_ONE_VAR = 0;
    variable_popup_obj.String = variableNames;
else
    FILEIMPORT.JUST_ONE_VAR = 1;
    entry=sprintf('%s (there is only one variable)', variableNames{1});
    variable_popup_obj.String = entry;
end

%%%% set up the 'field' popup menu
dummy='dummy';
checkoutSelectedVariable(variable_popup_obj,dummy)





function checkoutSelectedVariable(variable_popup_obj,~)
% callback to variable dropdown menu,  also gets called whenever selectedFile is changed
% set ups the 'variable' popup menu and everything regarding it


global FILEIMPORT

%%%% get the name (string) of the selected variable and put it in FILEIMPORT
variableNames=fieldnames(FILEIMPORT.FILE_DATA);
selectedVariableName = variableNames{variable_popup_obj.Value};
FILEIMPORT.VARIABLENAME = selectedVariableName;

%%%% set up field popup, initialize value to 1
field_popup_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag','FIELDNAME');
field_popup_obj.Value = 1;

%%%%% fill the field popup menu with entries
selectedVariable = FILEIMPORT.FILE_DATA.(selectedVariableName);
if isstruct(selectedVariable)
    FILEIMPORT.IS_STRUCT = 1;
    field_popup_obj.Enable = 'on';
    
    fieldNames = fieldnames(selectedVariable);
    field_popup_obj.String = fieldNames;
    
    FILEIMPORT.FIELDNAME = fieldNames{1}; % choose first field as default
    
else
    FILEIMPORT.IS_STRUCT = 0;
    field_popup_obj.Enable = 'off';
    
    field_popup_obj.String = 'Variable is already array with potential values';
end


function field_popup_callback(field_popup_obj,~)
% callback to field popup menu
global FILEIMPORT
FILEIMPORT.FIELDNAME = field_popup_obj.String{field_popup_obj.Value};


function transpose_callback(transpose_popup_obj,~)
%callback to the transpose popup menu
global FILEIMPORT
FILEIMPORT.DO_TRANSPOSE = transpose_popup_obj.Value -1;


function SELECTALL_Callback(~,~)
% callback to the select all button

global FILEIMPORT
listbox_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag', 'FILE_LISTBOX');
nFiles=length(FILEIMPORT.FILENAMES);
if nFiles < 1, return, end   %if no files in directory
listbox_obj.Value = 1:nFiles;

% dummy='dummy';
% checkoutSelectedFile(listbox_obj,dummy)


function usePattern_callback(pat_obj,~)
% callback to pattern editText bar
global FILEIMPORT
pat = pat_obj.String;

tag_list = {'VARIABLENAME','FIELDNAME'};

if isempty(pat)
    % if pattern not used, enable popup menus
    for p = 1:length(tag_list)
        obj = findobj(allchild(FILEIMPORT.FIGURE),'tag',tag_list{p});
        obj.Enable = 'on';
    end
else %else disable them
    for p = 1:length(tag_list)
        obj = findobj(allchild(FILEIMPORT.FIGURE),'tag',tag_list{p});
        obj.Enable = 'off';
    end
end
FILEIMPORT.PATTERN = pat;



%%%%%%%%%%%%%%%%% other functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function dealWithInputPath()
% enables file listbox and fills it with files from input directory
% gets called everytime input directory is changed

global FILEIMPORT
FILEIMPORT.FILENAMES = getFileNames(FILEIMPORT.INPUTDIR);

listbox_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag', 'FILE_LISTBOX');
field_popup_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag', 'FIELDNAME');
variable_popup_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag', 'VARIABLENAME');
transpose_popup_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag', 'DO_TRANSPOSE');


if isempty(FILEIMPORT.FILENAMES)
    listbox_obj.Enable = 'off';
    listbox_obj.String = 'No .mat files in this directory.';
    field_popup_obj.Enable = 'off';
    field_popup_obj.String = 'no file selected';
    variable_popup_obj.Enable = 'off';
    variable_popup_obj.String = 'no file selected';
    transpose_popup_obj.Enable ='off';
else
    listbox_obj.Enable='on';
    transpose_popup_obj.Enable ='on';
    listbox_obj.String = FILEIMPORT.FILENAMES;
    listbox_obj.Value = 1;
    dummy='dummy';
    checkoutSelectedFile(listbox_obj,dummy)
end






function convertFiles(~,~)
% callback to 'Convert selected Files' button
% this function is called after userdata is collected. It uses userdata to do everything needed.
% In particular: convert old files into new files with correct matmap format


global FILEIMPORT


%%%% check output directory
if isempty(FILEIMPORT.OUTPUTDIR)
    errordlg('No output directory provided.')
    return
end


%%%% determine which files should be converted
listbox_obj = findobj(allchild(FILEIMPORT.FIGURE),'tag', 'FILE_LISTBOX');
FILEIMPORT.SELECTED_FILES = listbox_obj.Value;


%%%% check if files are selected
if isempty(FILEIMPORT.FILENAMES) || isempty(FILEIMPORT.SELECTED_FILES)
    errordlg('No files selected to convert!')
    return
end


%%%% set up stuff for waitbar
nSelectedFiles = length(FILEIMPORT.SELECTED_FILES);
count=0;
h = waitbar(count/nSelectedFiles,'converting files...');

%%%% loop through all selected files
for fileNumber=FILEIMPORT.SELECTED_FILES
    filename = FILEIMPORT.FILENAMES{fileNumber};
    file_data=load(fullfile(FILEIMPORT.INPUTDIR, filename));
    var_names=fieldnames(file_data);
    
    if isempty(FILEIMPORT.PATTERN)   % if pattern is not used to retrieve potvals
        %%%% get the variable
        if FILEIMPORT.JUST_ONE_VAR
            variableName = var_names{1};
        else
            variableName = FILEIMPORT.VARIABLENAME;       
        end
        try
            variable=file_data.(variableName);    
        catch
            msg=sprintf('The variable ''%s'' in the file ''%s'' could not be loaded. Aborting..', variableName,filename);
            errordlg(msg)
            return
        end

        %%%% get the potvals in variable 
        if FILEIMPORT.IS_STRUCT
            try
                potvals=variable.(FILEIMPORT.FIELDNAME);
            catch
                msg = sprintf('The field ''%s'' in the variable ''%s'' in file ''%s'' does not exist. Aborting...',FILEIMPORT.FIELDNAME,variableName,filename);
                errordlg(msg)
                return
            end
        else
            potvals=variable;
        end
    else  % if a pattern is provided, use that one to retrieve potvals...
        str2beEvaluated = ['potvals = file_data.',FILEIMPORT.PATTERN, ';'];
        try
            eval(str2beEvaluated);
        catch
            msg = sprintf('The pattern provided to retrieve the potential values doesnt work for file ''%s''.', filename);
            errordlg(msg)
            return
        end
    end

    %%%% check the potvals
    if ~isnumeric(potvals)
        msg = sprintf('The potential values in the variable ''%s'' in file ''%s'' are not a matrix. Aborting...',variableName,filename);
        errordlg(msg)
        return
    end
    
    
    %%%% transpose if necessary
    if FILEIMPORT.DO_TRANSPOSE
        potvals=potvals';
    end
    
    %%%% save files with new name
    % get fullfilename
    [~,filename,~]=fileparts(filename);
    mod_filename=[filename, '-mm.mat'];
    fullfilename=fullfile(FILEIMPORT.OUTPUTDIR, mod_filename);
    
   % set up ts structure and save
   ts.potvals = potvals;
   ts.numleads = size(potvals,1);
   ts.numframes = size(potvals,2);
   
   save(fullfilename,'ts','-v6')       % -v6 is the fastest version
   
   
   %%%% update waitbar
   count = count + 1;
   waitbar(count/nSelectedFiles,h);
end
if isgraphics(h), delete(h), end




function filenames = getFileNames(path)
dir_data=dir(path);
filenames={};
for p=1:length(dir_data)
    filename=dir_data(p).name;
    if contains(filename,'.mat') % only load mat files
        filenames{end+1}=filename;
    end
end
filenames=sort(filenames);

    