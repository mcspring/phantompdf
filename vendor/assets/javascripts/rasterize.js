var page = require('webpage').create(),
    fs = require('fs'),
    system = require('system'),
    system_args_len = system.args.length,
    timer = null,
    phantom_exit = function(code, message){
      if (message) {
        console.log(message);
      }

      if (page) {
        page.close();
      }

      if (timer) {
        clearTimeout(timer);
      }

      phantom.exit(code || 0);
    };
if (phantom.version.major < 1 && phantom.version.minor < 7) {
  phantom_exit(1, "PhantomJS version must greater than 1.7!");
}
if (system_args_len < 3 || system_args_len > 12) {
  phantom_exit(1, "Usage: phantomjs rasterize.js SOURCE DESTINATION [paperWidth*paperHeight|paperFormat] [header] [footer] [margin] [orientation] [zoom] [cookies] [render_timeout] [timeout]\n     : paper (pdf output) examples: \"5in*7.5in\", \"10cm*20cm\", \"A4\", \"Letter\"");
}

var input = system.args[1],
    output = system.args[2],

    margin = system.args[6] || '0cm',
    orientation = system.args[7] || 'portrait',
    zoom = system.args[8] || '1.0',

    cookies = system.args[9],

    render_timeout = system.args[10] || 10000,
    timeout = system.args[11] || 90000,

    // PhantomJS CAN NOT handle images in custom header/footer,
    // and this is used to fix the issue.
    // NOTE: You must pass HTML content if you want to use this feature!
    io_images = [],

    is_http = function(s){
      return /https?:\/\/.+?/i.test(s) === true;
    },
    is_html = function(s){
      return /<([a-z]+?\d*?)[^>]*?>[^\0]*?<\/\1>/i.test(s) === true;
    }

    extract_images = function(html){
      var image_tags = html.match(/<img[^>]+?src=(["'])https?:\/\/[^>]+?\1[^>]*?\/?>/ig),
          image_tags_len,
          i, image;
      if (image_tags === null) {
        return;
      }

      image_tags_len = image_tags.length;
      for (i=0; i<image_tags_len; i++) {
        image = image_tags[i].match(/src=(["'])(https?:\/\/[^>]+?)\1/i);

        if (image.length == 3 && io_images.indexOf(image[2]) < 0) {
          io_images[io_images.length] = image[2];
        }
      }
    },
    inject_images = function(html){
      var images_num = io_images.length;
      if (images_num < 1) {
        return html;
      }

      var klass, klasses = [],
          html_injected, html_temp,
          i, fragments = ['<style type="text/css">'];
      for (i=0; i<images_num; i++) {
        klass = 'phantompdf-' + i;

        klasses[klasses.length] = klass;
        fragments[fragments.length] = '.' + klass + '{background:url(' + io_images[i] + ');}';
      }
      fragments[fragments.length] = '</style>';
      fragments[fragments.length] = '<div class="' + klasses.join(' ') + '" style="display:none;width:0;height:0;font-size:0;"></div>';

      html_injected = fragments.join('');

      html_temp = html.split('</body>');
      if (html_temp.length > 1) {
        html_temp[html_temp.length - 1] = html_injected + html_temp.slice(-1)[0];

        html = html_temp.join('</body>');
      } else {
        html = html + html_injected;
      }

      return html;
    },

    render_pdf = function(html){
      if (typeof(html) == 'string') {
        page.content = inject_images(html);
      }

      timer = window.setTimeout(function(){
        var output_tmp = output + '_tmp.pdf';

        page.render(output_tmp);
        if (!fs.exists(output_tmp)) {
          phantom_exit(1, 'Failed to render pdf tmp file!');
        }

        if (fs.exists(output)) {
          fs.remove(output);
        }

        try {
          fs.move(output_tmp, output);

          // return pdf file path
          console.log(output);
        } catch (e) {
          phantom_exit(1, e.message);
        }

        phantom_exit()
      }, render_timeout);
    };

var overtimer = window.setTimeout(function(){
  clearTimeout(overtimer);
  phantom_exit(1, "Shit's being weird no result within " + timeout + "ms");
}, timeout);

page.viewportSize = { width:600, height:600 };
if (output.substr(-4) === '.pdf') {
  var size, header, footer,
      paper_size_options = {};
  if (system_args_len > 3) {
    size = system.args[3].split('*');
    paper_size_options = size.length === 2 ? {width:size[0], height:size[1], margin:'0px'} : {format:system.args[3], orientation:orientation, margin:margin};
  }

  if (system_args_len > 4) {
    header = system.args[4].split('*');
    if (header.length >= 2) {
      extract_images(header.join('*'));

      paper_size_options['header'] = {
        height: header.shift(),
        contents: phantom.callback(function(pageNum, pageTotal){
          return header.join('*').replace(new RegExp('%{pageNum}', 'g'), pageNum).replace(new RegExp('%{pageTotal}', 'g'), pageTotal);
        })
      };
    }
  }

  if (system_args_len > 5) {
    footer = system.args[5].split('*');
    if (footer.length >= 2) {
      extract_images(footer.join('*'));

      paper_size_options['footer'] = {
        height: footer.shift(),
        contents: phantom.callback(function(pageNum, pageTotal){
          return footer.join('*').replace(new RegExp('%{pageNum}', 'g'), pageNum).replace(new RegExp('%{pageTotal}', 'g'), pageTotal);
        })
      };
    }
  }

  page.paperSize = paper_size_options;
}
page.zoomFactor = zoom;

// cookies injection
phantom.cookiesEnabled = false;
if (cookies) {
  try {
    cookies = JSON.parse(cookies);

    phantom.cookiesEnabled = true;
    phantom.cookies = cookies;
  } catch (e) {
    phantom.cookiesEnabled = false;
  }
}

if (is_html(input)) {  // for html string
  render_pdf(input);
} else {  // for url resource
  // determine the resourceStatusCode
  var resourceStatusCode = null;
  page.onResourceReceived = function(resource){
    if (new RegExp('^'+input).test(resource.url)) {
      resourceStatusCode = resource.status;
    }
  };

  page.open(input, function(status){
    if (status !== 'success' || (resourceStatusCode !== null && resourceStatusCode != 200)) {
      console.log(resourceStatusCode, 'Failed to load the input!');

      if (fs.exists(output)) {
        fs.remove(output);
      }

      try {
        fs.touch(output);
      } catch (e) {
        phantom_exit(1, e.message);
      }

      phantom_exit(1);
    } else {
      render_pdf(is_http(input) ? null : page.content);
    }
  });
}
