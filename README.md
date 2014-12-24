asaedit
========

Small sinatra app to add users to a cisco asa firewall over a web interface.

### Deploy
1. have an asa
2. edit the config.json as needed
3. have a server with docker and git
3. `docker build --rm=true --tag="asaedit/deploy" ./`
4. `docker run -d -P asaedit/deploy:latest`
