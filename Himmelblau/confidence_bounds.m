function [lb, ub] = confidence_bounds(safetyalpha, k, eps, M)


c_2 = 2/M * abs(log(6 * eps/(pi^2 * k^2)));

ub = safetyalpha + (c_2/4 + sqrt(c_2 * safetyalpha));
lb = safetyalpha - sqrt(c_2 * safetyalpha * (1 - safetyalpha));