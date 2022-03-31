module ResponsesHelper
  def options_for_responses_select(issue)
    responses = issue.available_responses
    tags = "".html_safe
    blank_text = "-- #{l(:label_responses)} --"
    tags << content_tag('option', blank_text, :value => '') if responses.size > 0
    tags << options_for_select(responses.map { |r| [r.name, r.id] })
    tags
  end
end
