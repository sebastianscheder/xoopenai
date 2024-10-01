::xo::library doc {
  Conversation Management Component

  The aim of this component is to provide a comprehensive API
  for management of conversation threads with OpenAI models, e.g.,
  handling of responses from the REST interface, among others.

  @author Sebastian Scheder
  @creation-date September, 2024
}

namespace eval ::xoopenai {
  ###########################################################
  #
  # xoopenai::ConversationManager
  #
  ###########################################################

  nx::Class create ConversationManager {

    :property {package_id}

    :public method www-completions {} {
      #
      # Require json::write package for conversions to JSON
      #
      package require json::write

      #
      # Retrieve message text from the content query param
      #
      set content [ns_queryget content]

      #
      # Instantiate a new interface and call OpenAI endpoints
      #
      set client_id     [parameter::get \
                            -package_id ${:package_id} \
                            -parameter openai_org_id]
      set client_secret [parameter::get \
                            -package_id ${:package_id} \
                            -parameter openai_api_key]
      set project_id    [parameter::get \
                            -package_id ${:package_id} \
                            -parameter openai_project_id]

      set o [::xoopenai::REST new \
                -client_id $client_id \
                -client_secret $client_secret \
                -project_id $project_id]

      set r [$o chat -max_tokens 100 -content $content]

      #
      # Convert the result into a JSON structure and return it
      #
      set res [::json::write object {*}[dict map {k v} $r {set v [json::write string $v]}]]
      ns_return 200 application/json $res
      ad_script_abort
    }
  }

}

::xo::library source_dependent

