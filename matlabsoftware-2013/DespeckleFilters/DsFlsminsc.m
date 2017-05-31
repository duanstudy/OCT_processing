function f = DsFlsminsc(g, nhood, niterations, edge)
%****************************************************************************
%Despeckle Filtering Toolbox 2008
%Linear Filtering: Homogeneous Area Filtering  
%SPECKLE REDUCTION  FILTER. (c) Christos P. Loizou 2007. lsminsc
%Ultrasound Image-Multiplicative Noise Filtering 
%Source: Computer Graphics and Image Processing 9, p. 394-407, 1979
%Title: Edge Preserving smoothing
%Filters  multiplicative noise in Ultrasound Images
%Utilizes the local statistics of the noise image g(m,n)
%The filter  utilizes different filter detectors, from which you may
%choose one according to your application.
%Choose an edge detector to be used for edge detection
%Input variables 
%g:             image  to be filtered, i.e. 'cell.tif'
% nhood :       sliding moving window, i.e [5 5]
%niterations:   itteration for which filter is applied itteratively
%edge       :   edge detector to be used for findiong the most homogeneous
%               areas within the sliding window 
%           : edge=0, use the variance as an edge detector 
%           : edge=1, use the speckle contast as an edge detector 
%           : edge=2, use max|m1-m2| input 2, max|m1/m2, m2/m1|'as an edge detector 
%           : edge=3, use the third moment as an edge detector 
%           : edge=4, use the fourth moment as an edge detector 

disp('Input the edge detector you would like to be used for the filter..');
disp('Input 0 for using the variance as a detector');
disp('Speckle Contrast input 1, max|m1-m2| input 2, max|m1/m2, m2/m1|');
disp('Moment 3rd grades 3, Moment 4rth grades 4');
%edge = input('Input the edge selector:     ')
%disp(['edge =', edge]);
%Example: f = DsFlsminsc(a, [5 5], 2, 0)
%*****************************************************************************

if isa(g, 'uint8')
  u8out = 1;
  if (islogical(g))
    % It doesn't make much sense to pass a binary image
    % in to this function, but just in case.
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
%Estimate the midle of the processing window, which takes onle values 3, 5 7,. . 
z=(nhood(1)-1)/2;
input=g; 

%Initialize the picture f (new picture) with zeros
f=g;

  for i = 1:niterations
  fprintf('\rIteration %d',i);
  if i >=2 
      g=f;
  end

%Estimate and change the middle pixel in window
handle=waitbar(0, 'Calculating/replacing the center pixel in a sliding window...');
%ma=100; na=100; 
ini=z+1;
for i= ini :(ma-z)
   for j= ini:(na-z)
      var_neu=1000000000.0;si_neu=10000000000.0; xmit1=0.0; cd_neu=10000000.0;
      hos_neu = 1000000000.0; hos4_neu = 100000000.0;
      for a= (i-z):i	
         for b=(j-z):j
            xmit= 0.0;
            for l=a:(a+z)
               for p=b:(b+z)
                  xmit=xmit + g(l, p);
               end % end for p
            end  %end for l
            xmit = (1.0/9.0) *xmit;
            var=0.0; pk=0.0; pk4=0.0;
            for l=a:(a+z)
               for p=b:(b+z)
                  var= var + ((g(l,p)-xmit)*(g(l, p)-xmit) );
                  pk= pk + ((g(l,p)-xmit)*(g(l, p)-xmit) * (g(l, p)-xmit) );%3rd moment
                  pk4=pk4 +(g(l,p)-xmit)*(g(l, p)-xmit)*(g(l, p)-xmit)*(g(l,p)-xmit);
               end % end for p
            end  %end for l
            var = (1/9.0)* var;			%variance in subwindow
            pk = (1/9.0)*pk;				%3rd moment in window
            if xmit ~=0.0
               si = sqrt(var)/xmit;			%speckle index in subwindow
            else 
               si=0.0;
            end
            cd = abs(xmit-xmit1); 	%gradient information of the subset
            xmit1 = xmit;
            if xmit~=0.0
               hos = power(pk, 0.5) /xmit;					%3rd higher order statistics
               hos4 = power (pk4, 0.25)/xmit; 				%4rth higher order statistics
            else
               hos=0.0;
               hos4=0.0;
            end
            
            if edge == 1			%Use the speckle contrast to calculate f(i, j)
            	if si < si_neu
               	si_neu = si;
               	f(i, j) = xmit;
               end					%end if speckle index
            elseif edge == 0		%Use the variance to calculate f(i, j)
            	if var <var_neu
               	var_neu = var;
               	f(i, j) = xmit;
               end					% end if var
            elseif edge == 2
               if cd < cd_neu
                  cd_neu =cd;		%use the local gradient to calculate f(i, j)
                  f(i, j)= xmit;
               end					%end if local gradient
            elseif edge == 3
               if hos < hos_neu
                  hos_neu = hos;	%use higher moments to calculate f(i, j)
                  f(i, j) = xmit;
               end					% end if higher order statistics 3rd grades
            elseif edge == 4
               if hos4 < hos4_neu
                  hos4_neu = hos4;	%use higher moments to 4rth grades to calculate f(i, j)
                  f(i, j) = xmit;
               end					% end if higher order statistics 4rth grades            
            end						% end if edge        
            
         end	%end for b
      end		%end for a
   end 		%end for n
        waitbar(i/na)
end 		% end for m

close(handle)
end         %end for itterations
fprintf('\n');

%statistics(g, f, ma, na);


if u8out==1,
  if (logicalOut)
    f = uint8(f);
  else
    f = uint8(round(f*255));
  end
end



figure, subplot(2,1,1),  imshow(input), title('Original Image');
subplot(2,1,2), imshow(f), title('Despeckled Image by DsFlsminsc'); 
