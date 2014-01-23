module MultiSite::PagesControllerExtensions
  def self.included(base)
    base.class_eval do
      before_filter do |c|
        c.include_stylesheet 'admin/multi_site'
      end
      alias_method_chain :index, :root
      alias_method_chain :continue_url, :site
      alias_method_chain :remove, :back
      responses.destroy.default do 
        return_url = session[:came_from]
        session[:came_from] = nil
        redirect_to return_url || admin_pages_url(:root => model.root.id)
      end
    end
  end

  def index_with_root
    if params[:site_id] # If a root page is specified
      @site = Site.find(params[:site_id])
      @homepage = @site.homepage
    elsif params[:root]
      @parent = Page.find_by_id(params[:root])
      @site = @parent.site
      @homepage = @site.homepage
    elsif current_site
      @site = current_site
      @homepage = @site.homepage
    elsif @site = Site.first(:order => "position ASC") # If there is a site defined
      if @site.homepage
        @homepage = @site.homepage
      end
    end
    @homepage ||= Page.find_by_parent_id(nil)
    response_for :plural
  end

  def remove_with_back
    session[:came_from] = request.env["HTTP_REFERER"]
    remove_without_back
  end
  
  def continue_url_with_site(options={})
    options[:redirect_to] || (params[:continue] ? edit_admin_page_url(model) : admin_pages_url(:root => model.root.id))
  end

end
