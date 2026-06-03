# Name: batch_export_las_gui_progress.tcl
# Purpose: 批量导出多口井的LAS文件(GUI版本 - 带进度条)
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
    set ::export_running 0
    set ::export_cancelled 0
    
    # 创建GUI窗口
    toplevel .export_las
    
    # 设置窗口标题
    wm title .export_las "批量导出LAS文件(Liu.Peng-2026)"
    
    # 创建frame
    frame .export_las.wells -borderwidth 2
    frame .export_las.dataset -borderwidth 2
    frame .export_las.output -borderwidth 2
    frame .export_las.samplerate -borderwidth 2
    frame .export_las.buttons -borderwidth 2
    frame .export_las.progress -borderwidth 2
    
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
    
    # 进度条区域
    label .export_las.progress.label -text "处理进度:"
    pack .export_las.progress.label -side top -anchor w
    
    # 进度条
    frame .export_las.progress.bar_frame -relief sunken -borderwidth 2
    canvas .export_las.progress.bar -width 400 -height 20 -bg white
    pack .export_las.progress.bar -padx 2 -pady 2
    
    # 进度信息标签
    label .export_las.progress.info -text "准备就绪"
    pack .export_las.progress.info -side top -anchor w -pady 5
    
    # 状态统计
    label .export_las.progress.stats -text "成功: 0 | 失败: 0 | 总数: 0"
    pack .export_las.progress.stats -side top -anchor w
    
    pack .export_las.progress.bar_frame
    pack .export_las.progress
    
    # 按钮
    button .export_las.buttons.selectall -text "全选" -command ::select_all_wells
    button .export_las.buttons.deselectall -text "取消全选" -command ::deselect_all_wells
    button .export_las.buttons.export -text "导出" -bg green -command ::do_export
    button .export_las.buttons.cancel -text "取消" -bg orange -command ::cancel_export -state disabled
    button .export_las.buttons.close -text "关闭" -bg steelblue -command {destroy .export_las}
    
    pack .export_las.buttons.selectall -side left -padx 5
    pack .export_las.buttons.deselectall -side left -padx 5
    pack .export_las.buttons.export -side left -padx 5
    pack .export_las.buttons.cancel -side left -padx 5
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

# 过程: 更新进度条
proc ::update_progress {current total message} {
    set percent [expr {double($current) * 100.0 / double($total)}]
    set formatted_percent [format "%.1f" $percent]
    
    # 计算进度条宽度 (最大400像素)
    set bar_width [expr {int(400.0 * $percent / 100.0)}]
    
    # 清除画布
    .export_las.progress.bar delete all
    
    # 绘制进度条背景
    .export_las.progress.bar create rectangle 0 0 400 20 -fill #e0e0e0 -outline ""
    
    # 绘制进度条前景
    if {$bar_width > 0} {
        # 根据进度选择颜色
        if {$percent < 30.0} {
            set bar_color "#4CAF50"  ;# 绿色
        } elseif {$percent < 70.0} {
            set bar_color "#FFC107"  ;# 黄色
        } else {
            set bar_color "#2196F3"  ;# 蓝色
        }
        .export_las.progress.bar create rectangle 0 0 $bar_width 20 -fill $bar_color -outline ""
    }
    
    # 绘制百分比文字
    set text_color "black"
    if {$percent > 50.0} {
        set text_color "white"
    }
    .export_las.progress.bar create text 200 10 -text "${formatted_percent}%" -fill $text_color -font {Arial 10 bold}
    
    # 更新信息标签
    .export_las.progress.info configure -text "$message"
    
    # 刷新界面
    update
}

# 过程: 更新统计信息
proc ::update_stats {success fail total} {
    .export_las.progress.stats configure -text "成功: $success | 失败: $fail | 总数: $total"
    update
}

# 过程: 取消导出
proc ::cancel_export {} {
    set ::export_cancelled 1
    .export_las.progress.info configure -text "正在取消..."
    update
}

