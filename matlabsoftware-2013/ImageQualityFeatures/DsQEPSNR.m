%Calculates the Peak Signal to Noise Radio (PSNR)
%MSE should be very low if the transformed image resembles close to original. 
%Conversely PSNR is higher for a better transformed image and low for a badly transformed image. 

function N = DsQEPSNR(P,Q,S);
R=DSQERMSE(P,Q);
max=0;
P=double(P);

len=(size(P,1));
wid=(size(P,2));

for i = 1:len
    for j=1:wid
        % For a 2-D image
        Pr=P(i,j);
        Qr=P(i,j);

        
        % For 3-D image
%         Pr=P(i,j,1);
%         Pg=P(i,j,2);
%         Pb=P(i,j,3);
        
%         mag =((Pr^2) + (Pg^2) + (Pb^2))^0.5;

          mag=((Pr^2) + (Qr^2))^0.5;
        if(mag>max)
            max=mag;
        end
    end
end
if (R==0)
    N=1000000;
else
    N=max/R;
    N=20*log10(N);
end
%has two images as imputs. calculates RMSE using RMSE functions. Uses llop to calculate Max pixel and the applies the formula.
