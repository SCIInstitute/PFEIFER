function s= readacq(filename)

  fid = fopen(filename, 'rt', 's');

  fseek(fid, 606, 'bof');
  numLeads = fread(fid, 1, 'uint16');
  fseek(fid, 608, 'bof');
  numFrames = fread(fid, 1, 'uint32');
  
  % Hardware has been know to lie so double-check numFrames value.
  fseek(fid, 0, 'eof');

  actualSize = ftell(fid) - 1024;
  claimedSize = numFrames*numLeads*2;
  if claimedSize < actualSize,
    numFrames = actualSize/(2*numLeads);
  end
  
  s = [];
  fseek(fid, 92, 'bof');
  s.label = char(fread(fid, 30, '*uchar'))';

  % Sample frequency
  fseek(fid, 634, 'bof');
  [samplefrequency ignore] = fread(fid, 1, 'uint16=>double');

  % Get hardware data (mode, gain, box).
  fseek(fid, 884, 'bof');

  hwi = fread(fid, 1, 'uint8');
  fclose(fid);

  gain(1) = bitand(bitshift(hwi, -2), hex2dec('01')) + 1;
  gain(2) = bitand(bitshift(hwi, -3), hex2dec('01')) + 1;
  gain(3) = bitand(bitshift(hwi, -4), hex2dec('01')) + 1;
  gain(4) = bitand(bitshift(hwi, -5), hex2dec('01')) + 1;
  s.box = bitand(bitshift(hwi, -6), hex2dec('01')) + 1;

  % Generate per-lead gains.
gains = zeros(numLeads, 1);
  if s.box == 1
    gains(1:2:numLeads) = gain(1);
    gains(2:2:numLeads) = gain(2);
    hwmap = 1:numLeads;
  end
  if s.box == 2
    gains(1:2:numLeads/2) = gain(1);
    gains(2:2:numLeads/2) = gain(2);
    gains(numLeads/2+1:2:numLeads) = gain(3);
    gains(numLeads/2+2:2:numLeads) = gain(4);
    hwmap = [1:2:numLeads 2:2:numLeads];
  end

  fid = fopen(filename, 'rt', 'b');
  fseek(fid,1024,-1);
  s.potvals = fread(fid,[numLeads numFrames],'int16');
%  s.potvals = s.potvals - 32768;
  fclose(fid);
  

  s.fids = [];
  s.filename = filename;
  s.gain = gains;
  s.numleads = numLeads;
  s.numframes = numFrames;
  s.samplefrequency = samplefrequency;
  s.leadinfo = [];
  s.unit = 'raw';
  
  s.geom = [];
  s.geomfile = [];
  s.expid = [];
  s.text = [];
  s.audit = 'Acq to matmap conversion';
  s.time = datestr(now, 14);
  s.newfileext = [];
  s.averagemethod = [];
  s.selframes = [];
  s.fidset = [];
  s.baselinewidth = [];
  s.tsdfcfilename = [];
