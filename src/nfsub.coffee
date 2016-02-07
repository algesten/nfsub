subplay   = require 'subplay'
jschardet = require 'jschardet'

mkel    = (n) ->  document.createElement n
byTag   = (tg) -> document.getElementsByTagName(tg)?[0]
byClass = (cl) -> document.getElementsByClassName(cl)?[0]
byId    = (id) -> document.getElementById id

merge   = (t, os...) -> t[k] = v for k,v of o when v != undefined for o in os; t

onready = (f) -> if /in/.test document.readyState then setTimeout(onready,9,f) else f()

log = console.log.bind console

# helper function to get video tag
getVideo  = -> byTag 'video'
attachDom = ->
  el = byClass 'nfsub'
  return el if el
  # this is where nf places their subtitles
  pttel = byClass 'player-timedtext'
  el = mkel 'div'
  el.className = 'nfsub'
  # append all into DOM
  pttel.parentNode.appendChild el
  # receive click on the element
  el.innerHTML =
  """
  <div class="nfsub-text"></div>
  <div class="nfsub-offs"></div>
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
  merge byClass('nfsub-text').style, {
    textAlign: 'center'
  }
  merge byClass('nfsub-offs').style, {
    right: '20px'
    top: '0'
    position: 'absolute'
    display: 'none'
  }

  loadel = mkel 'div'
  loadel.className = 'nfsub-load'
  loadel.innerHTML = 'Load'
  merge loadel.style, {
    position: 'absolute'
    top: '0'
    right: '0'
    color: '#fff'
    padding: '7px'
    cursor: 'pointer'
  }

  setTimeout ->
    pmtsel = byId 'player-menu-track-settings'
    pmtsel.appendChild loadel
    byClass('nfsub-load').addEventListener 'click', onLoadClick
  , 1000

  document.body.addEventListener 'keydown', onKeyDown

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
  # stop previous subtitles
  nfsub.stop()
  # do we have a file?
  f = ev.target.files?[0]
  return unless f
  # determine encoding
  r = new FileReader()
  r.onload = (e) ->
    log 'readFile onload detect encoding', e
    # remove <input type="file">
    ev.target.parentNode.removeChild ev.target
    srt = e.target.result
    det = jschardet.detect srt
    log 'readFile onload encoding', det
    return unless det?.encoding
    # now read with detected encoding
    r2 = new FileReader()
    r2.onload = (e) ->
      srt = e.target.result
      nfsub.start srt
    r2.readAsText f, det.encoding
  r.readAsBinaryString f


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
    videoEl.addEventListener 'pause', onPause
    videoEl.addEventListener 'play', onPlay
    attachDom()
    startIntervalChecks()
  inter = setInterval ->
    videoEl = getVideo()
    if videoEl
      videoEl.addEventListener 'timeupdate', receivedTimeupdate
  , 1000

log 'waiting onready'
onready installEventListener

startIntervalChecks = do ->
  started = false
  ->
    return if started
    setInterval ->
      # do nothing if we had a time update in the last 2 secs
      return if (Date.now() - lastTimeUpdate) < 2000
      installEventListener() # otherwise install again
    , 5000
    started = true

# the subplay update function
subupdate = null

# the update function or -> if inert
update = ->

# whether we are playing (or paused)
playing = true

# tells when we last got an time update, this is so we reinstall all
# the handlers if we not get any update for a while.
lastTimeUpdate = 0

# wire video update events to the update function
onTimeUpdate = (ev) ->
  lastTimeUpdate = Date.now()
  update ev.target.currentTime
onPlay  = ->
  log 'play'
  playing = true
onPause = ->
  log 'pause'
  playing = false
  update -1

# render function that places the text on screen
renderer = (text) ->
  byClass('nfsub-text').innerHTML = text

setOutput = (loadMode, text) ->
  el = attach()
  el.innerHTML = text

removeStandardSubs = -> byClass('player-timedtext')?.remove()

module.exports = nfsub =
  start: (srt) ->
    removeStandardSubs()
    subupdate = subplay(srt, renderer)
    playing = true
    update = (time) ->
      if playing and time >= 0
        time = if (dt = (time - offset / 1000)) >= 0 then dt else 0
        subupdate(time)
      else
        subupdate? -1
  stop: ->
    subupdate? -1 # stop it
    playing = false
    subupdate = null
    update = ->
