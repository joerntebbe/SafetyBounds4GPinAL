% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y, sigma, fmu, fs2, covnew, post] = gp_predict( obj, ramp, options)
if nargin > 2
    y_in = obj.post;
else
    y_in = obj.yIn;
end
if size(ramp, 2) == 10
ramp = tf_railpressure(ramp(:, 1:end-3), obj);
elseif size(ramp, 2) == 7
ramp = tf_railpressure(ramp(:, :), obj);
else
    error("Dimensions do not fit!")
end
[y, sigma, fmu, fs2, ~, post] = gp2(obj.hyp, @infGaussLik, ...
    obj.meanfunc, obj.covfunc, obj.likfunc, ...
    obj.xIn, y_in, ramp);

[y, sigma] = tf_y_inv(y, sigma, obj);
[fmu, fs2] = tf_y_inv(fmu, fs2, obj);

covnew = post.Kss;
% input is a GP object obj, a ramp of points ramp and potentially further
% options in options
end