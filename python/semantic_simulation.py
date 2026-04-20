import numpy as np

import matplotlib.pyplot as plt

import math



# ==============================================================================

# 1. SETUP VARIABLES AND PARAMETERS

# ==============================================================================

# We will test the Signal-to-Noise Ratio (SNR) from 0 dB to 15 dB. 

# Higher SNR means a clearer channel. Lower SNR means lots of noise.

# (Beyond 15 dB, both methods achieve 100% accuracy, so 0-15 dB is the crucial zone)

snr_db_range = np.arange(0, 16, 1)



# --- Standard Approach: Natural Language (NL) ---

# Example Sentence: "The quick brown fox jumped high over the sleeping dog"

# In standard communication, we send every single character (including spaces).

# 53 characters * 8 bits per character = 424 bits.

nl_length_bits = 424 



# --- New Approach: Semantic Triple Encoded Data ---

# Core meaning extracted: (fox, jumped, dog)

# Using a shared Knowledge Base dictionary:

# "fox"    (Noun) -> 10 bits (can represent 1024 unique animals)

# "jumped" (Verb) -> 8 bits  (can represent 256 unique actions)

# "dog"    (Noun) -> 10 bits (can represent 1024 unique animals)

# Total semantic bits needed to convey the EXACT same meaning = 28 bits.

semantic_length_bits = 28 





# ==============================================================================

# 2. DEFINING THE COMMUNICATION CHANNEL (THE FORMULAS)

# ==============================================================================



def calculate_bit_error_rate(snr_db):

    """

    Calculates the Bit Error Rate (BER) for a given Signal-to-Noise Ratio (SNR).

    BER is the probability that a single 1 flips to a 0, or a 0 flips to a 1 due to noise.

    

    Formula used: BPSK (Binary Phase Shift Keying) in AWGN (Gaussian Noise) channel.

    BER = 0.5 * erfc( sqrt( 10^(SNR/10) ) )

    """

    # Convert SNR from decibels (dB) to linear scale

    snr_linear = 10.0 ** (snr_db / 10.0)

    

    # Calculate error probability using the complementary error function (erfc)

    ber = 0.5 * math.erfc(math.sqrt(snr_linear))

    return ber





def calculate_task_accuracy(ber, num_bits_in_message):

    """

    Task Accuracy is the probability that the ENTIRE meaning is received correctly.

    If a message has 'N' bits, and the chance of a bit being correct is (1 - BER),

    then the chance of ALL bits being correct is (1 - BER) multiplied N times.

    

    Formula: Accuracy = (1 - BER) ^ number_of_bits

    """

    chance_single_bit_correct = 1.0 - ber

    

    # Probability that every single bit in the message survives the noise

    accuracy = chance_single_bit_correct ** num_bits_in_message

    return accuracy





# ==============================================================================

# 3. RUNNING THE SIMULATION

# ==============================================================================

# We will store the accuracy percentages here as we test different noise levels

nl_accuracies = []

semantic_accuracies = []



for snr in snr_db_range:

    

    # Step 3a: How likely is a bit to corrupt at this noise level?

    current_ber = calculate_bit_error_rate(snr)

    

    # Step 3b: Calculate accuracy for the long standard Natural Language message

    nl_acc = calculate_task_accuracy(current_ber, nl_length_bits)

    nl_accuracies.append(nl_acc * 100) # Convert to percentage

    

    # Step 3c: Calculate accuracy for our short Semantic Triple message

    sem_acc = calculate_task_accuracy(current_ber, semantic_length_bits)

    semantic_accuracies.append(sem_acc * 100) # Convert to percentage





# ==============================================================================

# 4. PLOTTING THE GRAPH TO PROVE SEMANTICS IS BETTER

# ==============================================================================

plt.figure(figsize=(10, 6))



# Plot Semantic performance (Green line)

plt.plot(snr_db_range, semantic_accuracies, 

         label=f'Semantic Triples ({semantic_length_bits} bits)', 

         color='green', linewidth=3, marker='o', markersize=8)

         

# Plot Natural Language performance (Red dotted line)

plt.plot(snr_db_range, nl_accuracies, 

         label=f'Natural Language ({nl_length_bits} bits)', 

         color='red', linewidth=3, marker='x', linestyle='--', markersize=8)



# Adding Text, Titles, and Labels clearly

plt.title('Task Accuracy vs. Channel Noise (SNR)', fontsize=16, fontweight='bold', pad=15)

plt.xlabel('Signal-to-Noise Ratio (SNR) in dB \n[Left = High Noise, Right = Clear Channel]', fontsize=12)

plt.ylabel('Task-Level Accuracy (%) \n[Probability Meaning is Received Intact]', fontsize=12)



# Make the chart look professional

plt.grid(True, linestyle=':', alpha=0.7)

plt.legend(fontsize=12, loc='lower right')

plt.ylim(-5, 105) # Keep percentages between 0 and 100

plt.xlim(0, 15)



# Highlight the huge gap in performance around 6-8 dB

plt.axvspan(5, 9, color='yellow', alpha=0.2, label='Maximum Semantic Advantage Zone')




# Save and Show the Graph

plt.tight_layout()

plt.savefig('semantic_advantage_simulation.png', dpi=300)

print("Simulation complete! Check the generated graph image.")



