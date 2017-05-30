# OCT_processing

`git clone https://github.com/petteriTeikari/OCT_processing`

## Usage

1) Get some example .img data to `/data' folder
2) Run `process_folder_of_OCT_scans.m`
3) This will process all the .img files found from `/data` folder with the associated custom croppings

## Sample processing results

Processing pipeline with the raw 8-bit .img Zeiss OCT input, followed by BM4D Denoising. (2nd row) Despeckling with L0 Smoothing which is used for more robust peak finding, while the actual peak value is read from the BM4D Denoised cube (well frame in our case)

![Processing](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab.png "Logo Title Text 1")

The same with CLAHE in ImageJ/FIJI with a maximum slope of 2 to enhance the contrast:

![Processing CLAHE](https://github.com/petteriTeikari/OCT_processing/blob/master/imgs/comparison_BM4D_matlab_CLAHE.png "Logo Title Text 1")
