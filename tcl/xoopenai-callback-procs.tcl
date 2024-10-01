ad_library {
  xoOpenAI callback procs

  @author Sebastian Scheder
  @creation-date September, 2024
}

namespace eval ::xoopenai {}

ad_proc -public ::xoopenai::add_applet_to_community {
    -applet_key:required
    -community_id:required
} {
    dotlrn_community::add_applet_to_community $community_id $applet_key
    set portal_id [dotlrn_community::get_portal_id -community_id $community_id]
    return [dotlrn_community::get_applet_package_id \
              -community_id $community_id \
              -applet_key $applet_key]
}

namespace eval ::xoopenai::callback {}

ad_proc -public -callback ::xoopenai::callback::instantiate {
    -package_id
} {
    Run when package is instantiated
} -

ad_proc -public -callback ::xoopenai::callback::after_mount {
  -package_id
  -node_id
} {
  Used to run specific code when the package is already mounted
} -

::xotcl::Object create ::xoopenai::manager

::xoopenai::manager ad_proc create_objects {
  {-package_id}
  {-node_id}
} {
  create needed pages
} {
  set node [site_node::get_from_node_id -node_id $node_id]
  set node_name [dict get $node url]
  ::xowiki::Package initialize -url $node_name

  #
  # do not create the objects in the site-wide instance
  #
  if {[$package_id package_url] eq "/acs-admin/site-wide/xoopenai/"} {
    return
  }

  #
  # Remembering the 'early days' of xoOpenAI, I leave the following code
  # as a comment. It started out with the idea of a simple xowiki page,
  # where an includelet was supposed to be rendered. This was basically
  # what was presented at the OpenACS conference 2024 at WU Vienna, long
  # before the conversation workflow was introduced.
  #
  # Create GPT page on package-mount
  #
  #::$package_id folder_id
  #set gpt_page [::xowiki::Page new \
  #  -parent_id [::$package_id folder_id] \
  #  -package_id $package_id \
  #  -title "ChatGPT" \
  #  -name "en:chatgpt" \
  #  -text { {{{chatgpt}}} text/enhanced }]
  #$gpt_page save_new

  #
  # Create parameter page
  #
  set root_folder_id [$package_id set folder_id]
  set root_folder [::xo::db::CrClass get_instance_from_db -item_id $root_folder_id]
  $root_folder set_property -new 1 extra_menu_entries "{config -use xoopenai-items}"
  $root_folder save

  #
  # require site-wide pages, else parameter_form_id = 0 and package cannot be mounted
  #
  ::xoopenai::Package require_site_wide_pages -refetch_if_modified true
  set parameter_form_id [$package_id lookup -use_site_wide_pages true -name "en:parameter.form"]

  set pp [::xowiki::FormPage new -noinit]
  $pp set object_type ::xowiki::FormPage
  $pp set page_template $parameter_form_id
  $pp set do_substitutions 1
  $pp set instance_attributes {
    use_hstore t
    production_mode f
    top_includelet none
    with_user_tracking f
    with_digg f
    with_general_comments f
    tidy f
    show_per_object_categories f
    with_tags f
    allow_comments f
    with_delicious f
    extra_css {}
    with_notifications f
    root_folder {}
    security_policy ::xowiki::policy1
    latest_p f
    index_page {xoopenai-index}
    MenuBar t
    MenuBarWithFolder f
    MenuBarSymLinks t
    ExtraMenuEntries {{config -use xoopenai-items}}
  }
  $pp set render_adp 1
  $pp set text {}
  $pp set absolute_links 0
  $pp set package_id $package_id
  $pp set nls_language en_US
  $pp set name en:parameter_page1
  $pp set publish_status production
  $pp set parent_id $root_folder_id

  parameter::set_value \
    -package_id $package_id \
    -parameter parameter_page \
    -value "en:parameter_page1"

  $pp save_new

  #
  # Create 'Threads' Folder
  #
  set parameter_form_id [$package_id lookup -use_site_wide_pages true -name "en:folder.form"]
  set cf [::xowiki::FormPage new -noinit]
  $cf set object_type ::xowiki::Page
  $cf set page_template $parameter_form_id
  $cf set do_substitutions 1
  $cf set instance_attributes {extra_menu_entries "{config -use xoopenai-items}"}
  $cf set render_adp 1
  $cf set text ""
  $cf set description "<p>{{openai-toc}}</p>"
  $cf set absolute_links 0
  $cf set package_id $package_id
  $cf set nls_language en_US
  $cf set name threads
  $cf set title "Threads"
  $cf set publish_status ready
  $cf set parent_id $root_folder_id

  $cf save_new
}

::xo::library source_dependent
