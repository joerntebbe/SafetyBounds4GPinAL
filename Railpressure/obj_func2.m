% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function var = obj_func2(obj,xIn,xnew,intermediate_steps)
xnew_ramp = create_ramp(xIn,xnew,intermediate_steps);
[~,~,~,~,K] = gp_predict( obj, xnew_ramp(:,:) ,[0,1,0] );
var = - det( K );
end