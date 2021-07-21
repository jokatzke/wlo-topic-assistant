import cherrypy, json, sys, cherrypy_cors

from topic_assistant import TopicAssistant

a = None

class WebService(object):

   @cherrypy.expose
   @cherrypy.tools.json_out()
   @cherrypy.tools.json_in()
   def topics(self):
      data = cherrypy.request.json
      print (data)
      output = a.go(data["text"])
      return output


if __name__ == '__main__':

   a = TopicAssistant()

   config = {'server.socket_host': '0.0.0.0', 'cors.expose.on': True}
   cherrypy_cors.install()
   cherrypy.config.update(config)
   cherrypy.quickstart(WebService())	