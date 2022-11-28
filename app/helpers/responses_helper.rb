module ResponsesHelper
  def options_for_responses_select(issue)
    responses = issue.available_responses
    tags = "".html_safe
    blank_text = "-- #{l(:label_responses)} --"
    tags << content_tag('option', blank_text, :value => '') if responses.size > 0
    tags << options_for_select(responses.map { |r| [r.name, r.id] })
    tags
  end

  # override principals_options_for_select ,to assign the response (with assigne to me) to the current user
  def principals_options_for_select_with_assigne_me_id_0(collection, selected=nil)
    s = +''
    if collection.include?(User.current)
      s << content_tag('option', "<< #{l(:label_me)} >>", :value => 0)
    end
    groups = +''
    collection.sort.each do |element|
      if option_value_selected?(element, selected) || element.id.to_s == selected
        selected_attribute = ' selected="selected"'
      end
      (element.is_a?(Group) ? groups : s) <<
        %(<option value="#{element.id}"#{selected_attribute}>#{h element.name}</option>)
    end
    unless groups.empty?
      s << %(<optgroup label="#{h(l(:label_group_plural))}">#{groups}</optgroup>)
    end
    s.html_safe
  end
end
