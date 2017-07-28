function varargout = winProcessingScriptMenu(varargin)
% WINPROCESSINGSCRIPTMENU M-file for winProcessingScriptMenu.fig
%      WINPROCESSINGSCRIPTMENU, by itself, creates a new WINPROCESSINGSCRIPTMENU or raises the existing
%      singleton*.
%
%      H = WINPROCESSINGSCRIPTMENU returns the handle to a new WINPROCESSINGSCRIPTMENU or the handle to
%      the existing singleton*.
%
%      WINPROCESSINGSCRIPTMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINPROCESSINGSCRIPTMENU.M with the given input arguments.
%
%      WINPROCESSINGSCRIPTMENU('Property','Value',...) creates a new WINPROCESSINGSCRIPTMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winProcessingScriptMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winProcessingScriptMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winProcessingScriptMenu

% Last Modified by GUIDE v2.5 21-Dec-2004 10:36:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winProcessingScriptMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @winProcessingScriptMenu_OutputFcn, ...
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

% --- Executes just before winProcessingScriptMenu is made visible.
function winProcessingScriptMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winProcessingScriptMenu (see VARARGIN)

% Choose default command line output for winProcessingScriptMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if strcmp(get(hObject,'Visible'),'off')
    initialize_gui(hObject, handles);
end

% UIWAIT makes winProcessingScriptMenu wait for user response (see UIRESUME)
% uiwait(handles.PROCESSINGSCRIPTMENU);


% --- Outputs from this function are returned to the command line.
function varargout = winProcessingScriptMenu_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function initialize_gui(fig_handle, handles)




