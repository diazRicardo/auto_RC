# 🚗 FPGA RC Car Project

An FPGA-based remote-controlled car built with Verilog, featuring motor control, state machine logic, and real-time hardware verification.  
Designed as a hands-on embedded systems project to explore hardware acceleration, digital design, and system integration.

---

## 📹 Demo
[![Watch the demo](images/demo_thumbnail.png)](https://youtu.be/your-demo-link)  
*(Click to watch the car in action!)*

---

## ✨ Features
- PWM-based motor speed control
- Obstacle detection using HC-SR04 ultrasonic sensor
- Two finite state machines (FSMs) for control and navigation
- Real-time testing and debugging with FPGA hardware
- Seven-seg display module (for initial sensor debugging)

---

## 🖼️ System Overview
![System Block Diagram](images/system_block_diagram.pdf)

---

## ⚙️ Hardware & Tools
- **FPGA Board:** Xilinx Zynq-7000 Z7-10
- **Sensor/Power regulator:** HC-SR04 ultrasonic sensor, L298n DC-DC
- **HDL:** Verilog
- **Toolchain:** Vivado 2023.2, Xilinx Vitis 2022.2

---

## 📂 Repo Structure
├── /src # Verilog source files

├── /test # Testbenches & simulation outputs

├── /docs # Detailed documentation

├── /images # Diagrams, schematics, photos

└── README.md # This file

## 🧩 Lessons Learned
- Importance of modular design for debugging
- Handling timing constraints, (CDC) in motor PWM generation
- Writing reusable testbenches to validate FSM behavior

## 🔮 Future Work
Improve autonomous navigation mode (via redesigning the FSM controlling the motors)

Add two more HC-SR04 sensors to improve obstacle detection

Optimize resource usage for larger FPGA boards
