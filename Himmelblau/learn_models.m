% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [explModel,healthModel] = learn_models(explModel, healthModel, xIn,yIn,yInhealth, train) 
       l_2 = [log(1.), log(1.)];
   s_2 = log(1.0);
   epsilon = log(.01);
   
   hypexpl = struct('mean', 0, ...
       'cov', [ l_2, s_2], ...
       'lik', epsilon);
   explModel = struct('hyp', hypexpl, ...
       'meanfunc', @meanConst, ...
       'covfunc', @covSEard, ...
       'likfunc', @likGauss);
       explModel.xIn = xIn;
       explModel.yIn = yIn;
       [~,~,~,~,~, post] = gp_predict( explModel, xIn(1,:));
       explModel.post = post;
   
   l_2_h = [log(1.), log(1.)];
   s_2_h = log(1.);
   epsilon_h = log(.01);
   hyphealth = struct('mean', -1 , ...
       'cov', [l_2_h, s_2_h ], ...
       'lik', epsilon_h);
   healthModel = struct('hyp', hyphealth, ...
       'meanfunc', @meanConst, ...
       'covfunc', @covSEard, ...
       'likfunc', @likGauss);
       healthModel.xIn = xIn;
       healthModel.yIn = yInhealth;
       [~,~,~,~,~, post] = gp_predict( healthModel, xIn(1,:));
       healthModel.post = post;
   end







