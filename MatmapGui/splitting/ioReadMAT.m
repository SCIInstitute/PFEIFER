function index = ioReadMAT(varargin)
% load .mat into TS, remap if mapfile is there.. no calibration!! this needs
% to be done earlier.

%%%% process input: identify mapping/cal/mat-file
mapping='';
matfile='';
for p=1:nargin
    [~,~,ext]=fileparts(varargin{p});
    switch ext
        case '.mat'
            matfile=varargin{p};
        case '.mapping'
            mapping=varargin{p};
    end
end

metadata=load(matfile);

if ~isempty(mapping)
    leadmap = ioReadMapping(mapping);
    metadata.ts.potvals=metadata.ts.potvals(leadmap,:);   % remap leads
    metadata.ts.audit=[metadata.ts.audit sprintf('|mappingfile=%s',mapping) ];
end


global TS
index=tsNew(1);
TS{index}=metadata.ts;










