AboutTemplate = require "../templates/about"
PrintPreTemplate = require "../templates/print-pre"
TextareaTemplate = require "../templates/textarea"

{version} = require "../pixie"

module.exports = (client) ->
  {system, application, UI, util} = client
  {MenuBar, Modal, Observable, Util:{parseMenu}} = UI
  {FileIO} = util

  exec = (cmd) ->
    ->
      textarea.focus()
      document.execCommand(cmd)

  TODO = -> console.log "TODO"

  initialValue = ""
  textContent = Observable ""

  wordWrap = Observable true
  fontStyle = Observable "monospace"

  textContent.observe (value) ->
    handlers.saved value is initialValue

  elementPresenter =
    fontStyle: ->
      fontFamily: fontStyle()
    value: textContent
    wrapStyle: ->
      if wordWrap()
        whiteSpace: "pre-wrap"
      else
        whiteSpace: "pre"

  textarea = TextareaTemplate elementPresenter
  printElement = PrintPreTemplate elementPresenter

  textarea.spellcheck = false

  handlers = Object.assign FileIO(system),
    loadFile: (blob, path) ->
      blob.readAsText()
      .then (text) ->
        handlers.currentPath path
        initialValue = text
        textContent initialValue
    newFile: ->
      initialValue = ""
      textContent initialValue
    saveData: ->
      data = new Blob [textContent()],
        type: "text/plain; charset=utf-8"

      return Promise.resolve data

    # Printing
    pageSetup: TODO
    print: ->
      window.print()

    exit: ->
      system.exit()

    undo: exec "undo"
    redo: exec "redo"
    cut: exec "cut"
    copy: exec "copy"
    # NOTE: Can't paste from system clipboard for security reasons
    # Can probably paste from an in-app clipboard equivalent
    paste: exec "paste"
    delete: exec "delete"

    find: TODO
    findNext: TODO
    replace: TODO
    goTo: TODO

    selectAll: ->
      textarea.select()

    timeDate: ->
      textarea.focus()
      dateText = (new Date).toString().split(" ").slice(0, -4).join(" ")
      document.execCommand("insertText", false, dateText)

    wordWrap: ->
      wordWrap.toggle()

    font: ->
      Modal.prompt "Font", fontStyle() or "monospace"
      .then (font) ->
        if font
          fontStyle(font)

    statusBar: TODO
    viewHelp: TODO
    aboutNotepad: ->
      Modal.show AboutTemplate
        version: version

  # TODO: Add in this Edit submenu some day
  """
        -
        [F]ind
        Find [N]ext
        [R]eplace
        [G]o To
  """

  menuBar = MenuBar
    items: parseMenu """
      [F]ile
        [N]ew
        [O]pen
        [S]ave
        Save [A]s
        -
        [P]rint
        -
        E[x]it
      [E]dit
        [U]ndo
        Redo
        -
        Cu[t]
        [C]opy
        De[l]ete
        -
        Select [A]ll
        Time/[D]ate
      F[o]rmat
        [W]ord Wrap
        [F]ont...
      [H]elp
        [A]bout Notepad
    """
    handlers: handlers

  title = Observable ->
    path = handlers.currentPath()
    if handlers.saved()
      savedIndicator = ""
    else
      savedIndicator = "*"

    if path
      path = " - #{path}"

    "Notepad.exe#{path}#{savedIndicator}"

  title.observe application.title

  editorElement = document.createElement "editor"
  editorElement.appendChild menuBar.element
  editorElement.appendChild textarea
  editorElement.appendChild printElement

  handlers.element = editorElement

  return handlers
