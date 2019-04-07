% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.



function defaultsettings=getDefaultSettings
    defaultsettings = {'FILES2SPLIT',[],'vector',...
                    'SPLITFILECONTAIN','','string',...
                    'SPLITDIR','','string',...
                    'SPLITINTERVAL','', 'string',...
                    'CALIBRATE_SPLIT',1,'integer',...
                    'CALIBRATIONFILE','','file', ...
                    'CALIBRATIONACQ','','vector', ...
                    'CALIBRATIONACQUSED','','vector',...
                    'SCRIPTFILE','','file',...
                    'ACQLISTBOX','','listbox',...
                    'ACQFILES',[],'listboxedit',...
                    'ACQPATTERN','','string',...
                    'ACQFILENUMBER',[],'vector',...
                    'ACQINFO',{},'string',...
                    'ACQFILENAME',{},'string',...
                    'ACQNUM',0,'integer',...
                    'DATAFILE','','file',...
                    'ACQDIR','','file',...
                    'ACQCONTAIN','','string',...
                    'ACQCONTAINNOT','','string',...
                    'ACQEXT','.mat,.ac2','string',...   
                    'BASELINEWIDTH',5,'integer',...
                    'GROUPNAME','GROUP','groupstring',... 
                    'GROUPLEADS',[],'groupvector',...
                    'GROUPEXTENSION','-ext','groupstring',...
                    'GROUPBADLEADS',[],'groupvector',...
                    'GROUPDONOTPROCESS',0,'groupbool',...
                    'GROUPSELECT',0,'select',...
                    'DO_CALIBRATE',1,'bool',...
                    'DO_BLANKBADLEADS',1,'bool',...
                    'DO_SLICE',1,'bool',...
                    'DO_SLICE_USER',1,'bool',...
                    'DO_ADDBADLEADS',0,'bool',...
                    'DO_SPLIT',1,'bool',...
                    'DO_BASELINE',1,'bool',...
                    'DO_BASELINE_RMS',0,'bool',...
                    'DO_BASELINE_USER',1,'bool',...
                    'DO_DETECT_USER',1,'bool',...
                    'DO_INTEGRALMAPS',1,'bool',...
                    'DO_ACTIVATIONMAPS',1,'bool',...
                    'DO_FILTER',0,'bool',...
                    'DO_DETECT',0,'bool',...
                    'USE_MAPPINGFILE',1,'bool',...
                    'SAMPLEFREQ', 1000, 'double',...
                    'NAVIGATION','apply','string',...
                    'DISPLAYTYPE',1,'integer',...
                    'DISPLAYTYPEF',1,'integer',...
                    'DISPLAYSCALING',1,'integer',...
                    'DISPLAYSCALINGF',1,'integer',...
                    'DISPLAYOFFSET',1,'integer',...
                    'DISPLAYGRID',1,'integer',...
                    'DISPLAYGRIDF',1,'integer',...
                    'DISPLAYLABEL',1,'integer',...
                    'DISPLAYLABELF',1,'integer',...
                    'DISPLAYTYPEF1',1,'integer',...
                    'DISPLAYTYPEF2',1,'integer',...
                    'DISPLAYPACING',1,'integer',...
                    'DISPLAYPACINGF',1,'integer',...
                    'DISPLAYGROUP',1,'vector',...
                    'DISPLAYGROUPF',1,'vector',...
                    'DISPLAYSCALE',1,'integer',...
                    'CURRENTTS',1,'integer',...
                    'FIDSLOOPFIDS',1,'integer',...
                    'LOOP_ORDER',1,'vector',...
                    'FIDSAUTOACT',1,'bool',...
                    'FIDSAUTOREC',1,'bool',...
                    'MATODIR','','string',...
                    'ACTWIN',7,'integer',...               
                    'ACTDEG',3,'integer',...
                    'RECWIN',7,'integer',...
                    'RECDEG',3,'integer',...
                    'FILTER_SELECTION',1,'toolsdropdownmenu',...    % tools options
                    'BASELINE_SELECTION',1,'toolsdropdownmenu',...
                    'ACT_SELECTION',1,'toolsdropdownmenu',...
                    'REC_SELECTION',1,'toolsdropdownmenu',...
                    'RUNGROUPSELECT',0,'selectR',...            % rungroup options
                    'RUNGROUPNAMES','RUNGROUP', 'rungroupstring',...
                    'RUNGROUPFILES',[],'rungroupvector'... 
                    'RUNGROUPMAPPINGFILE','','rungroupstring',...
                    'RUNGROUPCALIBRATIONMAPPINGUSED','','rungroupstring',...
                    'RUNGROUPFILECONTAIN', '', 'rungroupstring',...
                    'DO_AUTOFIDUCIALISING', 0, 'bool',...      % autofiducialising
                    'AUTOFID_USER_INTERACTION', 0, 'bool',...
                    'ACCURACY', 0.9, 'double',...
                    'FIDSKERNELLENGTH',20,'integer',...
                    'WINDOW_WIDTH', 30, 'integer',...
                    'NTOBEFIDUCIALISED', 10, 'integer',...
                    'TRESHOLD_VAR', 50,'integer',...     
                    'USE_RMS',1,'bool',...
                    'AUTO_UPDATE_KERNELS',0,'bool',...
                    'NUM_BEATS_TO_AVGR_OVER', 5, 'integer',...
                    'NUM_BEATS_BEFORE_UPDATING', 5, 'integer',...
                    'LEADS_FOR_AUTOFIDUCIALIZING',[],'vector',...
                    'DoIndivFids',0,'bool'
            };
end
