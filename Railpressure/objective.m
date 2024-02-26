% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [obj_func] = objective(hyp, inf, meanfunc, covfunc, likfunc, xIn, yIn)

hyp2 = struct("mean", hyp(1), ...
            "cov", hyp(2:end -1), ...
            "lik", hyp(end));
obj_func = gp2(hyp2, inf, meanfunc, covfunc, likfunc, xIn, yIn);
end