function Lintnew = triLaplacianInterpolation(varargin)
% FUNCTION Lint = triLaplacianInterpolation(surface,badleads,[numleads])
%
% DESCRIPTION
% This function computes a transfer matrix from the full potential vector
% with the potentials of the badleads to a full vector in which the
% bad leads have been interpolated using the known data. THhe function 
% uses the laplacian interpolation scheme (Oostendorp 1989, J Computational 
% Physics 80,331-343).
%
%  Utot_int = Lint*Utot_old
%
% INPUT
% surface     A surface description with fields .pts/.channels and .fac
% badleads    The leads you want to interpolate
% numleads    Number of leads, As the total number of leads is not
%             available from the channels file this separate entry
%             will define the dimensions of Lint. If you do not use
%             .chaannel files the function won't need this input
%
% OUTPUT
% Lint        The interpolation matrix
%
% SEE ALSO triSurfaceLaplacian

geomfiles = {};
surface = [];
numleads = 0;
nchannels = [];
readchannels = 0;

    for p = 1:nargin,
        if ischar(varargin{p}),
            geomfiles{end+1} = varargin{p};
        end
        if isstruct(varargin{p}),
            surface = varargin{p};
            if ~isfield(surface,'fac') | ~isfield(surface,'pts'),
                msgError('Surface needs to have fields .pts and .fac',5);
                return    
            end
        end
        if ~isstruct(varargin{p}) & ~ischar(varargin{p}),
            if readchannels == 0,
                nchannels = unique(varargin{p});
                readchannels = 1;
            else
                numleads = varargin{p};
                numleads = numleads(1); 
            end
                
        end
    end
                        
    if isempty(surface),
        if isempty(geomfiles),
            msgError('No Surface specified',5);
            return;
        else
            surface = ioReadGEOMdata(geomfiles{:});
            surface = surface{1};
        end
        
        if ~isfield(surface,'pts') & ~isfield(surface,'fac'),
            msgError('The surface needs to have fields .pts and .fac',5);
            return
        end    
    end
    
    if numleads == 0,
        numleads = size(surface.pts,2);
    end
    
    % NEED TO SOLVE HOW TO KNOW HOW MANY CHANNELS ARE INVOLVED
    
    if isfield(surface,'channels')
        if ~isempty(surface.channels),
            geomtrans = zeros(1,numleads);
            geomtrans(surface.channels) = 1:length(surface.channels);
            geomnchannels = geomtrans(nchannels(find(geomtrans(nchannels))));
            mychannels = surface.channels;
        else
            geomnchannels = nchannels;   
            mychannels = [1:numleads];
        end   
    else
        geomnchannels = nchannels;   
        mychannels = [1:numleads];
    end
        
    L = triSurfaceLaplacian(surface);

 
    I = zeros(1,size(L,2));
    I(geomnchannels) = 1;
    geomchannels = find(I == 0);
    
    L1 = L(:,geomnchannels);
    L2 = L(:,geomchannels);

    Lint = zeros(length(geomchannels)+length(geomnchannels),length(geomchannels)+length(geomnchannels));
    Lint(geomchannels,geomchannels) = eye(length(geomchannels));
    Lint(geomnchannels,geomchannels) = -inv(L1'*L1)*L1'*L2;
    
    Lintnew = eye(numleads);
    Lintnew(mychannels,mychannels) = Lint;
    
return
    
  