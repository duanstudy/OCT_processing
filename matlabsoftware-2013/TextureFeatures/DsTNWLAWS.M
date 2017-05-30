function [LL,EE,SS,LE,ES,LS]=DsTnwlaws(imagein,d)
% C.P. Loizou
%  Function to implement Laws texture energy method, for
%  3x3, 5x5 and 7x7 masks.
%
%  Method is as defined by 
%  1) "Rapid Texture Identification"
%     K.I.Laws, SPIE, 1980, Vol 238, 376-380
%  2) "Computer and Robot Vision Vol 1", 
%     R.M.Haralick & L.G.Shapiro, Addison-Wesley, 1992
%
%  Inputs:
%    imagein - input image
%    d       - mask dimension, either 3, 5 or 7
%
%  Outputs:
%    LL - texture energy from LL kernel
%    EE - texture energy from EE kernel
%    SS - texture energy from SS kernel
%    LE - average texture energy from LE and EL kernels
%    ES - average texture energy from ES and SE kernels
%    LS - average texture energy from LS ans SL kernels
%
%  Texture energy measures are given by standard deviation
%  of convolved image over entire region of interest.
%  Averaging of matched pairs of energy measures
%  gives rotational invariance.
%
%  Any pixel of value greater than 253 in the input image 
%  is considered to be outside the region of interest, and is 
%  excluded from the feature computation.


greylevels=254;
[rowsize,colsize]=size(imagein);

%****************************************************************
%  set up masks depending on required dimension
%****************************************************************

if d==3
	L=[ 1  2  1];
	E=[-1  0  1];
	S=[-1  2 -1];
	oneskernel=ones(3,3);

elseif d==5
	L=[ 1  4  6  4  1];
	E=[-1 -2  0  2  1];
	S=[-1  0  2  0 -1];
	oneskernel=ones(5,5);

else
	L=[ 1  6  15  20  15  6  1];
	E=[-1 -4  -5   0   5  4  1];
	S=[-1 -2   1   4   1 -2 -1];
	oneskernel=ones(7,7);
end

LLkernel=L'*L;
LEkernel=L'*E;
LSkernel=L'*S;
ELkernel=E'*L;
EEkernel=E'*E;
ESkernel=E'*S;
SLkernel=S'*L;
SEkernel=S'*E;
SSkernel=S'*S;


kernel=str2mat(	'LLkernel',...
		'LEkernel',...
		'LSkernel',...
		'ELkernel',...
		'EEkernel',...
		'ESkernel',...
		'SLkernel',...
		'SEkernel',...
		'SSkernel');

%**************************************************************
%  select region of interest
%**************************************************************

%  compute mask to select region of interest from image
%  mask=0 inside region, and +ve elsewhere

mask=sign(imagein-greylevels)+1;

%  convolve with kernel of ones to select pixels for which the
%  kernel lies entirely within region of interest
%  convmask=1 where kernel fits into region, 0 otherwise

convmask=conv2(mask,oneskernel,'valid');
convmask=abs(sign(convmask)-1);

%  N is total number of pixels in convmask

N=sum(sum(convmask));

%**************************************************************
%  convolve kernels with image and calculate energy measures
%**************************************************************

for i=1:9
	convimage=conv2(imagein,eval(kernel(i,:)),'valid').*convmask;
	mean=sum(sum(convimage))/N;
	f(i)=sqrt(sum(sum((convimage-mean).^2.*convmask))/N);
end

%**************************************************************
%  form output measures by rotational averaging
%**************************************************************

LL=f(1);
EE=f(5);
SS=f(9);
LE=(f(2)+f(4))/2;
ES=(f(6)+f(8))/2;
LS=(f(3)+f(7))/2;

