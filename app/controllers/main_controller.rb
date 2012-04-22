class MainController < ApplicationController
  def index
    @json_data = IO.read("#{Rails.root}/config/fmcd.com.json")
    @json_data
  end
  
  def test_page
  end
end
