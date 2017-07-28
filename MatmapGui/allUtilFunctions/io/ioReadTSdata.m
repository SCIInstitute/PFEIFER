function data = ioReadTSdata(varargin)

% FUNCTION data = ioReadTSdata(filenames,[indexvector],[options])
%
% REMARK
% This function is a copy of ioReadTS but does not load the data in the TS structure but returns a cell array
% directly.
%
% INPUT
% filenames      An cellarray of strings or a string specifying the files to be loaded. The function requires
%                that you specify the filename complete with extension. The use of wildcards in the filenames
%                is allowed. The filenames can be contained in one or more input arguments. The order of the
%                filenames determines the order in which they are read.
%                Files loaded include .tsdf/.tsdfc./dfc/.fids/.acq/.mapping/.cal/.cal8 
%                Specifying a TSDFC-file without any TSDF-files will load the complete list contained in the
%                TSDFC-file.
%                Specifying a TSDF-file in combination with a TSDFC-file, will use the TSDFC-files to lookup
%                the data specified for the timeseries in the TSDF-files. Instead of a TSDFC-file a DFC file
%                can be specified as well. The latter is considered to be an array TSDFC-files. If multiple
%                entries are found in the collection of TSDFC-files multiple versions of the TSDF-file are 
%                loaded. 
%
% indexvector    Specifies which and in which order the timeseries have to be loaded. Assuming the input file
%                series to be number 1 to n. The indexvector tells the function which of those to actually load.
%                Use this function to specify the timeseries in a TSDFC-file or for a TSDF-file with multiple
%                entries. The timeseries are read first scanning the first string array or string then passing to
%                the next argument and scanning through them etc. Use ioScanTS to get an overview of the timeseries
%                specified.
% options        See options section
%
% OUTPUT
% data           A cell array with the data contained in the files.
%
% OPTIONS
% Options can be defined as a structured array with fields specifying the options. Hence an option
% is a fieldname and its contents. Default options do not need to be specified (do not include the field)
% Here is a list of options you can use (will be extended in future)
%
% .framemap      Specifies which frames you want to read e.g. [1:20] reads the first twenty
%                The default setting is all frames.
% .leadmap       Specifies which leads you want to read e.g [1 3 5 6 7] reads channels 1,3,5,6,7
%                the default setting is all leads.
% .skiptsdffile  Specifies that you do not want to load the TSDF-files and it will only load the data from
%                the TSDFC-files. This function is turned off default. Just assign it to be one to turn it on.
% .scantsdffile  Specifies that you only want to scan the TSDF-files. This will load details like the label and
%                auditstrings, number of channels and number of leads but not the data itself.
%                This function is turned off default. Just assign it to be one to turn it on.
% .readtsdffids  Read the global fiducials stored in the TSDF-files as well. If this options is turned on, you 
%                cannot skip reading a TSDF-file. Turn this one by setting it to one.
% .timeseries    Another way of specifying which timeseries to load from a TSDF-file. This will apply to all the
%                files you supply. This array contains the number of timeseries you want to load.
% .scalemap      Adds a scalingmap for a ACQ file. A values are multiplied my the data in this vector
%                The vector should have the same size as the number of leads. 
%
% SEE ALSO ioWriteTS ioWriteTSdata ioReadTS sigCalibrate8

% JG Stinstra, 2002

global TS;

index = ioReadTS(varargin{:});
data = TS(index);
tsClear(index);

return



   
