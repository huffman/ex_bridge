module ExBridge::Response
  % TODO: Maybe an ordered dict is not the best/fastest way to represent the headers
  module Headers
    def __bound__(response, headers)
      @('response: response, 'headers: headers)
    end

    def [](key)
      @headers[key]
    end

    def merge(headers)
      @response.headers(@headers.merge(headers))
    end

    def clear
      @response.headers({})
    end

    def delete(key)
      @response.headers(@headers.delete(key))
    end

    def to_dict
      @headers
    end
  end

  % TODO: Maybe an ordered dict is not the best/fastest way to represent cookies
  module Cookies
    def __bound__(response, cookies)
      @('response: response, 'cookies: cookies)
    end

    def [](key)
      @cookies[key]
    end

    def set(key, value, options := {})
      @response.cookies @cookies.set(key, options.set('value, value))
    end

    def delete(key, options := {})
      set(key, "deleted", options.merge('expires: unix_1970))
    end

    def to_dict
      @cookies
    end

    private

    def unix_1970
      DateTime.new({{1970,1,1},{0,0,1}})
    end
  end

  attr_reader   ['docroot]
  attr_writer   ['headers, 'cookies]
  attr_accessor ['status, 'body, 'file]

  def __bound__(request, options)
    docroot = options['docroot]
    @('request: request, 'docroot: docroot, 'headers: {}, 'cookies: {})
  end

  % api: public
  def headers
    #ExBridge::Response::Headers(self, @headers)
  end

  % api: public
  def cookies
    #ExBridge::Response::Cookies(self, @cookies)
  end

  % api: public
  def dispatch!
    if @file
      self.serve_file!(@file, @headers)
    else
      headers = serialize_cookies(@headers, @cookies)
      self.serve_body!(@status || 200, headers, @body || "")
    end
  end

  % api: public
  def set(status, headers, body)
    @('status: status, 'headers: headers, 'body: body)
  end

  % api: plugin
  def serve_file_conditionally(path, function)
    if @docroot
      if ~r"\.\.".match?(path)
        self.serve_body!(403, {}, "Forbidden")
      else
        joined = File.join(@docroot, path)
        if File.regular?(joined)
          function.()
          200
        else
          self.serve_body!(404, {}, "Not Found")
        end
      end
    else
      error { 'nodocroot, "Cannot send file without docroot" }
    end
  end

  private

  def serialize_cookies(headers, {})
    headers
  end

  def serialize_cookies(headers, cookies)
    headers.to_list + cookies.to_list.map -> (c) { "Set-Cookie", serialize_cookie(c) }
  end

  def serialize_cookie({key, options})
    string = "#{key}=#{options['value]}"

    if expires = options['expires]
      string = string + "; expires=#{serialize_expires(expires)}"
    end

    if path = options['path]
      string = string + "; path=#{path}"
    end

    if domain = options['domain]
      string = string + "; domain=#{domain}"
    end

    if options['secure]
      string = string + "; secure"
    end

    unless options['httponly] == false
      string = string + "; httponly"
    end

    string
  end

  def serialize_expires(expires)
    % TODO Duck type when we have respond_to?
    if expires.__module_name__ == 'Time::Behavior
      expires.rfc1123
    else
      expires
    end
  end
end