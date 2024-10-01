ad_library {
    Supports xoOpenAI as a DotLRN applet

    @author Sebastian Scheder
    @creation-date September, 2024
}

Object create ::xoopenai_applet

::xoopenai_applet proc applet_key {} {
    return "dotlrn_xoopenai"
}

::xoopenai_applet proc my_package_key {} {
    return "xoopenai"
}

::xoopenai_applet proc package_key {} {
    return "xoopenai"
}

::xoopenai_applet proc node_name {} {
    return "xoopenai"
}

::xoopenai_applet proc pretty_name {} {
    return "OpenAI Applet"
}

::xoopenai_applet proc pkg_pretty_name {} {
    return "#xoopenai.pretty_name#"
}

::xoopenai_applet proc add_applet {} {
    dotlrn_applet::add_applet_to_dotlrn \
        -applet_key [:applet_key] \
        -package_key [:my_package_key]

}

::xoopenai_applet proc add_applet_to_community {
    community_id
} {
    set applet_id [dotlrn_applet::get_applet_id_from_key -applet_key [:applet_key]]
    set portal_id [dotlrn_community::get_portal_id -community_id $community_id]
    set package_id [dotlrn::instantiate_and_mount $community_id [:package_key]]
    ::xoopenai_portlet add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
        -param_action append

    return $package_id
}

::xoopenai_applet proc remove_applet_from_community {
    community_id
} {
    set package_id [dotlrn_community::get_applet_package_id \
                      -community_id $community_id \
                      -applet_key [:applet_key]]
    # unmount and delete site_node
    dotlrn::unmount_package -package_id $package_id
}

::xoopenai_applet proc add_user {
  user_id
} {
    #noop
}

::xoopenai_applet proc remove_user {} {
    ns_log warning "remove_user not implemented"
    return
}

::xoopenai_applet proc add_user_to_community {
    community_id
    user_id
} {
    set package_id [dotlrn_community::get_applet_package_id \
                        -community_id $community_id \
                        -applet_key [:applet_key]]

    set portal_id [dotlrn::get_portal_id -user_id $user_id]

    ::xoopenai_portlet add_self_to_page \
        -portal_id $portal_id \
        -package_id $package_id \
        -param_action append

}

::xoopenai_applet ad_proc remove_user_from_community {
    community_id
    user_id
} {
    Remove a user from a community
} {
    #noop
}

::xoopenai_applet proc add_portlet {} {
    # nothing happens here
}

::xoopenai_applet ad_proc add_portlet_helper {
    portal_id
    args
} {
    Some description
} {
    # noop
}

::xoopenai_applet ad_proc remove_portlet {
    portal_id
    args
} {
    #noop here
} {
    # noop
}

::xoopenai_applet ad_proc -private clone {
    old_community_id
    new_community_id
} {
    #noop
} {
    # noop
}

::xoopenai_applet ad_proc change_event_handler {
    community_id
    event
    old_value
    new_value
} {
    Listen for events.
} {
    # noop
}

::xoopenai_applet proc install {} {
    set name [:applet_key]
    db_transaction {
      ::xo::db::sql::acs_sc_impl new \
        -impl_contract_name "dotlrn_applet" -impl_name $name \
        -impl_pretty_name "" -impl_owner_name $name

    foreach {operation call} {
      GetPrettyName "::xoopenai_applet pretty_name"
      AddApplet "::xoopenai_applet add_applet"
      RemoveApplet "::xoopenai_applet remove_applet"
      AddAppletToCommunity "::xoopenai_applet add_applet_to_community"
      RemoveAppletFromCommunity "::xoopenai_applet remove_applet_from_community"
      AddUser "::xoopenai_applet add_user"
      RemoveUser "::xoopenai_applet remove_user"
      AddUserToCommunity "::xoopenai_applet add_user_to_community"
      RemoveUserFromCommunity "::xoopenai_applet remove_user_from_community"
      AddPortlet "::xoopenai_applet add_portlet"
      RemovePortlet "::xoopenai_applet remove_portlet"
      Clone "::xoopenai_applet clone"
      ChangeEventHandler "::xoopenai_applet change_event_handler"
    } {
      ::xo::db::sql::acs_sc_impl_alias new \
          -impl_contract_name "dotlrn_applet" -impl_name $name \
          -impl_operation_name $operation -impl_alias $call \
          -impl_pl "TCL"
    }

    ::xo::db::sql::acs_sc_binding new \
        -contract_name "dotlrn_applet" -impl_name $name
    }

    #
    # Portlet install
    #
    ::xoopenai_portlet install
}

::xoopenai_applet proc uninstall {} {
    set name [:applet_key]
    db_transaction {
        foreach operation {
            GetPrettyName
            AddApplet
            RemoveApplet
            AddAppletToCommunity
            RemoveAppletFromCommunity
            AddUser
            RemoveUser
            AddPortlet
            RemovePortlet
            Clone
            ChangeEventHandler
            AddUserToCommunity
            RemoveUserFromCommunity
        } {
            ::xo::db::sql::acs_sc_impl_alias delete \
                -impl_contract_name "dotlrn_applet" -impl_name $name \
                -impl_operation_name $operation
        }

        ::xo::db::sql::acs_sc_binding delete \
            -contract_name "dotlrn_applet" -impl_name $name

        ::xo::db::sql::acs_sc_impl delete \
            -contract_name "dotlrn_applet" -impl_name $name

        #
        # Portlet uninstall
        #
        ::xoopenai_portlet uninstall
    }
}

::xoopenai_applet proc after-install {} {
    ::xoopenai_applet install
}

::xoopenai_applet proc before-uninstall {} {
    ::xo::dc db_dml delete_xoopenai_applet "delete from dotlrn_applets where applet_key ='[:applet_key]' and '[:package_key]'"
    ::xoopenai_applet uninstall
}

