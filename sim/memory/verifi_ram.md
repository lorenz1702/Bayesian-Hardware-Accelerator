# 🧪 Verification Plan: Dual-Port RAM (Checklist)

## 🎯 Objective
This checklist serves the systematic verification of the Dual-Port RAM. Check off the items once the corresponding test case is implemented in the testbench and passes without errors.

## 🛠️ Setup & Infrastructure
- [x] **Golden Model created:** A software array (e.g., `logic [7:0] expected_ram [0:15]`) was added to the testbench to simulate the memory in parallel.
- [ ] **CRV Class implemented:** A class with `rand` variables for both ports (`addr_a`, `din_a`, `we_a`, `addr_b`, `din_b`, `we_b`) was created.
- [ ] **Automated Checker:** A function automatically compares the hardware output (`dout_a`, `dout_b`) with the Golden Model on every read access and reports any errors.

## 🟢 Category 1: Basic Operations (Single Port)
*Only one port is active, the other remains idle.*
- [ ] **[TC-1.1] Basic Write/Read Port A:** Write random data to an address via Port A and read it back correctly via Port A.
- [ ] **[TC-1.2] Basic Write/Read Port B:** Write random data to an address via Port B and read it back correctly via Port B.
- [ ] **[TC-1.3] Cross-Port Test:** Write data via Port A and then read exactly that data via Port B (and vice versa). Proves the shared memory space.

## 🟡 Category 2: Concurrent Operations (Without Collision)
*Both ports are active in the same clock cycle, but are guaranteed to access **different** addresses (`addr_a != addr_b`).*
- [ ] **[TC-2.1] Concurrent Read:** Ports A and B read simultaneously from different addresses. Both outputs provide the correct data.
- [ ] **[TC-2.2] Concurrent Write:** Ports A and B write simultaneously to different addresses. Both memory cells in the Golden Model and in hardware match.
- [ ] **[TC-2.3] Concurrent Read/Write:** Port A writes to address X, while Port B reads undisturbed from address Y.

## 🔴 Category 3: Collisions & Corner Cases
*The stress test: Both ports access the **exact same** address in the same clock cycle (`addr_a == addr_b`).*
- [ ] **[TC-3.1] Read/Read Collision:** Both ports read simultaneously from the same address. (Both must receive the same, correct value).
- [ ] **[TC-3.2] Write/Read Collision (RAW Hazard):** Port A writes to address X, Port B reads address X in the same clock cycle. *(Behavior is documented: Does the RAM return the old or the new value?)*.
- [ ] **[TC-3.3] Write/Write Collision (WAW Hazard):** Both ports try to write different values to the same address simultaneously. *(Behavior checked: E.g., Port A has priority, or memory cell is marked as undefined 'X').*
- [ ] **[TC-3.4] Boundary Checks:** Targeted read/write accesses to the absolute lowest (0x0) and highest (e.g., 0xF) memory addresses.

## 📊 Category 4: Coverage & Sign-off
- [ ] **100% Address Coverage:** A `covergroup` proves that every address of the RAM was written to and read from at least once by the randomizer.
- [ ] **Collision Coverage:** The `covergroup` proves that the hazard scenarios (TC-3.2, TC-3.3) were actually hit randomly at least once during the test.
- [ ] **Clean Run:** An automated stress test with, for example, 10,000 randomized cycles completed without a single mismatch (0 errors).