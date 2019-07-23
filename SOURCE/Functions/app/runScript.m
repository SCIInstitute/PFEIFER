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




function runScript(~)
%callback to 'apply' button, this starts the whole processing process!

%this function
%   - saves all settings in msd.SCRIPTFILE, just in case programm crashes
%   - checks if all settings are correkt (in particular, if groups have
%     been selected
%   - loads PROCESSINGDATA
%   - calls PreLoopScript, which:
%       - checks if mapfile etc exist (I do that already earlier?!)
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - sets up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
%   - starts the MAIN LOOP: for each file:  Process file
%   - at very end when everything is processed: update figure 
%       
    global SCRIPTDATA
    
    
    h = [];   %for waitbar
    success = PreLoopScript;
    if ~success, return, end
    
    %%%% make sure helper files are selected to save data
    if isempty(SCRIPTDATA.DATAFILE)
        errordlg('No Processing Data File given to save processing data. Provide a Processing Data File to run the script.')
        return
    end
    if isempty(SCRIPTDATA.SCRIPTFILE)
        errordlg('No Script Data File given to save settings. Provide a Script Data File to run the script.')
        return
    end
    
    %%%% save helper files 
    savePROCESSINGDATA;
    saveSettings;
    
    
    
    %%%% check some user inputs 
    if SCRIPTDATA.NUM_BEATS_TO_AVGR_OVER > SCRIPTDATA.NUM_BEATS_BEFORE_UPDATING
        errordlg('# Beats For Updating must not be greater than # Beats Before Updating.');
        return
    end
    if length(SCRIPTDATA.LEADS_FOR_AUTOFIDUCIALIZING) > SCRIPTDATA.NTOBEFIDUCIALISED
        errordlg('You cannot specify more Leads For Autofiducializing than there are Number of Leads.')
        return
    end
    
    
    
    %%%% make sure a rungroup is defined for each selected file
    for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
        if isempty(SCRIPTDATA.GROUPNAME{rungroupIdx})
            errordlg('you need to define groups for each defined rungroup in order to  process the data.');
            return
        end
    end

    %%%% MAIN LOOP %%%
    acqfiles = unique(SCRIPTDATA.ACQFILES);
    h  = waitbar(0,'SCRIPT PROGRESS','Tag','waitbar'); drawnow;
    
    
    p = 1;
    while (p <= length(acqfiles))

        SCRIPTDATA.ACQNUM = acqfiles(p);
        SCRIPTDATA.NAVIGATION = 'apply';
        
        %%%% find the current rungroup of processed file
        SCRIPTDATA.CURRENTRUNGROUP=[];
        for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
            if ismember(acqfiles(p), SCRIPTDATA.RUNGROUPFILES{rungroupIdx})
                SCRIPTDATA.CURRENTRUNGROUP=rungroupIdx;
                break
            end
        end
        if isempty(SCRIPTDATA.CURRENTRUNGROUP)
            msg=sprintf('No Rungroup specified for %s. You need to specify a Rungroup for each file that you want to process.',SCRIPTDATA.ACQFILENAME{acqfiles(p)});
            errordlg(msg);
            return
        end
        
        
%         try
            success = ProcessACQFile(SCRIPTDATA.ACQFILENAME{acqfiles(p)},SCRIPTDATA.ACQDIR);
%         catch
%             fprintf('ERROR: something went wrong procssing the file %s. Skipping this file...',SCRIPTDATA.ACQFILENAME{acqfiles(p)})
%         end
        
        if ~success, return, end
        
        switch SCRIPTDATA.NAVIGATION
            case 'prev'
                p = p-1; 
                if p == 0, p = 1; end
                continue;
            case {'redo','back'}
                continue;
            case 'stop'
                break;
        end
        if isgraphics(h), waitbar(p/length(acqfiles),h); end
        p = p+1;
    end

    if isgraphics(h), close(h); end
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
end
