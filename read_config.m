function config = read_config()

    config.file_listing_txt = 'A_scan_crops.txt';
    config.denoised_ending = '_denoised.tif';
    
    
    % You can simply set the min and max the same if you don't need the
    % rough cropping at all
    config.crop_z_window = [55 75];
    config.crop_left_eye = [1 150];
    config.crop_right_eye = [362 512];
    