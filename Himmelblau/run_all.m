% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_all(inf_crit_choice,rsd,nameprefix,health_const_choice,obj_choice,m_steps,...
    safetyalpha, diff, lb, ub, method, eval_cap, mc_disc, num_reps, t_cap)
close all
addpath( genpath('.'), genpath('./../SPI-Toolbox/') )
delete( strcat('output/',nameprefix,'*.csv') )
warning('off', 'gp:chol_failed')
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];

% Algorithm parameters to play around with
number_initial_samples = 1;  %must be >1 as first is start point of trajectory
n_dsal_samples = 200;  % for now uneven number please because of subplot routine
intermediate_steps = m_steps;

n_multistart = 5;
n_plot = 100;
global RANDOMSEED;
RANDOMSEED = rsd;
global BigTable
BigTable = [ 0, zeros(1,21) ];
global places
places = zeros(intermediate_steps,intermediate_steps);
for i=1:intermediate_steps
    for j=1:intermediate_steps
        places(i,j) = abs(i-j)+1;
    end
end
randomseed = rsd;
rng(randomseed);

noise = 0.01;
noise2 = 0.01;

fid = fopen(['output/', str, '/methods.csv'], 'w');
fclose(fid);

ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 1e7);
samples_cell = cell(length(mc_disc), 1);
for iii=1:length(mc_disc) - 1
    samples_cell{iii} = ran(mc_disc(iii) + 1:mc_disc(iii + 1), :);
end
samples_cell{end} = ran(1:mc_disc(end-1), :);
ran = samples_cell;
global healthcoverage 
healthcoverage = [];

model_choice = 'himmelblau';
n_col_plot = 6;
n_rows_plot = ceil(n_dsal_samples/n_col_plot);
modelhealth_choice = strcat(model_choice,'health');
modelhealth_choice = model_choice;
model = str2func(model_choice);
modelhealth = str2func(modelhealth_choice);
inf_crit = str2func(inf_crit_choice);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Initialization  %%%%
%%%%%%%%%%%%%%%%%%%%%%  
%%%%   Initial safe trajectories  %%%%%%%
xIn = [-.1 .1; .1 .1; .1 -.1; -.1 -.1];
yIn = [ himmelblau(xIn, noise)];
yInhealth = [ modelhealth( xIn,noise )];

%%%%%%%%% learn models initially
% learn
[explModel,healthModel] = learn_models([], [], xIn,yIn,yInhealth, false);

% evaluate RMSE 
load('eval_grid.mat');
evaluation(explModel,healthModel,xIn,model_choice,modelhealth_choice,5000, 0 ,nameprefix,...
    intermediate_steps,diff, lb, ub, save_test, safetyalpha, mc_disc, num_reps)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Iteration DSAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
evals = zeros(n_dsal_samples, 1);
t = zeros(n_dsal_samples, 1);
evaluation_2(explModel,healthModel,xIn,model_choice,modelhealth_choice,5000,0 ,nameprefix,...
    intermediate_steps,diff, lb, ub, save_test, safetyalpha, mc_disc, num_reps, [-0.1 -0.1], rsd, 0)
plot_arr = [30, 60, 1000];
ccc = 1;
for ii_dsal=1:n_dsal_samples
    disp(['*****',' Seed = ',num2str(RANDOMSEED) , ';   iter = ', num2str(ii_dsal),...
        ';  ',datestr( datetime ),';  ', num2str(safetyalpha)])
    % choose new point 
    ts = tic;
    global t_quantile;
    t_quantile = 0;
    xnew = inf_crit(explModel,healthModel,n_multistart,xIn,intermediate_steps,nameprefix,...
        health_const_choice,obj_choice,ran,safetyalpha,diff, lb, ub, method, mc_disc, num_reps, ii_dsal);
    t(ii_dsal) = toc(ts);
    t(ii_dsal) = t(ii_dsal) - t_quantile/2;
    evals(ii_dsal, 1) = get_evals(ii_dsal, str, method, mc_disc);
    
    disp(['Time elapsed: ', num2str(sum(t)), 'seconds'])
    if sum(t) > plot_arr(ccc)
    evaluation_2(explModel,healthModel,xIn,model_choice,modelhealth_choice,5000,ii_dsal ,nameprefix,...
        intermediate_steps,diff, lb, ub, save_test, safetyalpha, mc_disc, num_reps, xnew, rsd, ccc)
    ccc = ccc + 1;
    end
    if sum(t) > t_cap
        
        break
    end
    
    new_ramp = create_ramp(xIn, xnew,intermediate_steps);
    %%%%% Perform measurements %%%%%
    xIn = [xIn ; new_ramp(end, :) ];
    yIn = [ yIn; model(xIn(end,:),noise) ];
    yInhealth = [yInhealth; modelhealth(xIn(end,:),noise2)  ];
    
    % update models
    [explModel,healthModel] = learn_models(  explModel, healthModel, xIn , yIn , yInhealth, 0);
    %
    %%%%%%%%%%%%% Evaluation of RMSE and health coverage  %%%%%%%%%%%%%%%
    evaluation(explModel,healthModel,xIn,model_choice,modelhealth_choice,5000,ii_dsal ,nameprefix,...
        intermediate_steps,diff, lb, ub, save_test, safetyalpha)
       
end
%
evals = evals(1:ii_dsal, 1);
t = t(1:ii_dsal, 1);
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
save(['output/', str, '/', num2str(rsd), 'evals.mat'], "evals")
save(['output/', str, '/', num2str(rsd), 'time.mat'], "t");
movefile(['output/', str, '/methods.csv'], ['output/', str, '/', num2str(rsd), 'methods.csv']);
dlmwrite(  ['output/', str, '/',nameprefix,'x_train.csv'] ,[ xIn, yIn , yInhealth],'delimiter','\t' );
dlmwrite(  ['output/', str, '/',nameprefix,'health_coverage.csv'] ,healthcoverage,'delimiter','\t' );

end
 