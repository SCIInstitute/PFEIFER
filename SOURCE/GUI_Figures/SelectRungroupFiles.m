function varargout = SelectRungroupFiles(varargin)
% SELECTRUNGROUPFILES MATLAB code for SelectRungroupFiles.fig
%      SELECTRUNGROUPFILES, by itself, creates a new SELECTRUNGROUPFILES or raises the existing
%      singleton*.
%
%      H = SELECTRUNGROUPFILES returns the handle to a new SELECTRUNGROUPFILES or the handle to
%      the existing singleton*.
%
%      SELECTRUNGROUPFILES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECTRUNGROUPFILES.M with the given input arguments.
%
%      SELECTRUNGROUPFILES('Property','Value',...) creates a new SELECTRUNGROUPFILES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SelectRungroupFiles_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SelectRungroupFiles_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SelectRungroupFiles

% Last Modified by GUIDE v2.5 17-Oct-2017 13:47:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SelectRungroupFiles_OpeningFcn, ...
                   'gui_OutputFcn',  @SelectRungroupFiles_OutputFcn, ...
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


% --- Executes just before SelectRungroupFiles is made visible.
function SelectRungroupFiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SelectRungroupFiles (see VARARGIN)

% Choose default command line output for SelectRungroupFiles
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SelectRungroupFiles wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SelectRungroupFiles_OutputFcn(hObject, eventdata, handles) 
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
