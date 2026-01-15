# frozen_string_literal: true

module RedminePrefabricatedResponses
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("prefabricated_responses", :plugin => "redmine_prefabricated_responses") +
        javascript_include_tag('prefabricated_responses.js', plugin: 'redmine_prefabricated_responses')
    end

    # adds a link in the sidebar of the main issue page
    render_on :view_issues_sidebar_queries_bottom, :partial => 'hooks/view_sidebar_manage_responses'
  end

  class ModelHook < Redmine::Hook::Listener
    def after_plugins_loaded(_context = {})
      require_relative 'issue_patch'
      require_relative 'issue_status_patch'
      require_relative 'tracker_patch'
      require_relative 'project_patch'
      require_relative 'user_patch'
      require_relative 'group_patch'
    end
  end
end
