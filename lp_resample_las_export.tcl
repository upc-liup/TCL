set list_set [log_list _well set]

set list_set [join $list_set "\n"]
if { [catch {mui_select name = id_set\
                 title= "Select dataset"\
                 message = ""\
                 type=single_select\
                 list= $list_set\
                 list_title= "Sets"} id_set ] } {
    return
}

set project [log_dbms mode = list select = _root]

##########################
# Get well list
##########################

if {$env(PG_MODULE_MAIN) == "MUI_WELL"} {
  set allwells [join [ log_list _project process_wells ] "\t"]
  if {[ llength $allwells ] == 0} {
    set allwells [join [ log_list _project well] "\t"]
  }
} {
  set allwells [join [ log_dbms mode = list project = $project well = _all set= select = _project] "\t"]
}
if {[llength $allwells] == 1} {
  set wells $allwells
} {
catch {mui_select type = multiple_select title = Select Wells list_title = Select wells to process list = $allwells } wells
if { [ string match "\nchild " [string range $wells 0 6 ] ] } {
  puts "Program cancelled by user."
  return
}
}
puts "Selected Wells: $wells"

# Get unit system
if {$env(PG_UNIT_SYSTEM) == "metric" | $env(PG_UNIT_SYSTEM) == "mixed"} {
  set units "METRES"
} {
  set units "FEET"
}

# Get output directory
catch {mui_dialog type = prompt title = Output Directory message = 设置输出路径 default = ./data/} directory
if {[string match "Cancel" [string range $directory 0 5]]} {
  puts "Program cancelled by user."
  return
}
# Get desired output sample rate
if {$units == "METRES"} {
  set default_sr 0.1524
} {
  set default_sr 0.5
}
catch {mui_dialog type = prompt title = Sample rate message = 设置输出采样率 $units data_type = real default = $default_sr} sr
if {[string match "Cancel" [string range $sr 0 5]]} {
  puts "Program cancelled by user."
  return
}

# Output a LAS2 file per well for the WIRE set.
foreach well $wells {
  set set_list [log_dbms mode = list well = $well set = _all select = _well]
  if {[lsearch -exact $set_list $id_set] != -1} {
    puts "processing $well..."
    log_dbms mode = query \
         well = $well \
         set = $id_set \
         select = _set._reference _set._all_logs \
    | tp_interpolate \
         sample_rate = $sr \
         sr_units = $units \
         reference = DEPTH \
    | tp_name_translate \
        to_geolog = false \
        name_translation = none \
    | tp_to_las file_out = [ file join [list $directory ${well}.las ] ]
    puts "Output $well.las"
  } {
  puts "set WIRE doesn't exist in $well"
  }
#  file delete -force ./tmp.las
}

puts "Finished exporting wells to $directory."
