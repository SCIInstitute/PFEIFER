function A = scirunReadMatrix(filename)

% FUNCTION A = scirunReadMatrix(filename,[options,...])
%
% DESCRIPTION
% This function reads a file in the SCIRun matrix file format. It converts
% the data in the matrix into a matkab array.
%
% COMPATABILITY
% The function supports the ASCii file format and in a lesser degree the BINary
% A Problem with the binary format is that the property field (in the more recent SCIRun versions)
% can contain any object available in SCIRun and there are no counters on the sizes of these objects.
% Hence this function tries to read the file, but may get stuck on unknown objects in the
% file. In order to have a full support for binary files all possible objects in SCIRun
% should be supported. As the intention of this tool is a simple conversion, this is out
% of the scope. In the ASCii format mechanisms are build in to skip unknown objects, so
% this format is save to use. But so far I have not seen any use of the PropertyManager, so try the 
% BINary version as it is much faster and if that one fails use the ASCii format.
% In the SCIRun code a third file format is discussed being the GZIP format. Apparently it is not
% used in the current releases of SCIRun, hence it is not supported by this format.
%
% VERSION 0.1
%
% INPUT
% filename         Filename of the SCIRun matrix file (including extension)
% options          None specified at the moment (left open for future use)
%
% OUTPUT
% A                The matrix stored in the SCIRun matrix file
%
% EXAMPLES
%
% >> A = rand(5);                                           % Generate a random matrix of 5 by 5
% >> scirunWriteMatrix('mymatrix.mat',A,'sparse','BIN');    % Write a sparse matrix
% >> B = scirunReadMatrix('mymatrix.mat');                  % Reads the matrix into B
%
% SEE ALSO scirunWriteMatrix

%  scirunReadMatrix.m : reading persistent matrix objects into matlab
%
%  Version 0.1 for SCIRun 1.[4-5].x
% 
%  Written by:
%   dr. Jeroen G. Stinstra
%   Aug 6 2002
%   CardioVascular Research and Training Institute
%   University of Utah

% TO DO LIST
%
% * Need to test this function for newer versions of SCIRun
% * Improve the reading of delimiters in the ASCII case files
% * Need to find some ways of reading property classes without
%   having to scan them thoroughly for BINARY files
%

    if ~ischar(filename),
        error('ERROR: The filename should be a string');
    end
    
    if ~exist(filename,'file'),
        error('ERROR: Cannot locate the file');
    end

    SCIFILE = sciOpenFile(filename);
    SCIFILE = sciReadHeader(SCIFILE);
    
    
    sciReadClassStart(SCIFILE);
    [number,hasdata] = sciReadPointer(SCIFILE);
    
    if hasdata == 0,
        error('ERROR: Datafile does not seem to contain any data');
    end
    
    [class,version] = sciReadClass(SCIFILE);
    
    switch class
    case 'SparseRowMatrix',
    
            if version > 1, error('ERROR: This version of a sparse matrix is not supported'); end	
            [mclass,mversion] = sciReadClass(SCIFILE);
        
            switch mclass,
            case 'Matrix',
                if mversion > 3, error('ERROR: This version of the matrix class is not supported'); end
            
                if mversion < 2, tmpsym = sciReadInt(SCIFILE); end
            	
                if mversion > 2, 
                    [pclass,pversion] = sciReadClass(SCIFILE);
                    numproperties = sciReadInt(SCIFILE);
                    if (numproperties > 0) & (SCIFILE.METHOD == 1),
                        error('ERROR: Properties have not been implemented into this script, there is no way to find the start of the matrix data, please use ASCII format');
                    end
                    
                    sciReadEndClass(SCIFILE);        
                end        
                        
            otherwise
                error('ERROR: The SparseRowMatrix is from another class than Matrix')
            end    
            sciReadEndClass(SCIFILE);
    

            numcols = sciReadInt(SCIFILE);
            numrows = sciReadInt(SCIFILE);
            numnz   = sciReadInt(SCIFILE);
            
            % read row data
            
            sciReadStartDelim(SCIFILE);
                rows = sciReadDouble(SCIFILE,numrows+1);
            sciReadEndDelim(SCIFILE);
            rows = floor(interp1(rows,[1:numrows+1],[0:numnz-1]));
            
            % read column data
            
            sciReadStartDelim(SCIFILE);
                columns = sciReadDouble(SCIFILE,numnz);
            sciReadEndDelim(SCIFILE);
            columns = columns + 1;                
                            
            % read value data
            
            sciReadStartDelim(SCIFILE);
                values = sciReadDouble(SCIFILE,numnz);
            sciReadEndDelim(SCIFILE);
            
            A = sparse(rows,columns,values,numrows,numcols);
            
    
    case 'DenseMatrix',
    
            if version > 3, error('ERROR: This version of a dense matrix is not supported'); end	
            [mclass,mversion] = sciReadClass(SCIFILE);
        
            switch mclass,
            case 'Matrix',
                if mversion > 3, error('ERROR: This version of the matrix class is not supported'); end
            
                if mversion < 2, tmpsym = sciReadInt(SCIFILE); end
            	
                if mversion > 2, 
                    [pclass,pversion] = sciReadClass(SCIFILE);
                    numproperties = sciReadInt(SCIFILE);
                    if (numproperties > 0) & (SCIFILE.METHOD == 1),
                        error('ERROR: Properties have not been implemented into this script, there is no way to find the start of the matrix data, please use ASCII format');
                    end
                    
                    sciReadEndClass(SCIFILE);        
                end        
            sciReadEndClass(SCIFILE);
            
            numcol = sciReadInt(SCIFILE);
            numrow = sciReadInt(SCIFILE);
            
            sciReadStartDelim(SCIFILE);
                if version == 3,									% This version supports external files
                    split = sciReadInt(SCIFILE);
                    if split == 1,
                        rawdatafile = sciReadString(SCIFILE);						% Get the name of the external file
                        FID = fopen(rawdatafile,'r','b');						% Open the file in the proper mode
                        if FID == -1, error('ERROR: Could not locate external data file'); end		% Oops file is not there
                        A = fread(FID,numcol*numrow,'double');						% Read the data from the file
                        fclose(FID);									% Done :)
                    else
                        A = sciReadDouble(SCIFILE,numcol*numrow);					% Just doing it the old way
                    end        
                else
                    A = sciReadDouble(SCIFILE,numcol*numrow);
                end    
            sciReadEndDelim(SCIFILE);    
        
            A = reshape(A,numrow,numcol)'; %'
        
            % There is no point in continuing reading the file from this point
                    
            otherwise
                error('ERROR: The DenseMatrix is from another class than Matrix')
            end    
    
    
    otherwise
    
        error('ERROR: The matrix class in the file is not yet supported');
    
    end
                                    
        
    sciCloseFile(SCIFILE);
        
