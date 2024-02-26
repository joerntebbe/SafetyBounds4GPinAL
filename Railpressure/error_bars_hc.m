folders = struct('output_ana', struct('eval', [], 'health', [], 'xtrain', []), ...
                 'output_sim', struct('eval', [], 'health', [], 'xtrain', []));

intermediate = 5;
alphas = [0.1, 0.01, 0.001];
alphas_legend = {"$10^{-1}$", "$10^{-2}$", "$10^{-3}$"};
folder_base = 'output_2';

 legend_line = ["MC", "AMC", "AB" ,"ABM"];
 folder_names = {[folder_base, 'MC'], [folder_base, 'AMC'], [folder_base, 'AB'],[folder_base, 'BC']};
 lines = {"-", "-", "-", "-"};
 seeds = 1:10;
 endvals = zeros(length(alphas), length(seeds), 6);
 endvals_1 = endvals;
 endvals_2 = endvals;
 arr_size = 100;
 colors = 1/255 .* [[53 183 121]; [49 104 142]; [68 1 84]; [253 231 37]];
val_arr = zeros(arr_size, 3, length(alphas), length(folder_names), length(seeds));
 mean_arr = zeros(arr_size, 3,length(alphas), length(folder_names));
 std_arr = zeros(arr_size, 3,length(alphas), length(folder_names));
 interp_arr = logspace(3, 9, arr_size);
 interp_arr = linspace(0, 15, arr_size);
plot_xx = 'Runtime';

ax11 = [];
ax1 = [];
ax2 = [];
for j=1:length(alphas)
    figure;
    hold on;
    sgtitle(['$\alpha$ = ', num2str(alphas(j))], 'Interpreter', 'latex')
    t_max = 1e24;
    eval_max = 1e24;
    for k=1:length(folder_names)
    for ii =1:length(seeds)
        
    path = strcat(cell2mat(folder_names(k)), '/intermediate_', num2str(intermediate), '_alpha', erase(num2str(alphas(j)), '.'));
    load(strcat(path, "/", num2str(seeds(ii)), "time.mat"))
    load(strcat(path, "/", num2str(seeds(ii)), "evals.mat"))
    t_max = min(t_max, sum(t));
    eval_max = min(eval_max, sum(evals));
    end
    interp_arr = linspace(0, 900, arr_size);
    for ii =1:length(seeds)
        path = strcat(cell2mat(folder_names(k)), '/intermediate_', num2str(intermediate), '_alpha', erase(num2str(alphas(j)), '.'));
    load(strcat(path, "/", num2str(seeds(ii)), "time.mat"))
evals = [0; t];

num_evals = evals; 
evals_cum = cumsum(num_evals); 
while any(diff(evals_cum) == 0)
diff_arr = diff(evals_cum); 
evals_cum = evals_cum + ([zeros(1,1); diff_arr == 0]);
end
plot_evals = evals_cum(1:end);

folders.output_ana.eval = importevals(strcat(path, '/', num2str(seeds(ii)), 'opt-all_eval_tab1.csv'));
try
val_arr(:, 1, j, k, ii) = interp1(plot_evals(1:end - 1), folders.output_ana.eval(2:end, end), interp_arr);
catch
    try
    val_arr(:, 1, j, k, ii) = interp1(plot_evals(1:end), folders.output_ana.eval(2:end, end), interp_arr);
    catch
        val_arr(:, 1, j, k, ii) = interp1(plot_evals(1:end), folders.output_ana.eval(1:end, end), interp_arr);
    end
end
folders.output_ana.health = importhealthcoverage(strcat(path, '/', num2str(seeds(ii)), 'opt-all_health_coverage.csv'));
endvals(j, ii, 2) = (folders.output_ana.health(end, 2) - folders.output_ana.health(end, 4))./(folders.output_ana.health(end, 2));
% plot(folders.output_ana.health(:, 1), (folders.output_ana.health(:, 3) - folders.output_ana.health(:, 5))./(folders.output_ana.health(:, 2)), 'Color', colors(k, :))
hc_c = (10000 - folders.output_ana.health(:, 4) - folders.output_ana.health(:, 5))./(10000);
try
val_arr(:, 2, j, k, ii) = interp1(plot_evals(1:end - 1), hc_c(1:end, :), interp_arr);
catch
    try
    val_arr(:, 2, j, k, ii) = interp1(plot_evals(1:end), hc_c(1:end, :), interp_arr);
    catch
        val_arr(:, 2, j, k, ii) = interp1(plot_evals(1:end - 1), hc_c(2:end, :), interp_arr);
    end
end
endvals(j, ii, 6) = length(importxtrain(strcat(path, '/', num2str(seeds(ii)), 'opt-all_x_train.csv')));
folders.output_ana.xtrain = importxtrain(strcat(path, '/', num2str(seeds(ii)), 'opt-all_x_train.csv'));
    end
    std_arr(:, :, j, k) = nanstd(val_arr(:, :, j, k, :), [], 5);
    mean_arr(:, :, j, k) = nanmean(val_arr(:, :, j, k, :), 5);
    plot_x = [interp_arr, fliplr(interp_arr)];
    plot_y1 = mean_arr(:, 2, j, k) + std_arr(:, 2, j, k);
    plot_y2 = mean_arr(:, 2, j, k) - std_arr(:, 2, j, k);
    plot_y = cat(1, plot_y1, fliplr(plot_y2')');
    ax11_tmp = subplot(1, 4, k, 'FontSize', 24, 'FontName', 'Arial');
    hold on;
    title(legend_line(k), 'Interpreter','latex')
    patch(plot_x, plot_y(:, 1), colors(k, :));
    plot(interp_arr, mean_arr(:, 2, j, k), 'k-');
    set(gca, 'TickLabelInterpreter', 'latex')
    hold on;
    xlim([0, 900]);
    ylim([0.3,0.7]);
    ylabel('$c_h$', 'Interpreter','latex')
    box on;
    grid on; 
    end
end