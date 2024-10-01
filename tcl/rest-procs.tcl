::xo::library doc {
    Support for the OpenAI API

    The present interface classes support the interaction with the REST API
    provided by openai.com, which allows the usage of language models to
    authenticated users in order to perform tasks which belong to the field
    of Natural Language Processing, and other areas, e.g., question answering,
    text summarization, or code completion tasks, among many others.

    This interface is based on API keys which are rquired to access the
    OpenAI services. We assume that the user of this interface has
    already gained access to an API key by creating an account on
    https://platform.openai.com/signup and subsequently generating an
    API key on https://platform.openai.com/account/api-keys. Furthermore,
    the Organization ID of the organization to which a user belongs can
    be obtained from https://platform.openai.com/account/org-settings.
    Both, the API key and the Organization ID will be required for the
    configuration of an instance of the services provided by this interface.

    @author Sebastian Scheder
    @creation-date July, 2024

    See https://platform.openai.com/docs/api-reference/
}

::xo::library require -package xooauth rest-procs

namespace eval ::xoopenai {
    ###########################################################
    #
    # xoopenai::REST class:
    #
    # Support for the OpenAI API
    # https://platform.openai.com/docs/api-reference/
    #
    ###########################################################


    nx::Class create REST -superclasses ::xo::REST {
        #
        # In order to initialize an instance of OpenAI, one
        # needs to pass values for client_id and client_secret
        # which are required by the constructor of the REST
        # superclass. The params are explained as follows:
        #
        # -client_id: OpenAI organization ID. Each OpenAI account
        # is assigned an organization ID which can be found on
        # https://platform.openai.com/account/org-settings.
        #
        # -client_secret: OpenAI API key. They can be generated on
        # https://platform.openai.com/account/api-keys.
        #
        # -project_id: OpenAI project ID. Projects aim to introduce
        # an additional level for more granular management, see
        # https://platform.openai.com/docs/api-reference/projects,
        # https://help.openai.com/en/articles/9186755-managing-your-work-in-the-api-platform-with-projects.
        #
        # An exemplary setup and usage of a class instance can be
        # xoopenai::REST create o \
                            -client_id $org_id \
                            -project_id $project_id \
                            -client_secret $api_key
        # [o model list]
        #

        #
        # API version
        #
        :property {project_id}
        :property {version v1}

        :method request {
            {-method:required}
            {-content_type "application/json; charset=utf-8"}
            {-token}
            {-vars ""}
            {-url:required}
        } {
            if {[string match http* $url]} {
                #
                # If we have a full URL, just pass everything up
                #
                next
            } else {
                #
                # If we have a relative URL (which has to start with a
                # slash), preprend 'https://api.openai.com' as a prefix.
                #
                set tokenArg [expr {[info exists token] ? [list -token $token] : {}}]
                next [list \
                        -method $method \
                        -content_type $content_type \
                        {*}$tokenArg \
                        -vars $vars \
                        -url https://api.openai.com/${:version}$url]
            }
        }

        :method body {
            {-content_type "application/json; charset=utf-8"}
            {-vars ""}
        } {
            #
            # Build a body based on the provided variable names. The
            # values are retrieved via uplevel calls.
            #

            #
            # Get the caller of the caller (and ignore next calling levels).
            #
            set callinglevel [:uplevel [current callinglevel] [list current callinglevel]]

            if {[string match "application/json*" $content_type]} {
                #
                # Convert var bindings to a JSON structure. This supports
                # an interface somewhat similar to export_vars but
                # supports currently as import just a list of variable
                # names with a suffix of either "array" (when value is a
                # list) or "triples" (for processing a triple list as
                # returned by e.g. mongo::json::parse).
                #
                return [:typed_list_to_json [concat {*}[lmap p $vars {
                    if {[regexp {^(.*):([a-z]+)(,[a-z]+)?$} $p . prefix suffix type]} {
                        set type [expr {$type eq "" ? "string" : [string range $type 1 end]}]
                        if {$suffix eq "array"} {
                            set values [:uplevel $callinglevel [list set $prefix]]
                            set result {}; set c 0
                            foreach v $values {
                                lappend result [list [incr c] $type $v]
                            }
                            list $prefix array [concat {*}$result]
                        } elseif {$suffix eq "num"} {
                            #
                            # add support for numeric values
                            #
                            set values [:uplevel $callinglevel [list set $prefix]]
                            set result [expr {$values}]
                            list $prefix $suffix [concat {*}$result]
                        } else {
                            list $prefix $suffix [:uplevel $callinglevel [list set $prefix]]
                        }
                    } else {
                        if {![:uplevel $callinglevel [list info exists $p]]} continue
                        list $p string [:uplevel $callinglevel [list set $p]]
                    }
                }]]]
            } else {
                return [:uplevel $callinglevel [list export_vars $vars]]
            }
        }

        ###########################################################
        #
        # xoopenai::REST "model" ensemble
        #
        ###########################################################

        :public method "model list" {} {
            return [:request -method GET \
                        -token ${:client_secret} \
                        -url /models]
        }

        :public method "model get" {
            model
        } {
            return [:request -method GET \
                        -token ${:client_secret} \
                        -url /models/$model]
        }

        ###########################################################
        #
        # xoopenai::REST "chat" ensemble
        #
        ###########################################################

        :public method "chat" {
            {-model "gpt-3.5-turbo"}
            {-max_tokens 200}
            {-content:required}
        } {
            set model $model
            set role "user"
            set messages [subst {{
                role string "$role"
                content string "$content"
            }}]
            return [:request \
                        -method POST \
                        -token ${:client_secret} \
                        -vars {model max_tokens:num messages:array,document} \
                        -url /chat/completions]
        }
    }
}

::xo::library source_dependent
