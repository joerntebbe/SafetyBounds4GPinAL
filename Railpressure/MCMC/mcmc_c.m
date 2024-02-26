% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p_c, pdf_c] = mcmc_c(mu,sigma,M,ran, K_test)

eps = 1e-6;
while true
    try
        pdf_c = chol(sigma + eps * eye(size(sigma, 1)))' * transpose(ran);
        p_c = (sum(all(pdf_c < 1, 1)))/M;
        return
    catch
        eps = 10*eps;
    end
end

end
    

