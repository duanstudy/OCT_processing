function contrast = compare_contrastEnhancement(im)    
    
    ind = 0;
    
    % https://uk.mathworks.com/help/images/ref/locallapfilt.html
    % If you have R2017A
    %{
    ind = ind+1;
    contrast{ind}.name = 'Local Laplacian Filtering';    
    sigma = 0.4;
    alpha = 0.5;        
    tic;
    contrast{ind}.data = locallapfilt(im, sigma, alpha);
    contrast{ind}.timing = toc;
    %}
    
    ind = ind+1;
    contrast{ind}.name = 'CLAHE (Rayleigh)';
    clipLimit = 0.01; % the larger, more stronger effect
    tic;
    contrast{ind}.data = CLAHE_wrapper(im, clipLimit);
    contrast{ind}.timing = toc;
    contrast{ind}.param = [clipLimit];
    
    imwrite(contrast{ind}.data,[contrast{ind}.name, '.jpg'],'Quality',100)
