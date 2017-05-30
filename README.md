# OCT_processing

`git clone https://github.com/petteriTeikari/OCT_processing`

## Usage

1) Get some example .img data to `/data' folder
2) Run `process_folder_of_OCT_scans.m`
3) This will process all the .img files found from `/data` folder with the associated custom croppings

## Sample processing results

Processing pipeline with the raw 8-bit .img Zeiss OCT input, followed by BM4D Denoising in LOG domain (OCT noise is multiplicative). (2nd row) Despeckling with L0 Smoothing which is used for more robust peak finding, while the actual peak value is read from the BM4D Denoised cube (well frame in our case)

![Processing](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab.png "Logo Title Text 1")

The same with CLAHE in ImageJ/FIJI with a maximum slope of 2 to enhance the contrast:

![Processing CLAHE](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab_CLAHE.png "Logo Title Text 1")

### Error case

When you pick improper A-scan, the canonical 2-peak characteristic is missing and when the denoised signal for peak finding is not smooth enough, the [https://uk.mathworks.com/help/signal/ref/findpeaks.html](Matlab findpeaks) just finds two peaks very close to each other:

![Error case](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab_peakFailure.png "Logo Title Text 1")
