_util = @util
_api = new @FeedApi()
_event_api = new @EventsApi()

actionAddRepo= document.getElementById("forkfeed-add-repository")
actionAddRss = document.getElementById("forkfeed-add-rss-feed")
menu = document.getElementById("forkfeed-menu")

unless actionAddRss and actionAddRepo and menu
    throw new Error("Required elements are not found on page")

# actions for repository and rss feed
new @FastEditor(actionAddRepo, (status, value) ->
    if status
        _api.create "REP", value, ->
            console.log("before")
        , (ok, json) ->
            console.log ok, json
, "Add", "Cancel", "Add owner/repository", false)

new @FastEditor(actionAddRss, (status, value) ->
    if status
        _api.create "RSS", value, ->
            console.log("before")
        , (ok, json) ->
            console.log ok, json
, "Add", "Cancel", "Add rss feed url", false)

# assign actions to elements
list = menu.getElementsByTagName("*")
for elem in list
    # delete button
    if elem.getAttribute("daction") == "del"
        _util.addEventListener elem, "click", (e) ->
            itemid = @getAttribute("dkey")
            _api.delete(itemid, ->
                console.log "before delete"
            , (ok, json) ->
                console.log ok, json
            )
            e.stopPropagation()
            e.preventDefault()
    # loading actions
    else if elem.getAttribute("daction") == "load"
        dtype = elem.getAttribute("dtype").toLowerCase()
        if dtype == "rep"
            _util.addEventListener elem, "click", (e) ->
                item = @getAttribute("dlink")
                _event_api.githubEvent item, ->
                    console.log "before"
                , (ok, json) ->
                    console.log ok, json
        if dtype == "rss"
            console.log "RSS feed is not supported"
