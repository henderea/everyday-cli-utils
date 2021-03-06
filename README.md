# EverydayCliUtils

[![Gem Version](https://badge.fury.io/rb/everyday-cli-utils.svg)](http://badge.fury.io/rb/everyday-cli-utils)
[![Build Status](https://travis-ci.org/henderea/everyday-cli-utils.svg?branch=master)](https://travis-ci.org/henderea/everyday-cli-utils)
[![Dependency Status](https://gemnasium.com/henderea/everyday-cli-utils.svg)](https://gemnasium.com/henderea/everyday-cli-utils)
[![Code Climate](https://codeclimate.com/github/henderea/everyday-cli-utils/badges/gpa.svg)](https://codeclimate.com/github/henderea/everyday-cli-utils)
[![Test Coverage](https://codeclimate.com/github/henderea/everyday-cli-utils/badges/coverage.svg)](https://codeclimate.com/github/henderea/everyday-cli-utils)

A few CLI and general utilities.  Includes a numbered-menu select loop utility, a ANSI formatting escape code handler, a text-based histogram maker, k-means and n-means (k-means with minimum optimal k) calculators, various collection utility methods, and a utility for using OptionParser with less code.

Note: The curses utility has been moved to the `everyday-curses` gem

## Installation

Add this line to your application's Gemfile:

    gem 'everyday-cli-utils'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install everyday-cli-utils

## Usage

Because there are several different utilities in this gem, I have included a convenience method for including more than one in a single line

```ruby
require 'everyday-cli-utils'
include EverydayCliUtils
import :format, :option
```

You can also use `EverydayCliUtils::import :format, :option` if you don't want to include the module.

The possible values to pass to `import` are:

* `:ask`
* `:format`
* `:format_safe`
* `:histogram`
* `:histogram_safe`
* `:kmeans`
* `:kmeans_safe`
* `:maputil`
* `:maputil_safe`
* `:mycurses`
* `:option`

Some of the utilities normally modify built-in classes, like `String` and `Enumerable`.  For utilities that do this, I have included a "safe" version that does not modify the built-in classes.

Here are the utilities:

###EverydayCliUtils::Ask
Encapsulates the methods for prompting the user to select from a set of options.

####Ask::ask(question, options, &block)
Prompts the user to select from a set of options.  It calls `block` with the option selected.  It is designed to take an array of symbols for the `options` parameter and will return the symbol selected rather than the index selected.

######Parameters
* `question`: The question to show at the beginning of the prompt
* `options`: The array of options.  These are automatically numbered from `1` to `options.count`.  It is intended to be an array of symbols, but that is not required.
* `&block`: The block to call with the result of the prompting.  It takes a single parameter which is the option selected (the value, not the index).

####Ask::hash\_to\_options(hash, extra = [])
Take the keys of a hash and return them as an array and optionally include some extra options at the end of the array.

######Parameters
* `hash`: The hash that uses the desired options as keys
* `extra` [optional]: The options to add on to the end of the array of options

###EverydayCliUtils::Format

Encapsulates the methods for formatting command-line output.

####Colors:
* `:black`
* `:red`
* `:green`
* `:yellow`
* `:blue`
* `:purple`
* `:cyan`
* `:white`
* `:none`

####Format::colorize(text, fgcolor = nil, bgcolor = nil)
Apply colors to the text using ANSI escape sequences

######Parameters
* `text`: The text to format
* `fgcolor` [optional]: The foreground color to use for the text (you probably shouldn't leave this out)
* `bgcolor` [optional]: The background color to use for the text

####Format::bold(text, fgcolor = nil, bgcolor = nil)
Bold the text and optionally apply colors to it

######Parameters
* `text`: The text to format
* `fgcolor` [optional]: The foreground color to use for the text
* `bgcolor` [optional]: The background color to use for the text

####Format::underline(text, fgcolor = nil, bgcolor = nil)
Underline the text and optionally apply colors to it

######Parameters
* `text`: The text to format
* `fgcolor` [optional]: The foreground color to use for the text
* `bgcolor` [optional]: The background color to use for the text

####Format::boldunderline(text, fgcolor = nil, bgcolor = nil)
Bold and underline the text and optionally apply colors to it

######Parameters
* `text`: The text to format
* `fgcolor` [optional]: The foreground color to use for the text
* `bgcolor` [optional]: The background color to use for the text

####Modification to String class:
NOTE importing `:format_safe` will prevent these changes

`EverydayCliUtils::Format` modifies the `method_missing` and `respond_to?` methods of the `String` class.  This is to add convenience methods to String that allow formatting by using a special method naming style.  The regex is


```ruby
colors = 'black|red|green|yellow|blue|purple|cyan|white|none'
/format(_bold)?(_underline)?(?:_fg_(#{colors}))?(?:_bg_(#{colors}))?/
```

Here is an example:


```ruby
'hi'.format_bold_underline_fg_yellow_bg_green
```

This will return a string that uses ANSI escape sequences to make the word 'hi' bold and underlined, with a foreground color of yellow and a background color of green.  You can use any color and make any format supported by the `EverydayCliUtils::Format` module.  All 4 parts of the method (not counting the required `format` start) are optional, so you can do something like `'hi'.format_underline_bg_white`, but you have to keep the same order, so you can't do `'hi'.format_underline_bold_bg_white_fg_black`.

As of version 0.4.0, there is now a `String#format_all` method that will allow you to put formatting in the string instead of having to call methods in the middle of a string.  Here is an example:

```ruby
'abc {def}(bdulfywbgr) ghi {jkl}(ulfyw) mno'.format_all
```

which is equivalent to
```ruby
"abc #{'def'.format_bold_underline_fg_yellow_bg_green} ghi #{'jkl'.format_underline_fg_yellow} mno"
```

Much shorter, right?

There is also a static version of the method in `EverydayCliUtils::Format` that takes the string as a parameter, for those of you that use the "safe" version.

Here's the two-letter color keys:

```ruby
{
  'bk' => :black,
  'rd' => :red,
  'gr' => :green,
  'yw' => :yellow,
  'bl' => :blue,
  'pu' => :purple,
  'cy' => :cyan,
  'wh' => :white,
  'no' => :none
}
```

As of version 0.5.0, there is now a `String#mycenter` method that takes a length and an optional character (defaults to `' '`) and centers the string using that character and length.  This is designed to mimic the built-in `String#center` method, but add support for handling the formatting, since formatting is done by adding non-printing characters to the string.  If you were to use the built-in `center` method, you would be adding too little padding.

There is also a static version of the method in `EverydayCliUtils::Format` that takes the string as a parameter, for those of you that use the "safe" version.

As of version 1.2.0, there is now support for using color profiles in `String#format_all`.  Here's an example:

```ruby
EverydayCliUtils::Format.color_profile(:p1, bold: true, underline: true, fgcolor: :yellow, bgcolor: :green)
EverydayCliUtils::Format.color_profile(:p2, underline: true, fgcolor: :yellow)
'abc {def}(:p1) ghi {jkl}(:p2) mno'.format_all
```

This gives the same result as the earlier example.  With color profiles, you define it once and can use it as many times as you want.  So if you have an application that lets the user choose colors for certain things, you can define a color profile with the chosen colors once and re-use it as many times as you want.

Please note that if you define a second color profile with the same id, it will overwrite the first one.

###EverydayCliUtils::Histogram

Create a text-based histogram.  This is an extension to the `Enumerable` module, unless you import `:histogram_safe`, in which case you can use the static methods in `EverydayCliUtils::Histogram`, with an added first parameter of the collection.

####Enumerable.histogram(ks = nil, width = 100, height = 50)
Create a histogram on the `Enumerable` data

######Parameters
* `ks` [optional]: The array of averages (probably obtained from `kmeans` or `nmeans`).  If provided, an extra row will be added to the bottom that will display the averages as vertical bars at the correct positions along the axis.
* `width` [optional]: The width (in characters) of the histogram.
* `height` [optional]: The height (in lines) of the histogram.  This does not include the row added by the `ks` parameter.

###EverydayCliUtils::Kmeans

Extends the `Enumerable` module with k-means and n-means functionality, unless you import `:kmeans_safe`, in which case you can use the static methods in `EverydayCliUtils::Kmeans` with an added first parameter of the collection.

####Enumerable.outliers(sensitivity = 0.5, k = nil)
Returns an array of the outliers in the `Enumerable` data.

######Parameters
* `sensitivity` [optional]: The sensitivity level to use when determining if a piece of data is an outlier.  It is compared with the probability of that location on the normal curve multiplied by the number of data pieces in the cluster
* `k` [optional]: The number of averages to use.  If provided, it will run k-means on the data to get the averages it uses.  If omitted, it will use n-means on the data.

####Enumerable.nmeans(max_k = 10, threshold = 0.05)
Run n-means (k-means with minimum optimal k) on the `Enumerable` data.

######Parameters
* `max_k` [optional]: The maximum k value to try.
* `threshold` [optional]: The threshold used to determine if there is not enough benefit to increasing k by 1.

####Enumerable.kmeans(k)
Run k-means on the `Enumerable` data.

######Parameters
* `k`: The number of averages for the k-means algorithm

####Enumerable.get_clusters(means)
Gets the clusters in the `Enumerable` data based on which mean each data point is closest to.

######Parameters
* `means`: The means that the clusters are based on.

###EverydayCliUtils::MapUtil

Extends the `Enumerable` module with some utility methods, unless you import `:maputil_safe`, in which case you can use the static methods in `EverydayCliUtils::MapUtil` with an added first parameter of the collection.

####Enumerable.removefalse
Return the data without the values that are false.

####Enumerable.filtermap(&block)
Return the mapped data with the false values removed.

######Parameters
* `&block`: The block to use for the mapping.  Returning `false` will cause the element to be removed.

####Enumerable.sum
Return the sum of the data.

####Enumerable.prod
Return the product of the data.

####Enumerable.average
Return the average of the data.

####Enumerable.std_dev
Return the standard deviation of the data.

####Enumerable.summap(&block)
Return the sum of the mapped data.

######Parameters
* `&block`: The block to use for the mapping.

####Enumerable.productmap(&block)
Return the product of the mapped data.

######Parameters
* `&block`: The block to use for the mapping.

####Enumerable.chompall
Return the data with `chomp` called on all the elements.

####Enumerable.join(join_str)
Return the data joined into a single string with `join_str` in between the elements.

######Parameters
* `join_str`: The string to use for joining the elements together.

####Hash.expand
Takes a shorthand hash (like `{ [:a, :b, :c, :d] => '1-4', e: '5' }`) and turns it into a full hash (like `{ a: '1-4', b: '1-4', c: '1-4', d: '1-4', :e => '5' }`)

###EverydayCliUtils::Option

Some utility methods for the `OptionParser` class.

####Option::add\_option(options, opts, names, opt_name, settings = {})
Add a boolean option to the `OptionParser`.

######Parameters
* `options`: the hash of options
* `opts`: the `OptionParser` object
* `names`: the names of the options as an array (including leading hyphens)
* `opt_name`: the name of the option (usually a symbol)
* `settings`: additional optional options
    * `toggle: true|false`: true to make it toggle the value in the options hash, false or omitted to just set it to true

####Option::add\_option\_with\_param(options, opts, names, opt_name, settings = {})
Add a parameterized option to the `OptionParser`.  It will set the specified option to the entered value if the option appears in the command.  At least one of the names needs to have the parameter specified.  You can pass over a block to have run after the value is set when parsing options.

######Parameters
* `options`: the hash of options
* `opts`: the `OptionParser` object
* `names`: the names of the options as an array (including leading hyphens; at least one element needs to have the parameter specified)
* `opt_name`: the name of the option (usually a symbol)
* `settings`: additional optional options
    * `type: <data type>`: specify a type (such as `Integer` or `Float`) for the option parser to try to parse the parameter to (default is `String` (no parsing))
    * `append: true|false`: true to append the parameter to a list (for parameterized options that can occur multiple times), false or omitted to just set it to the parameter
    
### EverydayCliUtils::OptionUtil

As of version 0.6.0, there is a new way to use the option package.  See the below example:

```ruby
class MyOptions
  extend EverydayCliUtil::OptionUtil
  
  banner 'test app' # <-- version 1.0.0 and up
  
  defaults_option 'defaults.yaml', ['-d', '--set-defaults'] # <-- version 0.7.0 and up
  
  help_option ['-h', '--help'], desc: 'display this help' # <-- version 1.0.0 and up
  
  option :opt1, ['-1', '--opt-1']
  option_with_param :opt2, ['-2', '--opt-2 PARAM']
end

MyOptions.parse!

opts = MyOptions.options
```

The two methods shown above are the same as the ones in `EverydayCliUtils::Option`, but renamed to be shorter, and with the `opt_name` and `names` parameters switched around.  Also, the options hash and `OptionParser` instance are handled internally, so you don't have to pass those in.  There are read-only accessors for both of them.

Besides the different look, there are also improvements.  `EverydayCliUtils::OptionUtil.default_settings(settings = {})` is a new method that you can use to set the default values of the settings that you can pass to `option` and `option_with_param`.  Also, since this utility manages the options hash for you, in order to provide you with a way to override the defaults (`false` for boolean options, `nil` for non-appending parameter options, and `[]` for appending parameter options (don't change this)) by using `EverydayCliUtils::OptionUtil.default_options(options = {})`.

As of version 0.7.0, there is now built-in handling for setting and retrieving default options.  Use `EverydayCliUtils::OptionUtil.defaults_option`, which takes the file name (relative or absolute, it passes through `File.expand_path` before being used) as the first parameter and the list of option flag names as the second parameter.  It will automatically load the file if it exists, and if the user specifies one of the flags you pass to this method, after parsing the options, it will automatically store them in the place you specified.  Unless you specify the hash option `exit_on_save: false`, it will exit after it saves the options.

As of version 1.0.0, there is now support for the help display in `OptionParser`.  You can now provide a `desc:` hash option to the option creating methods (even pre-made ones like `defaults_option` and `help_option`).  You can set the banner with the `EverydayCliUtils::OptionUtil.banner` method, which takes the banner string as its parameter.  You can get the help string with `EverydayCliUtils::OptionUtil.help` or `EverydayCliUtils::OptionUtil.to_s`, or you can handle it with `EverydayCliUtils::OptionUtil.help_option`, which takes an array of the names and an optional `desc:` hash option.  When the user specifies one of those options, the utility will automatically print out the help and exit (unless you specify the hash option `exit_on_print: false`).

As of version 1.4.0, there is support for overriding the built-in help display.  You can now use the `help_str=` method to set the help string override.  See my `mvr` gem for an example.

As of version 1.5.0, there is support for having global defaults.  It is basically the same as the regular defaults option, but it uses the method `global_default_options` instead of just `default_options`.  If the global defaults file exists, it will be loaded first, with the local defaults being loaded on top of it as if they were passed as flags, and then the flags are loaded on top of that in the same manner.

## Contributing

1. Fork it ( http://github.com/henderea/everyday-cli-utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
