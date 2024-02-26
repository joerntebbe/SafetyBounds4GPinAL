% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function plotfunc(xIn, n_pts, lb, ub, evaluation)

arr = linspace(lb, ub, n_pts);
[x, y] = meshgrid(arr, arr);
z = zeros(n_pts, n_pts);
for i=1:n_pts
    for j=1:n_pts
        z(i, j) = himmelblau([x(i, j), y(i, j)], 0);
    end
end

hold on;
[M,c] = contour(x, y, z, [0. 0.], 'r');
c.LineWidth = 2.5;
hold on;
plot(xIn(:, 1), xIn(:, 2), 'ko-', 'MarkerSize', 4);
end