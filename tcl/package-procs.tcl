::xo::library doc {
  xoOpenAI - package-related procs

  @author Sebastian Scheder
  @creation-date August, 2024
}

::xo::library require -package xowf xowf-procs
::xo::library require -package xotcl-core 06-package-procs

namespace eval ::xoopenai {
  ::xo::PackageMgr create ::xoopenai::Package \
    -package_key "xoopenai" \
    -pretty_name "#xoopenai.pretty_name#" \
    -superclass ::xowf::Package

  ::xoopenai::Package instproc initialize {} {
    next
  }

  ::xoopenai::Package instproc destroy {} {
    next
  }

  ::xoopenai::Package site_wide_pages {
    parameter.form
    conversation.form
    conversation.wf
  }
}

::xo::library source_dependent
