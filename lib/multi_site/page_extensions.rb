module MultiSite::PageExtensions
  def self.included(base)
    base.class_eval {
      alias_method_chain :path, :sites
      mattr_accessor :current_site
      has_one :site, :foreign_key => "homepage_id", :dependent => :nullify
    }
    base.extend ClassMethods
    class << base
      alias_method_chain :find_by_path, :sites
      alias_method_chain :root, :sites
      
      def current_site
        @current_site ||= Site.default
      end
      
      def current_site=(site)
        @current_site = site
      end
    end
  end
  
  module ClassMethods
    def root_with_sites
      #root_obj = nil
      if self.current_site.is_a?(Site)
        #root_obj = self.current_site.homepage
        return self.current_site.homepage
      else
        #root_obj = root_without_sites
        return root_without_sites
      end  
      #root_obj
    end
    
    def find_by_path_with_sites(path, live=true)
      page_root = root
      raise Page::MissingRootPageError unless page_root
      page_root.find_by_path(path, live)
    end
    
    def homepage
      root
    end
  end
  
  def full_url
    self.root.site.url(self.path)
  end
  
  def path_with_sites
    #path_obj = nil
    if !self.parent.nil?
      #path_obj = self.parent.child_path(self)
      return self.parent.child_path(self)
    else
      #path_obj = "/"
      return "/"
    end
    #return path_obj
  end
end