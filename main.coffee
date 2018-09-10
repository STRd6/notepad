Drop = require "./lib/drop"
Editor = require "./views/editor"

SystemClient = require "sys"
SystemClient.applyExtensions()

{system, application, postmaster, util, UI} = client = SystemClient
  applyStyle: true

{Modal} = UI

# Add our style after system client UI styles so we can override
style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

editor = Editor(client)

Drop document, (e) ->
  return if e.defaultPrevented

  files = e.dataTransfer.files

  if files.length
    e.preventDefault()

    file = files[0]
    editor.loadFile file

document.addEventListener "keydown", (e) ->
  {ctrlKey:ctrl, key} = e
  if ctrl
    switch key
      when "s"
        e.preventDefault()
        editor.save()
      when "o"
        e.preventDefault()
        editor.open()

document.body.appendChild editor.element

application.delegate = editor

system.ready()
.catch (e) ->
  ReaderInput = require "./templates/reader-input"

  # Override chooser to use local PC
  editor.open = ->
    Modal.show ReaderInput
      accept: "text/*,application/javascript"
      select: (file) ->
        Modal.hide()
        editor.loadFile file

  # Override save to present download
  editor.save = ->
    Modal.prompt "File name", "newfile.txt"
    .then (name) ->
      editor.saveData()
      .then (blob) ->
        url = window.URL.createObjectURL(blob)
        a = document.createElement("a")
        a.href = url
        a.download = name
        a.click()
        window.URL.revokeObjectURL(url)

  console.warn e
