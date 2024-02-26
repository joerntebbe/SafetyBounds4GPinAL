% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alphavalues = [0.1, 0.01, 0.001];
methods = ["AMC", "MC", "AB", "BC"];
eval_cap = [1e10, 1e10, 1e10, 1e10];
t_cap = [60, 60, 60, 60];
intermediate_steps = 5;
delete output/*
try
rmdir output s
end
for j=1:length(methods)
    for i=1:length(alphavalues)
        str = ['intermediate_5_alpha',strrep( num2str( alphavalues(i) ), '.','') ];
        comparison(alphavalues(i), methods(j), eval_cap(j), t_cap(j), intermediate_steps);
    end
    movefile("output", strcat("output_1", methods(j)));
    delete output/*
    try
        rmdir output s
    end
end