# 过程: 执行导出
proc ::do_export {} {
    # 检查是否正在运行
    if {$::export_running} {
        puts "导出正在进行中,请稍候..."
        return
    }
    
    # 获取选中的井
    set selected_indices [.export_las.wells.list curselection]
    if {[llength $selected_indices] == 0} {
        mui_dialog type = error \
            title = "错误" \
            message = "请至少选择一口井!"
        return
    }
    
    # 禁用导出按钮,启用取消按钮
    .export_las.buttons.export configure -state disabled
    .export_las.buttons.cancel configure -state normal
    set ::export_running 1
    set ::export_cancelled 0
    
    set selected_wells ""
    foreach idx $selected_indices {
        set well [.export_las.wells.list get $idx]
        lappend selected_wells $well
    }
    
    set total_wells [llength $selected_wells]
    
    # 初始化统计
    set success_count 0
    set fail_count 0
    set well_count 0
    
    # 显示开始信息
    puts ""
    puts "========================================="
    puts "   批量导出LAS文件工具"
    puts "========================================="
    puts "数据集: $::dataset_name"
    puts "输出目录: $::output_dir"
    puts "采样率: $::sample_rate $::units"
    puts "已选择 $total_wells 口井"
    puts "井列表: $selected_wells"
    puts ""
    
    # 初始化进度条
    update_progress 0 $total_wells "准备开始导出..."
    update_stats 0 0 $total_wells
    
    # 遍历每口井
    foreach well $selected_wells {
        # 检查是否取消
        if {$::export_cancelled} {
            puts ""
            puts "导出已被用户取消"
            update_progress $well_count $total_wells "导出已取消"
            break
        }
        
        incr well_count
        
        # 更新进度条
        update_progress $well_count $total_wells "正在处理: $well ($well_count/$total_wells)"
        update_stats $success_count $fail_count $total_wells
        
        puts ""
        puts "进度: $well_count / $total_wells"
        puts "处理井: $well"
        
        # 检查数据集是否存在
        set set_list [log_dbms mode = list well = $well set = _all select = _well]
        
        if {[lsearch -exact $set_list $::dataset_name] != -1} {
            puts "  数据集: $::dataset_name"
            puts "  采样率: $::sample_rate $::units"
            
            # 使用标准管道操作导出LAS文件
            if {[catch {
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
            } error_msg]} {
                puts "  错误: $error_msg"
                incr fail_count
            } else {
                puts "  成功: 已导出到 [file join [list $::output_dir ${well}.las]]"
                incr success_count
            }
        } else {
            puts "  错误: 数据集 '$::dataset_name' 不存在"
            puts "  跳过: $well"
            incr fail_count
        }
        
        # 更新统计信息
        update_stats $success_count $fail_count $total_wells
    }
    
    # 导出完成
    set ::export_running 0
    .export_las.buttons.export configure -state normal
    .export_las.buttons.cancel configure -state disabled
    
    # 显示完成信息
    if {$::export_cancelled} {
        puts ""
        puts "========== 导出已取消 =========="
        puts "已处理: $well_count / $total_wells"
        puts "成功: $success_count"
        puts "失败: $fail_count"
        
        update_progress $well_count $total_wells "导出已取消: $well_count/$total_wells 口井"
    } else {
        puts ""
        puts "========== 批量导出完成 =========="
        puts "总井数: $total_wells"
        puts "成功: $success_count"
        puts "失败: $fail_count"
        puts "输出目录: $::output_dir"
        puts "采样率: $::sample_rate $::units"
        puts "数据集: $::dataset_name"
        puts ""
        
        # 进度条显示为100%
        update_progress $total_wells $total_wells "导出完成! 成功: $success_count, 失败: $fail_count"
    }
    
    update_stats $success_count $fail_count $total_wells
    
    # 显示完成对话框
    if {!$::export_cancelled} {
        if {$fail_count == 0} {
            mui_dialog type = info \
                title = "导出完成" \
                message = "批量导出完成!\n\n总井数: $total_wells\n成功: $success_count\n失败: $fail_count\n\n输出目录: $::output_dir"
        } else {
            mui_dialog type = warning \
                title = "导出完成(有失败)" \
                message = "批量导出完成,但有部分失败!\n\n总井数: $total_wells\n成功: $success_count\n失败: $fail_count\n\n请查看输出信息了解详情。"
        }
    }
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
