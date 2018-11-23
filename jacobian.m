%   File: 'jacobian.m'
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

function J = jacobian(jac_c, jac_t, x, y)

Ix = jac_c(:,1) + jac_t(:,1);
Iy = jac_c(:,2) + jac_t(:,2);

xIx = x.*Ix; yIx = y.*Ix; xIy = x.*Iy; yIy = y.*Iy; temp = -xIx-yIy;

J = [Ix, Iy, yIx, xIy, -yIy + xIx, temp-yIy, temp.*x, temp.*y];

return