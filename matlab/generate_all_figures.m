clear; clc; close all;
phase1_baseline = readtable('../data/results/phase1_baseline.csv');
phase1_comparison = readtable('../data/results/phase1_comparison.csv');
phase2_noise = readtable('../data/results/phase2_noise.csv');
fprintf('Generating Figure 1: Entropy Distribution...\n');
fig1 = figure('Position', [100, 100, 800, 350]);
% Subplot A: Character Entropy
subplot(1,2,1);
histogram(phase1_baseline.char_entropy, 12, ...
    'FaceColor', [0.2 0.4 0.8], 'EdgeColor', 'k', 'LineWidth', 1);
hold on;
xline(mean(phase1_baseline.char_entropy), 'r--', 'LineWidth', 2.5);
xlabel('Character Entropy (bits/char)', 'FontSize', 11);
ylabel('Frequency', 'FontSize', 11);
title('(a) Character-Level Entropy', 'FontSize', 12);
legend('Samples', sprintf('Mean = %.2f', mean(phase1_baseline.char_entropy)), ...
    'Location', 'northwest');
grid on; box on;
xlim([3.5, 5.0]);

% Subplot B: Word Entropy
subplot(1,2,2);
histogram(phase1_baseline.word_entropy, 12, ...
    'FaceColor', [0.8 0.4 0.2], 'EdgeColor', 'k', 'LineWidth', 1);
hold on;
xline(mean(phase1_baseline.word_entropy), 'r--', 'LineWidth', 2.5);
xlabel('Word Entropy (bits/word)', 'FontSize', 11);
ylabel('Frequency', 'FontSize', 11);
title('(b) Word-Level Entropy', 'FontSize', 12);
legend('Samples', sprintf('Mean = %.2f', mean(phase1_baseline.word_entropy)), ...
    'Location', 'northwest');
grid on; box on;

saveas(fig1, '../paper/figures/fig1_entropy_distribution.png');
fprintf('✓ Saved fig1_entropy_distribution.png\n');

% FIGURE 2: Storage Comparison
fprintf('Generating Figure 2: Storage Comparison...\n');

fig2 = figure('Position', [100, 100, 800, 500]);

% Subplot A: Byte Comparison
subplot(2,1,1);
x = phase1_comparison.sentence_id;
plot(x, phase1_comparison.natural_bytes, 'b-o', ...
    'LineWidth', 1.5, 'MarkerSize', 4, 'MarkerFaceColor', 'b');
hold on;
plot(x, phase1_comparison.semantic_bytes, 'r-s', ...
    'LineWidth', 1.5, 'MarkerSize', 4, 'MarkerFaceColor', 'r');
xlabel('Sentence ID', 'FontSize', 11);
ylabel('Storage (bytes)', 'FontSize', 11);
title('(a) Storage Requirements', 'FontSize', 12);
legend('Natural Language', 'Semantic Triples', 'Location', 'best');
grid on; box on;

% Subplot B: Compression Ratio
subplot(2,1,2);
bar(phase1_comparison.compression_ratio, ...
    'FaceColor', [0.4 0.7 0.4], 'EdgeColor', 'k', 'LineWidth', 0.5);
hold on;
yline(mean(phase1_comparison.compression_ratio), 'r--', 'LineWidth', 2.5);
xlabel('Sentence ID', 'FontSize', 11);
ylabel('Compression Ratio', 'FontSize', 11);
title('(b) Compression Ratio per Sentence', 'FontSize', 12);
legend('Compression Ratio', sprintf('Mean = %.2fx', ...
    mean(phase1_comparison.compression_ratio)), 'Location', 'best');
grid on; box on;
ylim([0, 3]);

saveas(fig2, '../paper/figures/fig2_storage_comparison.png');
fprintf('✓ Saved fig2_storage_comparison.png\n');

%% FIGURE 3: BER vs Task Accuracy
fprintf('Generating Figure 3: BER vs Task Accuracy...\n');

% Aggregate by SNR
SNR_levels = unique(phase2_noise.SNR_dB);
n_snr = length(SNR_levels);

avg_ber = zeros(n_snr, 1);
nat_acc = zeros(n_snr, 1);
sem_acc = zeros(n_snr, 1);

for i = 1:n_snr
    subset = phase2_noise(phase2_noise.SNR_dB == SNR_levels(i), :);
    avg_ber(i) = mean(subset.measured_BER);
    nat_acc(i) = mean(subset.natural_task_correct) * 100;
    sem_acc(i) = mean(subset.semantic_task_correct) * 100;
end

fig3 = figure('Position', [100, 100, 700, 450]);

semilogx(avg_ber, nat_acc, 'b-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
hold on;
semilogx(avg_ber, sem_acc, 'r-s', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('Bit Error Rate (BER)', 'FontSize', 12);
ylabel('Task Accuracy (%)', 'FontSize', 12);
title('BER vs Task-Level Accuracy', 'FontSize', 13);
legend('Natural Language', 'Semantic Communication', 'Location', 'southwest');
grid on; box on;
xlim([1e-18, 1e-1]);
ylim([0, 105]);

% Add reference line at 50%
yline(50, 'k--', 'LineWidth', 1.5, 'Alpha', 0.5);

saveas(fig3, '../paper/figures/fig3_ber_task_accuracy.png');
fprintf('✓ Saved fig3_ber_task_accuracy.png\n');

%% FIGURE 4: SNR vs Accuracy (Graceful Degradation)
fprintf('Generating Figure 4: SNR vs Accuracy...\n');

fig4 = figure('Position', [100, 100, 700, 450]);

plot(SNR_levels, nat_acc, 'b-o', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'b');
hold on;
plot(SNR_levels, sem_acc, 'r-s', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'r');
xlabel('SNR (dB)', 'FontSize', 12);
ylabel('Task Accuracy (%)', 'FontSize', 12);
title('SNR vs Task Accuracy: Graceful Degradation', 'FontSize', 13);
legend('Natural Language', 'Semantic Communication', 'Location', 'southeast');
grid on; box on;
xlim([0, 30]);
ylim([0, 105]);

% Shade region below 50% accuracy
fill([0 30 30 0], [0 0 50 50], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
text(15, 25, 'Unreliable Region', 'HorizontalAlignment', 'center', ...
    'FontSize', 11, 'Color', 'r');

saveas(fig4, '../paper/figures/fig4_snr_accuracy.png');
fprintf('✓ Saved fig4_snr_accuracy.png\n');

fprintf('\n✓ All figures generated successfully!\n');
fprintf('Figures saved to: ../paper/figures/\n\n');