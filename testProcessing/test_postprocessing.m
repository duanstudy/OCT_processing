function test_postprocessing()

    %% Add paths
        
        % Tip: with "Ctrl+Shift+Enter" you can run this code cell-by-cell
    
        close all
        
        curr_path = mfilename('fullpath');
        [curr_dir,filename,ext] = fileparts(curr_path);
        if isempty(curr_dir); curr_dir = pwd; end
        cd(curr_dir)
                    
        % add folders to Matlab path so that their functions are found
        addpath(fullfile(curr_dir, '..', 'utils'))
        addpath(fullfile(curr_dir, 'fast-guided-filter-code-v1'))
        addpath(fullfile(curr_dir, 'BM3D'))
        addpath(fullfile(curr_dir, '..', 'BM4D'))        
        addpath(fullfile(curr_dir, '..', 'L0smoothing'))
        
    %% INPUT

        load('testFrame.mat');
        % easier variable names
        raw = testFrame_raw;
        im = testFrame_BM4D;
        clear('testFrame_BM4D', 'testFrame_BM4D')        
    
    %% DENOISING    
        
        % Process with different filters
        denoised = compare_denoising(im);
        
        % Plot
        titleStr = ('Denoising');
        inputStr = ('Raw');
        plot_Filtering(raw, denoised, titleStr, inputStr)
        
    
    %% EDGE-AWARE SMOOTHING
    
        % Process with different filters
        denoised_im = denoised{1}.data;
        smoothed = compare_edgeAwareSmoothing(denoised_im);
        
        % Plot
        titleStr = ('Edge-Aware Smoothing');
        inputStr = ('BM3D');
        plot_Filtering(im, smoothed, titleStr, inputStr)

    %% CONTRAST ENHANCEMENT    
    
        % Process with different filters
        % TODO! Do a selector with the name that gives you the correct
        % index
        final_smoothed = smoothed{2}.data;
        contrast = compare_contrastEnhancement(final_smoothed);
        
        % Plot
        titleStr = ('Contrast Enhancement');
        inputStr = ('Guided + L0');
        plot_Filtering(final_smoothed, contrast, titleStr, inputStr)
     
    %% (Cascaded) Edge-Aware Smoothing
    
        % Now again we can try ghetto solutions with brute force, and
        % smooth the CLAHEed version and see how things look, which might
        % be good for developing a intuition for this
        
        clahe = contrast{1}.data;
        smoothed_clahe = compare_edgeAwareSmoothing(clahe);
        
        titleStr = ('Cascaded Edge-Aware Smoothing');
        inputStr = ('CLAHE');
        plot_Filtering(clahe, smoothed_clahe, titleStr, inputStr)
        