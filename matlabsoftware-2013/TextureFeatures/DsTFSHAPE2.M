function [feat]=DsTfshape(inname);
%function [feat]=fshape(inname);
%Shape features size (x, y), area, perimeter, perimeter^2 /area
%GIF file name should be given or image
%C.P. Loizou

if isstr(inname) 
 [img,map]=gifread(inname);
else;
 img=inname;
end

if max(max(img))==256;
  f=find(img==255 | img==254);
  img(f) = ones(length(f),1)*253;
  f=find(img==256);
  img(f) = ones(length(f),1)*255;
end;

[y,x]=size(img);
area=length(find(img<254));
%perim=length(find(img==255))
perim=sum(sum(bwperim(img<254,8)));

feat=[x,y,area,perim,perim^2/area];
