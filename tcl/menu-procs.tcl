::xo::library doc {
  Menu procs - custom menu implementations

  @author Sebastian Scheder
  @creation-date September, 2024
}

::xo::library require -package xowf   xowf-procs
::xo::library require -package xowiki menu-procs
::xo::library require -package xowiki form-field-procs

namespace eval ::xowiki {
  ::xowiki::MenuBar instproc config=xoopenai-items {
    {-bind_vars {}}
    -current_page:required
    -package_id:required
    -folder_link:required
    -return_url
  } {
    :config=default \
        -bind_vars $bind_vars \
        -current_page $current_page \
        -package_id $package_id \
        -folder_link $folder_link \
        -return_url $return_url

    return {
      {entry -name New.Item.Thread -form en:conversation.wf -label #xoopenai.thread#}
    }
  }
}

::xo::library source_dependent
