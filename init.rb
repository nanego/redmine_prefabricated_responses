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
  # require_dependency 'redmine_prefabricated_responses/issue_patch'
end

Redmine::Plugin.register :redmine_prefabricated_responses do
  name 'Redmine Prefabricated Responses plugin'
  author 'Vincent ROBERT'
  description 'This is a plugin for Redmine. It allows you to prepare frequent responses and make easy for your users to use them.'
  version '1.0.0'
  url 'https://github.com/nanego/redmine_prefabricated_responses'
  requires_redmine_plugin :redmine_base_rspec, :version_or_higher => '0.0.4' if Rails.env.test?
  requires_redmine_plugin :redmine_base_deface, :version_or_higher => '0.0.1'
  menu :admin_menu, :prefabricated_responses, { :controller => 'prefabricated_responses', :action => 'index' },
       :caption => :label_prefabricated_responses,
       :html => {:class => 'icon'}
end
