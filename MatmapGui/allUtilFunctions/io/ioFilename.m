function name = ioFilename(fileext,varargin)
% FUNCTION filename = ioFilename(fileext,label,filenumber,[filenameaddons,...])
%
% DESCRIPTION
% This function generates the CVRTI formatted filename from the different pieces
%
% INPUT
% fileext         the filename extension
% label           the label of the series
% filenumber      the number of the file or files (in case of more numbers it 
%                 creates a cell array of filenames)
% filenamesaddons addons like '_itg' or '_epi' etc.
%
% OUTPUT
% filename        the filename or a list of filenames (cellarray)
%
% SEE ALSO ioTSDFFilename


% try the 4 decimal filenames


 if ~isempty(strfind(fileext,'ac2')) 
     name = CreateFilename(fileext,'%04d',varargin{:});
     return;
 else
     name = CreateFilename(fileext, '-%04d', varargin{:});
 end


if iscell(name), firstname = name{1}; else firstname = name; end

if ~exist(firstname,'file')
    altname = CreateFilename(fileext,'-%03d',varargin{:});
    if iscell(altname), firstaltname = altname{1}; else firstaltname = altname; end
    if exist(firstaltname,'file'), name = altname; end
end


function name = CreateFilename(fileext,numformat,varargin)


name  = '';
for p = 1:(nargin-2),
    if ischar(varargin{p}),
        if iscell(name),
            for q=1:length(name), name{q} = [name{q} varargin{p}]; end
        else
            name = [name varargin{p}];
        end
    elseif isnumeric(varargin{p})
        if iscell(name)
            if length(varargin{p}) > 1,
                error('Only one multi number argument allowed');
            else
                for q = 1:length(name), name{q} = [name{q} sprintf(numformat,varargin{p})]; end
            end          
        else
            if length(varargin{p}) > 1,
                for q=1:length(varargin{p}),
                    namecell{q} = [name sprintf(numformat,varargin{p}(q))];
                end
                name = namecell;
            else
                name = [name sprintf(numformat,varargin{p})];
            end
        end
    elseif iscellstr(varargin{p})
        if iscell(name)
            if length(varargin{p}) > 1,
                error('Only one numeric argument allowed');
            else
                for q=1:length(name), name{q} = [name{q} varargin{p}]; end
            end
        else
            if length(varargin{p}) > 1,
                for q=1:length(varargin{p}),
                    namecell{q} = [name varargin{p}{q}];
                end
                name = namecell;
            else
                name = [name varargin{p}{1}];
            end
        end
    end
end

if iscell(name)
    for q=1:length(name),
        name{q} = [name{q} fileext];
    end
else     
    name = [name fileext];
end

return
