const jsdom = require('jsdom')
const dom = new jsdom.JSDOM("")
const jquery = require('jquery')(dom.window)
var expression;
const readline = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});

readline.question('Expression:', expr => {
  var expression = "${expr}"
  readline.close();
});


var url="https://api.mathjs.org/v4/"
var tua='?expr='
expression = encodeURIComponent(expression);
var url = url + tua + expression
var response = $.getJSON(url)
return response