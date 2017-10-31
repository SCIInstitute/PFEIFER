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


function TSindices = ioReadTS(varargin)

% FUNCTION TSindices = ioReadTS(filenames,[indexvector],[options])
%
% INPUT
% filenames      An cellarray of strings or a string specifying the files to be loaded. The function requires
%                that you specify the filename complete with extension. The use of wildcards in the filenames
%                is allowed. The filenames can be contained in one or more input arguments. The order of the
%                filenames determines the order in which they are read.
%                Files loaded include .tsdf/.data/.acq/.tsdfc./dfc./.fids/.mapping/.cal/.cal8
%                Warning do not mix .acq and .tsdf it may lead to some unpredicted effects
%                Specifying a TSDFC-file without any TSDF-files will load the complete list contained in the
%                TSDFC-file.
%                Specifying a TSDF-file in combination with a TSDFC-file, will use the TSDFC-files to lookup
%                the data specified for the timeseries in the TSDF-files. Instead of a TSDFC-file a DFC file
%                can be specified as well. The latter is considered to be an array TSDFC-files. If multiple
%                entries are found in the collection of TSDFC-files multiple versions of the TSDF-file are 
%                loaded. 
%                Specifying a GEOM-file or a combination of FAC/PTS/CHANNELS-files will add the geometry to the
%                loaded data. The geometry will be linked to the TS-data in the geom field which has a pointer
%                to geometries specified in GEOM. In order to specify geometries keep up with the following rules
%                specify the geometry files in the following order channels-file followed by a geom or fac file.
%                The latter may be accompanied by pts file as well. The program will keep this search order and
%                groups the geometry files in that order.
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
% TSindices      The indices to the TS-cell array where the files have been loaded.
%
% NOTE FOR ACQ FILES
%                Calibration and mapping is done while loading of the acq-data. Specify a .mapping and a .cal/.cal8
%                file as input parameters for calibration and mapping of the data. Use sigCalibrate8 to create a
%                calibration file.    
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
% .scalemap      For ACQ files only. This options specifies the scaling of each map. Basicly each channel is multiplied
%                by this value. The scalemap has to be the same size as the number of channels or th e leadmap
%                In case of a leadmap specify the scalemap values in the same order as the leadmap (the way it is done
%                in a .cals file)
% SEE ALSO ioWriteTS

% JG Stinstra, 2002

[files,indexvector,options] = ioiInputParameters(varargin); % process the input file names

% setup global and an empty output

global TS;
TSindices = [];

if ~isfield(options,'skiptsdffile')
    options.skiptsdffile = 0;				% By default the function loads the TSDF-files
end    

if ~isfield(options,'readtsdffids')
    options.readtsdffids = 0;				% cannot read fids when you do not want to load them at all
end    


% MAIN LOOP/SWITCH BOARD



if ~isempty(files.optraw)
    TSindices = [];
    for p=1:length(files.optraw)
        TSindices = [TSindices ioReadOptraw(files.optraw{p},options)];
    end
    return;
end


if ~isempty(files.mat)
     for q = 1:length(files.mat)
        matfile = files.mat{q};
        S = load(matfile);
        fname = fieldnames(S);
        for p=1:length(fname)
            data = getfield(S,fname{p});
            if isstruct(data)
                if isfield(data,'potvals')
                    index = tsNew(1);
                    TS{index} = data;
                    tsSet(index,'filename',matfile);
                    if ~isfield(TS{index},'label') TS{index}.label = ''; end
                    if ~isfield(TS{index},'numleads') TS{index}.numleads = size(TS{index}.potvals,1); end
                    if ~isfield(TS{index},'numframes') TS{index}.numframes = size(TS{index}.potvals,2); end
                    if ~isfield(TS{index},'leadinfo') TS{index}.leadinfo = zeros(size(TS{index}.potvals,1),1); end
                    if ~isfield(TS{index},'unit') TS{index}.unit = 'mV'; end
                    if ~isfield(TS{index},'expid') TS{index}.expid = ''; end
                    if ~isfield(TS{index},'text') TS{index}.text = ''; end
                    if ~isfield(TS{index},'samplefrequency') TS{index}.samplefrequency = 1000; end
                    if ~isfield(TS{index},'audit') TS{index}.audit = ''; end
                    TSindices = [TSindices index]; 
                end
            end
            if iscell(data)
                for r = 1:length(data)
                    D = data{r};
                    if isstruct(D)
                        if isfield(D,'potvals')
                            index = tsNew(1);
                            TS{index} = D;
                            tsSet(index,'filename',matfile);
                            if ~isfield(TS{index},'label') TS{index}.label = ''; end
                            if ~isfield(TS{index},'numleads') TS{index}.numleads = size(TS{index}.potvals,1); end
                            if ~isfield(TS{index},'numframes') TS{index}.numframes = size(TS{index}.potvals,2); end
                            if ~isfield(TS{index},'leadinfo') TS{index}.leadinfo = zeros(size(TS{index}.potvals,1),1); end
                            if ~isfield(TS{index},'unit') TS{index}.unit = 'mV'; end
                            if ~isfield(TS{index},'expid') TS{index}.expid = ''; end
                            if ~isfield(TS{index},'text') TS{index}.text = ''; end       
                            if ~isfield(TS{index},'samplefrequency') TS{index}.samplefrequency = 1000; end
                            if ~isfield(TS{index},'audit') TS{index}.audit = ''; end
                            TSindices = [TSindices index]; 
                        end
                    end
                end
            end
        end
    end
