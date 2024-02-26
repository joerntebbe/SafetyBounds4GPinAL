% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

folders = struct('output_ana', struct('eval', [], 'health', [], 'xtrain', []), ...
                 'output_sim', struct('eval', [], 'health', [], 'xtrain', []));

intermediate = 5;
alphas = [0.1, 0.01, 0.001];
filename = "output_1";
 folder_names = ["MC", "AMC", "AB", "BC"];
 seeds = 1:10;
 endvals = zeros(length(alphas), length(seeds), 6, length(folder_names));
 endvals_1 = endvals;
 endvals_2 = endvals;
 fileID = fopen(strcat(filename, ".txt"), 'w');
 fprintf(fileID, '\\begin{tabular}{|c|c|c|c|c|}\n \\hline \n method / $\\alpha$ & $n_{SAL}$ & RMSE & $c_h$ & $n_f$ \\\\ \n \\hline \n \\hline \n');

 for j=1:length(alphas)
    for k=1:length(folder_names)
    for ii =1:length(seeds)
    path = strcat(filename, folder_names(k), '/intermediate_', num2str(intermediate), '_alpha', erase(num2str(alphas(j)), '.'));
% RMSE
evals = importevals(strcat(path, '/', num2str(seeds(ii)), 'opt-all_eval_tab1.csv'));
endvals(j, ii, 1, k) = evals(end, end);
folders.output_ana.eval = importevals(strcat(path, '/', num2str(seeds(ii)), 'opt-all_eval_tab1.csv'));
% Health coverage
folders.output_ana.health = importhealthcoverage(strcat(path, '/', num2str(seeds(ii)), 'opt-all_health_coverage.csv'));
endvals(j, ii, 2, k) = (10000 - folders.output_ana.health(end, 4) - folders.output_ana.health(end, 5))./10000;
endvals(j, ii, 3, k) = folders.output_ana.health(end, 4);

endvals(j, ii, 4, k) = folders.output_ana.health(end, 3);
endvals(j, ii, 5, k) = folders.output_ana.eval(end, 2);
endvals(j, ii, 6, k) = length(importxtrain(strcat(path, '/', num2str(seeds(ii)), 'opt-all_x_train.csv')));
endvals(j, ii, 6, k) = length(evals);
folders.output_ana.xtrain = importxtrain(strcat(path, '/', num2str(seeds(ii)), 'opt-all_x_train.csv'));
    end
    endvals_size = size(endvals);
    endvals_tmp = reshape(endvals(j, :, :, :), endvals_size(2:end));
    endvals_mean = reshape(mean(endvals_tmp, 1), endvals_size(3:end));
    endvals_std = reshape(std(endvals_tmp, 0, 1), endvals_size(3:end));
    fprintf(fileID, [convertStringsToChars(folder_names(k)), ' / ', num2str(alphas(j)), ' & ']);
    fprintf(fileID, '%3.1f $\\pm$ %3.1f & ',endvals_mean(6, k), endvals_std(6, k) );
    fprintf(fileID, '%1.4f $\\pm$ %1.4f & ',endvals_mean(1, k), endvals_std(1, k) );
    fprintf(fileID, '%1.4f $\\pm$ %1.4f &',endvals_mean(2, k), endvals_std(2, k) );
    fprintf(fileID, '%1.4f $\\pm$ %1.4f ',endvals_mean(5, k), endvals_std(5, k) );
    fprintf(fileID, '\\\\ \n \\hline \n');
    end
 end
 fprintf(fileID, '\\end{tabular}');
 fclose(fileID);
