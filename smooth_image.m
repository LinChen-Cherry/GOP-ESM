function image_smoothed = smooth_image(image, smooth_type)

switch smooth_type;
    case 'Gauss'
        dic = 5;
        sigma = 1.5;
        gausFilter = fspecial('gaussian', [dic dic], sigm);
        image_smoothed = imfilter(image, gausFilter,'replicate');
        
    case 'PM' % Perona-Malik function (PM)
        iter = 15;
        delta_t = 1/7;
        option = 2;
        kappa = 5;
        image_smoothed = anisodiff2D(image, iter, delta_t, kappa, option);
    
    case 'BL'
        sigmaRange = 0.1*(max(max(image))-min(min(image)));
        sigmaSpatial = min( size(image,1), size(image,2) ) / 16;
        Diameter = 7;
        image_smoothed = double(cv.bilateralFilter(single(image),'Diameter', Diameter, 'SigmaColor', sigmaRange, 'SigmaSpace', sigmaSpatial));
    
    otherwise
        image_smoothed = image;
end

end