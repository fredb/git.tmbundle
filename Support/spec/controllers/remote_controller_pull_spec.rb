require File.dirname(__FILE__) + '/../spec_helper'

describe RemoteController do
  include SpecHelpers
  
  before(:each) do
    Git.reset_mock!
  end
  
  describe "pulling" do
    before(:each) do
      # query the sources
      Git.command_response["branch"] = "* master\n"
      Git.command_response["branch", "-r"] = "  origin/master\n  origin/release\n"
      Git.command_response["config", "remote.origin.fetch"] = "+refs/heads/*:refs/remotes/origin/*"
      Git.command_response["config", "branch.master.remote"] = %Q{origin}
      Git.command_response["config", "branch.master.merge"] = %Q{refs/heads/master}
      Git.command_response["remote"] = %Q{origin}
    
      # query the config - if source != self["remote.#{current_branch}.remote"] || self["remote.#{current_branch}.merge"].nil?
    
      # Git.command_response[] 
      Git.command_response["log", "-p", "791a587..4bfc230", "."] = fixture_file("log_with_diffs.txt")
      Git.command_response["log", "-p", "dc29d3d..05f9ad9", "."] = fixture_file("log_with_diffs.txt")
      Git.command_response["pull", "origin"] = fixture_file("pull_1_5_4_3_output.txt")
      
      @output = capture_output do
        dispatch :controller => "remote", :action => "pull"
      end
    end
    
    it "should output log of changes pulled" do
      @output.should include("Log of changes pulled")
      @output.should include("Branch 'master': 791a587..4bfc230")
      @output.should include("Branch 'asdf': dc29d3d..05f9ad9")
    end
  end
end