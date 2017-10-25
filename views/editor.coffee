TextareaTemplate = require "../templates/textarea"

module.exports = (system, FileIO) ->
  {MenuBar, Modal, Observable, Util:{parseMenu}, Window} = system.UI

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

  textarea = TextareaTemplate
    fontStyle: ->
      fontFamily: fontStyle()
    value: textContent
    wrapStyle: ->
      if wordWrap()
        whiteSpace: "pre-wrap"
      else
        whiteSpace: "pre"

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
        type: "text/plain"

      return Promise.resolve data

    # Printing
    pageSetup: TODO
    print: TODO

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
    aboutNotepad: TODO

  menuBar = MenuBar
    items: parseMenu """
      [F]ile
        [N]ew
        [O]pen
        [S]ave
        Save [A]s
        -
        Page Set[u]p
        [P]rint
        -
        E[x]it
      [E]dit
        [U]ndo
        Redo
        -
        Cu[t]
        [C]opy
        [P]aste
        De[l]ete
        -
        [F]ind
        Find [N]ext
        [R]eplace
        [G]o To
        -
        Select [A]ll
        Time/[D]ate
      F[o]rmat
        [W]ord Wrap
        [F]ont...
      [V]iew
        [S]tatus Bar
      [H]elp
        View [H]elp
        -
        [A]bout Notepad
    """
    handlers: handlers

  title = ->
    path = handlers.currentPath()
    if handlers.saved()
      savedIndicator = ""
    else
      savedIndicator = "*"

    if path
      path = " - #{path}"

    "Notepad.exe#{path}#{savedIndicator}"

  document.body.appendChild menuBar.element
  document.body.appendChild textarea

  return handlers
