module RedminePrefabricatedResponses
  class Hooks < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      stylesheet_link_tag("prefabricated_responses", :plugin => "redmine_prefabricated_responses")
    end
  end
end
