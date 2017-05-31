function [mean,var,med,mode,skew,kurt,eng,ent]=DsTnwfos(imagein)
%
%  Function to implement first order statistics for texture analysis.
%
%  Input:
%    imagein - input image
%
%  Outputs:
%    mean - mean
%    var  - variance
%    med  - median
%    mode - mode
%    skew - skewness
%    kurt - kurtosis
%    eng  - energy
%    ent  - entropy
%
%  Any pixel of value greater than 253 in the input image 
%  is considered to be outside the region of interest, and is 
%  excluded from the feature computation.
%

greylevels=254;
[rowsize,colsize]=size(imagein);

%******************************************************************
%  compute probability distribution of grey levels
%******************************************************************

%  compute mask to select region of interest
%  mask=1 inside region, and 0 elsewhere

mask=sign(imagein-greylevels);
mask=sign(mask.^2-mask);

%  initialise grey level count vector

P=zeros(1, greylevels+1);

%  initialise vector of greylevels

greyvec=[0:(greylevels-1)];

%  add 1 to all pixels and mask out unwanted region, so that 
%  pixel value of 0 occurs only outside region of interest,
%  and add 1 again to give index into count vector

imagein=(imagein+1).*mask+1;

%  loops to work through image to count no of pixels of 
%  each grey level

for row=1:rowsize
	for col=1:colsize
		P(imagein(row,col))=P(imagein(row,col))+1;
	end
end

%  discard first element of P which counts pixels outside 
%  area of interest

P(1)=[];

%  normalize P into probability distribution

P=P/sum(P);

%*************************************************************
%  calculate features
%*************************************************************

%  mean

mean=sum(greyvec.*P);

%  variance

var=sum((greyvec-mean).^2.*P);

%  median

cumP=cumsum(P);
i=1;
while cumP(i)<0.5
	i=i+1;
end
if i>1
	med=i-0.5-(cumP(i)-0.5)/(cumP(i)-cumP(i-1));
else
	med=0;
end

%  mode

[maxP,i]=max(P);
mode=i-1;

%  skewness

skew=sum((greyvec-mean).^3.*P)/sqrt(var)^3;

%  kurtosis

kurt=sum((greyvec-mean).^4.*P)/var^2;

%  energy

eng=sum(P.*P);

%  entropy

ent=-sum(P.*log(P+eps));
