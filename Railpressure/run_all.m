% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function run_all(inf_crit_choice,rsd,nameprefix,health_const_choice,obj_choice,m_steps,safetyalpha, eval_cap, method, mc_disc, t_cap, static_sample)
%
close all
addpath( genpath('.'), genpath('./../SPI-Toolbox/') )
delete( strcat('output/',nameprefix,'*.csv') )
warning('off', 'gp:chol_failed')
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];

% Algorithm parameters to play around with
number_initial_samples = 50;  %must be >1 as first is start point of trajectory
n_dsal_samples = 350;  % for now uneven number please because of subplot routine
intermediate_steps = m_steps;

n_multistart = 25;
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

noise = 1;
noise2 = .01;
plotQ = 0;

fid = fopen(['output/', str, '/methods.csv'], 'w');
fclose(fid);

ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 100 * (2^16));
ran = mvnrnd( zeros(intermediate_steps,1), diag(ones(intermediate_steps,1)) , 1e7);
samples_cell = cell(length(mc_disc), 1);
for iii=1:length(mc_disc) - 1
    samples_cell{iii} = ran(mc_disc(iii) + 1:mc_disc(iii + 1), :);
end
samples_cell{end} = ran(1:mc_disc(end - 1), :);
ran = samples_cell;
global healthcoverage 
healthcoverage = [];

model_choice = 'prist_w_FIR_3step';
n_col_plot = 6;
n_rows_plot = ceil(n_dsal_samples/n_col_plot);
modelhealth_choice = strcat(model_choice,'health');
model = str2func(model_choice);
modelhealth = str2func(modelhealth_choice);
inf_crit = str2func(inf_crit_choice);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%   Initialization  %%%%
%%%%%%%%%%%%%%%%%%%%%%  
%%%%   Initial safe trajectories  %%%%%%%
xIn = [ 
    2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 ;
    2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 ;
    2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 
    %%%%
    ]; 
yIn = [];
yInhealth = [];
for jj=1:size(xIn, 1)
yIn = [yIn;model( xIn(jj, :) ) + normrnd(0,noise)];
yInhealth = [yInhealth;modelhealth( xIn(jj, :) ) + normrnd(0,noise2)];
end
%
for ii = 1:number_initial_samples
    lbounds = [ max(2200, xIn(end,1) - 10 * intermediate_steps), max(24,xIn(end,5) - 5 * intermediate_steps)  ]; 
    ubounds = [ min(2800, xIn(end,1) + 10 * intermediate_steps)  ,  min(36,xIn(end,5) + 5 * intermediate_steps) ];
    rr1 = lbounds + (ubounds-lbounds).*rand(1,2);
    xIn = [xIn ; create_ramp(xIn, rr1,intermediate_steps) ];
    yIn = [ yIn; zeros(intermediate_steps,1) ];
    yInhealth = [yInhealth; zeros(intermediate_steps,1)  ];
    for jj=1:intermediate_steps
        yIn( end-intermediate_steps+jj) = model( xIn(end-intermediate_steps+jj,:)) + normrnd(0,noise);
        yInhealth( end-intermediate_steps+jj) = modelhealth( xIn(end-intermediate_steps+jj,:)) + normrnd(0,noise2);
    end
end


    
    
 
if plotQ
   figure 
   subplot(  n_rows_plot  ,n_col_plot ,1)
   plot_model_2d( model_choice, modelhealth_choice ,500,[],[])
   plot(xIn(:,1),xIn(:,2),'--','Color','red' )
   plot( xIn(2:end,1), xIn(2:end,2), 'o' )
end


%%%%%%%%% learn models initially

% xIn = xIn(3:end,:);
[explModel,healthModel] = learn_models([], [], xIn(:,:),yIn,yInhealth, false);
evaluation(explModel,healthModel,xIn,model_choice,modelhealth_choice,10000, 0 ,nameprefix,intermediate_steps, safetyalpha)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  Iteration DSAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
evals = zeros(n_dsal_samples, 1);
t = zeros(n_dsal_samples, 1);
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
for ii_dsal=1:n_dsal_samples
    disp(['*****',' Seed = ',num2str(RANDOMSEED) , ';   iter = ', num2str(ii_dsal),';  ',datestr( datetime ) ])
    ts = tic;
    global t_quantile;
    t_quantile = 0;
    xnew = inf_crit(explModel,healthModel,n_multistart,xIn,intermediate_steps,nameprefix,health_const_choice,obj_choice,ran,safetyalpha, method, ii_dsal, mc_disc);
    t(ii_dsal, 1) = toc(ts);
    t(ii_dsal, 1) = t(ii_dsal, 1) - t_quantile/2;
    evals(ii_dsal, 1) = get_evals(ii_dsal, str, method, mc_disc);
    disp([num2str(100*sum(evals)/eval_cap), '% of evals reached'])
    disp(['Time elapsed: ', num2str(sum(t)), 'seconds'])
    
    if sum(t) > t_cap
        break
    end
    xIn = [xIn ;create_ramp(xIn, xnew,intermediate_steps)];
    %
    %%%%% Measure %%%%%
    yIn = [ yIn; zeros(intermediate_steps,1) ];
    yInhealth = [yInhealth; zeros(intermediate_steps,1)  ];
    for jj=1:intermediate_steps
        yIn( end-intermediate_steps+jj) = model( xIn(end-intermediate_steps+jj,:)) + normrnd(0,noise);
        yInhealth( end-intermediate_steps+jj) = modelhealth( xIn(end-intermediate_steps+jj,:)) + normrnd(0,noise2);
    end
    %
    % update models
    [explModel,healthModel] = learn_models(  explModel, healthModel, xIn , yIn , yInhealth, -1);
    sta = number_initial_samples * intermediate_steps;
    [explModel,healthModel] = learn_models(explModel, healthModel,  explModel.xIn(sta:end,:) , explModel.yIn(sta:end,:) , healthModel.yIn(sta:end,:), safetyalpha );
    
    %%%%%%%%%%%%% Evaluation  %%%%%%%%%%%%%%%
    evaluation(explModel,healthModel,xIn,model_choice,modelhealth_choice,10000,ii_dsal ,nameprefix,intermediate_steps, safetyalpha)
end
%
evals = evals(1:ii_dsal, 1);
t = t(1:ii_dsal, 1);
save(['output/', str, '/', num2str(rsd), 'time.mat'], "t")
save(['output/', str, '/', num2str(rsd), 'evals.mat'], "evals")
movefile(['output/', str, '/methods.csv'], ['output/', str, '/', num2str(rsd), 'methods.csv']);
dlmwrite(  ['output/', str, '/',nameprefix,'x_train.csv'] ,[ xIn, yIn , yInhealth],'delimiter','\t' );
dlmwrite(  ['output/', str, '/',nameprefix,'health_coverage.csv'] ,healthcoverage,'delimiter','\t' );
end
 