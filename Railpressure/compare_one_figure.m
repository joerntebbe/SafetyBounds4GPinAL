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
alphas_legend = {"0.1", "0.01", "0.001"};
folder_base = 'output_2';
 legend_line = ["MC", "AMC", "AB" ,"ABM"];
 folder_names = {[folder_base, 'MC'],[folder_base, 'AMC'], [folder_base, 'AB'],[folder_base, 'BC']};
 seeds = 1:10;
 endvals = zeros(length(alphas), length(seeds), 6);
 endvals_1 = endvals;
 endvals_2 = endvals;
 arr_size = 100;
colors_2 = 1/255 .* [[53 183 121]; [49 104 142]; [68 1 84]; [253 56 37]];
 colors_3 = 1/255 .* [[237 121 83]; [156 23 158]; [13 8 135]];
 lines = {":", "-", ":", "-"};
val_arr = zeros(arr_size, 3, length(alphas), length(folder_names), length(seeds));
 mean_arr = zeros(arr_size, 3,length(alphas), length(folder_names));
 std_arr = zeros(arr_size, 3,length(alphas), length(folder_names));
plot_x = 'Runtime';
% plot_x = 'Samples';
figure;
hold on;
ax1 = [];
ax2 = [];
for j=1:length(alphas)
    
    t_max = 1e24;
    eval_max = 1e24;
    for k=1:length(folder_names)
%     for k=1:length(folders)
    for ii =1:length(seeds)
        
    path = strcat(cell2mat(folder_names(k)), '/intermediate_', num2str(intermediate), '_alpha', erase(num2str(alphas(j)), '.'));
    load(strcat(path, "/", num2str(seeds(ii)), "time.mat"))
    t_max = min(t_max, sum(t));
    end
    interp_arr = linspace(0, 900, arr_size);
    
    for ii =1:length(seeds)
        path = strcat(cell2mat(folder_names(k)), '/intermediate_', num2str(intermediate), '_alpha', erase(num2str(alphas(j)), '.'));
    load(strcat(path, "/", num2str(seeds(ii)), "time.mat"))
    load(strcat(path, "/", num2str(seeds(ii)), "evals.mat"))

    if length(evals) > length(t)
    evals = evals(1:length(t));
end
if strcmp(plot_x,'Runtime')
evals = [0; t];
eval_max = t_max;
end
num_evals = evals; 
evals_cum = cumsum(num_evals); 
while any(diff(evals_cum) == 0)
diff_arr = diff(evals_cum); 
evals_cum = evals_cum + ([zeros(1,1); diff_arr == 0]);
end
plot_evals = evals_cum(1:end);

subplot(1, 4, 2);
hold on;
title(strcat('RMSE'), 'Interpreter','latex')

folders.output_ana.eval = importevals(strcat(path, '/', num2str(seeds(ii)), 'opt-all_eval_tab1.csv'));
% plot(folders.output_ana.eval(2:end, 1), folders.output_ana.eval(2:end, end), 'Color', colors(k, :))

val_arr(:, 1, j, k, ii) = interp1(plot_evals(1:end - 1), folders.output_ana.eval(2:end, end), interp_arr);


subplot(1, 4, 3);

folders.output_ana.health = importhealthcoverage(strcat(path, '/', num2str(seeds(ii)), 'opt-all_health_coverage.csv'));
endvals(j, ii, 2) = (folders.output_ana.health(end, 2) - folders.output_ana.health(end, 4))./(folders.output_ana.health(end, 2));
% plot(folders.output_ana.health(:, 1), (folders.output_ana.health(:, 3) - folders.output_ana.health(:, 5))./(folders.output_ana.health(:, 2)), 'Color', colors(k, :))
hc_c = (10000 - folders.output_ana.health(:, 4) - folders.output_ana.health(:, 5))./(10000);
val_arr(:, 2, j, k, ii) = interp1(plot_evals(1:end - 1), hc_c(1:end, :), interp_arr);
endvals(j, ii, 6) = length(importxtrain(strcat(path, '/', num2str(seeds(ii)), 'opt-all_x_train.csv')));
folders.output_ana.xtrain = importxtrain(strcat(path, '/', num2str(seeds(ii)), 'opt-all_x_train.csv'));
    end
    mean_arr(:, :, j, k) = nanmean(val_arr(:, :, j, k, :), 5);
    end
    subplot(1, 4, 2, 'FontSize', 24, 'FontName', 'Arial');
    hold on;
    xlabel('Runtime [s]', 'Interpreter','latex')
    ylabel('RMSE', 'Interpreter','latex')
    title('AMC gain over MC', 'Interpreter','latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    plot(interp_arr, mean_arr(:, 1, j, 1) - mean_arr(:, 1, j, 2), '-', "Color", colors_3(j, :), 'LineWidth', 2.5);
    box on;
grid on;
legend(alphas_legend, 'Location','southoutside', 'Interpreter', 'latex', 'NumColumns', 3)
    subplot(1, 4, 3, 'FontSize', 24, 'FontName', 'Arial');
    hold on;
    xlabel('Runtime [s]', 'Interpreter','latex')
    ylabel('RMSE', 'Interpreter','latex')
    title('ABM gain over AMC', 'Interpreter','latex')
    set(gca, 'TickLabelInterpreter', 'latex')
    
    plot(interp_arr, mean_arr(:, 1, j, 2) - mean_arr(:, 1, j, 4), '-', "Color", colors_3(j, :), 'LineWidth', 2.5);
    box on;
grid on;
legend(alphas_legend, 'Location','southoutside', 'Interpreter', 'latex', 'NumColumns', 3)
subplot(1, 4, 4, 'FontSize', 24, 'FontName', 'Arial');
set(gca, 'TickLabelInterpreter', 'latex')

hold on;
    title('ABM gain over AMC', 'Interpreter','latex')
xlabel('Runtime [s]', 'Interpreter','latex')
    ylabel('Health Coverage', 'Interpreter','latex')
plot(interp_arr, mean_arr(:, 2, j, 4) - mean_arr(:, 2, j, 2), '-', "Color", colors_3(j, :), 'LineWidth', 2.5);
legend(alphas_legend, 'Location','southoutside', 'Interpreter', 'latex', 'NumColumns', 3)
str = [strrep( num2str( alphas(j) ), '.','') ];
box on;
grid on;

end
for k=1:length(folder_names)
    subplot(1, 4, 1, 'FontSize', 24, 'FontName', 'Arial')
    hold on;
    set(gca, 'TickLabelInterpreter', 'latex')
    title('$\alpha=0.001$', 'Interpreter','latex')
    xlabel('Runtime [s]', 'Interpreter','latex')
    ylabel('RMSE', 'Interpreter','latex')
    plot(interp_arr, squeeze(mean_arr(:, 1, end, k)), 'LineStyle', '-', 'Color', colors_2(k, :), 'LineWidth', 2.5)
    box on;
grid on;
    
end
legend(legend_line, 'Location','southoutside', 'Interpreter', 'latex', 'NumColumns', 4)