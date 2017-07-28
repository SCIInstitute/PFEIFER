function temporalFilter(index)

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


global myScriptData TS;

numchan = size(TS{index}.potvals,2);

if ~isfield(myScriptData,'FILTER')
    errordlg('No filter has been defined in the Settings menu');
    return;
end


if isfield(myScriptData.FILTERSETTINGS,'tf')
    A = myScriptData.FILTERSETTINGS.tf.den;
    B = myScriptData.FILTERSETTINGS.tf.num;
elseif isfield(myScriptData.FILTERSETTINGS,'A') && isfield(myScriptData.FILTERSETTINGS,'B')
    A = myScriptData.FILTERSETTINGS.A;
    B = myScriptData.FILTERSETTINGS.B;
else
    return;
end

h = waitbar(0,'Filtering signal please wait...');

D = TS{index}.potvals';
%Zi = ones(max(length(A),length(B))-1,1)*D(1,:);
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
TS{index}.potvals = D';


if isgraphics(h), close(h); end

return