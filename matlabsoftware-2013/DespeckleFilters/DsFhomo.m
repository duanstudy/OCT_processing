%Homomorhic filtering with the log function
% Christos Loizou 2/6/2008. lslog
%Example: out= DsFhomo(a); 
function f=DsFhomo(I);

L=log(double(I));
K=medfilt2(L, [5 5]); K=medfilt2(K, [5 5]);
KK=exp(K); 
KK=KK./255;
f=KK;

figure, subplot(2,1,1),  imshow(I), title('Original Image');
subplot(2,1,2), imshow(f), title('Despeckled Image by DsFhomo'); 