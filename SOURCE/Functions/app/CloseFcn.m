function CloseFcn(~)
%callback function for the 'close' buttons.
global SCRIPTDATA PROCESSINGDATA FIDSDISPLAY SLICEDISPLAY TS

%%%% save setting
try
    if ~isempty(SCRIPTDATA.SCRIPTFILE)
     saveSettings
     disp('Saved SETTINGS before closing PFEIFER')
    else
     disp('PFEIFER closed without saving SETTINGS')
    end
catch
    %do nothing
end

%%%% delete all gui figures
delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS')); 
delete(findobj(allchild(0),'tag','SLICEDISPLAY'));
delete(findobj(allchild(0),'tag','FIDSDISPLAY'));

%%%% delete all waitbars
waitObjs = findall(0,'type','figure','tag','waitbar');
delete(waitObjs);

%%%% delete all error dialog windows
errordlgObjs = findall(0,'type','figure','tag','Msgbox_Error Dialog');
delete(errordlgObjs);

%%%% clear globals
clear global FIDSDISPLAY SLICEDISPLAY TS
end