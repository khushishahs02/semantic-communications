# Semantic Communication Vs Natural Language Transmission

This repository contains the research work, MATLAB simulations, and the technical paper for our project comparing Semantic Language transmission against Natural Language transmission. 

## Authors
- **Khushi Shah**
- **Tanish Sanghavi**

## Overview
For seventy-five years, communication systems have optimized bit-level transmission accuracy, treating messages as symbol sequences without semantic awareness. We challenge this paradigm by demonstrating that meaning-centric transmission—semantic communication via knowledge graph representations—achieves superior compression and noise resilience compared to traditional natural language transmission.

## Key Contributions
- **Compression Advantage:** Empirical validation shows that semantic encoding achieves on average 1.74× compression while preserving 100% of factual content.
- **Noise Robustness:** Demonstrated a fundamental disconnect between bit-level and task-level accuracy. Under heavy realistic channel noise (0 dB SNR), semantic communication maintains 98% task accuracy while natural language achieves only 12% at the equivalent Bit Error Rate (BER).
- **Graceful Degradation:** Demonstrated that semantic accuracy degrades far more gracefully (1.2%/dB) compared to natural language's cliff effect (8.7%/dB), translating to an effective 10.3 dB SNR advantage.

## Repository Structure
- `paper/`: Contains the LaTeX source files (`main.tex`) and compiled PDF for the research findings.
- `matlab/`: MATLAB scripts for Shannon entropy analysis, data visualization, and noise injection simulations across various SNRs.
- `data/`: Source sentence datasets utilized across diverse domains (family relations, geographic facts, technical specs, etc.).

## Implications
Our findings highlight the theoretical and empirical advantages of a semantic-aware transmission framework. The proven spectrum savings and reduced transmit power requirements provide a strong foundation for future semantic-aware frameworks such as those proposed for 6G networks.
