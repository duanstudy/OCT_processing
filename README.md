# OCT_processing

`git clone https://github.com/petteriTeikari/OCT_processing`

## Usage

1) Get some example .img data to `/data' folder
2) Run `process_folder_of_OCT_scans.m`
3) This will process all the .img files found from `/data` folder with the associated custom croppings

### Custom cropping

Now we are computing A-scan(s) from OCT cube so you would like to specify which A-scan you would like to use that you can do [there](https://github.com/petteriTeikari/OCT_processing/blob/master/data/A_scan_crops.txt) which is just a tab-delimited text file that can be auto-generated using [update_A_scan_ROI.m](https://github.com/petteriTeikari/OCT_processing/blob/master/update_A_scan_ROI.m) based on the fixed values defined in [read_config.m](https://github.com/petteriTeikari/OCT_processing/blob/master/read_config.m). 

The function `update_A_scan_ROI.m` is however called on every run of [process_folder_of_OCT_scans.m](https://github.com/petteriTeikari/OCT_processing/blob/master/process_folder_of_OCT_scans.m), and if you add new files to `data` it should initialize them with the default values, and you can later modify them manually if you for example find the coordinates using ImageJ.

At the moment the right vs. left eye is determined from filename, if the filename contains OD or OS (not case-sensitive). If the filename does not contain that, the pipeline has no idea from which eye the scan was from.

## Sample processing results

Processing pipeline with the raw 8-bit .img Zeiss OCT input, followed by BM4D Denoising in LOG domain (OCT noise is multiplicative). (2nd row) Despeckling with L0 Smoothing which is used for more robust peak finding, while the actual peak value is read from the BM4D Denoised cube (well frame in our case)

![Processing](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab.png "Logo Title Text 1")

The same with CLAHE in ImageJ/FIJI with a maximum slope of 2 to enhance the contrast:

![Processing CLAHE](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab_CLAHE.png "Logo Title Text 1")

### Error case

When you pick improper A-scan, the canonical 2-peak characteristic is missing and when the denoised signal for peak finding is not smooth enough, the [Matlab findpeaks](https://uk.mathworks.com/help/signal/ref/findpeaks.html) just finds two peaks very close to each other:

![Error case](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab_peakFailure.png "Logo Title Text 1")
