window.util = {}

# Get parameters in query string as Object.
#
# example:
#    # window.location == http://example.com/posts?search=jquery&from=2012
#    => { search: 'jquery', from: '2012'}
#
util.getParams = (key) =>
  [n, paramsInArray...] = location.search.split(/[\?\&]/).map (x) -> x.split '='
  params = {}
  paramsInArray.forEach (p) -> params[p[0]] = p[1]
  params[key]
