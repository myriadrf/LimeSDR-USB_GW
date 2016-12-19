#Copy and Rename .sof file by hardware version (Same file for all versions)
file copy -force -- output_files/LimeSDR-USB_lms7_trx.sof output_files/LimeSDR-USB_lms7_trx_HW_1.0.sof
file copy -force -- output_files/LimeSDR-USB_lms7_trx.sof output_files/LimeSDR-USB_lms7_trx_HW_1.1.sof
file copy -force -- output_files/LimeSDR-USB_lms7_trx.sof output_files/LimeSDR-USB_lms7_trx_HW_1.2.sof
file copy -force -- output_files/LimeSDR-USB_lms7_trx.sof output_files/LimeSDR-USB_lms7_trx_HW_1.3.sof
#Generate .jic file
qexec "quartus_cpf -c output_files/jic_file_setup.cof"
#Copy and Rename .jic file by hardware version (Same file for all versions)
file copy -force -- output_files/LimeSDR-USB_lms7_trx_HW_1.0.jic output_files/LimeSDR-USB_lms7_trx_HW_1.1.jic
file copy -force -- output_files/LimeSDR-USB_lms7_trx_HW_1.0.jic output_files/LimeSDR-USB_lms7_trx_HW_1.2.jic
file copy -force -- output_files/LimeSDR-USB_lms7_trx_HW_1.0.jic output_files/LimeSDR-USB_lms7_trx_HW_1.3.jic
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.0.jic" -submsgs [list "Output file saved in /output_files directory"]
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.1.jic" -submsgs [list "Output file saved in /output_files directory"]
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.2.jic" -submsgs [list "Output file saved in /output_files directory"]
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.3.jic" -submsgs [list "Output file saved in /output_files directory"]
post_message "*******************************************************************"
#Generate .jic file
qexec "quartus_cpf -c output_files/rbf_file_setup.cof"
#Copy and Rename .rbf file by hardware version (Same file for all versions)
file copy -force -- output_files/LimeSDR-USB_lms7_trx_HW_1.0.rbf output_files/LimeSDR-USB_lms7_trx_HW_1.1.rbf
file copy -force -- output_files/LimeSDR-USB_lms7_trx_HW_1.0.rbf output_files/LimeSDR-USB_lms7_trx_HW_1.2.rbf
file copy -force -- output_files/LimeSDR-USB_lms7_trx_HW_1.0.rbf output_files/LimeSDR-USB_lms7_trx_HW_1.3.rbf
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.0.rbf" -submsgs [list "Output file saved in /output_files directory"]
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.1.rbf" -submsgs [list "Output file saved in /output_files directory"]
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.2.rbf" -submsgs [list "Output file saved in /output_files directory"]
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.3.rbf" -submsgs [list "Output file saved in /output_files directory"]
post_message "*******************************************************************"
