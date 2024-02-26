% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p, pdf] = mcmc2(mu,sigma,M,ran)

pdf = transpose(mu) .* ones(length(mu), M) + chol(sigma + 1e-6 * eye(size(sigma, 1)))' * transpose(ran);
p = (sum(all((pdf > 0), 1)))/M;

end
    

