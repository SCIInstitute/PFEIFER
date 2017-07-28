function varargout = winFidsDisplay(varargin)
% WINFIDSDISPLAY M-file for winFidsDisplay.fig
%      WINFIDSDISPLAY, by itself, creates a new WINFIDSDISPLAY or raises the existing
%      singleton*.
%
%      H = WINFIDSDISPLAY returns the handle to a new WINFIDSDISPLAY or the handle to
%      the existing singleton*.
%
%      WINFIDSDISPLAY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WINFIDSDISPLAY.M with the given input arguments.
%
%      WINFIDSDISPLAY('Property','Value',...) creates a new WINFIDSDISPLAY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winFidsDisplay_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to winFidsDisplay_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help winFidsDisplay

% Last Modified by GUIDE v2.5 11-Jun-2004 13:48:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @winFidsDisplay_OpeningFcn, ...
                   'gui_OutputFcn',  @winFidsDisplay_OutputFcn, ...
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


% --- Executes just before winFidsDisplay is made visible.
function winFidsDisplay_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to winFidsDisplay (see VARARGIN)

% Choose default command line output for winFidsDisplay
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes winFidsDisplay wait for user response (see UIRESUME)
% uiwait(handles.FIDSDISPLAY);


% --- Outputs from this function are returned to the command line.
function varargout = winFidsDisplay_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






