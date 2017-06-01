function [mse, snr, psnr, mssim] = compute_imageQuality(im, imFiltered, peakVal)

    if peakVal == 255
        scaling_8bit = 1;
    else
        scaling_8bit = 0;
    end
    
    im = norm_image_for_display(im, scaling_8bit);
    imFiltered = norm_image_for_display(imFiltered, scaling_8bit);

    % MSE
    mse = (im(:)-imFiltered(:))'*(im(:)-imFiltered(:))/numel(im);
        
    % SNR
    snr = 20*log10(mean(im(:))/mean(abs(imFiltered(:)-im(:))));
            
    % Peak SNR
    psnr = 10 * log(peakVal^2 / mean2((imFiltered - im).^2)) / log(10);
          
    % SSIM    
    % http://www.cns.nyu.edu/~lcv/ssim/
    [mssim, ssim_map] = ssim(im, imFiltered);
          
    % Image Enhancement Factor?
      % IEF = Image Enhancement Factor
      % http://www.mathworks.com/matlabcentral/fileexchange/46561-bilateral-filter