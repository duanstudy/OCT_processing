function y=DsTintens(x,s);
%function y=intens(x,s);
%Intensity difference vector with step s
%C.P. Loizou

n1=0;
n2=0;
cn1=0;
cn2=0;
[r,c]=size(x);

for k=1:s
  for r1=1:r
    for c1=1:c-k
      if x(r1,c1)<254 & x(r1,c1+k)<254;
        n1=n1+abs(x(r1,c1)-x(r1,c1+k));
        cn1=cn1+1;
      end
    end
  end
  for r2=1:r-k
    for c2=1:c
      if x(r2,c2)<254 & x(r2+k,c2)<254;
        n2=n2+abs(x(r2,c2)-x(r2+k,c2));
        cn2=cn2+1;
      end
    end
  end
  y(k)=(n1+n2)/(cn1+cn2);  
end