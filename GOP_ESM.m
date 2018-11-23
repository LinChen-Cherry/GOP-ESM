function [H, Handle] = GOP_ESM(ICur_gray, H, Handle)

n_pyrs = Handle.pyr;
maxIters = Handle.maxIters;
maxPyrIter = ceil(maxIters / n_pyrs);
epsilon = Handle.epsilon;
Nx = Handle.Nx;
size_template_x = Handle.size_template_x;
size_template_y = Handle.size_template_y;
feature_dim = Handle.feature_dim;
feature_t = Handle.feature_t;
jac_t = Handle.jac_t;
mask_t = Handle.mask_t;
H_tmp = Handle.H_tmp;
x = Handle.x;
y = Handle.y;
imx = Handle.imx;
imy = Handle.imy;

% get GOP features
[feature_init, mask_init] = get_GOP(ICur_gray, Handle);

% do GOP ESM
n_pyr = 1;
for all_iters = 0 : maxIters
    if n_pyr > n_pyrs
        break;
    end
    for n_pyr = 1 : n_pyrs
        for iters = 1 : maxPyrIter
            all_iters = all_iters + 1;

            feature = zeros(size_template_y(n_pyr), size_template_x(n_pyr), feature_dim);
            Jac = zeros(Nx(n_pyr)*feature_dim,8);

            % Computes warped feature images and gradient
            mask = (warp_a(mask_init{n_pyr}, H_tmp{n_pyr}, imx{n_pyr}, imy{n_pyr}) == 1) & mask_t{n_pyr};
            for i = 1:feature_dim
                [feature(:,:,i), mask] = warp_a(feature_init{n_pyr}(:,:,i), H_tmp{n_pyr}, imx{n_pyr}, imy{n_pyr}, mask);
                [dx, dy] = gradient(feature(:,:,i));
                Jac(Nx(n_pyr)*(i-1)+1:i*Nx(n_pyr),:) = jacobian([dx(:) dy(:)], jac_t{n_pyr}(:,:,i), x{n_pyr}, y{n_pyr});
            end

            % Computes mask image
            maskJ = isfinite(Jac(:,1)) & isfinite(Jac(:,2)) & isfinite(Jac(:,3)) & isfinite(Jac(:,4))...
                    & isfinite(Jac(:,5)) & isfinite(Jac(:,6)) & isfinite(Jac(:,7)) & isfinite(Jac(:,8));                
            mask_final = [mask(:);mask(:)] & maskJ;

            % Image difference
            feature_c = reshape(feature, Nx(n_pyr)*feature_dim, 1);
            feature_t_ = reshape(feature_t{n_pyr}, Nx(n_pyr)*feature_dim, 1); 
            di = feature_c(mask_final) - feature_t_(mask_final);

            % d H
            d = - 2 * pinv(Jac(mask_final,:)) * di;
            A = [d(5),d(3),d(1); d(4),-d(5)-d(6),d(2); d(7),d(8),d(6)];
            
            % update H
            H_tmp{n_pyr} = H_tmp{n_pyr}*expm(A);
            H = Handle.scale_H{n_pyr} * Handle.H_all{n_pyr} * H_tmp{n_pyr} * Handle.scale_H_tmp{n_pyr};
            for j = [1:n_pyr-1, n_pyr+1:n_pyrs]
                H_tmp{j} = (Handle.scale_H{j} * Handle.H_all{j}) \ (H / Handle.scale_H_tmp{j});            
            end
            
            % stop loop
            resd = sum(abs(d));
            if resd < epsilon && all_iters < maxIters              
                if n_pyr >= n_pyrs
                    for j = 1:n_pyrs
                        Handle.H_all{j} = (Handle.scale_H{j} \ H) /  (Handle.H_tmp{j} * Handle.scale_H_tmp{j});
                    end
                    return;                    
                end
                break;
            end
            if all_iters >= maxIters
                for j = 1:n_pyrs
                    Handle.H_all{j} = (Handle.scale_H{j} \ H) /  (Handle.H_tmp{j} * Handle.scale_H_tmp{j});
                end          
                return;                
            end        
        end
    end   
    for j = 1:n_pyrs
        Handle.H_all{j} = (Handle.scale_H{j} \ H) /  (Handle.H_tmp{j} * Handle.scale_H_tmp{j});
    end
    return
end
  