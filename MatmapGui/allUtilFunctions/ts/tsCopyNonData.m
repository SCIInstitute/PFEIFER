function tsCopyNonData(source,dest)
% function tsCopyNonData(source,dest)
% 
% This function copies all the non-data structures from
% source to dest. Non-data are all fields except
% potvals, framemap, leadmap, leadinfo
%
% INPUT
%  source	source index (may be vectorised)
%  dest		destination index
%
% SEE tsCopy

if length(source) ~= length(dest),
    msgError('source and dest should have equal length',3);
end

global TS;

for p=1:length(source),  % vectorised

    fnames = fieldnames(TS{source(p)});
    for q= 1:length(fnames)
        switch(fnames{q})
        case {'potvals','leadmap','framemap','numleads','numframes','leadinfo'},
            % do nothing 
        otherwise
            TS{dest(p)} = setfield(TS{dest(p)},fnames{q},getfield(TS{source(p)},fnames{q})) ; % copy the field
        end
    end
end               
