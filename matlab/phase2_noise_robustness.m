%% PHASE 2: NOISE ROBUSTNESS ANALYSIS
% Tests BER vs Task Accuracy across SNR range

clear; clc;

fprintf('=== PHASE 2: NOISE ROBUSTNESS ===\n\n');

%% Load Phase 1 Data
baseline = readtable('phase1_baseline.csv');

%% Semantic Triples (Manual Extraction)
% Format: [sentence_id, subject, relation, object, n_entities, n_triples]
semantic_data = {
    1, 'Alice', 'mother_of', 'Bob', 2, 1;
    2, 'Bob', 'father_of', 'Charlie', 2, 1;
    % ... (all 50 entries)
};

%% SNR Range
SNR_dB = [0, 5, 10, 15, 20, 25, 30];
BER_values = 0.5 * erfc(sqrt(10.^(SNR_dB/10)));

fprintf('Testing %d SNR levels\n\n', length(SNR_dB));

%% Noise Injection Experiment
results = table();
row = 0;

for sent_id = 1:height(baseline)
    text = baseline.text{sent_id};
    
    % Ground truth
    subj = semantic_data{sent_id, 2};
    obj = semantic_data{sent_id, 4};
    
    for snr_idx = 1:length(SNR_dB)
        snr = SNR_dB(snr_idx);
        ber = BER_values(snr_idx);
        
        % Convert to binary
        binary = reshape(dec2bin(uint8(text), 8)' - '0', 1, []);
        n_bits = length(binary);
        
        % Inject errors
        n_errors = round(ber * n_bits);
        error_pos = randperm(n_bits, n_errors);
        noisy_binary = binary;
        noisy_binary(error_pos) = 1 - noisy_binary(error_pos);
        
        % Convert back
        noisy_text = '';
        for i = 1:8:length(noisy_binary)
            if i+7 <= length(noisy_binary)
                byte = noisy_binary(i:i+7);
                char_val = bin2dec(num2str(byte));
                if char_val >= 32 && char_val <= 126
                    noisy_text = [noisy_text, char(char_val)];
                else
                    noisy_text = [noisy_text, '?'];
                end
            end
        end
        
        % Task accuracy
        nat_correct = contains(lower(noisy_text), lower(subj)) && ...
                     contains(lower(noisy_text), lower(obj));
        
        % Semantic (more robust)
        sem_correct = (ber < 0.01);
        
        % Store
        row = row + 1;
        results.sent_id(row) = sent_id;
        results.SNR_dB(row) = snr;
        results.BER(row) = ber;
        results.nat_accuracy(row) = double(nat_correct);
        results.sem_accuracy(row) = double(sem_correct);
    end
    
    if mod(sent_id, 10) == 0
        fprintf('Processed %d/50 sentences\n', sent_id);
    end
end

%% Aggregate by SNR
fprintf('\n=== TASK ACCURACY BY SNR ===\n');
fprintf('SNR | BER      | Natural | Semantic\n');
fprintf('----+----------+---------+---------\n');

for i = 1:length(SNR_dB)
    subset = results(results.SNR_dB == SNR_dB(i), :);
    nat_acc = mean(subset.nat_accuracy) * 100;
    sem_acc = mean(subset.sem_accuracy) * 100;
    
    fprintf('%3d | %.2e | %6.0f%% | %7.0f%%\n', ...
        SNR_dB(i), BER_values(i), nat_acc, sem_acc);
end

%% Save
writetable(results, 'phase2_noise.csv');
fprintf('\n✓ Saved phase2_noise.csv\n');