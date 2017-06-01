# Post-Processing Testing

Quick testing of different techniques using one OCT (Optical Coherence Tomography) frame

## Usage

Run `test_postprocessing.m`

## Denoising

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/denoising_comparison.png)

_By denoising the residual of the first BM3D and adding the remaining details to the result of the 1st pass, we can have sharper edges with this "ghetto fix" (2nd Column). And for the 3rd column we have taken the residual of 2nd column, and smoothed the residual with L0 gradient smoothing and added that back to 2nd column giving more details to the final image._

See zoomed version of the same filtering:

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/denoising_comparison_zoom.png)

## Decomposition filtering

We can break the image into base, detail and noise like typical in [HDR Tone Mapping](http://cinescopophilia.com/temporally-coherent-local-tone-mapping-of-hdr-video-from-disney-research-hub/)

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/decomposition_plot.png)

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/decomposition_plot_zoom.png)

Now we can independently process the detail layer by applying [Unsharpening Mask](http://thegreyblog.blogspot.co.uk/2011/11/clarity-adjustment-local-contrast-in.html/) to increase sharpness, and boost the base layer with CLAHE mitigating the noise boosting effect.

**NOTE** In ideal case this would be easy if the noise was perfectly separated from the base and the detail layer, but with our simple demo approach we can see that the noise in detail layer has been unfortunately been amplified. In the end the filtering result will depend on the decomposition algorithm used:

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/decomposition.png)

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/decomposition_zoom.png)

Despite of our simple approach, the "Base CLAHE + Detail" filtering looks quite good enhancement without having enhanced too much the noise in the image.

## Edge-Aware Smoothing

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/edgeawaresmoothing_comparison.png)

The zoomed blowout of the same

![alt text](https://github.com/petteriTeikari/OCT_processing/blob/master/testProcessing/images_output/edgeawaresmoothing_comparison_zoom.png)

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




