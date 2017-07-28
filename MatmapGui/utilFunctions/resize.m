function resize(handle,~)
    %this is the SizeChangedFcn callback for all windows of the gui.
    %It adjust the fontsize of all the windows whenever the windows are resized
    %so everything still looks nice..



    objects=allchild(handle);  
    
    newFontsize=5;
    %first find the default fontsize
    for p=1:length(objects)
        obj=objects(p);
        if isStaticTextObject(obj)
            obj.Units='pixel';
            avail_widht=obj.Position(3);
            avail_height=obj.Position(4);

            for temp_fontsize=[13:-1:5]  %try increasingly smaller fontsizes and check if they are small enough
                obj.FontSize=temp_fontsize;
                needed_width=obj.Extent(3);
                needed_height=obj.Extent(4);

                if needed_width < avail_widht && needed_height < avail_height
                    newFontsize=temp_fontsize;
                    break
                end           
            end
            obj.Units='normalize';
            break;
        end
    end

    %now change the fontsize of all objects to newFontsize
    for p=1:length(objects)
        if isprop(objects(p),'FontSize') && isprop(objects(p),'Extent') && ~strcmp(objects(p).Type,'uicontextmenu')
            objects(p).FontSize=newFontsize;
        end
    end

end


function tf=isStaticTextObject(obj)
    tf=false;
    if isprop(obj,'Style')
        if strcmp(obj.Style,'text')
            tf=true;
        end
    end
end
    
    
    
    
    
    
    
    
    
