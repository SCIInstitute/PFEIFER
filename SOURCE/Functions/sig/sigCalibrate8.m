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


function cal = sigCalibrate8(varargin)

% FUNCTION cal = sigCalibrate8(acqfilenames,[mappingfile],[cal8filename])
%
% DESCRIPTION
% This function generates a calibration file.
%
% INPUT
% acqfilename    Name of the ACQ file that contains the 1mV or 10mV dataset
% mappingfile    Name of the mapping file used to map the acq-file
% cal8filename   Name for a file in which the cals are stored
%
% OUTPUT
% cal            A vector containing the calibration values (scalars for multiplying the signal strengths).
%
% SEE ALSO
%
% EXAMPLE
% >> cal =  sigCalibrate8('10mvcal.acq','torsopluscage.mapping','1mvcal.acq','mycals.cal');
% This calibrates the signals based on two files the vectors tank and cage indicate which channels
% to take from each one. The mapping file is only specified once as it is equal for both files.
% The last argument saves the calibrations in the file mycals.cal. This input is not required, you can use
% ioWriteCal as well.


calfiles = {};
acqcalfiles = {};
mappingfiles = {};
acqfiles = {};
potentials = [];
channels = {};

displaybar = 0;
calerror = 0;

for p=1:nargin
    if ischar(varargin{p})
        [pn,fn,ext] = fileparts(varargin{p});
        switch ext
        case {'.cal','.cal8'}
            calfiles{end+1} = varargin{p};
        case {'.acqcal'}
            acqcalfiles{end+1} = varargin{p};
        case '.mapping'
            mappingfiles{end+1} = varargin{p};
        case {'.acq', '.ac2'}
            acqfiles{end+1} = varargin{p};
            fprintf(1,'CAL file: %s \n',varargin{p});
        end
        if strcmp(fn,'displaybar') == 1
            displaybar = 1;
        end
    end

end


if ~isempty(acqfiles)
    mappingfiles = {};
end

cal = [];

if displaybar == 1
    H = waitbar(0,'CALIBRATION PROGRESS ...','Tag','waitbar');
end

for p=1:length(acqfiles)

    if ~isempty(mappingfiles)
        D = ioReadTSdata(acqfiles{p},mappingfiles);
    else
        D = ioReadTSdata(acqfiles{p});
    end

    if p==1
        cal = zeros(D{1}.numleads,8);
    end

    if (contains(lower(D{1}.label),'1mv'))       % this seems wrong?  
        ten = 0;
    elseif (contains(lower(D{1}.label),'10mv'))
        ten = 1;
    else
        ten = 10;    % Assume it is a 10mV and further rely on the automated error detection    
    end


    minvalues =  [ 0.017 0.010 0.006 0.003 0.0016 0.00092 0.00053 0.00030];

    for r=1:8
        index = find(D{1}.gain(:,1) == r-1);

        if (r-1)>=4 && ~ten

            numblocks = floor(D{1}.numframes/250);
            if numblocks == 0
                leadmax = max(D{1}.potvals(index,:),[],2);
                leadmin = min(D{1}.potvals(index,:),[],2);
            else
                g = [];  h= [];
                for q=1:numblocks
                    g(:,q) = max(D{1}.potvals(index,[1:250]+(q-1)*250),[],2);
                    h(:,q) = min(D{1}.potvals(index,[1:250]+(q-1)*250),[],2);
                end
                leadmax = median(g,2);
                leadmin = median(h,2);
            end

            ind = find((leadmax-leadmin)<=50);       % For smallest gain the 1mV signal should be about 150 bits
            if ~isempty(ind)
                fprintf(1,'LEAD %d DOES NOT CONTAIN A CALIBRATION SIGNAL\n',ind);
                leadmax(ind) = 2*sqrt(2); leadmin(ind) = 0;
                calerror = 1;
            end

            cal(index,r) = 1*2*sqrt(2)./(leadmax-leadmin);

            if cal(index,r) < minvalues(r)
                cal(index,r) = 10*2*sqrt(2)./(leadmax-leadmin);  
            end

        end

         % check to see if gain between 0-3 and 10mv setting

        if (r-1)<=3 && ten 

            numblocks = floor(D{1}.numframes/250);
            if numblocks == 0
                leadmax = max(D{1}.potvals(index,:),[],2);
                leadmin = min(D{1}.potvals(index,:),[],2);
            else
                g = [];  h= [];
                for q=1:numblocks
                    g(:,q) = max(D{1}.potvals(index,[1:250]+(q-1)*250),[],2);
                    h(:,q) = min(D{1}.potvals(index,[1:250]+(q-1)*250),[],2);
                end
                leadmax = median(g,2);
                leadmin = median(h,2);
            end

            ind = find((leadmax-leadmin)<=50);       % For smallest gain the 1mV signal should be about 150 bits
            if ~isempty(ind)
                fprintf(1,'LEAD %d DOES NOT CONTAIN A CALIBRATION SIGNAL\n',ind);
                leadmax(ind) = 2*sqrt(2); leadmin(ind) = 0;
                calerror = 1;
            end

            cal(index,r) = 10*2*sqrt(2)./(leadmax-leadmin);

        end

        if (r-1)<=3 && ~ten

            numblocks = floor(D{1}.numframes/250);
            if numblocks == 0
                leadmax = max(D{1}.potvals(index,:),[],2);
                leadmin = min(D{1}.potvals(index,:),[],2);
            else
                g = [];  h= [];
                for q=1:numblocks
                    g(:,q) = max(D{1}.potvals(index,[1:250]+(q-1)*250),[],2);
                    h(:,q) = min(D{1}.potvals(index,[1:250]+(q-1)*250),[],2);
                end
                leadmax = median(g,2);
                leadmin = median(h,2);
            end

            ind = find((leadmax-leadmin)<=50);       % For smallest gain the 1mV signal should be about 150 bits
            if ~isempty(ind)
                fprintf(1,'LEAD %d DOES NOT CONTAIN A CALIBRATION SIGNAL\n',ind);
                leadmax(ind) = 2*sqrt(2); leadmin(ind) = 0;
                calerror = 1;
            end

            t = find(cal(index,r)==0);
            cal(index(t),r) = 2*sqrt(2)./(leadmax(t)-leadmin(t));

            if cal(index,r) < minvalues(r)
                cal(index,r) = 2*sqrt(2)./(leadmax-leadmin);  
            end

        end

    end
    if displaybar == 1
        H = waitbar(p/length(acqfiles),H,'Tag','waitbar');
    end

end    

if displaybar == 1
    if isgraphics(H), close(H); end
    if calerror == 1
        errordlg('NOT EVERY CHANNEL COULD BE CALIBRATED, NOT EVERY LEAD CONTAINS A CALIBRATION SIGNAL','SIGNAL CALIBRATION');
    end    
end
if ~isempty(calfiles)
  ioWriteCal8(calfiles{1},cal);
end

