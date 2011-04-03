% elixir: cache

object ExBridge::Misultin::Request
  proto ExBridge::Request

  def request_method
    Erlang.apply(@request, 'get, ['method])
  end

  def path
    { 'abs_path, path } = Erlang.apply(@request, 'get, ['uri])
    String.new path
  end

  def headers
    @headers || begin
      list = Erlang.apply(@request, 'get, ['headers])
      list = list.map -> ({x,y}) { upcase_headers(x), String.new(y) }
      OrderedDict.from_list list
    end
  end

  def build_response
    ExBridge::Misultin::Response.new(@request, @options)
  end
end