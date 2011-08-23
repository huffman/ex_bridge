module ExBridge::Request
  def __bound__(request, _options := {})
    @('request: request)
  end

  def memoize!
    memoize!('headers).memoize!('cookies).memoize!('query_params).memoize!('post_params)
  end

  def memoize!('headers)
    @('headers: self.headers)
  end

  def memoize!('cookies)
    @('cookies: self.cookies)
  end

  def memoize!('query_params)
    @('query_params: self.query_params)
  end

  def memoize!('post_params)
    @('post_params: self.post_params)
  end

  def cookies
    @cookies || begin
      headers = self.headers
      if raw_cookies = headers["Cookie"]
        list = raw_cookies.split(~r";").foldl [], do (cookie, acc)
          case cookie.strip.split(~r"=", 2)
          match [first, second] then [{first,second}|acc]
          else % Nothing
          end
        end
        OrderedDict.from_list list.flatten
      else
        {}
      end
    end
  end

  % Helpers

  def upcase_headers(object)
    if object.__module_name__ == 'Atom::Behavior
      object.to_s
    else
      upcase_headers(object.to_char_list, [])
    end
  end

  def upcase_headers([h|t], []) when h >= 97 and h <= 122
    upcase_headers([t], [h-32])
  end

  def upcase_headers([$-,h|t], acc) when h >= 97 and h <= 122
    upcase_headers(t, [h-32,$-|acc])
  end

  def upcase_headers([h|t], acc)
    upcase_headers(t, [h|acc])
  end

  def upcase_headers([], acc)
    acc.reverse.to_bin
  end
end
