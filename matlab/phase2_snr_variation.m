%% PHASE 2: SNR VARIATION ANALYSIS
% Tests graceful degradation under varying channel conditions
%
% Questions Answered:
%   1. Does semantic degrade more gracefully?
%   2. What is the critical SNR threshold?
%   3. Bandwidth efficiency under constraints
%
% OUTPUT: SNR sweep data

clear; clc;

fprintf('=== SNR VARIATION ANALYSIS ===\n\n');

%% Load Data
noise_data = readtable('../data/results/phase2_noise.csv');

%% Extract Unique SNR Levels
SNR_levels = unique(noise_data.SNR_dB);

%% Calculate Metrics for Each SNR
results = table();

for i = 1:length(SNR_levels)
    snr = SNR_levels(i);
    subset = noise_data(noise_data.SNR_dB == snr, :);
    
    % Metrics
    results.SNR_dB(i) = snr;
    results.avg_BER(i) = mean(subset.measured_BER);
    results.natural_accuracy(i) = mean(subset.natural_task_correct);
    results.semantic_accuracy(i) = mean(subset.semantic_task_correct);
    
    % Graceful degradation metric
    % How much does accuracy drop per dB decrease?
    if i > 1
        snr_drop = SNR_levels(i-1) - snr;
        nat_drop = results.natural_accuracy(i-1) - results.natural_accuracy(i);
        sem_drop = results.semantic_accuracy(i-1) - results.semantic_accuracy(i);
        
        results.natural_degradation_rate(i) = nat_drop / snr_drop;
        results.semantic_degradation_rate(i) = sem_drop / snr_drop;
    else
        results.natural_degradation_rate(i) = 0;
        results.semantic_degradation_rate(i) = 0;
    end
end

%% Find Critical SNR (50% accuracy threshold)
nat_critical_idx = find(results.natural_accuracy >= 0.5, 1, 'last');
sem_critical_idx = find(results.semantic_accuracy >= 0.5, 1, 'last');

nat_critical_snr = results.SNR_dB(nat_critical_idx);
sem_critical_snr = results.SNR_dB(sem_critical_idx);

fprintf('=== CRITICAL SNR THRESHOLDS ===\n');
fprintf('Natural Language:  %.1f dB (50%% accuracy)\n', nat_critical_snr);
fprintf('Semantic:          %.1f dB (50%% accuracy)\n', sem_critical_snr);
fprintf('Semantic advantage: %.1f dB\n\n', nat_critical_snr - sem_critical_snr);

%% Save Results
writetable(results, '../data/results/phase2_snr_analysis.csv');
fprintf('✓ Saved phase2_snr_analysis.csv\n\n');