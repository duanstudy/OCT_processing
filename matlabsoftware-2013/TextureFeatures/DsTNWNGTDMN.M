function[coars,contr,busyn,compl,stren]=DsTnwngtdmn(imagein,d)
% 
%  MATLAB function to implement the 'Normalized NGTDM'
%  method of texture analysis.
%  Method is as documented in "Texural Features Corresponding to 
%  Texural Properties", M.Amadasun, R.King.
%  IEEE Transactions on Systems, Man, and Cybernetics, Vol 19, No 5,
%  Sep/Oct 1989. 
%
%  Feature definitions normalized for images of differing size/shape
%  by dividing terms of sum(p*s) and sum(s) by R.
%
%  Inputs:
%    imagein	- input image
%    d		- neighborhood size
%
%  Outputs:
%    coars	- coarseness
%    contr	- contrast
%    busyn	- busyness
%    compl	- complexity
%    stren	- strength
%
%  Any pixel of value greater than 253 in the input image 
%  is considered to be outside the region of interest, and is 
%  excluded from the feature computation.

greylevels=254;
[rowsize, colsize]=size(imagein);

%****************************************************************
%  Calculation of Neighborhood grey tone vector and normalization
%  coefficients.
%****************************************************************

%  define neighborhood kernels

oneskernel=ones(2*d+1,2*d+1);
kernel=oneskernel;
kernel(d+1,d+1)=0;
kerncount=(2*d+1)^2-1;

%  set ngtd vector and count vector to zero 

S=zeros(greylevels,1);
N=zeros(greylevels,1);

%  increment entire image to give index into ngt and count vectors

imageinp1=imagein+1;

%****************************************************************
%  select region of interest
%****************************************************************

%  compute mask to select region of interest from image
%  mask=0 inside region, and +ve elsewhere

mask=sign(imagein-greylevels)+1;

%  convolve with kernel of ones to select pixels for which the
%  kernel lies entirely within region of interest
%  convmask=1 where kernel fits into region, 0 otherwise

convmask=conv2(mask,oneskernel,'same');
convmask=abs(sign(convmask)-1);

%****************************************************************
%  convolve kernel with image and compute NGTD matrix
%****************************************************************

%  calculate neighbourhood average

convimage=conv2(imagein,kernel,'same')/kerncount;

%  calculate absolute differences between actual and 
%  neighbourhood average grey levels

convimage=abs(imagein-convimage);

%  work through convolved image constructing NGTD matrix

for row=(1+d):(rowsize-d)
	for col=(1+d):(colsize-d)
		if convmask(row,col)>0
			index=imageinp1(row,col);
			S(index)=S(index)+convimage(row,col);
			N(index)=N(index)+1;
		end
	end
end

%  calculate normalization coefficient

R=sum(N);

%*******************************************************************
%  Calculate features
%*******************************************************************

%  calculate useful matrices

[Ni,Nj]=meshgrid(N);
[Si,Sj]=meshgrid(S);
[i,j]=meshgrid([0:greylevels-1]);
ilessjsq=(i-j).^2;

%  Elements of Ni and Nj are required to be zero where either 
%  Ni or Nj are zero.

Ni=Ni.*abs(sign(Nj));
Nj=Nj.*abs(sign(Ni));

%  coarseness

coars=R*R/sum(N.*S);

%  contrast

Ng=nnz(N);
contr=sum(S)*sum(sum(Ni.*Nj.*ilessjsq))/R^3/Ng/(Ng-1);

%  busyness
%  assumes that absolute value of sum of differences between 
%  weighted grey scale valuesis intended, in accordance with 
%  textual description in source paper

busyn=sum(N.*S)/sum(sum(abs(i.*Ni-j.*Nj)))/R;

%  complexity

compl=sum(sum(abs(i-j).*(Ni.*Si+Nj.*Sj)./(Ni+Nj+eps)))/R;

%  strength

stren=sum(sum((Ni+Nj).*ilessjsq))/(sum(S)+eps);

