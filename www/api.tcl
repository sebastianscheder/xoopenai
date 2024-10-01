ad_page_contract {
    Internal API

    @author Sebastian Scheder
    @creation-date October, 2024
} -query {
    m:oneof(completions)
    id:integer
    pid:integer
    {content ""}
}

#
# Web-callable API to be used by the chatgpt includelet
# on basic xowiki Pages.
#

#
# Require at least read permissions on the page
#
::permission::require_permission -object_id $id -privilege "read"

::xoopenai::ConversationManager create CM -package_id $pid

switch -- $m {
    completions {
        CM www-$m
    }
}

CM destroy

ad_script_abort
