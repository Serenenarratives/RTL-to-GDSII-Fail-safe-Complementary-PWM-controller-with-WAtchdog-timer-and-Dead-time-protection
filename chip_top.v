`timescale 1ns / 1ps

module chip_top (
    input  wire       clk_pad,
    input  wire       rst_pad,
    input  wire       en_pad,
    input  wire       wdt_kick_pad,
    input  wire [3:0] duty_cycle_pad,
    input  wire [1:0] dead_time_pad,
    output wire       pwm_high_pad,
    output wire       pwm_low_pad,
    output wire       wdt_fault_pad,
    output wire       safe_shutdown_pad,
    output wire       period_wrap_pad,
    output wire       heartbeat_ack_pad
);

    wire       clk_core;
    wire       rst_core;
    wire       en_core;
    wire       wdt_kick_core;
    wire [3:0] duty_cycle_core;
    wire [1:0] dead_time_core;
    wire       pwm_high_core;
    wire       pwm_low_core;
    wire       wdt_fault_core;
    wire       safe_shutdown_core;
    wire       period_wrap_core;
    wire       heartbeat_ack_core;

    // 1. Power & Ground Supply Pads (4 Pads)
    (* keep *) sky130_ef_io__vccd_lvc_pad  u_pad_vccd1 ();
    (* keep *) sky130_ef_io__vssd_lvc_pad  u_pad_vssd1 ();
    (* keep *) sky130_ef_io__vddio_hvc_pad u_pad_vddio ();
    (* keep *) sky130_ef_io__vssio_hvc_pad u_pad_vssio ();

    // 2. Digital Input Pads (10 Pads)
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_clk      (.PAD(clk_pad),           .IN(clk_core),           .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_rst      (.PAD(rst_pad),           .IN(rst_core),           .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_en       (.PAD(en_pad),            .IN(en_core),            .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_wdt_kick (.PAD(wdt_kick_pad),      .IN(wdt_kick_core),      .OUT(1'b0), .OE_N(1'b1));

    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_duty_0   (.PAD(duty_cycle_pad[0]), .IN(duty_cycle_core[0]), .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_duty_1   (.PAD(duty_cycle_pad[1]), .IN(duty_cycle_core[1]), .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_duty_2   (.PAD(duty_cycle_pad[2]), .IN(duty_cycle_core[2]), .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_duty_3   (.PAD(duty_cycle_pad[3]), .IN(duty_cycle_core[3]), .OUT(1'b0), .OE_N(1'b1));

    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_dt_0     (.PAD(dead_time_pad[0]),  .IN(dead_time_core[0]),  .OUT(1'b0), .OE_N(1'b1));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_dt_1     (.PAD(dead_time_pad[1]),  .IN(dead_time_core[1]),  .OUT(1'b0), .OE_N(1'b1));

    // 3. Digital Output Pads (6 Pads)
    wire nc0, nc1, nc2, nc3, nc4, nc5;
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_pwm_high      (.PAD(pwm_high_pad),      .IN(nc0), .OUT(pwm_high_core),      .OE_N(1'b0));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_pwm_low       (.PAD(pwm_low_pad),       .IN(nc1), .OUT(pwm_low_core),       .OE_N(1'b0));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_wdt_fault     (.PAD(wdt_fault_pad),     .IN(nc2), .OUT(wdt_fault_core),     .OE_N(1'b0));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_safe_shutdown (.PAD(safe_shutdown_pad), .IN(nc3), .OUT(safe_shutdown_core), .OE_N(1'b0));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_period_wrap   (.PAD(period_wrap_pad),   .IN(nc4), .OUT(period_wrap_core),   .OE_N(1'b0));
    (* keep *) sky130_ef_io__gpiov2_pad_wrapped pad_heartbeat_ack (.PAD(heartbeat_ack_pad), .IN(nc5), .OUT(heartbeat_ack_core), .OE_N(1'b0));

    // 4. Core Instance
    (* keep *) pwd_controller u_core (
        .clk           (clk_core),
        .rst           (rst_core),
        .en            (en_core),
        .wdt_kick      (wdt_kick_core),
        .duty_cycle    (duty_cycle_core),
        .dead_time     (dead_time_core),
        .pwm_high      (pwm_high_core),
        .pwm_low       (pwm_low_core),
        .wdt_fault     (wdt_fault_core),
        .safe_shutdown (safe_shutdown_core),
        .period_wrap   (period_wrap_core),
        .heartbeat_ack (heartbeat_ack_core)
    );

endmodule
