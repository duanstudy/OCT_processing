function im = norm_image_for_display(im, scaling_8bit)

    im = double(im);
    im = im - min(im(:));
    im = im / max(im(:));
    
    % easier to interpret the scale, and the residual especially
    if scaling_8bit == 1
        im = im * 255;
    end