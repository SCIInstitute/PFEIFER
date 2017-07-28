function map = generatemap(order,setting)

% function map = generatemap(order,[setting])
%
% INPUT
%  order  - string or cell array of strings determining the order
%           in which the channels should be mapped
%  setting - whether the acq file is obtained with 512 or 1024 channels
%            setting defaults to 1024. Just put the number 1024 or 512
%            here.
%  map - vector in which order the channels should be mapped
%
% This function generates a map file for mapping the acq files into
% everett or whatever program you are using. The purpose of mapping
% is reorder the data channels in such way that you can use it for 
% displaying data. 
%
% There are two processes going on, one is the reordering due to the
% multiplexing and the channels are stored in a different order than you
% would expect. Secondly you want to sort out torso data by torso data
% and other data by the other data.
%
% For instance you want your file to contain first 192 channels of torso and
% then directly the data from the sock, you will need a mapping file. 
%
% This function automaticly reorders the channels from the mux to become
% ordered as the data is streamed to the data acq system. So first channel to 
% the first socket of the fist 256 channel bank. 
%
% In order to simplify matters, the sockets have been given a name. The first bank is
% A1 to A6 then follows B1 to B6 and so on for C and D.
%
% In the parameter 'order' you specify in which order you want to read out the data
% for instance order='A1 A2 A3', will put the data in that order. You can specify
% order as a string or as a cellarray containing multiple strings
%
% In order to define a subset, use just matlabs own system, for example
% order = 'A1(1:10)' gives you the first ten channels of bank A1
% order = 'B1 B2 B3 B4(1:38)' gives you the data from bank B1 to B4 where in the last
% one only the first 38 are given
%
% To simplify matters a couple of configurations have been pre-set in the file
% for example
%   'torso1' = 'A1 A2 A3 A4',  the first leadset on the torso
%   'torso2' = 'B1 B2 B3 B4(1:38)', the second leadset
%   'cage' = 'B1 B2 B3 B4 B5 C1 C2 C3 C4 C5 D1 D2 D3(1:34)', the cage in bank B,C and D
%   'torso' = 'torso1 torso2'
%   NOTE Some torsos have been plugged differently so watch out which one was used
%   'torso2a' = [A5 B1 B2 B3(1:38)];  alternative plugging
%   'torsoa' = [torso1 torso2a]; complete one using the alternative plugging
%
%   'all' = all banks from A1 to D6
%    'sock490' = [C1 C2 C3 C4 C5 D1 D2 D3 D4 D5 D6(1:10)];
%
%    'A', 'B', 'C', 'D' are defined as well, describing the full A-bank/B-bank etc.
%	
% You can define more mapping in this m-file
%
% write mapping data to file with the function writemap

% JG Stinstra 2002

% full mapping of sockets on ACQ block list as follows
% A = the first set of 256 channels, B the second and so on

A1 = [  1: 48]; B1 = [257:304]; C1 = [513:560]; D1 = [769:816];
A2 = [ 49: 96]; B2 = [305:352]; C2 = [561:608]; D2 = [817:864];
A3 = [ 97:144]; B3 = [353:400]; C3 = [609:656]; D3 = [865:912];
A4 = [145:192]; B4 = [401:448]; C4 = [657:704]; D4 = [913:960];
A5 = [193:240]; B5 = [449:496]; C5 = [705:752]; D5 = [961:1008];
A6 = [241:256]; B6 = [497:512]; C6 = [753:768]; D6 = [1009:1024];

A = [A1 A2 A3 A4 A5 A6];
B = [B1 B2 B3 B4 B5 B6];
C = [C1 C2 C3 C4 C5 C6];
D = [D1 D2 D3 D4 D5 D6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% definitions of some other useful settings

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MORE DEFINITIONS FOLLOW HERE %

torso1 = [A1 A2 A3 A4];
torso2 = [B1 B2 B3 B4(1:38)]; %last ten do not count, they are not used
torso = [torso1 torso2]; % the complete torso

torso2a = [A5 B1 B2 B3(1:38)]; % alternative plugging
torsoa = [torso1 torso2a];

cage = [B1 B2 B3 B4 B5 C1 C2 C3 C4 C5 D1 D2 D3(1:34) ]; % define cage position
all = [1:1024];
sock490 = [C1 C2 C3 C4 C5 D1 D2 D3 D4 D5 D6(1:10)];

% Note matlab is casesensitive so just type in the names as given here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The actual part of the script 

% The script just puts the in 'order' defined vectors in the index vector

% The script first builds an index vector, which just specifies the order of channels you
% liked, based on the pin to pin ordering of the channels.
% As the index contains the channel numbers, it is next compared with the actual mapping
% in the file. The latter is given in the files map1024 and map512. These vectors describe
% for instance that channel 1 is found at place 1 and channel 2 at place 5 in the acq file.
% By using the index vector to reorder the this mapping file, for instance
% if index(1) = 10, we want the tenth entry of map1024 to be the first in the row as the 
% tenth entry corresponds to the actual place of the tenth channel in the data file. 
% Using index in this way it only takes one matlab call to do all the reordering
% The programming down here is merely to build up the index vector from a pleasent way setting
% the order using strings which correspond to the vectors defined above. 

% The routine below just appends the vectors you specified as strings to the end of index and
% hence the string you specified is the order in which the number with the various vectors
% appear in the index vector.

index = []; 

if iscell(order),
    for p=1:length(order),
        command = sprintf('index = [index %s];',order{p});
        try
            eval(command);
        catch
            err = sprintf('unknown option: %s\n',order{p});
            error(err);
        end
    end
elseif ischar(order),
    command = sprintf('index = [index %s];',order);
    try
        eval(command);
    catch
        err = sprintf('unknown option: %s\n',order);
        error(err);
    end
elseif isnumeric(order),
    index = order;
end

if nargin > 1,
    if ((setting~=512)&(setting~=1024))
        error('Please, indicate whether the 1024 or the 512 settings have to used\n');
    end
    if setting == 512,
        load map512;
        map = map512(index);
    else
        load map1024;
        map = map1024(index);
    end
else    
    load map1024;
    map = map1024(index);
end

return
