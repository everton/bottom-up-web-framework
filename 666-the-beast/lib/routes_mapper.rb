class RoutesMapper
  def initialize
    @routes = []
  end

  def root(options = {})
    get('/', options)
  end

  def get(path, options = {})
    @routes << Route.new(path, options)
  end

  def match(path)
    @routes.each do |route|
      params = route.match path
      return params if params
    end

    return nil
  end

  private
  class Route
    def initialize(path, options)
      @path   = regularize path
      @params = options
    end

    def match(path)
      App::LOGGER.debug "Matching '#{path}' against '#{@path}'"

      matches = path.match @path

      return unless matches

      captureds  = matches.names.map(&:to_sym)
      url_params = Hash[ captureds.zip(matches.captures) ]

      @params.merge url_params
    end

    private
    # regularize 'users/:id/:edit'
    # => /^\/users\/(?<id>\w*)\/(?<edit>\w*)$/
    def regularize(path)
      path = "/#{path}" unless path.start_with? '/'

      params = path.scan /\:\w+/
      params.each do |param|
        path.gsub! param, "(?<#{param[1..-1]}>\\w*)"
      end

      Regexp.new "^#{path}$"
    end
  end
end
