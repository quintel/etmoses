class FinancialProfilesController < ProfilesController
  def new
    @profile = FinancialProfile.new
  end

  #######
  private
  #######

  def profile_scope
    :financial_profile
  end

  def fetch_profile
    @profile = FinancialProfile.find(params[:id])
    authorize @profile
  end
end
