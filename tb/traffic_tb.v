
`timescale 1ns / 1ps

module traffic_light_fsm_tb;

    // =====================================================
    // Simulation parameters
    // =====================================================

    parameter GREEN_TIME  = 4;
    parameter YELLOW_TIME = 2;

    // =====================================================
    // Signals
    // =====================================================

    reg clk;
    reg reset;

    wire ns_red;
    wire ns_yellow;
    wire ns_green;

    wire ew_red;
    wire ew_yellow;
    wire ew_green;

    integer errors;
    integer cycle_count;

    // =====================================================
    // DUT
    // =====================================================

    traffic_light_fsm #(
        .GREEN_TIME(GREEN_TIME),
        .YELLOW_TIME(YELLOW_TIME)
    ) dut (
        .clk(clk),
        .reset(reset),

        .ns_red(ns_red),
        .ns_yellow(ns_yellow),
        .ns_green(ns_green),

        .ew_red(ew_red),
        .ew_yellow(ew_yellow),
        .ew_green(ew_green)
    );

    // =====================================================
    // Clock
    // 10 ns period = 100 MHz
    // =====================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end

    // =====================================================
    // Main test
    // =====================================================

    initial begin

        errors = 0;
        cycle_count = 0;

        $display("");
        $display("==============================================");
        $display("       TRAFFIC LIGHT FSM TESTBENCH");
        $display("==============================================");
        $display("GREEN_TIME  = %0d clocks", GREEN_TIME);
        $display("YELLOW_TIME = %0d clocks", YELLOW_TIME);
        $display("==============================================");
        $display("");

        // -------------------------------------------------
        // Reset
        // -------------------------------------------------

        reset = 1'b1;

        #20;

        // Check reset state
        check_ns_green;

        // -------------------------------------------------
        // Release reset
        // -------------------------------------------------

        reset = 1'b0;

        // -------------------------------------------------
        // Run 3 complete cycles
        // -------------------------------------------------

        repeat (3) begin

            // =============================================
            // NS GREEN
            // =============================================

            check_ns_green;

            repeat (GREEN_TIME) begin

                @(posedge clk);
                #1;

                check_outputs;

            end

            // =============================================
            // NS YELLOW
            // =============================================

            check_ns_yellow;

            repeat (YELLOW_TIME) begin

                @(posedge clk);
                #1;

                check_outputs;

            end

            // =============================================
            // EW GREEN
            // =============================================

            check_ew_green;

            repeat (GREEN_TIME) begin

                @(posedge clk);
                #1;

                check_outputs;

            end

            // =============================================
            // EW YELLOW
            // =============================================

            check_ew_yellow;

            repeat (YELLOW_TIME) begin

                @(posedge clk);
                #1;

                check_outputs;

            end

            cycle_count = cycle_count + 1;

        end

        // -------------------------------------------------
        // Final result
        // -------------------------------------------------

        #10;

        $display("");
        $display("==============================================");

        if (errors == 0) begin

            $display("              TEST PASSED");
            $display("Completed %0d traffic cycles.", cycle_count);

        end

        else begin

            $display("              TEST FAILED");
            $display("Total errors = %0d", errors);

        end

        $display("==============================================");
        $display("");

        $finish;

    end

    // =====================================================
    // Check NS GREEN
    // =====================================================

    task check_ns_green;

        begin

            #1;

            if (ns_green == 1'b1 &&
                ns_yellow == 1'b0 &&
                ns_red == 1'b0 &&
                ew_red == 1'b1 &&
                ew_yellow == 1'b0 &&
                ew_green == 1'b0) begin

                $display(
                    "PASS @ %0t : NS GREEN / EW RED",
                    $time
                );

            end

            else begin

                $display(
                    "FAIL @ %0t : Expected NS GREEN / EW RED",
                    $time
                );

                errors = errors + 1;

            end

        end

    endtask

    // =====================================================
    // Check NS YELLOW
    // =====================================================

    task check_ns_yellow;

        begin

            #1;

            if (ns_green == 1'b0 &&
                ns_yellow == 1'b1 &&
                ns_red == 1'b0 &&
                ew_red == 1'b1 &&
                ew_yellow == 1'b0 &&
                ew_green == 1'b0) begin

                $display(
                    "PASS @ %0t : NS YELLOW / EW RED",
                    $time
                );

            end

            else begin

                $display(
                    "FAIL @ %0t : Expected NS YELLOW / EW RED",
                    $time
                );

                errors = errors + 1;

            end

        end

    endtask

    // =====================================================
    // Check EW GREEN
    // =====================================================

    task check_ew_green;

        begin

            #1;

            if (ns_green == 1'b0 &&
                ns_yellow == 1'b0 &&
                ns_red == 1'b1 &&
                ew_red == 1'b0 &&
                ew_yellow == 1'b0 &&
                ew_green == 1'b1) begin

                $display(
                    "PASS @ %0t : NS RED / EW GREEN",
                    $time
                );

            end

            else begin

                $display(
                    "FAIL @ %0t : Expected NS RED / EW GREEN",
                    $time
                );

                errors = errors + 1;

            end

        end

    endtask

    // =====================================================
    // Check EW YELLOW
    // =====================================================

    task check_ew_yellow;

        begin

            #1;

            if (ns_green == 1'b0 &&
                ns_yellow == 1'b0 &&
                ns_red == 1'b1 &&
                ew_red == 1'b0 &&
                ew_yellow == 1'b1 &&
                ew_green == 1'b0) begin

                $display(
                    "PASS @ %0t : NS RED / EW YELLOW",
                    $time
                );

            end

            else begin

                $display(
                    "FAIL @ %0t : Expected NS RED / EW YELLOW",
                    $time
                );

                errors = errors + 1;

            end

        end

    endtask

    // =====================================================
    // General safety checks
    // =====================================================

    task check_outputs;

        begin

            // Exactly one NS light must be ON
            if ((ns_red + ns_yellow + ns_green) != 1) begin

                $display(
                    "FAIL @ %0t : Invalid NS light combination",
                    $time
                );

                errors = errors + 1;

            end

            // Exactly one EW light must be ON
            if ((ew_red + ew_yellow + ew_green) != 1) begin

                $display(
                    "FAIL @ %0t : Invalid EW light combination",
                    $time
                );

                errors = errors + 1;

            end

            // Both directions must never be green
            if (ns_green && ew_green) begin

                $display(
                    "FAIL @ %0t : BOTH directions are GREEN!",
                    $time
                );

                errors = errors + 1;

            end

            // Both directions must never be yellow
            if (ns_yellow && ew_yellow) begin

                $display(
                    "FAIL @ %0t : BOTH directions are YELLOW!",
                    $time
                );

                errors = errors + 1;

            end

        end

    endtask

endmodule
