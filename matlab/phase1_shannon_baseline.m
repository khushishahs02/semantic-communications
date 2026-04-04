%% PHASE 1: SHANNON ENTROPY BASELINE
% Calculates character and word-level entropy for natural language
% Reference: Shannon (1948), Bell Syst. Tech. J., 27(3), 379-423
%
% OUTPUT: phase1_baseline.csv with entropy metrics

clear; clc;

%% Read Dataset
fprintf('=== PHASE 1: SHANNON BASELINE ===\n\n');

% Read sentences from file
fid = fopen('../data/test_sentences.txt', 'r');
if fid == -1
    error('Cannot open test_sentences.txt - check file path');
end

sentences = {};
idx = 0;

while ~feof(fid)
    line = fgetl(fid);
    % Skip comments and empty lines
    if isempty(line) || (length(line) > 0 && line(1) == '#')
        continue;
    end
    idx = idx + 1;
    sentences{idx} = line;
end
fclose(fid);

fprintf('Loaded %d sentences\n\n', length(sentences));

%% Initialize Results Table
results = table();

%% Process Each Sentence
for i = 1:length(sentences)
    text = sentences{i};
    
    % === CHARACTER-LEVEL ENTROPY ===
    text_lower = lower(text);
    chars = text_lower(:)';  % Convert to char array
    
    % Count character frequencies
    unique_chars = unique(chars);
    n_chars = length(chars);
    
    H_char = 0;  % Shannon entropy
    for j = 1:length(unique_chars)
        count = sum(chars == unique_chars(j));
        p = count / n_chars;
        if p > 0
            H_char = H_char - p * log2(p);
        end
    end
    
    % === WORD-LEVEL ENTROPY ===
    words = strsplit(text_lower);
    unique_words = unique(words);
    n_words = length(words);
    
    H_word = 0;
    for j = 1:length(unique_words)
        count = sum(strcmp(words, unique_words{j}));
        p = count / n_words;
        if p > 0
            H_word = H_word - p * log2(p);
        end
    end
    
    % === REDUNDANCY CALCULATION ===
    % Max entropy for 27 symbols (26 letters + space)
    H_max = log2(27);
    redundancy = 1 - (H_char / H_max);
    
    % === STORAGE METRICS ===
    % Actual UTF-8 storage (approximate)
    actual_bytes = length(text);
    
    % Theoretical minimum from entropy
    theoretical_bytes = (H_char * n_chars) / 8;
    
    % Compression potential
    compression_potential = actual_bytes / theoretical_bytes;
    
    % === STORE RESULTS ===
    results.sentence_id(i) = i;
    results.text{i} = text;
    results.char_count(i) = n_chars;
    results.word_count(i) = n_words;
    results.char_entropy(i) = H_char;
    results.word_entropy(i) = H_word;
    results.redundancy(i) = redundancy;
    results.actual_bytes(i) = actual_bytes;
    results.theoretical_bytes(i) = theoretical_bytes;
    results.compression_potential(i) = compression_potential;
    
    % Progress indicator
    if mod(i, 10) == 0
        fprintf('Processed %d/%d sentences...\n', i, length(sentences));
    end
end

%% Save Results
writetable(results, '../data/results/phase1_baseline.csv');
fprintf('\n✓ Results saved to phase1_baseline.csv\n\n');

%% Summary Statistics
fprintf('=== SUMMARY STATISTICS ===\n');
fprintf('Character Entropy:     %.3f ± %.3f bits/char\n', ...
    mean(results.char_entropy), std(results.char_entropy));
fprintf('Word Entropy:          %.3f ± %.3f bits/word\n', ...
    mean(results.word_entropy), std(results.word_entropy));
fprintf('Redundancy:            %.1f%% ± %.1f%%\n', ...
    mean(results.redundancy)*100, std(results.redundancy)*100);
fprintf('Avg Actual Storage:    %.1f ± %.1f bytes\n', ...
    mean(results.actual_bytes), std(results.actual_bytes));
fprintf('Avg Theoretical:       %.1f ± %.1f bytes\n', ...
    mean(results.theoretical_bytes), std(results.theoretical_bytes));
fprintf('Compression Potential: %.2fx ± %.2fx\n', ...
    mean(results.compression_potential), std(results.compression_potential));
fprintf('\n');

% Shannon validation check
fprintf('=== VALIDATION ===\n');
fprintf('Expected char entropy: 4.0-4.5 bits/char (Shannon, 1948)\n');
fprintf('Your measurement:      %.2f bits/char\n', mean(results.char_entropy));
if mean(results.char_entropy) >= 3.5 && mean(results.char_entropy) <= 5.0
    fprintf('✓ Within expected range!\n\n');
else
    fprintf('⚠ Outside expected range - check implementation\n\n');
end