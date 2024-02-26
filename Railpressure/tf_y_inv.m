% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [yInT, s2T] = tf_y_inv(yIn, s2, obj)

yInT = (obj.scale_std.*yIn + obj.scale_mean);
s2T = obj.scale_std.^2 .* s2;
end