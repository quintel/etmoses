createEditor = (textarea) ->
  id = textarea.attr('id')

  textarea.hide()
  textarea.data('editor', true)

  textarea.after($("""
    <div class="editor-wrap"><pre id='#{ id }_editor'></pre></div>
  """))

  editor = ace.edit("#{ id }_editor")
  editor.getSession().setValue(textarea.text())
  editor.getSession().setMode('ace/mode/yaml')
  editor.setTheme('ace/theme/github')
  editor.setHighlightActiveLine(false)
  editor.setShowPrintMargin(false)

  editor.on 'change', ->
    textarea.text(editor.getSession().getValue())
    $("a[href='#topology']").addClass("editing");

$(document).on "page:change", ->
  textarea = $('textarea.topology-graph')
  if textarea.length and ! textarea.data('editor')
    createEditor(textarea)
