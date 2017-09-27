function varargout = winSelectRungroupFiles(varargin)
% WINSELECTRUNGROUPFILES MATLAB code for winSelectRungroupFiles.fig
%      WINSELECTRUNGROUPFILES, by itself, creates a new WINSELECTRUNGROUPFILES or raises the existing
%      singleton*.
%
%      H = WINSELECTRUNGROUPFILES returns the handle to a new WINSELECTRUNGROUPFILES or the handle to
%      the existing singleton*.
%
%      WINSELECTRUNGROUPFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINSELECTRUNGROUPFILES.M with the given input arguments.
%
%      WINSELECTRUNGROUPFILES('Property','Value',...) creates a new WINSELECTRUNGROUPFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winSelectRungroupFiles_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winSelectRungroupFiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winSelectRungroupFiles

% Last Modified by GUIDE v2.5 14-Jun-2017 11:24:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winSelectRungroupFiles_OpeningFcn, ...
                   'gui_OutputFcn',  @winSelectRungroupFiles_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before winSelectRungroupFiles is made visible.
function winSelectRungroupFiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winSelectRungroupFiles (see VARARGIN)

% Choose default command line output for winSelectRungroupFiles
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winSelectRungroupFiles wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = winSelectRungroupFiles_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function RUNGROUPLISTBOX_Callback(hObject, eventdata, handles)


function RUNGROUPLISTBOX_CreateFcn(hObject, eventdata, handles)

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton1_Callback(hObject, eventdata, handles)


function pushbutton2_Callback(hObject, eventdata, handles)


function edit1_Callback(hObject, eventdata, handles)


function edit1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton3_Callback(hObject, eventdata, handles)


function edit2_Callback(hObject, eventdata, handles)


function edit2_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton5_Callback(hObject, eventdata, handles)


function pushbutton6_Callback(hObject, eventdata, handles)


function RGFILESELECTION_Callback(hObject, eventdata, handles)


function RGFILESELECTION_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton7_Callback(hObject, eventdata, handles)


function RUNGROUPFILECONTAIN_Callback(hObject, eventdata, handles)


function RUNGROUPFILECONTAIN_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton8_Callback(hObject, eventdata, handles)
