% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


function name = ioUpdateFilename(fileext,oldfilename,filenameaddon,varargin)
% FUNCTION filename = ioUpdateFilename(fileext,oldfilename,[filenameaddon])
%
% DESCRIPTION
% This function generates the CVRTI formatted filename from the different pieces
%
% INPUT
% fileext             the filename extension
% oldfilename         the old filename
% filenamesaddon      an addon like '-itg' or '-ari' etc.
%
% OUTPUT
% filename        the filename or a list of filenames (cellarray)
%
% SEE ALSO ioTSDFFilename


% try the 4 decimal filenames

    name = '';
    
    if nargin > 2,
        if iscellstr(oldfilename) & iscellstr(filenameaddon),
            error('oldfilename and filenameaddon cannot be both cell arrays');
        end
            
        if iscellstr(filenameaddon)
            name = {};
            for q=1:length(filenameaddon),
                name{q} = '';
                [dummy,fnstart,ext] = fileparts(oldfilename);
                fnend = '';
                dashpos = findstr(fnstart,'-');
       
                if ~isempty(dashpos),
                    if sum(isletter(fnstart(dashpos(end):end))) == 0,
                        fnend = fnstart(dashpos(end):end);
                        fnstart = fnstart(1:(dashpos(end)-1));        
                    end    
                end
        
                name{q} = [fnstart ];
                if nargin > 2,
                    name{q} = [name{q} filenameaddon{q}];
                end
                if nargin > 3,
                    name{q} = [name{q} varargin{:}];
                end
                name{q} = [name{q} fnend fileext];
            end
            return
        end
    end    
    
    if ischar(oldfilename),
        [dummy,fnstart,ext] = fileparts(oldfilename);
        fnend = '';
        dashpos = findstr(fnstart,'-');

        if ~isempty(dashpos),
            if sum(isletter(fnstart(dashpos(end):end))) == 0,
                fnend = fnstart(dashpos(end):end);
                fnstart = fnstart(1:(dashpos(end)-1));        
            end    
        end
        
        name = [fnstart ];
        if nargin > 2,
            name = [name filenameaddon];
        end
        if nargin > 3,
            name{q} = [name{q} varargin{:}];
        end               
        name = [name fnend fileext];
    end

    if iscellstr(oldfilename)
        name = {};
        for q=1:length(oldfilename),
            name{q} = '';
            ofilename = oldfilename{q};
            [dummy,fnstart,ext] = fileparts(ofilename);
            fnend = '';
            dashpos = findstr(fnstart,'-');
       
            if ~isempty(dashpos),
                if sum(isletter(fnstart(dashpos(end):end))) == 0,
                    fnend = fnstart(dashpos(end):end);
                    fnstart = fnstart(1:(dashpos(end)-1));        
                end    
            end
        
            name{q} = [fnstart ];
            if nargin > 3,
                name{q} = [name{q} filenameaddon];
            end
            if nargin > 3,
                    name{q} = [name{q} varargin{:}];
            end    
            name{q} = [name{q} fnend fileext];
        end
    end 
    
return
