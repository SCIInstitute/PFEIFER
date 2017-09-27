
function setHelpMenus(handle)
tag_list={'ACQEXT', 'ACQDIR','SCRIPTFILE','DATAFILE','ACQDIR','MATODIR','DO_CALIBRATE',...
    'DO_FILTER','DO_SLICE_USER','DO_BASELINE_RMS','DO_BASELINE','DO_DETECT','DO_BASELINE_USER',...
    'DO_DETECT_USER','DO_INTEGRALMAPS','DO_ACTIVATIONMAPS'};

for p=1:length(tag_list)
    obj=findobj(allchild(handle),'Tag',tag_list{p});
    if isempty(obj)
        continue
    end
    
    c=uicontextmenu(handle);
    obj.UIContextMenu=c;
    
    uimenu(c,'Label','help','Tag',['UICTR_', tag_list{p}],'Callback',@displayHelp);
end


function displayHelp(source,~)

path=which('setHelpMenus');
[path,~,~]=fileparts(path);

filename=[source.Tag(7:end) '_help.html'];
filename=fullfile(path,'html',filename);
web(filename);



        




    
    
    
    
