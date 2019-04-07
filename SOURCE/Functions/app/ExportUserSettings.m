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


function ExportUserSettings(filename,index,fields)
    % save the user selections stored in TS{index}.(fields) in PROCESSINGDATA.  fields could be e.g. 'fids' 
    % if fields dont exist in ts, it will be set to [] in PROCESSINGDATA. It's no
    % problem if field doesnt exist in PROCESSINGDATA at beginning
    
    global PROCESSINGDATA TS;
    %%%% first find filename
    filenum = find(strcmp(filename,PROCESSINGDATA.FILENAME));

    %%%% if no entry for the file exists so far, make one
    if isempty(filenum)
        PROCESSINGDATA.FILENAME{end+1} = filename;
        filenum = length(PROCESSINGDATA.FILENAME);
    end
    
    %%%% loop through fields and save data in PROCESSINGDATA
    for p=1:length(fields)
        if isfield(TS{index},lower(fields{p}))
            value = TS{index}.(lower(fields{p}));
            if isfield(PROCESSINGDATA,fields{p})
                data = PROCESSINGDATA.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            PROCESSINGDATA.(fields{p})=data;
        else
            value = [];
            if isfield(PROCESSINGDATA,fields{p})
                data = PROCESSINGDATA.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            PROCESSINGDATA.(fields{p})=data;
        end
    end
    
    %%%% save data in PROCESSINGDATA file
    savePROCESSINGDATA; 
end