# general event object
class Event
    constructor: (@tpe=null, @title=null, @msg=null, @link=null, @user=null) ->

    valid: -> @tpe and @title and @msg and @link

    hasUser: -> @user != null

class Parser
    constructor: (@tpe) ->

    # rules for processing an json/xml object that encapsulates event
    parseObject: (obj) ->

    # rules for processing batch of events (how it will come as a response)
    parsePayload: (data) ->

class GithubApiParser extends Parser
    constructor: -> @tpe = "GithubApiParser"

    parseObject: (obj) ->
        unless obj
            console.log "[ERROR] Object is undefined"
            return null
        # resolve event
        event = new Event
        if obj["type"] == "IssueCommentEvent"
            event.tpe = "Issue Comment"
            event.title = obj["payload"]["issue"]["title"]
            event.msg = obj["payload"]["comment"]["body"]
            event.link = obj["payload"]["comment"]["html_url"]
            event.user = obj["payload"]["comment"]["user"]["login"]
        else if obj["type"] == "PullRequestEvent"
            event.tpe = "Pull Request"
            event.title = obj["payload"]["pull_request"]["title"]
            event.msg = obj["payload"]["action"]
            event.link = obj["payload"]["pull_request"]["html_url"]
            event.user = obj["payload"]["pull_request"]["user"]["login"]
        else if obj["type"] == "PullRequestReviewCommentEvent"
            event.tpe = "Pull Request Review Comment"
            event.title = obj["payload"]["pull_request"]["title"]
            event.msg = obj["payload"]["comment"]["body"]
            event.link = obj["payload"]["comment"]["html_url"]
            event.user = obj["payload"]["comment"]["user"]["login"]
        else
            console.log "[WARN] Unknown event for object", obj
        return event

    parsePayload: (data) ->
        unless data
            console.log "[ERROR] data is undefined"
            return []
        events = (@parseObject(elem) for elem in data)
        event for event in events when event isnt null and event.valid()

@GithubApiParser ?= GithubApiParser
