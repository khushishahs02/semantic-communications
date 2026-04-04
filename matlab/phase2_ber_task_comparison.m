%% PHASE 2: BER VS TASK ERROR COMPARISON
% Key Research Question: Does high bit-level accuracy guarantee 
% high task-level accuracy?
%
% Analysis:
%   - Plot BER vs Task Accuracy
%   - Show graceful degradation
%   - Demonstrate semantic robustness
%
% OUTPUT: Figure for paper

clear; clc;

fprintf('=== BER VS TASK ERROR ANALYSIS ===\n\n');

%% Load Noise Results
data = readtable('../data/results/phase2_noise.csv');

%% Aggregate by SNR
SNR_levels = unique(data.SNR_dB);
n_snr = length(SNR_levels);

avg_ber = zeros(n_snr, 1);
nat_accuracy = zeros(n_snr, 1);
sem_accuracy = zeros(n_snr, 1);

for i = 1:n_snr
    subset = data(data.SNR_dB == SNR_levels(i), :);
    
    avg_ber(i) = mean(subset.measured_BER);
    nat_accuracy(i) = mean(subset.natural_task_correct) * 100;
    sem_accuracy(i) = mean(subset.semantic_task_correct) * 100;
end

%% Calculate Task Error Rate (inverse of accuracy)
nat_error = 100 - nat_accuracy;
sem_error = 100 - sem_accuracy;

%% Display Table
fprintf('BER vs Task Error Comparison:\n');
fprintf('BER          | Natural Error | Semantic Error | Improvement\n');
fprintf('-------------|---------------|----------------|------------\n');
for i = 1:n_snr
    improvement = nat_error(i) - sem_error(i);
    fprintf('%.2e | %12.1f%% | %13.1f%% | %10.1f%%\n', ...
        avg_ber(i), nat_error(i), sem_error(i), improvement);
end
fprintf('\n');

%% Key Finding
fprintf('=== KEY FINDING ===\n');
fprintf('At BER = %.2e:\n', avg_ber(1));
fprintf('  Natural language error: %.1f%%\n', nat_error(1));
fprintf('  Semantic error: %.1f%%\n', sem_error(1));
fprintf('  → Semantic is %.1fx more robust\n\n', nat_error(1)/sem_error(1));