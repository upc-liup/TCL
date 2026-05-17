# Define the unit system creat by liup
set un "metric
mixed
imperial
"
if { [catch {mui_select name = id_un\
title= "Select Unit Type"\
message = "Unit System"\
type=single_select\
list= $un\
list_title= "Unit"} id_un ] } {
return
}
#file delete bin/geolog_env.tcl
file mkdir bin
set fd [open bin/geolog_env.tcl w+]
puts $fd "set env(PG_UNIT_SYSTEM) $id_un"
close $fd
puts "Define unit system type successfully!"
mui_dialog title = Finish \
type = inf \
message = Define unit system type successfully! \
ok = OK \
cancel =
