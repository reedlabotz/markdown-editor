import 'dart:html';
import 'package:dartdoc/markdown.dart' as markdown;

TextAreaElement editor;
DivElement preview;

void main() {
  editor = query("#editor");
  preview = query("#preview");
  
  editor.on.change.add((e) => watchDocument());
  editor.on.input.add((e) => watchDocument());
  editor.on.keyDown.add(keyPressed);
}

void watchDocument(){
  preview.innerHTML = markdown.markdownToHtml(editor.value);
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
