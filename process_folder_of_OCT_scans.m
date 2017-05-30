function process_folder_of_OCT_scans(directory, oct_extension)

    %% HOUSEKEEPING

        close all
    
        if nargin == 0
            directory = fullfile('.', 'data');
            oct_extension = 'img'; % TODO! update if you have mixed exts
        end
        
        curr_path = mfilename('fullpath');
        [curr_dir,filename,ext] = fileparts(curr_path);
        if isempty(curr_dir); curr_dir = pwd; end
        cd(curr_dir)
                    
        % add folders to Matlab path so that their functions are found
        addpath(fullfile(curr_dir, 'BM4D'))
        addpath(fullfile(curr_dir, 'utils'))
        addpath(fullfile(curr_dir, 'L0smoothing'))
        addpath(fullfile(curr_dir, 'matlabsoftware-2013', 'ImageQualityFeatures'))
        addpath(fullfile(curr_dir, 'matlabsoftware-2013', 'DespeckleFilters'))
        
        config = read_config();
                
    
    %% Get file listing
    
        s = dir(fullfile(directory, ['*.', oct_extension]));
        file_list = {s.name}';
        no_of_files = length(file_list);
        disp([' - found ', num2str(no_of_files), ' image files'])
        
        % check if there are new files added to the folder since last run
        % that have missing custom coordinates from the
        % "config.file_listing_txt"
        update_A_scan_ROI(directory, file_list, oct_extension)        
        
        % get also the list of A scan coordinates from the text file
        file_specs = get_file_specs(directory, config.file_listing_txt);       

        
    %% Process all of the files from the folder
    
        for file = 1 : no_of_files
            
            % check first if the file has been already denoised, so that we
            % don't have to do it again (remove the old denoised file from
            % the folder if you want to re-denoise with other method or
            % with other parameters
            ext_full = ['.', oct_extension]; % well just with the dot
            stripped_filename = strrep(file_list{file}, ext_full, '');
            denoised_filename = fullfile(directory, [stripped_filename, config.denoised_ending]);
            
            disp(['Reading the file "', file_list{file}, '"'])
            im = importZeissIMG(directory, file_list{file}); % Read the .img file in
            
            if exist(denoised_filename, 'file') == 2
                                
                disp(['The file "', file_list{file}, '" has already been denoised, skipping the denoising part'])
                % Read the .tif file in
                Z = import_tiff_stack(denoised_filename);
                
            else                
                
                % Pre-processing Image Restoration part
                % Denoises the whole cube (takes some time)
                % e.g. "1024x512x128px" Basic estimate completed (1265.4s) 
                disp([' Denoising the file "', file_list{file}, '"'])
                output = 'double';
                [Z, sigmaEst, PSNR, SSIM] = BM4D_cubeWrapper(im, output);
                save_in_parfor_loop(Z, denoised_filename)                
                
                % Save to disk as .TIFF
                % TODO! if you want .nrrd, .MAT,  .hdf5, or OME-TIFF, etc.
                bitDepth = 16; % you can save some disk space with 8-bit                                
                export_stack_toDisk(denoised_filename, Z, bitDepth)

            end
            
            % The faster part that extracts A-scans based on your desired
            % coordinates
            try
                coords_ind = check_if_coords(file_list{file}, file_specs.filename);
            catch err                
                if strcmp(err.identifier, 'MATLAB:table:UnrecognizedVarName')
                    % for now some reason, the headers are gone and we
                    % cannot reference with the field names?
                    error(['header fields are just as var1 / var2 / var3 / etc.,', ...
                           'they would need to have actually the variable names', ...
                           'You probably have error when writing the text file with too many columns, extra tabs or something'])                    
                else
                    err
                end
            end
            
            % check the filename for which eye
            if ~isempty(strfind(lower(file_list{file}), 'od'))
                disp('OD found from filename, RIGHT EYE')
                eye = 'right';
            elseif ~isempty(strfind(lower(file_list{file}), 'os'))
                disp('OS found from filename, LEFT EYE')
                eye = 'left';
            else
                warning('OD nor OS was found from the filename so the program now does not know which eye the scan was from, using RIGHT EYE coordinates')
                eye = 'right';
            end
            
            % Algorithm here to override the manually defined coordinates
            % Placeholder atm
            coords_ind = find_coords_from_cube(Z, coords_ind, file_specs, eye);
            
            if ~isempty(coords_ind)
                [Z_crop, A_scan, x, z] = crop_the_cube(Z, coords_ind, file_specs, eye);
            else
                warning(['No custom cropping coordinates found for file = "', ...
                        file_list{file}, '", how is that possible?'])
                [Z_crop, A_scan, x, z] = crop_the_cube(Z, coords_ind, file_specs, eye);
            end
            
            % Save the cropped cube, you could do further
            % denoising/smoothing at this point a lot faster than on the
            % first step with the full cube.
            bitDepth = 16; % you can save some disk space with 8-bit                                
            export_stack_toDisk(strrep(denoised_filename, '.tif', '_crop.tif'), Z_crop, bitDepth)
            
            % Denoise the A-scan (from 1D line)            
            A_scan_denoised = smooth(A_scan, 0.01, 'loess');            
            
            % Test to denoise just the single frame and see the diff.
            frame = double(Z(:,:,z));
            
            % Despeckle with a simple algorithm, https://doi.org/10.1016/j.cmpb.2014.01.018
            frame_denoised = DsFlsmv(frame, [3 3], 5);
            
            % L0 Smoothing            
            logOffset = 0.1; lambdaS = 1e-4;
            [frame_denoised, ~, ~, ~] = enhance_logSmooothingFilter(frame_denoised, logOffset, lambdaS);                        
            A_scan_denoised_frame = frame_denoised(:,x);
            
            % Further smooth with LOESS
            % Note! Now the smoothing parameters are hand set which is
            % quite suboptimal in the end
            A_scan_denoised_2D_1D = smooth(A_scan_denoised_frame, 0.01, 'loess');
            
            % Normalize, export, compare peak ratios
            [A_scan, A_scan_denoised, ...
                A_scan_denoised_frame, A_scan_denoised_2D_1D, ...
                peak_1, peak_2, locs_peaks, ratio] = ...
                compare_A_scans(A_scan, A_scan_denoised, ...
                            A_scan_denoised_frame, A_scan_denoised_2D_1D, ...
                            directory, stripped_filename);
        
            peak_1_8bit = double(im(locs_peaks(1),x,z));
            peak_2_8bit = double(im(locs_peaks(2),x,z));
            ratio_8bit =  peak_2_8bit/ peak_1_8bit;
            quantization_step = 1 / (2^8);
                        
            % Write results on disk
            write_ratio_to_disk(peak_1, peak_2, locs_peaks, ratio, peak_1_8bit, peak_2_8bit, ratio_8bit, ...
                quantization_step, z, x, directory, stripped_filename)            
                        
            % OPTIONAL VISUALIZATION
            z_of_interest = z;
            visualize_ON = 1;
            
            
            if visualize_ON == 1 
                
                
                close all
                scrsz = get(0,'ScreenSize');
                fig = figure('Color', 'w', 'Name', 'OCT A-Scan');
                    set(fig, 'Position', [0.1*scrsz(3) 0.1*scrsz(4) 0.8*scrsz(3) 0.8*scrsz(4)])
                
                rows = 2; cols = 3;
                
                % normalize for visualization
                in = double(im(:,:,z_of_interest));
                in = in - min(in(:));
                in = in / max(in(:));
                
                denoised = Z(:,:,z_of_interest);
                denoised = denoised - min(denoised(:));
                denoised = denoised / max(denoised(:));
                
                frame_denoised = frame_denoised - min(frame_denoised(:));
                frame_denoised = frame_denoised / max(frame_denoised(:));
                
                subplot(rows,cols,1); imshow(in, [])
                title('Input'); colorbar
                subplot(rows,cols,2); imshow(denoised, [])
                title('BM4D Denoised'); colorbar
                subplot(rows,cols,3); imshow(in-denoised, [])
                title('Noise Residual (In-BM4D)'); colorbar
                drawnow
                
                subplot(rows,cols,4); imshow(frame_denoised, [])
                title('FrameDenoising'); colorbar; hold on
                line([x x], [1 size(frame_denoised,1)], 'Color', 'r')
                drawnow
                
                subplot(rows,cols,5); imshow(denoised-frame_denoised, [])
                title('Noise Residual (BM4D-FrameDenoising)'); colorbar
                drawnow
                
                % A-Scan Comparison
                subplot(rows,cols,6); hold on
                y = linspace(1, length(A_scan), length(A_scan));
                p = plot(y, A_scan, ...
                         y, A_scan_denoised, ...
                         y, A_scan_denoised_frame, 'k', ...
                         y, A_scan_denoised_2D_1D);
                set(p(3), 'LineWidth', 1)
                
                xlim([0 length(y)])
                                
                % Give also the input peaks in the input UINT8 type
                strtitle = sprintf('%s\n%s\n%s', 'A-scan', ...
                                    ['peak1_i_n = ', num2str(im(locs_peaks(1),x,z)), ...
                                    ', peak2_i_n = ', num2str(im(locs_peaks(2),x,z))], ...
                                    ['8-bit ratio = ', num2str(ratio_8bit,3), ...
                                    ', quantization step = ', num2str(quantization_step,3)]);
                                
                tit = title(strtitle);
                set(tit, 'FontSize', 8)
                
                leg = legend(['A-scan (BM4D), ratio = ', num2str(ratio,3)], 'A-scan (1D Denoising)', ...
                             'A-scan (2D Denoising)', 'A-scan (2D+1D Denoising)');
                    legend('boxoff')
                % uistack(p(3),'top');
                
                % mark the peaks
                p_peaks = plot(locs_peaks(1), peak_1, '^', locs_peaks(2), peak_2, '^');
                set(p_peaks, 'MarkerFaceColor', 'k')
                drawnow
                hold off
                
                saveOn = 0;
                if saveOn == 1
                    filename = strrep(file_list{file}, '.img', '');
                    saveas(fig, fullfile(directory, filename), 'png')
                end
            end
            
        end
        
    
    
    function [A_scan, A_scan_denoised, A_scan_denoised_frame, A_scan_denoised_2D_1D, ...
            peak_1, peak_2, locs_peaks, ratio] = ...
            compare_A_scans(A_scan, A_scan_denoised, ...
                    A_scan_denoised_frame, A_scan_denoised_2D_1D, ...
                    directory, stripped_filename)

        % normalize the A_scan
        A_scan_denoised = A_scan_denoised - min(A_scan_denoised(:));
        A_scan_denoised = A_scan_denoised / max(A_scan_denoised(:));   

        % normalize the A_scan
        A_scan_denoised_frame = A_scan_denoised_frame - min(A_scan_denoised_frame(:));
        A_scan_denoised_frame = A_scan_denoised_frame / max(A_scan_denoised_frame(:));    

        % normalize the A_scan        
        A_scan_denoised_2D_1D = A_scan_denoised_2D_1D - min(A_scan_denoised_2D_1D(:));
        A_scan_denoised_2D_1D = A_scan_denoised_2D_1D / max(A_scan_denoised_2D_1D(:));
        
        % save the A-scan
        dlmwrite(fullfile(directory, [stripped_filename, '_Ascan_raw.txt']), A_scan)
        dlmwrite(fullfile(directory, [stripped_filename, '_Ascan_2D_denoised.txt']), A_scan_denoised_frame)
            % TODO! Maybe save some metadata if wanted at some point?    
        
        % [peak_1, peak_2, locs_peaks, ratio] = find_intensity_peaks(A_scan_denoised_frame, A_scan_denoised_2D_1D);
        [peak_1, peak_2, locs_peaks, ratio] = find_intensity_peaks(A_scan, A_scan_denoised_frame);
        
            % TODO! You could try different combinations, and you could do
            % systematic sensitivity analysis of how these parameters
            % actually affect your final estimates of the intensity ratio
            
            
    function [peak_1, peak_2, locs_peaks, ratio] = find_intensity_peaks(A_scan, A_Scan_denoised)
        
        % Quite dumb algorithm in the end working for your canonical OCT
        % profile for sure. Think of something more robust if this start
        % failing with pathological eyes or something
        
        % Use the denoised version for peak location, and get the values
        % from the raw non-denoised version
        
        x = linspace(1, length(A_scan), length(A_scan))';
        [pks,locs] = findpeaks(A_Scan_denoised,x);
        [pks,I] = sort(pks, 'descend');
        locs = locs(I);
        
        locs_peaks = [locs(1) locs(2)];
        
        peak_1 = A_scan(locs_peaks(1));
        peak_2 = A_scan(locs_peaks(2));
        ratio = peak_2 / peak_1;
            
        % TODO! If you feel like, you could add some uncertainty estimation with
        % Monte Carlo sampling or something similar as if your final
        % statistical analysis is done on the ratio, then if you take this
        % ratio as the "gold standard" it may lead to problems if this is
        % rather sensitivite to the actual denoising of the A-scan
        
        
    function [Z_crop, A_scan, x, z] = crop_the_cube(Z, coords_ind, file_specs, eye)
        
       
        if isempty(coords_ind)
            disp('Using the default crop coordinates')
            config = read_config();
            z_min = config.crop_z_window(1);
            z_max = config.crop_z_window(2);
            left_min = config.crop_left_eye(1);
            left_max = config.crop_left_eye(2);
            right_min = config.crop_right_eye(1);
            right_max = config.crop_right_eye(2);
        else
            z_min = file_specs.z_min(coords_ind);
            z_max = file_specs.z_max(coords_ind);
            left_min = file_specs.left_min(coords_ind);
            left_max = file_specs.left_max(coords_ind);
            right_min = file_specs.right_min(coords_ind);
            right_max = file_specs.right_max(coords_ind);
        end
        
        if strcmp(eye, 'left')
            x_min = left_min;
            x_max = left_max;
            
        elseif strcmp(eye, 'right')
            x_min = right_min;
            x_max = right_max;
            
        else
            error(['Typo with your eye, it is now: "', eye, '"'])
        end
        
        % The actual crop
        Z_crop = Z(:,x_min:x_max,z_min:z_max);
        
        % One A-scan that is the one in the middle of the x and z-range
        x = round((x_min + x_max)/2);
        z = round((z_min + z_max)/2);
        A_scan = Z(:,x,z);
        
        % normalize the A_scan
        A_scan = A_scan - min(A_scan(:));
        A_scan = A_scan / max(A_scan(:));
        
        % TODO! There is possibly quite a lot of empty space left still on
        % y-axis direction (note! in Matlab the first dimension is y)
        

    function coords_ind = find_coords_from_cube(Z, coords_ind, file_specs, eye)
        
        disp('   Placeholder here if you want to do automated ROI localization from image')
        
       
    function write_ratio_to_disk(peak_1, peak_2, locs_peaks, ratio, peak_1_8bit, peak_2_8bit, ratio_8bit, quantization_step, z, x, directory, stripped_filename)
        
        fileOut = fullfile(directory, [stripped_filename, 'ratio.txt']);
        fid = fopen(fileOut, 'wt');
        
        fprintf(fid, '%s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s\t %s \n', 'filename', 'peak_1', 'peak_2', 'ratio_BM4D', ...
                                     'peak_1_8bit', 'peak_2_8bit','ratio_8bit', 'quantization_step', 'z_AScan', 'x_AScan');  % header        
                                 
 
        fprintf(fid,'%s\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d\t %d \n', stripped_filename, ...
                                  peak_1, peak_2, ratio, ...
                                  peak_1_8bit, peak_2_8bit, ratio_8bit,...
                                  quantization_step, z, x);
        
        fclose(fid);
        

        
    function save_in_parfor_loop(Z, filename)
        
        disp(['  Saving as double-precision .mat: "', strrep(filename, '.tif', '.mat'), '"'])
        save(strrep(filename, '.tif', '.mat'), 'Z')
        
    
    