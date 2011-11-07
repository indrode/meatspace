#Creating Meatspace with nanoc

Meatspace is a nanoc-powered static blog that displays Markdown-formatted content and is pushed to a web server via rsync. The following is a quick tutorial and reference on the nanoc installation and usage workflow.

##Install

All important nanoc generators and commands can be triggered via the command line, so we launch our favorite terminal emulator and start off by installing some required gems for our implementation of nanoc.

<pre><code>
#!sql
gem install nanoc
gem instal asdf
gem install kramdown
gem install coderay
</code></pre>

Next up, we will set up the scaffold of the nanoc site.

<pre><code>
#!sql
nanoc create_site meatspace
</code></pre>

If you wish, you could create a new GitHub repository for the nanoc site. Although, unlike a Jekyll site, which can be updated via a simple `git push`, this would be just for general version control. If you do, initialize the git repository in the `meatspace` folder, add the generated files and folders, commit, and push this first commit to master.

<pre><code>
#!sql
cd meatspace
nanoc compile
</code></pre>

The last command compiles the site. Repeat this step after you made changes and are ready to deploy or if you want to view the current state of your site in your browser. For the latter, we start a WEBrick server in order to view the site under `http://localhost:3000/`:

<pre><code>
#!sql
nanoc view
</code></pre>

Your most basic nanoc setup is now complete! Before we continue to hack around with nanoc items, layout, and rules, we want to deploy what we have to a remote web server. The nanoc way to do this is via a rake task that calls rsync for lightning-fast deploys.


##Deploy

Just add block to the config.yml in the root of your site, where destination is the location on your remote web server:

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

I keep the thor script outside of revision control. Now that we know how to locally view our site and how to quickly deploy any changes to production, we can start configuring and customizing.

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


Meatspace uses [Foundation](http://foundation.zurb.com/), a boilerplate framework, so I replaced the existing layout and styles. I also added a coderay-sepcific stylesheet. You can view the [entire source on GitHub](https://github.com/indrode/meatspace).

