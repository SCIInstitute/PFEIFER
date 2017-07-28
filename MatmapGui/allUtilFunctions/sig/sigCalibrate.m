function cal = sigCalibrate(varargin)

% FUNCTION cal = sigCalibrate(acqfilename,[mappingfile],'1mV'/'10mV',[channels],[acqfilename2],....,[outputfilename])
%
% DESCRIPTION
% This function generates a calibration file.
%
% INPUT
% acqfilename    Name of the ACQ file that contains the 1mV or 10mV dataset
% mappingfile    Name of the mapping file used to map the acq-file
% '1mV'          To indicate it is a 1mV file
% '10mV'         To indicate it is a 10mV file (you always need to specify one of both)
% channels       To tell which channels should be used in the calibration the other channels are 
%                ignored. This option is for multiple acq-file so you can specify which channel
%                is calibrated with which file
% acqfilename2   After the first input you can enter a second couple of acqfilenames, '1mv'/'10mv', mapping file and
%                channel description to complete the cal file. Even three or more entries are allowed
% outputfilename Name for a file in which the cals are stored
%
% OUTPUT
% cal            A vector containing the calibration values (scalars for multiplying the signal strengths).
%
% SEE ALSO
%
% EXAMPLE
% >> tank = [1:192]
% >> cage = [193:802];
% >> cal =  sigCalibrate('10mvcal.acq','10mV',tank,'torsopluscage.mapping','1mvcal.acq','1mV',torso,'mycals.cal');
% This calibrates the signals based on two files the vectors tank and cage indicate which channels
% to take from each one. The mapping file is only specified once as it is equal for both files.
% The last argument saves the calibrations in the file mycals.cal. This input is not required, you can use
% ioWriteCal as well.


    calfiles = {};
    mappingfiles = {};
    acqfiles = {};
    potentials = [];
    channels = {};

    for p=1:nargin,
        if ischar(varargin{p}),
        switch varargin{p},
        case {'1mV','1mv','1MV'},
            potentials(end+1) = 1;
        case {'10mV','10mv','10MV'},
            potentials(end+1) = 10;
        otherwise
            [pn,fn,ext] = fileparts(varargin{p});
            switch ext,
            case '.cal',
                calfiles{end+1} = varargin{p};
            case '.mapping',
                mappingfiles{end+1} = varargin{p};
            case '.acq',
                acqfiles{end+1} = varargin{p};
            end
        end
        end
        
        if isnumeric(varargin{p}),
           channels{end+1} = varargin{p};
        end
    end
    
    if length(mappingfiles) == 1,
       for p=1:length(acqfiles), mappingfiles{p} = mappingfiles{1}; end
    end
    
    if length(potentials) == 1,
       for p=1:length(acqfiles), potentials(p) = potentials(1); end
    end
 
    if length(potentials) == 0,
        msgError('You need to indicate whether it is a ''1mV'' or ''10mV'' calibration set',5);
    end    
    
    if length(acqfiles) ~= length(potentials),
        msgError('The number of potential settings (1mV/10mV) should be equal to the number of ACQ-files',5);
    end
    
    if length(acqfiles) ~= length(mappingfiles),
        msgError('The number of mapping files should be equal to the number of ACQ-files',5);
    end         
    
    if length(calfiles) > 1,
        msgError('You should only supply one output filename',2);
        calfiles = calfiles(1);
    end
    
    cal = [];
    
    for p=1:length(acqfiles),
        if length(mappingfiles) > 0,
            D = ioReadTSdata(acqfiles{p},mappingfiles{p});
        else
            D = ioReadTSdata(acqfiles{p});
        end
        if p == 1,
            cal = zeros(D{1}.numleads,1);
        end
        
        numblocks = floor(D{1}.numframes/500);
        if numblocks == 0,
            leadmax = max(D{1}.potvals,[],2);
            leadmin = min(D{1}.potvals,[],2);
        else
            for q=1:numblocks,
                g(:,q) = max(D{1}.potvals(:,[1:500]+(q-1)*500),[],2);
                h(:,q) = min(D{1}.potvals(:,[1:500]+(q-1)*500),[],2);
            end
            leadmax = median(g,2);
            leadmin = median(h,2);
        end
        cal(channels{p}) = potentials(p)*2*sqrt(2)./(leadmax(channels{p})-leadmin(channels{p}));
    end
    
    if length(calfiles) > 0,
        ioWriteCal(calfiles{1},cal);
    end
    
    return             
        