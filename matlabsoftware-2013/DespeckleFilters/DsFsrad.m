function [I,rect] = DsFsrad(I,niter,lambda,rect)
%**************************************************************************
%Despeckle Filtering Toolbox 2008
%Christos Loizou 2007   
%Speckle filtering using SRAD, Speckle ReducingAnisotropic Diffusion 
%  INPUTS
%  I = original image
%  niter = number of iteration to perform the smoothing
%  lambda = time step
%  NOT REQUIRED
%  Ex. [I,rect] = DsFsrad(a(:,:,1),75,0.025);
%  OUTPUTS
%  I = new smoothed image
%  rect = ROI rect
%   Ex2: 
% Estimate the size of the image, by > size (a), and use the following function 
% [I,rect] = DsFsrad(a(:,:,1),75,0.025, [0 0 436 182]);
% to despeckle the image without choosing a rectangle
%**************************************************************************
orig_img=I; 
% transform image to double and normalize it 
I = double(I);
mx = max(I(:));
mn = min(I(:));
I = (I-mn)/(mx-mn);
% indices (using boudary conditions)
[M,N] = size(I);
iN = [1, 1:M-1];
iS = [2:M, M];
jW = [1, 1:N-1];
jE = [2:N, N];

% get an area of uniform speckle
if nargin < 4 || isempty(rect)
    imshow(I,[],'notruesize');
    rect = getrect;
end

%log uncompress and eliminate zero value pixels.
I = exp(I);

% wait bar
hwait = waitbar(0,'Diffusing Image');

% main algorithm
for iter = 1:niter

    % speckle scale function
    Iuniform = imcrop(I,rect);
    q0_squared = (std(Iuniform(:))/mean(Iuniform(:)))^2;

    % differences
    dN = I(iN,:) - I;
    dS = I(iS,:) - I;
    dW = I(:,jW) - I;
    dE = I(:,jE) - I;

    % normalized discrete gradient magnitude squared
    G2 = (dN.^2 + dS.^2 + dW.^2 + dE.^2) ./ (I.^2 + eps);

    %normalized discrete laplacian 
    L = (dN + dS + dW + dE) ./ (I + eps);

    % ICOV (equ 31/35)
    num = (.5*G2) - ((1/16)*(L.^2));
    den = (1 + ((1/4)*L)).^2;
    q_squared = num ./ (den + eps);

    % diffusion coefficent
    den = (q_squared - q0_squared) ./ (q0_squared *(1 + q0_squared) + eps);
    c = 1 ./ (1 + den);
    cS = c(iS, :);
    cE = c(:,jE);

    % divergence
    D = (cS.*dS) + (c.*dN) + (cE.*dE) + (c.*dW);

    % update 
    I = I + (lambda/4)*D;

    % update waitbar
    waitbar(iter/niter,hwait);

end

I = log(I);

figure, subplot(2,1,1),  imshow(orig_img), title('Original Image');
subplot(2,1,2), imshow(I), title('Despeckled Image by DsFsrad'); 
%figure, imshow(I);
% close wait bar
close(hwait)

return

