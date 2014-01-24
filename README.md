# EverydayCliUtils

[![Gem Version](https://badge.fury.io/rb/everyday-cli-utils.png)](http://badge.fury.io/rb/everyday-cli-utils)
[![Build Status](https://travis-ci.org/henderea/everyday-cli-utils.png?branch=master)](https://travis-ci.org/henderea/everyday-cli-utils)
[![Dependency Status](https://gemnasium.com/henderea/everyday-cli-utils.png)](https://gemnasium.com/henderea/everyday-cli-utils)
[![Code Climate](https://codeclimate.com/github/henderea/everyday-cli-utils.png)](https://codeclimate.com/github/henderea/everyday-cli-utils)
[![Coverage Status](https://coveralls.io/repos/henderea/everyday-cli-utils/badge.png?branch=master)](https://coveralls.io/r/henderea/everyday-cli-utils?branch=master)

A set of CLI and general utilities.

## Issue Tracking
Please use <https://everydayprogramminggenius.atlassian.net/browse/ECU> for issue tracking.

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

###EverydayCliUtils::MyCurses

Encapsulates the code for dealing with the curses library.

###Fields:
####MyCurses.headers
An array storing the header lines that will be printed out with `MyCurses.myprints`.

####MyCurses.bodies
An array storing the body lines that will be printed out with `MyCurses.myprints`.

####MyCurses.footers
An array storing the footer lines that will be printed out with `MyCurses.myprints`.

###Methods:

####MyCurses.new(use\_curses, linesh, linesf)
Initializes the class and sets the basic options.

######Parameters
* `use_curses`: `true` to use curses, `false` to use `puts`
* `linesh`: the number of header lines
* `linesf`: the number of footer lines

####MyCurses.clear
Clear the `headers`, `bodies`, and `footers` arrays

####MyCurses.myprints
Print out all of the lines stored in the `headers`, `bodies`, and `footers` arrays.  If `use_curses` is `true`, it will use curses and allow for scrolling.  Otherwise, it will just print out all of the lines with `puts`

####MyCurses.read\_ch
Update the character from the body pad.

####MyCurses.clear\_ch
Clear out any newline, ENTER, UP, or DOWN characters from the queue.

####MyCurses.scroll\_iteration
Update the display (including doing any scrolling) and read the next character.

####MyCurses.header\_live\_append(str)
Append `str` to the header pad immediately and update it.  Does not modify the `headers` array.

######Parameters
* `str`: the string to append

####MyCurses.body\_live\_append(str)
Append `str` to the body pad immediately and update it.  Does not modify the `bodies` array.

######Parameters
* `str`: the string to append

####MyCurses.footer\_live\_append(str)
Append `str` to the footer pad immediately and update it.  Does not modify the `footers` array.

######Parameters
* `str`: the string to append

####MyCurses.dispose
Close out the curses screen if curses was used.

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

## Contributing

1. Fork it ( http://github.com/henderea/everyday-cli-utils/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
