style = document.createElement "style"
style.innerHTML = require "./style"
document.head.appendChild style

Drop = require "./lib/drop"
Editor = require "./views/editor"

SystemClient = require "sys"
SystemClient.applyExtensions()
{system, application, postmaster, util} = SystemClient()

document.addEventListener "keydown", (e) ->
  {ctrlKey:ctrl, key} = e
  if ctrl
    switch key
      when "s"
        e.preventDefault()
        handlers.save()
      when "o"
        e.preventDefault()
        handlers.open()

editor = Editor(system, util.FileIO)

postmaster.delegate = editor

system.ready()
.catch console.warn
