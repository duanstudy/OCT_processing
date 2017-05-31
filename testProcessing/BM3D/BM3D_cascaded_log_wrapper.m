function denoised = BM3D_cascaded_log_wrapper(im, residual, epsilon, sigma, iter)
    
    scaling_8bit = 0;
    
    for i = 1 : iter
        
        residual_min = min(residual(:));
        residual_max = max(residual(:));

        denoised = BM3D_log_wrapper(residual, epsilon, sigma);

        % map back the [0...1] normalized image to input range
        low_in = 0; high_in = 1; 
        low_out = 0; 
        high_out = residual_max - (residual_min); % cannot directly map to negative value

        denoised = imadjust(denoised, [low_in; high_in],[low_out; high_out]);
        denoised = denoised + residual_min; 

        % add the denoised residual back to previous 1st pass
        denoised = im + denoised;   
        
        % needed when iterating
        if iter > 1
            % TODO! The iteration approach just ends up smoothing the image
            % too much
            
            residual = im - norm_image_for_display(denoised, scaling_8bit);
            im = denoised; 
        end
        
    end
    
    denoised = norm_image_for_display(denoised, scaling_8bit);
             