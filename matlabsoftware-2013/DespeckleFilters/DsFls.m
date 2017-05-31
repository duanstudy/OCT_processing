function f = DsFls(g, nhood, niterations)
%Despeckle Filtering Toolbox 2008
%Christos Loizou 2007. ls
%A filter that filters multiplikative noise. %Filters the multiplicative noise in 
%Ultrasound Images. %Utilizes the local statistics of the noise image g(m,n )
%g(m,n) = (max + min) /2; in the window
%Example: f = DsFls(a, [5 5], 3);

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

for i = 1:niterations
  fprintf('\rIteration %d',i);
  if i >=2 
      g=f;
  end

% Estimate the local maximum for every neighborhood 
fhelp =inline('max(x(:))'); 
localMax = nlfilter(g, nhood, fhelp);

% Estimate the local minimu for every neighborhood 
yhelp=inline('min(x(:))'); 
localMin = nlfilter(g, nhood, yhelp);
f = (localMax + localMin )./2;

end
fprintf('\n');

if u8out==1,
  if (logicalOut)
    f = uint8(f);
  else
    f = uint8(round(f*255));
  end
end

figure, subplot(2,1,1),  imshow(g), title('Original Image');
subplot(2,1,2), imshow(f), title('Despeckled Image by DsFls'); 

