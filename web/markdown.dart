import 'dart:html';
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
  
  editor.focus();
}

void watchDocument(){
  var value = editor.value;
  var cursor = editor.selectionStart;
  
  var i = cursor;
  if(i >= value.length){
    i = value.length -1;
  }
  while(i > -1 && !LETTERS.contains(value[i].toLowerCase())){
    i--;
  }
  i++;
  
  value = "${value.substring(0,i)}◈${value.substring(i,value.length)}";
  
  final document = new markdown.Document();
  final lines = value.split('\n');
  final blocks = document.parseLines(lines);
  var output = markdown.renderToHtml(blocks);
  output = output.replaceFirst("◈", "<span id='cursor' class='cursor'>|</span>");
  preview.innerHTML = markdown.markdownToHtml(output);
  
  Element cursorDiv = preview.query("#cursor");
  cursorDiv.scrollIntoView(true);
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
