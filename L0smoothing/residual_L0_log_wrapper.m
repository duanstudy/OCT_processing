function denoised = residual_L0_log_wrapper(im, residual, iter, kappa, lambda)

    if nargin == 3
        kappa = 2;
        lambda = 5e-4;
    end    
    
    whos
    disp([min(residual(:)) max(residual(:))])
    
    denoised = residual;
    init = residual;
    
    iter = 1;
    for i = 1 : iter        
        L0Smoothed = L0Smoothing(residual, lambda, kappa);
        residual = L0Smoothed;
    end
    
    % disp([min(residual(:)) max(residual(:))])
    % residual_L0 = residual;
    
    % smooth more the residual with Guided Filter (Fast)
    epsilon = 0.005^2; % regularization parameter: eps
    win_size = 2; % local window radius
    s = 1; % 1, no subsampling

    iter = 16;
    for i = 1 : iter
        residual = fastguidedfilter(residual, residual, win_size, epsilon, s);
    end
    
    denoised = im + residual;
    denoised = norm_image_for_display(denoised, 0);

    %{
    subplot(4,1,1); imshow(init, []); title('Residual In'); colorbar
    subplot(4,1,2); imshow(residual_L0, []); title('Residual Out'); colorbar
    subplot(4,1,3); imshow(residual, []); title('Residual Out'); colorbar
    subplot(4,1,4); imshow(init-residual, []); title('Residual Diff'); colorbar
    %}
    