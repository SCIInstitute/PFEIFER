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



function old2newSCRIPTDATA()
%convert old SCRIPTDATA without rungroups to the new format

    global SCRIPTDATA
    defaultsettings=getDefaultSettings;

    %%%%% remove unnecesary fields in the SCRIPTDATA file, that are not in the defaultsettings..
    mappingfile='';
    if isfield(SCRIPTDATA,'MAPPINGFILE'), mappingfile=SCRIPTDATA.MAPPINGFILE; end  %remember the mappingfile, before that information is deleted
    oldfields=fieldnames(SCRIPTDATA);
    fields2beRemoved=setdiff(oldfields,defaultsettings(1:3:end));
    SCRIPTDATA=rmfield(SCRIPTDATA,fields2beRemoved);
    
    
    %%%% now set .DEFAULT and TYPE and set/add missing fields with default values for all fields exept the ones related to (run)groups
    SCRIPTDATA.DEFAULT=struct();
    SCRIPTDATA.TYPE=struct();
    for p=1:3:length(defaultsettings)
        SCRIPTDATA.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
        SCRIPTDATA.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        if ~isfield(SCRIPTDATA,defaultsettings{p}) && ~(strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8))
            SCRIPTDATA.(defaultsettings{p})=defaultsettings{p+1};
        end
    end
    
    
    %%%% fix some problems with old SCRIPTDATA: in some cases there where e.g. 5 groups, but not all group related entries hat 5 entries.  This is fixed here by giving each group default values, if no values are provided yet
    if ~isempty(SCRIPTDATA.GROUPNAME)
        if ~iscell(SCRIPTDATA.GROUPNAME{1})  % if it is an old SCRIPTDATA
            len=length(SCRIPTDATA.GROUPNAME);
            for p=1:3:length(defaultsettings)
                if strncmp(SCRIPTDATA.TYPE.(defaultsettings{p}),'group',5) && (length(SCRIPTDATA.(defaultsettings{p})) < len)
                    SCRIPTDATA.defaultsettings{p}(1:len)=defaultsettings{p+1};
                end
            end
        end
    end
                    
 
    %%%% convert 'GROUP..' fields into new format
    fn=fieldnames(SCRIPTDATA.TYPE);
    rungroupAdded=0;
    for p=1:length(fn)                                    % for each group
        if strncmp(SCRIPTDATA.TYPE.(fn{p}),'group',5)          % if it is a group field  
            if ~isempty(SCRIPTDATA.(fn{p}))       % if there is an entry for it
                if ~iscell(SCRIPTDATA.(fn{p}){1}) % if old format
                    SCRIPTDATA.(fn{p})={SCRIPTDATA.(fn{p})};  % make it a cell  -> new SCRIPTDATA format
                    if ~rungroupAdded, rungroupAdded=1; end
                end
            end
        end   
    end
    

    %%%% create the 'RUNGROUP..'  fields, if they aren't there yet.
    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'rungroup',8)
            if ~isfield(SCRIPTDATA, defaultsettings{p})
                if rungroupAdded
                    SCRIPTDATA.(defaultsettings{p})={defaultsettings{p+1}};
                else
                    SCRIPTDATA.(defaultsettings{p})={};
                end
            end   
        end
    end
    
    if ~isempty(mappingfile) %if SCRIPTDATA.MAPPINFILE existed, make that mappinfile the mappinfile for all rungroups
            SCRIPTDATA.RUNGROUPMAPPINGFILE=cell(1,length(SCRIPTDATA.RUNGROUPNAMES));
            [SCRIPTDATA.RUNGROUPMAPPINGFILE{:}]=deal(mappingfile);
            
            SCRIPTDATA.RUNGROUPCALIBRATIONMAPPINGUSED=cell(1,length(SCRIPTDATA.RUNGROUPNAMES));
            [SCRIPTDATA.RUNGROUPCALIBRATIONMAPPINGUSED{:}]=deal('');
    end
    
    
    
    %%%% if there are no rungroups in old SCRIPTDATA, set all selected acq
    %%%% files as default for a newly created rungroup.
    if rungroupAdded
        SCRIPTDATA.RUNGROUPFILES={SCRIPTDATA.ACQFILES};
    end
    

    
    
    SCRIPTDATA.RUNGROUPSELECT=length(SCRIPTDATA.RUNGROUPNAMES);
    if SCRIPTDATA.RUNGROUPSELECT > 0
        SCRIPTDATA.GROUPSELECT=length(SCRIPTDATA.GROUPNAME{SCRIPTDATA.RUNGROUPSELECT});
    else
        SCRIPTDATA.GROUPSELECT=0;
    end  

end
