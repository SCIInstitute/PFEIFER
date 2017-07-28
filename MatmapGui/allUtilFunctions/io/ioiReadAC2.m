function TSindices = ioiReadACQ(varargin)

% FUNCTION TSindices = ioiReadACQ(tsdffilename,[indices],[options])
%
% INTERNAL FUNCTION
% Avoid using this function, as it might change in the future
% Use ioReadTS instead
%
% DESCRIPTION
% This function reads one ACQ file into the TS-structure. The function is based on
% mexReadACQ, but has some additional functionality, for instance it adds data on where
% the data originated from, so when using ioWriteTSDF it knows what filenames to use by
% default. 
% 
% INPUT
% acqfilename           A single acq-filename for reading
% indices               In case multiple timeseries are stored, select the ones needed
% options               For future usage
%
% OUTPUT
% TSindices             Indices into the TS-structure where the data has been loaded
%
% SEE ALSO ioReadTS, ioWriteTS

%%
% This function represents the matlab side of processing the data
% 1) the function reads the tsdf-file specified
% 2) It checks for the number of timeseries in the file
% 3) It creates a new TS structure
% 4) It checks the AUDIT string whether any additional data has been stored in there
% 

[files,~,options] = ioiInputParameters(varargin);

global TS;

ac2filename = files.ac2{1};
TSindices = [];

if isempty(ac2filename)
    msgError('No AC2-file specified',3);
    return;
end    

TSindices = tsNew(1);						% get the same number of new entries 
% TS(TSindices(1)) = mexReadACQ(acqfilename,options);				% load the timeseries into memory
% TS{TSindices(1)}.newfileext = ''; % extension for the new filename

%data = readacq(ac2filename);

% Matlab implementation of the mexReadACQ function
% First, create the data structure
data = struct('filename', '' , ...
              'label', '' , ...
              'potvals', [], ...
              'gain', [], ...
              'numleads', [], ...
              'numframes', [], ...
              'leadinfo', [], ...
              'unit', '', ...
              'geom', [], ...
              'geomfile', '', ...
              'expid', '', ...
              'text', '', ...
              'audit', '', ...
              'time', '');
          
 %Second, try to open the binary file and read the header
 %file = fopen(ac2filename, 'r', 'b');
 file = fopen(ac2filename, 'rt', 's');
 fseek(file,92,'bof');
 d_c = fread(file, 1, 'int8');
 label = fread(file,d_c,'*char');  %extract label from the header
 fseek(file, 580, 'bof');
 tsc = fread(file, 1, 'int8');
 time = fread(file,tsc, '*char'); % time

  fseek(file, 606, 'bof');
  numleads = fread(file, 1, 'uint16');
  fseek(file, 608, 'bof');
  numframes = fread(file, 1, 'uint32');
 

 
 data.filename = ac2filename;
 data.label = num2str(label');
 data.time = num2str(time');
 data.numleads = numleads;
 data.numframes = numframes;
 
 
 %Third, determine if the entire file is to be read
 if isfield(options, 'scantsdffile') && options.scantsdffile == 1 %only the header file needs to be scanned
     TS{TSindices(1)} = data; % just store the header in the memory
 else

%     TS(TSindices(1)) = mexReadACQ(acqfilename,options);
     potval = zeros(numleads,numframes); %potential values
     gaininfo = zeros(numleads,numframes);   % gain setting
     leadinfo = zeros(numleads,1); %bad leads.. for now, this is just a place holder
     
     %Read the raw data in to a matrix 
     fseek(file, 1024, 'bof');
     rawval = fread(file,[numleads,numframes],'uint16=>uint16');

     %Test #2 if the first channel of each mux has the most 
     %significant bit is set to 1
     %sig_bit = bitshift(rawval, -15);
     
     %Extract gain and potential information from the raw data
     
     
     
     bs=bitshift(rawval,-12);
     ui=uint16(7);    
     gaininfo = bitand(bs,ui);
     
     
     
     
     %gaininfo = bitand(bitshift(rawval,-12),uint16(7));
     potval  = double(bitand(rawval,uint16(4095))) - 2048;
     
    
     %if mapping file is available re-map the potential values
     if isfield(options, 'leadmap')
         try
             potval = potval(options.leadmap,:);
             gaininfo = gaininfo(options.leadmap,:);
         catch
             msg='Number of entries in mapping file doesn''t match number of leads. Wrong mapping file?';
             errordlg(msg)
             error('dimensions of mapping file and potvals don''t match')
         end
     end
     
     %if calibration file is available, recalibrate the data
     if isfield(options, 'scalemap')
         for i=1:numleads
             for j=1:numframes
                 cal = options.scalemap(i,gaininfo(i,j)+1);
                 potval(i,j) = potval(i,j)*cal; 
             end
         end      
     end
     
     data.potvals = potval;
     data.gain = gaininfo(:,1);
     data.leadinfo = leadinfo;
     TS{TSindices(1)} = data;
     
     %Test #3 for accuracy between the two versions of acqreader
     %j_potval = mexReadACQ(acqfilename,options);
     %diff_val =  potval - j_potval{1,1}.potvals;
         
          
 end
 
 %TS{TSindices(1)} = data;
 TS{TSindices(1)}.newfileext = '';
 fclose(file);
               
return