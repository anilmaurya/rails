require 'active_support/concern'
require 'action_view/helpers/asset_tag_helpers/helper_methods'

module ActionView
  module Helpers
    module AssetTagHelper

      module JavascriptTagHelpers
        extend ActiveSupport::Concern
        extend HelperMethods
        include SharedHelpers

        included do
          mattr_accessor :javascript_expansions
          self.javascript_expansions = { }
        end

        module ClassMethods
          # Register one or more javascript files to be included when <tt>symbol</tt>
          # is passed to <tt>javascript_include_tag</tt>. This method is typically intended
          # to be called from plugin initialization to register javascript files
          # that the plugin installed in <tt>public/javascripts</tt>.
          #
          #   ActionView::Helpers::AssetTagHelper.register_javascript_expansion :monkey => ["head", "body", "tail"]
          #
          #   javascript_include_tag :monkey # =>
          #     <script type="text/javascript" src="/javascripts/head.js"></script>
          #     <script type="text/javascript" src="/javascripts/body.js"></script>
          #     <script type="text/javascript" src="/javascripts/tail.js"></script>
          def register_javascript_expansion(expansions)
            self.javascript_expansions.merge!(expansions)
          end
        end

        # Computes the path to a javascript asset in the public javascripts directory.
        # If the +source+ filename has no extension, .js will be appended (except for explicit URIs)
        # Full paths from the document root will be passed through.
        # Used internally by javascript_include_tag to build the script path.
        #
        # ==== Examples
        #   javascript_path "xmlhr" # => /javascripts/xmlhr.js
        #   javascript_path "dir/xmlhr.js" # => /javascripts/dir/xmlhr.js
        #   javascript_path "/dir/xmlhr" # => /dir/xmlhr.js
        #   javascript_path "http://www.railsapplication.com/js/xmlhr" # => http://www.railsapplication.com/js/xmlhr
        #   javascript_path "http://www.railsapplication.com/js/xmlhr.js" # => http://www.railsapplication.com/js/xmlhr.js
        asset_path :javascript, 'js'

        # Returns an HTML script tag for each of the +sources+ provided. You
        # can pass in the filename (.js extension is optional) of JavaScript files
        # that exist in your <tt>public/javascripts</tt> directory for inclusion into the
        # current page or you can pass the full path relative to your document
        # root. To include the Prototype and Scriptaculous JavaScript libraries in
        # your application, pass <tt>:defaults</tt> as the source. When using
        # <tt>:defaults</tt>, if an <tt>application.js</tt> file exists in
        # <tt>public/javascripts</tt> it will be included as well. You can modify the
        # HTML attributes of the script tag by passing a hash as the last argument.
        #
        # ==== Examples
        #   javascript_include_tag "xmlhr" # =>
        #     <script type="text/javascript" src="/javascripts/xmlhr.js?1284139606"></script>
        #
        #   javascript_include_tag "xmlhr.js" # =>
        #     <script type="text/javascript" src="/javascripts/xmlhr.js?1284139606"></script>
        #
        #   javascript_include_tag "common.javascript", "/elsewhere/cools" # =>
        #     <script type="text/javascript" src="/javascripts/common.javascript?1284139606"></script>
        #     <script type="text/javascript" src="/elsewhere/cools.js?1423139606"></script>
        #
        #   javascript_include_tag "http://www.railsapplication.com/xmlhr" # =>
        #     <script type="text/javascript" src="http://www.railsapplication.com/xmlhr.js?1284139606"></script>
        #
        #   javascript_include_tag "http://www.railsapplication.com/xmlhr.js" # =>
        #     <script type="text/javascript" src="http://www.railsapplication.com/xmlhr.js?1284139606"></script>
        #
        #   javascript_include_tag :defaults # =>
        #     <script type="text/javascript" src="/javascripts/prototype.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/effects.js?1284139606"></script>
        #     ...
        #     <script type="text/javascript" src="/javascripts/application.js?1284139606"></script>
        #
        # * = The application.js file is only referenced if it exists
        #
        # You can also include all javascripts in the +javascripts+ directory using <tt>:all</tt> as the source:
        #
        #   javascript_include_tag :all # =>
        #     <script type="text/javascript" src="/javascripts/prototype.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/effects.js?1284139606"></script>
        #     ...
        #     <script type="text/javascript" src="/javascripts/application.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/shop.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/checkout.js?1284139606"></script>
        #
        # Note that the default javascript files will be included first. So Prototype and Scriptaculous are available to
        # all subsequently included files.
        #
        # If you want Rails to search in all the subdirectories under javascripts, you should explicitly set <tt>:recursive</tt>:
        #
        #   javascript_include_tag :all, :recursive => true
        #
        # == Caching multiple javascripts into one
        #
        # You can also cache multiple javascripts into one file, which requires less HTTP connections to download and can better be
        # compressed by gzip (leading to faster transfers). Caching will only happen if config.perform_caching
        # is set to <tt>true</tt> (which is the case by default for the Rails production environment, but not for the development
        # environment).
        #
        # ==== Examples
        #   javascript_include_tag :all, :cache => true # when config.perform_caching is false =>
        #     <script type="text/javascript" src="/javascripts/prototype.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/effects.js?1284139606"></script>
        #     ...
        #     <script type="text/javascript" src="/javascripts/application.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/shop.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/checkout.js?1284139606"></script>
        #
        #   javascript_include_tag :all, :cache => true # when config.perform_caching is true =>
        #     <script type="text/javascript" src="/javascripts/all.js?1344139789"></script>
        #
        #   javascript_include_tag "prototype", "cart", "checkout", :cache => "shop" # when config.perform_caching is false =>
        #     <script type="text/javascript" src="/javascripts/prototype.js?1284139606"></script>
        #     <script type="text/javascript" src="/javascripts/cart.js?1289139157"></script>
        #     <script type="text/javascript" src="/javascripts/checkout.js?1299139816"></script>
        #
        #   javascript_include_tag "prototype", "cart", "checkout", :cache => "shop" # when config.perform_caching is true =>
        #     <script type="text/javascript" src="/javascripts/shop.js?1299139816"></script>
        #
        # The <tt>:recursive</tt> option is also available for caching:
        #
        #   javascript_include_tag :all, :cache => true, :recursive => true
        def javascript_include_tag(*sources)
          options = sources.extract_options!.stringify_keys
          concat  = options.delete("concat")
          cache   = concat || options.delete("cache")
          recursive = options.delete("recursive")

          if concat || (config.perform_caching && cache)
            joined_javascript_name = (cache == true ? "all" : cache) + ".js"
            joined_javascript_path = File.join(joined_javascript_name[/^#{File::SEPARATOR}/] ? config.assets_dir : config.javascripts_dir, joined_javascript_name)

            unless config.perform_caching && File.exists?(joined_javascript_path)
              write_asset_file_contents(joined_javascript_path, compute_javascript_paths(sources, recursive))
            end
            javascript_src_tag(joined_javascript_name, options)
          else
            sources = expand_javascript_sources(sources, recursive)
            ensure_javascript_sources!(sources) if cache
            sources.collect { |source| javascript_src_tag(source, options) }.join("\n").html_safe
          end
        end

        private

          def javascript_src_tag(source, options)
            content_tag("script", "", { "type" => Mime::JS, "src" => path_to_javascript(source) }.merge(options))
          end

          def compute_javascript_paths(*args)
            expand_javascript_sources(*args).collect { |source| compute_public_path(source, 'javascripts', 'js', false) }
          end

          def expand_javascript_sources(sources, recursive = false)
            if sources.include?(:all)
              all_javascript_files = (collect_asset_files(config.javascripts_dir, ('**' if recursive), '*.js') - ['application']) << 'application'
              ((determine_source(:defaults, self.javascript_expansions).dup & all_javascript_files) + all_javascript_files).uniq
            else
              expanded_sources = sources.collect do |source|
                determine_source(source, self.javascript_expansions)
              end.flatten
              expanded_sources << "application" if sources.include?(:defaults) && File.exist?(File.join(config.javascripts_dir, "application.js"))
              expanded_sources
            end
          end

          def ensure_javascript_sources!(sources)
            sources.each do |source|
              asset_file_path!(path_to_javascript(source))
            end
            return sources
          end

      end

    end
  end
end