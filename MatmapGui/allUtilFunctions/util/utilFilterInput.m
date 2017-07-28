function varargout = utilFilterInput(cellarray)
% FUNCTION [filenames,varargout] = utilFilterInput(varargin) 
%
% DESCRIPTION
% This function stripts the supplied filenames form the first fields of input. The filename fields
% can be eihter a cellarray full of strings or a string with a filename. Filenames are recognised
% by the fact that they should contain more than only letters (a dot or a wildcard should be present).
% The first arguments are read until no string cellarray or a character is found.
%
% INPUT
% varargin           The cell array that the matlab command varargin returns.
%
% OUTPUT
% filenames          Cell array with the filenames   
% varargout          The other remaining parameters, all inputs not assinged will be given
%                    an empty array
%
% EXAMPLE
%
% >  function result = myFunction(varargin)
% >  [filenames,options,string] = utilFilterInput(varargin);
%
% This will filter the input of the function and search for filenames
%
% SEE ALSO - 

filenames = {};
otherinput = 1;

for p=1:length(cellarray),

    if (~iscellstr(cellarray{p}))&(~ischar(cellarray{p})),
        otherinput = p; 					% the other input starts here
        break; 							% read all filenames
    end
    
    if iscellstr(cellarray{p}),
        strarray = cellarray{p};				% get all the filenames
        filenames(end+1:end+length(strarray)) = strarray;	% add them to the end of the filenames string array
    end    

    if ischar(cellarray{p}),
        if sum(isletter(cellarray{p})) == length(cellarray{p}),	% check whether it can be a filename
            otherinput = p;					% no definitely no filename
            break;
        end
        filenames{end+1} = cellarray{p};			% add the name to the list
    end         
end

varargout{1} = filenames;					% set filenames as first output


for p=2:nargout,
    varargout{p} = [];						% default output: empty array 
    if length(cellarray) >= (p-2)+otherinput,			% can I assign a value to this output
        varargout{p} = cellarray{(p-2)+otherinput};    		% yes, copy the contents of the cell
    end  
end

return