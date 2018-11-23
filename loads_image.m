%   File: 'loads_image.m'
%
%   Author(s):  Rogerio Richa
%   Created on: 2011
% 
%   (C) Copyright 2006-2011 Johns Hopkins University (JHU), All Rights
%   Reserved.
% 
% --- begin cisst license - do not edit ---
% 
% This software is provided "as is" under an open source license, with
% no warranty.  The complete license can be found in license.txt and
% http://www.cisst.org/cisst/license.txt.
% 
% --- end cisst license ---

number = sprintf( [ '%0', num2str(length_number), 'd' ], nb_image);
imgname = strcat( path_to_images, file_name, number, image_format);
ICur = imread(imgname);

if size(ICur,3) ~= 1
    ICur_gray = rgb2gray(ICur);
else
    ICur_gray = ICur;
end

gausFilter = fspecial('gaussian', [5 5], 1.5);
ICur_gray = imfilter(ICur_gray, gausFilter, 'replicate');     

ICur_gray = double(imresize(ICur_gray, scale));
