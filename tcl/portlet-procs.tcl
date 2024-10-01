ad_library {
    DotLRN portlet for xoOpenAI

    @author Sebastian Scheder
    @creation-date September, 2024
}

Object create ::xoopenai_portlet

::xoopenai_portlet proc name {} {
    return "xoopenai_portlet"
}

::xoopenai_portlet proc pretty_name {} {
    return "#xoopenai.pretty_name#"
}

::xoopenai_portlet proc link {} {
    return ""
}


::xoopenai_portlet proc add_self_to_page {
    {-portal_id:required}
    {-package_id:required}
    {-param_action:required}
} {
    return [portal::add_element_parameters \
                -portal_id $portal_id \
                -portlet_name [:name] \
                -value $package_id \
                -pretty_name [:pretty_name] \
                -param_action $param_action]
}

::xoopenai_portlet proc remove_self_from_page {
    {-portal_id:required}
    {-package_id:required}
} {
    portal::remove_element_parameters \
        -portal_id $portal_id \
        -portlet_name [:name] \
        -key package_id \
        -value $package_id
}

::xoopenai_portlet proc show {cf} {
    portal::show_proc_helper \
        -package_key "xoopenai" \
        -template_src "xoopenai-portlet" \
        -config_list $cf

}

::xoopenai_portlet proc install {} {
    set name [:name]
    ::xo::dc transaction {
        set ds_id [portal::datasource::new -name $name -description "Displays xoOpenAI portlet page"]

        #
        # Default configuration
        #
        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p t \
            -key "shadeable_p" -value t

        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p t \
            -key "shaded_p" -value f

        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p t \
            -key "hideable_p" -value t

        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p t \
            -key "hide_p" -value t

        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p t \
            -key "user_editable_p" -value f

        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p t \
            -key "link_hideable_p" -value t

        #
        # Custom configuration
        #
        ::xo::db::sql::portal_datasource set_def_param -datasource_id $ds_id \
            -config_required_p t -configured_p f \
            -key "package_id" -value ""

        #
        # Service Contract
        #
        # 1. Create implementation
        #
        ::xo::db::sql::acs_sc_impl new \
            -impl_contract_name "portal_datasource" -impl_name $name \
            -impl_pretty_name "" -impl_owner_name $name

        #
        # 2. Add operations
        #
        foreach {operation call} {
            GetMyName             "::xoopenai_portlet name"
            GetPrettyName         "::xoopenai_portlet pretty_name"
            Link                  "::xoopenai_portlet link"
            AddSelfToPage         "::xoopenai_portlet add_self_to_page"
            Show                  "::xoopenai_portlet show"
            Edit                  "::xoopenai_portlet edit"
            RemoveSelfFromPage    "::xoopenai_portlet remove_self_from_page"
        } {
            ::xo::db::sql::acs_sc_impl_alias new \
                -impl_contract_name "portal_datasource" -impl_name $name  \
                -impl_operation_name $operation -impl_alias $call \
                -impl_pl "TCL"
        }

        #
        # 3. Add binding
        #
        ::xo::db::sql::acs_sc_binding new \
            -contract_name "portal_datasource" -impl_name $name
    }
}

::xoopenai_portlet proc uninstall {} {
    set name [:name]
    ::xo::dc transaction {
        set ds_id [db_string dbqd..get_ds_id {
            select datasource_id from portal_datasources where name = :name
        } -default "0"]

        if {$ds_id ne 0} {
            ::xo::db::sql::portal_datasource delete -datasource_id $ds_id
        }

        #
        # drop operations
        #
        foreach operation {
            GetMyName GetPrettyName Link AddSelfToPage
            Show Edit RemoveSelfFromPage
        } {
            ::xo::db::sql::acs_sc_impl_alias delete \
                -impl_contract_name "portal_datasource" -impl_name $name \
                -impl_operation_name $operation
        }

        #
        # drop binding
        #
        ::xo::db::sql::acs_sc_binding delete \
            -contract_name "portal_datasource" -impl_name $name

        #
        # drop implementation
        #
        ::xo::db::sql::acs_sc_impl delete \
            -impl_contract_name "portal_datasource" -impl_name $name
    }
}

