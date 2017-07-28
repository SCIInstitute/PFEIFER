function varargout = tsSplitTS(varargin)

% FUNCTION [newTSindices1,newTSindices2,...] = tsSplitTS(indices,channels,[newfileext],[nextchannels,nextnewfileext,...])
%          OR [Tseries1,Tseries2,..] = tsSplitTS(Tseries,channels,[newfileext],[nextchannels,nextnewfileext,...])
%


    if nargin < 1
        msgError('You need to supply indices into the TS array or a TS structured cell array',5);
        return
    end

    TSindices = varargin{1};
    
    channels = {};
    newext = {};
    count = 0;

    if ~iscell(varargin{2})
    for p = 2:nargin
        if ischar(varargin{p})
            if count == 0
                msgError('You need to put the newfilename-extension after the channels definitions',5);
                return
            end
            newext{count} = varargin{p};
        end
        if isnumeric(varargin{p})
            count = count+1;
            newext{count} = '';
            channels{count} = varargin{p};
        end
    end
    end

    if iscell(varargin{2})
       channels = varargin{2};
       count = length(channels);
       if nargin > 2
           newext = varargin{3};
           if ~iscell(newext), newext = {[newext]}; end
       else
           for p=1:count, newext{p} =''; end
       end
    end
  
    if (nargout ~= count)&&(nargout > 1)
        msgError('The number of output arguments has to match the number of pieces you split the data into',5);
        return;
    end

    if isnumeric(TSindices)
        global TS;
        newindices = tsNew(count*length(TSindices));
        newindices = reshape(newindices,count,length(TSindices));          
        for p=1:count
            if length(newext) < p, newext{p} =''; end
            for q=1:length(TSindices)
                  TS{newindices(p,q)} = TS{TSindices(q)};
                  TS{newindices(p,q)}.potvals = TS{newindices(p,q)}.potvals(channels{p},:);
                  TS{newindices(p,q)}.leadinfo = TS{newindices(p,q)}.leadinfo(channels{p});
                  TS{newindices(p,q)}.numleads = length(channels{p});
                  TS{newindices(p,q)}.newfileext = newext{p};
                  if isfield(TS{newindices(p,q)},'fids')
                      for r=1:length(TS{newindices(p,q)}.fids)
                          if length(TS{newindices(p,q)}.fids(r).value) > 1
                              TS{newindices(p,q)}.fids(r).value = TS{newindices(p,q)}.fids(r).value(channels{p});
                          end
                      end
                  end    
            end
        end
        if nargout == count
            for p=1:count
                varargout{p} = newindices(p,:);
            end
        end
        if nargout < 2
           varargout{1} = reshape(newindices,1,count*length(TSindices));
        end
    end

    if isstruct(TSindices)
        nTSindices{1} = TSindices;
        TSindices = nTSindices;
        clear nTSindices;
    end

    if iscell(TSindices)
       for p=1:count     
            for q=1:length(TSindices)
                  TS(p,q) = TSindices(q);
                  TS{p,q}.potvals = TS{p,q}.potvals(channels{p},:);
                  TS{p,q}.leadinfo = TS{p,q}.leadinfo(channels{p});
                  TS{p,q}.numleads = length(channels{p});
                  TS{p,q}.newfileext = newext{p};
                  if isfield(TS{p,q},'fids')
                      for r=1:length(TS{p,q}.fids)
                          if length(TS{p,q}.fids(r).value) > 1
                              TS{p,q}.fids(r).value = TS{p,q}.fids(r).value(channels{p});
                          end
                      end
                  end   
            end
        end
        if nargout == count
            for p=1:count
                varargout{p} = TS(p,:);
            end
        end
        if nargout < 2
           varargout{1} = reshape(TS,1,count*length(TSindices));
        end
    end

    return
    

