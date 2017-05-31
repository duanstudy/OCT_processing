function [f,noise] = DsFwiener2(varargin)
%Despeckle Filtering Toolbox 2008
%Christos Loizou 2007
%  Linear Filtering: First Order Statistics Filtering
%   J = WIENER2(I,[M N],NOISE) filters the image I using pixel-wise adaptive
%   Wiener filtering, using neighborhoods of size M-by-N to estimate the local
%   image mean and standard deviation. If you omit the [M N] argument, M and N
%   default to 3. The additive noise (Gaussian white noise) power is assumed
%   to be NOISE.
%   [J,NOISE] = WIENER2(I,[M N]) also estimates the additive noise power
%   before doing the filtering. WIENER2 returns this estimate as NOISE.
%
%  Example
%   -------
%       a = imread('image.tif');
%       K = DsFwiener2(double(a),[5 5]);
%       figure, imshow(a), figure, imshow(K)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[g, nhood, noise] = ParseInputs(varargin{:});
initial=g; 
classin = class(g);
classChanged = false;
if ~isa(g, 'double')
  classChanged = true;
  g = im2double(g);
end

% Estimate the local mean of f.
localMean = filter2(ones(nhood), g) / prod(nhood);

% Estimate of the local variance of f.
localVar = filter2(ones(nhood), g.^2) / prod(nhood) - localMean.^2;

% Estimate the noise power if necessary.
if (isempty(noise))
  noise = mean2(localVar);
end

% Compute result
% f = localMean + (max(0, localVar - noise) ./ ...
%           max(localVar, noise)) .* (g - localMean);
%
% Computation is split up to minimize use of memory
% for temp arrays.
f = g - localMean;
g = localVar - noise; 
g = max(g, 0);
localVar = max(localVar, noise);
f = f ./ localVar;
f = f .* g;
f = f + localMean;

if classChanged
  f = changeclass(classin, f);
end

figure, subplot(2,1,1),  imshow(initial./255), title('Original Image');
subplot(2,1,2), imshow(f./255), title('Despeckled Image by DsFwiener'); 
%%%
%%% Subfunction ParseInputs
%%%
function [g, nhood, noise] = ParseInputs(varargin)

g = [];
nhood = [3 3];
noise = [];

wid = sprintf('Images:%s:obsoleteSyntax',mfilename);            

switch nargin
case 0
    msg = 'Too few input arguments.';
    eid = sprintf('Images:%s:tooFewInputs',mfilename);            
    error(eid,'%s',msg);
    
case 1
    % wiener2(I)
    
    g = varargin{1};
    
case 2
    g = varargin{1};

    switch numel(varargin{2})
    case 1
        % wiener2(I,noise)
        
        noise = varargin{2};
        
    case 2
        % wiener2(I,[m n])

        nhood = varargin{2};
        
    otherwise
        msg = 'Invalid input syntax';
        eid = sprintf('Images:%s:invalidSyntax',mfilename);            
        error(eid,'%s',msg);
    end
    
case 3
    g = varargin{1};
        
    if (numel(varargin{3}) == 2)
        % wiener2(I,[m n],[mblock nblock])  OBSOLETE
        warning(wid,'%s %s',...
                'WIENER2(I,[m n],[mblock nblock]) is an obsolete syntax.',...
                'Omit the block size, the image matrix is processed all at once.');

        nhood = varargin{2};
    else
        % wiener2(I,[m n],noise)
        nhood = varargin{2};
        noise = varargin{3};
    end
    
case 4
    % wiener2(I,[m n],[mblock nblock],noise)  OBSOLETE
    warning(wid,'%s %s',...
            'WIENER2(I,[m n],[mblock nblock],noise) is an obsolete syntax.',...
            'Omit the block size, the image matrix is processed all at once.');
    g = varargin{1};
    nhood = varargin{2};
    noise = varargin{4};
    
otherwise
    msg = 'Too many input arguments.';
    eid = sprintf('Images:%s:tooManyInputs',mfilename);            
    error(eid,'%s',msg);

end

% checking if input image is a truecolor image-not supported by WIENER2
if (ndims(g) == 3)
    msg = 'WIENER2 does not support 3D truecolor images as an input.';
    eid = sprintf('Images:%s:wiener2DoesNotSupport3D',mfilename);            
    error(eid,'%s',msg); 
end


