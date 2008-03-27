class Admin::OperatorController < AdminController
  def index
    @reports = @campaign.reports
  end
end
