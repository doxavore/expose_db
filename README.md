ExposeDB
========

ExposeDB provides raw, read-only access to your data over an HTTP JSON API.
It uses the excellent [Sinatra][sinatra] and [Sequel][sequel] libraries
for all of the real work.

WARNING: ExposeDB doesn't offer any secure options, and as such is expected
         to be used only in a high-trust network!


Usage
-----
ExposeDB is in a very alpha stage of development, but seems to be doing a
rudimentary job querying for data. Output options are currently limited to
*all* fields in a table and is only exposed via JSON.

    expose-db SEQUEL_DATABASE_URI

For example:

    expose-db postgres://user:password@dbhost/my_db

Existing endpoints:
* `/` - Simple query interface
* `/my_table` - Get all the records in `my_table` as JSON
* `/my_table?q=ENCODED_QUERY&values[]=2&values[]=bob` - replace ?'s in ENCODED_QUERY with [2, 'bob']


TODO
----
* Tests
* Improve configuration options
  * HTTP Auth and security
  * Alternate output formats
* Better documentation


Contributing
------------
* Fork this repository
* Make your changes and submit a pull request


License
-------
Copyright (c) 2012 Doug Mayer. Distributed under the MIT License.
See `MIT-LICENSE` for further details.

[sequel]: http://sequel.rubyforge.org/
[sinatra]: http://sinatra.restafari.org/
