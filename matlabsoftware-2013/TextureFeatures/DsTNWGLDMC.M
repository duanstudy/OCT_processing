function [hom,con,eng,ent,mean]=DsTnwgldmc(imagein,d)
% C.P. Loizou
%  MATLAB function to calculate texture features for
%  'Compact GLDM' method.
%
%  Method is based upon description in "A Comparative
%  Study of Texture Measures for Terrain Classification",
%  J.S.Weszka, C.R.Dyer, A.Rosenfield, IEEE Transactions on
%  Systems, Man. & Cybernetics, Vol. SMC-6, April 1976.
%
%  Features are calculated from a single grey level difference
%  probability distribution vector, obtained from sum of four 
%  vectors for 0, 45, 90 and 135 degrees.
%
%  Inputs:
%    imagein - input image
%    d       - displacement distance in pixels
%
%  Outputs:
%    hom  - homogeneity
%    con  - contrast
%    eng  - energy
%    ent  - entropy
%    mean - mean
%
%  Any pixel of value greater than 253 in the input image 
%  is considered to be outside the region of interest, and is 
%  excluded from the feature computation.

greylevels=254;
[rowsize,colsize]=size(imagein);

%**************************************************************
%  Calculate probability distribution of grey level differences
%  for displacement distance d at four different angles
%**************************************************************

%  compute mask to select region of interest
%  mask=1 inside region, and 0 elsewhere

mask=sign(imagein-greylevels);
mask=sign(mask.^2-mask);

%  set up grey level difference vector

greydiff=[0:greylevels-1];

%  initialise grey level difference count vector

P=zeros(1,greylevels+1);

%  calculate grey level differences + 1, so that grey level
%  difference = 0 can only arise outside region of interest
%  after multiplication by masks

%  at 0 degrees

diff=abs(imagein(:,1:(colsize-d))-imagein(:,(1+d):colsize))+1;
diff=diff.*mask(:,1:(colsize-d)).*mask(:,(1+d):colsize)+1;
for row=1:rowsize
	for col=1:(colsize-d)
		P(diff(row,col))=P(diff(row,col))+1;
	end
end

%  at 45 degrees

diff=abs(imagein(1:(rowsize-d),1:(colsize-d))-imagein((1+d):rowsize,(1+d):colsize))+1;
diff=diff.*mask(1:(rowsize-d),1:(colsize-d)).*mask((1+d):rowsize,(1+d):colsize)+1;
for row=1:(rowsize-d)
	for col=1:(colsize-d)
		P(diff(row,col))=P(diff(row,col))+1;
	end
end

%  at 90 degrees

diff=abs(imagein(1:(rowsize-d),:)-imagein((1+d):rowsize,:))+1;
diff=diff.*mask(1:(rowsize-d),:).*mask((1+d):rowsize,:)+1;
for row=1:(rowsize-d)
	for col=1:colsize
		P(diff(row,col))=P(diff(row,col))+1;
	end
end

%  at 135 degrees

diff=abs(imagein(1:(rowsize-d),(1+d):colsize)-imagein((1+d):rowsize,1:(colsize-d)))+1;
diff=diff.*mask(1:(rowsize-d),(1+d):colsize).*mask((1+d):rowsize,1:(colsize-d))+1;
for row=1:(rowsize-d)
	for col=1:(colsize-d)
		P(diff(row,col))=P(diff(row,col))+1;
	end
end

%  normalize grey level difference histogram for all angles

P(1)=[];
P=P/sum(P);

%*******************************************************************
%  calculate features
%*******************************************************************

%  homogeneity

hom=sum(P./(greydiff.^2+1));

%  contrast

con=sum(P.*greydiff.^2);

%  energy

eng=sum(P.^2);

%  entropy

ent=-sum(P.*log(P+eps));

%  mean

mean=sum(P.*greydiff);
