function f = DsFlsmv(g, nhood, niterations)
%(c) Christos Loizou 2007
% Linear Filtering: First Order Statistics Filtering
% Filters  multiplicative and additive noise in Ultrasound Images
%Utilizes the local statistics of the noise image g(m,n )
%f[m,n]=m+k*(g[m,n] - m), where k = (1-sqr(m)*(sqr(sr)/sqr(sx))/(1+sqr(sr))
%Example: outimage= DsFlsmv (a, [5 5], 4); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isa(g, 'uint8')
  u8out = 1;
  if (islogical(g))
    logicalOut = 1;
    g = double(g);
  else
    logicalOut = 0;  
    g = double(g)/255;    
  end
else
  u8out = 0;
end

%Estimate the size of the image
[ma, na]=size(g);
f=g;

for i = 1:niterations
  fprintf('\rIteration %d',i);
  %if niterations >=2 
   %   g=f;
  %end


% Estimate the local mean of f.
localMean = filter2(ones(nhood), g) / prod(nhood);

% Estimate of the local variance of f.
localVar = filter2(ones(nhood), g.^2) / prod(nhood) - localMean.^2;

% Estimate the noise power if necessary,
% and take into consideration the logarithmic compression 
stdnoise=(std2(g).*std2(g))/mean2(g);  
noisevar=stdnoise; %noise variance 

% Compute result
t=(localMean.*localMean).*noisevar;
k = localVar./ (t + localVar+0.0001); %coefficient of variation 
f = localMean + k .*(g-localMean);    % Outpout (Despeckled)image 

end
fprintf('\n');

if u8out==1,
  if (logicalOut)
    f = uint8(f);
  else
    f = uint8(round(f*255));
  end
end

% figure, subplot(2,1,1),  imshow(g), title('Original Image');
% subplot(2,1,2), imshow(f), title('Despeckled Image by DsFlsmv'); 