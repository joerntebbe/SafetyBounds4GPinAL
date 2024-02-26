% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evaluation_2(obj,obj2,xIn,func00,func01,n_test,ii_dsal,nameprefix,intermediate_steps,...
    diff, lb, ub ,eval_grid, safetyalpha, mc_disc, num_reps, xnew, rsd, tval)
func0 = str2func(func00);
func1 = str2func(func01);
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
health_vals = zeros(0, 3);
save(['output/', str, '/health_vals.mat'], "health_vals");
%
%%% Number unsafe points
tab1 = zeros( size(xIn,1), 1);
for jj=1:size(xIn,1)
    tab1(jj) = func1( xIn(jj,:),0 );
end
n_bad_points = sum( tab1 < 0 );
%
%%%  Test wrt safe area
tab_test = [];
zw1 = func0(eval_grid, 0);
[~, ~, zw2, fs2] = gp_predict(obj, eval_grid, 1);
tab_test = [(zw1 - zw2).^2, zw1, zw2, fs2];

rmse2 = sqrt( sum( tab_test(:,end))/length(tab_test(:,end))  );
%
%%% Print out to csv file
out = [ii_dsal,n_bad_points,000, rmse2];
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
if exist(['output/', str, '/',nameprefix,'eval_tab2.csv'],'file')==2  
     abc = dlmread(['output/', str, '/',nameprefix,'eval_tab2.csv']  ); 
else   
     abc = zeros(1,4);   
end     
abc2 = [abc;out];     

dlmwrite(  ['output/', str, '/',nameprefix,'eval_tab2.csv'] ,abc2,'delimiter','\t' );  
%
%%%%%%%%%%%%%%%%  how much does safe area cover
tab_test2 = [];
traj_test_2 = [];

arr = linspace(lb, ub, 366);
[x, y] = meshgrid(arr, arr);
eval_grid_2 = [x(:) y(:)];
[~, ~, hcgp, fs2] = gp_predict(obj2, eval_grid_2, 1);
hc = func1(eval_grid_2, 0);
tab_test2 = [hc, hcgp, fs2];
tabx2 = tab_test2;
se_health = (tab_test2(:,1) - tab_test2(:,2)).^2;
zw1 = sum(  tab_test2( tab_test2(:,1)>0 , 2) < 0   );
zw2 = sum(  tab_test2(  tab_test2(:,2)>0 , 1) < 0   );
zw3 = [ii_dsal,  sum( tab_test2(:,1)>0 ), sum((tab_test2(:,2)>0)) , zw1 , zw2 ];

plotfunc(xIn, 100, lb, ub)
[M, c] = contour(x, y, reshape(hcgp, [sqrt(numel(hcgp)), sqrt(numel(hcgp))]), [0. 0.], 'g--');
c.LineWidth = 2.5;
if ii_dsal < 10
    indx = ['00', num2str(ii_dsal)];
elseif ii_dsal < 100
    indx = ['0', num2str(ii_dsal)];
else
    indx = num2str(ii_dsal);
end
axis equal;

set(gca, 'TickLabelInterpreter', 'latex')
set(gca, 'FontSize', 24)
xticks([-3, -2, -1, 0, 1, 2, 3])
yticks([-3, -2, -1, 0, 1, 2, 3])
title(['t=', num2str(tval), ', n=', num2str(length(xIn)), ' Ours'], 'Interpreter', 'latex')
savefig(['output/', str, '/', num2str(rsd), 'Plot_', indx])
close;
movefile(['output/', str, '/health_vals.mat'], ['output/', str, '/health_vals_evals_', num2str(ii_dsal), '.mat']);
end