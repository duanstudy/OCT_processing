function testL0Smoothing_2PM_image()

    close all;   
    fileName = mfilename; fullPath = mfilename('fullpath');
    pathCode = strrep(fullPath, fileName, '');
    if ~isempty(pathCode); cd(pathCode); end
    
    im = imread(fullfile('..', 'testData', 'retinal_image.png'));
    
    %% COMPUTE
    
        
        kappaVector = [2];
    
        % image
        
        lambdaVector = [1e-7 1e-6 1e-5 1e-4 1e-3 1e-2];
        
            for i = 1 : length(lambdaVector)
                lambda = lambdaVector(i);
                for j = 1 : length(kappaVector)            
                    kappa = kappaVector(j);
                    tic;
                    disp([i j])
                    S_im{i,j} = L0Smoothing(im, lambda, kappa);
                    tim_im(i,j) = toc;
                    titStr_im{i,j} = ['Im | lambda = ', num2str(lambda), ' | kappa = ', num2str(kappa)];
                end
            end
        

      

    
    %% VISUALIZE
    
        visualize_L0(im, S_im, tim_im, titStr_im)
            % export_fig('im_L0smoothed.png', '-r300', '-a1')
    
   