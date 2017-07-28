function varargout = winSelectLoopOrder(varargin)
% WINSELECTLOOPORDER MATLAB code for winSelectLoopOrder.fig
%      WINSELECTLOOPORDER, by itself, creates a new WINSELECTLOOPORDER or raises the existing
%      singleton*.
%
%      H = WINSELECTLOOPORDER returns the handle to a new WINSELECTLOOPORDER or the handle to
%      the existing singleton*.
%
%      WINSELECTLOOPORDER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINSELECTLOOPORDER.M with the given input arguments.
%
%      WINSELECTLOOPORDER('Property','Value',...) creates a new WINSELECTLOOPORDER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winSelectLoopOrder_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winSelectLoopOrder_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winSelectLoopOrder

% Last Modified by GUIDE v2.5 12-Jun-2017 15:54:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winSelectLoopOrder_OpeningFcn, ...
                   'gui_OutputFcn',  @winSelectLoopOrder_OutputFcn, ...
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


% --- Executes just before winSelectLoopOrder is made visible.
function winSelectLoopOrder_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winSelectLoopOrder (see VARARGIN)

% Choose default command line output for winSelectLoopOrder
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winSelectLoopOrder wait for user response (see UIRESUME)
% uiwait(handles.loopOrderWindow);


% --- Outputs from this function are returned to the command line.
function varargout = winSelectLoopOrder_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function LOOP_ORDER_Callback(hObject, eventdata, handles)


function LOOP_ORDER_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
