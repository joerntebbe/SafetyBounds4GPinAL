% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y = find_new_point(explModel,healthModel,n_multistart,xIn,intermediate_steps,~,~,obj_choice,ran,safetyalpha, method, ii_dsal, samples)
obj_func = str2func( obj_choice );
options = optimset('FinDiffRelStep',[0.5,0.05],'Algorithm','interior-point','AlwaysHonorConstraints','none','GradObj','off','TolFun',1e-15,'TolCon',1e-15,'GradConstr','off','MaxIter',100,'Display','off');  

str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
fid = fopen(['output/', str, '/health_vals.csv'], 'w');
fclose(fid);

lbounds = [ 1000,0];
ubounds = [4000,60];
global places
placesP = places;
%
grid1 = zeros(n_multistart,4);
grid2 = zeros(n_multistart,4);
str = ['intermediate_5_alpha',strrep( num2str( safetyalpha ), '.','') ];
for ii_multistart=1:n_multistart
    obj_func = str2func( obj_choice );
    xstart = [];kk=0;
    while isempty(xstart)  & kk <= 2
        kk = kk + 1;
        rr1 =  lbounds + (ubounds-lbounds).*rand(1,2);
        hc = health_constr(healthModel,xIn,rr1,intermediate_steps,ran,safetyalpha, method, num2str(ii_dsal), samples);
        if hc <= 0 
            xstart = rr1;
        end
    end
    if isempty(xstart)
       grid1( ii_multistart , :) = [[0 0], 0 ,0 ];
       xstart =  lbounds + (ubounds-lbounds).*rand(1,2);
    else
       grid1( ii_multistart , :) = [xstart, obj_func(explModel,xIn,xstart,intermediate_steps) ,1 ];
    end
    [xnew,varopt,exitflag] = fmincon( @(x) obj_func(explModel,xIn,x,intermediate_steps), xstart,[],[],[],[],lbounds,ubounds, @(x) health_constr(healthModel,xIn,x,intermediate_steps,ran,safetyalpha, method, num2str(ii_dsal), samples), options);
    grid2(ii_multistart,:) = [xnew,varopt,exitflag];
end
grid = [grid1;grid2];
grid_feasible = grid(  grid(:,end) >=  1 ,: );
%
%
if isempty(grid_feasible)
    %%%%%%%%%%    -> go back to safe area
    disp('  Go back to safe area');
    %lbounds = [ max(2200, xIn(end,1) - 10 * intermediate_steps), max(24,xIn(end,5) - 5 * intermediate_steps)  ]; 
    %ubounds = [ min(2800, xIn(end,1) + 10 * intermediate_steps),  min(36,xIn(end,5) + 5 * intermediate_steps) ];
    
    y = [2200,24] + [600,12].*rand(1,2);
else
    best = grid_feasible( grid_feasible(:,3) == min( grid_feasible(:,3) ),:);
    y = best(1,1:2);    
end
%
movefile(['output/', str, '/health_vals.csv'], ['output/', str, '/health_vals_', num2str(ii_dsal), '.csv']);
end