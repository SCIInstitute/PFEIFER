function name = ioACQFilename(varargin)
% FUNCTION filename = ioACQFilename(label,filenumber,[filenameaddons,...])
%
% DESCRIPTION
% This function generates the ACQ filenames from the different pieces
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

name = ioFilename('.acq',varargin{:});
return

