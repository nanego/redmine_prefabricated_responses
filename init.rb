Redmine::Plugin.register :redmine_prefabricated_responses do
  name
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

require 'redmine_prefabricated_responses/hooks'

ActiveSupport::Reloader.to_prepare do
  ::Issue.prepend RedminePrefabricatedResponses::IssuePatch
  require_dependency 'redmine_prefabricated_responses/issue_status_patch'
  require_dependency 'redmine_prefabricated_responses/tracker_patch'
  require_dependency 'redmine_prefabricated_responses/project_patch'
end

Redmine::Plugin.register :redmine_prefabricated_responses do
  name 'Redmine Prefabricated Responses plugin'
  author 'Vincent ROBERT'
  description 'This is a plugin for Redmine. It allows you to prepare frequent responses and make easy for your users to use them.'
  version '1.0.0'
  url 'https://github.com/nanego/redmine_prefabricated_responses'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.4' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  menu :admin_menu, :prefabricated_responses, { :controller => 'responses', :action => 'index' },
       :caption => :label_prefabricated_responses,
       :html => { :class => 'icon' }
  project_module :prefabricated_responses do
    permission :manage_public_responses, { :responses => [:index, :new, :create, :edit, :update, :destroy] }
    permission :use_public_responses, { :responses => [:index] }
    permission :create_prefabricated_responses, { :responses => [:index, :new, :create, :edit, :update, :destroy] }
    permission :edit_public_responses, { :responses => [:edit, :update] }
    permission :delete_public_responses, { :responses => [:destroy] }
  end
end
