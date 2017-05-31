%Im = imread('pflower.jpg');
Im = imread('pflower.jpg');
S = L0Smoothing(Im,0.01);

close all
figure('Color', 'w')
subplot(1,2,1)
imshow(Im); title('In')
subplot(1,2,2)
imshow(S); title('L0 Smoothed')
