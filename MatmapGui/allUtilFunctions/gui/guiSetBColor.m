function guiSetBColor(mode)

    global GUI;
    
    if mode == 1,
        color = GUI.Color.Window;
    else
        color = GUI.Color.Window2;
    end
    
    GUI.Template.Text.BackgroundColor = color;
    GUI.Template.Checkbox.BackgroundColor = color;
    GUI.Template.Axis.BackgroundColor = color;
    
return