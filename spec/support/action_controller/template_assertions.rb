module ActionController
  ##
  # We are monkey-patching this module's +assert_template+, as
  # ActionPack 3.2.16 will incorrectly match substrings when
  # asserting that templates have been rendered.
  module TemplateAssertions
    # Asserts that the request was rendered with the appropriate template file or partials.
    #
    # ==== Examples
    #
    #   # assert that the "new" view template was rendered
    #   assert_template "new"
    #
    #   # assert that the layout 'admin' was rendered
    #   assert_template :layout => 'admin'
    #   assert_template :layout => 'layouts/admin'
    #   assert_template :layout => :admin
    #
    #   # assert that no layout was rendered
    #   assert_template :layout => nil
    #   assert_template :layout => false
    #
    #   # assert that the "_customer" partial was rendered twice
    #   assert_template :partial => '_customer', :count => 2
    #
    #   # assert that no partials were rendered
    #   assert_template :partial => false
    #
    # In a view test case, you can also assert that specific locals are passed
    # to partials:
    #
    #   # assert that the "_customer" partial was rendered with a specific object
    #   assert_template :partial => '_customer', :locals => { :customer => @customer }
    #
    def assert_template(options = {}, message = nil)
      validate_request!
      # Force body to be read in case the template is being streamed
      response.body

      case options
      when NilClass, String, Symbol
        options = options.to_s if Symbol === options
        rendered = @templates
        msg = build_message(message,
                "expecting <?> but rendering with <?>",
                options, rendered.keys.join(', '))
        assert_block(msg) do
          if options
            rendered.any? { |t, _| Regexp.new("^#{t}$").match(options) }
          else
            @templates.blank?
          end
        end
      when Hash
        if options.key?(:layout)
          expected_layout = options[:layout]
          msg = build_message(message,
                  "expecting layout <?> but action rendered <?>",
                  expected_layout, @layouts.keys)

          case expected_layout
          when String, Symbol
            assert(@layouts.keys.include?(expected_layout.to_s), msg)
          when Regexp
            assert(@layouts.keys.any? {|l| l =~ expected_layout }, msg)
          when nil, false
            assert(@layouts.empty?, msg)
          end
        end

        if expected_partial = options[:partial]
          if expected_locals = options[:locals]
            if defined?(@locals)
              actual_locals = @locals[expected_partial.to_s.sub(/^_/,'')]
              expected_locals.each_pair do |k,v|
                assert_equal(v, actual_locals[k])
              end
            else
              warn "the :locals option to #assert_template is only supported in a ActionView::TestCase"
            end
          elsif expected_count = options[:count]
            actual_count = @partials[expected_partial]
            msg = build_message(message,
                    "expecting ? to be rendered ? time(s) but rendered ? time(s)",
                     expected_partial, expected_count, actual_count)
            assert(actual_count == expected_count.to_i, msg)
          else
            msg = build_message(message,
                    "expecting partial <?> but action rendered <?>",
                    options[:partial], @partials.keys)
            assert(@partials.include?(expected_partial), msg)
          end
        elsif options.key?(:partial)
          assert @partials.empty?,
            "Expected no partials to be rendered"
        end
      end
    end
  end
end

