function h=DsTfdta2(x,s);
%function h=fdta2(x,s);
%Fractal Dimension Texture Analysis
%Christodoulos Christodoulou

[r,c]=size(x);
h(s+1)=0;
ms=3;
i=1;
y=DsTintens2(x,ms);
h(i)=DsTleast(y,ms);
%m=log10(r)/log10(2);
mr=log2(r);
mc=log2(c);

while(i<=s)
  i=i+1;
  mr=mr-1;
  mc=mc-1;
  x=DsTresol2(x,mr,mc);
  y=DsTintens2(x,ms);
  h(i)=DsTleast(y,ms);
end;
