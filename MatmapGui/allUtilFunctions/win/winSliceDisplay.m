function varargout = winSliceDisplay(varargin)
% WINSLICEDISPLAY M-file for winSliceDisplay.fig
%      WINSLICEDISPLAY, by itself, creates a new WINSLICEDISPLAY or raises the existing
%      singleton*.
%
%      H = WINSLICEDISPLAY returns the handle to a new WINSLICEDISPLAY or the handle to
%      the existing singleton*.
%
%      WINSLICEDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINSLICEDISPLAY.M with the given input arguments.
%
%      WINSLICEDISPLAY('Property','Value',...) creates a new WINSLICEDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winSliceDisplay_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winSliceDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winSliceDisplay

% Last Modified by GUIDE v2.5 23-Dec-2003 13:46:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winSliceDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @winSliceDisplay_OutputFcn, ...
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


% --- Executes just before winSliceDisplay is made visible.
function winSliceDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winSliceDisplay (see VARARGIN)

% Choose default command line output for winSliceDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winSliceDisplay wait for user response (see UIRESUME)
% uiwait(handles.SLICEDISPLAY);


% --- Outputs from this function are returned to the command line.
function varargout = winSliceDisplay_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in NAVPREV.
function NAVPREV_Callback(hObject, eventdata, handles)
% hObject    handle to NAVPREV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NAVSTOP.
function NAVSTOP_Callback(hObject, eventdata, handles)
% hObject    handle to NAVSTOP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in NAVNEXT.
function NAVNEXT_Callback(hObject, eventdata, handles)
% hObject    handle to NAVNEXT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on selection change in DISPLAYTYPE.
function DISPLAYTYPE_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAYTYPE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAYTYPE contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DISPLAYTYPE


% --- Executes during object creation, after setting all properties.
function DISPLAYOFFSET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYOFFSET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in DISPLAYOFFSET.
function DISPLAYOFFSET_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAYOFFSET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAYOFFSET contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DISPLAYOFFSET


% --- Executes during object creation, after setting all properties.
function DISPLAYSCALING_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYSCALING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in DISPLAYSCALING.
function DISPLAYSCALING_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAYSCALING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAYSCALING contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DISPLAYSCALING


% --- Executes during object creation, after setting all properties.
function DISPLAYGRID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYGRID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in DISPLAYGRID.
function DISPLAYGRID_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAYGRID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAYGRID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DISPLAYGRID


% --- Executes during object creation, after setting all properties.
function DISPLAYZOOM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYZOOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in DISPLAYZOOM.
function DISPLAYZOOM_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAYZOOM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAYZOOM contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DISPLAYZOOM


% --- Executes during object creation, after setting all properties.
function DISPLAYGROUP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYGROUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in DISPLAYGROUP.
function DISPLAYGROUP_Callback(hObject, eventdata, handles)
% hObject    handle to DISPLAYGROUP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns DISPLAYGROUP contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DISPLAYGROUP


% --- Executes during object creation, after setting all properties.
function ALIGNENABLE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALIGNENABLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ALIGNENABLE.
function ALIGNENABLE_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNENABLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ALIGNENABLE


% --------------------------------------------------------------------
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ALIGNMETHOD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALIGNMETHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ALIGNMETHOD.
function ALIGNMETHOD_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNMETHOD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ALIGNMETHOD contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ALIGNMETHOD


% --- Executes during object creation, after setting all properties.
function popupmenu8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu8.
function popupmenu8_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu8 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu8


% --------------------------------------------------------------------
function text6_Callback(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function popupmenu9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function popupmenu9_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of popupmenu9 as text
%        str2double(get(hObject,'String')) returns contents of popupmenu9 as a double


% --------------------------------------------------------------------
function text7_Callback(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ALIGNSTARTENABLE.
function ALIGNSTARTENABLE_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNSTARTENABLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ALIGNSTARTENABLE


% --- Executes on button press in ALIGNSIZEENABLE.
function ALIGNSIZEENABLE_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNSIZEENABLE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ALIGNSIZEENABLE


% --- Executes during object creation, after setting all properties.
function ALIGNSTART_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALIGNSTART (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ALIGNSTART_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNSTART (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ALIGNSTART as text
%        str2double(get(hObject,'String')) returns contents of ALIGNSTART as a double


% --------------------------------------------------------------------
function text8_Callback(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ALIGNSTARTDETECT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALIGNSTARTDETECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ALIGNSTARTDETECT.
function ALIGNSTARTDETECT_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNSTARTDETECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ALIGNSIZE_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALIGNSIZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ALIGNSIZE_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNSIZE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ALIGNSIZE as text
%        str2double(get(hObject,'String')) returns contents of ALIGNSIZE as a double


% --------------------------------------------------------------------
function text10_Callback(hObject, eventdata, handles)
% hObject    handle to text10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ALIGNSIZEDETECT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ALIGNSIZEDETECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ALIGNSIZEDETECT.
function ALIGNSIZEDETECT_Callback(hObject, eventdata, handles)
% hObject    handle to ALIGNSIZEDETECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function DISPLAYLABEL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYLABEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




% --- Executes during object creation, after setting all properties.
function DISPLAYPACING_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DISPLAYPACING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


