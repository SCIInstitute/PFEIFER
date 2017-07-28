function result = scirunWriteMatrix(filename,A,varargin)

% FUNCTION result = scirunWriteMatrix(filename,matrix,[option,...])
%
% DESCRIPTION
% This function writes a file in the SCIRun matrix file format. It converts
% the matlab matrix A into a file SCIRun can read. At the moment you need to
% add the file extension. Both SCIRun and Matlab use the same extension (but
% different file format) for saving a matrix. So the choice of extension name
% is left to the user as SCIRun will read a file with any extension as long as 
% it recognises its own file format.
% 
% VERSION 0.1 
%
% INPUT
% filename         Filename of the SCIRun matrix file (including extension)
% matrix           The matrix that is to be exported to SCIRun
%                  The matrix can be either dense or sparse
% option           Here is a list of options and their meaning
%                  'BIN'    write a binary file
%                  'ASC'    write an ascii file
%                  'dense'  write in the dense matrix format
%                  'sparse' write in the sparse matrix format      
%                  'split'  split file into a header and raw file (only for dense matrices)   
%
% OUTPUT
% result           Result is 1 if the file is written successfully (0 otherwise) 
%
% DEFAULT
% As a default the function uses the format of the matrix, if the matrix is sparse
% a sparse matrix is written and vice versa. The default file format is binary using
% doubles for writing the data
%
% EXAMPLES
%
% This example generates a random matrix and writes a dense scirun matrix
% in binary format.
%
% >> A = rand(5);                                     % Generate a random matrix of 5 by 5
% >> scirunWriteMatrix('mymatrix.mat',A,'sparse','BIN');    % Write a sparse matrix
%
% SEE ALSO scirunReadMatrix


