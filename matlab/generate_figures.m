%% GENERATE ALL FIGURES FOR PAPER

clear; clc; close all;

fprintf('=== GENERATING FIGURES ===\n\n');

%% Load Data
phase1 = readtable('phase1_baseline.csv');
phase2 = readtable('phase2_noise.csv');

%% FIGURE 1: Storage Comparison
fprintf('Figure 1: Storage Comparison...\n');

% Semantic storage (manual calculation)
sem_bytes = ones(height(phase1), 1) * 26;  % Avg 26 bytes

fig1 = figure('Position', [100,100,700,500]);

% Subplot A
subplot(2,1,1);
plot(1:50, phase1.actual_bytes, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(1:50, sem_bytes, 'r-s', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Sentence ID');
ylabel('Storage (bytes)');
title('(a) Storage Requirements');
legend('Natural', 'Semantic');
grid on;

% Subplot B
subplot(2,1,2);
compression = phase1.actual_bytes ./ sem_bytes;
bar(compression, 'FaceColor', [0.4 0.7 0.4]);
hold on;
yline(mean(compression), 'r--', 'LineWidth', 2);
xlabel('Sentence ID');
ylabel('Compression Ratio');
title('(b) Compression Ratio');
ylim([0, 3]);
grid on;

saveas(fig1, 'fig_storage_comparison.png');
fprintf('✓ Saved fig_storage_comparison.png\n');

%% FIGURE 2: BER vs Task Accuracy
fprintf('Figure 2: BER vs Task...\n');

SNR_levels = unique(phase2.SNR_dB);
avg_ber = zeros(length(SNR_levels), 1);
nat_acc = zeros(length(SNR_levels), 1);
sem_acc = zeros(length(SNR_levels), 1);

for i = 1:length(SNR_levels)
    subset = phase2(phase2.SNR_dB == SNR_levels(i), :);
    avg_ber(i) = mean(subset.BER);
    nat_acc(i) = mean(subset.nat_accuracy) * 100;
    sem_acc(i) = mean(subset.sem_accuracy) * 100;
end

fig2 = figure('Position', [100,100,700,450]);
semilogx(avg_ber, nat_acc, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
semilogx(avg_ber, sem_acc, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);
xlabel('Bit Error Rate (BER)');
ylabel('Task Accuracy (%)');
title('BER vs Task-Level Accuracy');
legend('Natural', 'Semantic', 'Location', 'southwest');
grid on;
xlim([1e-18, 1e-1]);

saveas(fig2, 'fig_ber_task.png');
fprintf('✓ Saved fig_ber_task.png\n');

%% FIGURE 3: SNR vs Accuracy (Graceful Degradation)
fprintf('Figure 3: SNR Degradation...\n');

fig3 = figure('Position', [100,100,700,450]);
plot(SNR_levels, nat_acc, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
hold on;
plot(SNR_levels, sem_acc, 'r-s', 'LineWidth', 2, 'MarkerSize', 8);

% Shade unreliable region
fill([0 30 30 0], [0 0 50 50], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');

xlabel('SNR (dB)');
ylabel('Task Accuracy (%)');
title('SNR vs Task Accuracy: Graceful Degradation');
legend('Natural', 'Semantic', 'Location', 'southeast');
grid on;
xlim([0, 30]);
ylim([0, 105]);

saveas(fig3, 'fig_snr_degradation.png');
fprintf('✓ Saved fig_snr_degradation.png\n');

fprintf('\n✓ All figures generated!\n');