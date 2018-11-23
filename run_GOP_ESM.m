clear all;
close all;

%% config
seqs = config_seqs('POIC');
%dataset_path = '.\input';
dataset_path = 'E:\backup\G\dataset\POIC';
save_base_path = '.\results';

% show & save
plotSetting;
LineWidth = 2;
show = 1;
save_results = 1;
save_image = 1;

%% run GOP-ESM
% config the tracker
%   name:       name of tracker
%   maxIters:   total maximum iteration for all pyramid layers
%   smooth:     smooth method: none, Gauss, PM, BL
%   epsilon:    the threshold for breaking optimization loop
%   thd:        the threshold of gradient magnitude
%   scale:      scale input image
%   pad:        cropping pad
%   pyr:        the number of pyramid layers
%   N:          the number of pixels of template, must be even number
tracker = struct('name', 'sample_tracker', 'maxIters', 60, 'smooth', 'BL', 'epsilon', 0.01, 'thd', 0.1, 'scale', 1, 'pad', 1, 'pyr', 3, 'N', 10000);

for seq_index = 1:numel(seqs)
    seq = seqs{seq_index};
    init_tracker;

    % Runs on dataset
    for nb_image = nb_first_image : nb_last_image
        % Loads image
        loads_image
        % Display the template
        if show
            figure(2);
            imshow(ICur,'border','tight');
            text(10, 15, ['#' num2str(nb_image)], 'Color','b', 'FontWeight','bold', 'FontSize',30);
        end
        % Tracking

        [H, tracker] = GOP_ESM(ICur_gray, H, tracker);

        % Results
        T_pos = H*[0 size_template_x(n_pyrs) size_template_x(n_pyrs) 0 0; 0 0 size_template_y(n_pyrs)  size_template_y(n_pyrs) 0; ones(1,5)];            
        T_pos(1,:) = T_pos(1,:)./T_pos(3,:);
        T_pos(2,:) = T_pos(2,:)./T_pos(3,:);        

        % Show
        if show || save_image
            figure(2);
            LineStyle = plotDrawStyle{1}.lineStyle;
            hold on,      
            legend(plot(T_pos(1,:), T_pos(2,:), 'Color', plotDrawStyle{1}.color, 'LineWidth', LineWidth, 'LineStyle', LineStyle), tracker.name, -1);
            pause(0.1);
            % Saving tracking image
            if save_image
                imwrite(frame2im(getframe(gcf)), [save_images_path '/' file_name, number, image_format]);
            end
        end

        % Saving tracking results into files
        if save_results
            fprintf(file_save_results_corners, '%s %.6f %.6f %.6f %.6f %.6f %.6f %.6f %.6f\r\n', [file_name, number, image_format], reshape(T_pos(1:2,1:4),1,8));
        end        
    end

    % Closing the save files
    if save_results
       fclose(file_save_results_corners);
    end

end