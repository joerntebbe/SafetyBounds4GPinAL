% Copyright (c) 2018 Robert Bosch GmbH
% All rights reserved.
% This source code is licensed under the MIT license found in the
% LICENSE file in the root directory of this source tree.
% @author: Christoph Zimmer 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function comparison(alphavalues, method, eval_cap, t_cap, static_samples)
obj = struct('mean', [], 'cov', [0 0], 'lik', -1);
intermediate_steps = 5;
samples = [0, 100, 200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200, ...
    102400, 204800, 409600, 819200, 1638400, 3276800, 6553600];
for jj = 1 : length(alphavalues)
    clc
    diary on
    disp([ '*** alphavalue is :  ',num2str(alphavalues(jj)) ] );
    str = ['intermediate_5_alpha',strrep( num2str( alphavalues(jj) ), '.','') ];
    
    mkdir( ['output/',str] );
    
    hyps = zeros(4,0);
    hypse = zeros(4,0);
    
    meth_count = zeros(0, 4);
    
    save(strcat("output/", str, "/hyps.mat"), "hyps");
    save(strcat("output/", str, "/hypse.mat"), "hypse");
    save(strcat("output/", str, "/methods.mat"), "meth_count");
    diary(['output/',str,'3.txt'])
    for ii = 1 : 5
        run_all('find_new_point',  ii,[num2str(ii),'opt-all_'],  'all', 'obj_func2' , intermediate_steps , alphavalues(jj)  , eval_cap, method, samples, t_cap, static_samples);
    end
    
end
end