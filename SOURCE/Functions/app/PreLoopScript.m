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




function success = PreLoopScript
    %this function is called right before main loop starts. Its jobs are: 
%       - checks if mapfile etc exist
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - set up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
    
success = 0;
global SCRIPTDATA PROCESSINGDATA   
SCRIPTDATA.ALIGNSTART = 'detect';
SCRIPTDATA.ALIGNSIZE = 'detect';


%%%% -create filenames, which holds all the filename-strings of only the files selected by user.  
% -create index, which holds all the indexes of filenames, that contain '-acq' or '.ac2'
filenames = SCRIPTDATA.ACQFILENAME(SCRIPTDATA.ACQFILES);    % only take es selected by the user
index = [];
for r=1:length(filenames)
    if ~isempty(strfind(filenames{r},'.acq')) || ~isempty(strfind(filenames{r}, '.ac2')), index = [index r]; end
end   


%%%% check if input directory is provided and valid
if ~exist(SCRIPTDATA.MATODIR,'dir')
    errordlg('Provided output directory does not exist. Aborting...')
    return
end



%%%% check if at leat one lead is provided for each group
for RGIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
    for grIdx=1:length(SCRIPTDATA.GROUPNAME{RGIdx})
        if isempty(SCRIPTDATA.GROUPLEADS{RGIdx}{grIdx})
            success=0;
            errordlg('Not all groups in all Rungroups have their Lead Numbers specified.')
            return
        end
    end
end




if ~isempty(index)
    %%%%%%  generate a calibration file if neccessary %%%%%%%%%%%%%%%
    if SCRIPTDATA.DO_CALIBRATE == 1  % if 'calibrate Signall' button is on
        %%% if no calibration file and no CALIBRATIONACQ is given: exit
        %%% and make error message
        if isempty(SCRIPTDATA.CALIBRATIONACQ) && isempty(SCRIPTDATA.CALIBRATIONFILE)
            errordlg('Specify the filenumbers of the calibration measurements or a calibration file to do calibration. Aborting...');
            return; 
        end   

        %%%% create a calfile if DO_CALIBRATE is on, but no calfile is
        %%%% given
        if isempty(SCRIPTDATA.CALIBRATIONFILE) && SCRIPTDATA.DO_CALIBRATE
                % generate a cell array of the .ac2 files used for
                % calibration
                acqcalfiles=SCRIPTDATA.ACQFILENAME(SCRIPTDATA.CALIBRATIONACQ);
                if ~iscell(acqcalfiles), acqcalfiles = {acqcalfiles}; end 

                %find the mappingfile used for the acqcalfiles.
                mappingfile=[];
                for rg=1:length(SCRIPTDATA.RUNGROUPNAMES)
                    if ismember(SCRIPTDATA.CALIBRATIONACQ,SCRIPTDATA.RUNGROUPFILES{rg})
                        mappingfile=SCRIPTDATA.RUNGROUPMAPPINGFILE{rg};
                        break
                    end
                end
                if isempty(mappingfile) && SCRIPTDATA.USE_MAPPINGFILE
                    errordlg('No mappingfile given for the files used to create the calibration file...');
                    return
                end


                for p=1:length(acqcalfiles)
                    acqcalfiles{p} = fullfile(SCRIPTDATA.ACQDIR,acqcalfiles{p});
                end

                pointer = get(gcf,'pointer'); set(gcf,'pointer','watch');
                calfile='calibration.cal8';
                if SCRIPTDATA.USE_MAPPINGFILE
                    sigCalibrate8(acqcalfiles{:},mappingfile,calfile,'displaybar');
                else
                    sigCalibrate8(acqcalfiles{:},calfile,'displaybar');
                end
                set(gcf,'pointer',pointer);

                SCRIPTDATA.CALIBRATIONFILE = fullfile(pwd,calfile);
        end 
    end
end    

%%%% RENDER A GLOBAL LIST OF ALL THE BADLEADS,  set msd.GBADLEADS%%%%
SCRIPTDATA.GBADLEADS={};
for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
   badleads=[];
   for p=1:length(SCRIPTDATA.GROUPBADLEADS{rungroupIdx})      
        reference=SCRIPTDATA.GROUPLEADS{rungroupIdx}{p}(1)-1;    

        addBadleads = SCRIPTDATA.GROUPBADLEADS{rungroupIdx}{p} + reference;

        %%%% check if user input for badleads is correct
        diff=SCRIPTDATA.GROUPLEADS{rungroupIdx}{p}(end)-SCRIPTDATA.GROUPLEADS{rungroupIdx}{p}(1);
        if any(SCRIPTDATA.GROUPBADLEADS{rungroupIdx}{p} < 1) || any(SCRIPTDATA.GROUPBADLEADS{rungroupIdx}{p} > diff+1)
            msg=sprintf('Bad leads for the group %s in the rungroup %s are invalid. Bad leads must be between 1 and ( 1 + maxGrouplead - minGrouplead). Aborting...',SCRIPTDATA.GROUPNAME{rungroupIdx}{p}, SCRIPTDATA.RUNGROUPNAMES{rungroupIdx});
            errordlg(msg);
            return
        end


        %%%% read in badleadsfile, if there is one
%         if ~isempty(SCRIPTDATA.GROUPBADLEADSFILE{rungroupIdx}{rungroupIdx}) 
%             bfile = load(SCRIPTDATA.GROUPBADLEADSFILE{rungroupIdx}{p},'-ASCII');
%             badleads = union(bfile(:)',badleads);
%         end

        %%%% change format of addBadleads.. just in case. this can probably be ignored..
        if size(addBadleads,2) > 1
            addBadleads=addBadleads';
        end

        badleads=[badleads; addBadleads];
   end


    SCRIPTDATA.GBADLEADS{rungroupIdx} = badleads;
end
% GBADLEADS is now a nRungroup x 1 cellarray with the following entries for each rungroup:
% a nBadLeads x 1 array with the badleads in the "global frame" for the rungroup.

%%%% FIND MAXIMUM LEAD for each rg
SCRIPTDATA.MAXLEAD={};  %set to empty first, just in case
for rg=1:length(SCRIPTDATA.RUNGROUPNAMES)  
    maxlead = 1;
    for p=1:length(SCRIPTDATA.GROUPLEADS{rg})
        maxlead = max([maxlead SCRIPTDATA.GROUPLEADS{rg}{p}]);
    end
    SCRIPTDATA.MAXLEAD{rg} = maxlead;
end
success = 1;
end
