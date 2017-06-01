function smoothed = compare_edgeAwareSmoothing(im, title_string, compute_with_slow_filters)    
    
    if nargin == 2
        compute_with_slow_filters = 0;
    end
    ind = 0;
    
    %% GUIDED FILTER
    
        ind = ind+1;    
        % http://kaiminghe.com/eccv10/
        % http://www.mathworks.com/help/images/ref/imguidedfilter.html        
        smoothed{ind}.name = 'Guided Filter';
        disp(smoothed{ind}.name)

        % see e.g. Fig 2 of http://dx.doi.org/10.1109/TPAMI.2012.213
        epsilon = 0.004^2; % regularization parameter: eps
        win_size = 2; % local window radius
        s = 1; % 1, no subsampling
        iter = 4;
        tic;
        guide = im; % using image itself, when smoothing
        
        for i = 1 : iter
            im = fastguidedfilter(im, guide, win_size, epsilon, s);
            guide = im;
        end
        
        im = norm_image_for_display(im, 0);
        
        smoothed{ind}.data = im;    
        smoothed{ind}.timing = toc;
        smoothed{ind}.param = [epsilon; win_size];
        
        imwrite(smoothed{ind}.data,[title_string, '_', smoothed{ind}.name, '.jpg'],'Quality',100)

    
    %% L0 Gradient Smoothing
    
        ind = ind+1;  
        smoothed{ind}.name = 'L0 Gradient Smoothing';
        disp(smoothed{ind}.name)
        
        logOffset = 0.2; 
        lambdaS = 1e-5;
        tic;
        [smoothed{ind}.data, ~, ~, ~] = ...
            enhance_logSmooothingFilter(im, logOffset, lambdaS);
        smoothed{ind}.timing = toc;
        smoothed{ind}.param = [logOffset; lambdaS];
        
        imwrite(smoothed{ind}.data,[title_string, '_', smoothed{ind}.name, '.jpg'],'Quality',100)
 
    %% Bilateral Filter
    
        % http://www.mathworks.com/matlabcentral/fileexchange/50855-robust-bilateral-filter
        ind = ind+1;
            
        %  Acronyms used:
        %  SBF: Standard Bilateral Filter; RBF: Robust
        %  Bilater Filter; WBF: Weighted Bilateral Filter
        smoothed{ind}.name = 'Bilateral Filter (RBF)';
        disp(smoothed{ind}.name)

        % For parameters, see for example:
        % 
        sigmaNoise = 5;
        sigmaS = 1;     %  spatial gaussian kernel 
        sigmaR1 = 20;   %  range gaussian kernel for SBF
        sigmaR2 = 20;   %  range gaussian kernel  for RBF
        tol = 0.01;                      

        tic;
        smoothed{ind}.data = bilateralFilter_wrapper(im, sigmaNoise, sigmaS, sigmaR1, sigmaR2, tol, 'RBF');
        smoothed{ind}.timing = toc;
        smoothed{ind}.param = [sigmaNoise sigmaS sigmaR1 sigmaR2 tol];
        
        imwrite(smoothed{ind}.data,[title_string, '_', smoothed{ind}.name, '.jpg'],'Quality',100)

    
    %% Anisotropic Diffusion
    
        % see "coherenceToolbox", not that special results so not
        % implemented here
    
    %% Trilateral Filter
    
        % NOTE! Slow as hell
        % http://www.mathworks.com/matlabcentral/fileexchange/44613-two-dimensional-trilateral-filter
        if compute_with_slow_filters == 1
            
            ind = ind+1;
            smoothed{ind}.name = 'Trilateral filter';
            disp(smoothed{ind}.name)
            
            sigmaC = 2;
            epsilon = 0.4;
            
            tic;
            smoothed{ind}.data = trilateralFilter(im, sigmaC, epsilon);
            smoothed{ind}.timing = toc;
            smoothed{ind}.param = [sigmaC epsilon];
    
        end
        