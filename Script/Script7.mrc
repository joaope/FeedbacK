;_____________[ profiles ]________________________________________

alias profiles { _advanced.openDialog _profiles profiles }
dialog _profiles {
  title "Profiles"
  size -1 -1 156 168
  option dbu

  box "&Users:", 1, 4 4 147 108
  list 2, 10 14 89 90, size
  button "&New...", 3, 104 37 40 11
  button "&Load", 4, 104 58 40 11
  button "&Spawn", 5, 104 71 40 11

  box "&Options:", 7, 4 115 147 30
  check "&Ask for profile on startup", 8, 11 127 77 10

  button "&Close", 100, 68 151 40 11, cancel
  button "&Help", 99, 110 151 40 11
}
on *:DIALOG:_profiles:*:*:{
  if ($devent == INIT) { _profiles.updateDialog }
  elseif ($devent == SCLICK) {
    if ($did == 3) {
      var %d = _profiles.new
      __dummy $dialog(%d,%d,-4)
    }
    elseif ($did == 4) { _profiles.load -l $$did(2).seltext }
    elseif ($did == 5) { _profiles.load -s $$did(2).seltext }
    elseif ($did == 8) { _script.setOption Profiles AskOnStart $did(8).state }
  }
}
alias _profiles.currentLoaded {
  var %name = $gettok($nofile($_mirc.ini),-1,92)
  if ($_profiles.exists(%name)) && ($_mirc.ini == $_profiles.mainDirectory(%name,mirc.ini)) { return %name }
  return (Default)
}
alias _profiles.totalAvailable { return $finddir($_profiles.mainDirectory,*,0,1) }
alias _profiles.mainDirectory { 
  var %name = $iif($prop == current,$_profiles.currentLoaded,$iif($1 != $null,$1)), %r
  if (%name != $null) { %r = $mircdir $+ Profiles\ $+ %name $+ \ $+ $2- }
  else { %r = $mircdir $+ Profiles\ }
  return $_file.fixName(%r) 
}
alias -l _profiles.updateDialog {
  var %d = _profiles, %curr = $_profiles.currentLoaded
  if (!$dialog(%d)) { return }
  var %x = 1, %i
  did -r %d 2
  didtok %d 2 34 $_profiles.names
  dialog -t %d $gettok($dialog(%d).title,1,45) - Current: %curr
  if (%curr != (Default)) { did -b %d 8 }
  elseif ($_script.getOption(Profiles,AskOnStart)) { did -c %d 8 }
}
alias -l _profiles.names {
  var %names = (Default), %x = 1, %main = $_profiles.mainDirectory, %_temp
  while ($finddir(%main,*,%x,1)) {
    %_temp = $gettok($v1,-1,92)
    if ($_profiles.exists(%_temp)) && (%_temp != (Default)) { %names = $addtok(%names,%_temp,34) }
    inc %x
  }
  return %names
}
alias -l _profiles.exists {
  if ($1 == $null) { return }
  if ($1 == (Default)) { return 1 }
  var %dir = $_profiles.mainDirectory($1), %ini = $_profiles.mainDirectory($1,mirc.ini)
  if ($isdir(%dir)) && ($isfile(%ini)) { return 1 }
}
alias -l _profiles.validName {
  if ($1 == $null) { return }
  if ($1 isalnum) && ($len($1) <= 14) { return 1 }
}
dialog _profiles.new {
  title "Profiles - New"
  size -1 -1 132 124
  option dbu
  box "", 1, 4 4 123 96
  radio "", 2, 10 14 114 10
  radio "&Import settings from this profile:", 3, 10 26 115 10
  list 4, 18 36 101 56, size
  button "&Generate", 5, 44 107 40 11
  button "&Cancel", 6, 86 107 40 11, cancel
}
on *:DIALOG:_profiles.new:*:*:{
  if ($devent == INIT) {
    did -a $dname 2 &New profile (empty $_script.name instalation)
    didtok $dname 4 34 $_profiles.names
    did -c $dname 2
  } 
  elseif ($devent == DCLICK) && ($did == 4) && ($did(4).seltext != $null) { _profiles.new $v1 }
  elseif ($devent == SCLICK) {
    if ($did == 2) { did -u $dname 4 }
    elseif ($did == 3) {
      if (!$did(4).sel) { did -c $dname 4 1 }
    }
    elseif ($did == 4) { 
      did -u $dname 2
      did -c $dname 3
      did $iif($did(4).seltext != $null,-e,-b) $dname 5
    }
    elseif ($did == 5) { _profiles.new $did(4).seltext }
  }
}
alias -l _profiles.new {
  var %name = $gettok($_prompt.input(New profile name (only letters and numbers and not longer than 14 characters):"~"Profiles - New"tch"ProfilesNewName),1,32)
  if ($_profiles.exists(%name)) { _prompt.info Profile ' $+ %name $+ ' already exists. Halted."Profiles }
  else {
    var %dir = $_profiles.mainDirectory(%name), %ini = $_file.fixName(%dir $+ mirc.ini), %from = $1, %imported = 0
    _file.makeDirectory %dir
    if (%from) {
      if (!$_profiles.exists(%from)) { _prompt.error Invalid profile $+(',%from,') to generate from. Halted."Profiles }
      else {
        var %fromdir = $_profiles.mainDirectory(%from)
        __dummy $_file.copyDirectory(%fromdir,%dir,*)
        %imported = 1
      }
    }
    if (!$isfile(%newmircini)) { .copy -o $_mirc.ini %ini }
    writeini -n %ini rfiles n0 $remove(%dir,") $+ Users.mrc
    writeini -n %ini rfiles n1 $remove(%dir,") $+ Variables.mrc
    dialog -x _profiles.new
    _profiles.updateDialog
    _prompt.info New profile sucessfuly generated: %name $+ "Profiles
  }
}
alias -l _profiles.load {
  var %name = $2, %flags = $1, %d = _profiles

  if (%name == $null) { return }
  if ($lock(run)) {
    prompr.error Profile $+(',%name,') can't be $iif(s isincs %flags,spawned,loaded) $+ . /run command is locked. Check mIRC lock options (ALT+O\General\Lock)
    return
  }
  if (l isincs %flags) && (%name == $_profiles.currentLoaded) { 
    _prompt.info Profile $+(',%name,') already loaded. Halted"Profiles
    return
  }

  if (s isincs %flags) { var %ask = $_prompt.yesNoCancel(Close this mIRC copy? ('No' to just open another copy)"Profiles) }
  else { var %ask = $yes }

  if (%ask == $cancel) { return }
  else {
    if (%name == (Default)) { .run $_mirc.exe }
    else { .run $_mirc.exe -i $+ $_profiles.mainDirectory(%name,mirc.ini) }
    if (l isincs %flags) || (%ask == $yes) {
      _themes.commandEcho Profile Loading $+(',%name,'...)
      .exit
    }
    if ($dialog(%d)) { dialog -x %d }
  }
}
alias _profiles.onStart {
  if ($_script.getOption(Profiles,AskOnStart)) && ($numtok($_profiles.names,34) > 1) { _profiles.quickSelect }
}
alias -l _profiles.quickSelect { __dummy $dialog(_profiles.quickSelect,_profiles.quickSelect,-4) }
dialog _profiles.quickSelect {
  title "Profiles - Select"
  size -1 -1 122 71
  option dbu
  box "&Users:", 1, 4 4 113 44
  combo 2, 11 17 99 50, size drop
  check "&Don't ask again", 3, 11 31 50 10
  button "&Load", 4, 35 54 40 11, ok
  button "&Cancel", 5, 77 54 40 11, cancel
}
on *:DIALOG:_profiles.quickSelect:*:*:{
  if ($devent == INIT) {
    var %curr = $_profiles.currentLoaded
    dialog -t $dname Profiles - Current: %curr 
    didtok $dname 2 34 $remtok($_profiles.names,%curr,1,34)
    did -c $dname 2 1
  }
  elseif ($devent == SCLICK) && ($did == 4) { _profiles.load -l $$did(2).seltext }
  elseif ($devent == CLOSE) && ($did(3).state) { _script.setOption Profiles AskOnStart 0 }
}



;_____________[ cpanel ]________________________________________

alias cpanel { _advanced.openDialog _cpanel cpanel }
dialog _cpanel {
  title "Control panel"
  size -1 -1 258 156
  option dbu
  icon 1, 8 14 16 16
  list 2, 31 9 220 119, size sort hsbar
  text "Description:", 3, 33 133 31 8
  text "<not selected>", 4, 69 133 182 15
  list 1000, 0 0 0 0, hide disable
  button "", 2000, 0 0 0 0, cancel disable hide

  menu "&View", 100
  item "&Topics", 101
  item "&Description", 102
  item break, 104
  item "&Both", 103

  menu "&Help", 200
  item "&Topics", 201
}
on *:DIALOG:_cpanel:*:*:{
  if ($devent == INIT) { _cpanel.updateDialog }
  elseif ($devent == SCLICK) {
    if ($did == 2) { _cpanel.clickOnList }
  }
  elseif ($devent == DCLICK) && ($did == 2) && ($gettok($did(1000,$did(2).sel),2,32) != $null) {
    dialog -x $dname
    var %cmd = $v1
    if ($isalias(%cmd)) { %cmd }
  }
  elseif ($devent == MENU) { 
    if ($did isnum 101-103) {
      _script.setOption CPanel ViewType $calc($did - 100)
      _cpanel.updateDialog 
    }
    else { }
  }
}
alias _cpanel.viewType { return $iif($int($_script.getOption(CPanel,ViewType)) isnum 1-3,$v1,3) }
alias _cpanel.updateDialog {
  var %x = 1, %i, %d = _cpanel, %t = $_cpanel.viewType, %last = $did(%d,1000,$did(%d,2).sel)
  did -u %d 101,102,103
  did -c %d $calc(100 + %t)
  did -r %d 2
  while ($_cpanel.itemInfo(%x)) {
    tokenize 167 $v1
    if (%t == 1) { did -ac %d 2 $upper($1) }
    elseif (%t == 2) { did -ac %d 2 $2 }
    else { did -ac %d 2 $upper($1) - $2 }
    did -i %d 1000 $did(%d,2).sel $3 $4 $2
    inc %x
  }
  did -u %d 2
  did -z %d 2
  did -f %d 1
  if ($didwm(%d,1000,%last)) { did -c %d 2 $v1 }
  _cpanel.clickOnList
}
alias _cpanel.clickOnList {
  var %ico = $_script.directory(Images,$null,Script.ico)
  if ($did(2).sel) { 
    var %text = $did(1000,$did(2).sel)
    did -ra $dname 4 $gettok(%text,3-,32) 
    if ($_script.directory(Images, i ,$gettok(%text,1,32))) { %ico = $v1 }
  }
  else { did -ra $dname 4 <not selected> }
  if ($isfile(%ico)) { did -g $dname 1 %ico }
  else { did -g $dname 1 1 $_mirc.exe }
}
alias _cpanel.itemInfo {
  if ($1 isnum 1-19) { goto $1 } 
  return
  :1 | return Userlist options§Userlist options§Users.ico§userlisto
  :2 | return General options§Main options dialog for you to edit main settings§Options.ico§general
  :3 | return Themes§Load and preview all available themes for you to change your display§Display.ico§themes
  :4 | return Event sounds§Config all event sounds with the sound that you want§Sound.ico§sounds
  :5 | return Filters§Avoid reading the useless wallops and snotices messages§Text.ico§filters
  :6 | return Channel protections§Protect global or specific channel from unwanted actions§Channel.ico§cprots
  :7 | return Nicklist§Channel nick coloring§Colors.ico§nlist
  :8 | return Nick completion§Easy way of typing a nick in the channel nicklist§Nickcomp.ico§ncomp
  :9 | return Images§Add, remove and replace all script backgrounds and bars images§Images.ico§images
  :10 | return Euro convert§Convert local currency to euro and euro to your local currency easily§Euro.ico§euro
  :11 | return Logs viewer§View and remove logs§Folder.ico§logs
  :12 | return Settings options§Settings system configuration§Sys.ico§settings
  :13 | return News§Check last news available like updates or tips informations§News.ico§news
  :14 | return Update§Download and install last available update from script server§Get.ico§update
  :15 | return Personal protections§Protect you from flood attacks on Text, CTCPs, Invites, etc.§Pprots.ico§pprots
  :16 | return Function keys§Configure function keys at your own way§Fkeys.ico§fkeys
  :17 | return Advanced options§All options that doesn't fit anywhere but here§Options.ico§advanced
  :18 | return Protections options§Personal and Channel protections advanced options§Options.ico§proto
  :19 | return Profiles§Use profiles to separate script sessions and it's options§users.ico§profiles
}




;___________[ player ]____________________________________

alias player { 
  var %d = _player, %c = player
  if ($1 != $null) {
    if ($1 == -o) { var %d = _player.options, %c = playeropt }
    else { 
      _themes.sintaxEcho player [-o]
      return
    }
  }
  _advanced.openDialog %d %c
}
alias mircamp { player }
alias playeropt { player -o }

dialog _player {
  title "Sound player"
  size -1 -1 237 258
  ;; size -1 -1 487 258
  option dbu

  box "", 1, 6 4 224 75
  text "STOPPED", 2, 16 15 204 8, center
  text "00:00 / 00:00", 3, 16 28 50 8, center
  text "-", 4, 73 28 41 8, center
  text "-", 5, 117 28 41 8, center

  check "R", 20, 166 28 11 9, push
  check "C", 21, 177 28 11 9, push
  check "P", 22, 209 28 11 9, push
  check "M", 23, 188 28 11 9, push

  text "Time:", 40, 15 47 16 8
  scroll "", 41, 39 47 181 8, horizontal bottom

  text "Volume:", 60, 15 61 20 8
  scroll "", 61, 39 61 70 8, horizontal bottom

  button "<<", 100, 120 60 20 10
  button "|>", 101, 140 60 20 10
  check "||", 102, 160 60 20 10, disable push
  button "[]", 103, 180 60 20 10, disable
  button ">>", 104, 200 60 20 10

  list 500, 6 85 224 174, size extsel hsbar
  list 1000, 0 0 0 0, hide disable size extsel
  ;; list 1000, 231 7 251 241, size extsel hsbar

  menu "&File", 1800
  item "&Options...", 1801, 1800
  item break, 1802, 1800
  item "&Help...", 1803, 1800
  item break, 1804, 1800
  item "&Close", 1805, 1800

  menu "    ", 1900

  menu "&Add", 2000
  item "&Directory...", 2001, 2000
  item "&File...", 2002, 2000

  menu "&Remove", 2200
  item "&All", 2201, 2200
  item break, 2202, 2200
  item "&Selected", 2203, 2200
  item "&Unselected (crop)", 2204, 2200
  item break, 2205, 2200
  item "&Remove dead file(s)", 2206, 2200
  item "&Physically remove selected file(s)", 2207, 2200

  menu "&Select", 2400
  item "S&elect all", 2401, 2400
  item "&Unselect all", 2402, 2400
  item break, 2403, 2400
  item "&Invert selection", 2404, 2400

  menu "S&ort", 2600
  item "By &title", 2601, 2600
  item break, 2602, 2600
  item "By &filename", 2603, 2600
  item "By &path", 2604, 2600
  item "By p&ath filename", 2605, 2600
  item break, 2606, 2600
  item "By &length", 2607, 2600
  item break, 2608, 2600
  item "&Reverse order", 2609, 2600
  item "Ra&mdomize order", 2610, 2600

  menu "    ", 2700

  menu "&Playlist", 2800
  item "&New", 2801, 2800
  item break, 2802, 2800
  item "&Load...", 2803, 2800
  item "&Save...", 2804, 2800
}
on *:DIALOG:_player:*:*:{
  if ($devent == SCROLL) {
    if ($did == 41) {
      if ($insong.fname == $gettok($_script.variableValue(Player,CurrentPlayInfo),1,9)) {
        var %x = $did(41).sel, %y = $insong.length
        set -u2 $_script.variableName(Player,UsingEditToInfos) 1
        did -ra $dname 2 SEEK TO: $_player.timeFormat(%x,m) $+ / $_player.timeFormat(%y,m) < $+ $_math.percentage(%x,%y,0) $+ >
        splay seek %x
      }
    }
    elseif ($did == 61) { 
      set -u2 $_script.variableName(Player,UsingEditToInfos) 1
      did -ra $dname 2 VOLUME: $_math.percentage($did(61).sel,65535,0)
      vol -v $did(61).sel 
    }
  }
  elseif ($devent == INIT) {
    _player.mainTimer
    _player.showHidePlaylist
    did -z $dname 61 0 65535
    did -c $dname 61 $vol(master)
    if ($vol(master).mute) { did -c $dname 23 }
    if ($_player.getOption(RandomPlay)) { did -c $dname 20 }
    if ($_player.getOption(ContinuousPlay)) { did -c $dname 21 }
    if ($_player.getOption(LoadLastPlaylistOnStart))  {
      _player.playlistMenu load $_player.getOption(LastLoadedPlaylist)
      if ($_player.getOption(AutoPlayOnStart)) { _player.handleSound play }
    }
  }
  elseif ($devent == MENU) {
    if ($did == 1801) { player -o }
    elseif ($did == 1803) { ;;; }
    elseif ($did == 1805) { dialog -c $dname }
    elseif ($did == 2001) { _player.addMenu directory }
    elseif ($did == 2002) { _player.addMenu file }
    elseif ($did == 2201) { _player.removeMenu all }
    elseif ($did == 2203) { _player.removeMenu selected }
    elseif ($did == 2204) { _player.removeMenu unselected }
    elseif ($did == 2206) { _player.removeMenu dead }
    elseif ($did == 2207) { _player.removeMenu physic }
    elseif ($did == 2401) { _player.selectMenu all }
    elseif ($did == 2402) { _player.selectMenu unselectall }
    elseif ($did == 2404) { _player.selectMenu invert }
    elseif ($did == 2601) { _player.sortMenu title }
    elseif ($did == 2603) { _player.sortMenu filename }
    elseif ($did == 2604) { _player.sortMenu path }
    elseif ($did == 2605) { _player.sortMenu pathfilename }
    elseif ($did == 2607) { _player.sortMenu length }
    elseif ($did == 2609) { _player.sortMenu reverse }
    elseif ($did == 2610) { _player.sortMenu randomize }
    elseif ($did == 2801) { _player.playlistMenu new }
    elseif ($did == 2803) { _player.playlistMenu load }
    elseif ($did == 2804) { _player.playlistMenu save }
  }
  elseif ($devent == SCLICK) {
    if ($did == 20) { _player.setOption RandomPlay $did(20).state }
    elseif ($did == 21) { _player.setOption ContinuousPlay $did(21).state }
    elseif ($did == 22) { _player.showHidePlaylist $did(22).state }
    elseif ($did == 23) { vol -vu $+ $iif($did(23).state,1,2) }
    elseif ($did == 100) { _player.handleSound backward }
    elseif ($did == 101) { _player.handleSound play }
    elseif ($did == 102) { _player.handleSound pause }
    elseif ($did == 103) { _player.handleSound stop } 
    elseif ($did == 104) { _player.handleSound forward }
  }
  elseif ($devent == DCLICK) {
    if ($did == 500) { _player.handleSound play }
  }
  elseif ($devent == CLOSE) {
    if ($insong.fname != $null) && ($v1 == $_script.variableValue(Player,CurrentPlayFile)) { splay stop }
  }
}
alias -l _player.showHidePlaylist {
  if ($1 isnum 0-1) { _player.setOption ShowPlaylist $1 } 
  var %dname = _player, %show = $_player.getOption(ShowPlaylist), $&
    %xywh = $dialog(%dname).x $dialog(%dname).y $dialog(%dname).cw $calc($iif(%show,276,95) * $dbuh)
  dialog -s %dname %xywh
  did $iif(%show,-c,-u) %dname 22
}
alias -l _player.isSupportedFile {
  var %file = $remove($1-,"), %ext = $gettok(%file,-1,46)
  if ($istok($_player.supportedExtensions,%ext,32)) { return %file }
}
alias -l _player.supportedExtensions { return mp3 ogg wma }
alias -l _player.titleFormat {
  var %desc = $1-
  if ($_player.getOption(Convert20ToSpaces)) { %desc = $replace(%desc,$(%20),$chr(32)) }
  if ($_player.getOption(ConvertUnderscoreToSpaces)) { %desc = $replace(%desc,_,$chr(32)) }
  return %desc
}
alias -l _player.timeFormat {
  var %len = $1
  if ($2 == m) { %len = $calc(%len / 1000) }
  if (%len isnum 0-) {
    if (%len < 3600) { return $asctime(%len,nn:ss) }
    return $asctime(%len,HH:nn:ss)
  }
  return ??:??:??
}
alias -l _player.addFileToLists {
  ; <filename> <desc> <timeformat> <kbps> <khz> <complete length>
  var %d = _player, %string = $1-, %time = $_player.getOption(ListTime), %num = $_player.getOption(ListNumbers)
  tokenize 9 $1-
  if (!$didwm(%d,1000,$+($1,$chr(9),*))) {
    did -a %d 1000 %string
    if (%time && %num) { did -a %d 500 $+($did(%d,1000).lines,.) $2 ( $+ $3 $+ ) }
    elseif (%time) { did -a %d 500 $2 ( $+ $3 $+ ) }
    elseif (%num) { did -a %d 500 $+($did(%dname,1000).lines,.) $2 }
    else { did -a %d 500 $2 }
  }
}
alias -l _player.reorderMainList {
  var %d = _player, %x = 1, %time = $_player.getOption(ListTime), %num = $_player.getOption(ListNumbers)
  did -r %d 500
  while ($did(%d,1000,%x)) {
    tokenize 9 $v1
    if (%time && %num) { did -a %d 500 $+(%x,.) $2 ( $+ $3 $+ ) }
    elseif (%time) { did -a %d 500 $2 ( $+ $3 $+ ) }
    elseif (%num) { did -a %d 500 $+(%x,.) $2 }
    else { did -a %d 500 $2 }
    inc %x
  }
}
alias -l _player.checkLengthOrNot {
  if (!$_player.getOption(GetSoundLengthOnAdd)) { return 0 }
  return $iif($sound($1-).length isnum,$v1,0)
}
alias -l _player.addMenu {
  var %d = _player, %file, %dur, %desc, %len
  goto $1
  :directory
  var %dir = $_prompt.selectDirectory($sound(mp3),Player - Select directory to add,AddDirectoryToPlayer), %dir = $_file.fixName(%dir)
  dialog -v %d
  if ($isdir(%dir)) {
    var %x = 1, %file, %dur, %desc, %len
    while ($findfile(%dir,*.*,%x)) {
      if ($_player.isSupportedFile($v1)) {
        %file = $v1
        %desc = $_player.titleFormat($left($nopath(%file),-4))
        %len = $_player.checkLengthOrNot(%file)
        %dur = $_player.timeFormat(%len,m)
        _player.addFileToLists $+(%file,$chr(9),%desc,$chr(9),%dur,$chr(9),0,$chr(9),0,$chr(9),%len)
      }
      inc %x
    }
  }
  return 
  :file
  %file = $_prompt.selectFile($sound(mp3) $+ *. $+ $replace($_player.supportedExtensions,$chr(32),;*.),Player - Select file to add,PlayerAddFileToList)
  dialog -v %d
  %desc = $_player.titleFormat($left($nopath(%file),-4))
  %len = $_player.checkLengthOrNot(%file)
  %dur = %dur = $_player.timeFormat(%len,m)
  if ($_player.isSupportedFile(%file)) { _player.addFileToLists $+(%file,$chr(9),%desc,$chr(9),%dur,$chr(9),0,$chr(9),0,$chr(9),%len) }
}
alias _player.removeMenu {
  var %d = _player, %order = 0
  goto $1

  :all
  did -r %d 500,1000
  return

  :unselected
  _dialog.invertListSelections %d 500

  :selected
  var %y = $did(%d,500,0).sel
  while (%y != 0) {
    did -ukd %d 500,1000 $did(%d,500,%y).sel
    %order = 1
    dec %y
  }
  goto end

  :dead
  var %x = $did(%d,1000).lines, %f
  while ($did(%d,1000,%x) != $null) {
    %f = $gettok($v1,1,9)
    if (!$isfile(%f)) || (!$_player.isSupportedFile(%f)) {
      did -d %d 500,1000 %x
      %order = 1
    }
    dec %x
  }
  goto end

  :physic
  var %y = $did(%d,500,0).sel, %x = %y, %file
  if (!%y) || (!$_prompt.yesNo(This command will delete all selected files permanently from disk. Continue?"Sound player)) { return }
  while (%x >= 1) {
    %y = $did(%d,500,%x).sel
    %file = $_file.fixName($gettok($did(%d,1000,%y),1,9))
    did -ukd %d 500 %y
    did -d %d 1000 %y
    %order = 1
    if ($isfile(%file)) { .remove -b %file }
    dec %x
  }

  :end
  if (%order) { _player.reorderMainList }
}
alias _player.selectMenu {
  var %d = _player
  goto $1

  :all
  var %y = $did(%d,500).lines, %x = 1
  while (%x <= %y) {
    did -ck %d 500 %x
    inc %x
  }
  return

  :unselectall
  did -u %d 500
  return

  :invert 
  _dialog.invertListselections %d 500
}
alias _player.sortMenu {
  var %d = _player, %win = @_temp._player.sortMenu, %line1, %line2
  _window.open -hls %win
  goto $1

  :title
  :pathfilename
  :length
  var %x = 1, %ntok
  if ($1 == pathfilename) { %ntok = 1 }
  elseif ($1 == length) { %ntok = 3) }
  else { %ntok = 2 }
  while ($did(%d,1000,%x) != $null) {
    %line2 = $v1
    %line1 = $did(%d,500,%x)
    aline %win $+($gettok(%line2,%ntok,9),",%line1,",%line2)
    inc %x
  }
  goto end

  :filename
  var %x = 1
  while ($did(%d,1000,%x) != $null) {
    %line2 = $v1
    %line1 = $did(%d,500,%x)
    aline %win $+($nopath($gettok(%line2,1,9)),",%line1,",%line2)
    inc %x
  }
  goto end

  :path
  var %x = 1
  while ($did(%d,1000,%x) != $null) {
    %line2 = $v1
    %line1 = $did(%d,500,%x)
    aline %win $+($nofile($gettok(%line2,1,9)),",%line1,",%line2)
    inc %x
  }
  goto end

  :reverse
  :randomize
  var %x = $did(%d,1000).lines, %win = @_temp._player.sortMenu2
  _window.open -hl %win
  if ($1 == reverse) {
    while (%x) {
      %line2 = $did(%d,1000,%x)
      %line1 = $did(%d,500,%x)
      aline %win $+(X,",%line1,",%line2)
      dec %x
    }
  }
  else {
    while (%x) {
      var %r = $rand(1,%x)
      aline %win $+(X,",$did(%d,500,%r),",$did(%d,1000,%r))
      did -d %d 500,1000 %r
      dec %x
    }
  }

  :end
  did -r %d 1000
  var %x = 1
  while ($line(%win,%x) != $null) {
    _player.addFileToLists $gettok($v1,3-,34)
    inc %x
  }
  _player.reorderMainList
  close -@_temp._player.sortMenu*
}
alias _player.playlistMenu {
  var %dname = _player
  goto $1

  :NEW
  did -r %dname 500,1000
  return

  :LOAD
  var %playlistSpecified = $iif($2 != $null,1,0), $&
    %file = $_file.fixName($iif($2,$2-,$$_prompt.selectFile($+($sound(mp3),*.m3u;*.pls;*.b4s),Player - Select playlist to load,PlayerSelectPlaylist))), %win = @_temp._player.playlistMenu, %line
  if (!$isfile(%file)) { return }
  _player.setOption LastLoadedPlaylist %file
  if ($_player.getOption(DeletePlaylistOnLoad)) { did -r %dname 500,1000 }
  if ($_file.isExtension(%file,m3u)) {
    _window.open -hl %win
    loadbuf %win %file
    dialog -v %dname
    var %mp3file, %mp3desc, %mp3dur, %x = 1, %y = $line(%win,0)
    while (%x <= %y) {
      %line = $line(%win,%x)
      if (#EXTINF:*,* iswm %line) { var %mp3desc = $gettok(%line,2-,44), %len = $gettok($gettok(%line,1,44),2,58) }
      elseif (%line != #EXTM3U) {
        %mp3file = %line
        if ($_player.isSupportedFile(%mp3file)) {
          %mp3file = $v1
          if (?:* !iswm %mp3file) {
            if (\* iswm %mp3file) { %mp3file = $+($mid(%file,1,2),%mp3file) } 
            else { %mp3file = $+($nofile(%file),%mp3file) } 
          }
          %mp3dur = $_player.timeFormat(%len)
          if (%mp3desc == $null) { %mp3desc = $left($nopath(%mp3file),-4) }
          %mp3desc = $_player.titleFormat(%mp3desc)
          _player.addFileToLists $+(%mp3file,$chr(9),%mp3desc,$chr(9),%mp3dur,$chr(9),0,$chr(9),0,$chr(9),$+(%len,000))
        }
      }
      inc %x
    }
    goto end
  }
  elseif ($_file.isExtension(%file,pls)) {
    if ($readini(%file,playlist,version) != 2) {
      _prompt.error Only v2 PLS files are supported. Halted."Sound player
      dialog -v %dname
      return
    }
    var %y = $readini(%file,playlist,NumberOfEntries), %x = 1
    if (%y !isnum 1-) {
      _prompt.error No entries were found in the playlist."Sound player
      dialog -v %dname 
      return
    }
    dialog -v %dname
    while (%x <= %y) {
      var %mp3file = $readini(%file,playlist,$+(File,%x)), %len = $readini(%file,playlist,$+(Length,%x)), %mp3desc = $readini(%file,playlist,$+(Title,%x)), %mp3dur
      if ($_player.isSupportedFile(%mp3file) != $null) {
        %mp3file = $v1
        if (?:* !iswm %mp3file) {
          if (\* iswm %mp3file) { %mp3file = $+($mid(%file,1,2),%mp3file) } 
          else { %mp3file = $+($nofile(%file),%mp3file) } 
        }
        %mp3dur = $_player.timeFormat(%len)
        if (%mp3desc == $null) { %mp3desc = $left($nopath(%mp3file),-4) }
        %mp3desc = $_player.titleFormat(%mp3desc)
        _player.addFileToLists $+(%mp3file,$chr(9),%mp3desc,$chr(9),%mp3dur,$chr(9),0,$chr(9),0,$chr(9),$+(%len,000))
      }
      inc %x
    }
    goto end
  }
  elseif ($_file.isExtension(%file,b4s)) {
    _window.open -hl %win
    loadbuf %win %file
    if ($int($gettok($line(%win,1),2,34)) != 1) {
      _prompt.error Only v1.0 B4S files are supported. Halted."Sound player
      dialog -v %dname
      return
    }
    dialog -v %dname
    var %x = 5, %y = $calc($line(%win,0) - 2)
    while (%x <= %y) {
      tokenize 32 $line(%win,%x)
      if (<entry *> iswm $1-) { var %mp3file = $right($gettok($1-,2,34),-5) }
      elseif (<Name>* iswm $1-) { var %mp3desc = $left($right($1-,-6),-7) }
      elseif (<Length>* iswm $1-) { var %fulllength = $left($right($1-,-8),-9), %mp3dur = $calc(%fulllength / 1000) }
      elseif (</entry> iswm $1-) {
        if ($_player.isSupportedFile(%mp3file) != $null) {
          %mp3file = $replace($v1,&apos;,')
          %mp3desc = $_player.titleFormat($replace(%mp3desc,&apos;,'))
          %mp3dur = $_player.timeFormat(%mp3dur)
          if (%mp3desc == $null) { %mp3desc = $left($nopath(%mp3file),-4) }
          _player.addFileToLists $+(%mp3file,$chr(9),%mp3desc,$chr(9),%mp3dur,$chr(9),0,$chr(9),0,$chr(9),%fulllength)
        }
      }
      inc %x
    }
    goto end
  }
  else { 
    _prompt.error Unsupported playlist file extension. Only 'b4s', 'pls' and 'm3u' can be loaded."Sound player
    dialog -v %dname
  }
  return
  :END
  window -c %win
  if ($_player.getOption(SortFilesOnLoad)) { 
    var %n = $_player.getOption(SortFilesOnLoadBy), %n = $iif($istok(1.3.4.5.7.9.10,%n,46),%n,1)
    _player.sortMenu $gettok(title. .filename.path.pathfilename. .length. .reverse.randomize,%n,46)
  }
  if (!%playlistSpecified) {
    if ($insong.fname != $null) && ($v1 == $_script.variableValue(Player,CurrentPlayFile)) { splay stop }
    _player.handleSound play
  }
  return

  :SAVE
  var %file = $_file.fixName($iif($2,$2-,$$_prompt.selectFile($+($sound(mp3),*.m3u;*.pls;*.b4s),Player - Save playlist as,PlayerSavePlaylist))), %ext = $remove($gettok(%file,-1,46),"), %x = 1
  _player.setOption LastLoadedPlaylist %file
  if ($istok(m3u pls b4s,%ext,32)) {
    if ($isfile(%file)) && (!$_prompt.yesNo(File already exists. Overwrite?"Sound player)) { return }
    dialog -v %dname
    goto %ext

    :m3u
    write -c %file #EXTM3U
    while ($did(%dname,1000,%x) != $null) {
      var %i = $v1, %len = $iif($left($gettok(%i,6,9),-3) isnum,$v1,0), %mfile = $gettok(%i,1,9), %desc = $gettok(%i,2,9)
      write %file $+(#EXTINF:,%len,$chr(44),%desc)
      write %file $remove(%mfile,") 
      inc %x
    }
    return

    :pls
    var %w = writeini -n %file Playlist
    while ($did(%dname,1000,%x) != $null) {
      var %i = $v1, %len = $left($gettok(%i,6,9),-3), %mfile = $gettok(%i,1,9), %desc = $gettok(%i,2,9)
      %w $+(File,%x) %mfile
      %w $+(Title,%x) %desc
      %w $+(Length,%x) $iif(%len isnum 1-,%len,0)
      inc %x
    } 
    %w NumberOfEntries %x
    %w Version 2
    return

    :b4s
    write -c %file <?xml version="1.0" encoding='UTF-8' standalone="yes"?>
    write %file <WinampXML>
    write %file <!-- Generated by: $_script.name v $+ $_script.version (Sound player) by $_script.author -->
    write %file <playlist num_entries=" $+ $did(%dname,1000).lines $+ " label=" $+ $_script.name $+ ">
    while ($did(%dname,1000,%x) != $null) {
      var %i = $v1, %len = $gettok(%i,6,9), %mfile = $gettok(%i,1,9), %desc = $gettok(%i,2,9)
      write %file <entry Playstring="file: $+ $remove(%mfile,") $+ ">
      write %file $+(<Name>,%desc,</Name>)
      write %file $+(<Length>,%len,</Length>)
      write %file </entry>
      inc %x
    }
    write %file </playlist>
    write %file </WinampXML>
  }
  else { 
    _prompt.error Unsupported playlist file extension. Only 'b4s', 'pls' and 'm3u' can be correctly saved."Sound player
    dialog -v %dname
  }
}
alias -l _player.handleSound {
  var %dname = _player
  if (!$dialog(%dname)) { return }
  if ($1 == play) {
    var %sel1, %file
    if ($did(%dname,500,1).sel) { %sel1 = $v1 }
    elseif ($_player.getOption(RamdomPlay)) { %sel1 = $rand(1,$did(%dname,500).lines) }
    else { %sel1 = 1 }
    goto playThatFile?
  }
  elseif ($1 == stop) {
    splay stop
    set $_script.variableName(Player,PlayingSound) 0
    did -b %dname 102,103
    did -u %dname 102
    did -u %dname 41
  }
  elseif ($1 == backward) || ($1 == forward) {
    var %sel1, %file, %currLine = $_script.variableValue(Player,CurrentPlayLine), %lines = $did(%dname,500).lines
    if ($1 == backward) {
      if ($_player.getOption(RamdomPlay)) { %sel1 = $rand(1,%lines) }
      elseif (%currLine == 1) { %sel1 = %lines }
      elseif (%currLine isnum $+(2-,%lines)) { %sel1 = $calc(%currLine - $iif($int($_player.getOption(BackwardN)) isnum 2-,$v1,1)) }
      else { %sel1 = 1 }
    }
    else {
      if ($_player.getOption(RamdomPlay)) { %sel1 = $rand(1,%lines) }
      elseif (%currLine == %lines) { %sel1 = 1 }
      elseif (%currLine isnum $+(1-,%lines)) { %sel1 = $calc(%currLine + $iif($int($_player.getOption(ForwardN)) isnum 2-,$v1,1)) }
      else { %sel1 = 1 }
    }
    goto playThatFile?
  }
  elseif ($1 == pause) {
    if ($did(%dname,102).state) {
      if ($insong) { 
        splay pause
        set $_script.variableName(Player,PlayingSound) 0
      }
    }
    else {
      splay resume
      set $_script.variableName(Player,PlayingSound) 1
    }
  }
  return

  :playThatFile?
  if (%sel1 isnum 1-) { %file = $gettok($did(%dname,1000,%sel1 - 1),1,9) }
  if ($isfile(%file)) {
    var %line2 = $did(%dname,1000,%sel1), %len = $sound(%file).length, %tf = $_player.timeFormat(%len,m), %desc = $gettok(%line2,2,9), $&
      %kbps = $iif($sound(%file).bitrate != $null,$v1,0), %khz = $iif($round($calc($sound(%file).sample / 1000),1) != $null,$v1,0)
    did -o %dname 1000 %sel1 $puttok(     $puttok(   $puttok(%line2,%tf,3,9)  ,%kbps,4,9)   ,%khz,5,9) $+ $+($chr(9),%len)
    %line2 = $did(%dname,1000,%sel1)
    var %time = $_player.getOption(ListTime), %num = $_player.getOption(ListNumbers)
    if (%time && %num) { did -oc %dname 500 %sel1 $+(%sel1,.) %desc ( $+ %tf $+ ) }
    elseif (%time) { did -oc %dname 500 %sel1 %desc ( $+ %tf $+ ) }
    elseif (%num) { did -oc %dname 500 %sel1 $+(%sel1,.) %desc }
    else { did -oc %dname 500 %sel1 %desc }
    .splay -p $_file.fixName(%file)
    if ($insong.fname != %file) {
      _prompt.error Unable to play sound file. Check if Windows Media Player is correctly installed and/or if your system supports this file extension (. $+ $gettok(%file,-1,46) $+ )"Sound player
      goto end
    }
    did -e %dname 102,103
    set $_script.variableName(Player,PlayingSound) 1
    set $_script.variableName(Player,CurrentPlayLine) %sel1
    set $_script.variableName(Player,CurrentPlayInfo) %line2
    set $_script.variableName(Player,CurrentPlayFile) %file
    if ($_player.advertise == 2) { _player.performAdvertise }
    else { _player.advertiseTimer }
  }
  else {
    if ($insong) { splay stop }
    :end
    did -b %dname 102,103
    unset $_script.variableName(Player,PlayingSound)
    unset $_script.variableName(Player,CurrentPlayLine)
    unset $_script.variableName(Player,CurrentPlayInfo)
  }
}
on *:MP3END: {
  if (!$_player.getOption(ContinuousPlay)) { _player.handleSound stop }
  else { _player.handleSound forward }
}
alias -l _player.mainTimer {
  var %dname = _player, %timer = PLAYER~MAINTIMER
  if (!$dialog(%dname)) { .timer $+ %timer off }
  elseif ($timer(%timer)) {
    var %fname = $insong.fname, %line2 = $_script.variableValue(Player,CurrentPlayInfo)
    if (%fname != $null) && (%fname == $gettok(%line2,1,9)) {
      var %pos = $insong.pos, %len = $insong.length, $&
        %desc = $iif($gettok(%line2,2,9) != $null,$v1,$_id3.fileProp(%fname).file), $&
        %at = $_player.timeFormat(%pos,m), %t = $_player.timeFormat(%len,m), $&
        %br = $gettok(%line2,4,9), %b = $gettok(%line2,5,9)
      if (!$_script.variableValue(Player,UsingEditToInfos)) { did -ra %dname 2 $iif(!$_script.variableValue(Player,PlayingSound),PAUSED:) %desc }
      did -ra %dname 3 $iif(%at,%at,00:00) / $iif(%t,%t,00:00) 
      did -ra %dname 4 $iif(%br isnum 1-,%br,0) $+ Kbps
      did -ra %dname 5 $iif(%b isnum 1-,%b,0) $+ KHz
      if (%len > %pos) { 
        did -z %dname 41 0 %len
        did -c %dname 41 %pos
      }
    }
    else {
      did -ra %dname 2 STOPPED
      did -ra %dname 3 00:00 / 00:00
      did -ra %dname 4 0Kbps
      did -ra %dname 5 0KHz
    }
  }
  else { .timer $+ %timer -im 0 500 _player.mainTimer }
}
; options
dialog _player.options {
  title "Sound player options"
  size -1 -1 273 172
  option dbu

  tab "&Player", 1, 4 4 264 142

  box "&Display:", 2, 10 20 116 61, tab 1
  check "&Show music time in playlist", 3, 17 31 105 10, tab 1
  check "Sho&w numbers in playlist", 4, 17 42 105 10, tab 1
  check "Co&nvert %20 to space in titles", 5, 17 53 105 10, tab 1
  check "Con&vert underscore to space in titles", 6, 17 64 105 10, tab 1

  box "P&laylist:", 10, 132 20 130 61, tab 1
  check "&Load last playlist on dialog start", 11, 139 31 100 10, tab 1
  check "Dele&te previous playlist files on load", 12, 139 42 100 10, tab 1
  check "So&rt files on load:", 13, 139 53 53 10, tab 1
  combo 14, 193 53 61 50, tab 1 size drop
  check "&Get sound length when adding sound (slow)", 15, 139 64 119 10, tab 1

  box "Pla&ying:", 20, 10 84 252 55, tab 1
  text "...&backward:", 21, 142 111 36 8, tab 1
  edit "", 22, 180 110 74 11, tab 1 autohs right
  text "...for&ward:", 23, 142 122 36 8, tab 1
  edit "", 24, 180 121 74 11, tab 1 autohs right
  check "A&uto-play on sound player start", 25, 17 96 100 10, tab 1
  text "Nu&mber of files to jump over when performing...", 26, 18 111 121 8, tab 1

  tab "Advert&ise", 50

  box "", 51, 10 20 252 46, tab 50
  radio "&No advertise", 52, 73 30 50 10, tab 50
  radio "Advertise e&very time a music starts", 53, 73 40 96 10, tab 50
  radio "&Advertise every", 54, 73 50 49 10, tab 50
  edit "", 55, 124 50 38 11, disable tab 50 autohs right
  text "seconds", 56, 163 52 22 8, tab 50
  box "", 60, 10 62 252 77, tab 50

  text "Advertise met&hod(s):", 61, 17 73 53 8, tab 50
  check "Cha&nnel action", 62, 75 72 50 10, tab 50
  check "&Query action", 63, 75 81 50 10, tab 50
  check "Ch&annel message", 64, 139 72 55 10, tab 50
  check "Q&uery message", 65, 139 81 55 10, tab 50
  check "&Status echo", 66, 209 72 43 10, tab 50
  check "&Active echo", 67, 209 81 43 10, tab 50

  text "&Advertise messa&ge:", 80, 17 95 54 8, tab 50
  edit "", 81, 74 94 180 11, tab 50 autohs
  button "&Add tag...", 82, 171 106 40 11, tab 50
  button "De&fault", 83, 213 106 40 11, tab 50
  text "Exempted network(s):", 85, 17 122 55 8, tab 50
  edit "", 86, 74 120 180 11, tab 50 autohs

  button "&Ok", 1000, 144 154 40 11, ok
  button "&Cancel", 999, 186 154 40 11, cancel
  button "&Help", 998, 228 154 40 11
}
on *:DIALOG:_player.options:*:*:{
  if ($devent == INIT) {
    unset $_script.variableName(Player,Options,*)
    var %t = $_player.getOption(LastSelectedTab)
    .timer -mi 1 0 did -c $dname $iif($istok(1 50,%t,32),%t,50)

    didtok $dname 14 44 By title, ,By filename,By path,By path filename, ,By length, ,Reverse order,Randomize Order

    if ($_player.getOption(ListTime)) { did -c $dname 3 }
    if ($_player.getOption(ListNumbers)) { did -c $dname 4 }
    if ($_player.getOption(Convert20ToSpaces)) { did -c $dname 5 }
    if ($_player.getOption(ConvertUnderscoreToSpaces)) { did -c $dname 6 }
    if ($_player.getOption(LoadLastPlaylistOnStart)) { did -c $dname 11 }
    if ($_player.getOption(DeletePlaylistOnLoad)) { did -c $dname 12 }
    if ($_player.getOption(SortFilesOnLoad)) { did -c $dname 13 }
    else { did -b $dname 14 }
    var %by = $_player.getOption(SortFilesOnLoadBy)
    did -c $dname 14 $iif($istok(1 3 4 5 7 9 10,%by,32),%by,1)
    if ($_player.getOption(GetSoundLengthOnAdd)) { did -c $dname 15 }
    did -a $dname 22 $iif($int($_player.getOption(BackwardN)) isnum 1-,$v1,1)
    did -a $dname 24 $iif($int($_player.getOption(ForwardN)) isnum 1-,$v1,1)
    if ($_player.getOption(AutoPlayOnStart)) { did -c $dname 25 }
    var %a = $_player.advertise
    if (%a == 1) { did -c $dname 52 }
    elseif (%a == 2) { did -c $dname 53 }
    else {
      did -c $dname 54 
      did -e $dname 55
    }
    did -a $dname 55 $_player.advertiseTime
    if ($_player.getOption(AdvertiseChannelAction)) { did -c $dname 62 }
    if ($_player.getOption(AdvertiseQueryAction)) { did -c $dname 63 }
    if ($_player.getOption(AdvertiseChannelMessage)) { did -c $dname 64 }
    if ($_player.getOption(AdvertiseQueryMessage)) { did -c $dname 65 }
    if ($_player.getOption(AdvertiseStatusEcho)) { did -c $dname 66 }
    if ($_player.getOption(AdvertiseActiveEcho)) { did -c $dname 67 }
    did -a $dname 81 $_player.advertiseMessage
    did -a $dname 86 $_player.getOption(ExemptedFromAdvertise)
  }
  elseif ($devent == SCLICK) {
    if ($did == 13) { did $iif($did(13).state,-e,-b) $dname 14 }
    elseif ($did isnum 52-54) { did $iif($did == 54,-e,-b) $dname 55 }
    elseif ($did == 82) { _tags.add $dname 81 PLAYER_OPTIONS_ADVERTISE &Sound advertise: }
    elseif ($did == 83) { did -ra $dname 81 $_player.advertiseMessage(default) }
    elseif ($did == 1000) {
      var %» _player.setOption, %modified = $_player.getOption(ListTime) $_player.getOption(ListNumbers)
      %» ListTime $did(3).state
      %» ListNumbers $did(4).state
      %» Convert20ToSpaces $did(5).state
      %» ConvertUnderscoreToSpaces $did(6).state
      %» LoadLastPlaylistOnStart $did(11).state
      %» DeletePlaylistOnLoad $did(12).state
      %» SortFilesOnLoad $did(13).state
      %» SortFilesOnLoadBy $did(14).sel
      %» GetSoundLengthOnAdd $did(15).state
      %» AutoPlayOnStart $did(25).state
      %» BackwardN $did(22)
      %» ForwardN $did(24)
      %» Advertise $iif($did(52).state,1,$iif($did(53).state,2,3))
      %» AdvertiseTime $did(55)

      %» AdvertiseChannelAction $did(62).state
      %» AdvertiseQueryAction $did(63).state
      %» AdvertiseChannelMessage $did(64).state
      %» AdvertiseQueryMessage $did(65).state
      %» AdvertiseStatusEcho $did(66).state
      %» AdvertiseActiveEcho $did(67).state
      %» AdvertiseMessage $did(81)
      %» ExemptedFromAdvertise $did(86)

      var %_modified = $did(3).state $did(4).state
      if (%_modified != %modified) { set $_script.variableName(Player,Options,ReorderMainList) 1 }
    }
  }
  elseif ($devent == CLOSE) { 
    var %d = _player
    if ($dialog(%d)) {
      player
      if ($_script.variableValue(Player,Options,ReorderMainList)) { _player.reorderMainList }
    }
    _player.setOption LastSelectedTab $dialog($dname).tab
  }
} 

alias _player.getOption { return $_script.getOption(Player,$1) }
alias _player.setOption { _script.setOption Player $1- }

alias -l _player.advertiseMessage {
  if ($1 != default) && ($_player.getOption(AdvertiseMessage) != $null) { return $v1 }
  return listening: <FILENAME2> (<FILESIZE>Mb - <TIME>s - <SAMPLE>KHz)
}
alias -l _player.advertiseTime { return $iif($int($_player.getOption(AdvertiseTime)) isnum 1-,$v1,180) }
alias -l _player.advertise { return $iif($int($_player.getOption(Advertise)) isnum 1-3,$v1,1) }
alias _player.advertiseTimer {
  var %dname = _player, %timer = PLAYER~ADVERTISE, %time = $_player.advertiseTime
  if ($_player.advertise != 3) || (!$dialog(%dname)) { .timer $+ %timer off }
  elseif (!$timer(%timer)) { .timer $+ %timer -i 0 %time _player.advertiseTimer }
  else { _player.performAdvertise }
  /*
  elseif ($timer(%timer)) && ($timer(%timer).delay == %time) { _player.performAdvertise }
  else { .timer $+ %timer -i 0 %time _player.advertiseTimer }
  */
}
alias -l _player.performAdvertise {
  var %dname = _player, %line = $_script.variableValue(Player,CurrentPlayInfo)
  if (!$dialog(%dname)) { return }
  tokenize 9 %line
  var %f = $1
  if ($0 >= 6) && ($isfile(%f)) {
    var %f = $_file.fixName(%f), %m = $_tags.evaluateDefaults($_player.advertiseMessage), %t

    if (<FILESIZE> isincs %m) { %m = $replacecs(%m,<FILESIZE>,$bytes($file(%f).size,m)) }
    if (<FILEPATH> isincs %m) { %m = $replacecs(%m,<FILEPATH>,$nofile(%f)) }
    if (<FILENAME> isincs %m) { %m = $replacecs(%m,<FILENAME>,%f) }
    if (<FILENAME2> isincs %m) { %m = $replacecs(%m,<FILENAME2>, $replacecs($gettok($nopath(%f),$+(1-,$calc($numtok(%f,46) - 1)),46),_,$chr(32)) ) }
    if (<SAMPLE> isincs %m) { %m = $replacecs(%m,<SAMPLE>,$5) }
    if (<TIME> isincs %m) { %m = $replacecs(%m,<TIME>,$3) }
    if (<SECS> isincs %m) { %m = $replacecs(%m,<SECS>,$iif($left($6,-3) isnum 1-,$v1,0)) }
    if (<MSECS> isincs %m) { %m = $replacecs(%m,<MSECS>,$6) }
    if (<TITLE> isincs %m) { %m = $replacecs(%m,<TITLE>,$iif($_id3.fileProp(%f).title != $null,$v1,$2)) }
    if (<ALBUM> isincs %m) { %m = $replacecs(%m,<ALBUM>,$_id3.fileProp(%f).album) }
    if (<YEAR> isincs %m) { %m = $replacecs(%m,<YEAR>,$_id3.fileProp(%f).year) }
    if (<GENRE> isincs %m) { %m = $replacecs(%m,<GENRE>,$_id3.fileProp(%f).genre) }
    if (<COMPOSER> isincs %m) { %m = $replacecs(%m,<COMPOSER>,$_id3.fileProp(%f).composer) }
    if (<O-ARTIST> isincs %m) { %m = $replacecs(%m,<O-ARTIST>,$_id3.fileProp(%f).o-artist) }
    if (<COPYRIGHT> isincs %m) { %m = $replacecs(%m,<COPYRIGHT>,$_id3.fileProp(%f).copyright) }
    if (<URL> isincs %m) { %m = $replacecs(%m,<URL>,$_id3.fileProp(%f).url) }
    if (<ENCODER> isincs %m) { %m = $replacecs(%m,<ENCODER>,$_id3.fileProp(%f).encoder) }
    if (<COMMENT> isincs %m) { %m = $replacecs(%m,<COMMENT>,$_id3.fileProp(%f).comment) }
    if (<TRACK> isincs %m) { %m = $replacecs(%m,<TRACK>,$_id3.fileProp(%f).track) }

    %m = $eval(%m,2)

    var %cAction = $_player.getOption(AdvertiseChannelAction), %cMsg = $_player.getOption(AdvertiseChannelMessage), %qAction = $_player.getOption(AdvertiseQueryAction), $&
      %qMsg = $_player.getOption(AdvertiseQueryMessage), %x = 1, %target, %y, %status, %exempted = $_player.getOption(ExemptedFromAdvertise)

    while ($scon(%x)) {
      %status = $false
      scon %x
      if ($istok(%exempted,$_network.active,32)) { goto next } 
      if (%cAction) || (%cMsg) {
        %y = 1
        while ($chan(%y)) {
          %target = $v1
          if (%cAction) { describe %target %m }
          if (%cMsg) { msg %target %m }
          inc %y
        }
      }
      if (%qAction) || (%qMsg) {
        %y = 1
        while ($query(%y)) {
          %target = $v1
          if (%qAction) { describe %target %m }
          if (%qMsg) { msg %target %m }
          inc %y
        }
      }
      if ($_player.getOption(AdvertiseStatusEcho)) { 
        echo $color(Info text) -sti2 You: %m
        %status = $true
      }
      if ($_player.getOption(AdvertiseActiveEcho)) {
        if ((%status) && ($active == Status Window)) || ((%status) && ($_window.activeIsWindow)) { return }
        echo $color(Info text) -ati2 !Me %m
      }
      :next
      inc %x
    }
  }
}

;______________[ (very simple) notepad ]__________________________________________

alias edit { notepad $1- }
alias notepad {
  :dname
  var %dname = _notepad- $+ $rand(1,1000000), %com
  if ($dialog(%dname)) { goto dname }
  if ($1 != $null) {
    if ($1 == -o) { %com = _notepad.openFile %dname }
    elseif ($isfile($1-)) { %com = _notepad.openFile %dname $1- }
    else {
      sintax notepad [-o|filename] 
      return
    }
  }
  _advanced.openDialog _notepad notepad %dname
  %com
}
dialog _notepad {
  title "No title - Notepad"
  size -1 -1 269 247
  option dbu

  menu "&File", 1
  item "&New", 2
  item "&Open...", 3
  item "&Save", 4
  item "Save &as...", 5
  item break, 6
  item "&Exit", 9

  menu "&Help", 50
  item "&Topics", 51

  edit "", 1000, 1 0 267 246, multi return autohs autovs vsbar hsbar

  edit "", 2000, 0 0 0 0, autohs disable hide              ; Current file
  edit "", 2001, 0 0 0 0, autohs disable hide              ; Already edited
}
on *:DIALOG:_notepad-*:*:*:{
  if ($devent == EDIT) && (!$did(2001)) && ($did == 1000) {
    did -ra $dname 2001 1
    dialog -t $dname $_notepad.titlebarFile($dname) $+ * - Notepad
  }
  elseif ($devent == MENU) {
    if ($did == 2) { _notepad.new $dname }
    elseif ($did == 3) { _notepad.openFile $dname }
    elseif ($did == 4) { _notepad.saveFile $dname }
    elseif ($did == 5) { _notepad.saveFileAs $dname }
    elseif ($did == 9) { _notepad.tryCloseDialog $dname }
    elseif ($did == 51) { ;;; }
  }
}
alias -l _notepad.tryCloseDialog {
  var %d = $1
  _notepad.askForSave %d
  if (!$result) { return }
  dialog -x %d
}
alias -l _notepad.titlebarFile { return $left($dialog($1).title,-10) }
alias -l _notepad.new {
  var %d = $1, %ask
  _notepad.askForSave %d
  if ($result) {
    did -r %d 1000,2000,2001
    dialog -t %d No title - Notepad
  }
}
alias -l _notepad.askForSave {
  var %d = $1
  if ($did(%d,2001)) {
    var %ask = $_prompt.yesNoCancel(Save changes in the current file before?"Notepad), %file = $did(%d,2000)
    if (%ask == $cancel) { return }
    elseif (%ask == $yes) {
      if ($isfile(%file)) { _notepad.saveFile %d } 
      else { _notepad.saveFileAs %d }
      if (!$result) { return }
    }
  }
  return 1
}
alias -l _notepad.openFile {  
  var %d = $1, %t = $_notepad.titlebarFile(%dname), %file
  _notepad.askForSave %d
  if ($result) {
    %file = $iif($2 != $null,$2-,$$_prompt.selectFile($mircdir*.txt,Notepad - Select file to open,NotepadOpenFile))
    did -r %d 1000
    if ($_file.isFile(%file)) {
      %file = $v1
      _script.setRecentOption 15 Notepad RecentFiles $remove(%file,")
      filter -fo %file %d 1000
      did -ra %d 2000 %file
      did -r %d 2001
      dialog -t %d $nopath(%file) - Notepad
    }
  }
}
alias -l _notepad.saveFile {
  var %d = $1, %file = $_file.fixName($did(%d,2000))
  if (!$did(%d,2001)) { return }
  elseif (!$isfile(%file)) { _notepad.saveFileAs %d }
  else {
    write -c %file
    filter -if %d 1000 %file
    dialog -t %d $nopath(%file) - Notepad
    did -r %d 2001
    return 1
  }
}
alias -l _notepad.saveFileAs {
  var %d = $1, %file = $_file.fixName($$_prompt.selectFile($mircdir*.txt,Notepad - Save file as,NotepadSaveFile))
  did -ra %d 2000 %file
  did -ra %d 2001 1
  write -c %file
  _notepad.saveFile %d
  return 1
}
alias _notepad.recentFilesMenuBar {
  if (!$isid) { 
    if ($1 == $null) { 
      if ($_prompt.yesNo(Do you really want to delete all files from list?"Notepad)) { _script.setOption Notepad RecentFiles }
    }
    else { 
      if ($int($_prompt.inputNumber(1,15,-,h,Delete Nth file:,Notepad - Recent list)) isnum 1-15) { _script.deleteRecentOption $v1 Notepad RecentFiles }
    }
  }
  elseif ($1 isnum 1-15) {
    var %data = $gettok($_script.getOption(Notepad,RecentFiles),$1,59) 
    if (%data != $null) {
      var %name = $gettok(%data,-1,92)
      return $1 $+ . %name : _notepad.recentFilesMenuBarRunIt $1
    } 
  }
}
alias _notepad.recentFilesMenuBarRunIt {
  var %n = $1, %all = $_script.getOption(Notepad,RecentFiles), %f = $gettok(%all,%n,59)
  if (!$isfile(%f)) || (%f == $null) {
    if ($_prompt.yesNo( $ord(%n) recent file doesn't exists. Remove it from list?"Notepad)) { _script.deleteRecentOption Notepad RecentFiles %n }
  }
  else { notepad %f }
}


;___________[ country ]____________________________________

alias _country.get {
  var %c = $1
  if (%c == $null) { return (Unknown) }
  goto %c
  :AD | return Andorra
  :AE | return United Arab Emirates
  :AF | return Afghanistan
  :AG | return Antigua and Barbuda
  :AI | return Anguilla
  :AL | return Albania
  :AM | return Armenia
  :AN | return Netherlands Antilles
  :AO | return Angola
  :AQ | return Antarctica
  :AR | return Argentina
  :AS | return American Samoa
  :AT | return Austria
  :AU | return Australia
  :AW | return Aruba
  :AZ | return Azerbaijan
  :BA | return Bosnia and Herzegovina
  :BB | return Barbados
  :BD | return Bangladesh
  :BE | return Belgium
  :BF | return Burkina Faso
  :BG | return Bulgaria
  :BH | return Bahrain
  :BI | return Burundi
  :BJ | return Benin
  :BM | return Bermuda
  :BN | return Brunei Darussalam
  :BO | return Bolivia
  :BR | return Brazil
  :BS | return Bahamas
  :BT | return Bhutan
  :BVvBouvet Island
  :BW | return Botswana
  :BY | return Belarus
  :BZ | return Belize
  :CA | return Canada
  :CC | return Cocos Islands
  :CF | return Central African Republic
  :CG | return Congo
  :CH | return Switzerland
  :CI | return Cote D'Ivoire (Ivory Coast)
  :CK | return Cook Islands
  :CL | return Chile
  :CM | return Cameroon
  :CN | return China
  :CO | return Colombia
  :CR | return Costa Rica
  :CS | return Former Czechoslovakia
  :CU | return Cuba
  :CV | return Cape Verde
  :CX | return Christmas Island
  :CY | return Cyprus
  :CZ | return Czech Republic
  :DE | return Germany
  :DJ | return Djibouti
  :DK | return Denmark
  :DM | return Dominica
  :DO | return Dominican Republic
  :DZ | return Algeria
  :EC | return Ecuador
  :EE | return Estonia
  :EG | return Egypt
  :EH | return Western Sahara
  :ER | return Eritrea
  :ES | return Spain
  :ET | return Ethiopia
  :FI | return Finland
  :FJ | return Fiji
  :FK | return Falkland Islands
  :FM | return Micronesia
  :FO | return Faroe Islands
  :FR | return France
  :FX | return France, Metropolitan
  :GA | return Gabon
  :GB | return Great Britain
  :GD | return Grenada
  :GE | return Georgia
  :GF | return French Guiana
  :GH | return Ghana
  :GI | return Gibraltar
  :GL | return Greenland
  :GM | return Gambia
  :GN | return Guinea
  :GP | return Guadeloupe
  :GQ | return Equatorial Guinea
  :GR | return Greece
  :GS | return South Georgia/South Sandwich Isls.
  :GT | return Guatemala
  :GU | return Guam
  :GW | return Guinea-Bissau
  :GYGuyana
  :HK | return Hong Kong
  :HM | return Heard and McDonald Islands
  :HN | return Honduras
  :HR | return Croatia
  :HT | return Haiti
  :HU | return Hungary
  :ID | return Indonesia
  :IE | return Ireland
  :IL | return Israel
  :IN | return India
  :IO | return British Indian Ocean Territory
  :IQ | return Iraq
  :IR | return Iran
  :IS | return Iceland
  :IT | return Italy
  :JM | return Jamaica
  :JO | return Jordan
  :JP | return Japan
  :KE | return Kenya
  :KG | return Kyrgyzstan
  :KH | return Cambodia
  :KI | return Kiribati
  :KM | return Comoros
  :KN | return Saint Kitts and Nevis
  :KP | return North Korea
  :KR | return South Korea
  :KW | return Kuwait
  :KY | return Cayman Islands
  :KZ | return Kazakhstan
  :LA | return Laos
  :LB | return Lebanon
  :LC | return Saint Lucia
  :LI | return Liechtenstein
  :LK | return Sri Lanka
  :LR | return Liberia
  :LS | return Lesotho
  :LT | return Lithuania
  :LU | return Luxembourg
  :LV | return Latvia
  :LY | return Libya
  :MA | return Morocco
  :MC | return Monaco
  :MD | return Moldova
  :MG | return Madagascar
  :MH | return Marshall Islands
  :MK | return Macedonia
  :ML | return Mali
  :MM | return Myanmar
  :MN | return Mongolia
  :MO | return Macau
  :MP | return Northern Mariana Islands
  :MQ | return Martinique
  :MR | return Mauritania
  :MS | return Montserrat
  :MT | return Malta
  :MU | return Mauritius
  :MV | return Maldives
  :MW | return Malawi
  :MX | return Mexico
  :MY | return Malaysia
  :MZ | return Mozambique
  :NA | return Namibia
  :NC | return New Caledonia
  :NE | return Niger
  :NF | return Norfolk Island
  :NG | return Nigeria
  :NI | return Nicaragua
  :NL | return Netherlands
  :NO | return Norway
  :NP | return Nepal
  :NR | return Nauru
  :NT | return Neutral Zone
  :NU | return Niue
  :NZ | return New Zealand
  :OM | return Oman
  :PA | return Panama
  :PE | return Peru
  :PF | return French Polynesia
  :PG | return Papua New Guinea
  :PH | return Philippines
  :PK | return Pakistan
  :PL | return Poland
  :PM | return St. Pierre and Miquelon
  :PN | return Pitcairn
  :PR | return Puerto Rico
  :PT | return Portugal
  :PW | return Palau
  :PY | return Paraguay
  :QA | return Qatar
  :RE | return Reunion
  :RO | return Romania
  :RU | return Russia
  :RW | return Rwanda
  :SA | return Saudi Arabia
  :SB | return Solomon Islands
  :SC | return Seychelles
  :SD | return Sudan
  :SE | return Sweden
  :SG | return Singapore
  :SH | return St. Helena
  :SI | return Slovenia
  :SJ | return Svalbard and Jan Mayen Islands
  :SK | return Slovak Republic
  :SL | return Sierra Leone
  :SM | return San Marino
  :SN | return Senegal
  :SO | return Somalia
  :SR | return Suriname
  :ST | return Sao Tome and Principe
  :SU | return USSR
  :SV | return El Salvador
  :SY | return Syria
  :SZ | return Swaziland
  :TC | return Turks and Caicos Islands
  :TD | return Chad
  :TF | return French Southern Territories
  :TG | return Togo
  :TH | return Thailand
  :TJ | return Tajikistan
  :TK | return Tokelau
  :TM | return Turkmenistan
  :TN | return Tunisia
  :TO | return Tonga
  :TP | return East Timor
  :TR | return Turkey
  :TT | return Trinidad and Tobago
  :TV | return Tuvalu
  :TW | return Taiwan
  :TZ | return Tanzania
  :UA | return Ukraine
  :UG | return Uganda
  :UK | return United Kingdom
  :UM | return US Minor Outlying Islands
  :US | return United States
  :UY | return Uruguay
  :UZ | return Uzbekistan
  :VA | return Vatican City State
  :VC | return Saint Vincent and the Grenadines
  :VE | return Venezuela
  :VG | return Virgin Islands (British)
  :VI | return Virgin Islands (U.S.)
  :VN | return Vietnam
  :VU | return Vanuatu
  :WF | return Wallis and Futuna Islands
  :WS | return Samoa
  :YE | return Yemen
  :YT | return Mayotte
  :YU | return Yugoslavia
  :ZA | return South Africa
  :ZM | return Zambia
  :ZR | return Zaire
  :ZW | return Zimbabwe
  :COM | return Commercial
  :EDU | return Educational
  :GOV | return Government
  :INT | return International
  :MIL | return Military
  :NET | return Network
  :ORG | return Organization
  :RPA | return Old Style Arpanet
  :ATO | return Nato Field
  :%c | return (Unknown)
}
alias country {
  if ($2 != $null) { _themes.sintaxEcho country [code] }
  else {
    var %c = $iif($1 != $null,$1,$_prompt.input(Code to translate:"~"Country"tch"CountryCodeLookUp)), %country = $_country.get(%c)
    _themes.commandEcho country $+(,$upper(%c),) location is: $+(,%country,)
  }
}


;___________[ alarm ]____________________________________

alias alarmopt { alarm -o }
alias alarm {
  ; /alarm <-tc> [HH:mm | Off] [N | Off]
  ; -t    - sets timed alarm to specified [HH:mm]
  ; -c   - sets countinuous alarm to act every [N] minutes, from 0 to 59, or turn it [Off]
  ; If [N] and/or [HH:mm] are not specified they are asked to you

  if ($1 == $null) { var %f = -t }
  else { var %f = $1 }
  if (!$_string.areValidFlags(%f,tco)) { 
    _themes.sintaxEcho alarm <-tco> [HH:mm|Off] [N|Off] 
    return
  }
  var %timer1 = ALARM~TIMED, %timer2 = ALARM~CONTINUOUS, %setedTimed = 0, %setedContinuous = 0, %notValidParam = 0
  if (t isin %f) {
    var %time = $2
    if (%time == Off) {
      .timer $+ %timer1 off
      _themes.commandEcho alarm Timed alarm turned OFF
    }
    else {
      var %to = $_alarm.isSetedTo
      if (%to != Off) && (!$_prompt.yesNo(Timed alarm already seted to $+(%to,.) Continue anyway?"Alarm)) { goto continuous }
      :checkTime
      var %hh = $gettok(%time,1,58), %mm = $gettok(%time,2,58)
      if (??:?? !iswm %time) || (%hh !isnum 00-23) || (%mm !isnum 00-59) { 
        var %time = $_prompt.input(Time to be alarmed in HH:mm format (HH from 00 to 23 and mm from 00 to 59):"~"Alarm"tc"AlarmTimedTo), %notValidParam = 1
        if (%time != $null) { goto checkTime }
      }
      if (%time != $null) {
        .timer $+ %timer1 %time 1 1 _alarm.action -t
        %setedTimed = 1
      }
    }
  }
  :continuous
  if (c isin %f) {
    var %minutes = $iif(%notValidParam || t !isin %f,$2,$3)
    if (%minutes == Off) {
      .timer $+ %timer2 off
      _themes.commandEcho alarm Continuous alarm turned OFF
    }
    else {
      var %to = $_alarm.isSetedTo(continuous)
      if (%to != Off) && (!$_prompt.yesNo(Continuous alarm already seted to act every %to minutes. Continue anyway?"Alarm)) { return }

      :checkMinutes
      if (%minutes !isnum 0-59) {
        %minutes = $_prompt.inputNumber(0,59,-,h,Set continuous alarm to act every N minutes:,Alarm)
        if (%minutes != $null) { goto checkMinutes }
      }
      if (%minutes != $null) {
        .timer $+ %timer2 $_alarm.getNextContinuousTime(%minutes) 1 1 _alarm.action -c
        %setedContinuous = 1
      }
    }
  }
  var %msg1, %msg2
  if (%setedTimed) { %msg1 = Timed alarm seted to $+(,%time,) }
  if (%setedContinuous) { %msg2 = $iif(%setedTimed,and continuous,Continuous) alarm will trigger every $+(,%minutes,) minutes }
  if (%msg1 || %msg2) { _themes.commandEcho alarm %msg1 %msg2 }
  if (o isin %f) { _advanced.openDialog _alarm.options alarmopt }
}
alias _alarm.isSetedTo {
  if ($1 == continuous) { return $iif($timer(ALARM~CONTINUOUS).time,$gettok($v1,2,58),Off) }
  return $iif($timer(ALARM~TIMED).time,$v1,Off)
}
alias _alarm.getNextContinuousTime {
  var %mm = $1
  if (%mm !isnum 0-59) { return }
  var %_hh = $gettok($time,1,58), %_mm = $gettok($time,2,58), %hh
  if (%_mm >= %mm) { %hh = $iif(%_hh == 23,00,$calc(%_hh + 1)) }
  else { %hh = %_hh }
  var %hh = $right($+(0,%hh),2), %mm = $right($+(0,%mm),2)
  return $+(%hh,:,%mm)
}
alias _alarm.action {
  if ($_script.getOption(Alarm,PlaySound)) && ($_file.isFile($_script.getOption(Alarm,PlaySoundFile))) { splay $v1 }
  if (c isin $1) { .timerALARM~CONTINUOUS $_alarm.getNextContinuousTime($gettok($time,2,58)) 1 1 _alarm.action -c }
  goto $_alarm.actionType
  :1 | _prompt.info $_alarm.evaluateString($_alarm.string(PopupMessage),$1) $+ "Alarm | return
  :2 | _themes.commandEcho Alarm $_alarm.evaluateString($_alarm.string(EchoMessage),$1) | return
  :3 | $_alarm.evaluateString($_alarm.string(CustomCommand),$1)
}
alias _alarm.evaluateString {
  var %m = $_tags.evaluateDefaults($1)
  return $eval($replacecs(%m,<TIME>,$time,<ALARM>,$iif(t isin $2,Timed,Continuous)),2)
}
dialog _alarm.options {
  title "Alarm options"
  size -1 -1 182 180
  option dbu

  box "&Action on alarm:", 1, 4 3 173 152
  radio "&Popup dialog with message:", 2, 11 15 107 10
  edit "", 3, 19 25 150 11, autohs disable
  button "A&dd tag...", 4, 86 37 40 11, disable
  button "D&efault", 5, 128 37 40 11, disable

  radio "&Echo this message to active window:", 6, 11 51 110 10
  edit "", 7, 19 61 150 11, autohs disable
  button "Add &tag...", 8, 86 73 40 11, disable
  button "De&fault", 9, 128 73 40 11, disable

  radio "C&ustom command:", 10, 11 87 59 10
  edit "", 11, 19 97 150 11, autohs disable
  button "Add ta&g...", 12, 86 109 40 11, disable
  button "Defa&ult", 13, 128 109 40 11, disable

  check "Pla&y this sound:", 14, 12 125 60 10
  edit "", 15, 19 135 127 11, autohs
  button "...", 16, 149 135 9 11
  button "!", 17, 159 135 9 11

  button "&Ok", 100, 52 162 40 11, ok
  button "&Cancel", 99, 94 162 40 11, cancel
  button "&Help", 98, 136 162 40 11
}
on *:DIALOG:_alarm.options:*:*:{
  if ($devent == INIT) {
    var %t = $_alarm.actionType
    if (%t == 1) { 
      did -c $dname 2
      did -e $dname 3,4,5 
    }
    elseif (%t == 2) { 
      did -c $dname 6
      did -e $dname 7,8,9
    }
    else { 
      did -c $dname 10
      did -e $dname 11,12,13
    }
    var %sound = $_file.isFile($_script.getOption(Alarm,PlaySoundFile))
    did -a $dname 15 $remove(%sound,")
    if ($_script.getOption(Alarm,PlaySound)) && (%file) { did -c $dname 14 }
    else { did -b $dname 15,16,17 }
    did -ra $dname 3 $_alarm.string(PopupMessage)
    did -ra $dname 7 $_alarm.string(EchoMessage)
    did -ra $dname 11 $_alarm.string(CustomCommand)
  }
  elseif ($devent == SCLICK) {
    if ($istok(4 8 12,$did,32)) { _tags.add $dname $calc($did - 1) ALARM_MESSAGE Alar&m: }
    if ($did == 5) { did -ra $dname 3 $_alarm.defaultStrings(PopupMessage) }
    elseif ($did == 9) { did -ra $dname 7 $_alarm.defaultStrings(EchoMessage) }
    elseif ($did == 13) { did -ra $dname 11 $_alarm.defaultStrings(CustomCommand) }
    elseif ($did == 2) {
      did -e $dname 3,4,5 
      did -b $dname 7,8,9,11,12,13
    }
    elseif ($did == 6) { 
      did -e $dname 7,8,9
      did -b $dname 3,4,5,11,12,13
    }
    elseif ($did == 10) { 
      did -e $dname 11,12,13
      did -b $dname 3,4,5,7,8,9
    }
    elseif ($did == 14) { did $iif($did(14).state,-e,-b) $dname 15,16,17 }
    elseif ($did == 16) { 
      var %f = $_prompt.selectFile($_file.fixName($+($sound(wav),*.wav)),Alarm - Select sound file,AlarmSoundFile)
      if (%f != $null) { did -ra $dname 15 %f }
    }
    elseif ($did == 17) {
      if ($_file.isFile($did(15))) { splay $v1 }
    }
    elseif ($did == 100) {
      var %» = _script.setOption Alarm
      %» ActionType $iif($did(2).state,1,$iif($did(6).state,2,3))
      %» PopupMessage $did(3)
      %» EchoMessage $did(7)
      %» CustomCommand $did(11)
      %» PlaySound $did(14).state
      %» PlaySoundFile $did(15)
    }
  }
}
alias _alarm.defaultStrings {
  var %t = $1
  goto %t
  :PopupMessage | return <ALARM> alarm activated at <TIME>. Wake up!
  :EchoMessage | return <ALARM> alarm activated at <TIME>. Wake up!
  :CustomCommand | return /flash Alarm!
  :%t
}
alias _alarm.string { return $iif($_script.getOption(Alarm,$1) != $null,$v1,$_alarm.defaultStrings($1)) }
alias _alarm.actionType { return $iif($int($_script.getOption(Alarm,ActionType)) isnum 1-3,$v1,1) }



;___________[ sstats ]____________________________________

alias sstats { _advanced.openDialog _sstats sstats }
dialog _sstats {
  title "Sockets statistics"
  size -1 -1 271 166
  option dbu

  box "&Open sockets (0):", 1, 5 5 97 136

  list 2, 11 16 84 104, size sort

  button "C&lose socket", 3, 12 122 40 11
  button "Close &all...", 4, 54 122 40 11

  box "&Socket information (<none>):", 5, 107 5 158 136

  text "IP:", 9, 115 18 39 8
  text "Type:", 10, 115 28 39 8
  text "Bytes sent:", 11, 115 54 39 8
  text "Last sent:", 12, 115 64 39 8
  text "Bytes receive:", 13, 115 80 39 8
  text "Last receive:", 14, 115 90 39 8
  text "Last source:", 15, 115 106 39 8
  text "Status:", 16, 115 38 39 8

  text "<ip>", 17, 156 18 100 8
  text "<type>", 18, 156 28 100 8
  text "<status>", 19, 156 38 100 8
  text "<bytes sent>", 20, 156 54 100 8
  text "<last sent>", 21, 156 64 100 8
  text "<bytes receive>", 22, 156 80 100 8
  text "<last receive>", 23, 156 90 100 8
  text "<last source>", 24, 156 106 100 8

  button "&Update", 30, 217 122 40 11

  button "&Close", 100, 182 148 40 11, cancel
  button "&Help", 99, 224 148 40 11
}
on *:DIALOG:_sstats:*:*:{
  if ($devent == INIT) { _sstats.updateList }
  elseif ($devent == SCLICK) {
    if ($did == 2) || ($did == 30) { _sstats.updateInformation } 
    elseif ($did == 3) {
      if ($did(2).seltext != $null) { sockclose $v1 }
      else { did -b $dname 3 }
      _sstats.updateList
    }
    elseif ($did == 4) {
      if ($sock(*,0)) && ($_prompt.yesNo(Do you really want to close all open sockets?"Sockets statistics)) { 
        sockclose * 
        _sstats.updateList
      }
    }
    elseif ($did == 99) { ;;; }
  }
}
alias _sstats.updateInformation {
  var %d = _sstats
  if ($dialog(%d)) {
    var %s = $did(%d,2).seltext
    if (%s == $null) {
      did -ra %d 5 &Socket information (<none>):
      did -ra %d 17,18,19,20,21,22,23,24 -
      did -b %d 3,30
    }
    else {
      did -ra %d 5 &Socket information ( $+ %s $+ ):
      did -e %d 3,30
      did -ra %d 17 $sock(%s).ip (Port: $sock(%s).port $+ )
      did -ra %d 18 $upper($sock(%s).type)
      did -ra %d 19 $sock(%s).status
      did -ra %d 20 $bytes($sock(%s).sent,b).suf (Queued buffer: $bytes($sock(%s).sq,b).suf $+ )
      did -ra %d 21 $duration($sock(%s).ls) ago
      did -ra %d 22 $bytes($sock(%s).rcvd,b).suf (Queued buffer: $bytes($sock(%s).rq,b).suf $+ )
      did -ra %d 23 $duration($sock(%s).lr) ago
      if ($sock(%s).saddr != $null) { did -ra %d 24 $v1 (Port: $sock(%s).sport $+ ) }
      else { did -ra %d 24 - }
    }
  }
}
alias _sstats.updateList {
  var %d = _sstats
  if ($dialog(%d)) {
    var %x = 1, %y = $sock(*,0)
    did -r %d 2
    did -ra %d 1 &Open sockets ( $+ %y $+ ):
    did -ra %d 5 &Socket information (<none>):
    did -ra %d 17,18,19,20,21,22,23,24 -
    did -b %d 3,30
    did $iif(%y,-e,-b) %d 4
    while (%x <= %y) {
      did -a %d 2 $sock(*,%x)
      inc %x
    }
  }
}



;___________[ mixer ]____________________________________

alias mixer { _advanced.openDialog _mixer mixer }
dialog _mixer {
  title "Sound mixer"
  size -1 -1 143 172
  option dbu

  box "", 1, 5 4 33 143
  box "", 2, 44 4 94 143

  scroll "", 10, 17 25 8 104, range 0 65535
  scroll "", 11, 57 25 8 104, range 0 65535
  scroll "", 12, 87 25 8 104, range 0 65535
  scroll "", 13, 117 25 8 104, range 0 65535

  check "", 20, 18 131 10 10
  check "", 21, 58 131 10 10
  check "", 22, 88 131 10 10
  check "", 23, 118 131 10 10

  text "&Master", 30, 11 14 21 8, center
  text "&Wave", 31, 48 14 25 8, center
  text "&Midi", 32, 78 14 25 8, center
  text "&Song", 33, 109 14 25 8, center

  button "&Close", 100, 55 154 40 11, cancel
  button "&Help", 99, 97 154 40 11
}
on *:DIALOG:_mixer:*:*:{
  if ($devent == INIT) {
    var %scroll = 10, %check = 20, %x = 1, %types = Master Wave Midi Song
    while (%x <= 4) {
      var %type = $gettok(%types,%x,32), %vol = $_mixer.specialVolume(%type)
      did -c $dname %scroll %vol
      if ($vol(%type).mute) { did -c $dname %check }
      inc %x
      inc %scroll
      inc %check
    }
  }
  elseif ($devent == SCROLL) {
    if ($did == 10) { _mixer.selectVolume $dname $did(10).sel master -v }
    elseif ($did == 11) { _mixer.selectVolume $dname $did(11).sel wave -w }
    elseif ($did == 12) { _mixer.selectVolume $dname $did(12).sel midi -m }
    elseif ($did == 13) { _mixer.selectVolume $dname $did(13).sel song -p }
  }
  elseif ($devent == SCLICK) {
    if ($did isnum 20-23) { vol $+(-,$gettok(v w m p,$calc($did - 19),32),u,$iif($did($did).state,1,2)) }
  }
}
alias _mixer.selectVolume {
  var %vol = $calc(65535 - $2)
  vol $4 %vol
  var %vol = $vol($3), %jota = $gettok($dialog($1).title,1,45), %timer = MIXER~TITLEBAR
  dialog -t $1 %jota - $_math.percentage(%vol,65535,0)
  if (!$timer(%timer)) { .timer $+ %timer 1 1 dialog -t $1 %jota }
}
alias _mixer.specialVolume { return $remove($calc($vol($1) - 65535),-) }
