% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function model = gp( obj , xIn ,  yIn )
    model = minimize(obj.hyp, @gp2, -100, @infGaussLik, ...
        obj.meanfunc, obj.covfunc, obj.likfunc, xIn, yIn);
    model.xIn = xIn;
    model.yIn = yIn;
end