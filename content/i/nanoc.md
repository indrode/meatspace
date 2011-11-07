#nanoc-test

Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

<pre><code>
#!ruby
  class TranslationsController < ApplicationController

    def index
      @translations = TRANSLATION_STORE

      @locales = []
      @translations.keys.each do |k|
        locale = k.split('.').first
        @locales << locale unless @locales.include?(locale)
      end
    end

    def create
      I18n.backend.store_translations(params[:locale], {params[:key] => params[:value]}, :escape => false)
      redirect_to translations_url, :notice => "Updated translations."
    end
  end
</code></pre>

