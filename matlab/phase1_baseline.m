%% PHASE 1: SHANNON ENTROPY BASELINE
% CT216 Project - Semantic vs Natural Language Communication
% Calculates Shannon entropy for natural language baseline

clear; clc;

fprintf('=== PHASE 1: SHANNON BASELINE ===\n\n');

%% Test Sentences (50 total - 5 domains × 10 each)
sentences = {
    % Family Relations (10)
    'Alice is the mother of Bob.',
    'Bob is the father of Charlie.',
    'Charlie is the brother of David.',
    'David lives in Boston.',
    'Alice lives in New York.',
    'Bob works at Google.',
    'Charlie studies at MIT.',
    'David plays soccer.',
    'Alice likes reading books.',
    'Bob drives a Tesla car.',
    
    % Corporate Hierarchy (10)
    'The CEO leads the company.',
    'The company has one thousand employees.',
    'Employees work in modern offices.',
    'Offices are located in major cities.',
    'The CFO manages company finances.',
    'The CTO oversees all technology.',
    'Engineers write software code daily.',
    'Managers lead their project teams.',
    'Teams complete important projects.',
    'Projects generate significant revenue.',
    
    % Geographic Facts (10)
    'London is the capital of England.',
    'England is located in Europe.',
    'Paris is the capital of France.',
    'France shares borders with Spain.',
    'Berlin is located in Germany.',
    'Germany has eighty million people.',
    'Tokyo is located in Japan.',
    'Japan is an island nation.',
    'Rome has many ancient ruins.',
    'Italy produces excellent wine.',
    
    % Technical Specifications (10)
    'The server runs Linux operating system.',
    'Linux uses the stable kernel.',
    'The kernel manages system memory.',
    'Memory stores important data.',
    'Data flows through network connections.',
    'Networks connect multiple computers.',
    'Computers process digital information.',
    'Information requires network bandwidth.',
    'Bandwidth measures transmission speed.',
    'Speed affects overall performance.',
    
    % General Knowledge (10)
    'Water boils at one hundred degrees.',
    'The sun is a bright star.',
    'Earth orbits around the sun.',
    'Mars is a red planet.',
    'Gravity pulls objects downward.',
    'Light travels extremely fast.',
    'Sound requires a physical medium.',
    'Energy cannot be completely destroyed.',
    'Time moves only forward.',
    'Space is incredibly vast.'
};

fprintf('Loaded %d sentences\n\n', length(sentences));

%% Process Each Sentence
results = table();

for i = 1:length(sentences)
    text = sentences{i};
    text_lower = lower(text);
    
    % Character-level entropy
    chars = text_lower(:)';
    unique_chars = unique(chars);
    n_chars = length(chars);
    
    H_char = 0;
    for j = 1:length(unique_chars)
        count = sum(chars == unique_chars(j));
        p = count / n_chars;
        if p > 0
            H_char = H_char - p * log2(p);
        end
    end
    
    % Word-level entropy
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
    
    % Redundancy
    H_max = log2(27);  % 26 letters + space
    redundancy = 1 - (H_char / H_max);
    
    % Storage
    actual_bytes = length(text);
    theoretical_bytes = (H_char * n_chars) / 8;
    
    % Store results
    results.id(i) = i;
    results.text{i} = text;
    results.char_entropy(i) = H_char;
    results.word_entropy(i) = H_word;
    results.redundancy(i) = redundancy;
    results.actual_bytes(i) = actual_bytes;
    results.theoretical_bytes(i) = theoretical_bytes;
    
    if mod(i, 10) == 0
        fprintf('Processed %d/%d...\n', i, length(sentences));
    end
end

%% Summary Statistics
fprintf('\n=== SUMMARY ===\n');
fprintf('Char Entropy: %.2f ± %.2f bits/char\n', ...
    mean(results.char_entropy), std(results.char_entropy));
fprintf('Word Entropy: %.2f ± %.2f bits/word\n', ...
    mean(results.word_entropy), std(results.word_entropy));
fprintf('Redundancy: %.1f%% ± %.1f%%\n', ...
    mean(results.redundancy)*100, std(results.redundancy)*100);
fprintf('Avg Storage: %.1f ± %.1f bytes\n', ...
    mean(results.actual_bytes), std(results.actual_bytes));

% Validation
fprintf('\n=== VALIDATION ===\n');
fprintf('Expected: 4.0-4.5 bits/char (Shannon, 1948)\n');
fprintf('Measured: %.2f bits/char\n', mean(results.char_entropy));
if mean(results.char_entropy) >= 3.5 && mean(results.char_entropy) <= 5.0
    fprintf('✓ Within expected range!\n\n');
end

%% Save
writetable(results, 'phase1_baseline.csv');
fprintf('✓ Saved phase1_baseline.csv\n');