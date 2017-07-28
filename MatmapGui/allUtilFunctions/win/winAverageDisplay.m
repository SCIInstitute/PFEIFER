function varargout = winAverageDisplay(varargin)
% WINAVERAGEDISPLAY M-file for winAverageDisplay.fig
%      WINAVERAGEDISPLAY, by itself, creates a new WINAVERAGEDISPLAY or raises the existing
%      singleton*.
%
%      H = WINAVERAGEDISPLAY returns the handle to a new WINAVERAGEDISPLAY or the handle to
%      the existing singleton*.
%
%      WINAVERAGEDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINAVERAGEDISPLAY.M with the given input arguments.
%
%      WINAVERAGEDISPLAY('Property','Value',...) creates a new WINAVERAGEDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winAverageDisplay_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winAverageDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winAverageDisplay

% Last Modified by GUIDE v2.5 28-Dec-2004 12:37:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winAverageDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @winAverageDisplay_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before winAverageDisplay is made visible.
function winAverageDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winAverageDisplay (see VARARGIN)

% Choose default command line output for winAverageDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winAverageDisplay wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = winAverageDisplay_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function SLIDERY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SLIDERY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function SLIDERY_Callback(hObject, eventdata, handles)
% hObject    handle to SLIDERY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function SLIDERX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SLIDERX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function SLIDERX_Callback(hObject, eventdata, handles)
% hObject    handle to SLIDERX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes during object creation, after setting all properties.
function ADISPLAYOFFSET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADISPLAYOFFSET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ADISPLAYOFFSET.
function ADISPLAYOFFSET_Callback(hObject, eventdata, handles)
% hObject    handle to ADISPLAYOFFSET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ADISPLAYOFFSET contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ADISPLAYOFFSET


% --- Executes during object creation, after setting all properties.
function ADISPLAYGRID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADISPLAYGRID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ADISPLAYGRID.
function ADISPLAYGRID_Callback(hObject, eventdata, handles)
% hObject    handle to ADISPLAYGRID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ADISPLAYGRID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ADISPLAYGRID


% --- Executes during object creation, after setting all properties.
function ADISPLAYGROUP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADISPLAYGROUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ADISPLAYGROUP.
function ADISPLAYGROUP_Callback(hObject, eventdata, handles)
% hObject    handle to ADISPLAYGROUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ADISPLAYGROUP contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ADISPLAYGROUP


% --- Executes during object creation, after setting all properties.
function ADISPLAYTYPE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADISPLAYTYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ADISPLAYTYPE.
function ADISPLAYTYPE_Callback(hObject, eventdata, handles)
% hObject    handle to ADISPLAYTYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ADISPLAYTYPE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ADISPLAYTYPE


% --- Executes during object creation, after setting all properties.
function ALEADNUM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALEADNUM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ALEADNUM_Callback(hObject, eventdata, handles)
% hObject    handle to ALEADNUM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ALEADNUM as text
%        str2double(get(hObject,'String')) returns contents of ALEADNUM as a double


% --- Executes during object creation, after setting all properties.
function ADOFFSET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ADOFFSET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ADOFFSET_Callback(hObject, eventdata, handles)
% hObject    handle to ADOFFSET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ADOFFSET as text
%        str2double(get(hObject,'String')) returns contents of ADOFFSET as a double


