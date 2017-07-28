function MatMap(varargin)

% FUNCTION matmap(['nomsg'],['pathonly'],['keepglobal'])
%
% DESCRIPTION
%  This function launches the matlab environment for processing time series and maps
%  The function carries no input or output as it just initialises some of the windows 
%  the program environment can be programmed and adjusted using the windows that will
%  be launched.
%
%  OPTIONS
%   'nomsg'         Do not display the welcome message
%   'keepglobal'    Do not clear the globals
%   'pathonly'      Do only the path settings
%
% SEE ALSO -

% This function carries out a few jobs
% - Firstly it initiates the path environment
%   so all functions can be found. All the subdirectories 
%   of the main directory will be added.
% - Secondly the central globals will be initiated

% Changes removed global SETTINGS, I am not using it
   nomsg = 0;
   keepglobal = 0; 

   for p=1:nargin,
       switch(varargin{p}),
           case 'nomsg'
               nomsg = 1;
           case {'keepglobal','keepts','keepgeom'},
               keepglobal = 1;
           case 'pathonly'
               nomsg = 1;
               keepglobal = 1;
       end
   end

   if keepglobal == 0, ClearGlobals; end	
   AddPaths;
   if nomsg == 0, ShowStartupMSG; end

   evalin('caller','global TS GEOM;');	% assure user can find globals

   return

function ClearGlobals 

   % just empty the globals still present

   global Program TS GEOM;

   Program = {};
   TS = {};
   GEOM = {};

   return

function ShowStartupMSG

   % Just display the startup.doc contents
   global Program;

   startupdoc = fullfile(Program.Path,'doc','startup.doc');
   startuptext = [];
   fid = fopen(startupdoc); 
   
   % in case the file not exists return
   if fid == -1, return; end
   
   while ~feof(fid), 
      startuptext = [startuptext fgets(fid)];
   end
   fclose(fid);
   disp(startuptext);
   return 

function AddPaths

   % Function adds paths to search tree of matlab

   % Who am I ? Since I have not decided on a nice acronym yet
   % keep the programming name independent. Just renaming this file
   % should do the trick

   FullProgramName = which(mfilename); % Try to find my location

   % The file runs ergo the file must exist

   [ProgramPath,ProgramName,Ext] = fileparts(FullProgramName);   
   % Put this info up there for every one to use

   global Program
   Program.Name = ProgramName;
   Program.Path = ProgramPath;

   % Now add all subdirectories of this directory to the pathlist

   Dir = dir(ProgramPath);

   for p = 1:length(Dir),
      if Dir(p).isdir == 1,
         % Since matlab does not add a path twice we do not need to worry about that
         addpath(fullfile(ProgramPath,Dir(p).name,'')); % Do it properly so it will work on both unix as Windoos
      end
   end

   % The program should run this way, keeping the current path as it is
   % In case somebody wants to run it from the data directory
   % Having a matlab path to the central directory is hence enough to start the program

   return