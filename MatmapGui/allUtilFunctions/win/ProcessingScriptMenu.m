function varargout = ProcessingScriptMenu(varargin)
% PROCESSINGSCRIPTMENU M-file for ProcessingScriptMenu.fig
%      PROCESSINGSCRIPTMENU, by itself, creates a new PROCESSINGSCRIPTMENU or raises the existing
%      singleton*.
%
%      H = PROCESSINGSCRIPTMENU returns the handle to a new PROCESSINGSCRIPTMENU or the handle to
%      the existing singleton*.
%
%      PROCESSINGSCRIPTMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCESSINGSCRIPTMENU.M with the given input arguments.
%
%      PROCESSINGSCRIPTMENU('Property','Value',...) creates a new PROCESSINGSCRIPTMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProcessingScriptMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProcessingScriptMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProcessingScriptMenu

% Last Modified by GUIDE v2.5 16-Oct-2003 14:42:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcessingScriptMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcessingScriptMenu_OutputFcn, ...
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

% --- Executes just before ProcessingScriptMenu is made visible.
function ProcessingScriptMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ProcessingScriptMenu (see VARARGIN)

% Choose default command line output for ProcessingScriptMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if strcmp(get(hObject,'Visible'),'off')
    initialize_gui(hObject, handles);
end

