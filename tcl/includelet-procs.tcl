::xo::library doc {
  Includelet procs

  @author Sebastian Scheder
  @creation-date September, 2024
}

namespace eval ::xowiki::includelet {

  Class create chatgpt \
    -superclass ::xowiki::Includelet \
    -parameter {
      {__decoration plain}
    } -ad_doc {
      Interface includelet for ChatGPT
    }

  chatgpt instproc render {} {
    :get_parameters
    #
    # In the Conversation workflow, we already add the ConversationManager mixin.
    # If this is not presen at this point, we imply the includelet is being used
    # in a 'plain' ::xowiki::Page and we target a separate internal API.
    #
    set endpoint_url [${:__including_page} pretty_link -query m=completions]

    if {[${:__including_page} info mixin] eq ""} {
      set package_id ${:package_id}
      #
      # Check if we are in a xoOpenAI instance, or somewhere else, e.g., in XoWiki
      #
      if {[$package_id package_key] ne "xoopenai"} {
        set package_id [acs_admin::require_site_wide_package -package_key xoopenai]
        ::xo::Package initialize -package_id $package_id
      }
      set base_url [$package_id package_url]
      set endpoint_url ${base_url}api?m=completions&id=[${:__including_page} item_id]&pid=$package_id
    }

    #
    # add required css and javascript
    #
    template::head::add_css -href /resources/xowiki/chat-skins/chat-bubbles.css
    template::head::add_css -href /resources/xoopenai/css/openai.css
    template::head::add_javascript -src /resources/xowiki/chat-skins/chat-bubbles.js
    template::head::add_javascript -src /resources/xoopenai/openai.js -order 30

    #
    # placeholders
    #
    set html ""
    set js ""

    #
    # define the markup to be returned for the user interface
    #
    set message_label [_ xowiki.chat_message]
    set send_label [_ xowiki.chat_Send_Refresh]

    append html [subst {
      <div id='xowiki-chat'>
        <div id='xowiki-chat-messages-and-form'>
          <div id='xowiki-chat-messages'></div>
          <div id='xowiki-chat-messages-form-block'>
            <div id='xowiki-chat-messages-form' action='#'>
              <input type='text' placeholder="$message_label" id='xowiki-chat-send' autocomplete="off" />
              <button id='xowiki-chat-send-button'>$send_label</button>
            </div>
          </div>
        </div>
      </div>
    }]

    #
    # append:
    # (a) full-screen functionality
    # (b) 'beautified' send button
    #
    append js {addFullScreenLink();}
    append js {addSendPic();}
    append js [subst {
        initialize("$endpoint_url");}]
    append html [subst {
      <script nonce="[security::csp::nonce]">
        $js
      </script>
    }]
    return $html
  }

  ::xowiki::IncludeletClass create openai-toc \
    -superclass ::xowiki::Includelet \
    -parameter {
      {__decoration plain}
      {parameter_declaration {
        {-minimal:boolean false}
      }
    }} -ad_doc {
      Toc view for conversation workflow instances
    }

  openai-toc instproc render {} {
    :get_parameters
    set page ${:__including_page}
    set package_id [$page package_id]
    set parent [expr {[$page is_folder_page] ? [$page item_id] : [$page parent_id]}]
    set field_names "custom_title,_state,_last_modified,_state,_creation_user"
    set buttons "delete"
    set extra_form_constraints custom_title:conversation_item_pretty_link,label=#xowiki.title#
    set forms [$package_id instantiate_forms \
      -parent_id $parent \
      -default_lang [$page lang] \
      -forms en:conversation.wf]

    #
    # minimal is a view setting, which is used e.g.,
    # in the conversation workflow for the side menu.
    #
    if {$minimal} {
      set field_names "custom_title"
      set buttons ""
    }

    return [$page include [list form-usages \
                               -csv false \
                               -parent_id $parent \
                               -form_item_id $forms \
                               -field_names $field_names \
                               -date_format pretty-age \
                               -buttons $buttons \
                               -bulk_actions {} \
                               -extra_form_constraints $extra_form_constraints \
                               -with_form_link false]]
  }
}

