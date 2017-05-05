;______________[ invite ]______________________________________________

alias _invite.onInviteAction { return $iif($int($_goptions.get(OnInviteDo)) isnum 1-3,$v1,3)  }
alias _invite.mircAutojoin { return $_mirc.iniOption(3,11) }
alias _invite.onEvent {
  var %n = $_invite.onInviteAction, %nick = $1, %chan = $2
  unset $_script.variableName(Invite,Echo,Comments,$cid,%nick,%chan)
  if (%n == 1) || ((%n == 2) && (!$_invite.mircAutojoinOption)) { halt }
  _fkeys.addTemporaryKey c1 15 scid -t1 $cid join %chan
  set $_script.variableName(Invite,Echo,Comments,$cid,%nick,%chan) - Press Ctrl+F1 within 15s to join
}


;______________[ regain nick ]__________________________________________

alias _regainick.nickname { return $_goptions.get(AutoRegainThisNick) }
alias _regainick.state { return $_goptions.get(AutoRegainNick) }
alias _regainick.onConnect {
  if ($_regainick.state) && ($_regainick.nickname != $me) { .notify $v1 }
}
alias _regainick.onNotify {
  if ($1 == $_regainick.nickname) && ($_regainick.state) { echo AQUI! | halt }
}
alias _regainick.onUnotify {
  var %nick = $1
  if (%nick == $_regainick.nickname) {
    if ($_regainick.state) && (%nick != $me) { .timer 1 0 _regainick.doIt %nick }
    .notify -r %nick
    halt
  }
}
alias _regainick.doIt {
  var %nick = $1
  if ($_goptions.get(AskBeforeAutoRegain)) && (!$_prompt.yesNo(' $+ %nick $+ ' nickname is available for you to use it. Change your current nick?"Auto Regain Nick)) { return }
  nick %nick
}


;______________[ ctcp replies ]__________________________________________

alias ctcprep { 
  var %dname = _ctcprep, %cmd = userlist
  if ($1 != $null) {
    if ($1 == -o) { var %dname = _ctcprep.options, %cmd = ctcprepo }
    else { _themes.sintaxEcho userlist [-o] }
  }
  _advanced.openDialog %dname %cmd
}
alias ctcprepo { ctcprep -o }
dialog _ctcprep {
  title "CTCP Replies"
  size -1 -1 270 213
  option dbu

  box "CTC&Ps list:", 1, 4 4 262 106
  list 2, 9 14 252 77, size autohs hsbar sort
  button "&Add...", 3, 136 92 40 11
  button "&Remove", 4, 178 92 40 11
  button "&Default", 6, 220 92 40 11

  box "Edit reply:", 10, 4 114 262 74
  radio "I&gnore", 11, 10 126 96 10
  radio "&Send this text:", 12, 10 137 50 10
  edit "", 13, 18 147 199 11, autohs
  button "Add &tag...", 14, 220 147 40 11
  radio "S&elect random line from file:", 15, 10 160 81 10
  edit "", 16, 18 170 199 11, read autohs
  button "Select &file...", 17, 220 170 40 11

  button "&Ok", 100, 142 195 40 11, ok
  button "&Cancel", 99, 184 195 40 11, cancel
  button "&Help", 98, 226 195 40 11
  button "O&ptions...", 97, 100 195 40 11
}
on *:DIALOG:_ctcprep:*:*:{
  if ($devent == INIT) {
    var %x = 1, %hash = $_hash.prefixed(CtcpRep), %data
    while ($hfind(%hash,CTCP_*,%x,w) != $null) {
      var %i = $v1, %ctcp = $right($upper(%i),-5)
      tokenize 58 $hget(%hash,$v1)
      if ($1 == TEXT) { %data = %ctcp (Send text: $2- $+ ) }
      elseif ($1 ==  RANDOM) { %data = %ctcp (Random from file: $2- $+ ) } 
      else { %data = %ctcp (Ignore) }
      did -a $dname 2 %data
      inc %x
    }
    if ($didwm(2,$_ctcprep.getOption(LastListItemSelected) *)) { did -c $dname 2 $v1 }
    _ctcprep.listItemSelected 
    did -z $dname 2
  }
  elseif ($devent == SCLICK) {
    if ($did == 2) { _ctcprep.listItemSelected }
    elseif ($did == 3) {
      var %add = $_prompt.input(New CTCP to add to list:"~"CTCP Replies"-tch"CtcpRepAddButton), %add = $gettok(%add,1,32)
      if ($didwm(2,%add *)) { _prompt.error CTCP already listed. Halted!"CTCP Replies }
      else {
        did -ac $dname 2 $upper(%add) (Ignore)
        _ctcprep.listItemSelected
      }
    }
    elseif ($did == 4) {
      var %sel = $did(2).sel
      if (%sel) {
        did -d $dname 2 %sel
        if ($did(2,%sel) != $null) { did -c $dname 2 %sel }
        elseif ($calc(%sel - 1)) { did -c $dname 2 $v1 }
      }
      _ctcprep.listItemSelected
    }
    elseif ($did == 6) {
      did -r $dname 2
      var %d = did -a $dname 2
      %d SCRIPT (Send text: <SCRIPTLOGO> v<SCRIPTVERSION> written by <SCRIPTAUTHOR> - <SCRIPTURL>)
      %d TIME (Send text: Current time here: <FULLDATE>)
      %d USERINFO (Ignore)
      %d VERSION (Send text: <SCRIPTLOGO> v<SCRIPTVERSION> written by <SCRIPTAUTHOR> - <SCRIPTURL>)
      _ctcprep.listItemSelected
    }
    elseif ($did == 14) { _tags.add $dname 13 CTCPREP_SEND_TEXT C&TCP reply: }
    elseif ($istok(11.12.15,$did,46)) {
      var %sel = $did(2).sel, %t
      if (!%sel) {
        _ctcprep.listItemSelected
        return
      }
      tokenize 32 $did(2).seltext
      if ($did == 11) {
        var %t = $1 (Ignore)
        did -b $dname 13,14,16,17
      }
      elseif ($did == 12) {
        var %t = $1 (Send text: $iif($did(13) != $null,$v1,<none>) $+ )
        did -e $dname 13,14
        did -b $dname 16,17
      }
      else {
        var %t = $1 (Random from file: $iif($did(16),$v1,<none>) $+ )
        did -e $dname 16,17
        did -b $dname 13,14
      }
      did -ocz $dname 2 %sel %t
    }
    elseif ($did == 17) {
      var %sel = $did(2).sel, %t
      if (!%sel) {
        _ctcprep.listItemSelected
        return
      }
      tokenize 32 $did(2).seltext
      var %file = $$_prompt.selectFile($mircdir\*.txt,Select $+($1,'s) replies file,CtcpRepliesFileSelect)
      did -ra $dname 16 %file
      did -ocz $dname 2 %sel $1 (Random from file: %file $+ )
    }
    elseif ($did == 97) { ctcprepo }
    elseif ($did == 100) {
      hdel -w $_hash.prefixed(CtcpRep) CTCP_*
      var %x = 1, %s = ""
      while ($did(2,%x) != $null) {
        tokenize 32 $v1
        if ($3 == text:) { %s = TEXT: $+ $left($4-,-1) }
        elseif ($3 == from) { %s = RANDOM: $+ $left($5-,-1) }
        else { %s = IGNORE }
        _ctcprep.setOption $+(CTCP_,$1) %s
        inc %x
      }
    }
  }
  elseif ($devent == EDIT) && ($did == 13) && ($did(2).sel) {
    did -ocz $dname 2 $v1 $gettok($did(2).seltext,1,32) (Send text: $did(13) $+ )
  }
  elseif ($devent == CLOSE) {
    _ctcprep.setOption LastListItemSelected $gettok($did(2).seltext,1,32)
  }
}
alias _ctcprep.getOption { return $_script.getOption(CtcpRep,$1) }
alias _ctcprep.setOption { _script.setOption CtcpRep $1- }
alias _ctcprep.listItemSelected {
  var %d = _ctcprep
  tokenize 32 $did(%d,2).seltext
  if ($1- == $null) {
    did -r %d 13,16
    did -u %d 11,12,15
    did -b %d 4,11,12,13,14,15,16,17
    did -ra %d 10 No reply selected to edit
  }
  else {
    did -e %d 4,11,12,13,14,15,16,17  
    did -u %d 11,12,15
    did -ra %d 10 &Edit $+($1,'s) reply:
    did -r %d 13,16
    if ($3 == text:) {
      did -c %d 12
      did -e %d 13,14
      did -b %d 16,17
      did -ra %d 13 $left($4-,-1)
    }
    elseif ($3 == from) {
      did -c %d 15
      did -e %d 16,17
      did -b %d 13,14
      did -ra %d 16 $left($5-,-1)
    }
    else {
      did -c %d 11
      did -b %d 13,14,16,17
    }
  }
}

; CTCP Replies options
dialog _ctcprep.options {
  title "CTCP Replies options"
  size -1 -1 157 82
  option dbu
  box "", 1, 5 4 147 55
  check "&Ignore all requests except on this networks:", 2, 12 13 122 10
  edit "", 3, 21 23 124 11, autohs
  text "O&n request ignore:", 4, 13 41 48 8
  combo 5, 64 40 81 50, size drop
  button "&Ok", 100, 69 65 40 11, ok
  button "&Cancel", 99, 111 65 40 11, cancel
}
on *:DIALOG:_ctcprep.options:*:*:{
  if ($devent == INIT) {
    didtok $dname 5 44 Show request,Hide request
    if ($_ctcprep.getOption(IgnoreAll)) { did -c $dname 2 }
    did -a $dname 3 $_ctcprep.getOption(IgnoreAllExceptNetworks)
    did -c $dname 5 $iif($_ctcprep.getOption(OnIgnoreAction) == 2,2,1)
  }
  elseif ($devent == SCLICK) {
    if ($did == 100) {
      _ctcprep.setOption IgnoreAll $did(2).state
      _ctcprep.setOption IgnoreAllExceptNetworks $did(3)
      _ctcprep.setOption OnIgnoreAction $did(5).sel
    }
  }
}
alias _ctcprep.onEvent {
  var %target = $2, %ctcp = $3, %param = $_script.getOption(CtcpRep,$+(CTCP_,%ctcp)), %reply
  if (%param == IGNORE) || (($_ctcprep.getOption(IgnoreAll)) && (!$istok($_ctcprep.getOption(IgnoreAllExceptNetworks),$_network.active,32))) {
    if ($_ctcprep.getOption(OnIgnoreAction) == 2) { halt }
    return
  }
  if (%param != $null) {
    if (TEXT:* iswm %param) { %reply = $gettok(%param,2-,58) }
    elseif (RANDOM:* iswm %param) { %reply = $read($gettok(%param,2-,58)) }
    if (%reply != $null) { 
      %reply = $_tags.evaluateDefaults(%reply)
      ctcpreply %target %ctcp %reply
    }
  }
}


;______________[ login ]________________________________________________

alias login {
  var %echo = $iif($show,_themes.commandEcho login,__dummy)
  if (!$server) { 
    %echo Not connected
    return 
  }
  var %pass = $iif($1 != $null,$1,$_login.getPassword), %nick = $me, %cmd = $_tags.evaluateDefaults($_goptions.get(LoginCommand))
  if (%pass == $null) {
    %echo No password set to %nick
    return 
  }
  if (%cmd == $null) {
    %echo No command set to perform login. Configure it under General Options dialog.
    return 
  }
  $eval($replacecs(%cmd,<PASS>,%pass),2)
}
alias _login.getPassword {
  var %nick = $iif($1 != $null,$1,$me), %nicks = $_goptions.get(NicksToLogin), %x = 1
  while ($gettok(%nicks,%x,59) != $null) {
    %i = $v1
    if (%nick * iswm %i) {
      return $right($left($gettok(%i,2,32),-1),-1)
    }
    inc %x
  }
}
alias _login.onEvent {
  var %on = $iif($int($_goptions.get(LoginOn)) isnum 2-4,$v1,1), %serv = $2, %str = $3-, %reqstr = $iif($_goptions.get(LoginRequestString) != $null,$v1,*)
  if ($1 == %on) {
    if (%on == 2) { .login }
    elseif (%on isnum 3-4) && (%serv == $_goptions.get(LoginServiceNick)) && (%reqstr iswm %str) { .login }
  }
}



;______________[ ial ]__________________________________________________

alias _ial.updateOn { return $iif($int($_goptions.get(UpdateIALOn)) isnum 1-3,$v1,1) }
alias _ial.askBeforeUpdateIfMoreThan { return $iif($int($_goptions.get(AskBeforeUpdateIALMoreThan)) isnum 1-,$v1,200) }
alias _ial.dontUpdateIfMoreThan { return $iif($int($_goptions.get(DontUpdateIALMoreThan)) isnum 1-,$v1,200) }
alias _ial.updateOnJoinOp {
  var %on = $_ial.updateOn, %event = $1, %chan = $2
  if (%chan !ischan) || (%on == 1) || ((%event == Join) && (%on != 2)) || ((%event == Op) && (%on != 3)) { return }
  var %total = $nick(%chan,0)
  if (%total > $_ial.dontUpdateIfMoreThan) { return }
  var %more = $_ial.askBeforeUpdateIfMoreThan
  if ($_goptions.get(AskBeforeUpdateIAL)) && (%total > %more) {
    .timer -m 1 0 _ial.askToContinue %chan %more %total
    if (!$result) { return }
  }
  else { _ial.update %chan }
}
alias _ial.update {
  var %chan = $1
  if (%chan !ischan) { return }
  set $_script.variableName(IAL,Updating,$cid,%chan) 1
  .raw WHO %chan
}
alias _ial.isUpdating { return $_script.variableValue(IAL,Updating,$cid,$1) }
alias _ial.askToContinue {
  if ($_prompt.yesNo(More than $2 nicks on $1 ( $+ $3 $+ ). Continue with IAL update?"IAL)) { _ial.update $1  }
}

;______________[ ibl ]__________________________________________________

alias _ibl.updateOn { return $iif($int($_goptions.get(UpdateIBLOn)) isnum 1-3,$v1,1) }
alias _ibl.update {
  var %event = $1, %chan = $2, %on = $_ibl.updateOn
  if (%chan !ischan) || (%on == 1) || ((%event == Join) && (%on != 2)) || ((%event == Op) && (%on != 3)) { return }
  set $_script.variableName(IBL,Updating,$cid,%chan) 1
  .raw MODE $1 +b
}


;______________[ files & folders ]__________________________________________

alias explore {
  var %d = $iif($1 != $null,$1-,$$_prompt.selectDirectory($mircdir,Select folder to explore:,SelectToExplore)), %d = $_file.fixName(%d)
  if (!$isdir(%d)) { _themes.commandEcho explore Folder doesn't exists. Halted. }
  else { .run explorer %d }
}
alias _ff.getSpecialFolder {
  ;;  AllUsersDesktop
  ;;  AllUsersStartMenu 
  ;;  AllUsersPrograms 
  ;;  AllUsersStartup 
  ;;  Desktop 
  ;;  Favorites 
  ;;  Fonts 
  ;;  MyDocuments 
  ;;  NetHood 
  ;;  PrintHood 
  ;;  Programs 
  ;;  Recent 
  ;;  SendTo 
  ;;  StartMenu 
  ;;  Startup 
  ;;  Templates
  return
  var %name = SpecialFolders, %x
  if ($com(%name)) { .comclose %name }
  .comopen %name WScript.Shell
  if ($com(%name,%name,3,bstr,$1) != $null) { %x = $com(%name).result }
  .timer 1 1 .comclose %name
  return $_file.fixName(%x)
}
alias _ff.getEnvironmentString {
  return
  ;; Path
  ;; Temp
  ;; SystemDrive
  ;; SystemRoot
  ;; Windir

  var %name = ExpandEnvironmentStrings, %x
  if ($com(%name)) { .comclose %name }
  .comopen %name WScript.Shell
  if ($com(%name,%name,3,bstr,$+(%,$1,%)) != $null) { %x = $com(%name).result }
  return $iif(%x != $+(%,$1,%),%x)
}

alias _ff.miscFoldersMenu {
  if ($1 isnum 1-) {
    var %n = $1
    goto %n
    :1 | return m&IRC: _ff.miscFoldersMenuRunIt 1
    :2 | return &Logs: _ff.miscFoldersMenuRunIt 2
    :3 | return &Downloads: _ff.miscFoldersMenuRunIt 3
    :4 | return -
    :5 | :6 | :7 | :8
    var %x = $calc(%n - 4), %temp = &All Users Desktop.All Users StartMe&nu.All Users &Programs.All Users S&tartup, $&
      %puta = $remove(%temp,$chr(32),&), %folder = $_ff.getSpecialFolder($gettok(%puta,%x,46))
    return $iif($isdir(%folder),$gettok(%temp,%x,46)) : _ff.miscFoldersMenuRunIt %n
    :9 | return -
    :10 
    var %f = $_ff.getSpecialFolder(MyDocuments)
    return $iif($isdir(%f),&My Documents) : _ff.miscFoldersMenuRunIt 10
    :11 | return -
    :12 | :13 | :14 | :15
    var %x = $calc(%n - 11), %temp = D&esktop.Sta&rtMenu.Pro&grams.Start&up, $&
      %puta = $remove(%temp,$chr(32),&), %folder = $_ff.getSpecialFolder($gettok(%puta,%x,46))
    return $iif($isdir(%folder),$gettok(%temp,%x,46)) : _ff.miscFoldersMenuRunIt %n
    :%n
  }
}
alias _ff.drivesFoldersMenu {
  if ($1 isnum 1-) {
    var %_temp = $_script.variableValue(FilesFolders,Drivers,Paths,Labels)
    if ($numtok(%_temp,59) == $disk(0)) && ($gettok(%_temp,$1,59) != $null) { var %i = $v1, %p = $gettok(%i,1,63), %lb = $gettok(%i,2,63), %type = $gettok(%i,3,63), %size = $gettok(%i,4,63) }
    else {
      if ($1 == 1) { %_temp = "" }
      var %p = $disk($1).path, %lb = $iif($disk($1).label,$v1,$left(%p,1)), %type = $disk($1).type, %size = $disk($1).size
      if (%p == $null) { return }
      set $_script.variableName(FilesFolders,Drivers,Paths,Labels) $addtok(%_temp, $+(%p,?,%lb,?,%type,?,%size)  ,59)
    }
    if (%p) { return %lb $chr(9) $_string.surrounded(%type - $iif(%size == 0,<drive n\a>,$bytes($v1,g).suf)) : explore %p }
  }
}
alias _ff.miscFoldersMenuRunIt {
  var %n = $1, %f
  goto %n
  :1 | %f = $mircdir | goto e
  :2 | %f = $logdir | goto e
  :3 | %f = $getdir | goto e
  :5 | %f = $_ff.getSpecialFolder(AllUsersDesktop) | goto e
  :6 | %f = $_ff.getSpecialFolder(AllUsersStartMenu) | goto e
  :7 | %f = $_ff.getSpecialFolder(AllUsersPrograms) | goto e
  :8 | %f = $_ff.getSpecialFolder(AllUsersStartup) | goto e
  :10 | %f = $_ff.getSpecialFolder(MyDocuments) | goto e
  :12 | %f = $_ff.getSpecialFolder(Desktop) | goto e
  :13 | %f = $_ff.getSpecialFolder(StartMenu) | goto e
  :14 | %f = $_ff.getSpecialFolder(Programs) | goto e
  :15 | %f = $_ff.getSpecialFolder(Startup) | goto e
  :e | explore %f
  :%n
}
alias _ff.addRecentFile {
  var %f = $_prompt.selectFile($mircdir\*.*,Files - Select file to add to list,FilesFoldersAddFile) 
  _script.setRecentOption 15 FilesFolders RecentFiles %f 
  if ($_prompt.yesNo(Run $nopath(%f) now?"Files)) { run %f }
}
alias _ff.recentFilesMenu {
  if (!$isid) { 
    if ($1 == $null) { 
      if ($_prompt.yesNo(Do you really want to delete all files from list?"Files)) { _script.setOption FilesFolders RecentFiles }
    }
    else { 
      if ($int($_prompt.inputNumber(1,15,-,h,Delete Nth file:,Files)) isnum 1-15) { _script.deleteRecentOption $v1 FilesFolders RecentFiles }
    }
  }
  elseif ($1 isnum 1-15) {
    var %data = $gettok($_script.getOption(FilesFolders,RecentFiles),$1,59) 
    if (%data != $null) { return $1 $+ . $nopath(%data) : _ff.recentFilesRunIt $1 } 
  }
}
alias _ff.recentFilesRunIt {
  var %n = $1, %all = $_script.getOption(FilesFolders,RecentFiles), %f = $gettok(%all,%n,59)
  if (!$isfile(%f)) || (%f == $null) {
    if ($_prompt.yesNo( $ord(%n) viewed file doesn't exists. Remove it from list?"Files)) { _script.deleteRecentOption FilesFolders RecentFiles %n }
  }
  else { run %f }
}
alias _ff.addRecentFolder {
  var %f = $_prompt.selectDirectory($mircdir,Folders - Select folder to add to list,ToAddToList) 
  _script.setRecentOption 15 FilesFolders RecentFolders %f 
  if ($_prompt.yesNo(Explore this folder?"Folders)) { explore %f }
}
alias _ff.recentFoldersMenu {
  if (!$isid) { 
    if ($1 == $null) { 
      if ($_prompt.yesNo(Do you really want to delete all folders from list?"Folders)) { _script.setOption FilesFolders RecentFolders }
    }
    else { 
      if ($int($_prompt.inputNumber(1,15,-,h,Delete Nth folder:,Files)) isnum 1-15) { _script.deleteRecentOption $v1 FilesFolders RecentFolders }
    }
  }
  elseif ($1 isnum 1-15) {
    var %data = $gettok($_script.getOption(FilesFolders,RecentFolders),$1,59) 
    if (%data != $null) {
      var %name = $gettok(%data,-1,92), %name = $iif(?: iswm %name,<Drive $upper($left(%name,1)) $+ >,%name)
      return $1 $+ . %name : _ff.recentFoldersRunIt $1
    } 
  }
}
alias _ff.recentFoldersRunIt {
  var %n = $1, %all = $_script.getOption(FilesFolders,RecentFolders), %f = $gettok(%all,%n,59)
  if (!$isdir(%f)) || (%f == $null) {
    if ($_prompt.yesNo( $ord(%n) explored folder doesn't exists. Remove it from list?"Folders)) { _script.deleteRecentOption FilesFolders RecentFolders %n }
  }
  else { explore %f }
}

;______________[ id3 ]__________________________________________

dialog _id3.viewer {
  title "ID3 viewer"
  size -1 -1 177 198
  option dbu
  text "Track #:", 20, 120 15 22 8
  edit "", 1, 145 13 19 11, read autohs
  text "Title:", 21, 9 28 33 8, right
  edit "", 2, 44 26 121 11, read autohs
  text "Artist:", 22, 9 41 33 8, right
  edit "", 3, 44 39 121 11, read autohs
  text "Album:", 23, 9 54 33 8, right
  edit "", 4, 44 52 121 11, read autohs
  text "Year:", 24, 9 67 33 8, right
  edit "", 5, 44 65 28 11, read autohs
  text "Genre:", 25, 75 67 18 8
  edit "", 6, 95 65 70 11, read autohs
  text "Comments:", 26, 9 80 33 8, right
  edit "", 7, 44 78 121 26, read multi vsbar
  text "Composer:", 27, 9 108 33 8, right
  edit "", 8, 44 106 121 11, read autohs
  text "Orig. Artist:", 28, 9 121 33 8, right
  edit "", 9, 44 119 121 11, read autohs
  text "Copyright:", 29, 9 134 33 8, right
  edit "", 10, 44 132 121 11, read autohs
  text "URL:", 30, 9 147 33 8, right
  edit "", 11, 44 145 121 11, read autohs
  text "Encoded by:", 31, 9 160 33 8, right
  edit "", 12, 44 158 121 11, read autohs
  box "", 99, 4 3 168 173
  button "&Close", 100, 132 182 40 11, cancel
  button "&Help", 101, 90 182 40 11
}
alias id3 {
  var %m = $iif($1 != $null,$1-,$$_prompt.selectFile($iif($sound(mp3),  $+($v1,*.mp3),   *\*.mp3),ID3 - Select file to view,Id3SelectFile)), %f = $_file.fixName($longfn(%m))
  if (!$_file.isExtension(%m,mp3)) || (!$isfile(%m)) { _themes.commandEcho id3 Invalid or unexistance mp3 file ( $+ %m $+ ). }
  else {
    _script.setRecentOption 10 Id3 RecentFiles %m
    :dn
    var %dname = $+(Id3-,$rand(1,99999))
    if ($dialog(%dname)) { goto dn }
    var %i = 1, %h = track.title.artist.album.year.genre.comment.composer.o-artist.copyright.url.encoder, %tag
    _advanced.openDialog _id3.viewer id3 %dname
    dialog -t %dname $gettok($dialog(%dname).title,1,45) - $_id3.fileProp(%m).file
    while ($gettok(%h,%i,46) != $null) { 
      %tag = $_id3.fileProp(%m). [ $+ [ $v1 ] ] 
      did -a %dname %i %tag
      inc %i 
    }
  }
}
alias _id3.fileProp {
  var %file = $_file.fixName($shortfn($1-))
  if (!$_file.isExtension(%file,mp3)) || (!$isfile(%file)) { return }
  if ($istok(time.atime.mb.file.sr,$prop,46)) {
    goto $prop
    :time
    return $asctime($calc($sound(%file).length / 1000),n:ss))
    :atime 
    if ($insong) { return $asctime($calc($insong.pos / 1000),nn:ss)) }
    else { return }
    :mb 
    return $bytes($lof(%file),3)
    :file 
    %file = $longfn(%file) 
    return $left($replace($nopath(%file),_,$chr(32)),-4)
    :sr 
    return $round($calc($sound(%file).sample / 1000),1)
  }
  if ($sound($1-). [ $+ [ $prop ] ] != $null && $v1 != $false) { 
    var %r = $v1
    if ($prop == track) { %r = $iif(%r > 0,$v1) }
    return %r
  }
  elseif ($_id3.filePropV2($1-). [ $+ [ $prop ] ]) { return $v1 }
}
alias _id3.filePropV2 {
  var %m = $_file.fixName($shortfn($1-)), %hds = TRCK.TENC.WXXX.TCOP.TOPE.TCOM.COMM.TALB.TCON.TYER.TPE1.TIT2, $&
    %gens = track.enconder.url.copyright.o-artist.composer.comment.album.genre.year.artist.title
  if (!$isfile(%m)) || (!$prop) || (!$istok(%gens,$prop,46)) { return } 
  bread %m 0 4096 &mp3 
  if ($bvar(&mp3,1,3).text != ID3) { return }
  var %h = $gettok(%hds,$findtok(%gens,$prop,1,46),46), %n, %p 
  if ($prop == url) { %n = 12 } 
  elseif ($prop == comment) { %n = 15 } 
  else { %n = 11 } 
  %p = $calc($bfind(&mp3,1,%h).text + %n)
  bread %m $calc(%p - 1) 4096 &mp3 
  return $iif($prop == title,$bvar(&mp3,1,4096).text,$left($bvar(&mp3,1,4096).text,-4))
}
alias _id3.recentFilesMenu {
  if (!$isid) { 
    if ($1 == $null) { _script.setOption Id3 RecentFiles }
    else { 
      if ($int($_prompt.inputNumber(1,15,-,h,Delete Nth recent file:,ID3)) isnum 1-15) { _script.deleteRecentOption Id3 RecentFiles $v1 }
    }
  }
  elseif ($1 isnum 1-15) {
    var %data = $gettok($_script.getOption(Id3,RecentFiles),$1,59) 
    if (%data != $null) { return $1 $+ . $nopath(%data) : _id3.recentFilesRunIt $1 } 
  }
}
alias _id3.recentFilesRunIt {
  var %n = $1, %all = $_script.getOption(Id3,RecentFiles), %f = $gettok(%all,%n,59)
  if (!$isfile(%f)) || (%f == $null) {
    if ($_prompt.yesNo( $ord(%n) viewed file doesn't exists. Remove it from recent files list?"Files)) { _script.deleteRecentOption Id3 RecentFiles %n }
  }
  else { id3 %f }
}


;______________[ help ]__________________________________________

alias helpd { 
  var %d = _help
  _advanced.openDialog %d helpd
  if ($1 == -t) && ($didwm(%d,21,$2-)) {
    did -c %d 20
    did -c %d 21 $v1
    _help.fillTopics -t $2-
  }
  elseif ($1 != $null) {
    did -c %d 10
    did -ra %d 11 $1-
    _help.performSearch
  }
}
dialog _help {
  title "Help!"
  size -1 -1 273 197
  option dbu

  tab "&Topics", 20, 4 5 264 159
  list 21, 9 23 68 135, tab 20 size
  edit "", 22, 81 23 182 135, tab 20 read multi autovs vsbar

  tab "&Commands", 1
  list 2, 9 23 68 135, tab 1 sort size
  edit "", 3, 81 23 182 121, tab 1 read multi autovs vsbar
  button "&More...", 4, 222 146 40 11, tab 1 disable

  tab "&Search", 10
  edit "", 11, 9 23 68 11, tab 10 autohs
  button "S&earch", 12, 37 36 40 11, tab 10
  list 13, 9 50 68 94, tab 10 sort size
  text "", 14, 10 148 66 8, tab 10
  edit "", 15, 81 23 182 135, tab 10 read multi autovs vsbar

  text "", 97, 100 178 30 7, hide disable
  icon 98, 5 173 15 15,  $mircexe , 0
  text "", 99, 24 178 75 7, disable

  button "&Close", 100, 228 176 40 11, cancel
  button "&mIRC help", 101, 186 176 40 11
}
on *:DIALOG:_help:*:*:{
  if ($devent == INIT) {
    did -g $dname 98 0 $_script.directory(images,m,Script.ico)
    did -a $dname 99 $_script.name v $+ $_script.version help
    didtok $dname 21 167 $_help.topics
    var %win = @_help.listCommands, %x = 1
    _window.open -hs %win
    if ($_file.isFile($_help.file(commands))) { filter -fw $v1 %win *~* }
    while ($line(%win,%x)) { 
      did -a $dname 2 $gettok($v1,1,126) 
      inc %x 
    } 
    window -c %win
    _help.fillCommand -cs 
    _help.fillTopics -t
  }
  elseif ($devent == SCLICK) {
    if ($did == 2) {
      if ($did(2).seltext) { _help.fillCommand -c $v1 }
    }
    elseif ($did == 4) {
      if ($did(2).seltext) { .help $+(/,$v1) }
      else { did -b $dname $did }
    }
    elseif ($did == 12) { _help.performSearch }
    elseif ($did == 13) {
      var %t = $did(13).seltext
      if (- * iswm %t) { _help.fillTopics -s $gettok(%t,2-,32) }
      else { _help.fillCommand -s %t }
    }
    elseif ($did == 21) {
      if ($did(21).seltext) { _help.fillTopics -t $v1 }
    }
    elseif ($did == 98) { 
      var %d = 97 
      if ($did(%d).visible) { did -h $dname %d }
      else {
        if ($r(1,2) == 1) { return }
        did -rav $dname %d $__gub(2) 
      }
    }
    elseif ($did == 101) { help }
  }
  elseif ($devent == EDIT) && ($did == 11) { did -t $dname 12 }
}
alias -l _help.fillCommand {
  ; On file: command~sintax~description*
  ; If * at the end 'More...' will be enabled to open mIRC help to that command

  if ($1 == -c) { var %id = 3 } 
  elseif ($1 == -s) { var %id = 15 } 
  else { var %id = 3,15 }
  var %dname = _help, %help = $read($_help.file(commands),w,$2 $+ ~*)
  did -r %dname %id
  var %com = $2, %sintax = $gettok(%help,2,126)

  if (!%com) { did -a %dname %id $crlf $str($chr(160),26) *** NO ITEM SELECTED *** } 
  else {
    ; Use another command sintax and description if sintax starts with "-"
    if (-* iswm %sintax) { %help = $read($_help.file(commands),w,$right(%sintax,-1) $+ ~*) }
    var %sintax = $iif($gettok(%help,2,126),/ $+ %com $v1,(not available)), %desc = $iif($gettok(%help,3,126),$v1,(not available)), %more = 0

    %desc = $replace(%desc,<CRLF>,$crlf,<CRLF2>,$crlf $crlf)

    ; Removes * from the end if any and check %more toogle
    if ($right(%desc,1) == *) {
      %desc = $left(%desc,-1)
      %more = 1
    }

    ; Fill command infos
    did -i %dname %id 1 $chr(160) _____
    did -i %dname %id 2 ( Sintax )
    did -i %dname %id 3 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    did -i %dname %id 4 %sintax $crlf
    did -a %dname %id $chr(160) _________ $crlf
    did -a %dname %id ( Description ) $crlf
    did -a %dname %id ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    did -a %dname %id $crlf $+ $crfl $+ %desc $crlf $crlf

    did $iif(%more,-e,-b) $dname 4

    did -c %dname %id 1
  }
}
alias _help.file {
  if ($1 == topics) { var %f = $_script.directory(misc,m,HelpTopics.txt) }
  if ($1 == commands) { var %f = $_script.directory(misc,m,HelpCommands.txt) }
  return %f
}
alias -l _help.performSearch {
  var %dname = _help, %text = $did(%dname,11), %string = $_string.wildcarded(%text), %file = $_help.file(commands), %file2 = $_help.file(topics), $&
    %whatsnew = $_script.whatsnewFile, %win = @_help.search, %filtered = 0
  if ($len($remove(%text,?,*,$chr(32))) == 1) || (%text == $null) { did -ra %dname 14 At least 2 characters }
  else {
    did -r %dname 13,15
    did -ra %dname 14 Searching...
    _window.open -h %win
    clear %win
    ;     search topics
    if ($isfile(%file2)) {
      var %x = 1, %topics
      while ($ini(%file2,%x)) {
        var %tmp = $v1
        loadbuf -t $+ %tmp %win %file2
        if ($fline(%win,%string,1,0)) {
          %topics = $addtok(%topics,- $replace(%tmp,_,$chr(32)),167)
          inc %filtered
        }
        clear %win
        inc %x
      }
      if (%topics) { didtok %dname 13 167 %topics }
    }
    ;     search whatsnew file
    if ($isfile(%whatsnew)) {
      _window.open -h %win
      loadbuf %win %whatsnew
      if ($fline(%win,%string,1,0)) { 
        did -a %dname 13 - Whatsnew
        inc %filtered
      }
    }

    if (%filtered) { did -a %dname 13 $chr(160) }
    ;       search commands
    if ($isfile(%file)) {
      var %string = *~*~ $+ %string, %x = 1
      clear %win
      filter -fw %file %win %string
      while ($line(%win,%x)) { 
        did -a %dname 13 $gettok($v1,1,126) 
        inc %x
      }
      %filtered = %filtered + $filtered
    }
    did -ra %dname 14 %filtered result $+ $iif(%filtered != 1,s) found 
    window -c %win
    _help.fillCommand -s
  }
}
alias -l _help.topics { return About§Whatsnew§ §Control panel§ §General Options§Misc Options§ §Themes§Images§Nicklist Colors§Event Sounds§Echos§ $&
    §Personal Protections§Channel Protections§Protections Options§ §CTCP Replies§Filters§Function Keys§Nick Completion§ §Profiles§ §Userlist§Userlist Options§ §Pagers§Awaylog Viewer§ §Settings§Statistics
}
alias -l _help.fillTopics {
  if ($1 == -t) { var %id = 22 } 
  else { var %id = 15 }
  var %_topic = $replace($2-,$chr(32),_), %topic = $replace($2-,_,$chr(32)), %file = $_help.file(topics), %dname = _help, %file2 = $_script.whatsnewFile
  did -r %dname %id
  if ($2 == whatsnew) && ($isfile(%file2)) {
    loadbuf -o %dname %id %file2
    did -i %dname %id 1
    did -i %dname %id 2  $upper(%topic)
    did -i %dname %id 3 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  }
  elseif ($ini(%file,%_topic)) && ($isfile(%file)) {
    loadbuf -oet $+ %_topic %dname %id %file
    did -i %dname %id 1
    did -i %dname %id 2  $upper(%topic)
    did -i %dname %id 3 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
  }
  else { did -a %dname %id $crlf $str($chr(160),26) *** NO ITEM $iif(%topic == $null,SELECTED,AVAILABLE) *** }
  did -c %dname %id 1
}



;_____________[ tags ] ________________________________________

dialog _tags.add {
  title "Add tag"
  size -1 -1 171 144
  option dbu
  box "", 1, 4 4 162 79
  text "&Defaults:", 2, 10 13 30 8
  list 3, 9 21 75 56, sort size
  text "&Other tags:", 4, 86 13 69 8
  list 5, 85 21 75 56, sort size
  box "Description:", 6, 4 86 162 37
  text "", 8, 9 96 152 21
  button "&Add", 100, 82 128 40 11, ok
  button "&Cancel", 99, 125 128 40 11, cancel
  edit "", 1000, 2 2 0 0, hide disable autohs
}
on *:DIALOG:_tags.add:*:*:{
  if ($devent == INIT) {
    tokenize 32 $_script.variableValue(Tags,DialogParameters)
    did -a $dname 1000 $1-
    didtok $dname 3 32 $_tags.values(default)

    if ($3 != $null) {
      did -ra $dname 4 $4-
      didtok $dname 5 32 $_tags.values($3) 
    }
    else { did -b $dname 4,5 }
  }
  elseif ($devent == DCLICK) && ($istok(3 5,$did,32)) { dialog -k $dname }
  elseif ($devent == SCLICK) {
    if ($did == 3) {
      did -u $dname 5
      did -ra $dname 8 $iif($did(3).seltext != $null,$_tags.values(default,$v1)) 
    }
    elseif ($did == 5) {
      did -u $dname 3
      did -ra $dname 8 $iif($did(5).seltext,$_tags.values($gettok($did(1000),3,32),$v1)) 
    }
    elseif ($did == 100) { 
      if ($did($dname,3).seltext) || ($did($dname,5).seltext != $null) { var %tag = $v1 }
      if (<*> iswm %tag) { set -u1 $_script.variableName(Tags,ReturnValue) %tag }
    }
  }
}
alias _tags.add {
  var %dname = _tags.add
  tokenize 32 $1-
  if ($dialog(%dname)) { 
    dialog -v %dname
    return
  }
  if (!$dialog($1)) || ($int($2) !isnum 1-) { return }
  set -u0 $_script.variableName(Tags,DialogParameters) $1-
  __dummy $dialog(%dname,%dname,-4)
  if ($dialog($1)) && ($int($2) isnum 1-) && ($_script.variableValue(Tags,ReturnValue) != $null) { did -a $1-2 $v1 }
}
alias -l _tags.values {
  var %dname = $1, %r = return, %tags
  if (%dname != $null) { goto %dname }
  else { return }

  :DEFAULT
  return $_tags.value_DEFAULT($2)

  :NICKCOMP_CUSTOM_STYLE
  return $_tags.value_NICKCOMP_CUSTOM_STYLE($2)

  :CPROTS_PENALTIES
  return $_tags.value_CPROTS_PENALTIES($2)

  :PROTO_NOTICE_FLOODER
  return $_tags.value_PROTO_NOTICE_FLOODER($2)

  :PROTO_KICK_MESSAGE
  return $_tags.value_PROTO_KICK_MESSAGE($2)

  :PLAYER_OPTIONS_ADVERTISE
  return $_tags.value_PLAYER_OPTIONS_ADVERTISE($2)

  :LOGIN_COMMAND
  return $_tags.value_LOGIN_COMMAND($2)

  :AWAY_BACK_ANNOUNCE
  return $_tags.value_AWAY_BACK_ANNOUNCE($2)

  :ALARM_MESSAGE
  return $_tags.value_ALARM_MESSAGE($2)

  :SEEN_RESPONSE_1
  return $_tags.value_SEEN_RESPONSE_1($2)

  :SEEN_RESPONSE_2
  return $_tags.value_SEEN_RESPONSE_2($2)

  :SEEN_RESPONSE_3
  return $_tags.value_SEEN_RESPONSE_3($2)

  :SEEN_RESPONSE_4
  return $_tags.value_SEEN_RESPONSE_4($2)

  :SEEN_RESPONSE_5
  return $_tags.value_SEEN_RESPONSE_5($2)

  :SEEN_RESPONSE_6
  return $_tags.value_SEEN_RESPONSE_6($2)

  :SEEN_RESPONSE_7
  return $_tags.value_SEEN_RESPONSE_7($2)

  :CTCPREP_SEND_TEXT
  return $_tags.value_CTCPREP_SEND_TEXT($2)

  :%dname
}
alias _tags.value_CTCPREP_SEND_TEXT {
  var %r = return, %tags = <NICK> <CTCP>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<NICK> | %r Nick\channel which request CTCP reply
  :<CTCP> | %r CTCP name in uppercase (Eg.: VERSION or TIME)
}
alias _tags.value_SEEN_RESPONSE_1 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
}
alias _tags.value_SEEN_RESPONSE_2 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
}
alias _tags.value_SEEN_RESPONSE_3 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL> <NICKS> <TOTAL>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
  :<NICKS> | %r String with all nicks founded and alphabetic sorted
  :<TOTAL> | %r Number of founded nicks
}
alias _tags.value_SEEN_RESPONSE_4 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL> <NICKS> <DISPLAYED> <TOTAL>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
  :<NICKS> |%r String only with nicks that can be displayed and alphabetic sorted
  :<DISPLAYED> | %r Number of nicks that can be displayed
  :<TOTAL> | %r Number of founded nicks
}
alias _tags.value_SEEN_RESPONSE_5 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
}
alias _tags.value_SEEN_RESPONSE_6 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL> <COMCHANNELS>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
  :<COMCHANNELS> | %r String with all common channels with requested nick alphabetic sorted
}
alias _tags.value_SEEN_RESPONSE_7 {
  var %r = return, %tags = <REQUEST> <NICK> <CHANNEL> <TIME> <TIMEAGO> <DATE> <CTIME> <EVENT> <ADDRESS> <LASTCHANNEL>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REQUEST> | %r Requested nick to check for seen information
  :<NICK> | %r Nick that requested seen information
  :<CHANNEL> | %r Channel where trigger takes place
  :<TIME> | %r Default formated time when requested nick was last seen
  :<TIMEAGO> | %r String in a week/day/hour/minute/second format with the time paste since requested nick was seen
  :<DATE> | %r String with default formated date when requested nick was last seen
  :<CTIME> | %r $!ctime value when requested nick was last seen. Can be used together with $!asctime mIRC identifier
  :<EVENT> | %r Last event that requested nicks trigger (can be "Join", "Part" or "Kick")
  :<ADDRESS> | %r Requested nick's address
  :<LASTCHANNEL> | %r Last channel where requested nick was last seen 
}
alias _tags.value_ALARM_MESSAGE {
  var %r = return, %tags = <TIME> <ALARM>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<ALARM> | %r Returns alarm type string ('Timed' or 'Continuous')
  :<TIME> | %r Current time in HH:mm:ss format
}
alias _tags.value_AWAY_BACK_ANNOUNCE {
  var %r = return, %tags = <REASON> <CTIME> <SINCE> <PAGER> <LOG> <TIME> <DURATION>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<REASON> | %r Current away message
  :<CTIME> | %r $!ctime value when away was seted. Can be used together with $!asctime mIRC identifier
  :<SINCE> | %r Full date string when away was seted
  :<DURATION> | %r Elapsed time since away was seted in a week/day/hour/minute/second format.
  :<PAGER> | %r Pager state ('On' or 'Off') while away 
  :<LOG> | %r Away logging state ('On' or 'Off') for window being announced
  :<TIME> | %r Elapsed seconds since away was seted. Can be used together with $!asctime mIRC identifier
}
alias _tags.value_LOGIN_COMMAND {
  var %r = return, %tags = <PASS>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<PASS> | %r Nick's password
}
alias _tags.value_PLAYER_OPTIONS_ADVERTISE {
  var %r = return, %tags = <FILESIZE> <FILENAME> <SAMPLE> <TIME> <SECS> <MSECS> <TITLE> <ALBUM> <YEAR> <GENRE> <COMPOSER> <O-ARTIST> $&
    <COPYRIGHT> <URL> <ENCODER> <TRACK> <COMMENT> <FILEPATH> <FILENAME2>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<FILESIZE> | %r Music file size (Mb)
  :<FILEPATH> | %r Music path
  :<FILENAME> | %r Music filename
  :<FILENAME2> | %r Music filename without extension and underscores (replaced by spaces)
  :<SAMPLE> | %r Music samplerate (KHz)
  :<TIME> | %r Music time (in text format)
  :<SECS> | %r Music length in seconds
  :<MSECS> | %r Music length in miliseconds
  :<TITLE> | %r Music title
  :<ALBUM> | %r Music album
  :<YEAR> | %r Music year
  :<TRACK> | %r Music track
  :<GENRE> | %r Music genre
  :<COMPOSER> | %r Music composer (ID3v2)
  :<O-ARTIST> | %r Music original artist (ID3v2)
  :<COPYRIGHT> | %r Music copyright
  :<URL> | %r Music URL (ID3v2)
  :<ENCODER> | %r Music encoder (ID3v2)
  :<COMMENT> | %r Music comment
}
alias _tags.value_DEFAULT {
  var %r = return, %tags = <ME> <NETWORK> <ACTIVE> <MYFULLADDRESS> <SCRIPTURL> <SCRIPTAUTHOR> <SCRIPTVERSION> <SCRIPTLOGO> <B> <U> <R> <CURRENTIME> <FULLDATE>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<ME> | %r Your current nick. If no nick returns your main nick.
  :<NETWORK> | %r Your active network.
  :<ACTIVE> | %r You current active window. Can be a nick, a channel, a DCC chat (=nick) or a window.
  :<MYFULLADDRESS> | %r Your current address (nick!user@host)
  :<SCRIPTURL> | %r Script's website
  :<SCRIPTAUTHOR> | %r Script's author nick
  :<SCRIPTVERSION> | %r Script's current version
  :<SCRIPTLOGO> | %r Script logo (includes control codes)
  :<U> | %r Underline character code
  :<B> | %r Bold character code
  :<K> | %r Color character code
  :<R> | %r Reverse character code
  :<CURRENTIME> | %r $!ctime value to be used for example to format current date and time
  :<FULLDATE> | %r Date and time string (Eg: Wed Apr 27 23:54:59 2005)
}
alias _tags.value_PROTO_NOTICE_FLOODER {
  var %r = return, %tags = <NICK> <ADDRESS> <FULLADDRESS> <OFFENCE> <IGNORETIME>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<NICK> | %r Flooder's nick
  :<ADDRESS> | %r Flooder's address (user@host)
  :<FULLADDRESS> | %r Flooder's full address (nick!user@host)
  :<OFFENCE> | %r Name of the offence that trigger this penalty (Eg: 'Invite Flood')
  :<IGNORETIME> | %r Seconds that flooder will be ignored ('Permanently' is returned if not a timed ignore)
}
alias _tags.value_CPROTS_PENALTIES {
  var %r = return, %tags = <CHANNEL> <NICK> <ADDRESS> <FULLADDRESS> <OFFENCE> <PENALTY>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<NICK> | %r Offender's nick (the one who triggers penalty)
  :<CHANNEL> | %r Channel where penalty was been triggered
  :<ADDRESS> | %r Offender's address (user@host)
  :<FULLADDRESS> | %r Offender's full address (nick!user@host)
  :<OFFENCE> | %r Name of the offence that trigger this penalty (Eg: 'Text Flood')
  :<PENALTY> | %r Nth penalty triggered by this user for this offence
}
alias _tags.value_PROTO_KICK_MESSAGE {
  var %r = return, %tags = <CHANNEL> <NICK> <ADDRESS> <FULLADDRESS> <MESSAGE> <ALLCOUNT> <CHANCOUNT>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<NICK> | %r Nick being kicked
  :<CHANNEL> | %r Channel where nick is being kicked
  :<ADDRESS> | %r Kicked's address (user@host)
  :<FULLADDRESS> | %r Kicked's full address (nick!user@host)
  :<MESSAGE> | %r Kick message (it's usually the kick reason)
  :<ALLCOUNT> | %r Kicks count from all channels
  :<CHANCOUNT> | %r Kicks count from that specifique channel
}
alias _tags.value_NICKCOMP_CUSTOM_STYLE {
  var %r = return, %tags = <NICK> <FIRST> <LAST> <MIDDLE> <TRIGGER>
  if ($istok(%tags,$1,32)) { goto $1 }
  %r %tags

  :<NICK> | %r Nick matching completion
  :<FIRST> | %r First character from nick to be completed
  :<LAST> | %r Last character from nick to be completed
  :<MIDDLE> | %r Middle section from nick to be completed (without first and last characters)
  :<TRIGGER> | %r Character used to trigger nick completion
}
alias _tags.evaluateDefaults {
  if ($1 == $null) { return }
  var %m = $replace($1-,<CURRENTIME>,$ctime,<FULLDATE>,$asctime,<ME>,$me,<NETWORK>,$_network.active,<ACTIVE>,$active,<MYFULLADDRESS>,$iif($__myAddress,$v1,$+($me,!ident@localhost)), $&
    <SCRIPTURL>,$_script.home,<SCRIPTAUTHOR>,$_script.author,<SCRIPTVERSION>,$_script.version,<SCRIPTLOGO>,$_script.logo,<B>,,<K>,,<U>,,<R>,)
  return %m
}



;______________[ ascii ]__________________________________________

alias ascii { _advanced.openDialog _ascii ascii }
dialog _ascii {
  title "ASCII viewer"
  size -1 -1 227 95
  option dbu
  scroll "", 1, 9 12 208 8, range 1 255 horizontal top
  text "1", 2, 10 22 25 8
  text "255", 3, 191 22 25 8, right
  box "", 4, 4 35 88 38
  text "Number:", 5, 11 46 28 8
  text "N", 6, 43 46 40 8, right
  text "Character:", 7, 11 58 28 8
  text "CHAR", 8, 43 58 40 8, right
  box "", 9, 98 35 124 38
  text "&Go to ASCII number:", 10, 106 46 57 8
  edit "", 11, 165 44 50 11, autohs right
  text "G&o to ASCII character:", 12, 106 58 57 8
  edit "", 13, 165 56 50 11, autohs right
  button "Cli&pboard", 14, 140 79 40 11
  button "&Close", 15, 182 79 40 11, ok
}
on *:DIALOG:_ascii:*:*:{
  if ($devent == INIT) { _ascii.select }
  elseif ($devent == SCROLL) { _ascii.select $did(1).sel } 
  elseif ($devent == EDIT) { 
    if ($did == 11) { 
      if ($did(11) isnum 1-255) { _ascii.select $v1 }
      else { did -r $dname 11 }
    }   
    elseif ($did == 13) { 
      if ($len($did(13)) == 1) { _ascii.select $asc($did(13)) } 
      else { did -r $dname 13 } 
    }
  }
  elseif ($devent == SCLICK) {
    if ($did == 14) { 
      clipboard $chr($did(1).sel) 
      did -b $dname $did
    }
  }
}
alias -l _ascii.select {
  var %x = $iif($int($1) isnum 1-255,$v1,1), %chr = $chr(%x), %dname = _ascii
  if (%chr == $null) || (%x == 4) || (%x == 15) { %chr = <Null> }
  elseif (%x == 2) { %chr = (Bold) } 
  elseif (%x == 3) { %chr = (Color) }
  elseif (%x == 9) { %chr = (Tab) }
  elseif (%x == 22) { %chr = (Reverse) } 
  elseif (%x == 31) { %chr = (Underline) } 
  elseif (%x == 32) { %chr = (Space) }
  elseif (%x == 38) { %chr = && }
  did -ra %dname 6 %x
  did -ra %dname 8 %chr
  did -c %dname 1 %x
  if (!$did(%dname,14).enabled) { did -e %dname 14 }
}



;______________[ tips ]__________________________________________

alias tip { _advanced.openDialog _tips tips }
alias tips { tip }
dialog _tips {
  title "Tips"
  size -1 -1 173 73
  option dbu
  box "", 1, 4 4 165 45
  text "<no tips available>", 2, 11 14 150 27
  button "&Next >>", 4, 87 56 40 11
  button "&Close", 5, 129 56 40 11, cancel
  edit "", 100, 0 0 0 0, autohs disable hide
}
on *:DIALOG:_tips:*:*:{ 
  if ($devent == INIT) || (($devent == SCLICK) && ($did == 4)) { _tips.next }
}
alias _tips.file { return $_file.isFile($_script.directory(Misc,$null,Tips.txt)) }
alias _tips.next {
  var %d = _tips
  if ($dialog(%d)) {
    var %f = $_tips.file
    if (!%f) || (!$lines(%f)) {
      did -ra %d 2 <no tips available>
      did -r %d 100
      did -b %d 4
    }
    else {
      var %x = $did(%d,100)
      inc %x
      :read
      if ($read(%f,%x) != $null) { did -ra %d 2 $v1 }
      else { 
        %x = 1
        goto read
      }
      did -ra %d 100 %x
    }
  }
}
