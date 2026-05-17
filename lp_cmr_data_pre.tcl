# Recorded well workflow
set list_set [log_list _well set]

set list_set [join $list_set "\n"]
if { [catch {mui_select name = id_set\
                 title= "Select RAW CMR plus data"\
                 message = "Select a set containing raw CMR plus data"\
                 type=single_select\
                 list= $list_set\
                 list_title= "Sets"} id_set ] } {
    return
}
launcher module = cmr_plus_record  set_in = $id_set set_out = $id_set dialog_mode = blocked
launcher module = cmr_plus_record  set_in = $id_set set_out =CMR_PROCESS dialog_mode = none
launcher module = nmr_cmr_calibrate set_in = $id_set set_out =CMR_PROCESS dialog_mode = none
launcher module = nmr_cmr_plus_extract set_in = $id_set set_out =CMR_PROCESS dialog_mode = none

layout_open layout = lp_nmr_cmr_epm_process