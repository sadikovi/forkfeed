_util = @util
_mapper = @mapper
_api = new @FeedApi()
_event_api = new @EventsApi()
_github_parser = new @GithubApiParser()

actionAddRepo= document.getElementById("forkfeed-add-repository")
actionAddRss = document.getElementById("forkfeed-add-rss-feed")
menu = document.getElementById("forkfeed-menu")
contentHeader = document.getElementById("forkfeed-header")
content = document.getElementById("forkfeed-content")

unless actionAddRss and actionAddRepo and menu and contentHeader and content
    throw new Error("Required elements are not found on page")

# actions for repository and rss feed
new @FastEditor(actionAddRepo, (status, value) ->
    if status
        _api.create "REP", value, null, (ok, json) ->
            location.reload() if ok
, "Add", "Cancel", "Add owner/repository", false)

new @FastEditor(actionAddRss, (status, value) ->
    if status
        _api.create "RSS", value, null, (ok, json) ->
            location.reload() if ok
, "Add", "Cancel", "Add rss feed url", false)

# function to build event html segment
eventHtml = (event) ->
    footer =
        type: "div"
        cls: "breadcrumb"
        children: [
            {type: "div", cls: "section", children:
                type: "span", cls: "text-mute", title: "#{event.tpe}"},
            {type: "div", cls: "section", children:
                type: "span", cls: "text-mute", title: "by @#{event.user}"},
            {type: "div", cls: "section", children:
                type: "a", title: "View on website", href: "#{event.link}", target: "_blank"},
        ]
    elem =
        type: "div"
        cls: "segment"
        children: [
            {type: "h3", title: "#{event.title}"}
            {type: "pre", cls: "with-wrapping", title: "#{event.msg}"}
            footer
        ]
    _mapper.parseMapForParent(elem)

# function to selecte single element
selectElem = (element, list = null) ->
    # select element / deselect others
    if list
        _util.removeClass(el, "selected") for el in list when el.getAttribute("daction") == "load"
    _util.addClass(element, "selected")
    dtype = element.getAttribute("dtype").toLowerCase()
    if dtype == "rep"
        item = element.getAttribute("dlink")
        _event_api.githubEvent item, ->
            contentHeader.innerHTML = ""
            content.innerHTML = ""
            _util.addClass(content, "loading")
        , (ok, json) ->
            _util.removeClass(content, "loading")
            if ok
                events = _github_parser.parsePayload(json)
                htmlEvents = (eventHtml(event) for event in events)
                holder = type: "div", cls: "segments", children: htmlEvents
                contentHeader.innerHTML = "#{item}"
                _mapper.parseMapForParent(holder, content)
            else
                errorBox = type: "div", cls: "error-box", title: "#{json["message"]} ", children:
                    type: "a", href: "#{json["documentation_url"]}", title: "#{json["documentation_url"]}"
                _mapper.parseMapForParent(errorBox, content)
    if dtype == "rss"
        console.log "RSS feed is not supported"

# if selected index matches current index element will be selected
buildListWithSelected = (selectedIndex) ->
    loadElement = null
    list = menu.getElementsByTagName("*")
    i = 0
    for elem in list
        # delete button
        if elem.getAttribute("daction") == "del"
            _util.addEventListener elem, "click", (e) ->
                itemid = @getAttribute("dkey")
                _api.delete itemid, null, (ok, json) ->
                    location.reload() if ok
                e.stopPropagation()
                e.preventDefault()
        # loading actions
        else if elem.getAttribute("daction") == "load"
            loadElement = elem if i == selectedIndex
            _util.addEventListener elem, "click", (e) -> selectElem(@, list)
            i++
    selectElem(loadElement, list) if loadElement

# build initial list if exists
buildListWithSelected(0)
