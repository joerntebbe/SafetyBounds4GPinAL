% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cleq, k] = health(mu, fs2, method, safetyalpha, intermediate_steps, ran)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
  
    
    if method == "MC"
        % ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 10000);
        [safety_matlab, ~] = mcmc(mu,fs2,length(ran),ran);
        
        cleq1 = safety_matlab;
        cleq = - cleq1 + (1-safetyalpha)  ;
        
    elseif method == "B"
        inv_mu = diag(1./mu);
        K_c = inv_mu * fs2 * inv_mu;
        % ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 1/5 * 10000);
        [~, pdf_c] = mcmc_c(mu, K_c, length(ran), ran, fs2);
        
        safety_ana = borel(max(pdf_c, [], 1), max(diag(K_c)), 1);
        cleq1 = safety_ana;
        cleq = - cleq1 + (1-safetyalpha)  ;
        
    else
        error('Method not known!')
    end
    k = length(ran);
    % load('saves/evals.mat')
    % evals = evals + 1;
    % save("saves/evals.mat", "evals")
end