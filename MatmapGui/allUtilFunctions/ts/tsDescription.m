function Abstract = tsDescription(TSnum)

global TS;

if isfield(TS{TSnum},'label'), Abstract.label = TS{TSnum}.label; end
if isfield(TS{TSnum},'numleads'), Abstract.numleads = TS{TSnum}.numleads; end
if isfield(TS{TSnum},'numframes'), Abstract.numframes = TS{TSnum}.numframes; end

return