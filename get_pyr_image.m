function image_pyr = get_pyr_image(image, n_pyrs)    
    % the bottom layer
    image_pyr{n_pyrs} = image;
    
    % upper layers
    for n_pyr = n_pyrs-1:-1:1
        image_pyr{n_pyr} = impyramid(image_pyr{n_pyr+1}, 'reduce');
    end

end