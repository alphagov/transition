module HitsHelper
  def link_to_hit(hit)
    scheme_and_host = 'http://'+ hit.host.hostname
    link_to hit.path, scheme_and_host + hit.path
  end
end
