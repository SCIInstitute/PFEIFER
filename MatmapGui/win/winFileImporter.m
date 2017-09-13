function varargout = winFileImporter(varargin)
%WINFILEIMPORTER MATLAB code file for winFileImporter.fig
%      WINFILEIMPORTER, by itself, creates a new WINFILEIMPORTER or raises the existing
%      singleton*.
%
%      H = WINFILEIMPORTER returns the handle to a new WINFILEIMPORTER or the handle to
%      the existing singleton*.
%
%      WINFILEIMPORTER('Property','Value',...) creates a new WINFILEIMPORTER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to winFileImporter_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      WINFILEIMPORTER('CALLBACK') and WINFILEIMPORTER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in WINFILEIMPORTER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winFileImporter

% Last Modified by GUIDE v2.5 29-Aug-2017 19:23:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winFileImporter_OpeningFcn, ...
                   'gui_OutputFcn',  @winFileImporter_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function winFileImporter_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for winFileImporter
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winFileImporter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function varargout = winFileImporter_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


function INPUTDIR_Callback(hObject, eventdata, handles)


function INPUTDIR_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function OUTPUTDIR_Callback(hObject, eventdata, handles)


function OUTPUTDIR_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function VARIABLENAME_Callback(hObject, eventdata, handles)


function VARIABLENAME_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function INPUTDIR_BROWSE_Callback(hObject, eventdata, handles)


function OUTPUTDIR_BROWSE_Callback(hObject, eventdata, handles)


function FIELDNAME_Callback(hObject, eventdata, handles)


function FIELDNAME_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function DO_TRANSPOSE_Callback(hObject, eventdata, handles)


function DO_TRANSPOSE_CreateFcn(hObject, eventdata, handles)

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function FILE_LISTBOX_Callback(hObject, eventdata, handles)


function FILE_LISTBOX_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function SELECTALL_Callback(hObject, eventdata, handles)


function pushbutton4_Callback(hObject, eventdata, handles)


function USE_PATTERN_Callback(hObject, eventdata, handles)


function USE_PATTERN_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton5_Callback(hObject, eventdata, handles)
