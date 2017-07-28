function TSindices = tsAddAudit(TSindices,addaudit)
% FUNCTION      tsAddAudit(TSindices,addaudit)
%          TS = tsAddAudit(TS,addaudit)
%
% DESCRIPTION
% This function adds a string to the end of the audit string.
%
% INPUT
% TSindices/TS    The timeseries need to have their audit string altered
% addaudit        The string to append at the end
%
% OUTPUT
% TS		  In case of directly entered data, the new data is returned
%
% SEE ALSO

    % In case the data is entered directly and not through the TS system

    if addaudit(1) ~= '|'
        addaudit = ['|' addaudit];
    end
    
    if iscell(TSindices)
        for q=1:length(TSindices)
            TSindices{q}.audit = [TSindices{q}.audit addaudit];
        end
    end
    if isstruct(TSindices)
        TSindices.audit = [TSindices.audit addaudit];
    end
    if isnumeric(TSindices)
        global TS;
        for p=TSindices(:)'
            if p<=length(TS)
                TS{p}.audit = [TS{p}.audit addaudit];
            end
        end
    end



