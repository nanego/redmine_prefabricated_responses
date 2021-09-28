require File.dirname(__FILE__) + '/../../helpers/responses_helper'
include ResponsesHelper

Deface::Override.new :virtual_path  => 'issues/_action_menu',
                     :name          => 'add-responses-to-issue-actions',
                     :insert_top    => '.contextual',
                     :partial          => 'responses/action_menu_dropdown'

