function scriptInterp(tsdflabel,tsdfnumbers,varargin)

% FUNCTION scriptInterp(tsdflabel,tsdfnumbers,.geomfile/.facfile/.channelsfile,badleads)
%
% DESCRIPTION
% This function does the laplacian interpolation scheme for a series of
% tsdf files.
%
% INPUT
% tsdflabel    The label of the tsdf files (label is filename without -number)
% tsdfnumbers  The numbers of the files you want to process
% .geomfiles   The .geom/.fac/.pts/.channels files that describe the
%              geometry. This input cab be spread over multiple inputs
% badleads     The badlads you want to interpolate
%
% OUTPUT
%              Tries to overwrite old files with the newly interpolate ones
%
% SEE ALSO
% -

global TS;

filenames = ioTSDFFilename(tsdflabel,tsdfnumbers);
L = triLaplacianInterpolation(varargin{:});
index = ioReadTS(filenames);
for p=index,
    TS{p}.potvals = L*TS{p}.potvals;
end
ioWriteTS(index,'oworiginal');
tsClear(index);

% fin %
