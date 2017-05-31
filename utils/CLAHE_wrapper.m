function CLAHE_video = CLAHE_wrapper(video, clipLimit)

    if nargin == 1
        clipLimit = 0.01;
    end

    % normalize
    videoMax = max(video(:));
    video = video / videoMax;
    
    CLAHE_video = zeros(size(video));
    
    for i = 1 : size(video, 3)
        CLAHE_video(:,:,i) = adapthisteq(video(:,:,i),...
            'clipLimit',clipLimit,'Distribution','rayleigh');   
    end
    
    % Scale back
    CLAHE_video = CLAHE_video * videoMax;