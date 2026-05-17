# Name: batch_export_las_gui_fixed.tcl
# Purpose: 批量导出多口井的LAS文件(GUI版本 - 修复版)
# Author: Based on Geolog TCL standards
# Date: 2024-03-29
# Reference: example2_merging_gui.tcl, lp_swp_mono_process.tcl

# 构建命令字符串
set cmd {
    # 获取单位系统
    if {[info exists env(PG_UNIT_SYSTEM)]} {
        set units_system $env(PG_UNIT_SYSTEM)
    } else {
        set units_system "metric"
    }
    
    # 根据单位系统设置深度单位
    if {$units_system == "metric" | $units_system == "mixed"} {
        set units "METRES"
        set default_sr 0.1524
    } else {
        set units "FEET"
        set default_sr 0.5
    }
    
    # 获取井列表
    set allwells [join [log_list _project well] "\t"]
    
    # 检查当前井
    if {[info exists env(PG_WELL)]} {
        set currentwell $env(PG_WELL)
    } else {
        set currentwell ""
    }
    
    # 初始化变量
    set ::selected_wells ""
    set ::dataset_name "WIRE"
    set ::output_dir "./data/"
    set ::sample_rate $default_sr
    set ::allwells $allwells
    set ::units $units
    
    # 创建GUI窗口
    toplevel .export_las
    
    # 设置窗口标题
    wm title .export_las "批量导出LAS文件"
    
    # 创建frame
    frame .export_las.wells -borderwidth 2
    frame .export_las.dataset -borderwidth 2
    frame .export_las.output -borderwidth 2
    frame .export_las.samplerate -borderwidth 2
    frame .export_las.buttons -borderwidth 2
    
    # 井选择部分
    label .export_las.wells.label -text "选择井"
    pack .export_las.wells.label -side top -anchor w
    
    scrollbar .export_las.wells.scroll -command ".export_las.wells.list yview"
    listbox .export_las.wells.list \
        -selectmode multiple \
        -height 10 \
        -yscrollcommand ".export_las.wells.scroll set" \
        -exportselection yes
    
    pack .export_las.wells.scroll -side right -fill y
    pack .export_las.wells.list -side left -fill both -expand yes
    
    # 数据集输入
    label .export_las.dataset.label -text "数据集名称"
    entry .export_las.dataset.entry \
        -width 20 \
        -relief sunken \
        -textvariable ::dataset_name
    
    pack .export_las.dataset.label -side top -anchor w
    pack .export_las.dataset.entry -side top -pady 5
    
    # 输出目录
    label .export_las.output.label -text "输出目录"
    entry .export_las.output.entry \
        -width 40 \
        -relief sunken \
        -textvariable ::output_dir
    button .export_las.output.browse -text "浏览..." -command ::browse_directory
    
    pack .export_las.output.label -side top -anchor w
    pack .export_las.output.entry -side left -pady 5
    pack .export_las.output.browse -side left -pady 5 -padx 5
    
    # 采样率
    label .export_las.samplerate.label -text "采样率 ($::units)"
    entry .export_las.samplerate.entry \
        -width 10 \
        -relief sunken \
        -textvariable ::sample_rate
    
    pack .export_las.samplerate.label -side top -anchor w
    pack .export_las.samplerate.entry -side top -pady 5
    
    # 按钮
    button .export_las.buttons.selectall -text "全选" -command ::select_all_wells
    button .export_las.buttons.deselectall -text "取消全选" -command ::deselect_all_wells
    button .export_las.buttons.export -text "导出" -bg green -command ::do_export
    button .export_las.buttons.close -text "关闭" -bg steelblue -command {destroy .export_las}
    
    pack .export_las.buttons.selectall -side left -padx 5
    pack .export_las.buttons.deselectall -side left -padx 5
    pack .export_las.buttons.export -side left -padx 5
    pack .export_las.buttons.close -side left -padx 5
    
    # 布局frames
    pack .export_las.wells -side left -padx 10 -pady 10
    pack .export_las.dataset -side top -pady 5
    pack .export_las.output -side top -pady 5
    pack .export_las.samplerate -side top -pady 5
    pack .export_las.buttons -side top -pady 10
    
    # 填充井列表
    foreach well $::allwells {
        .export_las.wells.list insert end $well
    }
    
    # 如果当前井存在,默认选中
    if {$currentwell != ""} {
        set idx [.export_las.wells.list index $currentwell]
        if {$idx >= 0} {
            .export_las.wells.list selection set $idx
        }
    }
}

