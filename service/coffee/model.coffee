# general event object
class Event
    constructor: (@tpe, @title, @msg, @link, @user, @id) ->

    valid: -> @tpe and @title and @msg and @link and @id

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
            event.id = obj["payload"]["issue"]["number"]
            event.title = obj["payload"]["issue"]["title"]
            event.msg = obj["payload"]["comment"]["body"]
            event.link = obj["payload"]["comment"]["html_url"]
            event.user = obj["actor"]["login"]
        else if obj["type"] == "PullRequestEvent"
            event.tpe = "Pull Request"
            event.id = obj["payload"]["number"]
            event.title = obj["payload"]["pull_request"]["title"]
            event.msg = obj["payload"]["action"]
            event.link = obj["payload"]["pull_request"]["html_url"]
            event.user = obj["actor"]["login"]
        else if obj["type"] == "PullRequestReviewCommentEvent"
            event.tpe = "Pull Request Review Comment"
            event.id = obj["payload"]["pull_request"]["number"]
            event.title = obj["payload"]["pull_request"]["title"]
            event.msg = obj["payload"]["comment"]["body"]
            event.link = obj["payload"]["comment"]["html_url"]
            event.user = obj["actor"]["login"]
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
