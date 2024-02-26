% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p, pdf] = mcmc(mu,sigma,n,ran)

if max(eig(sigma))>0
    [p, pdf] = mcmc2(mu',sigma,n,ran);
else
   error('Sigma is not positive definit !!');
end
end