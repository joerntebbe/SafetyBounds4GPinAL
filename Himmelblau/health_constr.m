% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [cleq,ceq] = health_constr(obj,xIn,xnew,intermediate_steps,ran,safetyalpha, method, samples, num_reps)
    ceq = [];
    xnew_ramp = create_ramp(xIn,xnew,intermediate_steps);
    [mu,~,~,~,~, post_] = gp_predict( obj, xnew_ramp(:,:), 1);
    fs2 = post_.fs2_;
    if any(mu < 0)
        cleq1 = 0.5 - norm(max(mu, zeros(size(mu))));
        cleq = - cleq1 + (1-safetyalpha)  ;
        return
    else
        if isempty(ran)
            ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 1e6);
        end

        str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
        
        fid = fopen(strcat('output/', str, '/health_vals.csv'), "a");
        
        if method == "AMC"
            [cleq_amc, k] = adaptive_mc(mu, fs2, safetyalpha, intermediate_steps, ran, samples);
            cleq = cleq_amc;
        elseif method == "AB"
            [cleq_ab, k] = adaptive_borell(mu, fs2, safetyalpha, intermediate_steps, ran, samples);
            cleq = cleq_ab;
        elseif method == "MC"
            [cleq_mc, k] = health(mu, post_.fs2_, "MC", safetyalpha, intermediate_steps, cell2mat(ran(end)));
            cleq = cleq_mc;
        elseif method == "B"
            [cleq_b, k] = health(mu, post_.fs2_, "B", safetyalpha, intermediate_steps, cell2mat(ran(end)));
            cleq = cleq_b;
        elseif method == "BC"
            [cleq, k, met] = adaptive_bc(mu, fs2, safetyalpha, intermediate_steps, ran, samples);
            fprintf(fid, strcat(num2str(cleq), ",", num2str(k), ",", num2str(met), "\n"));
            fclose(fid);
            return
        end
    fprintf(fid, strcat(num2str(cleq), ',', num2str(k),"\n"));
    fclose(fid);
    end
end
   
