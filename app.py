#!/usr/bin/env python

from google.appengine.api import users
from google.appengine.ext.webapp import template
import os, json, webapp2
import paths

class MainApp(webapp2.RequestHandler):
    def get(self):
        user = users.get_current_user()
        if user:
            # create template values
            template_values = {
                "username": user.nickname(),
                "logouturl": "/logout"
            }
            # load template
            path = os.path.join(os.path.dirname(__file__), "service", "index.html")
            self.response.out.write(template.render(path, template_values))
        else:
            self.redirect(users.create_login_url("/"))

class Logout(webapp2.RequestHandler):
    def get(self):
        self.redirect(users.create_logout_url("/"))

application = webapp2.WSGIApplication([
    ("/logout", Logout),
    ("/.*", MainApp)
], debug=True)