# 过程: 选择所有井
proc ::select_all_wells {} {
    .export_las.wells.list selection set 0 end
}

# 过程: 取消选择所有井
proc ::deselect_all_wells {} {
    .export_las.wells.list selection clear 0 end
}

# 过程: 浏览目录
proc ::browse_directory {} {
    if {[catch {mui_dialog type = prompt \
        title = "Select Output Directory" \
        message = "Select output directory" \
        default = $::output_dir} new_dir]} {
        return
    }
    if {![string match "Cancel" [string range $new_dir 0 5]]} {
        set ::output_dir $new_dir
    }
}

# 过程: 执行导出
proc ::do_export {} {
    # 获取选中的井
    set selected_indices [.export_las.wells.list curselection]
    if {[llength $selected_indices] == 0} {
        puts stderr "请至少选择一口井!"
        return
    }
    
    set selected_wells ""
    foreach idx $selected_indices {
        set well [.export_las.wells.list get $idx]
        lappend selected_wells $well
    }
    
    puts ""
    puts "========================================="
    puts "   批量导出LAS文件工具"
    puts "========================================="
    puts ""
    puts "数据集: $::dataset_name"
    puts "输出目录: $::output_dir"
    puts "采样率: $::sample_rate $::units"
    puts "已选择 [llength $selected_wells] 口井"
    puts "  井列表: $selected_wells"
    puts ""
    
    puts "========== 开始批量导出 =========="
    
    set success_count 0
    set fail_count 0
    set well_count 0
    
    # 遍历每口井
    foreach well $selected_wells {
        incr well_count
        
        puts ""
        puts "进度: $well_count / [llength $selected_wells]"
        puts "处理井: $well"
        
        # 检查数据集是否存在
        set set_list [log_dbms mode = list well = $well set = _all select = _well]
        
        if {[lsearch -exact $set_list $::dataset_name] != -1} {
            puts "  数据集: $::dataset_name"
            puts "  采样率: $::sample_rate $::units"
            
            # 使用标准管道操作导出LAS文件
            log_dbms mode = query \
                well = $well \
                set = $::dataset_name \
                select = _set._reference _set._all_logs \
            | tp_interpolate \
                sample_rate = $::sample_rate \
                sr_units = $::units \
                reference = DEPTH \
            | tp_name_translate \
                to_geolog = false \
                name_translation = none \
            | tp_to_las file_out = [file join [list $::output_dir ${well}.las]]
            
            puts "  成功: 已导出到 [file join [list $::output_dir ${well}.las]]"
            incr success_count
        } else {
            puts "  错误: 数据集 '$::dataset_name' 不存在"
            puts "  跳过: $well"
            incr fail_count
        }
    }
    
    puts ""
    puts "========== 批量导出完成 =========="
    puts "总井数: [llength $selected_wells]"
    puts "成功: $success_count"
    puts "失败: $fail_count"
    puts "输出目录: $::output_dir"
    puts "采样率: $::sample_rate $::units"
    puts "数据集: $::dataset_name"
    puts ""
}

# 发送命令到Well应用
set wapp [min_connect well]
if {$wapp != ""} {
    catch [list min_send $wapp $cmd] msg
    if {$msg != ""} {
        puts $msg
    }
} else {
    puts "无法连接到Well应用"
}
