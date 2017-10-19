function [TSmapindex, success] = sigActRecMap(TSindeces,refmode)
% - get act and rec from TS{TSindex}.fid
% - create datamap=[ act; rec; ari=act-rec]
% - place a new ts in TS, that is a copy of the input ts, but with
% potvals=datamap
% return index of the new 'act/rec' ts

    TSmapindex = [];

    if isnumeric(TSindeces)
        global TS;
  
        for TSidx=TSindeces
            
            %%%% get act, ref and rec: nx1 vectors that contain the fids          
            act = fidsFindLocalFids(TSidx,'act');
            
            if ~isempty(act)
                act = act(:,1); % only get the first series
            else
                success=0; 
                msg=sprintf('There are no activation values for the file %s. Cannot do activation maps..',TS{TSidx}.filename);
                errordlg(msg)
                return
            end
            rec = fidsFindLocalFids(TSidx,'rec');
            if ~isempty(rec)
                rec = rec(:,1); % only get the first series
            else
                success=0;
                msg=sprintf('There are no recovery values for the file %s. Cannot do activation maps..',TS{TSidx}.filename);
                errordlg(msg)
                return
            end
            ref = 0;
            rf = fidsFindGlobalFids(TSidx,'reference');
            if (~isempty(rf))
                ref = (rf(1)-1);
            end 
            
            %%% shift with ref..
            act = act - ref;
            rec = rec - ref;
            
            
            
            if length(act) == length(rec)
                ari = rec-act; 
            else
                ari = [];    
            end
            
            
            %%%% create datamap=[ act; rec; ari=act-rec]
            numchannels = size(TS{TSidx}.potvals,1);
            datamap = zeros(numchannels,3);
            
            if ~isempty(act), if length(act) == numchannels, datamap(:,1) = act; end, end
            if ~isempty(rec), if length(rec) == numchannels, datamap(:,2) = rec; end, end
            if ~isempty(ari), if length(ari) == numchannels, datamap(:,3) = ari; end, end
    
            
            %%%% place a new ts in TS, that is a copy of the input ts,
            %%%% except that potvals are changed to datamap.
            q = tsNew(1);
            TS{q} = TS{TSidx};
            TS{q}.potvals = datamap;
            TS{q}.numleads = numchannels;
            TS{q}.numframes = 3;
            TS{q}.pacing  = [];
            TS{q}.fids = [];
            TS{q}.fidset = {};
            TS{q}.audit = [TS{q}.audit '| Activation/Recovery/ARInterval map'];
    
            TSmapindex = [TSmapindex q];
        end
    end
    success = 1;