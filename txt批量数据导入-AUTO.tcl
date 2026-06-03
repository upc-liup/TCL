# Get files format
catch {mui_dialog type = prompt title = Files message = 数据格式后缀 default = txt} hz
if {[string match "Cancel" [string range $hz 0 5]]} {
  puts "Program cancelled by user."
  return
}
#set hosts [glob -directory "DATA" -- "*.txt"] 
set hosts [glob -directory ./data/ -- "*.${hz}"] 
foreach host $hosts { 
value_set parent = APP_MDI_DOC_MANAGER name = LOAD_FILE action = activate commands = {
  value_set parent = FILE_SELECTOR name = SELECTION value = $host action = OK
}
value_set parent = APP_MDI_DOC_MANAGER name = IMPORT_DATA action = activate commands = {
  value_set parent = WELL_SELECT name = OK action = activate
}
} 
