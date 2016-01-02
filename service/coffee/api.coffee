_loader = @loader
_util = @util

class AbstractApi
    doRequest: (type, before, after, url, params) ->
        atype = type.toLowerCase()
        if params and atype == "get"
            url = url + "?" + ("#{_util.quote(k)}=#{_util.quote(v)}" for k, v of params).join("&")
            params = null
        else if atype == "post"
            params = JSON.stringify(params)
        before?()
        loader.sendrequest atype, url, {}, params
        , (success, response) ->
            json = util.jsonOrElse(response)
            after?(!!json, json)
        , (error, response) ->
            json = util.jsonOrElse(response)
            after?(false, json)

    doGet: (before, after, url, data=null) -> @doRequest("get", before, after, url, data)

    doPost: (before, after, url, data) -> @doRequest("post", before, after, url, data)

################################################################
### API
################################################################
class FeedApi extends AbstractApi
    create: (tpe, item, before, after) ->
        @doGet(before, after, "/api/v1/feed/create", {type: "#{tpe}", item: "#{item}"})

    delete: (itemid, before, after) ->
        @doGet(before, after, "/api/v1/feed/delete", {itemid: "#{itemid}"})

@FeedApi ?= FeedApi
