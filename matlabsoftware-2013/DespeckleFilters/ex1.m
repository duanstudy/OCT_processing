%Example 1: Read an image, despeckle, and extract the texture features of the original
%and the despeckled images. 
%INPUTS
% a:            original (noisy) image
%OUTPUTS
%outimage:      despeckled image
%or_feats:      texture features of the original image
%Ds_feats:      texture features of the despeckled image
%After running the program the texture features may be opened in the matlab
%space by double clicling on the variables created or by using 
% open or_feat, open Ds_feat; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read the image to be filtered 
clear all;

a=imread('cell.tif'); %figure, imshow(a), title ('original image'); 

%Despeckle the image with the despeckle filter DSFlsmv
% with a [5x5] moving sliding window and 2 itterations 
outimage= DsFlsmv (a, [3 3], 5); %figure, imshow(outimage), title ('Despeckled image');

%Extract the texture features for the original image
% and save them in the matrix or_feat
[or_feat]=DsTTEXFEAT(double(a)); % open or_feat;
save or_feat or_feat;
%Extract the texture features for the despeckled image
%and save them in the matrix Ds_Feat
[Ds_feat]=DsTtexfeat(double(outimage)); %open Ds_feat
save Ds_feat Ds_feat; 
% Calculate the image quality metrics and save them in F
% F= [gaer, mse, snr, rmse, psnr, me, m4, qi, ssim, AD, SC, NK, MD,
%           LMSE, NAE, PQS]
F=DsQmetrics(a,outimage); 
save QEmetrics F; 

