function [coars, cont, period, rough]=DsTnwsfm(imagein,lr,lc)
%
%  Function to implememt the Statistical Feature Matrix method 
%  of texture analysis.
%  
%  Method is as defined by "Statistical Feature Matrix for 
%  Texture Analysis", Chung-Ming Wu and Yung-Chang Chen, 
%  CVGIP: Graphical Models and Image Processing
%  Vol 54, No 5, Sep '92, pp 407-419.
%
%  Inputs:
%    imagein	- input image
%    lr		- variable Lr defining size of feature matrix
%    lc		- variable Lc defining size of feature matrix
%
%  Outputs:
%    coars	- coarseness measure
%    cont	- contrast measure
%    period	- periodicity measure
%    rough	- roughness measure
%
%  Any pixel of value greater than 253 in the input image 
%  is considered to be outside the region of interest, and is 
%  excluded from the feature computation.

greylevels=254;
[rowsize,colsize]=size(imagein);

%*******************************************************************************
%  compute statistical feature matrices
%*******************************************************************************

%  work through statistical feature matrices one delta at a time

for delrow=0:lr
	for delcol=-lc:lc

%  define coords in sf matrix

		row=delrow+1;
		col=delcol+lc+1;

%  shift image by delrow and delcol

		delimage=ones(rowsize,colsize)*(greylevels+1);
		if delcol<0
			delimage(1:(rowsize-delrow),(1-delcol):colsize)=...
			  imagein((1+delrow):rowsize,1:(colsize+delcol));
		else
			delimage(1:(rowsize-delrow),1:(colsize-delcol))=...
			  imagein((1+delrow):rowsize,(1+delcol):colsize);
		end

%  mask to define area of interest in original and shifted image
%  pixels are only considered where they are present in both 
%  original and shifted images

		imagmask=sign(imagein-greylevels);
		imagmask=sign(imagmask.*imagmask-imagmask);

		delimagmask=sign(delimage-greylevels);
		delimagmask=sign(delimagmask.*delimagmask-delimagmask);

		mask=imagmask.*delimagmask;

%  number of pixels to be considered

		n=sum(sum(mask));

%  mean of image area of interest

		meanimage=sum(sum(imagein.*mask))/n;

%  compute contrast for this delta

		con(row,col)=sum(sum(((imagein-delimage).*mask).^2))/n;

%  compute covariance for this delta

		cov(row,col)=sum(sum((imagein-meanimage).*(delimage-meanimage).*mask))/n;

%  compute dissimilarity for this delta

		dss(row,col)=sum(sum(abs(imagein-delimage).*mask))/n;

	end
end

%  set first half of first row to zero to preserve symmetry, as per Wu and Chen

con(1,1:(lc+1))=zeros(1,lc+1);
cov(1,1:(lc+1))=zeros(1,lc+1);
dss(1,1:(lc+1))=zeros(1,lc+1);

%**************************************************************************************
%  calculate features based on sfm
%**************************************************************************************

%  compute coarseness measure
%  value of c is set arbitrarily to 100 as per Wu and Chen

r=min([lr,lc]);
coars=100*(r+1)*(2*r)/sum(sum(dss(1:(r+1),(1+lc-r):(1+lc+r))));

%  compute contrast measure

cont=sqrt(sum(sum(con(1:2,lc:(lc+2))))/2);

%  compute periodicity measure
%  exclude zero elements from determination of minimum of dss,
%  and computation of mean

dsscol=reshape(dss',1,(lr+1)*(2*lc+1));
dsscol(1:(lc+1))=[];
meandss=sum(sum(dss))/((lr+1)*(2*lc+1)-(lc+1));
period=(meandss-min(dsscol))/meandss;

%  compute roughness measure

lgdssr=log(dss(1,(lc+2):(2*lc+1))+eps);
lgdssc=log(dss(2:(lr+1),lc+1)+eps);
lgdelr=log([1:lc]);
lgdelc=log([1:lr]');
Hr=(lc*sum(lgdssr.*lgdelr)-sum(lgdelr)*sum(lgdssr))/(lc*sum(lgdelr.^2)-sum(lgdelr)^2);
Hc=(lr*sum(lgdssc.*lgdelc)-sum(lgdelc)*sum(lgdssc))/(lr*sum(lgdelc.^2)-sum(lgdelc)^2);
rough=(6-Hr-Hc)/2;


