# 🚀 Top-Level CRV Verification Plan: Bayesian Hardware Accelerator

This directory contains the Constrained Random Verification (CRV) environment for the `top_modul` of the BNN (Bayesian Neural Network) Accelerator. While the unit tests (e.g., `bnn_alu`) validate the mathematical correctness of the data paths at the bit level, this top-level testbench focuses on **module integration, data flow, backpressure handling, direct AXI-style handshaking, and FSM transitions**.

## 🛠️ To-Dos (Pre-Verification Checklist)

Before writing the CRV testbench, the following tasks must be completed in the RTL code and the test environment to ensure a verifiable design:

- [x] **CRV Class Creation:** Create a `TopTx` class that randomizes the input data (`x_in`) as well as the timing/delays for the handshake signals (`x_valid` and `ready_to_receive`).

---

## 📋 Test Cases (Verification Plan)

### Category 1: Basic Data Flow & Sanity Checks
**Goal:** Verify that a simple transaction flows seamlessly through all sub-modules (CLT -> ALU -> FSM) without getting stuck.

- [x] **TC-1.1 Single Transaction**
  - **Description:** Send exactly one valid `x_in` value. Keep `ready_to_receive` tied to `1`.
  - **Expected Behavior:** After a few cycles of latency (CLT noise generation + ALU computation), `bnn_valid` must assert for exactly one clock cycle. The FSM must assert `x_ready` exactly once to consume the input. The result must match the Golden Model.
- [x] **TC-1.2 Continuous Flow**
  - **Description:** Set `x_valid = 1` and pump 100 consecutive random `x_in` values into the module without interruption.
  - **Expected Behavior:** The system processes data continuously. `bnn_valid` must stream results out, and the FSM must properly toggle `x_ready` to throttle the input according to the ALU's computation time. No data loss is allowed.

### Category 2: Handshake & Backpressure (FSM Focus)
**Goal:** Test how the FSM reacts when data stalls or the external receiver blocks the output. This is where most hardware bugs hide!

- [x] **TC-2.1 Receiver Backpressure**
  - **Description:** Provide continuous valid data (`x_valid = 1`), but block the output (`ready_to_receive = 0`).
  - **Expected Behavior:** The FSM must freeze in the `WAIT_FOR_ALU` state once a result is ready. Crucially, it must keep `x_ready = 0` so the testbench cannot send any new `x_in` data until the current output is finally read.
- [x] **TC-2.2 Sender Starvation**
  - **Description:** The receiver is ready (`ready_to_receive = 1`), but no new data arrives (`x_valid = 0`).
  - **Expected Behavior:** The FSM must remain in the `IDLE` state. It must hold `bnn_valid = 0`. The ALU must not output "ghost data" (repeated old values) and `x_ready` must stay `0`.
- [ ] **TC-2.3 Random Handshake**
  - **Description:** Both `x_valid` and `ready_to_receive` toggle completely randomly (using CRV constraints to inject 0-5 cycles of delay between assertions).
  - **Expected Behavior:** The system must operate with a stuttering but flawless data flow. The Golden Model (using a `[$]` queue) must match the hardware outputs 100% in the correct order.

### Category 3: Corner Cases & Sub-Module Integration
**Goal:** Test edge conditions that often cause state machines to hang or corrupt data.

- [x] **TC-3.1 In-Flight Reset**
  - **Description:** Send data through the system. While the ALU is actively computing, trigger `reset = 1`.
  - **Expected Behavior:** All internal states (ALU registers, FSM state) must be wiped immediately. `bnn_valid` must drop to `0`. The system must cleanly accept new data right after the reset deasserts.
- [x] **TC-3.2 CLT Delay Tolerance**
  - **Description:** Simulate a scenario where the CLT module takes longer to compute the random noise (`clt_is_valid = 0` temporarily).
  - **Expected Behavior:** The FSM must wait in the `WAIT_FOR_CLT` state. It must not assert `x_ready` to consume the input, nor start the ALU, until the noise (`epsilon`) is completely ready.

---

## 🏗️ Top-Level Testbench Architecture
To execute these test cases, the testbench will be structured into the following components:
1. **Clock & Reset Generator.**
2. **TopTx CRV Class:** Randomizes `x_in` and generates dynamic wait times (delays) for the AXI-style valid/ready handshake.
3. **Stimulus Driver:** Pushes data into the top-level module based on the `x_valid` & `x_ready` handshake protocol.
4. **Pipeline Monitor (Checker):** Uses a dynamic queue (`[$]`) that waits for `ready_to_receive && bnn_valid` to pop the expected result and compare it against the `bnn_result` from the DUT.