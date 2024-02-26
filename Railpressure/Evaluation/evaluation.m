% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evaluation(obj,obj2,xIn,func00,func01,n_test,ii_dsal,nameprefix,intermediate_steps, safetyalpha )
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
tabxx = zeros(n_test/5, 5*11);
for i=1:n_test/5
    func0 = str2func(func00);
    func1 = str2func(func01);
    tabx = [];
    while length(tabx) < 1
        rr1s = 1000 + 3000 * rand(1,1);
        rr1e = 1000 + 3000 * rand(1,1);
        rr5s = 0 + 60*rand(1,1);
        rr5e = 0 + 60*rand(1,1);
        %
        xIn = [ 
        2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 ;
        2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 ;
        rr1s 2500 2500 2500 rr5s 30 30 0.7 0.7 0.7
        ]; 
        % 
        traj0 = create_ramp(xIn,[rr1e,rr5e],8);
        traj1 = traj0(end-4:end,:);
        hc = zeros(1,5);
        for jj=1:5
             hc(jj) = func1(traj1(jj,:));
        end
        if prod(hc>0) == 1
            for jj = 1 : 5
                zw1 = func0( traj1(jj,:));
                zw2 = gp_predict( obj,traj1(jj,:), "Explore" );
                tabx = [tabx; [traj1(jj,:),(zw1-zw2)^2 ]];
            end
            tabxx(i,:) = [ tabx(1,:), tabx(2,:), tabx(3,:), tabx(4,:),tabx(5,:)];
        end
    end
end
tab_test = zeros(n_test,11);
for i = 1 : length(tabxx)
    for jj = 1 : 5
        tab_test( 5*(i-1) + jj,: ) = tabxx(i, 11*(jj-1)+1:11*jj );
    end
end
rmse2 = sqrt( sum( tab_test(:,end))/length(tab_test(:,end))  );
%
%%% Print out to csv file
out = [ii_dsal,n_bad_points,000, rmse2];
if exist(['output/', str, '/',nameprefix,'eval_tab1.csv'],'file')==2  
     abc = dlmread(['output/', str, '/',nameprefix,'eval_tab1.csv']  ); 
else   
     abc = zeros(1,4);   
end     
abc2 = [abc;out];       
dlmwrite(  ['output/', str, '/',nameprefix,'eval_tab1.csv'] ,abc2,'delimiter','\t' );  
%
%%%%%%%%%%%%%%%%  how much does safe area cover
tabxx2 = zeros(n_test/5,5*2);
for i=1:n_test/5
    func1 = str2func(func01);
    tabx2 = [];
    while length(tabx2) < 1
        rr1s = 1000 + 3000 * rand(1,1);
        rr1e = 1000 + 3000 * rand(1,1);
        rr5s = 0 + 60*rand(1,1);
        rr5e = 0 + 60*rand(1,1);
        %
        xIn = [ 
            2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 ;
            2500 2500 2500 2500 30 30 30 0.7 0.7 0.7 ;
            rr1s 2500 2500 2500 rr5s 30 30 0.7 0.7 0.7
          ]; 
      % 
      traj0 = create_ramp(xIn,[rr1e,rr5e],8);
      traj1 = traj0(end-4:end,:);     
      for jj=1:5
          hc = func1(traj1(jj,:));
          hcgp = gp_predict(obj2, traj1(jj,:), "Health" );
          tabx2 = [tabx2; [hc, hcgp]];
      end 
    end
    tabxx2 (i,:) = [ tabx2(1,:), tabx2(2,:), tabx2(3,:), tabx2(4,:),tabx2(5,:)];
end      
tab_test2 = zeros(n_test,2);
for i = 1 : length(tabxx2)
    for jj = 1 : 5
        tab_test2( 5*(i-1) + jj,: ) = tabxx2(i, 2*(jj-1)+1:2*jj );
    end
end
zw1 = sum(  tab_test2( tab_test2(:,1)>0 , 2) < 0   );
zw2 = sum(  tab_test2(  tab_test2(:,2)>0 , 1) < 0   );
zw3 = [ii_dsal,  sum( tab_test2(:,1)>0 ), sum(tab_test2(:,2)>0) , zw1 , zw2 ];
global healthcoverage
healthcoverage =[ healthcoverage; zw3]; 
movefile(['output/', str, '/health_vals.mat'], ['output/', str, '/health_vals_eval_', num2str(ii_dsal), '.mat']);
end