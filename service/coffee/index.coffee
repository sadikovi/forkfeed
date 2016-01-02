_util = @util
_api = new @FeedApi()

actionAddRepo= document.getElementById("forkfeed-add-repository")
actionAddRss = document.getElementById("forkfeed-add-rss-feed")
menu = document.getElementById("forkfeed-menu")

unless actionAddRss and actionAddRepo and menu
    throw new Error("Required elements are not found on page")

# actions for repository and rss feed
new @FastEditor(actionAddRepo, (status, value) ->
    console.log status, value
    _api.create("REP", value, ->
        console.log("before")
    , (ok, json) ->
        console.log ok, json
    )
, "Add", "Cancel", "Add repository", false)

new @FastEditor(actionAddRss, (status, value) ->
    console.log status, value
    _api.create("RSS", value, ->
        console.log("before")
    , (ok, json) ->
        console.log ok, json
    )
, "Add", "Cancel", "Add rss feed url", false)

# add delete actions
list = menu.getElementsByTagName("div")
for div in list
    if div.hasAttribute("daction")
        _util.addEventListener div, "click", ->
            itemid = @getAttribute("dkey")
            _api.delete(itemid, ->
                console.log "before delete"
            , (ok, json) ->
                console.log ok, json
            )
