Traffic Light FSM — Verilog HDL

A parameterized Traffic Light Controller implemented using Verilog HDL and modeled as a Finite State Machine (FSM). The design controls traffic signals for two directions: North-South (NS) and East-West (EW).

The project includes a self-checking Verilog testbench that verifies the FSM transitions, traffic-light outputs, and safety conditions over multiple complete cycles.

Architecture

The controller consists of:

FSM state register
Next-state combinational logic
Timing counter
Parameterized green/yellow durations
North-South traffic-light outputs
East-West traffic-light outputs
Block Diagram

FSM State Diagram

The controller contains four states:

State	NS Direction	EW Direction	Duration
NS_GREEN	Green	Red	GREEN_TIME
NS_YELLOW	Yellow	Red	YELLOW_TIME
EW_GREEN	Red	Green	GREEN_TIME
EW_YELLOW	Red	Yellow	YELLOW_TIME
State Transition Sequence
        GREEN_TIME
NS_GREEN ──────────────► NS_YELLOW
    ▲                        │
    │                        │ YELLOW_TIME
    │                        ▼
EW_YELLOW ◄────────────── EW_GREEN
    ▲                        │
    │                        │ GREEN_TIME
    │                        ▼
    └──── YELLOW_TIME ───────┘

The actual cyclic sequence is:

NS_GREEN
    ↓
NS_YELLOW
    ↓
EW_GREEN
    ↓
EW_YELLOW
    ↓
NS_GREEN
    ↓
(repeat)
State Encoding

The FSM uses 2-bit state encoding:

00 → NS_GREEN
01 → NS_YELLOW
10 → EW_GREEN
11 → EW_YELLOW
Inputs
Signal	Description
clk	System clock
reset	Synchronous reset; returns FSM to NS_GREEN
Outputs
North-South
Signal	Description
ns_red	North-South red light
ns_yellow	North-South yellow light
ns_green	North-South green light
East-West
Signal	Description
ew_red	East-West red light
ew_yellow	East-West yellow light
ew_green	East-West green light
Parameters

The timing of the controller can be changed without modifying the FSM logic:

parameter GREEN_TIME  = 4;
parameter YELLOW_TIME = 2;

For example:

traffic_light_fsm #(
    .GREEN_TIME(10),
    .YELLOW_TIME(3)
) dut (...);

Here, the green state remains active for 10 clock cycles and the yellow state remains active for 3 clock cycles.

Note: GREEN_TIME and YELLOW_TIME represent clock cycles, not seconds. A clock divider or clock-enable circuit would be required for real-time second-based operation on an FPGA.

Design Behavior
1. North-South Green
NS = GREEN
EW = RED

The controller remains in this state for GREEN_TIME clock cycles.

2. North-South Yellow
NS = YELLOW
EW = RED

After YELLOW_TIME clock cycles, control switches to the East-West direction.

3. East-West Green
NS = RED
EW = GREEN

The controller remains in this state for GREEN_TIME clock cycles.

4. East-West Yellow
NS = RED
EW = YELLOW

After YELLOW_TIME clock cycles, the controller returns to NS_GREEN.

Safety Conditions

The design ensures that:

Both directions cannot be green simultaneously.
Both directions cannot be yellow simultaneously.
Each direction has exactly one active light.
Reset returns the controller to a known state.
The FSM continuously follows the defined traffic-light sequence.
Verification

A self-checking Verilog testbench is included in the project.

The testbench verifies:

Reset behavior
NS_GREEN
NS_YELLOW
EW_GREEN
EW_YELLOW
Valid light combinations
No simultaneous green signals
No simultaneous yellow signals
Multiple complete FSM cycles
Simulation Configuration

For fast simulation:

GREEN_TIME  = 4 clocks
YELLOW_TIME = 2 clocks
Clock period = 10 ns

Therefore:

NS_GREEN   → 40 ns
NS_YELLOW  → 20 ns
EW_GREEN   → 40 ns
EW_YELLOW  → 20 ns

The testbench verifies 3 complete traffic-light cycles.

Expected result:

==============================================
              TEST PASSED
Completed 3 traffic cycles.
==============================================
Simulation Waveform

The expected waveform follows:

NS GREEN
    │
    ├── GREEN_TIME cycles
    │
NS YELLOW
    │
    ├── YELLOW_TIME cycles
    │
EW GREEN
    │
    ├── GREEN_TIME cycles
    │
EW YELLOW
    │
    ├── YELLOW_TIME cycles
    │
    └──────────────► NS GREEN
Project Structure
traffic-light-fsm/
│
├── rtl/
│   └── traffic_light_fsm.v
│
├── tb/
│   └── traffic_light_fsm_tb.v
│
├── docs/
│   └── architecture.png
│
└── README.md
Tools Used
Verilog HDL
AMD Vivado
XSim Simulator
RTL Simulation
Self-Checking Testbench
Key Learning Outcomes

Through this project, the following RTL design concepts were implemented:

Finite State Machine design
State encoding
Sequential and combinational logic
Parameterized RTL
Counter-based timing
Synchronous reset
Output decoding
Self-checking testbench
Functional simulation
Waveform analysis
Future Improvements

Possible extensions include:

Clock divider / clock-enable for real-time traffic timing
Pedestrian crossing support
Emergency vehicle priority
Vehicle sensors
Adjustable traffic timing
FPGA implementation
Seven-segment display for countdown timers
Author

Mohammad Ayan Khan

B.Tech Electronics — VLSI Design & Technology
Jamia Millia Islamia