end



if (~isempty(files.acq))
   % Load a series of ACQ files into memory
     
   for p = 1:length(files.acq)
      % This function first scans the TSDF-file to see whether more than one file is stored in this file
      % subsequently it creates empty spaces in the TS structure and starts loading the TSDF files into
      % these empty slots

      acqfile = files.acq{p};
      if options.skiptsdffile
          index = tsNew(1);						% create an empty array
          tsSet(index,'filename',acqfile);				% just put in the filenames
      else
          addaudit = sprintf('|acqfile=%s',acqfile);  
          newoptions = options;
          if ~isempty(files.mapping)
             mapfile = files.mapping{1};
             newoptions.leadmap = ioReadMapping(mapfile);
             addaudit = [addaudit sprintf('|mappingfile=%s',mapfile)];
          end
   
          if ~isempty(files.cal)
             calfile = files.cal{1};
             newoptions.scalemap = ioReadCal(calfile);
             addaudit = [addaudit sprintf('|calfile=%s',calfile)];
          end    
          if ~isempty(files.cal8)
             calfile = files.cal8{1};
             newoptions.scalemap = ioReadCal8(calfile);
             addaudit = [addaudit sprintf('|cal8file=%s',calfile)];
          end
                    
          if ~isempty(files.acqcal)
             calfile = files.calacq{1};
             newoptions.scalemap = ioReadCal8(calfile);
             if ~isempty(files.mapping)
                 leadmap = newoptions.leadmap;
                 newoptions = rmfield(newoptions,'leadmap');
             end    
             index = ioiReadACQ(acqfile,newoptions);
             TS{index}.audit = [TS{index}.audit addaudit];
             if ~isempty(files.mapping)
                TS{index}.potvals = TS{index}.potvals(leadmap,:);
                TS{index}.leadinfo = TS{index}.leadinfo(leadmap);
                TS{index}.gain = TS{index}.gain(leadmap);
                TS{index}.numnleads = size(leadmap);
             end
         else
             index = ioiReadACQ(acqfile,newoptions);
             TS{index}.audit = [TS{index}.audit addaudit];     
         end
      end
    
      if ~isfield(TS{index},'samplefrequency'), TS{index}.samplefrequency = 1000; end
      
      TSindices = [TSindices index]; 					% add them to the output vector 
   end
end


if (~isempty(files.ac2))
   % Load a series of AC2 files into memory
     
   for p = 1:length(files.ac2)

        ac2file = files.ac2{p};

        addaudit = sprintf('|ac2file=%s',ac2file);  
        newoptions = options;

        %%%% if there is a mapping file, load it
        if ~isempty(files.mapping)
            mapfile = files.mapping{1};
            newoptions.leadmap = ioReadMapping(mapfile);
            addaudit = [addaudit sprintf('|mappingfile=%s',mapfile)];
        end

        %%%% if there is a calibration file, load it
        if ~isempty(files.cal8)
            calfile = files.cal8{1};
            newoptions.scalemap = ioReadCal8(calfile);
            addaudit = [addaudit sprintf('|cal8file=%s',calfile)];
        end

        %%%% read in the ac2 file
        index = ioiReadAC2(ac2file,newoptions);
        TS{index}.audit = [TS{index}.audit addaudit];     

        if ~isfield(TS{index},'samplefrequency'), TS{index}.samplefrequency = 1000; end

        TSindices = [TSindices index]; 					% add them to the output vector 
   end
end


