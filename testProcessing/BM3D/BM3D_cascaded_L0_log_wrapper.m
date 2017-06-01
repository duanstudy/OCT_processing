function denoised = BM3D_cascaded_L0_log_wrapper(im_prev_step, residual, epsilon, sigma, iter)

    denoised = residual;
    subplot(3,1,1); imshow(residual, []); colorbar
    
    kappa = 2;
    lambda = 1e-5;
    
    init = residual;
    
    for i = 1 : iter
        
        L0Smoothed = L0Smoothing(residual, lambda, kappa);
        
        subplot(3,1,2); imshow(L0Smoothed, []); colorbar
        subplot(3,1,3); imshow(init-L0Smoothed, []); colorbar
        residual = L0Smoothed;
        
        drawnow
        pause
        
    end