return
        
        
% SUB functions for reading the files

function SCIFILE = sciOpenFile(filename)

% This function opens a stream for reading the file
%
% There are various file formats supported by the SCIRun program:
% BIN : Binary file format
% ASC : Ascii file format
% GZP : Gzip file format (not supported)
% The file are written in IEEE floating point format with the LSB at the end
% Hence for the binary format the files are opened in the 'b' format

% The SCIFILE structure:
%   FID      - File identifier
%   METHOD   - 1 for binary and 2 for ascii
%   POINTER  - Counter for generating unique pointer numbers
%              For each pointer this number will be incremented

    SCIFILE.FID = fopen(filename,'r','b');
    SCIFILE.METHOD = 0;
    SCIFILE.POINTER = 0;

    if SCIFILE.FID == -1,
        error('ERROR: Could not open file');
    end    
return    


function sciCloseFile(SCIFILE)

% This function closes the SCIFILE

    fclose(SCIFILE.FID);
return 


function SCIFILE = sciReadHeader(SCIFILE)

% This function read the scirun header at the start of the file
% The header consists of the following blocks
% string 'SCI\n' indicates a SCIRun file
% string {'BIN\n','ASC\n','GZP\n'} identifying the format 
% string version specifying the version number (here I use 1 as it should be compatible with version 1)

    % Is the file a genuine SCIRun File ?

    identifier = char(fread(SCIFILE.FID,4,'int8'));
    if strncmp(identifier,'SCI',3) == 0,
        error('ERROR: The file is not a proper SCIRun file');
    end
    
    % What format is the file written in
    
    format = char(fread(SCIFILE.FID,4,'int8'))'; %'
    switch format(1:3),
    case 'BIN',
        SCIFILE.METHOD = 1;
    case 'ASC',
        SCIFILE.METHOD = 2;
    otherwise
        err = sprintf('ERROR: The file is written in unsupported file format called %s',format(1:3));
        error(err);
    end    

    if SCIFILE.METHOD == 1,
        version = fscanf(SCIFILE.FID,'%3d\n',1);
    else
        version = fscanf(SCIFILE.FID,'%d\n',1);
    end
    
    % One big drawback of the SCIRun file format is the inability to skip newer objects that live
    % in a new file structure as they can be of any size, making it impossible to cope with these
    % objects. Hence we have to be strict in checking the version numbers as newer versions probably
    % will contain new objects making it virtually impossible to locate the old structures in the 
    % file format. Hopefully version 2 of the SCIRun file format will have a guidance system with the
    % file formats so you can read specific data and do not depend on having all data on all classes.     
                
    if version > 1,
        error('ERROR: This function does not support a SCIRun file format larger than version 1')
    end    

    SCIFILE.VERSION = version;

return


function sciReadClassStart(SCIFILE)

% This is a simple method for checking file integrity
% Analogous to the SCIRun code, which will not except
% any addional spaces what so ever. So we follow this pattern

    if SCIFILE.METHOD == 2,
        c = fread(SCIFILE.FID,1,'int8');
        if c ~= char('{'),
            error('ERROR: Expected a "{" in the file');
        end
    end
