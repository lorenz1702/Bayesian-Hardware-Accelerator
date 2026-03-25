# 🚀 Top-Level CRV Verification Plan: Bayesian Hardware Accelerator

This directory contains the Constrained Random Verification (CRV) environment for the `top_modul` of the BNN (Bayesian Neural Network) Accelerator. While the unit tests (e.g., `bnn_alu`) validate the mathematical correctness of the data paths at the bit level, this top-level testbench focuses on **module integration, data flow, backpressure handling, FIFO mechanics, and FSM transitions**.

## 🛠️ To-Dos (Pre-Verification Checklist)

Before writing the CRV testbench, the following tasks must be completed in the RTL code and the test environment to ensure a verifiable design:

- [ ] **RTL Fix:** Rename the input signal `ready_to_resive` to `ready_to_receive` and properly connect it to the FSM/ALU to enable genuine external backpressure.
- [ ] **RTL Fix:** The `result_valid` signal from the ALU is currently floating. It must be routed to the `main_fsm` so the FSM knows exactly when to assert the top-level `bnn_valid` output.
- [ ] **Golden Model Upgrade:** Write a top-level Golden Model (in C/C++ or SystemVerilog) that simulates a FIFO queue and incorporates the static ROM values (`mu`, `sigma`, `bias` fetched from address `0`).
- [ ] **CRV Class Creation:** Create a `TopTx` class that randomizes the input data (`x_in`) as well as the timing/delays for the handshake signals (`x_valid` and `ready_to_receive`).

---

## 📋 Test Cases (Verification Plan)

### Category 1: Basic Data Flow & Sanity Checks
**Goal:** Verify that a simple transaction flows seamlessly through all sub-modules (FIFO -> CLT -> ALU -> FSM) without getting stuck.

- [ ] **TC-1.1 Single Transaction**
  - **Description:** Send exactly one valid `x_in` value. Keep `ready_to_receive` tied to `1`.
  - **Expected Behavior:** After a few cycles of pipeline latency (FIFO + CLT + ALU), `bnn_valid` must assert for exactly one clock cycle. The result must match the Golden Model.
- [ ] **TC-1.2 Continuous Flow**
  - **Description:** Set `x_valid = 1` and pump 100 consecutive random `x_in` values into the module without interruption.
  - **Expected Behavior:** The pipeline fills up. `bnn_valid` must stream results out synchronously according to the ALU's throughput capability. No data loss is allowed.

### Category 2: Handshake & Backpressure (FSM Focus)
**Goal:** Test how the FIFO and FSM react when data stalls or the external receiver blocks the output. This is where most hardware bugs hide!

- [ ] **TC-2.1 Receiver Backpressure**
  - **Description:** Flood the pipeline with data (`x_valid = 1`), but block the output (`ready_to_receive = 0`).
  - **Expected Behavior:** The FSM must stall the ALU. The FIFO fills up until `fifo_full = 1`. Any further incoming data must be handled or rejected correctly according to the protocol.
- [ ] **TC-2.2 Sender Starvation**
  - **Description:** The receiver is ready (`ready_to_receive = 1`), but no new data arrives (`x_valid = 0`).
  - **Expected Behavior:** The FIFO drains until `fifo_empty = 1`. The FSM must hold `bnn_valid = 0`. The ALU must not output "ghost data" (repeated old values).
- [ ] **TC-2.3 Random Handshake**
  - **Description:** Both `x_valid` and `ready_to_receive` toggle completely randomly (using CRV constraints to inject 0-5 cycles of delay between assertions).
  - **Expected Behavior:** The system must operate with a stuttering but flawless data flow. The Golden Model (using a `[$]` queue) must match the hardware outputs 100% in the correct order.

### Category 3: Corner Cases & Sub-Module Integration
**Goal:** Test edge conditions that often cause state machines to hang or corrupt data.

- [ ] **TC-3.1 In-Flight Reset**
  - **Description:** Send data through the pipeline. While the ALU is actively computing, trigger `reset = 1`.
  - **Expected Behavior:** All internal states (FIFO, ALU registers, FSM state) must be wiped immediately. `bnn_valid` must drop to `0`. The system must cleanly accept new data right after the reset deasserts.
- [ ] **TC-3.2 CLT Delay Tolerance**
  - **Description:** Simulate a scenario where the CLT module takes longer to compute the random noise (`clt_is_valid = 0` temporarily).
  - **Expected Behavior:** The ALU must not start its computation, and the FSM must pause popping data from the FIFO until the noise (`epsilon`) is completely ready.
- [ ] **TC-3.3 ROM Integration Check**
  - **Description:** Inject extreme `x_in` values (e.g., `8'h7F`) to verify that the statically assigned ROM address (`4'd0`) is read out and applied correctly.
  - **Expected Behavior:** The Golden Model uses the hardcoded ROM[0] values. The top-module output must match exactly, proving the ROM wiring is correct.

---

## 🏗️ Top-Level Testbench Architecture
To execute these test cases, the testbench will be structured into the following components:
1. **Clock & Reset Generator.**
2. **TopTx CRV Class:** Randomizes `x_in` and generates dynamic wait times (delays) for the AXI-style valid/ready handshake.
3. **Stimulus Driver:** Pushes data into the top-level module based on the `x_valid` handshake protocol.
4. **Pipeline Monitor (Checker):** Uses a dynamic queue (`[$]`) that waits for `ready_to_receive && bnn_valid` to pop the expected result and compare it against the `bnn_result` from the DUT.