`timescale 1ns / 1ps

(* blackbox, keep *)
module sky130_ef_io__gpiov2_pad_wrapped (
    inout  wire PAD,
    output wire IN,
    input  wire OUT,
    input  wire OE_N,
    input  wire INP_DIS,
    input  wire [2:0] DM,
    input  wire HLD_H_N,
    input  wire ENABLE_H,
    input  wire ENABLE_INP_H,
    input  wire ENABLE_VDDA_H,
    input  wire ENABLE_VSWITCH_H,
    input  wire ENABLE_VDDIO,
    input  wire HLD_OVR,
    input  wire ANALOG_EN,
    input  wire ANALOG_SEL,
    input  wire ANALOG_POL,
    input  wire SLOW,
    input  wire VTRIP_SEL,
    input  wire IB_MODE_SEL,
    output wire IN_H,
    output wire TIE_HI_ESD,
    output wire TIE_LO_ESD,
    inout  wire VCCD,
    inout  wire VSSD,
    inout  wire VDDIO,
    inout  wire VSSIO
);
endmodule

(* blackbox, keep *)
module sky130_ef_io__vccd_lvc_pad (
    inout wire VCCD,
    inout wire VSSD,
    inout wire VDDIO,
    inout wire VSSIO
);
endmodule

(* blackbox, keep *)
module sky130_ef_io__vssd_lvc_pad (
    inout wire VCCD,
    inout wire VSSD,
    inout wire VDDIO,
    inout wire VSSIO
);
endmodule

(* blackbox, keep *)
module sky130_ef_io__vddio_hvc_pad (
    inout wire VCCD,
    inout wire VSSD,
    inout wire VDDIO,
    inout wire VSSIO
);
endmodule

(* blackbox, keep *)
module sky130_ef_io__vssio_hvc_pad (
    inout wire VCCD,
    inout wire VSSD,
    inout wire VDDIO,
    inout wire VSSIO
);
endmodule

(* blackbox, keep *)
module sky130_ef_io__corner_pad (
    inout wire VCCD,
    inout wire VSSD,
    inout wire VDDIO,
    inout wire VSSIO
);
endmodule
