## PhantomPDF

Generate PDF from HTML using PhantomJS!

Supporting *URL*, *FILE* and *STRING* formats for HTML resource.

## Why PhantomPDF?

Within the Ruby community, there is no simply way to generate *PDF* from *HTML*. You must setup dependences separate and then call some wrapped methods around. When you manage several servers or need to do migrations around, things become much more terrible!

PhantomPDF was born to simplify those. It brings simple API and easy maintenance.

**Yes, PhantomPDF is simply!** You only need to take care of your HTML layout. And then put remaining work to PhantomPDF.

## How to start?

### Installation

##### For Gemfile project
Adding following to your `Gemfile`

```ruby
gem 'phantompdf'
```

and then execute

```ruby
$ bundle
```

##### For normal project
```ruby
$ gem install phantompdf
```

That's all! Pretty simple?!

### Usage

##### Quick starts
```ruby
require 'phantompdf'

options = {
  :format => 'A4',
  :margin => '1cm'
}
output_file = '/tmp/phantompdf_google.pdf'

# for *URL* resource
url = 'http://www.google.com'
url_generator = PhantomPDF::Generator.new(url, output_file, options)
returned_file = url_generator.generate  # If output_file is valid(writable) returned_file == output_file, otherwise returned_file should be temp file of your OS.

# for *FILE* resource
file = 'file://path/to/file.html'
file_generator = PhantomPDF::Generator.new(file, output_file, options)
returned_file = file_generator.generate

# for *STRING* resource
html = '<h1>Hello, PhantomPDF!</h1>'
html_generator = PhantomPDF::Generator.new(html, output_file, options)
returned_file = html_generator.generate

# want to dynamic output?
url_generator.generate('/tmp/dynamic_phantompdf_google.pdf')  # This will output pdf file to /tmp/dynamic_phantompdf_google.pdf though you pass *output* arg when creating generator instance.
```

##### Configuration
You can configure PhantomPDF globally in your project, such as Rails' initializers principle.

```ruby
PhantomPDF.configure do |config|
  # default pdf output format, e.g. "5in*7.5in", "10cm*20cm", "A4", "Letter"
  :format            => 'A4',

  # default pdf header, formatted in [headerHeight*]headerString(HTML is supported)
  # default to 1.2cm when you omit headerHeight
  # you can use *%{pageNum}* and *%{pageTotal}* to refer current values of page
  # example: 1.2cm*<h5>PhantomPDF header %{pageNum}/%{pageTotal}
  :header            => nil,

  # default pdf footer, formatted in footerHeight*footerString(HTML is supported)
  # you can use *%{pageNum}* and *%{pageTotal}* to refer current values of page
  # example: 0.6cm*<h5>PhantomPDF header %{pageNum}/%{pageTotal}
  :footer            => nil,

  # default page margin
  :margin            => '1cm',

  # default page orientation, 'portrait' or 'landscape'
  :orientation       => 'portrait',

  # default page zoom factor
  :zoom              => 1,

  # default cookies, only used for *URL* resource
  :cookies           => {},

  # PhantomJS running timeout
  :timeout           => 90000,

  # pdf rendering timeout, increase if your HTML page is big
  :rendering_timeout => 1000
end
```

You can also configure PhantomPDF in place when needs.

```ruby
# for *URL* resource
url = 'http://www.google.com'
url_generator = PhantomPDF::Generator.new(url, output_file, options)
url_generator.options.header = '0.8cm*<h3>Configure PhantomPDF dynamic</h3>'
returned_file = url_generator.generate
```

##### APIs
```ruby
# create PhantomPDF
PhantomPDF::Generator.new(input, output=nil, options={})

# generate pdf
PhantomPDF::Generator#generate(output=>nil)

# raise PhantomPDF::RenderingError when failed to generate pdf
PhantomPDF::Generator#generate!(output=>nil)

# get generated pdf as string
PhantomPDF::Generator#to_string
```

### Contributing
If you'd like to help improve PhantomPDF or you find some bugs. You can contribute to it by following:

- Submit an issue describing your problem
- Fork your repo and work your magic
- Test your code as far as possible
- Submit a pull request when you finished hack

### License
PhantomPDF is released under [MIT license](http://www.opensource.org/licenses/MIT).

### Authors
[Spring MC](https://twitter.com/mcspring)
