/*
 * CORRECTED TMR Implementation: 3 ALUs + Hardware Voter Simulation
 * This simulates HARDWARE TMR (not 3 cores)
 * 
 * Architecture:
 * - Single fetch/decode unit
 * - 3 parallel ALUs 
 * - Hardware majority voter
 * - Same as FPGA TMR but in software simulation
 */

// TMR ALU Structure (simulates 3 hardware ALUs)
typedef struct {
    volatile int alu0_result;
    volatile int alu1_result; 
    volatile int alu2_result;
    volatile int voted_result;
    volatile int error_flags;
} tmr_alu_t;

// Global TMR ALU instance
tmr_alu_t tmr_alu = {0, 0, 0, 0, 0};

// Simulate individual ALU hardware units
volatile int alu0_execute(volatile int operand_a, volatile int operand_b) {
    // ALU 0 - Direct hardware addition (same as FPGA ALU 0)
    return operand_a + operand_b;
}

volatile int alu1_execute(volatile int operand_a, volatile int operand_b) {
    // ALU 1 - Direct hardware addition (same as FPGA ALU 1)
    return operand_a + operand_b;
}

volatile int alu2_execute(volatile int operand_a, volatile int operand_b) {
    // ALU 2 - Direct hardware addition (same as FPGA ALU 2)
    return operand_a + operand_b;
}

// Hardware Majority Voter (simulates FPGA voter logic)
volatile int hardware_majority_voter(volatile int r0, volatile int r1, volatile int r2) {
    // Same logic as FPGA hardware voter
    if (r0 == r1) return r0;      // ALU 0 and 1 agree
    else if (r0 == r2) return r0; // ALU 0 and 2 agree  
    else if (r1 == r2) return r1; // ALU 1 and 2 agree
    else {
        // All ALUs disagree - major fault (same as FPGA)
        tmr_alu.error_flags |= 0x07;
        return r0; // Default to ALU 0 (hardware behavior)
    }
}

// TMR Error Detection (simulates FPGA error detection)
volatile int detect_alu_errors(volatile int r0, volatile int r1, volatile int r2) {
    volatile int errors = 0;
    if (r0 != r1) errors |= 0x01;  // ALU 0-1 mismatch
    if (r0 != r2) errors |= 0x02;  // ALU 0-2 mismatch
    if (r1 != r2) errors |= 0x04;  // ALU 1-2 mismatch
    return errors;
}

// TMR ALU Operation (simulates single RISC-V instruction with TMR ALUs)
volatile int tmr_alu_add(volatile int a, volatile int b) {
    // Simulate parallel ALU execution (same as FPGA)
    // In hardware, this happens in SINGLE CLOCK CYCLE
    
    // Execute on all 3 ALUs simultaneously (parallel in hardware)
    tmr_alu.alu0_result = alu0_execute(a, b);
    tmr_alu.alu1_result = alu1_execute(a, b);
    tmr_alu.alu2_result = alu2_execute(a, b);
    
    // Hardware error detection
    tmr_alu.error_flags = detect_alu_errors(
        tmr_alu.alu0_result,
        tmr_alu.alu1_result,
        tmr_alu.alu2_result
    );
    
    // Hardware majority voting
    tmr_alu.voted_result = hardware_majority_voter(
        tmr_alu.alu0_result,
        tmr_alu.alu1_result,
        tmr_alu.alu2_result
    );
    
    return tmr_alu.voted_result;
}

// Main TMR function (simulates FPGA TMR processor)
void main_tmr(void) {
    // Same algorithm as Single SoC and FPGA
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;
    
    // Single instruction with TMR ALU (same as FPGA)
    result = tmr_alu_add(a, b);
    
    // Expected results:
    // alu0_result = 30
    // alu1_result = 30
    // alu2_result = 30  
    // voted_result = 30
    // error_flags = 0
    
    // Same infinite loop as Single SoC and FPGA
    while(1) {
        // Keep system alive
        // In FPGA, this would be continuous operation
    }
}

/*
 * TMR ANALYSIS (CORRECTED):
 * 
 * RESOURCES:
 * - 3x ALU hardware (vs 1x in Single)
 * - 1x Voter logic 
 * - 1x Error detection
 * - Same fetch/decode/registers
 * 
 * PERFORMANCE:
 * - SAME latency as Single (parallel ALUs)
 * - SAME throughput (single cycle)
 * - Voter adds minimal delay (~1 gate delay)
 * 
 * POWER:
 * - ~3x ALU power (3 ALUs vs 1)
 * - +Voter power
 * - +Error detection power
 * - Same control/memory power
 * 
 * RELIABILITY:
 * - Tolerates 1 ALU failure
 * - Detects up to 2 ALU failures
 * - Hardware-level fault tolerance
 */