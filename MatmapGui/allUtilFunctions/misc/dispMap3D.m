function dispmap3d(varargin)

dispfiles = [];

mode = 'epi';
slavescale = 0;
tsdfcfile = [];
channel = 0;

label ='rsm19jun03'

for p=1:nargin
   if isnumeric(varargin{p}),
       dispfiles = [dispfiles varargin{p}];
   end
   if ischar(varargin{p}),
       switch varargin{p},
            case {'epi','endo','all','epiitg','endoitg','allitg'}
                mode = varargin{p};
            case 'slave'
                slavescale = varargin{p+1};
                p = p +1; 
            case 'label'
                label = varargin{p+1};
                p = p + 1;
            case 'tsdfc'
                tsdfcfile = varargin{p+1};
                p = p + 1;
            case 'channel'
                channel = varargin{p+1};
                p = p + 1;
        end
    end
end

command = '!map3d -o -b -nw '

slavestring = ''

if slavescale > 0,
    slavestring = ['-sl ' sprintf('%d ',slavescale) ' '];
end

winsize = {'-as 0 245 623 923 ','-as 245 490 623 923 ','-as 490 735 623 923 ','-as 735 980 623 923 ', ...
           '-as 0 245 150 473 ','-as 245 490 150 473 ','-as 490 735 150 473 ','-as 735 980 150 473 '};
   
timesize = {'-at 0 245 523 623 ','-at 245 490 523 623 ','-at 490 735 523 623 ','-at 735 980 523 623 ', ...
            '-at 0 245  50 150 ','-at 245 490  50 150 ','-at 490 735  50 150 ','-at 735 980  50 150 '};   
   
endofacfile = '-f endosock2.fac ';
epifacfile  = '-f 490sock.geom -lm 490sock.lmarks ';


if length(dispfiles) > 8,
    warning('Last files are not displayed (only first 8 files are displayed)');
    dispfiles = dispfiles(1:8);
end

if (length(dispfiles) >4 )& (strcmp(mode,'all')==1),
    warning('last fiels are not displayed (only first 4 files are displayed)');
    dispfiles = dispfiles(1:4);
end

if ~isempty(tsdfcfile),
    fprintf(1,'Aligning your data in time\n');
    options.scantsdffile = 1;
    rpeak = [];
    nframes = [];
    
    for p=1:length(dispfiles),
        global TS;
        index = ioReadTS(ioTSDFFilename(label,'-cs',dispfiles(p)),tsdfcfile,options);
        nframes(p) = TS{index}.numleads;
        rpeak(p) = fidsGetGlobalFids(index,'rpeak');
        tsClear(index);
    end
    
    
    epeak = min(rpeak);
    startf = rpeak - epeak + 1;
    nframes = nframes - startf;
    endf = startf + min(nframes);
   
    for p=1:length(dispfiles),
        if (~isnan(startf(p))), framecommand{p} = sprintf(' -s %d %d ',startf(p),endf(p)); else framecommand{p} = ''; end
    end
else
    for p=1:length(dispfiles),
        framecommand{p} = '';
    end
end

if channel,
    channelcommand = sprintf('-t %d ',channel);
else
    channelcommand = '';
end


switch mode
    case 'epi'
        for p=1:length(dispfiles),
            addcommand = [ epifacfile winsize{p} '-p ' sprintf('%s-cs-%04d.tsdf',label,dispfiles(p)) ' ' framecommand{p} slavestring timesize{p} channelcommand];
            command = [command addcommand];
        end
    case 'endo'
       for p=1:length(dispfiles),
            addcommand = [ endofacfile winsize{p} '-p ' sprintf('%s-es-%04d.tsdf',label,dispfiles(p)) ' ' framecommand{p} slavestring timesize{p} channelcommand];
            command = [command addcommand];
        end
    case 'all'
        
        for p=1:length(dispfiles),
            addcommand = [ epifacfile winsize{p} '-p ' sprintf('%s-cs-%04d.tsdf',label,dispfiles(p)) ' ' framecommand{p} slavestring timesize{p} channelcommand];
            command = [command addcommand];
            addcommand = [ endofacfile winsize{p+4} '-p ' sprintf('%s-es-%04d.tsdf',label,dispfiles(p)) ' ' framecommand{p} slavestring timesize{p+4} channelcommand];
            command = [command addcommand];
        end
    
    case 'epiitg'
        for p=1:length(dispfiles),
            addcommand = [ epifacfile winsize{p} '-p ' sprintf('%s-cs-%04d_itg.tsdf',label,dispfiles(p)) ' ' slavestring timesize{p} channelcommand];
            command = [command addcommand];
        end
    case 'endoitg'
       for p=1:length(dispfiles),
            addcommand = [ endofacfile winsize{p} '-p ' sprintf('%s-es-%04d_itg.tsdf',label,dispfiles(p)) ' ' slavestring timesize{p} channelcommand];
            command = [command addcommand];
        end
    case 'allitg'
        
        for p=1:length(dispfiles),
            addcommand = [ epifacfile winsize{p} '-p ' sprintf('%s-cs-%04d_itg.tsdf',label,dispfiles(p)) ' ' slavestring timesize{p} channelcommand];
            command = [command addcommand];
            addcommand = [ endofacfile winsize{p+4} '-p ' sprintf('%s-es-%04d_itg.tsdf',label,dispfiles(p)) ' ' slavestring timesize{p} channelcommand];
            command = [command addcommand];
        end
end

command


eval(command);

