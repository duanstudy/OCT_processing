function export_stack_toDisk(fileOut, im, bitDepth)

    if nargin == 2
        % Default bit depth when called without input arguments
        bitDepth = 8;
    end

    % Make sure that the input is double
    im = double(im);
    
    % Normalize
    im = im - min(im(:));        
    im = im / max(im(:));
    
    % display on command window
    disp(['   .. Writing ', fileOut, ' to disk as multilayer ', num2str(bitDepth), '-bit TIF'])

    % Check the bit depth
    if bitDepth == 8
        imOut = uint8(im * 255);
    elseif bitDepth == 16
        imOut = uint16(im * 65535);
    elseif bitDepth == 32
                
        % http://www.mathworks.com/matlabcentral/answers/115249-save-images-as-tif-32-bits-by-using-imwrite
        imOut = uint32(im * (2^32 -1));
        
        % This is a direct interface to libtiff
        t = Tiff(fileOut, 'w');
        
        % Setup tags
        % Lots of info here:
        % http://www.mathworks.com/help/matlab/ref/tiffclass.html
        tagstruct.ImageLength     = size(imOut,1);
        tagstruct.ImageWidth      = size(imOut,2);
        tagstruct.Photometric     = Tiff.Photometric.MinIsBlack;
        tagstruct.BitsPerSample   = 32;
        tagstruct.SamplesPerPixel = size(imOut,3);
        tagstruct.RowsPerStrip    = 16;
        tagstruct.PlanarConfiguration = Tiff.PlanarConfiguration.Chunky;
        tagstruct.Software        = 'MATLAB';
        t.setTag(tagstruct)
        
        t.write(imOut);
        t.close();
        
    else
        error(['bitDepth of ', num2str(bitDepth), ' not supported! (only 8/16/32 bit are)'])
    end

    if bitDepth ~= 32

        % First slice
        imwrite(imOut(:,:,1), fileOut, 'tif', 'Compression', 'lzw')

        % Go through the other slices
        for k = 2:size(imOut,3)
            imwrite(imOut(:,:,k), fileOut, 'tif', 'writemode', 'append', 'Compression', 'lzw');
        end
        
    end
       