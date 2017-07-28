function TemporalFilter(index)

% FUNCTION TemporalFilter(index)
%
% DESCRIPTION
% This function is the implementation of the temporal filter for the
% processing script. When using the script, the active time signal is
% located in TS{index}. The settings that are made through the GUI can be
% found in SCRIPT. 
%
% INPUT
%  index    The index of the TS array which with to work
%
% OUTPUT
%  -    Changes to the TS global make sure that the program knows what is
%       going on. Basically the TS structure can be modified as one wishes
%
% SEE ALSO
% -


global SCRIPT TS;

numchan = size(TS{index}.potvals,2);

if ~isfield(SCRIPT,'FILTER'),
    errordlg('No filter has been defined in the ProcessingScript Settings menu');
    return;
end


if isfield(SCRIPT.FILTERSETTINGS,'tf'),
    A = SCRIPT.FILTERSETTINGS.tf.den;
    B = SCRIPT.FILTERSETTINGS.tf.num;
elseif isfield(SCRIPT.FILTERSETTINGS,'A') & isfield(SCRIPT.FILTERSETTINGS,'B'),
    A = SCRIPT.FILTERSETTINGS.A;
    B = SCRIPT.FILTERSETTINGS.B;
else
    return;
end

h = waitbar(0,'Filtering signal please wait...','Tag','waitbar');

D = TS{index}.potvals';
%Zi = ones(max(length(A),length(B))-1,1)*D(1,:);
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
TS{index}.potvals = D';


if isgraphics(h), close(h); end
return