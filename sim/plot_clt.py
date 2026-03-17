import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import norm
import os

# Path to the generated data file (located in the scripts/ folder)
data_file = os.path.join('scripts', 'clt_data.txt')

print("Reading CLT data from:", data_file)

# Check if the simulation data actually exists
if not os.path.exists(data_file):
    print(f"ERROR: File not found at {data_file}")
    print("Please run 'make sim TB=tb_clt_data' first.")
    exit()

# 1. Load the data
data = np.loadtxt(data_file)
num_samples = len(data)

print(f"Successfully loaded {num_samples} samples.")

# 2. Calculate hardware data statistics
mean_hw = np.mean(data)
std_hw = np.std(data)

print(f"Hardware Data Stats:")
print(f"  Mean: {mean_hw:.4f} (Should be close to 0.0)")
print(f"  Std Dev: {std_hw:.4f}")
print(f"  Range: {np.min(data):.2f} to {np.max(data):.2f}")

# === PLOTTING ===

plt.figure(figsize=(10, 6))

# 3. Plot the histogram of hardware data (the bars)
# We use 'density=True' so that the area under the histogram integrates to 1.0
count, bins, ignored = plt.hist(data, bins=100, density=True, alpha=0.6, color='b', label='Hardware CLT Sum')

# 4. Overlay the mathematically perfect normal distribution
# We use the mean and standard deviation from our hardware data
# to visualize how well our logic fits the ideal curve.
xmin, xmax = plt.xlim()
x = np.linspace(xmin, xmax, 200)
p_perfect = norm.pdf(x, mean_hw, std_hw)

plt.plot(x, p_perfect, 'r', linewidth=2, label=f'Perfect Gaussian Curve (μ={mean_hw:.2f}, σ={std_hw:.2f})')

# Layout and Labels
plt.title(f'Normal Distribution Check: CLT Sum of Hardware LFSRs ({num_samples} samples)')
plt.xlabel('Normalized Value (clt_out / 256.0)')
plt.ylabel('Probability Density')
plt.grid(axis='y', alpha=0.5)
plt.legend()

# Save the final plot to a file
plt.savefig('clt_normal_distribution.png')
print("Plot saved as clt_normal_distribution.png")

# Optional: Display the plot window
# plt.show()