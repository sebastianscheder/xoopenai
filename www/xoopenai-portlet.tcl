ad_include_contract {
    xoOpenAI Portlet implementation

    @author Sebastian Scheder
    @creation-date September, 2024
}

if {![ns_conn isconnected]} {
    return
}

set user_id [::xo::cc set user_id]
array set config $cf

#
# Do not continue if the portlet is shaded
#
set shaded_p $config(shaded_p)
if {$shaded_p} {
    return
}

set package_id [expr {[info exists config(package_id)]
                      ? $config(package_id)
                      : ""}]

#
# if we do not get the proper package_id from the instance
# mounted in the community, it is pointless to continue
#
if {$package_id eq ""} {
  return
}

#
# hint: if we are in /dotlrn, community_id = 0
#
set community_id [dotlrn_community::get_community_id]

#
# initialize package
#
::xowf::Package initialize -package_id $package_id

#
# placeholders
#
set content ""
set wf_instances {}

#
# Create a list of form usages for conversation workflows.
#
set folder_form_id  [$package_id instantiate_forms -forms en:folder.form]
set wf_form_id      [$package_id instantiate_forms -forms en:conversation.wf]
set folder_pages    [::xowiki::FormPage get_form_entries \
                        -base_item_ids $folder_form_id \
                        -form_fields "" \
                        -publish_status ready \
                        -parent_id [$package_id set folder_id] \
                        -package_id $package_id]

if {[llength [$folder_pages children]] > 0} {
  append content "<hr><p>Threads</p>"

  foreach f [$folder_pages children] {
      set items [::xowiki::FormPage get_form_entries \
                      -base_item_ids $wf_form_id \
                      -form_fields "" \
                      -parent_id [$f item_id] \
                      -package_id $package_id]

      if {[llength [$items children]] > 0} {
          append content "<ul>"
          foreach c [$items children] {
              set item_url [::xowiki::Package get_url_from_id -item_id [$c set item_id]]
              append content "<li><a href='$item_url'>[$c set title]</a></li>"
          }
          append content "</ul>"
      } else {
          append content "<p>#xoopenai.no_threads#</p>"
      }
  }
  append content "<hr>"
}

append content "<a href='[ad_conn package_url]xoopenai'>#xoopenai.pretty_name#</a></p>"

ad_return_template

