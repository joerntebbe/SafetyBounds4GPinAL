% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
function y = prist_w_FIR_3stephealth(xIn)
y0 = prist_w_FIR_3step(xIn);
y=1-exp((y0-18)/10);
end