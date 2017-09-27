function varargout = winSelectSplitting(varargin)
% WINSELECTSPLITTING MATLAB code for winSelectSplitting.fig
%      WINSELECTSPLITTING, by itself, creates a new WINSELECTSPLITTING or raises the existing
%      singleton*.
%
%      H = WINSELECTSPLITTING returns the handle to a new WINSELECTSPLITTING or the handle to
%      the existing singleton*.
%
%      WINSELECTSPLITTING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINSELECTSPLITTING.M with the given input arguments.
%
%      WINSELECTSPLITTING('Property','Value',...) creates a new WINSELECTSPLITTING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winSelectSplitting_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winSelectSplitting_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winSelectSplitting

% Last Modified by GUIDE v2.5 06-Jul-2017 14:47:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winSelectSplitting_OpeningFcn, ...
                   'gui_OutputFcn',  @winSelectSplitting_OutputFcn, ...
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


% --- Executes just before winSelectSplitting is made visible.
function winSelectSplitting_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winSelectSplitting (see VARARGIN)

% Choose default command line output for winSelectSplitting
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winSelectSplitting wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = winSelectSplitting_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function SPLITFILELISTBOX_Callback(hObject, eventdata, handles)


function SPLITFILELISTBOX_CreateFcn(hObject, eventdata, handles)

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


function FILES2SPLIT_Callback(hObject, eventdata, handles)


function FILES2SPLIT_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton7_Callback(hObject, eventdata, handles)


function SPLITFILECONTAIN_Callback(hObject, eventdata, handles)


function SPLITFILECONTAIN_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton8_Callback(hObject, eventdata, handles)


function SPLITDIR_Callback(hObject, eventdata, handles)


function SPLITDIR_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pushbutton9_Callback(hObject, eventdata, handles)


function CALIBRATE_SPLIT_Callback(hObject, eventdata, handles)


function SPLITINTERVAL_Callback(hObject, eventdata, handles)


function SPLITINTERVAL_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
