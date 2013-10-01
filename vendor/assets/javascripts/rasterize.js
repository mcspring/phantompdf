var page = require('webpage').create(),
    fs = require('fs'),
    system = require('system'),
    system_args_length = system.args.length;
if (system_args_length < 3 || system_args_length > 12) {
  console.log('Usage: phantomjs rasterize.js SOURCE DESTINATION [paperWidth*paperHeight|paperFormat] [header] [footer] [margin] [orientation] [zoom] [cookie_file] [render_timeout] [timeout]');
  console.log('     : paper (pdf output) examples: "5in*7.5in", "10cm*20cm", "A4", "Letter"');
  phantom.exit(1);
}

var // PhantomJS CAN NOT handle images in custom header/footer,
    // and this is used to fix the issue.
    io_images = [],

    is_html = function(s){
      return /<([a-z]+?\d*?)[^>]*?>[^\0]*?<\/\1>/i.test(s) === true;
    },

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
      if (!is_html(html)) {
        console.log('Invalid HTML source for rendering!');

        phantom.exit(1);
      }

      page.content = inject_images(html);

      window.setTimeout(function(){
        var output_tmp = output + '_tmp.pdf';

        page.render(output_tmp);
        if (!fs.exists(output_tmp)) {
          console.log('Failed to render pdf tmp file!');

          phantom.exit(1);
        }

        if (fs.exists(output)) {
          fs.remove(output);
        }

        try {
          fs.move(output + '_tmp.pdf', output);

          // return pdf file path
          console.log(output);
        } catch (e) {
          console.log(e.message);

          phantom.exit(1);
        }

        phantom.exit();
      }, render_timeout);
    },

    input = system.args[1],
    output = system.args[2],

    margin = system.args[6] || '0cm',
    orientation = system.args[7] || 'portrait',
    zoom = system.args[8] || '1.0',

    cookie_file = system.args[9],
    cookies = {},

    render_timeout = system.args[10] || 10000,
    timeout = system.args[11] || 90000;

window.setTimeout(function(){
  console.log("Shit's being weird no result within " + timeout + "ms");

  phantom.exit(1);
}, timeout);

page.viewportSize = { width:600, height:600 };
if (output.substr(-4) === '.pdf') {
  var size, header, footer,
      paper_size_options = {};
  if (system_args_length > 3) {
    size = system.args[3].split('*');
    paper_size_options = size.length === 2 ? {width:size[0], height:size[1], margin:'0px'} : {format:system.args[3], orientation:orientation, margin:margin};
  }

  if (system_args_length > 4) {
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

  if (system_args_length > 5) {
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
if (cookie_file) {
  try {
    fd = fs.open(cookie_file, 'r');
    cookies = JSON.parse(fd.read());
    fs.remove(cookie_file);


    phantom.cookiesEnabled = true;
    phantom.cookies = cookies;
  } catch (e) {
    // ignore
  }
}

if (is_html(input)) {  // for html string
  render_pdf(input);
} else {  // for url resource
  var statusCode = null;

  // determine the statusCode
  page.onResourceReceived = function(resource){
    if (new RegExp('^'+input).test(resource.url)) {
      statusCode = resource.status;
    }
  };

  page.open(input, function(status){
    if (status !== 'success' || (statusCode !== null && statusCode != 200)) {
      console.log(statusCode, 'Failed to load the input!');

      if (fs.exists(output)) {
        fs.remove(output);
      }

      try {
        fs.touch(output);
      } catch (e) {
        console.log(e.message);

        phantom.exit(1);
      }

      phantom.exit(1);
    } else {
      render_pdf(page.content);
    }
  });
}