%  scirunWriteMatrix.m : writing persistent matrix objects from matlab
%
%  Version 0.1 for SCIRun 1.4.2 and higher
% 
%  Written by:
%   dr. Jeroen G. Stinstra
%   Aug 6 2002
%   CardioVascular Research and Training Institute
%   University of Utah



    % set defaults

    format = 'BIN';
    method = 'dense';
    split = 0;
    
    if issparse(A), method = 'sparse'; end
    
    if ~ischar(filename),
        error('ERROR: The filename must be a string');
    end
    
    if ~isnumeric(A),
        error('ERROR: matrix needs to be a numeric matrix');
    end
    
    if ndims(A) > 2,
        error('ERROR: Only two dimensional matrices are supported');
    end    
 
     % read options from input
       
    if nargin > 2,
        for p=1:length(varargin),
            if ~ischar(varargin{p}),
                error('ERROR: the options must be specified as strings');
            end
            switch lower(varargin{p})
            case 'dense', 
                    method = 'dense';
            case 'sparse',
                    method = 'sparse';
            case 'bin',
                    format = 'BIN';
            case 'asc',
                    format = 'ASC';
            case 'split'
                    split = 1;
            otherwise
                    error('ERROR: You specified an unknown option');
            end
        end
    end         

    switch method
    case 'dense'
    
        % Write a dense matrix to file
        
        sciWriteDenseMatrix(filename,A',format,split); %'
    
        result = 1;
    
    case 'sparse'
    
        % In order to avoid copying A again, the conversion to a scirun sparse matrix is done here
        
        % I have to convert the matlab sparse matrix to a scirun sparse matrix
        % A Scirun sparse matrix is defined as follows	
        %
        % - rows  -> number of entries per row; (cumulative sum)
        % - columns -> column number of each subsequent entry
        % - values -> same length as columns only now the value at each row
        %
    
        % Algorithm info
        % 1) Transpose matrix: this will cause matlab to sort the matrix elements in
        % the scirun order, first the first row elements then the second row and so on.
        % 2) Find the non-zero elements, this will generate three vector, the row, the
        % column and the value of each non-zero entry. They are sorted per column and then
        % by row (that is why first the matrix was transposed)
        % Subsequently the column numbers must be translated into C-matrix indices by subtracting one.
        % 3) Histogram of rows: A histogram of the rows is made to generate the information on how
        % many non-zero entries there are per row
        % The latter histogram starts at zero to compensate for the zero at the start of the data
        % strucure. When studying the scirun code it becomes obvious that the first number is ignored
        
        % By the way the algorithm also works for full matrices !
        
        % An effort has been made to use only build in functions to speed up the conversion process
        
        sizeA = [size(A)];
        [column,row,value] = find(A');  %'
        clear A;
        sizeA = [sizeA length(value)];
        column = column - 1;
        row = cumsum(histc(row,0:sizeA(1)));
    
        sciWriteSparseMatrix(filename,sizeA,row,column,value,format);

        result = 1;

    otherwise

        result = 0;
        
    end    


return


function sciWriteDenseMatrix(filename,A,format,split)

% This function writes a basic dense matrix to a SCIRun matrix file
% The function writes out a version 3 dense matrix, which is supported
% by at least version 1.4.2 and higher.
%

% Algorithm Info:
%
% The function first opens a data stream and writes a header stating that
% it is a SCIRun matrix file. 
% 
% Then it starts the master "class" in which a pointer is written which is
% supposed to point to the matrix structure. As there cannot not be a pointer
% in the file, a marker will be placed for the MatrixReader and this marker will
% be followed with the actual contents of the matrix class.
%
% Then a DenseMatrix class will be defined which enherites its properties from the
% Matrix class. There will be a field PropertyManager but it will not be used.
% At the moment I still have to find out how this PropertyManager works and whether
% I can make a matlab access for it
% 
% The dense matrix has four fields
% -> the number of rows
% -> the number of columns
% -> the name of a file that stores the array of data (is not used by the matlab code yet)
%      Hence the data is assumed to reside within the datafile itself
% -> an array of data
%
% The latter has to be placed between two delimeters to make the ascii code better
% readable
 
    if nargin == 2,
        format = 'BIN';
    end

    SCIFILE = sciOpenFile(filename,format);

    sciWriteHeader(SCIFILE,1);
    sciWriteStartClass(SCIFILE);
    
        SCIFILE = sciWritePointer(SCIFILE,1);
        sciWriteClass(SCIFILE,'DenseMatrix',3);
    
            sciWriteClass(SCIFILE,'Matrix',3);
                sciWriteClass(SCIFILE,'PropertyManager',1);
                    sciWriteInt(SCIFILE,0);
                sciWriteEndClass(SCIFILE);    
            sciWriteEndClass(SCIFILE);
            
            % Here the actual matrix data is written to file
            
            sciWriteInt(SCIFILE,[size(A,2) size(A,1)]);			% the size of the matrix
            sciWriteStartDelim(SCIFILE);
                if split == 1,
                    sciWriteInt(SCIFILE,1);			% Indicate that the next field is a filename
                    [fp,fn] = fileparts(filename);		% generate a raw filename
                    rawfilename = fullfile(fp,[fn '.raw']);
                    sciWriteString(SCIFILE,rawfilename); 	% Write the string in the next field
                    FID = fopen(rawfilename,'w','b');   	% Open the rawfile (with big endian options)
                    fwrite(FID,A(:),'double');         		% write all the doubles
                    fclose(FID); 				% and close this file again
                else
                    sciWriteInt(SCIFILE,0);			% No file splitting
                    sciWriteDouble(SCIFILE,A);			% the array of data being the matrix
                end    
            sciWriteEndDelim(SCIFILE);
            
            % The data has been written to file, so the file can be closed
            
        sciWriteEndClass(SCIFILE);
    sciWriteEndClass(SCIFILE);   
    sciCloseFile(SCIFILE);          

return



function sciWriteSparseMatrix(filename,sizeA,row,column,value,format)

% This function writes sparse matrices. As both SCIRun and matlab support sparse matrices,
% the most economic way of transfering for instance Finite Element Stiffness matrices is through
% sparse matrices.
%
% This function writes out a previously for SCIRun translated matrix to file
%
% The SparseRowMatrix class has the following fields
% -> The number of rows in the matrix
% -> The number of columns in the matrix
% -> The number of non-zero elements
% -> A vector describing where each row starts with its data
%  To be more specific: For each row a number is stored and it tells the program at which entry in the values
%  vector the data for that row is stored. As the data is sorted by row this index should be incremented by the
%  number of column values found in the row to get the index for the next row.
% -> A vector containing the column numbers for each element (length vector is the number of non-zeros)
% -> A vector containing the values for each element specified by the previous vector (also length vector is nnz)


    if nargin == 2,
        format = 'BIN';
    end

    SCIFILE = sciOpenFile(filename,format);

    sciWriteHeader(SCIFILE,1);
    sciWriteStartClass(SCIFILE);
        SCIFILE = sciWritePointer(SCIFILE,1);
        sciWriteClass(SCIFILE,'SparseRowMatrix',1);

            % Write the Matrix class stuff
        
            sciWriteClass(SCIFILE,'Matrix',3);
                sciWriteClass(SCIFILE,'PropertyManager',1);
                    sciWriteInt(SCIFILE,0);
                sciWriteEndClass(SCIFILE); 
            sciWriteEndClass(SCIFILE);
            
            % Here the actual output of data starts
            % First the dimensions of the data are stored 
            
            sciWriteInt(SCIFILE,sizeA([2 1]));
            
            % Now write three vectors
            
            % Write the row descriptor
            
            sciWriteStartDelim(SCIFILE);
                sciWriteDouble(SCIFILE,row);
            sciWriteEndDelim(SCIFILE);
            
            % Write the column descriptor
            
            sciWriteStartDelim(SCIFILE);
                sciWriteDouble(SCIFILE,column);
            sciWriteEndDelim(SCIFILE);
            
            % Write the values for the sparse matrix
            
            sciWriteStartDelim(SCIFILE);
                sciWriteDouble(SCIFILE,value);
            sciWriteEndDelim(SCIFILE);
                        
        sciWriteEndClass(SCIFILE);
    sciWriteEndClass(SCIFILE);         
    
    sciCloseFile(SCIFILE);      
return



% SUB functions for writing the files

function SCIFILE = sciOpenFile(filename,format)

% This function opens a stream for writing the file
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

    switch upper(format)
    case 'BIN'
        SCIFILE.FID = fopen(filename,'w','b');
        SCIFILE.METHOD = 1;
        SCIFILE.POINTER = 0;
    case 'ASC'
        SCIFILE.FID = fopen(filename,'w');
        SCIFILE.METHOD = 2;
        SCIFILE.POINTER = 0;
    otherwise
        error('ERROR: The requested fileformat has not been implemented');
    end    
return    

function sciCloseFile(SCIFILE)

% This function closes the SCIFILE

    fclose(SCIFILE.FID);
return    


function sciWriteHeader(SCIFILE,version)

% This function writes the scirun header at the start of the file
% The header consists of the following blocks
% string 'SCI\n' indicates a SCIRun file
% string {'BIN\n','ASC\n','GZP\n'} identifying the format 
% string version specifying the version number (here I use 1 as it should be compatible with version 1)

    if SCIFILE.METHOD == 1,
        fprintf(SCIFILE.FID,'SCI\nBIN\n%03d\n',version);
    else
        fprintf(SCIFILE.FID,'SCI\nASC\n%d\n',version);
    end 
return


% Now some functions follow to write out the data
%

function sciWriteStartClass(SCIFILE)

    if SCIFILE.METHOD == 2,
        fprintf(SCIFILE.FID,'{');
    end    
return

function sciWriteEndClass(SCIFILE)

    if SCIFILE.METHOD == 2,
        fprintf(SCIFILE.FID,'}\n');
    end    
return


function sciWriteClass(SCIFILE,classname,version)

    if SCIFILE.METHOD == 1,
        xdrstring(SCIFILE.FID,classname);
        fwrite(SCIFILE.FID,version,'int32');
    else
        fprintf(SCIFILE.FID,'{%s %d ',classname,round(version));
    end    
return

function [SCIFILE,number] = sciWritePointer(SCIFILE,hasdata,number)

    if nargin == 2,
        SCIFILE.POINTER = SCIFILE.POINTER + 1;
        number = SCIFILE.POINTER;
    end
    
    if SCIFILE.METHOD == 1,
        fwrite(SCIFILE.FID,hasdata,'int32');
        fwrite(SCIFILE.FID,number,'int32');
     else
        if hasdata,
            fprintf(SCIFILE.FID,'@%d ',number);
        else
            fprintf(SCIFILE.FID,'%%%d ',number);
        end
     end   
return    

function sciWriteStartDelim(SCIFILE)
    
    if SCIFILE.METHOD == 2,
        fprintf(SCIFILE.FID,'{');
    end
return

function sciWriteEndDelim(SCIFILE)

    if SCIFILE.METHOD == 2,
        fprintf(SCIFILE.FID,'}');
    end
return

function sciWriteInt(SCIFILE,Data)

    if SCIFILE.METHOD == 1,
        fwrite(SCIFILE.FID,Data(:),'int32');	% This function is already vectorised
    else
        fprintf(SCIFILE.FID,'%d ',round(Data(:)));     % This funtion is vectorised as well
    end
return

function sciWriteDouble(SCIFILE,Data)

    if SCIFILE.METHOD == 1,
        fwrite(SCIFILE.FID,Data(:),'double');	% This function is already vectorised
    else
        fprintf(SCIFILE.FID,'%d ',Data(:));     % This funtion is vectorised as well
    end
return



function sciWriteString(SCIFILE,string)

    if SCIFILE.METHOD  == 1,
        xdrstring(SCIFILE.FID,string);
    else
        if isempty(string),
            fprintf(SCIFILE.FID,'0 ');
        else    
            fprintf(SCIFILE.FID,'"%s" ',string);
        end    
    end
return        
        

function xdrstring(FID,string)

% SCIRun uses the XDR library to be compatible with different kind of unix
% systems and to avoid problems like byte swapping.
%
% Matlab support already a lot of this stuff just through fopen and specifying
% the byte order and the floating point format. Only for strings XDR uses a different
% system. Hence this function converts and writes a XDR string into the file. 
%
% Write an XDR formatted string: 4 bytes for the length and then the data
% aligned at the four 4 bytes boundary. Hence the zeros will be padded to
% align the string to a 4 bytes boundary. 

    len = length(string);
    fwrite(FID,len,'int32');
    if len > 0,
        append = mod(4-mod(len,4),4);
        string(end+append) = 0;
        fwrite(FID,string,'int8');
    end     
return
