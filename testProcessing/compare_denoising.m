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
        iter = 1; % keeps iterating on the residual
        denoised{ind}.data = BM3D_cascaded_log_wrapper(im_prev_step, residual, epsilon, sigma, iter);
        
        % Motivation for this "ghetto fix" was that the initial denoising
        % pass might denoise too much and take some of the edges that can
        % be useful for example in retinal layer segmentation, and by
        % re-denoising the residual, we could denoise the noise away and
        % keep some of the once removed edges and add those edges back        
        denoised{ind}.timing = toc;
        denoised{ind}.param = [epsilon; sigma];
        
        imwrite(denoised{ind}.data,[denoised{ind}.name, '.jpg'],'Quality',100)

        
        
    %% POISSON NL-MEANS
    
        % You could transform the image first with inverse Anscombe to
        % "Poisson" and then back with Anscombe transform?
    
        %{
        ind = ind+1;
        denoised{ind}.name = 'Poisson NL-Means';
        hW = 10; % def. 10 in code, 21 in the paper
        hB = 3; % def. 3 in code, 7 in the paper
        hK = 6; % def. 6 in code, 13 in the paper

        Q = max(max(im)) / 20;  % reducing factor of underlying luminosity
        ima_lambda = im / Q;
        ima_lambda(ima_lambda == 0) = min(min(ima_lambda(ima_lambda > 0)));

        tol = 0.01/mean2(Q); % stopping criteria |CSURE(i) - CSURE(i-1)| < tol
        maxIter = 40;

        tic;
        ima_lambda_ma = diskconvolution(ima_lambda, hK);
        denoised{ind}.data = poisson_nlmeans_PT(ima_lambda, ...
                                                 ima_lambda_ma, ...
                                                 hW, hB, ...
                                                 tol, maxIter);
                                             % maxIter added by PT
        denoised{ind}.timing = toc;
        denoised{ind}.param = [hW hB hK Q tol maxIter];
        %}
    