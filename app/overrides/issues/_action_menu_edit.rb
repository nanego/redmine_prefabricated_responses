Deface::Override.new :virtual_path => 'issues/_action_menu_edit',
                     :name         => 'identify-bottom-action-menu',
                     :replace      => 'erb[loud]:contains("render :partial => \'action_menu\'")',
                     :text         => <<BOTTOM_ACTION_MENU
<%= render :partial => 'action_menu', locals: { bottom: true }  %>
BOTTOM_ACTION_MENU
