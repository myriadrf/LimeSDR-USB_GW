#Copy and Rename .sof file by hardware version 
file copy -force -- output_files/LimeSDR-USB_lms7_trx.sof output_files/LimeSDR-USB_lms7_trx_HW_1.4.sof
qexec "quartus_cpf -c output_files/jic_file_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.4.jic" -submsgs [list "Output file saved in /output_files directory"]
post_message "*******************************************************************"
qexec "quartus_cpf -c output_files/rbf_file_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-USB_lms7_trx_HW_1.4" -submsgs [list "Output file saved in /output_files directory"]
post_message "*******************************************************************"
