global tp_data_set
global tp_data_log
toplevel .swp 

frame .swp.dataset -borderwidth 0
frame .swp.settext -borderwidth 0
frame .swp.datalog -borderwidth 0
frame .swp.logtext -borderwidth 0
frame .swp.spece -borderwidth 0
frame .swp.title -borderwidth 0
frame .swp.tt -borderwidth 0
frame .swp.module_1 -borderwidth 0
frame .swp.arrow_1 -borderwidth 0
frame .swp.module_2 -borderwidth 0
frame .swp.arrow_2 -borderwidth 0
frame .swp.module_3 -borderwidth 0
frame .swp.arrow_3 -borderwidth 0
frame .swp.module_4 -borderwidth 0
frame .swp.arrow_4 -borderwidth 0
frame .swp.module_5 -borderwidth 0
frame .swp.arrow_5 -borderwidth 0
frame .swp.module_6 -borderwidth 0
frame .swp.arrow_6 -borderwidth 0
frame .swp.module_7 -borderwidth 0
frame .swp.arrow_7 -borderwidth 0
frame .swp.module_8 -borderwidth 0
frame .swp.arrow_8 -borderwidth 0
frame .swp.module_9 -borderwidth 0
frame .swp.arrow_9 -borderwidth 0
frame .swp.module_10 -borderwidth 0
frame .swp.arrow_10 -borderwidth 0

###Text Dispaly
label .swp.title.label -width 30 -height 1 -text "2017年 作者：刘鹏"
pack .swp.title.label
label .swp.tt.label -width 30 -height 1 -text "<======显示模板人机交互======>"
pack .swp.tt.label
button .swp.dataset.button  -width 30 -height 1 -text "选择输入的数据集" -command {set tp_data_set [get_set]}
pack .swp.dataset.button
entry .swp.settext.entry -width 30 -background white -textvariable tp_data_set
pack .swp.settext.entry
canvas .swp.spece.canvas -width 100 -height 20
pack .swp.spece.canvas -side top

#module#################################################################
button .swp.datalog.button -width 30 -height 1 -text "选择波列曲线" -command {set tp_data_log [get_log]}
pack .swp.datalog.button
entry .swp.logtext.entry -width 30 -background white -textvariable tp_data_log
pack .swp.logtext.entry

#######################################################################
proc get_set {} {
.swp.dataset.button configure -background green
    set sets [log_list _well set]
    set sets [join $sets "\n"]
    if { [catch {mui_select type = single_select list = $sets } selected_set] } {return}

    return $selected_set
}
#######################################################################
proc get_log {} {
.swp.datalog.button configure -background green
    set logs [log_list _well log]
    set logs [join $logs "\n"]
    if { [catch {mui_select type = single_select list = $logs } selected_log] } {return}

    return $selected_log
}

