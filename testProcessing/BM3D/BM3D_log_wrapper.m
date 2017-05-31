function Z = BM3D_log_wrapper(im, epsilon, sigma)
        
    im = double(im);
    im = im - min(im(:));
    im = im / max(im(:));

    % Multiplicative noise in OCT, log transform
    im_log = log10(im + epsilon);
    
    imshow(im_log, [])
    drawnow

    % Blind denoising with BM3D
    sigma; % fixed value, TODO! estimate from the image
    [NA, im_den] = BM3D(1, im_log, sigma); 

    % convert back to linear domain
    Z = 10 .^ im_den;
    Z = Z - min(Z(:));
    Z = Z / max(Z(:));