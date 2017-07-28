function typenum = fidsType(typestr)
% FUNCTION fidtype = fidsType(typestr)
% OR       typestr  = fidsType(fidtype)
%
% DESCRIPTION
%  this function translates the string describing the type of a fiducial in its
%  corresponding number (or vice versa). In the TSDFC file format fiducials are 
%  stored with a type the type is a number which corresponds to a certain time interval. 
%  In order to ease the matlab programming, they are define as strings as well. So 
%  entering a string will lead to an automatic translation. The translation of each string
%  is accomplished by means of this function.
%
% INPUT
%  typestr		A string describing the type, see TYPES
%
% OUTPUT
%  fidtype		The corresponding number to the fiducial description
%                       or -1 if the string could not be identified 
%
% TYPES
%  The fids descriptions should match one of the following strings (case insensitive)
%  pon,pstart,
%  pend,poff, 
%  qon,qrson,qrsstart,
%  rpeak,qrspeak,
%  soff,qrsend,qrsoff,
%  stoff,tstart,ton,
%  tpeak,
%  toff,tend,
%  act, actplus, actminus,
%  rec, recplus, recminus,
%  ref,reference,
%  jpt,
%  baseline	
%  pacing
%
%  The list may not be complete, so all additions are welcome
%
% SEE ALSO

typenum = -1; % default error

if ischar(typestr)
    switch lower(typestr),
    case {'pon','pstart'}
        typenum = 0;
    case {'poff','pend'}
        typenum = 1;
    case {'qon','qrsstart','qrson'}
        typenum = 2;
    case {'rpeak','qrspeak'}
        typenum = 3;
    case {'soff','qrsend','qrsoff'}
        typenum = 4;
    case {'stoff','tstart','ton'}
        typenum = 5;
    case {'tpeak'}
        typenum = 6;
    case {'toff','tend'}
        typenum = 7;
    case {'actplus'}
        typenum = 8;
    case {'actminus'}
        typenum = 9;
    case {'act'},
        typenum = 10;
    case {'recplus'},
        typenum = 11;
    case {'recminus'}
        typenum = 12;
    case {'rec'}
        typenum = 13;
    case {'ref','reference'}
        typenum = 14;
    case {'jpt','jpoint'}
        typenum = 15;    
    case {'baseline'}
        typenum = 16;
    %% NEWLY DEFINED FIDUCIALS
    %% MY NEWLY DEFINED FIDUCIAL TYPES START
    %% AT 30
    case {'pacing'}
        typenum = 30;
        
    end
end

if  isnumeric(typestr)
    switch typestr,
        case 0,
            typenum = 'pon';
        case 1,
            typenum = 'poff';
        case 2,
            typenum = 'qrson';
        case 3,
            typenum = 'rpeak';
        case 4,
            typenum = 'qrsoff';
        case 5,
            typenum = 'ton';
        case 6,
            typenum = 'tpeak';
        case 7,
            typenum = 'toff';
        case 8,
            typenum = 'actplus';
        case 9,
            typenum = 'actminus';
        case 10,
            typenum = 'act';
        case 11,
            typenum = 'recplus';
        case 12,
            typenum = 'recminus';
        case 13,
            typenum = 'rec';
        case 14,
            typenum = 'reference';
        case 15,
            typenum = 'jpt';
        case 16,
            typenum = 'baseline';
        case 30,
            typenum = 'pacing';
        otherwise
            fprintf(1,'Fiducial type unknown\n');
            typenum = NaN;
    end
end


return         