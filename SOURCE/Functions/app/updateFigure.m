function updateFigure(figObj)
% changes all Settings in the figure ( that belongs to handle) according to
% SCRIPTDATA.  
%Updates everything in the gui figures, including File Listbox etc..
% handle is gui figure object

global SCRIPTDATA;

%%%% loop through all fieldnames of SCRIPTDATA and make changes accourding to the fieldname
fn = fieldnames(SCRIPTDATA);
for p=1:length(fn)
    %%%% identify the uicontrol object in the gui figure ("handle") that is related to the fieldname. The uicontrol object are identified by there tag property
    obj = findobj(allchild(figObj),'tag',fn{p});
    if ~isempty(obj) % if field is also Tag to a uicontroll object in the figure..
        %%%% change that uicontroll. Depending on type..  
        objtype = SCRIPTDATA.TYPE.(fn{p});
        switch objtype
            case {'file','string'}
                obj.String = SCRIPTDATA.(fn{p});
            case {'listbox'}
                cellarray = SCRIPTDATA.(fn{p});
                if ~isempty(cellarray) 
                    values = intersect(SCRIPTDATA.ACQFILENUMBER,SCRIPTDATA.ACQFILES);
                    
                    if length(cellarray) == 1
                        maxVal=3;
                    else
                        maxVal = length(cellarray);
                    end
                    set(obj,'string',cellarray,'max',maxVal,'value',values,'enable','on');
                else
                    set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
                end
            case {'double','vector','listboxedit','integer'}
                obj.String = mynum2str(SCRIPTDATA.(fn{p}));
            case {'bool','toolsdropdownmenu'}
                [obj.Value] = deal(SCRIPTDATA.(fn{p}));
            case {'select'}   % case of SCRIPTDATA.GROUPSELECT  
                value = SCRIPTDATA.(fn{p});    % int telling which group is selected
                if value == 0, value = 1; end  %if nothing was selected
                obj.Value = value;
                rungroup=SCRIPTDATA.RUNGROUPSELECT;
                if rungroup==0, continue; end
                selectnames = SCRIPTDATA.GROUPNAME{rungroup};  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                selectnames{end+1} = 'NEW GROUP';
                obj.String = selectnames;

            case {'selectR'}
                value = SCRIPTDATA.(fn{p});    % int telling which rungroup is selected
                if value == 0, value = 1; end  %if nothing was selected
                selectrnames = SCRIPTDATA.RUNGROUPNAMES;  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                selectrnames{end+1} = 'NEW RUNGROUP'; 
                obj.String = selectrnames;
                obj.Value = value;


            case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}   
                group = SCRIPTDATA.GROUPSELECT;
                if (group > 0)
                    set(obj,'enable','on','visible','on');
                    cellarray = SCRIPTDATA.(fn{p}){SCRIPTDATA.RUNGROUPSELECT};
                    if length(cellarray) < group   %if the 'new group' option is selected!
                        cellarray{group} = SCRIPTDATA.DEFAULT.(fn{p});      % if new group was added, fill emty array slots with default values
                    end
                    switch objtype(6:end)
                        case {'file','string'}
                            obj.String = cellarray{group};
                        case {'double','vector','integer'}
                            obj.String = mynum2str(cellarray{group});
                        case {'bool'}
                            obj.Value = cellarray{group};
                    end
                    SCRIPTDATA.(fn{p}){SCRIPTDATA.RUNGROUPSELECT}=cellarray;    
                else
                    set(obj,'enable','inactive','visible','off');
                end
            case {'rungroupstring', 'rungroupvector'}    %any of the rungroupbuttons
                rungroup = SCRIPTDATA.RUNGROUPSELECT;
                if (rungroup > 0)
                    set(obj,'enable','on','visible','on');
                    set(findobj(allchild(figObj),'tag','GROUPSELECT'),'enable','on','visible','on')
                    set(findobj(allchild(figObj),'tag','RUNGROUPFILESBUTTON'),'enable','on','visible','on','BackgroundColor',[0.28 0.28 0.28])
                    
                    set(findobj(allchild(figObj),'tag','BROWSE_RUNGROUPMAPPINGFILE'),'enable','on','visible','on','BackgroundColor',[0.28 0.28 0.28])
                    set(findobj(allchild(figObj),'tag','USE_MAPPINGFILE'),'enable','on','visible','on')
                    set(findobj(allchild(figObj),'tag','mappingfileStaticTextObj'),'enable','on','visible','on')

                    cellarray = SCRIPTDATA.(fn{p});                     
                    switch objtype(9:end)
                        case {'file','string'}
                            obj.String = cellarray{rungroup};
                        case {'double','vector','integer'}
                            obj.String = mynum2str(cellarray{rungroup});
                        case {'bool'}
                            obj.Value = cellarray{rungroup};
                    end
                    SCRIPTDATA.(fn{p})=cellarray;
                else
                    set(obj,'enable','inactive','visible','off');
                    set(findobj(allchild(figObj),'tag','GROUPSELECT'),'enable','off','visible','off')
                    set(findobj(allchild(figObj),'tag','RUNGROUPFILESBUTTON'),'enable','off','visible','off')
                    
                    set(findobj(allchild(figObj),'tag','BROWSE_RUNGROUPMAPPINGFILE'),'enable','off','visible','off')
                    set(findobj(allchild(figObj),'tag','USE_MAPPINGFILE'),'enable','off','visible','off')
                    set(findobj(allchild(figObj),'tag','mappingfileStaticTextObj'),'enable','off','visible','off')
                end
        end
    end
end
end
