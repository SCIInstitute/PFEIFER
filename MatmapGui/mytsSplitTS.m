function newindices = tsSplitTS(TSindex, channels)

% FUNCTION [newTSindices1,newTSindices2,...] = tsSplitTS(indices,channels)

   count = length(channels);
    global TS;
    newindices = tsNew(count);
    for p=1:count
      toBeCleared=[];
      TS{newindices(p)} = TS{TSindex};
      TS{newindices(p)}.potvals = TS{newindices(p)}.potvals(channels{p},:);
      TS{newindices(p)}.leadinfo = TS{newindices(p)}.leadinfo(channels{p});
      TS{newindices(p)}.numleads = length(channels{p});
      if isfield(TS{newindices(p)},'fids')
          for r=1:length(TS{newindices(p)}.fids)
              if length(TS{newindices(p)}.fids(r).value) > 1
                  if isempty(find(0==ismember(channels{p},1:length(TS{newindices(p)}.fids(r).value)), 1))
                      TS{newindices(p)}.fids(r).value = TS{newindices(p)}.fids(r).value(channels{p});
                  else
                      toBeCleared=[toBeCleared r];
                  end
              end
          end
          TS{newindices(p)}.fids(toBeCleared)=[];
      end    
    end

end
    

