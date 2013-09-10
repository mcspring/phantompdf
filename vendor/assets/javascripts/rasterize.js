var page = require('webpage').create(),
    fs = require('fs'),
    system = require('system'),
    system_args_length = system.args.length;
if (system_args_length < 3 || system_args_length > 12) {
  console.log('Usage: phantomjs rasterize.js SOURCE DESTINATION [paperWidth*paperHeight|paperFormat] [header] [footer] [margin] [orientation] [zoom] [cookie_file] [render_timeout] [timeout]');
  console.log('     : paper (pdf output) examples: "5in*7.5in", "10cm*20cm", "A4", "Letter"');
  phantom.exit(1);
}

var input = system.args[1],
    output = system.args[2],

    margin = system.args[6] || '0cm',
    orientation = system.args[7] || 'portrait',
    zoom = system.args[8] || '1.0',

    cookie_file = system.args[9],
    cookies = {},

    render_timeout = system.args[10] || 10000,
    timeout = system.args[11] || 90000;

window.setTimeout(function () {
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

if (/<([a-z]+?\d*?).*?>[^\0]*?<\/\1>/i.test(input) === true) {
  page.content = input;

  window.setTimeout(function () {
    page.render(output + '_tmp.pdf');

    if (fs.exists(output)) {
      fs.remove(output);
    }

    try {
      fs.move(output + '_tmp.pdf', output);

      console.log(output);
    } catch (e) {
      phantom.exit(1);
      throw e;
    }

    phantom.exit();
  }, render_timeout);
} else {
  var statusCode = null;

  if (cookie_file) {
    try {
      fd = fs.open(cookie_file, 'r');
      cookies = JSON.parse(fd.read());
      fs.remove(cookie_file);


      phantom.cookiesEnabled = true;
      phantom.cookies = cookies;
    } catch (e) {
      // console.log(e);
    }
  }

  // determine the statusCode
  page.onResourceReceived = function (resource) {
    if (new RegExp('^'+input).test(resource.url)) {
      statusCode = resource.status;
    }
  };

  page.open(input, function (status) {
    if (status !== 'success' || (statusCode !== null && statusCode != 200)) {
      console.log(statusCode, 'Failed to load the input!');

      if (fs.exists(output)) {
        fs.remove(output);
      }

      try {
        fs.touch(output);
      } catch (e) {
        phantom.exit(1);
        throw e;
      }

      phantom.exit(1);
    } else {
      window.setTimeout(function () {
        page.render(output + '_tmp.pdf');

        if (fs.exists(output)) {
          fs.remove(output);
        }

        try {
          fs.move(output + '_tmp.pdf', output);

          console.log(output);
        } catch (e) {
          phantom.exit(1);
          throw e;
        }

        phantom.exit();
      }, render_timeout);
    }
  });
}
