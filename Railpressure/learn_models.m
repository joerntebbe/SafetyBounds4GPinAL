% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [explModel,healthModel] = learn_models(explModel, healthModel, xIn,yIn,yInhealth, train ) 
    %specifiy further options here as explModel object:
   % start values for hyperparameters:  [2.0440 2.8944  3.4799 1.7412 0.2092 1.2262 0.1892 1.0 1.00 1.0 1.0236 0.1962];
    % lower bounds for hyperparameters:   [0.5 0.5 0.5 0.5 0.05 0.5 0.05 1.0 1.0 1.0 1 0.05];
 % upper bounds for hyperparameters:   [5.0 5.0 5.0 5.0 2.00 2.5 2.50 1.0 1.0 1.0 1 0.50];   
   end_ind = size(xIn, 2) - 3;
   if train > 0
       hypexpl = explModel.hyp; % Adjust the initial values as needed

% Set the lower and upper bounds for the hyperparameters
lb = [(-explModel.scale_mean)/explModel.scale_std log([0.5 0.5 0.5 0.5 0.05 0.5 0.05 ...1.0 1.0 1.0
    1]) log(0.05)];% Lower bounds for hyperparameters
ub = [(-explModel.scale_mean)/explModel.scale_std log([5.0 5.0 5.0 5.0 2.00 2.5 2.50... 1.0 1.0 1.0
    1]) log(0.5)];  % Upper bounds for hyperparameters
% Perform constrained optimization
hypexpl = explModel.hyp;
options = optimoptions('fmincon', 'Display', 'off');
hyp0 = [(-explModel.scale_mean)/explModel.scale_std hypexpl.cov hypexpl.lik];
[hyp2, ~] = fmincon(@(hyp) objective(hyp, @infGaussLik, explModel.meanfunc, explModel.covfunc, explModel.likfunc, xIn, yIn), hyp0, [], [], [], [], lb, ub, []);

