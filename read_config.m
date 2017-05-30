function config = read_config()

    config.file_listing_txt = 'A_scan_crops.txt';
    config.denoised_ending = '_denoised.tif';
    
    config.crop_z_window = [55 75];
    config.crop_left_eye = [0 150];
    config.crop_right_eye = [362 512];
    