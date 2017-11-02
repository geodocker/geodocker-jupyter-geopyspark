from oauthenticator.github import LocalGitHubOAuthenticator

class HadoopAuthenticator(LocalGitHubOAuthenticator):
     def normalize_username(self, username):
          return "hadoop"

c = get_config()
c.JupyterHub.log_level = 10
c.JupyterHub.authenticator_class = HadoopAuthenticator
c.LocalGitHubOAuthenticator.create_system_users = False
c.Authenticator.whitelist = whitelist = set()
c.JupyterHub.admin_users = admin = set()
