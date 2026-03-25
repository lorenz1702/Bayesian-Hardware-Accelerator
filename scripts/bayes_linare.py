import torch
import matplotlib.pyplot as plt

torch.manual_seed(42)

# 1. Parameter definieren (Passend zu deinen Hardware-Inputs)
x = torch.linspace(-20, 20, 100)
mu = 4.0
bias = -10.0

# Achtung: Da sigma jetzt mit x multipliziert wird, wirkt ein Wert von 3.0 extrem stark!
# Bei x=20 hättest du Rauschen im Bereich von +/- 60. 
# Ich setze es hier für ein schöneres Bild auf 0.5, pass es an deine Hardware an.
sigma = 0.5 

# 2. Epsilon generieren (Das ist dein Random-Input in der Hardware)
epsilon = torch.randn(100)

# 3. BNN-Berechnung wie in deiner Verilog-ALU
w = mu + (sigma * epsilon)
y_bnn = w * x + bias

# 4. Zum Vergleich: Das "ideale" Ergebnis ohne Rauschen
y_true = mu * x + bias

# --- Plotten ---
plt.plot(x, y_true, label="Ideal (y = 4x - 10)", color="red", linewidth=2)
plt.scatter(x, y_bnn, label="BNN Hardware Modell", color="blue", s=15)
plt.title("Bayesian Neural Network: Multiplikatives Rauschen")
plt.xlabel("x")
plt.ylabel("y")
plt.legend()
plt.grid(True)
plt.show()