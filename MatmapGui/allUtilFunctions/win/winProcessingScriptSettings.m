function varargout = winProcessingScriptSettings(varargin)
% WINPROCESSINGSCRIPTSETTINGS M-file for winProcessingScriptSettings.fig
%      WINPROCESSINGSCRIPTSETTINGS, by itself, creates a new WINPROCESSINGSCRIPTSETTINGS or raises the existing
%      singleton*.
%
%      H = WINPROCESSINGSCRIPTSETTINGS returns the handle to a new WINPROCESSINGSCRIPTSETTINGS or the handle to
%      the existing singleton*.
%
%      WINPROCESSINGSCRIPTSETTINGS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINPROCESSINGSCRIPTSETTINGS.M with the given input arguments.
%
%      WINPROCESSINGSCRIPTSETTINGS('Property','Value',...) creates a new WINPROCESSINGSCRIPTSETTINGS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winProcessingScriptSettings_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winProcessingScriptSettings_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winProcessingScriptSettings

% Last Modified by GUIDE v2.5 12-May-2004 13:32:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winProcessingScriptSettings_OpeningFcn, ...
                   'gui_OutputFcn',  @winProcessingScriptSettings_OutputFcn, ...
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


% --- Executes just before winProcessingScriptSettings is made visible.
function winProcessingScriptSettings_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winProcessingScriptSettings (see VARARGIN)

% Choose default command line output for winProcessingScriptSettings
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winProcessingScriptSettings wait for user response (see UIRESUME)
% uiwait(handles.PROCESSINGSCRIPTSETTINGS);

% --- Outputs from this function are returned to the command line.
function varargout = winProcessingScriptSettings_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