#module#################################################################
button .swp.module_1.button -width 30 -height 1 -text "加载仪器参数文件（自动）" -command {module_1}
pack .swp.module_1.button -side top
canvas .swp.arrow_1.canvas -width 100 -height 20
pack .swp.arrow_1.canvas -side top
proc module_1 {} {
.swp.module_1.button configure -background yellow
set cmd {
    launcher module = tp_evaluate set_in = $tp_data_set set_out = monopole EXPRESSION=$tp_data_log LOG_OUT=PWF 
tools_start
file_close
    launcher module = tp_array_sonic_loadspec set_in = monopole set_out = monopole TOOL_SPEC=fwp_dsi_m4_mono LOG_IN=PWF dialog_mode=blocked
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_7.button -width 25 -height 1 -text "频率滤波（选做）" -command {module_7}
pack .swp.module_7.button -side top
canvas .swp.arrow_7.canvas -width 100 -height 20
pack .swp.arrow_7.canvas -side top
proc module_7 {} {
.swp.module_7.button configure -background green
set cmd {
    launcher module = tp_array_sonic_filter set_in = monopole set_out = monopole HIGH_END=25 LOG_IN=PWF LOG_OUT=PWF dialog_mode=blocked
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_2.button -width 30 -height 1 -text "时间慢度相关法法处理（自动）" -command {module_2}
pack .swp.module_2.button -side top
canvas .swp.arrow_2.canvas -width 100 -height 20
pack .swp.arrow_2.canvas -side top
proc module_2 {} {
.swp.module_2.button configure -background yellow
set cmd {
    launcher module = tp_array_sonic_process set_in = monopole set_out = monopole UTIME_WINDOW=400 UTIME_STEP=50 DT_FROM=40 DT_TO=240 DT_STEP=1 LOG_IN=PWF dialog_mode=non_blocked
tools_start
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_9.button -width 25 -height 1 -text "生成提波辅助线（纵横波）" -command {module_9}
pack .swp.module_9.button -side top
canvas .swp.arrow_9.canvas -width 100 -height 20
pack .swp.arrow_9.canvas -side top
proc module_9 {} {
.swp.module_9.button configure -background yellow
set cmd {
    launcher module = tp_evaluate set_out = monopole EXPRESSION=80 UNITS=us/f LOG_OUT=DT_GURID1 dialog_mode=none
launcher module = tp_evaluate set_out = monopole EXPRESSION=140 UNITS=us/f LOG_OUT=DT_GURID2 dialog_mode=none
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_10.button -width 25 -height 1 -text "生成提波辅助线（斯通利波）" -command {module_10}
pack .swp.module_10.button -side top
canvas .swp.arrow_10.canvas -width 100 -height 20
pack .swp.arrow_10.canvas -side top
proc module_10 {} {
.swp.module_10.button configure -background yellow
set cmd {
    launcher module = tp_evaluate set_out = monopole EXPRESSION=210 UNITS=us/f LOG_OUT=DT_GURID3 dialog_mode=none
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}

#module#################################################################
button .swp.module_3.button -width 20 -height 1 -text "提波（纵横波）" -command {module_3}
pack .swp.module_3.button -side top
canvas .swp.arrow_3.canvas -width 100 -height 20
pack .swp.arrow_3.canvas -side top
proc module_3 {} {
.swp.module_3.button configure -background yellow
set cmd {
    launcher module = tp_array_sonic_label set_in = monopole set_out = monopole PICK_OPTION=BOTH USE_SEED=GUIDE_LOG DT_P1=DT_GURID1 DT_P2=DT_GURID2 PROJECTION=PROJECTION_R dialog_mode=blocked
launcher module = tp_smooth set_in = monopole set_out = monopole LOG_IN=DT_PICK1 LOG_OUT=DTC dialog_mode=none
launcher module = tp_smooth set_in = monopole set_out = monopole LOG_IN=DT_PICK2 LOG_OUT=DTS dialog_mode=none
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_4.button -width 20 -height 1 -text "提波（斯通利波）" -command {module_4}
pack .swp.module_4.button -side top
canvas .swp.arrow_4.canvas -width 100 -height 20
pack .swp.arrow_4.canvas -side top
proc module_4 {} {
.swp.module_4.button configure -background yellow
set cmd {
    launcher module = tp_array_sonic_label set_in = monopole set_out = monopole USE_SEED=GUIDE_LOG DT_P1=DT_GURID3 PROJECTION=PROJECTION_R_stoneley DT_PICK1=DT_PICK3 dialog_mode=blocked
launcher module = tp_smooth set_in = monopole set_out = monopole LOG_IN=DT_PICK3 LOG_OUT=DTST dialog_mode=none
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}

#module#################################################################
button .swp.module_8.button -width 20 -height 1 -text "单极子提波模板显示" -command {module_8}
pack .swp.module_8.button -side top
canvas .swp.arrow_8.canvas -width 100 -height 20
pack .swp.arrow_8.canvas -side top
proc module_8 {} {
.swp.module_8.button configure -background green
set cmd {
layout_open layout=lp_swp_monopole_pwf
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_5.button -width 20 -height 1 -text "单极子频散计算" -command {module_5}
pack .swp.module_5.button -side top
canvas .swp.arrow_5.canvas -width 100 -height 20
pack .swp.arrow_5.canvas -side top
proc module_5 {} {
.swp.module_5.button configure -background yellow
set cmd {
launcher module = tp_array_sonic_sf set_in = monopole set_out = monopole FREQ_TO=25 DT_ESTIMATE=DTC LOG_IN=PWF OPT_TRACE_NORM=Yes OPT_DC_REMOVE=Yes OPT_GAIN=Yes MAP2D_SF=MAP2D_SF_dtc PROJECTION_SF=PROJECTION_SF_dtc SPECTRUM=SPECTRUM_dtc DISPERSION=DISPERSION_dtc dialog_mode=blocked
launcher module = tp_array_sonic_sf set_in = monopole set_out = monopole FREQ_TO=25 DT_ESTIMATE=DTs LOG_IN=PWF OPT_TRACE_NORM=Yes OPT_DC_REMOVE=Yes OPT_GAIN=Yes MAP2D_SF=MAP2D_SF_dts PROJECTION_SF=PROJECTION_SF_dts SPECTRUM=SPECTRUM_dts DISPERSION=DISPERSION_dts
tools_start
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}
#module#################################################################
button .swp.module_6.button -width 20 -height 1 -text "单极子频散图显示" -command {module_6}
pack .swp.module_6.button -side top
canvas .swp.arrow_6.canvas -width 100 -height 20
pack .swp.arrow_6.canvas -side top
proc module_6 {} {
.swp.module_6.button configure -background green
set cmd {
arrayplot arrayplot = lp_dispersion_p_s
    }
catch [list min_send [tk appname] $cmd] msg
    if {$msg !=""} { return $msg}
}

###Set Grid up the frames
grid .swp.dataset -column 0 -row 0
grid .swp.settext -column 1 -row 0
grid .swp.datalog -column 0 -row 1
grid .swp.logtext -column 1 -row 1
grid .swp.spece -column 1 -row 2
grid .swp.title -column 2 -row 0
grid .swp.tt -column 1 -row 10
grid .swp.module_1 -column 1 -row 6
grid .swp.arrow_1 -column 1 -row 7
grid .swp.module_2 -column 1 -row 8
grid .swp.arrow_2 -column 1 -row 9
grid .swp.module_3 -column 0 -row 12
grid .swp.arrow_3 -column 0 -row 13
grid .swp.module_4 -column 2 -row 12
grid .swp.arrow_4 -column 2 -row 13
grid .swp.module_5 -column 1 -row 19
grid .swp.arrow_5 -column 1 -row 20
grid .swp.module_6 -column 1 -row 21
grid .swp.arrow_6 -column 1 -row 22
grid .swp.module_7 -column 0 -row 8
grid .swp.arrow_7 -column 0 -row 9
grid .swp.module_8 -column 1 -row 16
grid .swp.arrow_8 -column 1 -row 17
grid .swp.module_9 -column 0 -row 10
grid .swp.arrow_9 -column 0 -row 11
grid .swp.module_10 -column 2 -row 10
grid .swp.arrow_10 -column 2 -row 11

###Set arrows parameter
.swp.arrow_1.canvas create line 50 0 50 20 -arrow last -width 5
.swp.arrow_2.canvas create line 50 0 50 20 -arrow last -width 5
.swp.arrow_5.canvas create line 50 0 50 20 -arrow last -width 5
.swp.arrow_9.canvas create line 50 0 50 20 -arrow last -width 5
.swp.arrow_10.canvas create line 50 0 50 20 -arrow last -width 5