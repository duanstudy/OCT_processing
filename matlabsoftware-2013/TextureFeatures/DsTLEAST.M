function y=DsTleast(id,r);
%function y=least(id,r);
%Estimation of the curve slope using least squares 
%regression, in log-log scale
%C.P. Loizou

ym=0;
sm=0;
n1=0;
n2=0;

for i=1:r
  ym=ym+log10(id(i));
  sm=sm+log10(i);
end
ym=ym/r;
sm=sm/r;
for i=1:r
  n1=n1+(log10(i)-sm)*(log10(id(i))-ym);
  n2=n2+(log10(i)-sm)^2;
end
y=n1/n2;
