#!/usr/bin/env python

from google.appengine.api import users
from google.appengine.ext.webapp import template
import os, json, webapp2, urllib2, uuid, re
import paths
from src.result import Error, Success
import src.memcachev as memcachev

################################################################
# Item types
################################################################
class RSS(object):
    TYPE = "rss"

    @staticmethod
    def validate(item):
        item = str(item).strip()
        return item if len(item) > 0 else None

class REP(object):
    TYPE = "rep"

    @staticmethod
    def validate(item):
        item = str(item).strip()
        # check repository as "owner/repo" string
        return item if re.match("^\w+/\w+$", item) else None

################################################################
# Application handlers
################################################################
class MainApp(webapp2.RequestHandler):
    def get(self):
        user = users.get_current_user()
        if user:
            # fetch items for the user
            data = memcachev.get_all(user.user_id())
            data = [] if not data else data.items()
            repos = [{"key": k, "type": v["type"], "item": v["item"]} for k, v in data \
                if v["type"] == REP.TYPE]
            rss = [{"key": k, "type": v["type"], "item": v["item"]} for k, v in data \
                if v["type"] == RSS.TYPE]
            # sort lists in increasing order
            repos.sort(lambda x,y: cmp(x["item"], y["item"]))
            rss.sort(lambda x,y: cmp(x["item"], y["item"]))
            # create template values
            template_values = {
                "username": user.nickname(),
                "logouturl": "/logout",
                "repos": repos,
                "rss": rss
            }
            # load template
            path = os.path.join(os.path.dirname(__file__), "service", "index.html")
            self.response.out.write(template.render(path, template_values))
        else:
            self.redirect(users.create_login_url("/"))

class Logout(webapp2.RequestHandler):
    def get(self):
        self.redirect(users.create_logout_url("/"))

class FeedApi(webapp2.RequestHandler):
    def get(self, action):
        self.response.headers["Content-Type"] = "application/json"
        res = Error(500, "Internal error")
        user = users.get_current_user()
        if not user:
            res = Error(401, "Not authenticated")
        elif action == "create":
            tpe = urllib2.unquote(self.request.get("type").strip()).lower()
            item = urllib2.unquote(self.request.get("item").strip())
            if not tpe or not item:
                res = Error(400, "Expected type and item")
            elif tpe != REP.TYPE and tpe != RSS.TYPE:
                res = Error(400, "Invalid type %s" % tpe)
            elif (tpe == REP.TYPE and not REP.validate(item)) or \
                (tpe == RSS.TYPE and not RSS.validate(item)):
                res = Error(400, "Could not process item %s for type %s" % (item, tpe))
            else:
                itemid = uuid.uuid4().hex
                data = {"item": item, "type": tpe}
                memcachev.set(itemid, data, namespace=user.user_id())
                res = Success({"message": "Item %s has been added" % itemid})
        elif action == "delete":
            itemid = urllib2.unquote(self.request.get("itemid").strip())
            if not itemid:
                res = Error(400, "Expected item id")
            else:
                if memcachev.delete(itemid, namespace=user.user_id()):
                    res = Success({"message": "Item has been deleted"})
                else:
                    res = Error(400, "Could not delete key %s" % itemid)
        elif action == "select":
            data = memcachev.get_all(user.user_id())
            res = Success({"items": data})
        else:
            # unknown feed action
            res = Error(400, "Unknown action %s" % action)
        self.response.set_status(res.code())
        self.response.out.write(json.dumps(res.json()))

application = webapp2.WSGIApplication([
    ("/logout", Logout),
    (r"/api/v1/feed/(\w+)", FeedApi),
    ("/.*", MainApp)
], debug=True)
