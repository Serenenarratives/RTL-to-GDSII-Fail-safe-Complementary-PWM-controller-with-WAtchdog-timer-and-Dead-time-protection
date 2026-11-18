set db [ord::get_db]
set tech [$db getTech]
set chip [$db getChip]
set block [$chip getBlock]
set dbu [$block getDefUnits]

proc place_fixed_pad {block dbu name x_um y_um orient} {
    set inst [$block findInst $name]
    if {$inst == "NULL"} {
        puts "WARNING: Pad instance $name not found!"
        return
    }
    $inst setOrient $orient
    $inst setLocation [expr {int($x_um * $dbu)}] [expr {int($y_um * $dbu)}]
    $inst setPlacementStatus "FIRM"
}

# 1. Create and lock the 4 corner pads inset inside [0, 0, 1200, 1200]
set corner_master [$db findMaster "sky130_ef_io__corner_pad"]
if {$corner_master != "NULL"} {
    foreach {cname x y orient} {
        corner_sw 25  25  R0
        corner_se 970 25  R90
        corner_ne 970 970 R180
        corner_nw 25  970 R270
    } {
        set cinst [$block findInst $cname]
        if {$cinst == "NULL"} {
            set cinst [odb::dbInst_create $block $corner_master $cname]
        }
        $cinst setOrient $orient
        $cinst setLocation [expr {int($x * $dbu)}] [expr {int($y * $dbu)}]
        $cinst setPlacementStatus "FIRM"
    }
}

# 2. Place and lock the 20 pads on WEST (x=25), NORTH (y=970), EAST (x=970), SOUTH (y=25)
set coords {260 390 520 650 780}
foreach pname {pad_clk pad_rst pad_en pad_wdt_kick u_pad_vccd1} y $coords {
    place_fixed_pad $block $dbu $pname 25 $y R270
}
foreach pname {pad_duty_0 pad_duty_1 pad_duty_2 pad_duty_3 u_pad_vssd1} x $coords {
    place_fixed_pad $block $dbu $pname $x 970 R180
}
foreach pname {pad_pwm_high pad_pwm_low pad_wdt_fault pad_safe_shutdown pad_period_wrap} y $coords {
    place_fixed_pad $block $dbu $pname 970 $y R90
}
foreach pname {pad_dt_0 pad_dt_1 u_pad_vddio u_pad_vssio pad_heartbeat_ack} x $coords {
    place_fixed_pad $block $dbu $pname $x 25 R0
}

# 3. Place top-level port terminals directly onto the pad cells' PAD pins
catch { place_io_terminals pad_*/PAD }

# 4. Fallback for any remaining unplaced top-level ports (BTerms)
set pin_layer [$tech findLayer "met5"]
if {$pin_layer == "NULL"} {
    set pin_layer [$tech findLayer "met4"]
}

foreach bterm [$block getBTerms] {
    if {[llength [$bterm getBPins]] == 0} {
        set net [$bterm getNet]
        set cx [expr {100 * $dbu}]
        set cy [expr {260 * $dbu}]
        if {$net != "NULL"} {
            foreach iterm [$net getITerms] {
                set inst [$iterm getInst]
                if {$inst != "NULL"} {
                    set bbox [$iterm getBBox]
                    set cx [expr {([$bbox xMin] + [$bbox xMax]) / 2}]
                    set cy [expr {([$bbox yMin] + [$bbox yMax]) / 2}]
                    break
                }
            }
        }
        set bpin [odb::dbBPin_create $bterm]
        odb::dbBox_create $bpin $pin_layer [expr {$cx - 2000}] [expr {$cy - 2000}] [expr {$cx + 2000}] [expr {$cy + 2000}]
        $bpin setPlacementStatus "FIRM"
    }
}
puts "INFO: Custom Sky130 PadRing and top-level BTerms placed inside die area."
