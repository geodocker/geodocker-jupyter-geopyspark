from oauthenticator.google import LocalGoogleOAuthenticator

class HadoopAuthenticator(LocalGoogleOAuthenticator):
     def normalize_username(self, username):
          return "hadoop"

c = get_config()
c.JupyterHub.log_level = 10
c.JupyterHub.authenticator_class = HadoopAuthenticator
c.LocalGoogleOAuthenticator.create_system_users = False
c.Authenticator.whitelist = whitelist = set()
c.JupyterHub.admin_users = admin = set()
