% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cleq, k] = adaptive_borell(mu, fs2, safetyalpha, intermediate_steps, ran_full, samples)
inv_mu = diag(1./mu);
K_c = inv_mu * fs2 * inv_mu;
sigma_max = max(diag(K_c));
epsilon = 1e-3;
p_hat_pluss = zeros(length(samples), 1);
p_hat_minuss = zeros(length(samples), 1);
q_pluss = zeros(length(samples), 1);
q_minuss = zeros(length(samples), 1);
sim_arr = [];
for k=1:length(samples)-1
    chi = min(1 - 6 * epsilon/(pi^2 * k^2), 1 - eps);
    diff_term_beta = max(norminv(chi)/sqrt(4*samples(k + 1)), 0);
    
    beta_1 = 0.5 + diff_term_beta;
    beta_2 = 0.5 - diff_term_beta;
    beta_minus = min([beta_1, beta_2]);
    beta_plus = max([beta_1, beta_2]);
    if isempty(ran_full)
        ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , samples(k + 1) - samples(k));
    else
        ran = ran_full{k};
    end
    [~, pdf_c] = mcmc_c(mu, K_c, length(ran), ran, fs2);
    max_arr = max(pdf_c, [], 1);
    sim_arr = [sim_arr, max_arr];
    
    global t_quantile;
    tic;
    Q = quantile(sim_arr, [min(beta_plus, 1), max(beta_minus, 0)]);
    t_quantile = t_quantile + toc;
    
    q_plus = Q(1);
    q_minus = Q(2);
    q_pluss(k+1) = q_plus;
    q_minuss(k+1) = q_minus;
    if q_plus < 1
    p_hat_plus = 1 - normcdf((1 - q_plus)/sigma_max);
    else
    p_hat_plus = 1;
    end
    if q_minus < 1
    p_hat_minus = 1 - normcdf((1 - q_minus)/sigma_max);
    else
    p_hat_minus = 1;
    end
    p_hat_pluss(k + 1) = p_hat_plus;
    p_hat_minuss(k + 1) = p_hat_minus;
    if p_hat_plus <= safetyalpha
        cleq1 = 1 - p_hat_plus;
        cleq = - cleq1 + (1-safetyalpha)  ;
        return
    elseif p_hat_minus >= safetyalpha
        cleq1 = 1 - p_hat_minus;
        cleq = - cleq1 + (1-safetyalpha)  ; 
        return
    end
end

cleq1 = 1 - p_hat_plus;
cleq = - cleq1 + (1-safetyalpha)  ; 

end