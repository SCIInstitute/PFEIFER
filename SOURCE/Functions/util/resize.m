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


function resize(figObj,~)
%this is the SizeChangedFcn callback for all windows of the gui.
%It adjust the fontsize of all the windows whenever the windows are resized
%so everything still looks nice..
% this function works best if all textfields have the same size..

% what you need to do to make this function work and make figure resizable with changing fontsize
% - make this function the callback for the 'SizeChangedFcn' of figure
% - put the 'Rezise' figure property to 'On'
% - set figure.Units = 'characters'
% - set the 'Units' property of all children to 'normalized'

% - the first Object with textproperties in figure is used to determine fontsize.
%  => use its innerPosition property to control FontSize.  A heigth of 0.026145 results in FontSize = 13;




objects=allchild(figObj);  

newFontsize=5;
%%%% first find the default fontsize
for p=1:length(objects)
    obj=objects(p);
    if isSuitableStaticTextObject(obj)
        obj.Units='pixel';
        avail_widht=obj.Position(3);
        avail_height=obj.Position(4);
        
        %%%% try increasingly smaller fontsizes and check if they are small enough
        for temp_fontsize=[13:-1:5]  % for each fontsize
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




function tf=isSuitableStaticTextObject(obj)
tf=false;

tagsOfNotSuitableTextObjs = {'multilinetext'};
if ismember(obj.Tag,tagsOfNotSuitableTextObjs)
    return
end


if isprop(obj,'Style')
    if strcmp(obj.Style,'text')
        tf=true;
    end
end


    
    
    
    
    
    
    
    
