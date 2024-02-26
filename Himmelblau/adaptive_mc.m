% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cleq, k] = adaptive_mc(mu, fs2, safetyalpha, intermediate_steps, ran_full, samples)

p_hat = zeros(length(samples), 1);
lbs = zeros(length(samples), 1);
ubs = zeros(length(samples), 1);
for k=1:length(samples)-1
    if isempty(ran_full)
        ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , samples(k + 1) - samples(k));
    else
        ran = ran_full{k};
    end
    [~, pdf] = mcmc(mu,fs2,length(ran),ran);
    p_check = samples(k)/samples(k+1) * p_hat(k) + 1/samples(k+1) * (sum(any((pdf < 0), 1)));
    p_hat(k + 1) = p_check;
    [lb, ub] = confidence_bounds(safetyalpha, (k), 1e-3,samples(k + 1) );
    lbs(k + 1) = lb;
    ubs(k + 1) = ub;
    
    if p_hat(k + 1) <= lb
        cleq1 = 1 - p_hat(k + 1);
        cleq = - cleq1 + (1-safetyalpha)  ;
        return
    elseif p_hat(k + 1) >= ub
        cleq1 = 1 - p_hat(k+1);
        cleq = - cleq1 + (1-safetyalpha)  ; 
        return
    end

end
cleq1 = 1 - ub;
cleq = - cleq1 + (1-safetyalpha)  ; 
end