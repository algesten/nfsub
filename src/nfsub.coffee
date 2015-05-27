subplay = require 'subplay'

mkel    = (n) ->  document.createElement n
byTag   = (tg) -> document.getElementsByTagName(tg)?[0]
byClass = (cl) -> document.getElementsByClassName(cl)?[0]

merge   = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t

onready = (f) -> if /in/.test document.readyState then setTimeout(onready,9,f) else f()

log = (as...) -> console.log as...

# helper function to get video tag
getVideo  = -> byTag 'video'
attachDom = ->
  el = byClass 'nfsub'
  return el if el
  # this is where nf places their subtitles
  sib = byClass 'player-timedtext'
  el = mkel 'div'
  el.className = 'nfsub'
  # append all into DOM
  sib.parentNode.appendChild el
  # receive click on the element
  el.innerHTML =
  """
  <div class="nfsub-text"></div>
  <div class="nfsub-offs"></div>
  <div class="nfsub-load">Click to load subtitles<div>
  """

  merge el.style, {
    position: 'absolute'
    bottom: '50px'
    left: '0'
    height: '100px'
    width: '100%'
    fontSize: '3vw'
    color: '#fff'
    textShadow: '
      -1px -1px 0 #000,
       1px -1px 0 #000,
      -1px  1px 0 #000,
       1px  1px 0 #000'
  }
  merge byClass('nfsub-load').style, {
    textAlign: 'center'
  }
  merge byClass('nfsub-text').style, {
    textAlign: 'center'
  }
  merge byClass('nfsub-offs').style, {
    right: '0'
    top: '0'
    position: 'absolute'
    display: 'none'
  }

  document.body.addEventListener 'keydown', onKeyDown

  byClass('nfsub-load').addEventListener 'click', onLoadClick
  log 'attachDom appended', el
  el


onLoadClick = (ev) ->
  log 'onLoadClick', ev
  ev.preventDefault()
  ev.stopPropagation()
  # append file input used to load srt
  iel = mkel 'input'
  iel.type = 'file'
  # the event listener for reading srt
  iel.addEventListener 'change', readFile, false
  iel.opacity = 0
  document.body.appendChild iel
  # simulate click
  iel.click()

isModifierKey = (ev) -> ev.ctrlKey || ev.metaKey || ev.shiftKey

offset = 0
INC = 50

onKeyDown = (ev) ->
  return if isModifierKey ev
  if ev.keyCode == 71
    # g
    offset -= INC
    showOffset()
  else if ev.keyCode == 72
    # h
    offset += INC
    showOffset()


showOffset = ->
  el = byClass('nfsub-offs')
  el.innerHTML = "#{offset}ms"
  el.style.display = 'block'
  clearTimeout(el._timeout) if el._timeout
  el._timeout = setTimeout ->
    el.style.display = 'none'
  , 1000


# the handler for change events which reads a srt-file
# and starts the subplay player.
readFile = (ev) ->
  log 'readFile', ev
  f = ev.target.files?[0]
  return unless f
  r = new FileReader()
  r.onload = (e) ->
    log 'readFile onload', e
    # remove <input type="file">
    ev.target.parentNode.removeChild ev.target
    srt = e.target.result
    nfsub.start srt
    byClass('nfsub-load').style.display = 'none'
  r.readAsText(f, 'cp1252')


# the initial <video> tag is inert and any event handlers
# added to it are not working. this function installs an event
# listener every second and only when it actually fires
# does it add the actual onTimeUpdate() handler.
installEventListener = ->
  log 'start install event listener'
  videoEl = null
  if videoEl
    videoEl.removeEventListener 'timeupdate', onTimeUpdate
  receivedTimeupdate = ->
    log 'installing handler'
    clearInterval inter # stop installing
    videoEl.removeEventListener 'timeupdate', receivedTimeupdate # remove self
    videoEl.addEventListener 'timeupdate', onTimeUpdate # install real
    attachDom()
  inter = setInterval ->
    videoEl = getVideo()
    if videoEl
      videoEl.addEventListener 'timeupdate', receivedTimeupdate
  , 1000


log 'waiting onready'
onready installEventListener

# the subplay update function
subupdate = null

# the update function or -> if inert
update = ->

# wire video update events to the update function
onTimeUpdate = (ev) -> update ev.target.currentTime

# render function that places the text on screen
renderer = (text) ->
  byClass('nfsub-text').innerHTML = text

setOutput = (loadMode, text) ->
  el = attach()
  el.innerHTML = text

module.exports = nfsub =
  start: (srt) ->
    subupdate = subplay(srt, renderer)
    update = (time) -> subupdate(if (dt = time + offset / 1000) >= 0 then dt else 0)
  stop: ->
    subupdate -1 # stop it
    subupdate = null
    update = ->
