function plot_Filtering(im, filtered, titleStr, inputStr, without_target, target, scaling_8bit)

    if nargin == 6
        % No Python-style keyword arguments :(
        scaling_8bit = 1;
    end

    fig = figure('Name', titleStr, 'Color', 'w');
                
    scrsz = get(0,'ScreenSize');
        set(fig, 'Position', [0.58*scrsz(3) 0.1*scrsz(4) 0.4*scrsz(3) 0.8*scrsz(4)])
        
    
    rows = 3; % 1) Input, 2) Filter, 3) Residual
    cols = length(filtered);

    for i = 1 : length(filtered)

        % normalize images
        im = norm_image_for_display(im, scaling_8bit);
        filtered{i}.data = norm_image_for_display(filtered{i}.data, scaling_8bit);
        
        % compute metrics
        E_im = compute_entropy(im, scaling_8bit);
        E_filt = compute_entropy(filtered{i}.data, scaling_8bit);
        
        if without_target  == 0
            peakVal = 255;
            [mse, snr, psnr, mssim] = compute_imageQuality(target, filtered{i}.data, peakVal);
            titlestring = sprintf('%s\n%s\n%s', filtered{i}.name, ...
                                  ['E = ', num2str(E_filt, 2), ' bits'], ...
                                  ['PSNR = ', num2str(psnr, 4), ', MSSIM = ', num2str(mssim, 2)]);
            
        else
             titlestring = sprintf('%s\n%s', filtered{i}.name, ...
                                  ['E = ', num2str(E_filt, 2), ' bits']);
        end
        
            % Input
            sp(i) = subplot(rows,cols,i);
            p(i,1) = imshow(im, []);
                tit(i,1) = title([inputStr, ', E = ', num2str(E_im, 2), ' bits']);
                colorbar
                
            % Filtered
            sp(i+cols) = subplot(rows,cols,i+cols);
            p(i,2) = imshow(filtered{i}.data, []);               
                tit(i,2) = title(titlestring);
                lab(i) = xlabel(['t = ', num2str(filtered{i}.timing, 2), ' s']);
                colorbar
                
            % Residual
            sp(i+(2*cols)) = subplot(rows,cols,i+(2*cols));
            p(i,3) = imshow(im - filtered{i}.data, []);
                tit(i,3) = title('Residual'); 
                colorbar

    end
    
    set(tit, 'FontSize', 8)
    set(lab, 'FontSize', 7)
    
% SUBFUNCTIONS

    
function E = compute_entropy(I, scaling_8bit)

    % If you want to compute sample entropy, or approximate entropy
    % you need to add additiona code here

    if scaling_8bit == 1
        max_value = 255;
    else
        max_value = 1;
    end

    % Assume I in the range 0..max_value
    no_of_bins = 256;
    p = hist(I(:), linspace(0, max_value, no_of_bins));  % create histogram
    p(p==0) = []; % remove zero entries that would cause log2 to return NaN
    p = p/numel(I); % normalize histogram to unity
    E = -sum(p.*log2(p)); % entropy definition

    