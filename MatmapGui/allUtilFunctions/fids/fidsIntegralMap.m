function TSmapindex = fidsIntegralMap(TSmapindex,TSindices,startframe,endframe,average)
% FUNCTION TSmapindex = fidsIntegralMap(TSmapindex,TSindices,startframe,endframe,['average'])
% OR       TSmapdata  = fidsIntegralMap(TSmapdata,TSdata,startframe,endframe,['average'])
%
% DESCRIPTION
% This function adds integralmaps at the end of a TS-structure that already contains some
% integral-maps or creates a new one.
%
% INPUT
% TSmapindex        An index into the TS-array, pointing to the TS-structure where the
%                   maps have to be stored (could be an empty initialised TS-structure)
% TSindices         Indices into the TS-array of the time data that needs to be integrated
% TSmapdata         Similar to TSmapindex, but now the data is directly put on the input
% TSdata            Similar to TSindices, but now the data is directly put on the input
% startframe        frame number of where to start the integration
% endframe          frame number of where to end the integration
%
% OUTPUT
% TSmapindex
%   /TSmapdata      Output of the adjusted data 
%
%

if nargin == 4
    average = 0;
end

if nargin == 5
    if ischar(average), average = 1; else, average = 0; end 
end

global TS;

numleads = 0;
label = '';
filename = '';

if ~isempty(TSmapindex)
    unit = '';
	if isnumeric(TSmapindex)
		if length(TSmapindex) > 1
			error('The maps can only be stored in one TS-array\n');
		end
		numleads = TS{TSmapindex}.numleads;
        leadinfo = TS{TSmapindex}.leadinfo;
        unit = TS{TSmapindex}.unit;
        label = TS{TSmapindex}.label;
        filename = TS{TSmapindex}.filename;
	end
	if iscell(TSmapindex)
		if length(TSmapindex) > 1
			error('The maps can only be stored in one TS-array\n');
		end
		numleads = TSmapindex{1}.numleads;
        leadinfo = TSmapindex{1}.leadinfo;
        unit = TSmapindex{1}.unit;
        label = TSmapindex{1}.label;
        filename = TSmapindex{1}.filename;
    end
	if isstruct(TSmapindex)
		numleads = TSmapindex.numleads;
        leadinfo = TSmapindex.leadinfo;
        unit = TSmapindex.unit;
        label = TSmapindex.label;
        filename = TSmapindex.filename;

	end
    if ischar(TSmapindex)
        TSmapindex.filename = '';
        TSmapindex.label = '';
        TSmapindex.potvals = [];
        TSmapindex.numleads = 0;
        Tsmapindex.numframes = 0;
        TSmapindex.leadinfo = [];
        TSmapindex.unit = '';
        TSmapindex.geom = [];
        TSmapindex.geomfile = '';
        TSmapindex.audit = 'Integralmap|Created by fidsIntegralMap()';
        TSmapindex.text = '';
        TSmapindex.newfileext = '-itg';
    end
else
    TSmapindex = tsInitNew(1);
    TS{TSmapindex}.newfileext =  '-itg';
end

% Find the numleads in each of the TSindices

if numleads == 0
    if isnumeric(TSindices)
        numleads = TS{TSindices(1)}.numleads;
        unit = TS{TSindices(1)}.unit;
        label = TS{TSindices(1)}.label;
        filename = TS{TSindices(1)}.filename;
    end
    if iscell(TSindices)
        numleads = TSindices{1}.numleads;
        unit = TSindices{1}.unit;    
        label = TSindices{1}.label;
        filename = TSindices{1}.filename;  
    end
    if isstruct(TSindices)
        numleads = TSindices.numleads;
        unit = TSindices.unit;
        label = TSindices.label;
        filename = TSindices.filename;
    end    
    leadinfo = zeros(numleads,1);
    if average == 0
        unit = [unit 'ms'];
    end
end

if isnumeric(TSindices)
    for p=1:length(TSindices)
        if TS{TSindices(p)}.numleads ~= numleads, error('All Time series should have the same number of leads\n'); end
    end
end

if iscell(TSindices)
    for p=1:length(TSindices)
        if TSindices{p}.numleads ~= numleads, error('All Time series should have the same number of leads\n'); end
    end
end

if isstruct(TSindices)
    if TSindices.numleads ~= numleads, error('All Time series should have the same number of leads\n'); end
end

% Startframe to bring the data in a better format

if iscell(startframe)
	newstartframe = zeros(numleads,length(startframe));
	for p=1:length(startframe)
		if length(startframe{p}) == 1
            newstartframe(:,p) = startframe{p}*ones(numleads,1);
        else
            if ~isempty(startframe{p} ~= numleads), error('The local fiducials vector should have the same number of entries as the number of leads\n'); end
            newstartframe(:,p) = reshape(startframe{p},numleads,1);
        end
    end
    startframe = newstartframe;
end

