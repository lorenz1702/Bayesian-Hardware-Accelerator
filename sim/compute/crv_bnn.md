#  Verification Plan: BNN ALU (Datapath & Handshake)

##  Objective
This verification plan outlines the strategy for testing the Bayesian Neural Network Arithmetic Logic Unit (`bnn_alu`). The focus is on verifying correct **signed fixed-point arithmetic**, handling of edge cases (overflows/zeroes), and the robustness of the AXI-Stream-like **handshake protocol** (`valid`/`ready`).

##  Setup & Infrastructure
- [X] **CRV Transaction Class:** Create a SystemVerilog class `AluTx` containing `rand signed [7:0]` variables for `x`, `mu`, `sigma`, `epsilon`, and `bias`.
- [X] **Golden Model (Software Reference):** Implement a SystemVerilog function that calculates `expected_y = (mu + (sigma * epsilon)) * x + bias` using 32-bit signed arithmetic to prevent intermediate truncation.
- [X] **Fixed-Point Formatting:** Add a display function in the checker that prints the 32-bit integer result as a human-readable floating-point number (e.g., dividing by $2^{\text{fractional\_bits}}$) to prove fixed-point correctness.
- [X] **Automated Checker:** A monitor block that triggers on `valid_out && ready_in` and automatically compares `y_out` against `expected_y`.

##  Category 1: Signed Arithmetics & Data Values
*Testing the datapath with various combinations of positive and negative numbers.*
- [x] **[TC-1.1] All Positive:** Constrain all inputs (`x`, `mu`, `sigma`, `epsilon`, `bias`) to be strictly $> 0$.
- [X] **[TC-1.2] All Negative:** Constrain all inputs to be strictly $< 0$ (Tests correct Two's Complement sign extension during multiplication).
- [x] **[TC-1.3] Mixed Signs:** Truly random mix of positive and negative inputs (CRV default).
- [x] **[TC-1.4] Multiplication by Zero:** Force `x = 0`, `epsilon = 0`, or `sigma = 0` randomly. The Golden Model and DUT must perfectly match (e.g., if `x=0`, output must be exactly `bias`).
- [x] **[TC-1.5] Extreme Values (Corner Cases):** Inject maximum positive (`8'h7F` / 127) and maximum negative (`8'h80` / -128) values simultaneously to ensure the `32-bit` accumulator (`y_acc`) does not overflow.

##  Category 2: Handshake Protocol (Control Flow)
*Testing the `valid_in`, `ready_out`, `valid_out`, and `ready_in` signals.*
- [x] **[TC-2.1] Continuous Flow (Pipeline ideal):** `valid_in` and `ready_in` are permanently `1`. The ALU processes a new pixel every clock cycle.
- [x] **[TC-2.2] Receiver Backpressure:** The ALU finishes calculation (`valid_out = 1`), but the outside world is not ready (`ready_in = 0`). 
  - *Check:* The ALU must hold the `y_out` value stable and not overwrite it until `ready_in` goes high.
- [x] **[TC-2.3] Sender Starvation:** The outside world is ready (`ready_in = 1`), but no new data is coming in (`valid_in = 0`).
  - *Check:* `valid_out` must remain `0` (or drop to `0` after the last transaction is read).

