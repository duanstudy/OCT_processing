function [fr,fa]=DsTfps(x);
%function [fr,fa]=fps(x);
%Fourier Power Spectrum, consider only ROI
%C.P. Loizou

[r,c]=size(x);
f1=zeros(size(x));

msk=(x<254);

l1=length(find(msk>0));

%Compute fft of each column
%Consider curves in ROI outline
for i=1:c
  sp=0;
  ep=0;
  j=1;
  while j < r;
    while msk(j,i)==1 & j < r;
      if sp==0; sp=j; end;
      j=j+1;
    end
    if sp>0 & ep==0; 
      if j<r; ep=j-1; 
        else; ep=j; end;        
      f1(sp:ep,i)=fft(x(sp:ep,i));
      sp=0;
      ep=0;
    end;
    while msk(j,i)==0 & j < r;
      j=j+1;
    end 
  end
end

f11=f1;

f1=f1.';
msk=msk';

%Compute fft of each row
%Consider curves in ROI outline
for i=1:r
  sp=0;
  ep=0;
  j=1;
  while j < c;
    while msk(j,i)==1 & j < c;
      if sp==0; sp=j; end;
      j=j+1;
    end
    if sp>0 & ep==0; 
      if j<r; ep=j-1; 
        else; ep=j; end;        
      f1(sp:ep,i)=fft(f1(sp:ep,i));
      sp=0;
      ep=0;
    end;
    while msk(j,i)==0 & j < c;
      j=j+1;
    end 
  end
end

f1=f1.';
msk=msk';

re=real(f1);
im=imag(f1);
re=re.*msk;
im=im.*msk;

%radial sum
fr=sqrt(sum(sum(re.^2)) / l1);
%angular sum
fa=sqrt(sum(sum(im.^2)) / l1);


