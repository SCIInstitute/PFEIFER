function varargout = fiducializer(varargin)
% FIDUCIALIZER M-file for fiducializer.fig
%      FIDUCIALIZER, by itself, creates a new FIDUCIALIZER or raises the existing
%      singleton*.
%
%      H = FIDUCIALIZER returns the handle to a new FIDUCIALIZER or the handle to
%      the existing singleton*.
%
%      FIDUCIALIZER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIDUCIALIZER.M with the given input arguments.
%
%      FIDUCIALIZER('Property','Value',...) creates a new FIDUCIALIZER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before winFidsDisplay_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fiducializer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fiducializer

% Last Modified by GUIDE v2.5 17-Oct-2017 13:41:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fiducializer_OpeningFcn, ...
                   'gui_OutputFcn',  @fiducializer_OutputFcn, ...
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


% --- Executes just before fiducializer is made visible.
function fiducializer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fiducializer (see VARARGIN)

% Choose default command line output for fiducializer
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fiducializer wait for user response (see UIRESUME)
% uiwait(handles.FIDSDISPLAY);


% --- Outputs from this function are returned to the command line.
function varargout = fiducializer_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;






