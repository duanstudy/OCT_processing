function [mf,rf]=DsTnwsgldm(imagein,d)
%
%  MATLAB function to implement 'Full SGLDM' method 
%  of texture analysis.
%  Method is as described in "Textural Features for Image 
%  Classification", R.M. Haralick, K.Shanmugam, I. Dinstein,
%  IEEE Transactions on Systems, Man., and Cybernetics, 
%  Vol. SMC-3, Nov. 1993.
%  Inputs:
%    imagein	- input image
%    d		- distance for computation of cooccurence matrices
%
%  The features f1 to f13 are computed for angles 0, 45, 90 and 135 degrees, 
%  and the mean and range of the features over the four angles are output 
%  in the 13 elements of mf and rf respectively as follows:
%    1)  f1  - angular second moment (energy)
%    2)  f2  - contrast
%    3)  f3  - correlation
%    4)  f4  - sum of squares (variance)
%    5)  f5  - inverse difference moment (homogeneity)
%    6)  f6  - sum average
%    7)  f7  - sum variance
%    8)  f8  - sum entropy
%    9)  f9  - entropy
%   10) f10 - difference variance
%   11) f11 - difference entropy
%   12) f12 }
%   13) f13 } information measures of correlation
%
%  Any pixel of value greater than 253 in the input image 
%  is considered to be outside the region of interest, and is 
%  excluded from the feature computation.
%

greylevels=254;
coocsize=256;
[rowsize, colsize]=size(imagein);

%*************************************************************
%	generalised calculation of co-occurence matrices
%	Pn is co-occurence matrix for angle n
%	Rn is normalization factor for angle n
%	d is distance for calculation of co-occurence matrix
%**************************************************************

%  initialise cooccurence matrices to zero

P0=zeros(coocsize,coocsize);
P45=P0;
P90=P0;
P135=P0;

%  increment entire image to give index to cooccurence matrix

imagein=imagein+1;

%  buffer edge of image

buffimage=ones(rowsize+2*d,colsize+2*d)*coocsize;
buffimage((1+d):(rowsize+d),(1+d):(colsize+d))=imagein;

%  work through entire image, calculating cooccurence matrices
%  count pixels in one direction only in loop 

for row=(1+d):(rowsize+d)
	for col=(1+d):(colsize+d)

		value=buffimage(row,col);

		rowmd=row-d;
		rowpd=row+d;
		colmd=col-d;
		colpd=col+d;

		P0(value,buffimage(row,colpd))=P0(value,buffimage(row,colpd))+1;

		P45(value,buffimage(rowmd,colpd))=P45(value,buffimage(rowmd,colpd))+1;

		P90(value,buffimage(rowmd,col))=P90(value,buffimage(rowmd,col))+1;

		P135(value,buffimage(rowmd,colmd))=P135(value,buffimage(rowmd,colmd))+1;

	end
end

%  add transpose of matrices to themselves, to include effect of
%  pixels in equal and opposite directions

P0=P0+P0';
P45=P45+P45';
P90=P90+P90';
P135=P135+P135';

%  discard elements in P matrices corresponding pixels outside region of interest

greylevelsp1=greylevels+1;
P0(greylevelsp1:coocsize,:)=[];
P0(:,greylevelsp1:coocsize)=[];
P45(greylevelsp1:coocsize,:)=[];
P45(:,greylevelsp1:coocsize)=[];
P90(greylevelsp1:coocsize,:)=[];
P90(:,greylevelsp1:coocsize)=[];
P135(greylevelsp1:coocsize,:)=[];
P135(:,greylevelsp1:coocsize)=[];

%  calculate normalization coefficients

R0=sum(sum(P0));
R45=sum(sum(P45));
R90=sum(sum(P90));
R135=sum(sum(P135));

%  normalize matrices

P0=P0/R0;
P45=P45/R45;
P90=P90/R90;
P135=P135/R135;

%**************************************************************
%	functions to calculate features
%**************************************************************

%  define commonly used matrices

[m l]=meshgrid([1:254],[1:254]);
lminusmsq=(l-m).^2;
vec=[1:254];

%  calculate f1 - angular second moment (energy)

f1(1)=sum(sum(P0.*P0));
f1(2)=sum(sum(P45.*P45));
f1(3)=sum(sum(P90.*P90));
f1(4)=sum(sum(P135.*P135));

mf(1)=mean(f1);
rf(1)=max(f1)-min(f1);

%  calculate f2 - contrast

