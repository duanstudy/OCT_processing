function [imLog10_S_Lin, imLog10_S, imLog10, imScaled] = enhance_logSmooothingFilter(im, logOffset, lambdaS)

    % Scale in Linear domain
    imScaled = im / max(im(:));
    imScaled = imScaled + logOffset;

    % Log10
    imLog10 = log10(imScaled);
    imLog10 = imLog10 - min(imLog10(:));
    imLog10 = imLog10 / max(imLog10(:));

    % Smooth
    kappa = 2;
    noOfSlices = size(imLog10, 3);
    if noOfSlices > 1
        imLog10_S = L0Smoothing_stack(imLog10, lambdaS, kappa);
    else
        imLog10_S = L0Smoothing_PT(imLog10, lambdaS, kappa);
    end
             
    % Convert back to Linear
    imLog10_S_Lin = 10 .^ imLog10_S;
    imLog10_S_Lin = imLog10_S_Lin / max(imLog10_S_Lin(:));