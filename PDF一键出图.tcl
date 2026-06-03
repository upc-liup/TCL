set listofwells  [log_list _project process_wells]
puts "List of wells is $listofwells"
foreach well $listofwells {
    puts "Well is $well"
  value_set parent = SIDEBAR_WELLS name = WELL_NAMES value = $well
file_print commands = {
  value_set parent = GEOLOG_PRINT_DIALOG name = PRINTDLG_DEVICE_LIST value = "File: Adobe PDF (Western European)"
  value_set parent = GEOLOG_PRINT_DIALOG name = PRINT action = activate
#  value_set parent = MESSAGE name = SCALE action = activate
}
}