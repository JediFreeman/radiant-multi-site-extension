module MultiSite::SiteControllerExtensions
  def self.included(base)
    base.class_eval do
      before_filter :set_site
      
      alias_method_chain :dev?, :sites
    end
  end
  
  def set_site
    Page.current_site = Site.find_for_host(request.host)
    true
  end
  
  def dev_with_sites?
    if dev_host = Page.current_site.dev_base_domain
      request.host == dev_host
    else
      request.host =~ /^dev\./
    end
  end
end
