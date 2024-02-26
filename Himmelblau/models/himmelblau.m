function y = himmelblau(x, noise)

y = ((x(:, 1).^2 + x(:, 2) - 11).^2 + (x(:, 1) + x(:, 2).^2 - 7).^2 - 50);
y = 0.01 * y + noise * randn(length(y), 1);
end