#!/usr/bin/env coffee

###
This script is used to generate nginx server configurations, in litcoffee just
because I find this kind of task easier here than in shell.
###

{docopt} = require 'docopt'
fs = require 'fs'
path = require 'path'
_ = require 'lodash'
handlebars = require 'handlebars'
pkg = require(path.join(__dirname, "../package.json"))
doc = """
#{pkg.description}

Usage:
  generate servers <infofile>...
  generate -h | --help | --version

Notes:

"""
options = docopt doc, version: pkg.version

if options.servers
  buffer = []
  for infofile in options['<infofile>']
    try
      content = JSON.parse(String(fs.readFileSync(infofile)))
      buffer.push content
    catch e
      console.error e
  template = """
  {{#each .}}
    location {{url}} {
      # Path rewriting to hide mount prefix
      rewrite {{url}}(.*) /$1 break;
      proxy_pass http://{{containerIP}}:{{containerPort}};
      add_header X-CODE-SHA {{sha}};
      add_header X-CONTAINER {{container}};
      add_header X-SHIP {{hostname}};
      # WebSocket support (nginx 1.4)
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";

      proxy_redirect off;
    }
  {{/each}}
  """
  console.log handlebars.compile(template)(buffer)