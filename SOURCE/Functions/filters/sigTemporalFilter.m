function sigTemporalFilter(index)

% FUNCTION sigTemporalFilter(index)
%
% DESCRIPTION
% This function is the implementation of the temporal filter for the
% processing script. When using the script, the active time signal is
% located in TS{index}. The settings that are made through the GUI can be
% found in ScriptData. 
%
% INPUT
%  index    The index of the TS array which with to work
%
% OUTPUT
%  -    Changes to the TS global make sure that the program knows what is
%       going on. Basically the TS structure can be modified as one wishes
%
% SEE ALSO


global ScriptData TS;

% A = ScriptData.FILTERSETTINGS.A;
% B = ScriptData.FILTERSETTINGS.B;
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];





h = waitbar(0,'Filtering signal please wait...');

D = TS{index}.potvals';
%Zi = ones(max(length(A),length(B))-1,1)*D(1,:);
D = filter(B,A,D);
D(  1: (max(length(A),length(B))-1)   , :) = ones( max(length(A),length(B))-1  ,1 )  *  D( max(length(A),length(B)) ,:);
TS{index}.potvals = D'; 



%%%% add addAudit label
tsAddAudit(index,'|used a temporal filter on the data');

if isgraphics(h), close(h); end