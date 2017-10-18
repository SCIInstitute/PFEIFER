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

% Check whether the DFC-files have been converted to TSDFC-files
% If not return error

% if this warning pops up something has gone wrong as dfc-files should be implemented
if ~isempty(files.dfc)
    msgError('DFC support has not been implemented yet',5);
end

% OPTICAL DATA SUPPORT
% CURRENTLY THE CAMERA DATA IS DEFINED BY A FILE WITH NO FILE EXTENSION
% AND STARTING WITH RUN...... 
% IT IS CRUDE BUT SHOULD WORK FOR THE TIME BEING

if ~isempty(files.optraw)
    TSindices = [];
    for p=1:length(files.optraw)
        TSindices = [TSindices ioReadOptraw(files.optraw{p},options)];
    end
    return;
end

% MAT FILE SUPPORT
% THIS WILL CONVERT ANY MATLAB FILE TO THE PROPER DATA FORMAT

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

if (isempty(files.tsdf)) && (~isempty(files.tsdfc))
    % Load a complete TSDFC file into memory
    % Use ioReadTSDFC to read the complete set into memory   

    % This function adds the complete TSDFC listing to the files.tsdf directory
    % and then continues in the next function, loading them all
    
    files.tsdf = ioiReadTSDFCFiles(files.tsdfc);
    
    % This should be sufficient to force the next function to read all the files
end
    
if (~isempty(files.tsdf))
   % Load a series of TSDF files into memory
     
   for p = 1:length(files.tsdf)
     
      % This function first scans the TSDF-file to see whether more than one file is stored in this file
      % subsequently it creates empty spaces in the TS structure and starts loading the TSDF files into
      % these empty slots
   
      tsdffile = files.tsdf{p};
      if options.skiptsdffile
          index = tsNew(1);						% create an empty array
          tsSet(index,'filename',tsdffile);				% just put in the filenames
      else
          index = ioiReadTSDF(tsdffile,options);  			% store the TS entries
      end
            
      ioiReadFids(index,tsdffile,files.tsdfc,files.fids,options); 	% add the fiducials	
      fidsUpdateFids(index,options);					% check range/number of channels in fiducials
      
      TSindices = [TSindices index]; 					% add them to the output vector 
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
             if length(files.mapping) > 1
	         msgError('Currently only one mapping file per run is supported',2);
             end
             mapfile = files.mapping{1};
             newoptions.leadmap = ioReadMapping(mapfile);
             addaudit = [addaudit sprintf('|mappingfile=%s',mapfile)];
          end
   
          if ~isempty(files.cal)
             if length(files.cal) > 1
                 msgError('Currently only one cal file per run is supported',2);
             end
             calfile = files.cal{1};
             newoptions.scalemap = ioReadCal(calfile);
             addaudit = [addaudit sprintf('|calfile=%s',calfile)];
          end    
          if ~isempty(files.cal8)
             if length(files.cal8) > 1
                 msgError('Currently only one cal8 file per run is supported',2);
             end
             calfile = files.cal8{1};
             newoptions.scalemap = ioReadCal8(calfile);
             addaudit = [addaudit sprintf('|cal8file=%s',calfile)];
          end
                    
          if ~isempty(files.acqcal)
             if length(files.acqcal) > 1
                 msgError('Currently only one acqcal file per run is supported',2);
             end
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
     
      % This function first scans the TSDF-file to see whether more than one file is stored in this file
      % subsequently it creates empty spaces in the TS structure and starts loading the TSDF files into
      % these empty slots

      ac2file = files.ac2{p};
      if options.skiptsdffile
          index = tsNew(1);						% create an empty array
          tsSet(index,'filename',ac2file);				% just put in the filenames
      else
          addaudit = sprintf('|ac2file=%s',ac2file);  
          newoptions = options;
          if ~isempty(files.mapping)
             if length(files.mapping) > 1
	         msgError('Currently only one mapping file per run is supported',2);
             end
             mapfile = files.mapping{1};
             newoptions.leadmap = ioReadMapping(mapfile);
             addaudit = [addaudit sprintf('|mappingfile=%s',mapfile)];
          end
   
          if ~isempty(files.cal)
             if length(files.cal) > 1
                 msgError('Currently only one cal file per run is supported',2);
             end
             calfile = files.cal{1};
             newoptions.scalemap = ioReadCal(calfile);
             addaudit = [addaudit sprintf('|calfile=%s',calfile)];
          end    
          if ~isempty(files.cal8)
             if length(files.cal8) > 1
                 msgError('Currently only one cal8 file per run is supported',2);
             end
             calfile = files.cal8{1};
             newoptions.scalemap = ioReadCal8(calfile);
             addaudit = [addaudit sprintf('|cal8file=%s',calfile)];
          end
                    
          if ~isempty(files.acqcal)
             if length(files.acqcal) > 1
                 msgError('Currently only one acqcal file per run is supported',2);
             end
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
             index = ioiReadAC2(ac2file,newoptions);
             TS{index}.audit = [TS{index}.audit addaudit];     
         end
      end
    
      if ~isfield(TS{index},'samplefrequency'), TS{index}.samplefrequency = 1000; end
      
      TSindices = [TSindices index]; 					% add them to the output vector 
   end
end



if (isempty(files.tsdf)&& isempty(files.tsdfc) && isempty(files.acq) && isempty(files.ac2) && isempty(files.mat))
   msgError('You should specify a filename with a timeseries',1);
end
   
      
if ~isempty(files.geom)

    geomindices = ioReadGEOM(files.geom);
    tsSet(TSindices,'geom',geomindices);                % link geometry with timeseries
  
end

return   
   