if length(startframe) == numel(startframe)
    if length(startframe) == 1
        startframe = startframe*ones(1,length(TSindices));
    end
    if length(startframe) == length(TSindices)
        startframe = reshape(startframe,1,length(TSindices));
    end
    if size(startframe,2) == 1
        startframe = startframe*ones(1,length(TSindices));
    end
    if size(startframe,1) == 1
        startframe = ones(numleads,1)*startframe;
    end
end
    
if (size(startframe,1) ~= numleads)||(size(startframe,2) ~= length(TSindices))
    error('startframe has not the right dimensions\n');
end


% Startframe to bring the data in a better format

if iscell(endframe)
	newendframe = zeros(numleads,length(endframe));
	for p=1:length(endframe)
		if length(endframe{p}) == 1
            newendframe(:,p) = endframe{p}*ones(numleads,1);
        else
            if ~isempty(endframe{p} ~= numleads), error('The local fiducials vector should have the same number of entries as the number of leads\n'); end
            newendframe(:,p) = reshape(endframe{p},numleads,1);
        end
    end
    endframe = newendframe;
end

if length(endframe) == numel(endframe)
    if length(endframe) == 1
        endframe = endframe*ones(1,length(TSindices));
    end
    if length(endframe) == length(TSindices)
        endframe = reshape(endframe,1,length(TSindices));
    end
    if size(endframe,2) == 1
        endframe = endframe*ones(1,length(TSindices));
    end
    if size(endframe,1) == 1
        endframe = ones(numleads,1)*endframe;
    end
end
    
if (size(endframe,1) ~= numleads)||(size(endframe,2) ~= length(TSindices))
    error('endframe has not the right dimensions\n');
end


startframe = round(startframe);
endframe = round(endframe);

% Finally start with the integration

map = zeros(numleads,length(TSindices));
audit = '';

for p = 1:length(TSindices)
    if isnumeric(TSindices)
        audit = [audit sprintf('|AddIntegralMap( file=%s, start=%d, end=%d)',TS{TSindices(p)}.filename,startframe(1,p),endframe(1,p))];
        for q=1:numleads
            idx=startframe(q,p):endframe(q,p);
            
            x=TS{TSindices(p)}.potvals(q,idx);
            
            map(q,p) = sum(x);
            leadinfo(q) = leadinfo(q) & TS{TSindices(p)}.leadinfo(q);
        end
    end
    if iscell(TSindices)
       audit = [audit sprintf('|AddIntegralMap( file=%s, start=%d, end=%d)',TSindices{p}.filename,startframe(1,p),endframe(1,p))];
       for q=1:numleads
            map(q,p) = sum(TSindices{p}.potvals(q,startframe(q,p):endframe(q,p)));
            leadinfo(q) = leadinfo(q) & TSindices{p}.leadinfo(q);
        end
    end 
    if isstruct(TSindices)
       audit = [audit sprintf('|AddIntegralMap( file=%s, start=%d, end=%d)',TSindices.filename,startframe(1,p),endframe(1,p))]; 
       for q=1:numleads
            map(q,p) = sum(TSindices.potvals(q,startframe(q,p):endframe(q,p)));
            leadinfo(q) = leadinfo(q) & TSindices.leadinfo(q);
        end
    end 
    
    if average == 1
        len = endframe(:,p)-startframe(:,p);
        map(:,p) = map(:,p)./len;
    end
end
    

if isstruct(TSmapindex)
    TSmapindex.potvals = [TSmapindex.potvals map];
    TSmapindex.numframes = size(TSmapindex.potvals,2);
    TSmapindex.numleads  = size(TSmapindex.potvals,1);
    TSmapindex.unit = unit;
    TSmapindex.leadinfo = leadinfo;
    TSmapindex.audit  = [TSmapindex.audit audit];
    TSmapindex.label = label;
    TSmapindex.filename = filename;    
end

if iscell(TSmapindex)
    TSmapindex{1}.potvals = [TSmapindex{1}.potvals map];
    TSmapindex{1}.numframes = size(TSmapindex{1}.potvals,2);
    TSmapindex{1}.numleads = size(TSmapindex{1}.potvals,1);
    TSmapindex{1}.unit = unit;
    TSmapindex{1}.leadinfo = leadinfo;
    TSmapindex{1}.audit  = [TSmapindex{1}.audit audit];
    TSmapindex{1}.label = label;
    TSmapindex{1}.filename = filename;    
end

if isnumeric(TSmapindex)
    TS{TSmapindex}.potvals = [TS{TSmapindex}.potvals map];
    TS{TSmapindex}.numframes = size(TS{TSmapindex}.potvals,2);
    TS{TSmapindex}.numleads = size(TS{TSmapindex}.potvals,1);
    TS{TSmapindex}.unit = unit;
    TS{TSmapindex}.leadinfo = leadinfo;
    TS{TSmapindex}.audit  = [TS{TSmapindex}.audit audit];
    TS{TSmapindex}.label = label;
    TS{TSmapindex}.filename = filename;    
end


return
%%%%






        