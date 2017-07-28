function varargout = winProcessingScriptSettings2(varargin)
% WINPROCESSINGSCRIPTSETTINGS2 M-file for winProcessingScriptSettings2.fig
%      WINPROCESSINGSCRIPTSETTINGS2, by itself, creates a new WINPROCESSINGSCRIPTSETTINGS2 or raises the existing
%      singleton*.
%
%      H = WINPROCESSINGSCRIPTSETTINGS2 returns the handle to a new WINPROCESSINGSCRIPTSETTINGS2 or the handle to
%      the existing singleton*.
%
%      WINPROCESSINGSCRIPTSETTINGS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINPROCESSINGSCRIPTSETTINGS2.M with the given input arguments.
%
%      WINPROCESSINGSCRIPTSETTINGS2('Property','Value',...) creates a new WINPROCESSINGSCRIPTSETTINGS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winProcessingScriptSettings2_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winProcessingScriptSettings2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winProcessingScriptSettings2

% Last Modified by GUIDE v2.5 07-Jan-2005 12:42:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winProcessingScriptSettings2_OpeningFcn, ...
                   'gui_OutputFcn',  @winProcessingScriptSettings2_OutputFcn, ...
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


% --- Executes just before winProcessingScriptSettings2 is made visible.
function winProcessingScriptSettings2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winProcessingScriptSettings2 (see VARARGIN)

% Choose default command line output for winProcessingScriptSettings2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winProcessingScriptSettings2 wait for user response (see UIRESUME)
% uiwait(handles.PROCESSINGSCRIPTSETTINGS);

% --- Outputs from this function are returned to the command line.
function varargout = winProcessingScriptSettings2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



