::xo::library doc {
  xoOpenAI-specific formfield definitions

  @author Sebastian Scheder
  @creation-date September, 2024
}

::xo::library require -package xowiki form-field-procs

namespace eval ::xowiki::formfield {

  Class create openai_model -superclass select -parameter {}
  openai_model instproc initialize {} {
    if {${:__state} ne "after_specs"} return
    set :options [list {"gpt-3.5" "gpt-3.5"} {"gpt-4.0" "gpt-4.0"}]
    next
    set :__initialized 1
  }

  Class create conversation_item_pretty_link -superclass FormField -parameter {}
  conversation_item_pretty_link instproc pretty_value {value} {
    set locale [[${:object} package_id] default_locale]
    set localized_title [::lang::util::localize [${:object} title] $locale]
    return "<a data-title='$localized_title' href='[${:object} pretty_link]' >$localized_title</a>"
  }
}

::xo::library source_dependent
