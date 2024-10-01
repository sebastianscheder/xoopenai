ad_library {
  APM Callback procs

  @author Sebastian Scheder
  @creation-date September, 2024
}

::xo::library require -package xowiki xowiki-callback-procs

namespace eval ::xoopenai::apm {}
namespace eval ::xoopenai::install {}

ad_proc -private ::xoopenai::apm::before_install {} {
    setup xoOpenAI
} {
    # noop
}

ad_proc -private ::xoopenai::apm::after_install {} {
    Install the xoOpenAI DotLRN applet
} {
    ::xoopenai_applet after-install
}

ad_proc -private ::xoopenai::apm::before_uninstall {} {
    Uninstall the xoOpenAI DotLRN applet
} {
    ::xoopenai_applet before-uninstall
}

ad_proc -private ::xoopenai::apm::after_mount {
    {-package_id:required}
    {-node_id:required}
} {
    ::xoopenai::manager create_objects -package_id $package_id -node_id $node_id
}

ad_proc -private ::xoopenai::apm::after_instantiate {
    {-package_id:required}
} {
    some desciption
} {
    # but nothing to do
}

ad_proc -private ::xoopenai::apm::before_uninstantiate {
    {-package_id:required}
} {
    Description
} {
    ::xowiki::before-uninstantiate -package_id $package_id
}

