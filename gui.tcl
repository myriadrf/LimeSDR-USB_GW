 
# Create a standard Yes/No message box dialog passing in the 
# dialog title and text.
proc CreateDialog {title text} {
   tk_messageBox \
      -type yesno \
      -title $title \
      -default yes \
      -message $text \
      -icon question
}
 
# Do this when user clicks Yes
proc Yes {} {
   post_message -type info "*******************************************************************"
   post_message -type info "User request to update project revision"
   source "update_rev.tcl"
   post_message -type info "*******************************************************************"



}
 
# Do this when user clicks No
proc No {} {
   post_message -type warning "*******************************************************************"
   post_message -type warning "Project revision was not updated."
   post_message -type warning "*******************************************************************"
}
 
#################
# Program Start #
#################
init_tk
set dialogTitle "Project revision update"
set dialogText "Update project revision?"
 
if {[CreateDialog $dialogTitle $dialogText] == yes} {
   Yes
} else {
   No
}