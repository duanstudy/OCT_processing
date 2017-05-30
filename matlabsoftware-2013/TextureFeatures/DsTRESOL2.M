function res=DsTresol2(x,mr,mc);
%function res=resol2(x,mr,mc);
%Multiple resolution feature exctraction

[r,c]=size(x);
%res(r,c)=0
res=[];

nr=(2^mr)-1;
nc=(2^mc)-1;

for i=1:nr;
  for j=1:nc;
    res(i,j)=(x((2*i),(2*j))+x((2*i+1),(2*j))+x((2*i),(2*j+1))+x((2*i+1),(2*j+1)))/4;
  end
end