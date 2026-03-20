# 🧪 Day 5: Verification (Minimized to CRV)

**🎯 Focus:** Automated testing with intelligent randomness (without UVM/C overhead).  
**🧩 Covered Patterns:** `Various verification techniques`, `Coverage`

### ✅ Tasks (The Minimal Version):

- [ ] **The CRV Class:** Write a simple SystemVerilog class (Transaction) where your `pixel_in` is declared as `rand`.
- [ ] **Constraints:** Set simple boundaries (e.g., `pixel_in` must be between 0 and 100) so the simulator doesn't generate completely wild values.
- [ ] **The SV Golden Model:** Simply calculate the expected result within the testbench using standard Verilog variables (instead of utilizing an external C program).
- [ ] **Automated Comparison:** Create a loop that generates 100 randomized pixels and automatically compares the hardware's `bnn_result` with your SV Golden Model.
- [ ] **Coverage (Bonus, but excellent for the final grade):** Implement a small `covergroup` that logs and proves whether your FSM actually hit the `IDLE`, `CALC`, and `DONE` states.

> **🏆 Daily Goal:** A script that fires off 100 tests and simply prints `"TEST PASSED: 100/100"` to the console at the end.