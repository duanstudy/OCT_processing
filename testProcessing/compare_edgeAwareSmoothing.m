function smoothed = compare_edgeAwareSmoothing(im)    
    
    ind = 0;
    
    %% GUIDED FILTER
    
        ind = ind+1;    
        % http://kaiminghe.com/eccv10/
        % http://www.mathworks.com/help/images/ref/imguidedfilter.html
        smoothed{ind}.name = 'Guided Filter';

        % see e.g. Fig 2 of http://dx.doi.org/10.1109/TPAMI.2012.213
        epsilon = 1^2; % regularization parameter: eps
        win_size = 2; % local window radius
        s = 1; % 1, no subsampling
        tic;
        guide = im; % using image itself, when smoothing
        smoothed{ind}.data = fastguidedfilter(im, guide, win_size, epsilon, s);
        smoothed{ind}.timing = toc;
        smoothed{ind}.param = [epsilon win_size];
    
    %% L0 Gradient Smoothing
    
        ind = ind+1;  
        smoothed{ind}.name = 'L0 Gradient Smoothing';
        logOffset = 0.2; 
        lambdaS = 1e-5;
        tic;
        [smoothed{ind}.data, ~, ~, ~] = ...
            enhance_logSmooothingFilter(im, logOffset, lambdaS);
        smoothed{ind}.timing = toc;
        smoothed{ind}.param = [logOffset lambdaS];
 