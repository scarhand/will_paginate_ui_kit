class UiKitLinkRenderer < WillPaginate::ViewHelpers::LinkRendererBase

  GET_PARAMS_BLACKLIST = [:script_name, :original_script_name]

  # * +collection+ is a WillPaginate::Collection instance or any other object
  #   that conforms to that API
  # * +options+ are forwarded from +will_paginate+ view helper
  # * +template+ is the reference to the template being rendered
  def prepare(collection, options, template)
    super(collection, options)
    @options[:class] = 'uk-pagination'
    @template = template
    @container_attributes = @base_url_params = nil
  end

  # Process it! This method returns the complete HTML string which contains
  # pagination links. Feel free to subclass LinkRenderer and change this
  # method as you see fit.
  def to_html
    html = pagination.map do |item|
      item.is_a?(Integer) ?
        page_number(item) :
        send(item)
    end.join(@options[:link_separator])
    
    @options[:container] ? html_container(html) : html
  end

  # Returns the subset of +options+ this instance was initialized with that
  # represent HTML attributes for the container element of pagination links.
  def container_attributes
    @container_attributes ||= @options.except(*(WillPaginate::ViewHelpers.pagination_options.keys + [:renderer] - [:class]))
  end

  def default_url_params
    {}
  end

  def page_number(page)
    if page == current_page
      tag(:li, nil, class: 'uk-active') do
        tag(:span, page)
      end
    else
      tag(:li) do
        tag(:a, page, href: url(page), rel: rel_value(page))
      end
    end
  end

  def gap
    text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
    tag(:li) do
      tag(:span, text)
    end
  end

  def previous_page
    num = @collection.current_page > 1 && @collection.current_page - 1
    previous_or_next_page(num, 'uk-pagination-previous')
  end

  def next_page
    num = @collection.current_page < total_pages && @collection.current_page + 1
    previous_or_next_page(num, 'uk-pagination-next')
  end

  def previous_or_next_page(page, attribute)
    if page
      tag(:li, nil) do
        tag(:a, nil, href: url(page), rel: rel_value(page)) do 
          tag(:span, '', attribute => '')
        end
      end
    else
      tag(:li, nil, class: 'uk-disabled') do
        tag(:a, nil, href: '#') do 
          tag(:span, '', attribute => '')
        end
      end
    end
  end

  def html_container(html)
    tag(:ul, html, container_attributes)
  end

  protected

  def url(page)
    @base_url_params ||= begin
      url_params = merge_get_params(default_url_params)
      url_params[:only_path] = true
      merge_optional_params(url_params)
    end

    url_params = @base_url_params.dup
    add_current_page_param(url_params, page)

    @template.url_for(url_params)
  end

  def merge_get_params(url_params)
    if @template.respond_to? :request and @template.request and @template.request.get?
      symbolized_update(url_params, @template.params, GET_PARAMS_BLACKLIST)
    end
    url_params
  end

  def merge_optional_params(url_params)
    symbolized_update(url_params, @options[:params]) if @options[:params]
    url_params
  end

  def add_current_page_param(url_params, page)
    unless param_name.index(/[^\w-]/)
      url_params[param_name.to_sym] = page
    else
      page_param = parse_query_parameters("#{param_name}=#{page}")
      symbolized_update(url_params, page_param)
    end
  end

  private

  def parse_query_parameters(params)
    Rack::Utils.parse_nested_query(params)
  end

  def param_name
    @options[:param_name].to_s
  end

  def link(text, target, attributes = {})
    if target.is_a?(Integer)
      attributes[:rel] = rel_value(target)
      target = url(target)
    end
    attributes[:href] = target
    tag(:a, text, attributes)
  end

  def tag(name, value = '', attributes = {}, &block)
    if block_given?
      value = yield
    end
    string_attributes = attributes.inject('') do |attrs, pair|
      unless pair.last.nil?
        attrs << %( #{pair.first}="#{CGI::escapeHTML(pair.last.to_s)}")
      end
      attrs
    end
    "<#{name}#{string_attributes}>#{value}</#{name}>"
  end

  def rel_value(page)
    case page
    when @collection.current_page - 1; 'prev'
    when @collection.current_page + 1; 'next'
    end
  end

  def symbolized_update(target, other, blacklist = nil)
    other.each_pair do |key, value|
      key = key.to_sym
      existing = target[key]
      next if blacklist && blacklist.include?(key)

      if value.respond_to?(:each_pair) and (existing.is_a?(Hash) or existing.nil?)
        symbolized_update(existing || (target[key] = {}), value)
      else
        target[key] = value
      end
    end
  end

end