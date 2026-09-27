
`timescale 1ns / 1ps

module traffic_light_fsm #(
    parameter GREEN_TIME  = 4,
    parameter YELLOW_TIME = 2
)(
    input  clk,
    input  reset,

    output ns_red,
    output ns_yellow,
    output ns_green,

    output ew_red,
    output ew_yellow,
    output ew_green
);

    // =====================================================
    // State encoding
    // =====================================================

    parameter NS_GREEN  = 2'b00;
    parameter NS_YELLOW = 2'b01;
    parameter EW_GREEN  = 2'b10;
    parameter EW_YELLOW = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;

    // =====================================================
    // Counter
    // Width is based on the larger timing value
    // =====================================================

    parameter MAX_TIME =
              (GREEN_TIME > YELLOW_TIME) ?
              GREEN_TIME : YELLOW_TIME;

    reg [31:0] counter;

    // =====================================================
    // State and counter register
    // =====================================================

    always @(posedge clk) begin

        if (reset) begin

            state   <= NS_GREEN;
            counter <= 0;

        end

        else begin

            state <= next_state;

            if (state != next_state)
                counter <= 0;

            else
                counter <= counter + 1'b1;

        end

    end

    // =====================================================
    // Next-state logic
    // =====================================================

    always @(*) begin

        // Default
        next_state = state;

        case (state)

            // -------------------------------------------------
            // North-South GREEN
            // -------------------------------------------------

            NS_GREEN: begin

                if (counter == GREEN_TIME - 1)
                    next_state = NS_YELLOW;
                else
                    next_state = NS_GREEN;

            end

            // -------------------------------------------------
            // North-South YELLOW
            // -------------------------------------------------

            NS_YELLOW: begin

                if (counter == YELLOW_TIME - 1)
                    next_state = EW_GREEN;
                else
                    next_state = NS_YELLOW;

            end

            // -------------------------------------------------
            // East-West GREEN
            // -------------------------------------------------

            EW_GREEN: begin

                if (counter == GREEN_TIME - 1)
                    next_state = EW_YELLOW;
                else
                    next_state = EW_GREEN;

            end

            // -------------------------------------------------
            // East-West YELLOW
            // -------------------------------------------------

            EW_YELLOW: begin

                if (counter == YELLOW_TIME - 1)
                    next_state = NS_GREEN;
                else
                    next_state = EW_YELLOW;

            end

            // -------------------------------------------------
            // Safety state
            // -------------------------------------------------

            default: begin
                next_state = NS_GREEN;
            end

        endcase

    end

    // =====================================================
    // Traffic light outputs
    // =====================================================

    assign ns_red =
           (state == EW_GREEN) ||
           (state == EW_YELLOW);

    assign ns_yellow =
           (state == NS_YELLOW);

    assign ns_green =
           (state == NS_GREEN);

    assign ew_red =
           (state == NS_GREEN) ||
           (state == NS_YELLOW);

    assign ew_yellow =
           (state == EW_YELLOW);

    assign ew_green =
           (state == EW_GREEN);

endmodule