return        
   
function sciReadStartDelim(SCIFILE)

% This is a simple method for checking file integrity
% Analogous to the SCIRun code, which will not except
% any addional spaces what so ever. So we follow this pattern

    if SCIFILE.METHOD == 2,
        c = fread(SCIFILE.FID,1,'int8');
        if c ~= char('{'),
            error('ERROR: Expected a "{" in the file');
        end
    end
return              
            
          
function sciReadEndClass(SCIFILE)

    if SCIFILE.METHOD == 2,
        c = fread(SCIFILE.FID,1,'int8');
        if c(1) ~= char('}'),
            result = findEndDelim(SCIFILE.FID);									% Try to scan for the end
            if result == 0,  
                error('ERROR: Expected a "}" in the file'); 
            end
         end
        c = fread(SCIFILE.FID,1,'int8');									% Read the end of line
    end
return            
    
function sciReadEndDelim(SCIFILE)

    if SCIFILE.METHOD == 2,
        c = fread(SCIFILE.FID,1,'int8');
        if c(1) ~= char('}'),
            result = findEndDelim(SCIFILE.FID);									% Try to scan for the end
            if result == 0,  
                error('ERROR: Expected a "}" in the file'); 
            end
         end
    end
return  
                
        
function [number,hasdata] = sciReadPointer(SCIFILE)

    if SCIFILE.METHOD == 1,
        number  = fread(SCIFILE.FID,1,'int32');
        hasdata = fread(SCIFILE.FID,1,'int32');
    else
        c = fread(SCIFILE.FID,1,'int8');
        hasdata = 0;
        if c == '@', hasdata = 1; end
        number = fscanf(SCIFILE.FID,'%d ',1);
    end
return        


function [class,version] = sciReadClass(SCIFILE)

    if SCIFILE.METHOD == 1,
        class = xdrstring(SCIFILE.FID);
        version = fread(SCIFILE.FID,1,'int32');
    else
        class = fscanf(SCIFILE.FID,'{%s ',1);
        version = fscanf(SCIFILE.FID,'%d ',1);
    end
return


function data = sciReadInt(SCIFILE,num)

    if nargin == 1,
        num = 1;
    end    

    if SCIFILE.METHOD == 1,
        data = fread(SCIFILE.FID,num,'int32');
    else
        data = fscanf(SCIFILE.FID,'%d ',num);
    end
return        

function data = sciReadDouble(SCIFILE,num)

    if nargin == 1,
        num = 1;
    end    

    if SCIFILE.METHOD == 1,
        data = fread(SCIFILE.FID,num,'double');
    else
        data = fscanf(SCIFILE.FID,'%f ',num);
    end
return        

function string = sciReadString(SCIFILE)

    if SCIFILE.METHOD == 1,
        string = xdrstring(SCIFILE.FID);
    else
        string = '';
        c = char(fread(SCIFILE.FID,1,'int8'));
        if c ~= char('"'), error('ERROR: a string should start with a ["]'); end    
        
        c = char(fread(SCIFILE.FID,1,'int8'));
        while c ~= char('"'), 
            string = [string c]; 
            c = char(fread(SCIFILE.FID,1,'int8'));
        end
        fread(SCIFILE.FID,1,'int8');			% read the trailing space
    end
return            

function result = findEndDelim(FID)

% In case of an ASCII file we can count the number of open and closing brackets
% to skip an unknown object. Doing this byte by byte will be very slow in matlab
% Hence in this function a buffer is used to load data and process it by counting
% the bracket in the buffer, if the closing one is not found another buffer will be
% read until the end of the file or a corresponding closing bracket is found.

% TODO Add string support theoretically we should ignore all brackets in a string "..."
%      This case is assumed not to be very common hence it is ignored for the moment

    buflen = 200;

    buffer = [];
    bufmark = [];
    
    count = buflen;
    
    numopen = 1;
    done = 0;
    
    while (count == buflen)&(done == 0),
        [buffer,count] = fread(FID,buflen,'int8');
        buffer = char(buffer)'; %'
        bufmark = zeros(size(buffer));
        bufmark(findstr(buffer,'{')) = 1;
        bufmark(findstr(buffer,'}')) = -1;
        bufmark(1) = bufmark(1) + numopen;
        bufmark = cumsum(bufmark);
        index = find(bufmark == 0);
        if ~isempty(index),
            done = 1;
            fseek(FID,index(1)-count,0);
         end
         numopen = bufmark(end);
    end
    
    result = done;
    
return                    

        
function string = xdrstring(FID)

    strlen = fread(FID,1,'int32');
    append = mod(4-mod(strlen,4),4);
    tlen = strlen+append;
    if tlen > 0,
        string = fread(FID,tlen,'int8')';   %'      
        string = char(string(1:strlen));
    else
        string = '';
    end    
    
return    
        
