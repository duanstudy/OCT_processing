%The function metrics calclualtes the image quality metrics between the
%original and the despeckled image
% INPUTS:   I: original image
%           K: despeckled image
% OUTPUT
%           f: matrix containing all image quality evaluation metrics 
%           The matrix f will contain the following metrics 
%           [gaer, mse, snr, rmse, psnr, me, m4, qi, ssim, AD, SC, NK, MD,
%           LMSE, NAE, PQS]
% Ex.:      F=DsQmetrics(I,K); 
%(C) C.P. Loizou 2008

function f=DsQmetrics(I,K);
I=double(I); K=double(K);
 gaer = DsQEGAE(I,K);
 metrics= [gaer];
 %calculate the mean square error mse
 mser=mse(I,K);
 metrics=[metrics, mser];
 %calculate the signal-to-noise radio snr
 snrad=dsqesnr(I,K);
 metrics=[metrics, snrad];
 %calculate the square root of the mean square error
 rmser=dsqermse(I, K);
 metrics=[metrics, rmser];
 %Calculate the peak-signal-to-noise radio
 psnrad=dsqepsnr(I,K);
 metrics=[metrics, psnrad];
 %Calculate the Minkwofski measure
 [M3, M4] = DsQEminkowski(I, K);
 metrics=[metrics, M3, M4];
 %Calculate the universal quality index
 [quality, quality_map] = DsQEimg_qi(I,K);
 metrics=[metrics, quality];
 %Calculate the structural similarity index
 [mssim, ssim_map] = DsQEssim_index(I, K);
 metrics=[metrics, mssim];
 
 %calculate aditional metrics 
 [MSE,PSNR,AD,SC,NK,MD,LMSE,NAE,PQS]=DsQEiq_measures(I,K);
 metrics=[metrics, AD, SC, NK, MD, LMSE, NAE, PQS];
 
 %MEM=[MEM, metrics']; 
 f= metrics; 
 
