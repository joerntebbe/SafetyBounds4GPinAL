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

[y, sigma, fmu, fs2, ~, post] = gp2(obj.hyp, @infGaussLik, ...
    obj.meanfunc, obj.covfunc, obj.likfunc, ...
    obj.xIn, y_in, ramp);

covnew = post.Kss;
end