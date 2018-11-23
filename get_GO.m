function [feature, feature_mask] = get_GO(image, Handle)

size_x = size(image,2);
size_y = size(image,1);
feature_dim = 2;
feature = zeros(size_y, size_x, feature_dim);
sum = zeros(size_y, size_x);

[feature(:,:,1), feature(:,:,2)] = gradient(image);
for i = 1:feature_dim
    sum = sum + feature(:,:,i).^2;
end
n = sqrt(sum);
for i = 1:feature_dim
    feature(:,:,i) = feature(:,:,i) ./ n;
end  

feature_mask = double(n > Handle.thd);

end