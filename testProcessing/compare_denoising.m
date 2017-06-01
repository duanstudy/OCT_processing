function denoised = compare_denoising(im)    
    
    ind = 0;
    im = double(im);
    im = norm_image_for_display(im, 0);
    
    imwrite(im,['raw_noisy_input.jpg'],'Quality',100)

    
    %% BM3D
    
        ind = ind+1;
        denoised{ind}.name = 'BM3D';
        epsilon = 0.9;
        sigma = 25;
        tic;
        denoised{ind}.data = BM3D_log_wrapper(im, epsilon, sigma);
        denoised{ind}.timing = toc;
        denoised{ind}.param = [epsilon; sigma];

        imwrite(denoised{ind}.data,[denoised{ind}.name, '.jpg'],'Quality',100)

        
    %% BM3D (Cascaded)
    
        % trial-and-error use of BM3D trying to denoise the residual, and
        % add the remaining details back to input (1st pass of the BM3D)
    
        ind = ind+1;
        denoised{ind}.name = 'BM3D Cascaded Residual';
        im_prev_step = denoised{ind-1}.data;
        scaling_8bit = 0;
        residual = im - norm_image_for_display(im_prev_step, scaling_8bit);
             
        epsilon = 0.9;
        sigma = 25;
        denoised{ind}.data = BM3D_cascaded_log_wrapper(im_prev_step, residual, epsilon, sigma);
        
        % Motivation for this "ghetto fix" was that the initial denoising
        % pass might denoise too much and take some of the edges that can
        % be useful for example in retinal layer segmentation, and by
        % re-denoising the residual, we could denoise the noise away and
        % keep some of the once removed edges and add those edges back        
        denoised{ind}.timing = toc;
        denoised{ind}.param = [epsilon; sigma];
        
        imwrite(denoised{ind}.data,[denoised{ind}.name, '.jpg'],'Quality',100)
        

    %% Residual cleaning with L0
    
        load('temp.mat')
        
        ind = ind+1;
        denoised{ind}.name = 'BM3D Cascaded Residual + L0';
        im_prev_step = denoised{ind-1}.data;
        scaling_8bit = 0;
        residual = im - norm_image_for_display(im_prev_step, scaling_8bit);
        
        epsilon = 0.9;
        sigma = 25;
        iter = 2; % keeps iterating on the residual
        denoised{ind}.data = residual_L0_log_wrapper(im_prev_step, residual, iter);
        denoised{ind}.timing = toc;
        denoised{ind}.param = [epsilon; sigma];
        
        imwrite(denoised{ind}.data,[denoised{ind}.name, '.jpg'],'Quality',100)
        