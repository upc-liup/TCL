set cmd {
        #       Get the well
        #
        if { [info exists env(PG_WELL)] } {
            set inputwell $env(PG_WELL)
        } else {
            set inputwell ""
        }
        if {$inputwell == ""} {
                puts stderr "Please Open a Well!!"
        } else {
                well_open well = $inputwell
        }
        #
        #       Now get the set
        #
        regsub -all " " [log_list _well set] "\n" sets
        set inputset [ mui_select list = $sets type = single_select list_title = set selection ]
        well_default_set set = $inputset
        #
        #       And now the logs
        #
        regsub -all " " [ log_list $inputset log ] "\n" logs
        set inputlog [ mui_select list = $logs type = single_select list_title = input curve ]
        #
        #       Form the output name from the input name
        #
        set outputlog [join "[lindex [split $inputlog _] 0] [lindex [split $inputlog _] 1] N" _]
        #puts stderr [list $inputlog $outputlog]
        #      Initialize variables
        set aa 0.0
        set bb 1.0
        set hi1 ""
        set hi2 ""
        set lo1 ""
        set lo2 ""
        #     Build GUI elements
        toplevel .cp
        wm title .cp "Compute A and B"
        frame .cp.qt
        pack .cp.qt -side top -fill x
        button .cp.qt.b -text "Dismiss" -bg steelblue -command {destroy .cp}
        button .cp.qt.go -text "Evaluate" -bg green -command evaluate
        pack .cp.qt.go .cp.qt.b -side right -padx 5
        frame .cp.bh
        pack .cp.bh -side top -fill x
        label .cp.bh.l -text "                 Corrected"
        label .cp.bh.2 -text "   Current"
        pack .cp.bh.l .cp.bh.2 -side left -padx 50
        frame .cp.bx
        pack .cp.bx -side top -fill x
        frame .cp.ba
        pack .cp.ba -side top -fill x
        label .cp.bx.l1 -text "High Porosity   "
        label .cp.bx.le -text "  =  A  +   "
        label .cp.bx.l2 -text "  B"
        label .cp.ba.le -text "  =  A  +   "
        label .cp.ba.l2 -text "  B"
        label .cp.ba.l3 -text "Low Porosity   "
        entry .cp.bx.b1 -width 10 -relief sunken -textvar hi1
        entry .cp.bx.b2 -width 10 -relief sunken -textvar hi2
        entry .cp.ba.b1 -width 10 -relief sunken -textvar lo1
        entry .cp.ba.b2 -width 10 -relief sunken -textvar lo2
        pack .cp.bx.l1 .cp.bx.b1 .cp.bx.le .cp.bx.b2 .cp.bx.l2 -side left -padx 5
        pack .cp.ba.l3 .cp.ba.b1 .cp.ba.le .cp.ba.b2 .cp.ba.l2 -side left -padx 5
        frame .cp.butns
        pack .cp.butns -side top -fill x
        button .cp.butns.b0 -text "Get A & B" -bg orange -command getab
        label .cp.butns.l1 -text "  A = "
        label .cp.butns.l2 -text "  B = "
        entry .cp.butns.a1 -width 10 -relief sunken -textvar aa
        entry .cp.butns.b1 -width 10 -relief sunken -textvar bb
        pack .cp.butns.b0 .cp.butns.l1 .cp.butns.a1 .cp.butns.l2 .cp.butns.b1 -side left -padx 5
        #     Proc to compute a and b and store as header constants
        proc getab {} {
                global inputwell inputset hi1 hi2 lo1 lo2 aa bb
                set dif1 [expr $hi1 - $lo1]
                set dif2 [expr $hi2 - $lo2]
                set bb [expr $dif1 / $dif2]
                set aa [expr $hi1 - $hi2 * $bb]
                puts stderr [list $aa $bb]
                log_put well_header.a_$inputset $aa
                log_put well_header.b_$inputset $bb
        }
        #     Proc to infill tp_evaluate module and display
        proc evaluate {} {
                global inputwell inputset inputlog outputlog aa bb
                launcher module = tp_evaluate set_in = $inputset \
                set_out = $inputset expression = $inputlog + $aa \
                log_out = $outputlog
        }
}
#
#       Now submit the entire string to the well interpreter
#
set wapp [min_connect well]
if { $wapp != "" } {
        catch [list min_send $wapp $cmd] msg
        if {$msg != ""} {
                puts $msg
        }
}
