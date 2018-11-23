function Handle = init_GOP_ESM(Handle)

Nx = Handle.Nx;
n_pyrs = Handle.pyr;
imx = Handle.imx;
imy = Handle.imy;
H_tmp = Handle.H_tmp;

feature_dim = 2;
Handle.feature_dim = feature_dim;

% warp feature image
[feature_org, mask_org] = get_GOP(Handle.image, Handle);
for n_pyr = 1:n_pyrs
    jac_t{n_pyr} = zeros(Nx(n_pyr), 2, 2);
end

for n_pyr = 1:n_pyrs
    mask_t{n_pyr} = warp_a(mask_org{n_pyr}, H_tmp{n_pyr}, imx{n_pyr}, imy{n_pyr}) == 1;
    for i = 1:feature_dim
        [feature_t{n_pyr}(:,:,i), mask_t{n_pyr}]= warp_a(feature_org{n_pyr}(:,:,i), H_tmp{n_pyr}, imx{n_pyr}, imy{n_pyr}, mask_t{n_pyr});
        [Ix_t, Iy_t] = gradient(feature_t{n_pyr}(:,:,i));
        jac_t{n_pyr}(:,:,i) = [Ix_t(:) Iy_t(:)]; 
    end  
end

Handle.feature_t = feature_t;
Handle.jac_t = jac_t;
Handle.mask_t = mask_t;
Handle.feature_dim = feature_dim;
Handle.H_tmp = H_tmp;
    
end