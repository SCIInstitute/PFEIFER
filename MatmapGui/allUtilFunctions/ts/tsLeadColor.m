function color = tsLeadColor(TSindex,leads)
% FUNCTION color = tsLeadColor(TSindex,[leads])
%
% DESCRIPTION
% This functions returns the color for displaying a certain lead. The latter
% depends on the state of the leadinfo array. All bad leads are displayed in
% red, all blank ones in blue and all interpolated ones in green.
%
% INPUT
% TSindex	The timeseries index
% leads         The leads on which color information as to be provided
%               default: all leads
%
% OUTPUT
% colors        Cellarray containing th color identifier strings
%
% SEE ALSO -   


global TS;

% Define an array with coloring for three bits it is still doable
% The index-1 defines the color with which a channel should be displayed
% a normal channel is displayed in black
% a bad channel in red
% a blank channel overrides both orthers and results in a blue color
% a interp overrides the others again resulting in a green color
% The array is laid out a cell array, so rgb values can be specified as well


if nargin == 1,
    lead = [1:TS{TSindex}.numleads];					% default all leads
end    

colors = { 'r' , 'b', 'b', 'g', 'g', 'g', 'g' };

[color{1:length(Leads)}] = deal('k'); 					% set the default color

index = find(TS{TSindex}.leadinfo(leads));
value = TS{TSindex}.leadinfo(leads(index));

for p = 1:length(index), 
    if value(p) < 8,							% otherwise keep the default
        color{index(p)} = colors{value(p)}; 
    end    
end

