% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = create_ramp(xIn,xend,intermediate_steps)
zw1 = 1:1:intermediate_steps;
tau = zeros( intermediate_steps, 2 );
for jj=1:intermediate_steps
    tau(jj,:) = xIn(end,:) + zw1(jj)/intermediate_steps * (xend - xIn(end,:));
end 
y =  tau; 
end




 
  
    
    
    