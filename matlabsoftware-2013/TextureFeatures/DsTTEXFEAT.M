function [feat]=DsTtexfeat(inname);
%function [feat]=DsTtexfeat(inname);
%C.P. Loizou-2008-Modified for MATLAB R12 
%61 different image features extraction
%inname = GIF file name should be given or image

if isstr(inname) 
   [img,map]=imread(inname,'gif');
   img=double(img)+1; % Imread range 0-255 / gifread 1-256
else;
   img=inname;
end

feat=[];

if max(max(img))==256;
   f=find(img==255 | img==254);
   img(f) = ones(length(f),1)*253;
   f=find(img==256);
   img(f) = ones(length(f),1)*255;
end;

x=img(find(img<254));
st=std(x);

%First Order Statistics (FOS) (features 1-5)
[mean,var,med,mode,skew,kurt,eng,ent]=DsTnwfos(img);
feat=[mean,med,st,skew,kurt];  			

%Haralick Spatial Gray Level Dependence Matrices (SGLDM) (6-31)
[mf,rf]=DsTnwsgldm(img,1);
feat=[feat, mf, rf];				

%Gray Level Difference Statistics (GLDS) (32-35)
[hom,con,eng,ent,mean]=DsTnwgldmc(img,1);  
feat=[feat, con,eng,ent,mean];

%Neighbourhood Gray Tone Difference Matrix (NGTDM) (36-40)
[coars,contr,busyn,compl,stren]=DsTnwngtdmn(img,1);
feat=[feat, coars,contr,busyn,compl,stren ];	

%Statistical Feature Matrix (SFM) (41-44)
[coars, cont, period, rough]=DsTnwsfm(img,4,4);
feat=[feat, coars, cont, period, rough];	

%Laws Texture Energy Measures (TEM) (45-50)
[LL,EE,SS,LE,ES,LS]=DsTnwlaws(img,7);
feat=[feat, LL,EE,SS,LE,ES,LS];			

% Fractal Dimension Texture Analysis (FDTA) (51-54)
h=DsTfdta2(img,3);					
feat=[feat, h];					

% Fourier Power Spectrum (FPS) (55-56)
[fr,fa]=DsTfps(img);
feat=[feat, fr,fa];				

% Shape (x, y, area, perim, perim^2/area) (57-61)
f=DsTfshape2(img);
feat=[feat, f];					