% UIWAIT makes ProcessingScriptMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ProcessingScriptMenu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function density_CreateFcn(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function density_Callback(hObject, eventdata, handles)
% hObject    handle to density (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of density as text
%        str2double(get(hObject,'String')) returns contents of density as a double
density = str2double(get(hObject, 'String'));
if isnan(density)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

data = getappdata(gcbf, 'metricdata');
data.density = density;
setappdata(gcbf, 'metricdata', data);

% --- Executes during object creation, after setting all properties.
function volume_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function volume_Callback(hObject, eventdata, handles)
% hObject    handle to volume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of volume as text
%        str2double(get(hObject,'String')) returns contents of volume as a double
volume = str2double(get(hObject, 'String'));
if isnan(volume)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end

data = getappdata(gcbf, 'metricdata');
data.volume = volume;
setappdata(gcbf, 'metricdata', data);

% --- Executes during object creation, after setting all properties.
function mass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function mass_Callback(hObject, eventdata, handles)
% hObject    handle to mass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mass as text
%        str2double(get(hObject,'String')) returns contents of mass as a double


% --- Executes on button press in english.
function english_Callback(hObject, eventdata, handles)
% hObject    handle to english (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of english

set(handles.english, 'Value', 1);
set(handles.si, 'Value', 0);

set(handles.text4, 'String', 'lb/cu.in');
set(handles.text5, 'String', 'cu.in');
set(handles.text6, 'String', 'lb');

% --- Executes on button press in si.
function si_Callback(hObject, eventdata, handles)
% hObject    handle to si (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of si

set(handles.english, 'Value', 0);
set(handles.si, 'Value', 1);

set(handles.text4, 'String', 'kg/cu.m');
set(handles.text5, 'String', 'cu.m');
set(handles.text6, 'String', 'kg');

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = getappdata(gcbf, 'metricdata');

mass = data.density * data.volume;
set(handles.mass, 'String', mass);

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

initialize_gui(gcbf, handles);



function initialize_gui(fig_handle, handles)
data.density = 0;
data.volume = 0;
setappdata(fig_handle, 'metricdata', data);

set(handles.density, 'String', data.density);
set(handles.volume, 'String', data.volume);
set(handles.mass, 'String', 0);

set(handles.english, 'Value', 1);
set(handles.si, 'Value', 0);

set(handles.text4, 'String', 'lb/cu.in');
set(handles.text5, 'String', 'cu.in');
set(handles.text6, 'String', 'lb');


% --- Executes during object creation, after setting all properties.
function ACQFILES_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ACQFILES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ACQFILES.
function ACQFILES_Callback(hObject, eventdata, handles)
% hObject    handle to ACQFILES (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ACQFILES contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ACQFILES


% --- Executes on button press in SELECTALL.
function SELECTALL_Callback(hObject, eventdata, handles)
% hObject    handle to SELECTALL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CLEARSELECTION.
function CLEARSELECTION_Callback(hObject, eventdata, handles)
% hObject    handle to CLEARSELECTION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ACQNUMBERS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ACQNUMBERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ACQNUMBERS_Callback(hObject, eventdata, handles)
% hObject    handle to ACQNUMBERS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ACQNUMBERS as text
%        str2double(get(hObject,'String')) returns contents of ACQNUMBERS as a double


% --- Executes on button press in SELECTLABEL.
function SELECTLABEL_Callback(hObject, eventdata, handles)
% hObject    handle to SELECTLABEL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function LABELPATTERN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LABELPATTERN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function LABELPATTERN_Callback(hObject, eventdata, handles)
% hObject    handle to LABELPATTERN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LABELPATTERN as text
%        str2double(get(hObject,'String')) returns contents of LABELPATTERN as a double


% --- Executes on button press in USERINTERACTION.
function USERINTERACTION_Callback(hObject, eventdata, handles)
% hObject    handle to USERINTERACTION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of USERINTERACTION


% --- Executes on button press in CALIBRATE.
function CALIBRATE_Callback(hObject, eventdata, handles)
% hObject    handle to CALIBRATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CALIBRATE


% --- Executes on button press in SLICE.
function SLICE_Callback(hObject, eventdata, handles)
% hObject    handle to SLICE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SLICE


% --- Executes on button press in CALIBRATE.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to CALIBRATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CALIBRATE


% --- Executes on button press in RECOMPUTECALIBRATION.
function RECOMPUTECALIBRATION_Callback(hObject, eventdata, handles)
% hObject    handle to RECOMPUTECALIBRATION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RECOMPUTECALIBRATION


% --- Executes on button press in SLICE.
function checkbox8_Callback(hObject, eventdata, handles)
% hObject    handle to SLICE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SLICE


% --- Executes on button press in SLICE_USER.
function SLICE_USER_Callback(hObject, eventdata, handles)
% hObject    handle to SLICE_USER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SLICE_USER


% --- Executes on button press in SLICE_AUTODETECT.
function SLICE_AUTODETECT_Callback(hObject, eventdata, handles)
% hObject    handle to SLICE_AUTODETECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SLICE_AUTODETECT


% --- Executes on button press in SPLIT.
function SPLIT_Callback(hObject, eventdata, handles)
% hObject    handle to SPLIT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SPLIT


% --- Executes on button press in DETECT.
function DETECT_Callback(hObject, eventdata, handles)
% hObject    handle to DETECT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DETECT


% --- Executes on button press in DETECT_USER.
function DETECT_USER_Callback(hObject, eventdata, handles)
% hObject    handle to DETECT_USER (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DETECT_USER


% --- Executes on button press in DETECT_LOADTSDFC.
function DETECT_LOADTSDFC_Callback(hObject, eventdata, handles)
% hObject    handle to DETECT_LOADTSDFC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DETECT_LOADTSDFC


% --- Executes on button press in DETECT_AUTO.
function DETECT_AUTO_Callback(hObject, eventdata, handles)
% hObject    handle to DETECT_AUTO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DETECT_AUTO


% --- Executes on button press in INTERPOLATE.
function INTERPOLATE_Callback(hObject, eventdata, handles)
% hObject    handle to INTERPOLATE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of INTERPOLATE


% --- Executes on button press in INTEGRALMAPS.
function INTEGRALMAPS_Callback(hObject, eventdata, handles)
% hObject    handle to INTEGRALMAPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of INTEGRALMAPS


% --- Executes on button press in BLANKBADLEADS.
function BLANKBADLEADS_Callback(hObject, eventdata, handles)
% hObject    handle to BLANKBADLEADS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of BLANKBADLEADS


% --- Executes on button press in SLICE_AUTOALIGN.
function SLICE_AUTOALIGN_Callback(hObject, eventdata, handles)
% hObject    handle to SLICE_AUTOALIGN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SLICE_AUTOALIGN


% --- Executes on button press in DETECT_PACING.
function DETECT_PACING_Callback(hObject, eventdata, handles)
% hObject    handle to DETECT_PACING (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of DETECT_PACING


% --- Executes on button press in ACTIVATION.
function ACTIVATION_Callback(hObject, eventdata, handles)
% hObject    handle to ACTIVATION (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ACTIVATION


% --- Executes on button press in ACTIVATIONMAPS.
function ACTIVATIONMAPS_Callback(hObject, eventdata, handles)
% hObject    handle to ACTIVATIONMAPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ACTIVATIONMAPS


% --- Executes on button press in SEPARATEACTMAPS.
function SEPARATEACTMAPS_Callback(hObject, eventdata, handles)
% hObject    handle to SEPARATEACTMAPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SEPARATEACTMAPS


% --- Executes on button press in RUNSCRIPT.
function RUNSCRIPT_Callback(hObject, eventdata, handles)
% hObject    handle to RUNSCRIPT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radiobutton11.
function radiobutton11_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton11


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


