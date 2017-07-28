function name = ioAC2Filename(varargin)
% FUNCTION filename = ioAC2Filename(label,filenumber,[filenameaddons,...])
%
% DESCRIPTION
% This function generates the AC2 filenames from the different pieces
%
% INPUT
% label           the label of the series
% filenumber      the number of the file or files (in case of more numbers it 
%                 creates a cell array of filenames)
% filenamesaddons addons like '_itg' or '_epi' etc.
%
% OUTPUT
% filename        the filename or a list of filenames (cellarray)
%
% SEE ALSO ioTSDFFilename

name = ioFilename('.ac2',varargin{:});
return