testexpl = [lb;hyp0;hyp2;ub];
disp(testexpl)
% Retrieve the optimized hyperparameters
       explModel.hyp.mean = (-explModel.scale_mean)/explModel.scale_std;
       explModel.hyp.cov = hyp2(2:end-1);
       explModel.hyp.lik = hyp2(end);
       str = ['intermediate_5_alpha',strrep( num2str( train ), '.','') ];
       load(strcat("output/", str, "/hypse.mat"))
       hypse = [hypse; explModel.hyp.mean, explModel.hyp.cov, explModel.hyp.lik];
       [~,~,~,~,~, post] = gp_predict( explModel, xIn(1,:));
       explModel.post = post;
        save(strcat("output/", str, "/hypse.mat"), "hypse");
   elseif train < 0
       explModel.x_scale_mean = mean(xIn(:,1:end_ind), 1);
       explModel.x_scale_std = std(xIn(:,1:end_ind), 1);
       
       explModel.scale_mean = mean(yIn);
       explModel.scale_std = std(yIn);
       explModel.hyp.mean = (-explModel.scale_mean)/explModel.scale_std;
       explModel.xIn = tf_railpressure(xIn(:,1:end_ind), explModel);
       
       explModel.yIn = tf_y(yIn, explModel);
       [~,~,~,~,~, post] = gp_predict( explModel, xIn(1,:));
       explModel.post = post;
   else
       l_2 = [log(2.0440), log(2.8944), log(3.4799), log(1.7412), log(0.2092), log(1.2262), log(0.1892)];
   s_2 = log(1.0236);
   epsilon = log(0.1962);
   y_mean = mean(yIn);
   y_std = std(yIn);
   hypexpl = struct('mean', (-y_mean)/y_std, ...
       'cov', [ l_2, s_2], ...
       'lik', epsilon);
   explModel = struct('hyp', hypexpl, ...
       'meanfunc', @meanConst, ...
       'covfunc', @covSEard, ...
       'likfunc', @likGauss);
   explModel.x_scale_mean = mean(xIn(:,1:end_ind), 1);
       explModel.x_scale_std = std(xIn(:,1:end_ind), 1);
   explModel.scale_mean = y_mean;
       explModel.scale_std = y_std;
       explModel.xIn = tf_railpressure(xIn(:,1:end_ind), explModel);
       explModel.yIn = tf_y(yIn, explModel);
       [~,~,~,~,~, post] = gp_predict( explModel, xIn(1,:));
       explModel.post = post;
   end
   %
   %%%%%%%%
   %
       %specifiy further options here as healthModel object:
   % start values for hyperparameters:   [2.0440 2.8944  3.4799 1.7412 0.2092 1.2262 0.1892 1.0 1.00 1.0 1.0236 0.1962];
    % lower bounds for hyperparameters:  [0.5 0.5 0.5 0.5 0.05 0.5 0.05 1.0 1.0 1.0 0.1 .1];
 % upper bounds for hyperparameters:  [1*[5.0 5.0 5.0 5.0 2.00 2.5 2.50], 1.0 1.0 1.0 5.0 .1]; 
   if train > 0
       hyphealth = healthModel.hyp;
       lb = [(-0.01-healthModel.scale_mean)./healthModel.scale_std log([0.5 0.5 0.5 0.5 0.05 0.5 0.05 ... 1.0 1.0 1.0 
           0.1]) log(0.1)];
        ub = [(-0.01-healthModel.scale_mean)./healthModel.scale_std log([5.0 5.0 5.0 5.0 2.00 2.5 2.50 ... 1.0 1.0 1.0
            5.0]) log(0.1)];
        % Perform constrained optimization
        options = optimoptions('fmincon', 'Display', 'off');
        hyp0 = [(-0.01-healthModel.scale_mean)./healthModel.scale_std hyphealth.cov hyphealth.lik];
        
        [hyp2, ~] = fmincon(@(hyp) objective(hyp, @infGaussLik, explModel.meanfunc, explModel.covfunc, explModel.likfunc, xIn, yInhealth), hyp0, [], [], [], [], lb, ub, [], options);
        testhealth = [lb;hyp0;hyp2;ub];
        disp(testhealth)        
        healthModel.hyp.mean = (-0.01-healthModel.scale_mean)./healthModel.scale_std;
        healthModel.hyp.cov = hyp2(2:end-1);
        healthModel.hyp.lik = hyp2(end);
        str = ['intermediate_5_alpha',strrep( num2str( train ), '.','') ];
        load(strcat("output/", str, "/hyps.mat"))
        hyps = [hyps; healthModel.hyp.mean, healthModel.hyp.cov, healthModel.hyp.lik];
        save(strcat("output/", str, "/hyps.mat"), "hyps");
        [~,~,~,~,~, post] = gp_predict( healthModel, xIn(1,:));
       healthModel.post = post;
   elseif train < 0
       healthModel.x_scale_mean = mean(xIn(:,1:end_ind), 1);
       healthModel.x_scale_std = std(xIn(:,1:end_ind), 1);
       
       healthModel.scale_mean = mean(yInhealth);
       healthModel.scale_std = std(yInhealth);
       healthModel.hyp.mean = (-0.01-healthModel.scale_mean)./healthModel.scale_std;
       healthModel.xIn = tf_railpressure(xIn(:,1:end_ind), healthModel);
       healthModel.yIn = tf_y(yInhealth, healthModel);
       [~,~,~,~,~, post] = gp_predict( healthModel, xIn(1,:));
       healthModel.post = post;
   else
       l_2_h = [log(2.0440), log(2.8944), log(3.4799), log(1.7412), log(0.2092), log(1.2262), log(0.1892)]; ...
   s_2_h = log(1.0236);
   epsilon_h = log(0.1962);
   x_mean = mean(xIn(:,1:end_ind), 1);
   x_std = std(xIn(:,1:end_ind), 1);
   y_mean = mean(yInhealth);
   y_std = std(yInhealth);
   hyphealth = struct('mean', (-0.01 - y_mean)/y_std, ...
       'cov', [l_2_h, s_2_h ], ...
       'lik', epsilon_h);
   healthModel = struct('hyp', hyphealth, ...
       'meanfunc', @meanConst, ...
       'covfunc', @covSEard, ...
       'likfunc', @likGauss);
   healthModel.x_scale_mean = x_mean;
   healthModel.x_scale_std = x_std;
   healthModel.scale_mean = y_mean;
       healthModel.scale_std = y_std;
       healthModel.xIn = tf_railpressure(xIn(:,1:end_ind), healthModel);
       healthModel.yIn = tf_y(yInhealth, healthModel);
       [~,~,~,~,~, post] = gp_predict( healthModel, xIn(1,:));
       healthModel.post = post;
   end
   
end