f2(1)=sum(sum(P0.*lminusmsq));
f2(2)=sum(sum(P45.*lminusmsq));
f2(3)=sum(sum(P90.*lminusmsq));
f2(4)=sum(sum(P135.*lminusmsq));

mf(2)=mean(f2);
rf(2)=max(f2)-min(f2);

%  calculate f3 - correlation

meanm0=sum(vec.*sum(P0));
meanm45=sum(vec.*sum(P45));
meanm90=sum(vec.*sum(P90));
meanm135=sum(vec.*sum(P135));

sdm0=sqrt(sum((vec-meanm0).^2.*sum(P0)));
sdm45=sqrt(sum((vec-meanm45).^2.*sum(P45)));
sdm90=sqrt(sum((vec-meanm90).^2.*sum(P90)));
sdm135=sqrt(sum((vec-meanm135).^2.*sum(P135)));

f3(1)=(sum(sum(l.*m.*P0))-meanm0^2)/sdm0^2;
f3(2)=(sum(sum(l.*m.*P45))-meanm45^2)/sdm45^2;
f3(3)=(sum(sum(l.*m.*P90))-meanm90^2)/sdm90^2;
f3(4)=(sum(sum(l.*m.*P135))-meanm135^2)/sdm135^2;

mf(3)=mean(f3);
rf(3)=max(f3)-min(f3);

%  calculate f4 - sum of squares

f4(1)=sum(sum((m-meanm0).^2.*P0));
f4(2)=sum(sum((m-meanm45).^2.*P45));
f4(3)=sum(sum((m-meanm90).^2.*P90));
f4(4)=sum(sum((m-meanm135).^2.*P135));

mf(4)=mean(f4);
rf(4)=max(f4)-min(f4);

%  calculate f5 - inverse difference moment (homogeneity)

f5(1)=sum(sum(P0./(lminusmsq+1)));
f5(2)=sum(sum(P45./(lminusmsq+1)));
f5(3)=sum(sum(P90./(lminusmsq+1)));
f5(4)=sum(sum(P135./(lminusmsq+1)));

mf(5)=mean(f5);
rf(5)=max(f5)-min(f5);

%  calculate f9 - entropy

f9(1)=-sum(sum(P0.*log(P0+eps)));
f9(2)=-sum(sum(P45.*log(P45+eps)));
f9(3)=-sum(sum(P90.*log(P90+eps)));
f9(4)=-sum(sum(P135.*log(P135+eps)));

mf(9)=mean(f9);
rf(9)=max(f9)-min(f9);

%************************************************************************
%  calculation of sum features
%************************************************************************

%  set up vectors for sum features

rotP=rot90(P0);
for i=1:2*greylevels-1
	Pxplusy0(i)=sum(diag(rotP,i-greylevels));
end

rotP=rot90(P45);
for i=1:2*greylevels-1
	Pxplusy45(i)=sum(diag(rotP,i-greylevels));
end

rotP=rot90(P90);
for i=1:2*greylevels-1
	Pxplusy90(i)=sum(diag(rotP,i-greylevels));
end

rotP=rot90(P135);
for i=1:2*greylevels-1
	Pxplusy135(i)=sum(diag(rotP,i-greylevels));
end

isumvec=[2:(2*greylevels)];

%  calculate f6 - sum average

f6(1)=sum(isumvec.*Pxplusy0);
f6(2)=sum(isumvec.*Pxplusy45);
f6(3)=sum(isumvec.*Pxplusy90);
f6(4)=sum(isumvec.*Pxplusy135);

mf(6)=mean(f6);
rf(6)=max(f6)-min(f6);

%  calculate f7 - sum variance

f7(1)=sum((isumvec-f6(1)).^2.*Pxplusy0);
f7(2)=sum((isumvec-f6(2)).^2.*Pxplusy45);
f7(3)=sum((isumvec-f6(3)).^2.*Pxplusy90);
f7(4)=sum((isumvec-f6(4)).^2.*Pxplusy135);

mf(7)=mean(f7);
rf(7)=max(f7)-min(f7);

%  calculate f8 - sum entropy

f8(1)=-sum(Pxplusy0.*log(Pxplusy0+eps));
f8(2)=-sum(Pxplusy45.*log(Pxplusy45+eps));
f8(3)=-sum(Pxplusy90.*log(Pxplusy90+eps));
f8(4)=-sum(Pxplusy135.*log(Pxplusy135+eps));

