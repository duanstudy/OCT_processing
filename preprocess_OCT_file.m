function [denoised_cube, A_scan] = preprocess_OCT_file(cube)

    %% HOUSEKEEPING

        % get the path of this .m-file
        curr_path = mfilename('fullpath');
        [curr_dir,filename,ext] = fileparts(curr_path);
        if isempty(curr_dir); curr_dir = pwd; end
        cd(curr_dir)
    
    %% DENOISING 
    
        [Y_BM4D, sigmaEst, PSNR, SSIM] = denoise_BM4Dwrapper(X, 1);