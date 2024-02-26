% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function comparison(alphavalues, method, eval_cap, t_cap, int_steps)

lb=-3.;
ub = 3.;

warning('off', 'MATLAB:nearlySingularMatrix');
diff = 1.2;
num_reps = 0;
mc_disc = [0, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200, ...
    102400, 204800, 409600, 819200];
for jj = 1 : length(alphavalues)
    clc
    diary on
    
    hyps = zeros(4,0);
    hypse = zeros(4,0);
    
    str = ['intermediate_5_alpha',strrep( num2str( alphavalues(jj) ), '.','') ];
    
    mkdir( ['output/',str] );
    
    for ii = 1:10
        run_all('find_new_point',  ii,[num2str(ii),'opt-all_'],  'all', 'obj_func2' , int_steps , alphavalues(jj), diff ,lb, ub, method, eval_cap, mc_disc, num_reps, t_cap);
    end
end

