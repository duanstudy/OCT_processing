%Despeckle Filtering Toolbox 2008
%Wavelet filtering 
%Christos Loizou 2007
%Example: outimage= DsFwaveltc (a, 4);

function xd= waveltc(g, nitterations);

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

for i = 1:nitterations
  fprintf('\rIteration %d',i);
  if i >=2 
      g=xd;
  end
  
    [thr, sorh, kepapp]=ddencmp('den', 'wv', g);
    %g= round(log(double(g)).*255);
    xd=wdencmp('gbl', g, 'sym4', 2, thr, sorh, kepapp); 

end 		% end for i itterations

figure, subplot(2,1,1),  imshow(g), title('Original Image');
subplot(2,1,2), imshow(xd), title('Despeckled Image by DsFwaveltc'); 
