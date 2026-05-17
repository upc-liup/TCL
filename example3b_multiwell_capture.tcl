set afile faulted_wells.list
set wlist [log_list _project well]
set nw [llength $wlist]
puts stdout $nw
foreach well $wlist {
        set fw 0
#       puts stdout $well
#       Is this a faulted well?
        if {[file exists $afile] > 0 && $well != ""} {
                set af [open $afile r]
                while {[gets $af aline] >= 0} {
                        if {$well == [lindex $aline 0]} {
                                set fw 1
#                               puts stdout $well
                                break
                        }
                }
                close $af
        } else {
        puts stdout "Cannot open $afile"
        }
        if {$fw == 0} {
                well_open well=$well
                well_layout_open layout = pbu_wurd modified = discard
                if {[log_exists wurd_normlog.rhob_n] & \
                        [log_exists wurd_normlog.dt_n] & \
                        [log_exists wurd_normlog.gr_n] & \
                        [log_exists wurd_picks.pick]} {
                        launcher module = zone1pay set_in = CALC_WURD dialog_mode = NONE \
                        lmdepth = REFERENCE.DEPTH ssdepth = REFERENCE.SSTVD \
                        xcoord = REFERENCE.XCOORD ycoord = REFERENCE.YCOORD \
                        shlflg = CALC_WURD.SHALE STRAT = WURD_PICKS.PICK \
                        fluid = TOPS_FLUIDS_WURD.TOPS
                } else {
                        continue
                }
        } else {
                well_open well=$well
                well_layout_open layout = pbu_wurd modified = discard
                if {[log_exists wurd_normlog.rhob_n] & \
                        [log_exists wurd_normlog.dt_n] & \
                        [log_exists wurd_normlog.gr_n] & \
                        [log_exists wurd_picks.pick] & \
                        [log_exists wurd_faults.pick]} {
                        launcher module = zone1payf set_in = CALC_WURD dialog_mode = NONE \
                        lmdepth = REFERENCE.DEPTH ssdepth = REFERENCE.SSTVD \
                        xcoord = REFERENCE.XCOORD ycoord = REFERENCE.YCOORD \
                        shlflg = CALC_WURD.SHALE STRAT = WURD_PICKS.PICK \
                        fluid = TOPS_FLUIDS_WURD.TOPS fault = WURD_FAULTS.PICK
                } else {
                        continue
                }
        }
}
