%   File: 'warp.m'
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

function warped = warp(ICur, H, size_template_x, size_template_y)

[imx,imy] = meshgrid(1:size_template_x, 1:size_template_y);

x = H(1,1)*imx + H(1,2)*imy + H(1,3);
y = H(2,1)*imx + H(2,2)*imy + H(2,3);
z = H(3,1)*imx + H(3,2)*imy + H(3,3);

warped = interp2(ICur, x./z, y./z, 'bilinear');
m = isnan(warped);
warped(m) = 0;