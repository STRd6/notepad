module.exports = (system, FileIO) ->
  {MenuBar, Modal, Util:{parseMenu}, Window} = system.UI

  # system.Achievement.unlock "Notepad.exe"

  exec = (cmd) ->
    ->
      textarea.focus()
      document.execCommand(cmd)

  TODO = -> console.log "TODO"

  textarea = document.createElement "textarea"
  textarea.spellcheck = false

  initialValue = ""

  textarea.addEventListener "input", ->
    handlers.saved textarea.value is initialValue

  handlers = Object.assign FileIO(system),
    loadFile: (blob, path) ->
      blob.readAsText()
      .then (text) ->
        handlers.currentPath path
        initialValue = text
        textarea.value = initialValue
    newFile: ->
      initialValue = ""
      textarea.value = initialValue
    saveData: ->
      data = new Blob [textarea.value],
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

    wordWrap: TODO

    font: ->
      Modal.prompt "Font", textarea.style.fontFamily or "monospace"
      .then (font) ->
        if font
          textarea.style.fontFamily = font

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

  return
