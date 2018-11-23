function [warped, mask] = warp_a(ICur, H, imx, imy, mask)

x = H(1,1)*imx + H(1,2)*imy + H(1,3);
y = H(2,1)*imx + H(2,2)*imy + H(2,3);
z = H(3,1)*imx + H(3,2)*imy + H(3,3);

warped = interp2(ICur, x./z, y./z, 'bilinear');
m = isnan(warped);
warped(m) = 0;
if exist( 'mask', 'var' ),
    mask(m) = 0;
end

return