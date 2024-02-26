% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

alphavalues = [0.001, 0.01, 0.1];
methods = ["AMC", "AB", "BC", "MC"];
eval_cap = [1e15, 1e15, 1e15, 1e15];
t_cap = [1000, 1000, 1000, 1000];
for j=1:length(eval_cap)
    for i=1:length(alphavalues)
        comparison(alphavalues(i), methods(j), eval_cap(j), t_cap(j), 0);
    end
    
    movefile("output", strcat("output_", methods(j)));
    delete output/*
    try
        rmdir output s
    end
end