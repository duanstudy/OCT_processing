function FinalImage = import_tiff_stack(path_for_filename)

    % Matlab TIFF stack reading could be better, see:
    % http://www.matlabtips.com/how-to-load-tiff-stacks-fast-really-fast/
    
    InfoImage=imfinfo(path_for_filename);
    mImage=InfoImage(1).Width;
    nImage=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    FinalImage=zeros(nImage,mImage,NumberImages,'uint16');

    for i=1:NumberImages
       FinalImage(:,:,i)=imread(path_for_filename,'Index',i,'Info',InfoImage);
    end
    
    FinalImage = double(FinalImage);


    