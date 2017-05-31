function f = DsFca(g, nhood, niterations)
%Despeckle Filtering Toolbox 2008
%Non-LINEAR  FILTER: Linear Scaling Filtering 
%Christos Loizou 2008
%Ultrasound Image-filtering of noise through linear skaling of the pixel Intensities 
%Source: Digitle Bildverarbeitung, Chapter 7, MOdifikation der Grauwerte
% Examble: f = DsFls(g, [5 5], 2);

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
[ma ,na] = size(g);
%Estimate the midle of the processing window
z=(nhood(1)-1)/2;

%Calculate the noise and the noise variance in the image 
stdnoise=(std2(g).*std2(g))/mean2(g);

%Initialize the picture f (new picture) with zeros
f=g;

for i = 1:niterations
  fprintf('\rIteration %d',i);
  if i >=2 
      g=f;
  end

%Estimate the maximmum intensity in every pixel neighborhood of  g.
handle=waitbar(0, 'Calculating the MAX/MIN Intensities in every neighborhood...');
%ma=100; na=100; 
ini=z+1;
for i= ini :(ma-z)
   for j= ini:(na-z)
      maxi=0.0;
      mini=1.0;
      for a= (i-z):(i+z)	
         for b=(j-z):(j+z)
            if (g(a, b))> maxi 
               maxi=g(a, b);
            end   % end if maxi
            
            if (g(a, b)) < mini
               mini= g(a, b);
            end	% end if mini
            
         end	%end for b
      end		%end for a
      
     
% The new pixel intensities		
      f(i, j) =  abs( (maxi+ mini)/2);  
   end	% end for j
      waitbar(i/na)
end		% end for i

close(handle)

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

