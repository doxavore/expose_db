ExposeDB
========

ExposeDB provides raw, read-only access to your data over an HTTP JSON API.
It uses the excellent [Sinatra][sinatra] and [Sequel][sequel] libraries
for all of the real work.

WARNING: ExposeDB doesn't offer any secure options, and as such is expected
         to be used only in a high-trust network!


ExposeDB consists of both a client and server in one package. The server need
not be used with the client: it simply provides a JSON endpoint. The client
will wrap that JSON endpoint in a very simple [Sequel][sequel]-like API.


But Why?
--------
Ideally, connecting straight to the source database would always be possible.
Since it's not: why.


Server Usage
------------
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


Client Usage
------------
ExposeDB client use isn't required to use the server, but provides a very simple
mapping layer built with [Hashie][hashie]. Use `exposed_as` to define the server's
table name after inheriting from `ExposeDB::Model` and setting your subclass's
`base_uri`. You can `find` and `filter` your models, along with anything that
[HTTParty][httparty] provides.

Since the models are built from a `Hashie::Mash`, you don't need to define
any fields or columns on the client side.

```ruby
require 'expose_db/model'

class BaseModel < ExposeDB::Model
  base_uri 'http://api.example.com/v1'
end

class Person < BaseModel
  exposed_as 'people'

  # Class is inferred from singular of relation name, and foreign key is assumed
  # to be this_class_name_id. Singular inflections are very limited, so you may
  # need to specify class_name here
  has_many :tasks
end

class Task < BaseModel
  exposed_as 'tasks'

  # Assume the returned task has a person_id column and the class_name is Person
  belongs_to :person

  # Provie a wrapper for the underlying string from the ExposeDB server
  def completed_at
    ca = self[:completed_at]
    ca ? Time.parse(ca) : nil
  end
end

bob = Person.find(123)
#=> your person (by column `id`) or raise ExposeDB::RecordNotFound

bob.tasks
#=> find all tasks with person_id = 123

Person.find_by_id(123)
#=> your person (by column `id`) or nil

Person.filter('last_name = ? AND first_name LIKE ?',
              "Saget", "B%")
#=> array of persons with last_name of Saget and first_name starting with B

Task.find(456).person.first_name
#=> Load task with `id` 456, then request Person with `id` (if task.person_id isn't nil)
#   This task's person is cached on the task itself, but there is no identity map
#   so all Task.find(456) calls will call the server again.
```

Implementing your own filter methods are easy:
```ruby
class Task < BaseModel
  exposed_as 'tasks'

  # Assume the returned task has a person_id column and the class_name is Person
  belongs_to :person

  def self.completed_for_person(person)
    filter('person_id = ? AND completed = 1', person.id)
  end

  def self.next_for_person(person)
    # NOTE: Currently, this pulls back ALL the items maching the query and only
    #       then selects the first task
    filter('person_id = ? AND completed = 0', person.id).first
  end
end
```


TODO
----
* Tests
* Smarter relations
  * Has one
  * Offsets and limits
* Other missing common SQL (i.e. Sequel) functionality
* Improve configuration options
  * HTTP Auth and security
  * Alternate output formats/content types
  * Primary keys other than `id`
* Better documentation


Contributing
------------
* Fork this repository
* Make your changes and submit a pull request


License
-------
Copyright (c) 2012 Doug Mayer. Distributed under the MIT License.
See `MIT-LICENSE` for further details.

[hashie]: https://github.com/intridea/hashie
[httpary]: http://johnnunemaker.com/httparty/
[sequel]: http://sequel.rubyforge.org/
[sinatra]: http://sinatra.restafari.org/
