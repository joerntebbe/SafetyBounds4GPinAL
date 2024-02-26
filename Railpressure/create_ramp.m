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
    tau(jj,:) = xIn(end,[1,5]) + zw1(jj)/intermediate_steps * (xend - xIn(end,[1,5]));
end 
xIn =  [ xIn ; [tau(:,1) ,  zeros(length(tau(:,1)),3),  tau(:,2),  zeros(length(tau(:,1)),5)+0.7 ]  ]; 
pastinputblock = zeros(length(tau(:,1)),3) ;
for jj=1:length(tau(:,1))
        pastinputblock(jj,1) = xIn(end-1-intermediate_steps+jj,1);
        pastinputblock(jj,2) = xIn(end-2-intermediate_steps+jj,1);
        pastinputblock(jj,3) = xIn(end-3-intermediate_steps+jj,1);
        pastinputblock(jj,4) = xIn(end-1-intermediate_steps+jj,5);
        pastinputblock(jj,5) = xIn(end-3-intermediate_steps+jj,5);
end
y =  [tau(:,1), pastinputblock(:,1:3), tau(:,2), pastinputblock(:,4:5), zeros(length(tau(:,1)),3)+0.7 ];  
end




 
  
    
    
    