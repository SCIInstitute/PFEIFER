function varargout = workbench(varargin)
% WORKBENCH M-file for workbench.fig
%      WORKBENCH, by itself, creates a new WORKBENCH or raises the existing
%      singleton*.
%
%      H = WORKBENCH returns the handle to a new WORKBENCH or the handle to
%      the existing singleton*.
%
%      WORKBENCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORKBENCH.M with the given input arguments.
%
%      WORKBENCH('Property','Value',...) creates a new WORKBENCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winProcessingScriptMenu2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to workbench_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help workbench

% Last Modified by GUIDE v2.5 17-Oct-2017 13:35:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @workbench_OpeningFcn, ...
                   'gui_OutputFcn',  @workbench_OutputFcn, ...
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








% --- Executes just before workbench is made visible.
function workbench_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to workbench (see VARARGIN)

% Choose default command line output for workbench
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if strcmp(get(hObject,'Visible'),'off')
    initialize_gui(hObject, handles);
end

% UIWAIT makes workbench wait for user response (see UIRESUME)
% uiwait(handles.PROCESSINGSCRIPTMENU);


% --- Outputs from this function are returned to the command line.
function varargout = workbench_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function initialize_gui(fig_handle, handles)





