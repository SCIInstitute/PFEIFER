function varargout = ioAddFilePath(pathname,varargin)

    if nargin > 1

        for p=1:(nargin-1)
            if iscell(varargin{p})
                files = varargin{p};
                for q=1:length(files)
                    files{q} = fullfile(pathname,files{q});
                end
                varargout{p} = files;
            end
            if ischar(varargin{p})
                file = varargin{p};
                file = fullfile(pathname,file);
                varargout{p} = file;
            end
        end
    
    end
    return
    