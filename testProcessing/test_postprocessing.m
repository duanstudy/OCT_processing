function test_postprocessing()

    %% Add paths
        
        % Tip: with "Ctrl+Shift+Enter" you can run this code cell-by-cell
    
        close all
        
        curr_path = mfilename('fullpath');
        [curr_dir,filename,ext] = fileparts(curr_path);
        if isempty(curr_dir); curr_dir = pwd; end
        cd(curr_dir)
                    
        % add folders to Matlab path so that their functions are found
        
        addpath(fullfile(curr_dir, 'fast-guided-filter-code-v1'))
        addpath(fullfile(curr_dir, 'BM3D'))
        addpath(fullfile(curr_dir, 'coherenceFilterToolbox'))
        addpath(fullfile(curr_dir, 'FAST_NLM'))
        addpath(fullfile(curr_dir, 'RobustBilateralFilter'))
        addpath(fullfile(curr_dir, 'trilateralFilter'))
        
        addpath(fullfile(curr_dir, '..', 'BM4D'))        
        addpath(fullfile(curr_dir, '..', 'L0smoothing'))
        addpath(fullfile(curr_dir, '..', 'utils'))
        
    %% INPUT

        % Now we have two types of test cases:
        
        % 1) Where the ground truth / noiseless image is not known,
        %    which is the case typically when you acquire images without
        %    massive averaging and multiframe reconstruction
        
        % 2) Target is provided from averaging allowing us to quantify
        %    the quality of the denoising. The averaged image is provided
        %    as part of the paper by Lyuan Fan et al. (2016)
        %    Leyuan Fang, Shutao Li, David Cunefare and Sina Farsiu, 
        %   "Segmentation Based Sparse Reconstruction of Optical Coherence Tomography Images" 
        %   IEEE Transactions on Medical Imaging, https://doi.org/10.1109/TMI.2016.2611503
        %   https://sites.google.com/site/leyuanfang/
        
        without_target = 0;
        process_subwindow = 0; % speeds up the computations
        % zoom_in = 0; % TODO for display
        
        if without_target == 1    
            load('testFrame.mat');       
            raw = testFrame_raw;
            im = testFrame_BM4D;
            clear('testFrame_BM4D', 'testFrame_BM4D')      
            target = [];
            
        else
            load('testFrame_with_target.mat');
            raw = test;
            im = average;
            clear('test', 'average')     
            target = im;
            
        end
        
        y1 = 121; y2 = 320;
        x1 = 335; x2 = 534;
        
        if process_subwindow == 1
            
            % note the matrix notation, y is before x
            raw = raw(y1:y2, x1:x2);
            im = im(y1:y2, x1:x2);
            target = target(y1:y2, x1:x2);
        end
            
    
    %% DENOISING    
        
        % Process with different filters
        denoised = compare_denoising(im);
        
        % Plot
        titleStr = ('Denoising');
        inputStr = ('Raw');
        plot_Filtering(raw, denoised, titleStr, inputStr, without_target, target)
        
        
    %% DECOMPOSITION
    
        [base_ind, base_name] = find_index_for_name(denoised, 'BM3D');
        [final_ind, final_name] = find_index_for_name(denoised, 'BM3D Cascaded Residual + L0');
        decomp_filt = decompose_OCT(raw, denoised{base_ind}.data, denoised{final_ind}.data);
        
        % Plot
        titleStr = ('Decomposition Filtering');
        inputStr = ('Base CLAHE');
        [decomp_ind, decomp_name] = find_index_for_name(denoised, 'Base CLAHE');
        
        plot_Filtering(denoised{final_ind}.data, decomp_filt, titleStr, inputStr, without_target, target)
        
    
    %% EDGE-AWARE SMOOTHING
    
        % Process with different filters
        desired_input_name_EAR = 'Base CLAHE'; % picking the desired input from previous block
        [desired_ind, desired_input_name_EAR] = find_index_for_name(decomp_filt, desired_input_name_EAR);
        smoothed = compare_edgeAwareSmoothing(decomp_filt{desired_ind}.data, 'denoised');
        
        % Plot
        titleStr = 'Edge-Aware Smoothing';
        inputStr = desired_input_name_EAR;
        plot_Filtering(decomp_filt{desired_ind}.data, smoothed, titleStr, inputStr, without_target, target)

    %% CONTRAST ENHANCEMENT    
    
        % Process with different filters
        desired_input_name_contrast = 'L0 Gradient Smoothing'; % picking the desired input from previous block
        [desired_ind, desired_input_name_contrast] = find_index_for_name(smoothed, desired_input_name_contrast);        
        contrast = compare_contrastEnhancement(smoothed{desired_ind}.data);
        
        % Plot
        titleStr = 'Contrast Enhancement';
        inputStr = [desired_input_name_EAR, '+', desired_input_name_contrast];
        plot_Filtering(smoothed{desired_ind}.data, contrast, titleStr, inputStr, without_target, target)
     
    %% (Cascaded) Edge-Aware Smoothing
    
        % Now again we can try ghetto solutions with brute force, and
        % smooth the CLAHEed version and see how things look, which might
        % be good for developing a intuition for this
        
        clahe = contrast{1}.data;
        smoothed_clahe = compare_edgeAwareSmoothing(clahe, 'clahe');
        
        titleStr = 'Cascaded Edge-Aware Smoothing';
        inputStr = 'CLAHE';
        plot_Filtering(clahe, smoothed_clahe, titleStr, inputStr, without_target, target)
        