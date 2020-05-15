class LeaderboardController < ApplicationController
  def index
    unless current_user.gds_editor?
      redirect_to root_path, flash: { notice: "Only GDS Editors can access the leaderboard." }
    end

    @leaderboard = Organisation.leaderboard
  end
end
