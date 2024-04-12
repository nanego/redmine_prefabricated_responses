require "spec_helper"
require File.dirname(__FILE__) + '/../../lib/redmine_prefabricated_responses/user_patch'

describe "UserPatch/update reponse table" do

  fixtures :responses, :users

  before(:each) do
    Response.find(2).update(assigned_to_id: 2)
  end

  it "Set assigned_to_id to nil when deleting a user" do
    user = User.find(2)
    user.destroy

    expect(Response.find(2).assigned_to_id).to be_nil
  end

  it "Set anonymous author when deleting a user" do
    user = User.find(2)
    user.destroy

    expect(Response.find(1).author_id).to eq(User.anonymous.id)
  end

end
