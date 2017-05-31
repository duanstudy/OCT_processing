function f = DsFlecasort(g, nhood, niterations)
%***************************************************************************************
%Despeckle Filtering Toolbox 2008
%NeigborHood  Averaging FILTER. 
%Christos Loizou 2008. DsFlecasort
%Ultrasound Image-filtering of noise through linear skaling of the pixel Intensities
%Reduces speckle in Medical Ultrasound images through linear skalation
%Take k points of a pixel array which are closest to the gray level of the image 
%at point P (middle point in window) including P itself. Assign the value of this points 
%to the pixel P. (Usually N=9 3x3 window , k=6). After 3 itterations is very powerfull.
%Examble: f = DsFlecasort(a, [5 5], 3);
%****************************************************************************************

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
noise=noisevar(z, nhood, ma, na, g);
stdnoise=(noise*noise); % This is the standard deviation of the noise
initimage=g; 
%Initialize the picture f (new picture) with zeros
f=g;
for i = 1:niterations
  fprintf('\rIteration %d',i);
  if i >=2 
      g=f;
  end

%Estimate the maximmum intensity in every pixel neighborhood of  g.
handle=waitbar(0, 'Sorting And Averaging Values in neighborhood...');
%ma=100; na=100; 
ini=z+1;
for i= ini :(ma-z)
   for j= ini:(na-z)
      index=1;
      for a= (i-z):(i+z)	
         for b=(j-z):(j+z)
            buff(index) = g(a, b);
            index = index+1;
         end	%end for b
      end		%end for a
      xsort=sort(buff);		% sort all the value in the mask (window)
      w=nhood(1); u= nhood(1)*nhood(1) - nhood(1);
      xmit=0.0;
      for a= w:u
          xmit = xmit + xsort(a);
      end		%end for a
      xmit = xmit / ((nhood(1)- 1) * (nhood(1)-1 ));      
      
% The new pixel intensities		
      f(i, j) =  xmit;
      
   end	% end for j
      waitbar(i/na)
end		% end for i

close(handle)

end
fprintf('\n');

%statistics(g, f, ma, na);


if u8out==1,
  if (logicalOut)
    f = uint8(f);
  else
    f = uint8(round(f*255));
  end
else
    f=f/255;
end

figure, subplot(2,1,1),  imshow(initimage), title('Original Image');
subplot(2,1,2), imshow(f), title('Despeckled Image by DsFlecasort'); 
