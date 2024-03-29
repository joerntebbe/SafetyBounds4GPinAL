% Copyright (c) 2024 Jörn Tebbe
% All rights reserved.
% This source code is licensed under the BSD license found in the
% LICENSE file in the root directory of this source tree.
% @author: Jörn Tebbe 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function optallhealthcoverage = importhealthcoverage(filename, dataLines)
%IMPORTFILE Import data from a text file
%  OPTALLHEALTHCOVERAGE = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the numeric data.
%
%  OPTALLHEALTHCOVERAGE = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  optallhealthcoverage = importfile("C:\Users\Tebbe\PycharmProjects\chaining\Dynamic-Safe-Active-Learning\Himmelblau\output_ana\intermediate_5_alpha02\6opt-all_health_coverage.csv", [1, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 27-Apr-2023 08:27:00

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [1, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "\t";

% Specify column names and types
opts.VariableNames = ["VarName1", "VarName2", "VarName3", "VarName4", "VarName5"];
opts.VariableTypes = ["double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
optallhealthcoverage = readtable(filename, opts);

%% Convert to output type
optallhealthcoverage = table2array(optallhealthcoverage);
end