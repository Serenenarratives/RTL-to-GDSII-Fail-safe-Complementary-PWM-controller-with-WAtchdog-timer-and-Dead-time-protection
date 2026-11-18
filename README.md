# Fail-safe Complementary PWM Controller with Watchdog Timer and Dead-Time Protection

A small digital IP block written in Verilog and taken from RTL toward GDSII with the open-source **LibreLane** flow (Sky130).

It generates a pair of complementary PWM signals for a half-bridge power stage, inserts a programmable dead-time between them, and forces everything off if a watchdog timer is not "kicked" in time.

> **Status: work in progress.** The RTL is complete and a standalone layout was generated and viewed in KLayout. The chip-level pad ring (files `chip_top.v`, `pad_cfg.tcl`, `sky130_io_blackbox.v`) is still being debugged. See [Status](#status).

## Features

- PWM generator, 4-bit resolution, 16-clock period
- Programmable dead-time of 0 to 3 clock cycles; `pwm_high` and `pwm_low` are never on together
- Watchdog timer: fault after 64 clock cycles without a kick
- 3-state FSM: `IDLE`, `RUN`, `FAULT`, with a safe-shutdown output
- All outputs registered (glitch-free, change only on the rising clock edge)
- Single clock domain, synchronous active-high reset
- 18 flip-flops (2 state + 4 PWM counter + 6 watchdog counter + 6 outputs)

## Interface

| Pin | Dir | Width | Description |
| --- | --- | --- | --- |
| `clk` | in | 1 | Clock, rising edge |
| `rst` | in | 1 | Synchronous reset, active high |
| `en` | in | 1 | Enable. 0 returns to IDLE and clears a fault |
| `wdt_kick` | in | 1 | Watchdog kick ("I am alive") |
| `duty_cycle` | in | 4 | PWM duty setting, 0 to 15 |
| `dead_time` | in | 2 | Dead-time in clock cycles, 0 to 3 |
| `pwm_high` | out | 1 | High-side drive |
| `pwm_low` | out | 1 | Low-side drive |
| `wdt_fault` | out | 1 | 1 while in FAULT |
| `safe_shutdown` | out | 1 | 1 when not actively running (reset, IDLE, FAULT) |
| `period_wrap` | out | 1 | 1 during the last clock cycle of each PWM period |
| `heartbeat_ack` | out | 1 | 1 for the cycle after an accepted kick |

## How it works

Let `cnt` be the 4-bit PWM counter (0 to 15, wraps), `duty = duty_cycle` and `dt = dead_time`:

- **High side on** when `dt <= cnt < duty`
- **Low side on** when `cnt >= duty + dt` and `duty != 15`

The comparison uses 5-bit zero-extended values so `duty + dt` (up to 18) cannot overflow.

Results that follow from these rules:

- High-side on-time is `duty - dt` clock cycles per period.
- There is a gap of exactly `dt` cycles with both outputs off at each switch-over.
- `duty = 15` gives 15/16 high-side drive and the low side stays off.
- PWM frequency is `fclk / 16`; output latency is one clock cycle.

### State machine

| State | Code | Behaviour |
| --- | --- | --- |
| IDLE | `00` | Outputs off, counters cleared, `safe_shutdown = 1`. Goes to RUN when `en = 1` |
| RUN | `01` | PWM and watchdog counters run |
| FAULT | `10` | Outputs forced off, `wdt_fault = 1`. Cleared only by `en = 0` (or reset) |

Inside RUN, `en = 0` is checked first (go to IDLE), then the watchdog (`wdt_cnt == 63` and no kick goes to FAULT), then normal operation. A fault occurs on the 64th clock cycle after the last kick. A kick arriving on the cycle the counter reads 63 still saves the block. Code `11` is unused and returns to IDLE.

## Repository contents

| File | Purpose |
| --- | --- |
| `pwd_controller.v` | The IP block (module `pwd_controller`) |
| `config.json` | LibreLane configuration (chip-level / pad ring experiment) |
| `chip_top.v` | Chip-level wrapper with I/O pad instances around the core |
| `sky130_io_blackbox.v` | Black-box stubs for the Sky130 I/O pad cells |
| `pad_cfg.tcl` | OpenROAD script that places the pad ring |
| `chip_top.sdc` | Timing constraints for the chip-level design |
| `Images/` | Screenshots and layout pictures |
| `LICENSE` | Apache 2.0 |

## Building the layout

Requirements: LibreLane (tested with v3.0.16), the Sky130 PDK, and KLayout.

For the standalone block, use a minimal config such as the following (save as `config_macro.json`):

```json
{
  "DESIGN_NAME": "pwd_controller",
  "VERILOG_FILES": "dir::pwd_controller.v",
  "CLOCK_PORT": "clk",
  "CLOCK_PERIOD": 20,
  "PDN_MULTILAYER": false,
  "FP_SIZING": "relative",
  "FP_CORE_UTIL": 40
}
```

Run it:

```
librelane config_macro.json
```

The GDS is written to `runs/<run-name>/final/gds/`. Open it with KLayout.

## Status

- [x] RTL written and lint-clean with Verilator (the check inside LibreLane)
- [x] Standalone layout generated and viewed in KLayout
- [ ] Chip-level pad ring: in progress (pad placement step of the Chip flow fails with the current `pad_cfg.tcl`)
- [ ] Self-checking testbench and simulation results
- [ ] Multi-corner timing results
- [ ] Final DRC and LVS reports

## Known limitations

- A `wdt_kick` held permanently high disables the watchdog; the system should drive kick as a periodic pulse.
- `en` and `wdt_kick` are assumed synchronous to `clk`; asynchronous sources need an external synchronizer.
- `duty_cycle` and `dead_time` take effect on the next cycle and are not latched at period boundaries.
- The watchdog timeout is fixed at 64 clock cycles.

## License

Apache License 2.0. See [LICENSE](LICENSE).
