qexec "quartus_cpf -c output_files/jic_file_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-USB_lms7_trx.jic" -submsgs [list "Ouput file saved in /output_files directory"]
post_message "*******************************************************************"
qexec "quartus_cpf -c output_files/rbf_file_setup.cof"
post_message "*******************************************************************"
post_message "Generated programming file: LimeSDR-USB_lms7_trx.rbf" -submsgs [list "Ouput file saved in /output_files directory"]
post_message "*******************************************************************"