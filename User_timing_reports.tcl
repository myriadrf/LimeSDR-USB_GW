reset_design
read_sdc
report_timing -from_clock { LMS_LAUNCH_CLK } -to_clock { LMS_LATCH_CLK } -setup -npaths 10 -detail full_path -panel_name {Report Timing}