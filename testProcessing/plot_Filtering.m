function plot_Filtering(im, filtered, titleStr, inputStr)

    fig = figure('Name', titleStr, 'Color', 'w');
                
    scrsz = get(0,'ScreenSize');
        set(fig, 'Position', [0.58*scrsz(3) 0.1*scrsz(4) 0.4*scrsz(3) 0.8*scrsz(4)])
        
    
    rows = 3; % 1) Input, 2) Filter, 3) Residual
    cols = length(filtered);

    for i = 1 : length(filtered)

        % normalize images
        im = norm_image_for_display(im);
        filtered{i}.data = norm_image_for_display(filtered{i}.data);
        
            % Input
            sp(i) = subplot(rows,cols,i);
            p(i,1) = imshow(im, []);
                tit(i,1) = title(inputStr);
                colorbar
                
            % Filtered
            sp(i+cols) = subplot(rows,cols,i+cols);
            p(i,2) = imshow(filtered{i}.data, []);
                titlestring = sprintf('%s\n%s', filtered{i}.name, filtered{i}.param);
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
function im = norm_image_for_display(im)

    im = double(im);
    im = im - min(im(:));
    im = im / max(im(:));