function options = subscriptRemapping(options)
% FUNCTION options = subscriptRemapping(options)
%
% DESCRIPTION
% This function is a piece of a complete script which helps you setup some 
% remapping parameters such as a leadmap or framemap. It also lets you load
% channels/mapping files to remap the channels for more convenient displaying
%
% INPUT
% options      The options array in which the remapping options have to be translated
%
% OUTPUT
% options      The same options array only now with a field leadmap or framemap
%
% NOTE
% You can put this subscript in your script if you want to allow remapping.
% You can supply the options array to ioReadTS, which will do the remapping for you
% upon loading the files. Or supply the options array to tsRemap, which will remap
% a set of timeseries in memory. Both functions accept the mapping options specified
% by this subscript.
% 
% SEE ALSO - 

if nargin == 0,
    options = [];
end    


disp('Selecting a subset of leads/frames')
disp(' ')
disp('Using the remapping options you can specify which frames/leads you want to process.')
disp('A mapping vector is a vector specifying the numbers of the leads/frames you want to use.')
disp('The way the numbers are ordered in the vector corresponds to the order in which the leads/frames')
disp('are processed.')
disp(' ')
disp('By default all leads and all frames are used (in the order specified in the TSDF/TSDFC-files)')
disp(' ')

if isfield(options,'leadmap'),
    disp('The current leadmap has been defined through the options matrix');
    disp(' ');
end    

if isfield(options,'framemap'),
    disp('The current framemap has been defined through the options matrix');
    disp(' ');
end    


if utilQuestionYN('Do you want to use default mapping options (y), or do you want to specify them (n)?'),
    return		% user does not want to do any remapping
end    

disp('There are two ways in which you can remap the data:')
disp(' ')
disp('You can specify a mapping/channels file which contains the remapping information or')
disp('you can enter a vector in the matlab-style that specifies the channel numbers and the order of the channels')
disp(' e.g. [1:100] specifies the first 100 channels, [1,2,3,8] specifies a number of channels (being number 1,2,3 and 8),')
disp('      [1:4:100] specifies 1,5,9,13,... etc (increment of 4)')
disp(' ')

if utilQuestionYN('Do you want to remap the leads (take a subset of leads) ?'),
    success = 0;
    while ~success,
        string = utilGetString('Enter a matlab vector or a filename (no wildcards)','array/filename');
        if exist(string,'file'),
            options.leadmap = ioReadMap(string);
            options.leadmap(find(options.leadmap == 0)) = 1;
            success = 1;
        else
            try
                eval(sprintf('options.leadmap = %s;',string));
                success = 1;
            catch
                disp(' ')
                disp('The array you entered cannot be intepreted, please try again..');
                disp(' ')
            end    
        end
    end
    disp(' ')
    disp('A valid lead remapping vector was retrieved');
    disp(' ')
end    

if utilQuestionYN('Do you want to remap the frames (take a subset of frames) ?'),
    success = 0;
    while ~success,
        string = utilGetString('Enter a matlab vector or a filename (no wildcards)','array/filename');
        if exist(string,'file'),
            options.framemap = ioReadMap(string);       
            options.framemap(find(options.framemap == 0)) = 1;
            success = 1; 
        else
            try
                eval(sprintf('options.framemap = %s;',string));
                success = 1;
            catch
                disp(' ')
                disp('The array you entered cannot be intepreted, please try again');
                disp(' ')
            end    
        end
    end
    disp(' ')
    disp('A valid frame remapping vector was retrieved');
    disp(' ')
end

disp(' ');					% give viewer some space on the screen

return