function decomp_filt = decompose_OCT(raw, denoised_smooth, denoised_sharp)

    ind = 0;    
    raw = norm_image_for_display(raw, 0);

    %{
    disp([min(raw(:)) max(raw(:)) ...
            min(denoised_smooth(:)) max(denoised_smooth(:)) ...
            min(denoised_sharp(:)) max(denoised_sharp(:))])
    %}

    % create the three components
    base = denoised_smooth;
    details = denoised_sharp - denoised_smooth;
    noise = raw - denoised_sharp;   
        
    %% Boost the base layer with CLAHE
    
        ind = ind+1;
        decomp_filt{ind}.name = 'Base CLAHE';

        tic;
        clipLimit = 0.01; % the larger, more stronger effect
        decomp_filt{ind}.data = CLAHE_wrapper(base, clipLimit);
        decomp_filt{ind}.data = decomp_filt{ind}.data + details;
        decomp_filt{ind}.timing = toc;
        decomp_filt{ind}.param = [clipLimit];
    
    %% Unsharpen Mask (for detail layer)
    
        ind = ind+1;
        decomp_filt{ind}.name = 'Base CLAHE + Unsharpening Mask)';

        tic;        
        decomp_filt{ind}.data = imsharpen(details,'Radius',4,'Amount',1);
        decomp_filt{ind}.data = decomp_filt{ind}.data + decomp_filt{ind-1}.data;
        decomp_filt{ind}.timing = toc;
        decomp_filt{ind}.param = [];
    
    
    %% FIGURE
    % fig = figure();
    
        %{
        rows = 3;
        cols = 3;
        
        indP = 0;
        
        indP = indP + 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow(base, []); colorbar
            tit(indP) = title('Base');
        
        indP = indP + 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow(details, []); colorbar
            tit(indP) = title('Detail');
        
        indP = indP + 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow(noise, []); colorbar
            tit(indP) = title('Noise');
            
        indP = indP + 1;
        ind = 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow(decomp_filt{ind}.data, []); colorbar
            tit(indP) = title(decomp_filt{ind}.name);
        
        indP = indP + 1;        
        sp(indP) = subplot(rows,cols,indP);
            imshow(decomp_filt{ind}.data+details, []); colorbar
            tit(indP) = title([decomp_filt{ind}.name, '+Detail']);
            
        indP = indP + 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow((decomp_filt{ind}.data+details)-base, []); colorbar
            tit(indP) = title(['(', decomp_filt{ind}.name, '+Detail) - Base']);
            
        indP = indP + 1;
        ind = 2;
        sp(indP) = subplot(rows,cols,indP);
            imshow(decomp_filt{ind}.data, []); colorbar
            tit(indP) = title(decomp_filt{ind}.name);
        
        indP = indP + 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow(decomp_filt{ind}.data+decomp_filt{ind-1}.data, []); colorbar
            tit(indP) = title([decomp_filt{ind}.name, '+Base CLAHE']);
            
        indP = indP + 1;
        sp(indP) = subplot(rows,cols,indP);
            imshow((decomp_filt{ind}.data+decomp_filt{ind-1}.data)-base, []); colorbar
            tit(indP) = title(['(', decomp_filt{ind}.name, '+Base CLAHE) - Base']);
        
        set(tit, 'FontSize', 8)
        %}