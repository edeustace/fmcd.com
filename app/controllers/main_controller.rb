class MainController < ApplicationController
  def index
    json_file = ENV['FMCD_JSON_FILE'] || "fmcd.com.json"
    @json_data = IO.read("#{Rails.root}/config/#{json_file}")
    @json_data
  end

  def test_one
    render :layout => false 
  end

end
