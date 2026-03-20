# 🧪 Verification Plan: Simple Dual-Port RAM

## 🎯 Objective
This checklist serves the systematic verification of the Simple Dual-Port RAM (1 write port, 1 read port). Check off the items once the corresponding test case is implemented in the testbench and passes without errors.

---

## 🛠️ Setup & Infrastructure
- [x] **Golden Model created:** A software array (`logic [DATA_WIDTH-1:0] expected_ram [0:(1<<ADDR_WIDTH)-1]`) was integrated into the testbench and initialized with `'x`.
- [x] **CRV Class implemented:** A transaction class with `rand` variables for the write port (`wr_addr`, `wr_data`, `we`) and the read port (`rd_addr`) has been implemented.
- [x] **Automated Checker (1-Cycle Latency):** The checker accounts for the fact that read data (`rd_data`) is only valid one clock cycle after the read address (`rd_addr`) is applied, and automatically compares it with the Golden Model.

---

## 🟢 Category 1: Basic Operations (Isolated)
*Basic tests to verify fundamental functionality.*
- [X] **[TC-1.1] Basic Write & Read:** Write random data to an address, wait, and read from exactly that address. (Verifies data retention).
- [x] **[TC-1.2] Back-to-Back Writes:** Write data to different addresses in consecutive clock cycles without interruption.
- [ ] **[TC-1.3] Back-to-Back Reads:** Read from different addresses in consecutive clock cycles. (