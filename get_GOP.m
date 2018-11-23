function [GOP, mask] = get_GOP(ICur_gray, Handle)

H_all = Handle.H_all;
n_pyrs = Handle.pyr;
size_pad_x = Handle.size_pad_x;
size_pad_y = Handle.size_pad_y;

% pre-warp
image_warped = warp(ICur_gray, H_all{n_pyrs}, size_pad_x(n_pyrs), size_pad_y(n_pyrs));

% denoise
image_smoothed = smooth_image(image_warped, Handle.smooth);

% GOP
image_pyr = get_pyr_image(image_smoothed, n_pyrs);
mask = cell(1, n_pyrs);
GOP = cell(1, n_pyrs);
for n_pyr = 1:n_pyrs
    [GOP{n_pyr}, mask{n_pyr}] = get_GO(image_pyr{n_pyr}, Handle); 
end