---
title: An API wrapper in Ruby with HTTParty and Fakeweb
created_at: 15.11.2011
kind: article
---

#An API wrapper in Ruby with HTTParty and Fakeweb

This is a quick tutorial on writing a fully-tested API wrapper in Ruby. As example, I am taking [zimdb](https://github.com/indrode/zimdb), a small gem that I developed the other day. First, I'll cover the (test-driven) implementation of the functionality. To top it off, I'll quickly touch the process of creating a gem that can be used by other developers.

##What does ZIMDb do?

**ZIMDb** is a wrapper for [imdbapi.com](http://www.imdbapi.com/), a service that provides content from the vast movie database [IMDB](http://www.imdb.com/) which I am sure everyone has heard of. IMDb doesn't provide its own open API to developers, so in order to access information, we'll have to resort to 3rd party providers. Right now, ZIMDb only fetches information about a single movie and the only way to access information for a specific movie is to search for it by its title. For the scope of this article, that should be all we need.

##A simple approach

The imdbapi.com "API" (it's basically just one call) is very straight-forward. Still, it's always good to have a general idea of what we want to do, before daftly jumping into the code. Here are the different steps of this approach: 

1. trigger a sample call and examine the result
2. define what we want to fetch (via tests)
3. implement it!
4. transform it into a gem (we may start doing that earlier in the process)

###1. The Call

[imdbapi.com](http://www.imdbapi.com/) provides a nice web interface to make sample calls. It is also very convenient that responses are nicely packed in JSON. For now, we'll just search for movies by title, but we could additionally allow searching movies by IMDb-ID and year. Here is how a sample response looks like:

<pre><code>
#!json
{"Title":"The Godfather","Year":"1972","Rated":"R","Released":"24 Mar 1972","Genre":"Crime, Drama","Director":"Francis Ford Coppola","Writer":"Mario Puzo, Mario Puzo","Actors":"Marlon Brando, Al Pacino, James Caan, Diane Keaton","Plot":"The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.","Poster":"http://ia.media-imdb.com/images/M/MV5BMTIyMTIxNjI5NF5BMl5BanBnXkFtZTcwNzQzNDM5MQ@@._V1._SX320.jpg","Runtime":"2 hrs 55 mins","Rating":"9.2","Votes":"436305","ID":"tt0068646","Response":"True"}
</code></pre>

For our API wrapper, we would like to fetch some of these movie attributes. So let's fire up your favorite text editor and create a new file. We'll create a new folder and some subfolders too while we're at it.

<pre><code>
#!sql
mkdir zimdb
cd zimdb
mkdir lib
mkdir spec
mate spec/movie_spec.rb
</code></pre>

###2. A first test

We will use `rspec` to test our gem, so make sure it is installed (`gem install rspec`). In `movie_spec.rb`, we can now add a first test for a very common task we want the gem to achieve.

<pre><code>
#!ruby
describe "zimdb" do
  it "should fetch a movie title" do
    movie = Zimdb::Movie.new(:title => "Godfather")
    movie.title.should == "The Godfather"
  end
end
</code></pre>

This already does more than one step at once, but I will keep this tutorial rather brief, so let's run these tests with `rspec spec/movie_spec.rb` and see what's happening.

<pre><code>
#!sql
F

Failures:

  1) zimdb should fetch a movie title
     Failure/Error: movie = Zimdb::Movie.new(:title => "Godfather")
     NameError:
       uninitialized constant Zimdb
     # ./spec/movie_spec.rb:5:in `block (2 levels) in &lt;top (required)&gt;'

Finished in 0.47559 seconds
1 example, 1 failure

Failed examples:

rspec ./spec/movie_spec.rb:4 # zimdb should fetch a movie title
</code></pre>

Nothing unexpected here, considering that we haven't written a single line of actual code. In our test, we already made a couple of assumptions. First, we want to create a module called `Zimdb` because we want to pack it into a gem later. Then, we need a class `Movie` which can be instantiated by passing it the param `:title`. Maybe, at some later point in time, we'll also want to fetch movies via the IMDb-ID, which is why we are passing the movie title via the `:title` symbol. Finally, we have a `title` method for each Movie object that returns the movie's title.

###3. Some more tests

Because we wanted to define the attributes we wanted to fetch (for the sake of brevity, let's just get a few of them), let's add these to our spec file as well. We will still implement them one by one. Since we are aways instantiating a new movie object, we'll put that into a `before(:each)` block. Here is our movie_spec.rb:

<pre><code>
#!ruby
describe "zimdb" do
  before(:each) do
    @movie = Zimdb::Movie.new(:title => "Godfather")
  end
  
  it "should return the title" do
    @movie.title.should == "The Godfather"
  end
  
  it "should return the year" do
    @movie.year.should == 1972
  end
  
  it "should return the rating" do
    @movie.rated.should == "R"
  end
end
</code></pre>

###4. Setting up the Gem with Bundler

Okay, now let's get going and start to code? Not quite yet. Since we want to create a new gem anyway, why not set it up now, so we can start developing in the right places and don't have to move too many files around later. We will use `Bundler` to set up our gem.

<pre><code>
#!ruby
bundle gem zimdb
</code></pre>

Run this from the level below the `/zimdb` folder and it will create a couple of useful files, such as the gemspec file `zimdb.gemspec`. There are various tutorials on the web on how to customize this gemspec file, therefore I will make this short. We only need to add two dependencies apart from rspec: `httparty` (for runtime) and `fakeweb` (for development). More on these in a second.

<pre><code>
#!ruby
s.add_runtime_dependency "httparty"
s.add_development_dependency "rspec", "~> 2.6"
s.add_development_dependency "fakeweb", "~> 1.3"
</code></pre>

We can also use this moment to setup a `spec_helper.rb` to use for testing (we will need it later). In `/spec` we create that file and add some code to it:

<pre><code>
#!ruby
require 'bundler/setup'
require 'zimdb'
require 'fakeweb'

RSpec.configure do |config|
  # we'll add more here later
end
</code></pre>

In our `movie_spec.rb` we can now `require 'spec_helper'`.

###5. Fakeweb

In our final code, we will make calls to imdbapi.com, but we don't want to do that during testing. To fake these web requests, we will take advantage of a neat little gem called `fakeweb` (see [https://github.com/chrisk/fakeweb](https://github.com/chrisk/fakeweb)). Let's just drop the response we got earlier and drop it into `spec/fixtures`. For testing purposes, we will read the contents of that file, whenever a test tries to make such a request. Still in `spec_helper.rb` we can add the following code to the RSpec configure-block:

<pre><code>
#!ruby
FakeWeb.allow_net_connect = false

RSpec.configure do |config|
  def fixture(filename)
    File.dirname(__FILE__) + '/fixtures/' + filename
  end
  
  FakeWeb.register_uri(:get, "http://www.imdbapi.com/?t=Godfather", 
                       :body => open(fixture("godfather.json")))
end
</code></pre>
  
This assumed that we called the file `godfather.json`. Any tests with web requests that are not registered for fakeweb will still be made. To prevent our test suite communicating with the web, we add `FakeWeb.allow_net_connect = false`.

###6. HTTParty

Now that we have set up everything we need, we can finally start coding. There isn't really too much to do thanks to the great `httparty` gem (see [https://github.com/jnunemaker/httparty](https://github.com/jnunemaker/httparty)).

But first let's see where we want to put our code. In `lib/zimdb.rb` we will have to require some dependencies and include httparty while we're at it to make it available to all the classes which we define under `lib/zimdb/`. In our example, we only have the `Movie` class, but it's still a good idea to separate the files. This leaves us with a very simple zimdb.rb:

<pre><code>
#!ruby
require "httparty"
require "json"
require "zimdb/movie"

module Zimdb
  include HTTParty
end
</code></pre>

Note, that you [should not require rubygems](http://tomayko.com/writings/require-rubygems-antipattern). Now on to `lib/zimdb/movie.rb`:

<pre><code>
#!ruby
module Zimdb
  class Movie
    def initialize(params)
      @json = JSON.parse(HTTParty.get("http://www.imdbapi.com/?t=#{params[:title]}"))
    end
  end
end
</code></pre>

It really couldn't be much simpler. We now have `@json`, which is a hash of the response of our call. This won't make our tests pass, so let's add a method to get the movie title:

<pre><code>
#!ruby
def title
  @json["Title"]
end
</code></pre>

Running the tests now yields the following output:

<pre><code>
#!sql
.FF

Failures:

  1) zimdb should return the year
     Failure/Error: @movie.year.should == 2009
     NoMethodError:
       undefined method `year' for #&lt;Zimdb::Movie:0x007fe204aa8a50&gt;
     # ./spec/movie_spec.rb:30:in `block (2 levels) in &lt;top (required)&gt;'

  2) zimdb should return the rating
     Failure/Error: @movie.rated.should == "R"
     NoMethodError:
       undefined method `rated' for #&lt;Zimdb::Movie:0x007fe203901108&gt;
     # ./spec/movie_spec.rb:34:in `block (2 levels) in &lt;top (required)&gt;'

Finished in 1.21 seconds
3 examples, 2 failures

Failed examples:

rspec ./spec/movie_spec.rb:29 # zimdb should return the year
rspec ./spec/movie_spec.rb:33 # zimdb should return the rating
</code></pre>

Looking good! One test already passed.

###7. Making all tests pass

We can make the other two tests pass by simply adding the corresponding methods.

<pre><code>
#!ruby
def year
  @json["Year"].to_i
end

def rated
  @json["Rated"]
end
</code></pre>

All the tests pass! However, I do not like `@json["Year"]`. In my opinion, something like `@json[:year]` looks a lot cleaner and opens up more possibilities. While we would normally just implement the least amount of code to make all the tests pass, I do want to add a little method to `Hash` that creates these symbolized keys. Let's call it `symbolize_keys` and write a test in `spec/hash_spec.rb`:

<pre><code>
#!ruby
require 'spec_helper'

describe Hash do
  it "should symbolize keys" do
    my_hash = { "Title" => "The Hangover", "Year" => "2009" }
    my_hash.symbolize_keys
    my_hash.should == { :title => "The Hangover",
                        :year => "2009" }
  end
end
</code></pre>

Basically, we have a hash with ugly strings as keys and want to transform those keys into nice Ruby-esque symbols by calling `symbolize_keys` on that hash. To do this, we extend the `Hash` class (in `lib/zimdb/hash.rb`) and implement this behavior:

<pre><code>
#!ruby
class Hash
  def symbolize_keys
    hash = self.dup
    self.clear
    hash.each_pair{|k, v| self[k.downcase.to_sym] = v}
    self
  end
end
</code></pre>

We require this in `lib/zimdb.rb` and add it to our Movie class:

<pre><code>
#!ruby
@json = JSON.parse(HTTParty.get("http://www.imdbapi.com/?t=#{params[:title]}")).symbolize_keys
</code></pre>

Now we can rewrite our methods as follows:

<pre><code>
#!ruby
def year
  @json[:year].to_i
end
</code></pre>

###8. And where is the gem?

Our code is implemented and our tests are passing. The next step would be to package it all into a gem using the `gem` command-line tools. Read more about this in the [rubygems documentation](http://docs.rubygems.org/read/book/2). It would be wise to create a sample Ruby app that uses the gem, for example querying the user for a movie title and then spitting out some information about that movie. Or, we could just test it in the Ruby shell. Of course, adding the remaining attributes and handling empty responses (what happens when our movie wasn't found?) should be taken care of as well.

Just for reference, this is how we would build and push the gem to `rubygems`:

<pre><code>
#!sql
gem build zimdb.gemspec
gem push zimdb-0.0.1.gem
</code></pre>

To view the current state of the actual ZIMDb gem, check it out on [GitHub](https://github.com/indrode/zimdb) or browse the [documentation](http://rubydoc.info/gems/zimdb/0.0.1/frames). As always, install it the old-fashioned way:

<pre><code>
#!sql
gem install zimdb
</code></pre>

You may also dump it into your `Gemfile` if you are using Bundler.

<pre><code>
#!sql
gem "zimdb", "~> 0.0.1"
</code></pre>
