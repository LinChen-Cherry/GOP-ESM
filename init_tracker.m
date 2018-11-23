% Initialization for first image
path_to_images = [dataset_path '/' seq.name '/'];
file_name = seq.file_name;
image_format = seq.image_format;
length_number = seq.length_number; % size of number characters in image name
nb_first_image = seq.nb_first_image;
nb_last_image = seq.nb_last_image;
nb_image = nb_first_image;
scale = tracker.scale;
pad = tracker.pad;
loads_image;

% Template's size (in pixels, MUST BE PAIR)
n_pyrs = tracker.pyr;
Nx_all = tracker.N;
size_x_org = size(ICur_gray,2);
size_y_org = size(ICur_gray,1);
size_template_x = zeros(n_pyrs,1);
size_template_y = zeros(n_pyrs,1);
corners = cell(n_pyrs,1);
size_x = zeros(n_pyrs,1);
size_y = zeros(n_pyrs,1);

ground_truth_file = [dataset_path '/' seq.name '.txt'];
data = importdata(ground_truth_file);
gt = data.data * scale;
corners_org = reshape(data.data(1,:), 2, 4)' * scale;
image_pyr = get_pyr_image(ICur_gray, n_pyrs);

size_template_x_all = ((corners_org(2,1)-corners_org(1,1)+corners_org(3,1)-corners_org(4,1))/2);
size_template_y_all = ((corners_org(4,2)-corners_org(1,2)+corners_org(3,2)-corners_org(2,2))/2); 
template_ratio = size_template_x_all / size_template_y_all;
size_template_x_all = floor(sqrt(Nx_all * template_ratio));
size_template_y_all = floor(Nx_all / size_template_x_all);        
size_template_x_pyr = ceil(size_template_x_all/2^(n_pyrs-1));
size_template_y_pyr = ceil(size_template_y_all/2^(n_pyrs-1));

for n_pyr = 1:n_pyrs
    corners{n_pyr} = ceil(corners_org * 0.5^(n_pyrs-n_pyr));
    size_template_x(n_pyr) = size_template_x_pyr * 2^(n_pyr-1);
    size_template_y(n_pyr) = size_template_y_pyr * 2^(n_pyr-1);
    size_x(n_pyr) = size(image_pyr{n_pyr},2);
    size_y(n_pyr) = size(image_pyr{n_pyr},1);

    width_t = size_template_x(n_pyr);
    height_t = size_template_y(n_pyr);
    size_pad_x(n_pyr) = ceil((1+pad) * max(size_template_x(n_pyr), size_template_y(n_pyr)));
    size_pad_y(n_pyr) = ceil((1+pad) * max(size_template_x(n_pyr), size_template_y(n_pyr)));
    pos_x = (size_pad_x(n_pyr) - width_t)/2;
    pos_y = (size_pad_y(n_pyr) - height_t)/2;

    Nx(n_pyr) = size_template_x(n_pyr) * size_template_y(n_pyr);
    dst_corners_H{n_pyr} = [0, 0; size_template_x(n_pyr), 0; size_template_x(n_pyr), size_template_y(n_pyr); 0, size_template_y(n_pyr)];    
    size_corners{n_pyr} = [0, 0; size_x(n_pyr), 0; size_x(n_pyr), size_y(n_pyr); 0, size_y(n_pyr)];        

    dst_corners_H_all{n_pyr} = [pos_x, pos_y; (pos_x + width_t -1), pos_y; (pos_x + width_t -1), (pos_y + height_t -1); pos_x, (pos_y + height_t -1)];
    src_corners_H_tmp{n_pyr} = dst_corners_H_all{n_pyr};
    dst_corners_H_tmp{n_pyr} = [0, 0; size_template_x(n_pyr), 0; size_template_x(n_pyr), size_template_y(n_pyr); 0, size_template_y(n_pyr)];
end

for n_pyr = 1:n_pyrs
    scale_H_tmp{n_pyr} = cv.getPerspectiveTransform(dst_corners_H_tmp{n_pyrs}, dst_corners_H_tmp{n_pyr});
    scale_H{n_pyr} = cv.getPerspectiveTransform(size_corners{n_pyr}, size_corners{n_pyrs});
    if n_pyr ~= n_pyrs
        scale_H_all{n_pyr} = cv.getPerspectiveTransform(dst_corners_H_all{n_pyr+1}, dst_corners_H_all{n_pyr});
    else
        scale_H_all{n_pyr} = cv.getPerspectiveTransform(dst_corners_H_all{1}, dst_corners_H_all{n_pyr});
    end
    H_{n_pyr} = cv.getPerspectiveTransform(dst_corners_H{n_pyr}, corners{n_pyr});
    H_all{n_pyr} = cv.getPerspectiveTransform(dst_corners_H_all{n_pyr}, corners{n_pyr});
    H_tmp{n_pyr} = cv.getPerspectiveTransform(dst_corners_H{n_pyr}, dst_corners_H_all{n_pyr});
end
H = H_{n_pyrs};
Template = warp(ICur_gray, H, size_template_x(n_pyrs), size_template_y(n_pyrs));  

% Storage directory
if save_results
    save_path = [save_base_path '\' seq.name];
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end
    % Saving tracking results: 4 corner points' positions
    save_results_corners = [save_path '/' seq.name '_' tracker.name '_corners.txt'];
    file_save_results_corners = fopen(save_results_corners,'w+');
    fprintf(file_save_results_corners,'%s %s %s %s %s %s %s %s %s\r\n','frame','ulx','uly','urx','ury','lrx','lry','llx','lly');
    results.results_corners = zeros(abs(nb_last_image-nb_first_image)+1,8); % store the tracking results
end
if save_image
    save_images_path = [save_path '/' tracker.name];
    if ~exist(save_images_path, 'dir')
        mkdir(save_images_path);
    end
end

% Init Jac
imx = [];
imy = [];
x = [];
y = [];
for n_pyr = 1:n_pyrs
    [imx{n_pyr},imy{n_pyr}] = meshgrid(1:size_template_x(n_pyr), 1:size_template_y(n_pyr));
    x{n_pyr} = reshape(imx{n_pyr}, Nx(n_pyr), 1);
    y{n_pyr} = reshape(imy{n_pyr}, Nx(n_pyr), 1);
end

% Init GO-ESM
tracker.H = H_;
tracker.H_tmp = H_tmp;
tracker.H_all = H_all;
tracker.scale_H_all = scale_H_all;
tracker.scale_H_tmp = scale_H_tmp;
tracker.scale_H = scale_H;
tracker.size_template_x = size_template_x;
tracker.size_template_y = size_template_y;
tracker.size_x = size_x;
tracker.size_y = size_y;
tracker.size_pad_x = size_pad_x;
tracker.size_pad_y = size_pad_y;
tracker.image = ICur_gray;
tracker.Nx = Nx;
tracker.x = x;
tracker.y = y;
tracker.imx = imx;
tracker.imy = imy;
tracker = init_GOP_ESM(tracker);  %init














