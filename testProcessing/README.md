# Post-Processing Testing

Quick testing of different techniques using one OCT (Optical Coherence Tomography) frame

## Usage

Run `test_postprocessing.m`

## Denoising

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/denoising_comparison.png)

_By denoising the residual of the first BM3D and adding the remaining details to the result of the 1st pass, we can have sharper edges with this "ghetto fix"_

## Edge-Aware Smoothing

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/edgeawaresmoothing_comparison.png)

**NOTE!** The scaling is different, even though guided filter seems quite extreme, that is quite low-amplitude noise in the end

## Contrast Enhancement

For filtered CLAHE:

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/clahe_filtered.png)

And for the raw noisy input

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/clahe_raw.png)

### File size

When getting rid of high-spatial frequencies for [DCT transform](https://users.cs.cf.ac.uk/Dave.Marshall/Multimedia/node231.html) used by JPEG format, the filesizes come down considerably when using the highest quality `100` in Matlab:

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/filesize_comparison.png)

_From raw input of 299.1 kB, we get to 120.7 kB with "BM3D cascaded residual + L0", and then from there either 83.2 kB with bilateral filter, 102.5 kB for guided filter, and 94.2 kB with L0 gradient smoothing. So roughly to **31%** of the original size!_

Even if you look at the edge-aware smoothing results and seemingly minimal results of guided filtering for already denoised image, the guided filter put the filesize to 85% of the original size (102.5kB/120.7kB). And depending on the algorithm, this might be useful or not.

Visually for clinician evaluation obviously this does not have much of an effect.

For more on machine learning and compression, I recommend the following excellent review:

Ghahramani, Zoubin. **"Probabilistic machine learning and artificial intelligence."** _Nature_ 521.7553 (2015): 452. [doi: 10.1038/nature14541](https://dx.doi.org/10.1038/nature14541)




