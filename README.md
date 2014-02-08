Bot Handler
====

Getting started
---

Install PhantomJS 1.9+

```bash
git clone git@github.com:t-k/bot_handler.git

phantomjs app.js
# Or run in production(load ./config/production.json)
PHANTOM_ENV=production phantomjs app.js
```

Nginx configuration
---

for example

```nginx
    location / {
        # "bot|spider" for usual bots
        # "facebook" for facebook
        # "Google" for Google+
        if ($http_user_agent ~* bot|spider|facebook|Google)  {
            proxy_pass http://bot_proxy;
            break;
        }
        proxy_pass http://app_server;
    }
```