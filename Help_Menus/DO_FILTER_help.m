%% Apply Temporal Filter
% If this option is ON, a temporal filter is applied to all loaded files.
%
% The temporal filter is done in the temporalFilter.m file. There one finds
% something aequivalent to the following lines of code:

% for each data input file:
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
A = 1;  % A and B are hardcoded into matmap
D=ts.potvals'; % the potential values to be filtered.
D = filter(B,A,D);   % filter is a build in matlab function
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
ts.potvals = D'; % set the filtered data as the new potvals