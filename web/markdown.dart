import 'dart:html';
import 'dart:math';
import 'package:dartdoc/markdown.dart' as markdown;

const LETTERS = "abcdefghijklmnopqrstuvwxyz";

TextAreaElement editor;
DivElement preview;

void main() {
  editor = query("#editor");
  preview = query("#preview");
  
  editor.on.change.add((e) => watchDocument());
  editor.on.input.add((e) => watchDocument());
  editor.on.keyDown.add(keyPressed);
  editor.on.scroll.add((e) => scrollDocument());
  preview.on.scroll.add((e) => e.preventDefault());
  
  editor.focus();
}

void scrollDocument(){
  var percentScroll = (editor.scrollTop / (editor.scrollHeight - editor.clientHeight));
  var percentView = editor.clientHeight * percentScroll;
  var percent = editor.scrollTop + percentView;
  var line = (percent/21).toInt(); // the line that is mid way down the screen
  
  var usableWidth = editor.clientWidth-20;
  var charsPerLine = (usableWidth/8).floor().toInt(); // the number of chars per line
  
  var lines = editor.value.split('\n');
  var realLines = [];
  for(var l in lines){
    while(l.length > charsPerLine){
      realLines.add(l.substring(0, charsPerLine));
      l = l.substring(charsPerLine,l.length);
    }
    realLines.add(l);
  }
  
  var offset = 0;
  for(var a=0;a<line && a < realLines.length;a++){
    offset += realLines[a].length + 1;
  }
  
  if(offset >= editor.value.length){
    offset = editor.value.length - 1;
  }

  placeAndScroll(offset,editor.value);
}

void watchDocument(){
  var value = editor.value;
  var cursor = editor.selectionStart;
  
  placeAndScroll(cursor,value);
}

void placeAndScroll(int cursor, String value){
  var i = cursor;
  if(i >= value.length){
    i = value.length -1;
  }
  while(i > -1 && !LETTERS.contains(value[i].toLowerCase())){
    i--;
  }
  
  value = "${value.substring(0,i)}◈${value.substring(i,value.length)}";
  
  final document = new markdown.Document();
  final lines = value.split('\n');
  final blocks = document.parseLines(lines);
  var output = markdown.renderToHtml(blocks);
  output = output.replaceFirst("◈", "<span id='cursor' class='cursor'>|</span>");
  preview.innerHTML = markdown.markdownToHtml(output);
  
  Element cursorDiv = preview.query("#cursor");
  if(cursorDiv != null){
    cursorDiv.scrollIntoView(true);
  }
}

void keyPressed(KeyboardEvent e){
  if(e.keyCode == 9){//tab
    e.preventDefault();
    var cursor = editor.selectionStart;
    var value = editor.value;
    editor.value = "${value.substring(0,cursor)}  ${value.substring(cursor,value.length)}";
    editor.selectionStart = cursor + 2;
    editor.selectionEnd = cursor + 2;
  }
}
