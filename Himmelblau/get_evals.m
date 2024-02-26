% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function evals = get_evals(iter, str, method, samples)
if method == "MC" || method == "B"
    try
        csv_read = dlmread(['output/', str, '/health_vals_2_', num2str(iter), '.csv']);
    catch
        csv_read = [0 0];
    end
    if method == "MC"
        evals = sum(csv_read(:, 2));
    elseif method == "B"
        evals = sum(csv_read(:, 2));
    end
    return
end
try
csv_read = dlmread(['output/', str, '/health_vals_', num2str(iter), '.csv']);
catch
csv_read = [0 0 0 0];
end
n_reps = size(csv_read, 1);
samples_rep = repmat(samples, [n_reps, 1]);

if method == "AB"
    evals = sum(samples_rep(sub2ind(size(samples_rep), (1:size(samples_rep, 1))', (csv_read(:, 2) + 1))));
elseif method == "AMC"
    evals = sum(samples_rep(sub2ind(size(samples_rep), (1:size(samples_rep, 1))', (csv_read(:, 2) + 1))));
elseif method == "MinIter"
    evals = sum(samples_rep(sub2ind(size(samples_rep), (1:size(samples_rep, 1))', min(csv_read(:, 3:4), [], 2) + 1)));
elseif method == "MaxIter"
    evals = sum(samples_rep(sub2ind(size(samples_rep), (1:size(samples_rep, 1))', max(csv_read(:, 3:4), [], 2) + 1)));
elseif method == "BC"
    evals = sum(samples_rep(sub2ind(size(samples_rep), (1:size(samples_rep, 1))', (csv_read(:, 2) + 1))));
    fid = fopen(['output/', str, '/methods.csv'], "a");
    fprintf(fid, strcat(num2str(sum(csv_read(:, 3) == -1)), ",", ...
        num2str(sum(csv_read(:, 3) == 1)), ",", ...
        num2str(sum(csv_read(:, 3) == 2)), ",", ...
        num2str(sum(csv_read(:, 3) == 3)), ",", ...
        "\n"));
    fclose(fid);
else 
    raise("Method not known!")
end
end

