---
title: Creating static sites with nanoc
created_at: 07.11.2011
kind: article
---

#Creating static sites with nanoc

Meatspace is a nanoc-powered static website that displays Markdown- and CodeRay-formatted content. The following is a quick tutorial and reference on the nanoc installation process and usage workflow. Nanoc is light-weight, flexible, and completely written in Ruby, which we all love. To find out more, check out [the nanoc website](http://nanoc.stoneship.org/).

##Install

All important nanoc generators and commands can be triggered via the command line, so we launch our favorite terminal emulator and start off by installing some required gems for our implementation of nanoc.

<pre><code>
#!sql
gem install nanoc
gem install asdf
gem install kramdown
gem install coderay
</code></pre>

Next up, we will set up a basic scaffold of the nanoc site.

<pre><code>
#!sql
# creates new nanoc site
nanoc create_site meatspace
</code></pre>

If you wish, you could create a new GitHub repository for the nanoc site. Although, unlike Jekyll sites, which can be updated via a simple `git push` if used as GitHub Pages, this would be just for general revision control. If you do, initialize the git repository in the `meatspace` folder, add the generated files and folders, commit, and push this first commit to master.

<pre><code>
#!sql
cd meatspace
nanoc compile
</code></pre>

The last command compiles the site (the shortcut is `nanoc co`). Repeat this step after you made changes and are ready to deploy or if you want to view the current state of your site in your browser. For the latter, we start a WEBrick server in order to view the site under `http://localhost:3000/`.

<pre><code>
#!sql
# starts server on localhost:3000
nanoc view
</code></pre>

Your most basic nanoc setup is now complete! Before we continue to hack around with nanoc items, layouts, and rules, we want to deploy what we have to a remote web server. The nanoc way to do this is via a rake task that calls rsync for lightning-fast deploys.

##Deploy

Just add this block to the `config.yml` in the root of your site, where `dst` is the location on your remote web server.

<pre><code>
#!ruby
deploy:
  default:
    dst: "indrode.com:/home/bandito/meatspace"
</code></pre>

ss64's rsync page [http://ss64.com/bash/rsync.html](http://ss64.com/bash/rsync.html) tells you all the different options to set up the rsync connection, and much more. The rake task to deploy is:

<pre><code>
#!sql
rake deploy:rsync
</code></pre>

For Meatspace, I am using a different approach because of some customized server security configurations. Also, I want to deploy to different environments (staging, production) so instead of rsync, a simple secure copy triggered by a [Thor script](https://github.com/wycats/thor) gets the nanoc deployed just as fast:

<pre><code>
#!sql
thor nanoc:deploy staging
</code></pre>

I do keep the Thor script outside of revision control as it includes some server specific configurations. Now that we know how to locally view our site and how to quickly deploy any changes to production, we can start configuring and customizing.

##Customize

The nanoc documenation is pretty good ([http://nanoc.stoneship.org/docs/3-getting-started/](http://nanoc.stoneship.org/docs/3-getting-started/)), so this will just cover some reminders and notes.

<pre><code>
#!sql
# creating a new static page
nanoc create_item about
</code></pre>

I want to use Markdown to write my pages (at least the articles), so nanoc will have to know that certain item types should go through the `kramdown` filter. On top of that, I want to be able to highlight any source code that I may include in an article using `coderay`. All these configurations are called rules and exist in the `Rules` file.

<pre><code>
#!ruby
compile '/i/*' do
  filter :kramdown
  filter :colorize_syntax,
         :colorizers => { :ruby => :coderay }
  layout 'default'
end
</code></pre>

The `compile` blocks specify how items are processed. The `route` blocks set all the necessary routing settings. All in all, a lot of the concepts and implementations look very familiar if you know your way around Ruby and some Ruby-based frameworks.

Meatspace uses [Foundation](http://foundation.zurb.com/), a boilerplate framework, so I replaced the existing layout and styles. I also added a CodeRay-specific stylesheet. Nanoc is perfect for websites with static pages, but it can easily work as a blog or really anything else you throw at it. For example, displaying all blog entries on one page would achieved through a simple Ruby enumeration:

<pre><code>
#!haml
- @site.sorted_articles.each |article| do
  %p= article.compiled_content
  %p
    = "Written on #{article[:created_at]}."
    %a{:href => article.path} Permalink
</code></pre>

The above code snippet is in Haml, but you can easily use ERB instead. Just specify in the compile filters of the `Rules` file, how you want to process your code.

I will cut this short by, once again, referring to the very nice write-up on the [nanoc homepage](http://nanoc.stoneship.org/docs/1-introduction/). You can also view the [entire source of Meatspace on GitHub](https://github.com/indrode/meatspace).

