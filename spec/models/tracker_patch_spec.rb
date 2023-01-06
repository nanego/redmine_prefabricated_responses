require "spec_helper"
require File.dirname(__FILE__) + '/../../lib/redmine_prefabricated_responses/tracker_patch'

describe "TrackerPatch/update reponse table" do

  fixtures :responses, :trackers  

  it "Delete tracker should remove its id from Response.tracker_ids" do
    response_test = Response.find(5)
    tracker_test = Tracker.create(name: "test", default_status_id: 1)
    response_test.tracker_ids << tracker_test.id.to_s
    response_test.save
    
    tracker_test.destroy
    
    expect(Response.find(5).tracker_ids).not_to include(tracker_test.id.to_s)
  end  

end