% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cleq,ceq] = health_constr(obj,xIn,xnew,intermediate_steps,ran,safetyalpha, method, mode, samples)
   
   ceq = [];
   
   xnew_ramp = create_ramp(xIn,xnew,intermediate_steps);
   [mu,~,~,~,~, post_] = gp_predict( obj, xnew_ramp(:,:), 1);
   fs2 = post_.fs2_;
   if any(mu <= 0)
       % cleq1 = 0;
       cleq1 = 0.5 - eps - norm(min(mu, zeros(size(mu))));
       cleq = - cleq1 + (1-safetyalpha)  ;
       % disp(['Mu', num2str(min(mu))]);
       return
   else
   str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
       if isempty(ran)
    ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 1e6);
       end
    % load(strcat('output/', str, '/health_vals.mat'));  
    fid = fopen(strcat('output/', str, '/health_vals.csv'), "a");
    % close all;
    % if method == "AMC"
        % samples = [0, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200, 102400, 204800, 409600, 819200];
        % samples(1) = 0;
    if method == "AMC"
        [cleq, k] = adaptive_mc(mu, fs2, safetyalpha, intermediate_steps, ran, samples);
        % disp(['MC: ', num2str((cleq_amc - (1 - safetyalpha)) * (-1)), ' Iterations: ', num2str(k_amc)])
        % health_vals = [health_vals; cleq, k];
    % elseif method == "AB"
        % samples = 100:100:1e4;
        % samples(1) = 0;
    elseif method == "AB"
        [cleq, k] = adaptive_borell(mu, fs2, safetyalpha, intermediate_steps, ran, samples);
        % health_vals = [health_vals; cleq_amc, cleq_ab, k_amc, k_ab];
        % disp(['Borell: ', num2str((cleq_ab - (1 - safetyalpha)) * (-1)), ', Iterations: ', num2str(k_ab)]);
        
        % load('saves/evals.mat', "evals")
        % fid_2 = fopen(strcat('output/', str, '/health_vals_2.csv'), "a");
    elseif method == "MC"
            [cleq, k] = health(mu, post_.fs2_, "MC", safetyalpha, intermediate_steps, cell2mat(ran(end)));
    elseif method == "B"
            [cleq, k] = health(mu, post_.fs2_, "B", safetyalpha, intermediate_steps, cell2mat(ran(end)));
        % fprintf(fid_2, strcat(num2str(cleq_mc), ",", num2str(cleq_b), ",", num2str(k_mc), ",", num2str(k_b),"\n"));
        % fclose(fid_2); 
    elseif method == "BC"
        [cleq, k, met] = adaptive_bc(mu, fs2, safetyalpha, intermediate_steps, ran, samples);
        fprintf(fid, strcat(num2str(cleq), ",", num2str(k), ",", num2str(met), "\n"));
    fclose(fid);
    return
    end

    fprintf(fid, strcat(num2str(cleq), ",", num2str(k), "\n"));
    fclose(fid);
        % if method == "AMC"
        %     cleq = cleq_amc;
        % 
        %     % evals(end) = evals(end) + 100 * 2^(k_amc - 1);
        %     % save('saves/evals.mat', "evals");
        %     return
        % elseif method == "AB"
        %     cleq = cleq_ab;
        %     % evals = evals + 100 * 2^(k_ab - 1);
        %     % save('saves/evals.mat', "evals");
        %     return
        % elseif method == "MC"
        %     cleq = cleq_mc;
        %     return
        % elseif method == "B"
        %     cleq = cleq_b;
        %     return
        % elseif method == "MinIter"
        %     [cleq, ind_opt] = min([cleq_amc, cleq_ab]);
        % 
        % 
        % elseif method == "MaxIter"
        %     [cleq, ind_opt] = max([cleq_amc, cleq_ab]);
        % 
        % 
        % end
        % if ind_opt == 1
        %         k_opt = k_amc;
        %     elseif ind_opt == 2
        %         k_opt = k_ab;
        %     else
        %         raise("Index error for cleq")
        % end
        % save(strcat('output/', str, '/health_vals.mat'), "health_vals");  
        % load('saves/evals.mat')
        
        % evals = evals + 100 * 2^(k_opt - 1);
        % save('saves/evals.mat', "evals");
   end
end