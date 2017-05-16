module CheckSiteIsNotGlobal
  extend ActiveSupport::Concern

  class_methods do
    def check_site_is_not_global(options = {})
      before_action :check_global_redirect_or_archive, options
    end
  end

protected

  def check_global_redirect_or_archive
    if @site.global_type.present?
      if @site.global_redirect?
        message = "This site has been entirely redirected."
      elsif @site.global_archive?
        message = "This site has been entirely archived."
      end
      redirect_to site_path(@site), alert: "#{message} You can't edit its mappings."
    end
  end
end
