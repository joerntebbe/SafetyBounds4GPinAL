% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evaluation_2(obj,obj2,xIn,func00,func01,n_test,ii_dsal,nameprefix,intermediate_steps, safetyalpha, xnew )
%
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
health_vals = zeros(0, 3);
save(['output/', str, '/health_vals.mat'], "health_vals");
func1 = str2func(func01);
%%% Number unsafe points
tab1 = zeros( size(xIn,1), 1);
for jj=1:size(xIn,1)
    tab1(jj) = func1( xIn(jj,:) );
end
n_bad_points = sum( tab1 < 0 );
%
%%%  Test wrt learned as safe area
tabxx = zeros(n_test, 14);
for i=1:n_test
    func0 = str2func(func00);
    func1 = str2func(func01);
    tabx = [];
    while length(tabx) < 1
        rr1s = 1000 + 3000 * rand(1,1);
        rr1e = 1000 + 3000 * rand(1,1);
        rr5s = 0 + 60*rand(1,1);
        rr5e = 0 + 60*rand(1,1);
        %
        % 
        % traj0 = create_ramp(xIn,[rr1e,rr5e],8);
        traj1 = [rr1s, xIn(end, 1), xIn(end, 2), xIn(end, 3), rr5s, xIn(end, 5), xIn(end - 1, 6), 0.7, 0.7, 0.7];
        hc = func1(traj1);
        % hc = zeros(1,5);
        % for jj=1:5
        %      hc(jj) = func1(traj1(jj,:));
        % end
        if hc>0
                zw1 = func0( traj1);
                [~, ~, zw2, fs2] = gp_predict( obj,traj1, "Explore");
                tabx = [tabx; [traj1,(zw1-zw2)^2, zw1, zw2, fs2 ]];
                tabxx(i,:) = tabx;
        end
        
    end
end
tab_test = tabxx;
% for i = 1 : length(tabxx)
%     for jj = 1 : 5
%         tab_test( 5*(i-1) + jj,: ) = tabxx(i, 11*(jj-1)+1:11*jj );
%     end
% end
rmse2 = sqrt( sum( tab_test(:,end))/length(tab_test(:,end))  );
%
%%% Print out to csv file
out = [ii_dsal,n_bad_points,000, rmse2];
if exist(['output/', str, '/',nameprefix,'eval_tab2.csv'],'file')==2  
     abc = dlmread(['output/', str, '/',nameprefix,'eval_tab2.csv']  ); 
else   
     abc = zeros(1,4);   
end     
abc2 = [abc;out];       
dlmwrite(  ['output/', str, '/',nameprefix,'eval_tab2.csv'] ,abc2,'delimiter','\t' );  
%
%%%%%%%%%%%%%%%%  how much does safe area cover
tabxx2 = zeros(n_test,2);
tabx2 = [];
func1 = str2func(func01);
for i=1:n_test
    
    
        rr1s = 1000 + 3000 * rand(1,1);
        rr1e = 1000 + 3000 * rand(1,1);
        rr5s = 0 + 60*rand(1,1);
        rr5e = 0 + 60*rand(1,1);
        %
        traj1 = [rr1s, xIn(end, 1), xIn(end, 2), xIn(end, 3), rr5s, xIn(end, 5), xIn(end - 1, 6), 0.7, 0.7, 0.7];    
      
          hc = func1(traj1);
          [~, ~, hcgp, fs2] = gp_predict(obj2, traj1, 'Health' );
          tabx2 = [tabx2; [hc, hcgp, fs2]];
          tabxx2(i,:) = [rr1s, rr5s];
end      
tab_test2 = tabx2;
zw1 = sum(  tab_test2( tab_test2(:,1)>0 , 2) < 0   );
zw2 = sum(  tab_test2(  tab_test2(:,2)>0 , 1) < 0   );
zw3 = [ii_dsal,  sum( tab_test2(:,1)>0 ), sum(tab_test2(:,2)>0) , zw1 , zw2 ];
se_health = (tab_test2(:,1) - tab_test2(:, 2)).^2;
% close all
disp(['Mean', num2str(mean(tabx2, 1))])
disp(['Std', num2str(std(tabx2, 1))])
figure('units','normalized','outerposition',[0 0 1 1])
hold on;
subplot(2,4,1)
hold on;
title('SE Explore')
scatter(tab_test(:, 1), tab_test(:, 5), 1, tab_test(:,end - 3))
colorbar;
caxis([0. 10.0])
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 10)
plot(xIn(:,1), xIn(:, 5), 'r.')
subplot(2,4,2)
hold on;
title("Ground Truth Explore")
scatter(tab_test(:, 1), tab_test(:, 5), 1, tab_test(:,end - 2))
colorbar;
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 5)
plot(xIn(:,1), xIn(:, 5), 'r.')
subplot(2,4,3)
hold on;
title("GP Mean Explore")
scatter(tab_test(:, 1), tab_test(:, 5), 1, tab_test(:,end - 1))
colorbar;
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 5)
plot(xIn(:,1), xIn(:, 5), 'r.')
subplot(2,4,4)
hold on;
title("GP Variance Explore")
scatter(tab_test(:, 1), tab_test(:, 5), 1, tab_test(:,end))
colorbar;
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 5)
plot(xIn(:,1), xIn(:, 5), 'r.')
subplot(2,4,5)
hold on;
title("SE Health")
scatter(tabxx2(:, 1), tabxx2(:, 2), 1, se_health)
colorbar;
caxis([0, 1])
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 5)
plot(xIn(:,1), xIn(:, 5), 'r.')

subplot(2, 4, 6)
hold on;
title("True Health")
scatter(tabxx2(:, 1), tabxx2(:, 2), 1, tabx2(:, 1))
colorbar;
caxis([-2 1])
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 5)
plot(xIn(:,1), xIn(:, 5), 'r.')
subplot(2,4,7)
hold on;
title("GP Mean Health")
scatter(tabxx2(:, 1), tabxx2(:, 2), 1, tabx2(:, 2))
colorbar;
% caxis([-2 1])
plot(xnew(1), xnew(2), 'rx', 'MarkerSize', 5)
plot(xIn(:,1), xIn(:, 5), 'r.')

subplot(2,4,8)
hold on;
title("GP Variance Health")
scatter(tabxx2(:, 1), tabxx2(:, 2), 1, tabx2(:, 3))
colorbar;
% caxis([0 1])
plot(xnew(1), xnew(2), 'rx')
plot(xIn(:,1), xIn(:, 5), 'r.')
% drawnow;
savefig(['output/', str, '/Plot_', num2str(ii_dsal)])
close;
% plotfunc([], [100, 100], [1000, 0], 1, [4000, 60])
% global healthcoverage
% healthcoverage =[ healthcoverage; zw3]; 
movefile(['output/', str, '/health_vals.mat'], ['output/', str, '/health_vals_eval2_', num2str(ii_dsal), '.mat']);
end