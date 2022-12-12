# MkDocs Webhook

## Quickstart

1. Build the image

~~~BASH
docker build -t docs .
~~~

2. Run the image

~~~BASH
docker run -it  -e REPOSITORY=REPOSITORY_URL -p "80:80" -p "9000:9000"  docs
~~~

where 

 * REPOSITORY_URL  must be a link to a Github repository (e.g: https://github.com/deNBI/cloud-user-docs). 
   The GitHub repository must have at its root a config yaml for describing the setup. See https://github.com/deNBI/cloud-user-docs.git as an example.

3. You can now open  "localhost/wiki" in your browser and send request to localhost:9000/wiki/hooks/update to update the pages

### Parameters

* You can modify the webhook url prefix by changing the environment variable (**WEBHOOK_URL_PREFIX**):

## Production

1. Replace hooks.json in order to set the correct hook (e.g.: GitHub webhooks) with the command:

~~~BASH
docker run -it -e WEBHOOK_URL_PREFIX=<WEBHOOK_URL_PREFIX> -v "$(pwd)/config:/usr/local/bin" -e REPOSITORY=REPOSITORY_URL -p "80:80" -p "9000:9000"  docs
~~~

where

 * **WEBHOOK_URLPREFIX**: is an optional parameter to update the webhook url prefix.

 * config is a folder with the **hooks.json** file.

2. (Optional) You can change the theme in the config yaml.

You can use the SITE_URL environment variable to set a specific URL if you want to override the default of the mkdocs configuration.
To do this, specify another variable in the command above:

~~~BASH
 -e SITE_URL=SITE_URL
~~~