mf(8)=mean(f8);
rf(8)=max(f8)-min(f8);

%****************************************************************************
%  calculate difference features
%****************************************************************************

%  set up vectors for difference features

Pxminusy0(1)=trace(P0);
Pxminusy45(1)=trace(P45);
Pxminusy90(1)=trace(P90);
Pxminusy135(1)=trace(P135);

for i=2:greylevels
	Pxminusy0(i)=sum(diag(P0,i-1))+sum(diag(P0,1-i));
	Pxminusy45(i)=sum(diag(P45,i-1))+sum(diag(P45,1-i));
	Pxminusy90(i)=sum(diag(P90,i-1))+sum(diag(P90,1-i));
	Pxminusy135(i)=sum(diag(P135,i-1))+sum(diag(P135,1-i));
end

idifvec=[0:greylevels-1];

%  calculate f10 - difference variance

av0=sum(idifvec.*Pxminusy0);
av45=sum(idifvec.*Pxminusy45);
av90=sum(idifvec.*Pxminusy90);
av135=sum(idifvec.*Pxminusy135);

f10(1)=sum((idifvec-av0).^2.*Pxminusy0);
f10(2)=sum((idifvec-av45).^2.*Pxminusy45);
f10(3)=sum((idifvec-av90).^2.*Pxminusy90);
f10(4)=sum((idifvec-av135).^2.*Pxminusy135);

mf(10)=mean(f10);
rf(10)=max(f10)-min(f10);

%  calculate f11 - difference entropy

f11(1)=-sum(Pxminusy0.*log(Pxminusy0+eps));
f11(2)=-sum(Pxminusy45.*log(Pxminusy45+eps));
f11(3)=-sum(Pxminusy90.*log(Pxminusy90+eps));
f11(4)=-sum(Pxminusy135.*log(Pxminusy135+eps));

mf(11)=mean(f11);
rf(11)=max(f11)-min(f11);

%************************************************************************
%  information measures of correlation
%************************************************************************

%  calculate entropy matrices

pvec=sum(P0);
logpvec=log(pvec+eps);
[py,px]=meshgrid(pvec);
[logpy,logpx]=meshgrid(logpvec);
pxpy=px.*py;
logpxpy=logpx+logpy;
hxy1_0=-sum(sum(P0.*logpxpy));
hxy2_0=-sum(sum(pxpy.*logpxpy));
h_0=-sum(pvec.*logpvec);

pvec=sum(P45);
logpvec=log(pvec+eps);
[py,px]=meshgrid(pvec);
[logpy,logpx]=meshgrid(logpvec);
pxpy=px.*py;
logpxpy=logpx+logpy;
hxy1_45=-sum(sum(P45.*logpxpy));
hxy2_45=-sum(sum(pxpy.*logpxpy));
h_45=-sum(pvec.*logpvec);

pvec=sum(P90);
logpvec=log(pvec+eps);
[py,px]=meshgrid(pvec);
[logpy,logpx]=meshgrid(logpvec);
pxpy=px.*py;
logpxpy=logpx+logpy;
hxy1_90=-sum(sum(P90.*logpxpy));
hxy2_90=-sum(sum(pxpy.*logpxpy));
h_90=-sum(pvec.*logpvec);

pvec=sum(P135);
logpvec=log(pvec+eps);
[py,px]=meshgrid(pvec);
[logpy,logpx]=meshgrid(logpvec);
pxpy=px.*py;
logpxpy=logpx+logpy;
hxy1_135=-sum(sum(P135.*logpxpy));
hxy2_135=-sum(sum(pxpy.*logpxpy));
h_135=-sum(pvec.*logpvec);

%  calculate f12 

f12(1)=(f9(1)-hxy1_0)/h_0;
f12(2)=(f9(2)-hxy1_45)/h_45;
f12(3)=(f9(3)-hxy1_90)/h_90;
f12(4)=(f9(4)-hxy1_135)/h_135;

mf(12)=mean(f12);
rf(12)=max(f12)-min(f12);

%  calculate f13

f13(1)=sqrt(1-exp(-2*(hxy2_0-f9(1))));
f13(2)=sqrt(1-exp(-2*(hxy2_45-f9(2))));
f13(3)=sqrt(1-exp(-2*(hxy2_90-f9(3))));
f13(4)=sqrt(1-exp(-2*(hxy2_135-f9(4))));

mf(13)=mean(f13);
rf(13)=max(f13)-min(f13);








