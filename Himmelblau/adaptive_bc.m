% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cleq, k, met] = adaptive_bc(mu, fs2, safetyalpha, intermediate_steps, ran_full, samples)
inv_mu = diag(1./mu);
K_c = inv_mu * fs2 * inv_mu;
sigma_max = max(diag(K_c));

epsilon = 0.5 * 1e-3;
p_hat_pluss = zeros(length(samples), 1);
p_hat_minuss = zeros(length(samples), 1);
q_pluss = zeros(length(samples), 1);
q_minuss = zeros(length(samples), 1);
p_hat = zeros(length(samples), 1);
lbs = zeros(length(samples), 1);
ubs = zeros(length(samples), 1);
sim_arr = [];
borell = 0;
mc = 0;
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
    p_check = samples(k)/samples(k+1) * p_hat(k) + 1/samples(k+1) * (sum(any((pdf_c > 1), 1)));
    p_hat(k + 1) = p_check;
    [lb, ub] = confidence_bounds(safetyalpha, (k), epsilon,samples(k+1) );
    lbs(k + 1) = lb;
    ubs(k + 1) = ub;
    
    
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
    p_hat_minus = 0;
    end
    p_hat_pluss(k + 1) = p_hat_plus;
    p_hat_minuss(k + 1) = p_hat_minus;
    
    if p_hat_plus <= safetyalpha
        cleq1 = 1 - p_hat_plus;
        
        cleq_b = - cleq1 + (1-safetyalpha)  ;
        borell = 1;
    end
    if p_hat(k + 1) <= lb
        cleq1 = 1 - p_hat(k + 1);
        cleq_mc = - cleq1 + (1-safetyalpha)  ;
        mc = 1;
    elseif p_hat(k + 1) >= ub
        cleq1 = 1 - p_hat(k+1);
        cleq_mc = - cleq1 + (1-safetyalpha)  ; 
        mc = 1;
    end
    if (borell == 1)
        if mc == 1
            cleq = cleq_mc;
            met = 3;
        else
            cleq = cleq_b;
            met = 1;
        end
        return
    elseif mc == 1
        cleq = cleq_mc;
        met = 2;
        return
    end
end
cleq1 = 1 - p_hat_plus;
cleq = - cleq1 + (1-safetyalpha)  ; 
met = -1;
end