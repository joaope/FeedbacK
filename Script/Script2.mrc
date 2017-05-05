;______________[ userlist ]__________________________________________

alias userlist { 
  var %dname = _userlist.list, %cmd = userlist
  if ($1 != $null) {
    if ($1 == -o) { var %dname = _userlist.options, %cmd = userlisto }
    else { _themes.sintaxEcho userlist [-o] }
  }
  _advanced.openDialog %dname %cmd
}
alias users { userlist }
alias userlisto { userlist -o }
dialog _userlist.list {
  title "Userlist"
  size -1 -1 249 133
  option dbu

  box "&Users:", 1, 4 3 241 109
  list 2, 9 12 230 81, sort size

  button "&Add...", 10, 9 94 40 11
  button "&Edit...", 11, 50 94 40 11
  button "&Remove", 12, 91 94 40 11

  button "&Import...", 20, 199 94 40 11

  button "&Options...", 99, 120 117 40 11
  button "&Close", 100, 162 117 40 11, ok
  button "&Help", 98, 204 117 40 11
}
on *:DIALOG:_userlist.list:*:*:{
  if (($devent == DCLICK) && ($did == 2)) || (($devent == SCLICK) && ($did == 11)) {
    if ($gettok($did(2).seltext,1,32) != $null) { _userlist.addUser $v1 }
    else { did -b $dname 11,12 }
  }
  elseif ($devent == INIT) { _userlist.listUsers }
  elseif ($devent == SCLICK) {
    if ($did == 2) { did $iif($did(2).seltext != $null,-e,-b) $dname 11,12 }
    elseif ($did == 10) { _userlist.addUser }
    elseif ($did == 12) {
      if ($gettok($did(2).seltext,1,32) != $null) { 
        .ruser $v1 
        _userlist.listUsers 
      }
    }
    elseif ($did == 20) { _userlist.importUsers }
    elseif ($did == 99) { userlist -o }
  }
}
alias -l _userlist.listUsers {
  var %x = 1, %d = _userlist.list
  if (!$dialog(%d)) { return }
  did -r %d 2
  while ($ulist(*,*,%x)) { 
    var %host = $v1, %level = $level(%host) 
    did -a %d 2 %host ( $+ $_userlist.levelToString(%level) $+ : %level $+ ) $&
      (Networks: $iif($_userlist.userInfo(%host).networks != $null,$v1,<all>) $+ ) $&
      (Channels: $iif($_userlist.userInfo(%host).chans != $null,$v1,<all>) $+ )
    inc %x 
  }
  did -b %d 11,12
  did -z %d 2
}
alias _userlist.addUser { 
  set $_script.variableName(Userlist,Hostmask,To,Add) $1
  set $_script.variableName(Userlist,Level,To,Add) $2
  __dummy $_advanced.openDialog(_userlist.addUser).modal
}
dialog _userlist.addUser {
  title "Userlist - Add user"
  size -1 -1 255 188
  option dbu

  text "&Hostmask:", 1, 19 9 28 8
  edit "", 2, 47 8 186 11, autohs

  box "&Options:", 7, 4 73 137 93
  text "N&ickname:", 8, 10 100 28 8, right
  text "&Channels:", 9, 10 113 28 8, right
  text "&Password:", 10, 10 126 28 8, right
  text "C&omments:", 11, 10 139 28 8, right
  text "Nic&k color:", 12, 10 152 28 8, right
  edit "", 13, 39 99 95 11, autohs
  edit "", 14, 39 111 95 11, autohs
  edit "", 15, 39 124 95 11, pass autohs
  edit "", 16, 39 137 95 11, autohs
  icon 17, 39 150 11 11,  $mircexe, 0
  text "&Channels", 18, 10 100 28 8, hide right
  text "&Reason:", 19, 10 113 28 8, hide right
  edit "", 20, 39 99 95 11, hide autohs
  edit "", 21, 39 111 95 11, hide autohs
  text "&Networks:", 22, 10 86 28 8, right
  edit "", 23, 39 85 82 11, autohs
  button "...", 24, 124 85 9 11

  box "&Level:", 40, 4 27 137 44
  text "(100) Your level (added when you connect)", 41, 18 38 108 8
  radio "(50) &Friendly user", 42, 9 46 56 10
  radio "(10) &Shitlisted user", 43, 9 56 59 10

  box "F&riend flags:", 44, 146 27 105 139
  check "&Auto op (o)", 45, 153 39 94 10
  check "A&uto voice (v)", 46, 153 49 94 10
  check "Auto accept &DCC chat (c)", 47, 153 59 94 10
  check "Auto accept DCC &sends (s)", 48, 153 69 94 10
  check "E&xempted user (e)", 49, 153 79 94 10
  check "Pro&tected user (p)", 50, 153 89 94 10
  check ".(de)&voice <nick> access (V)", 51, 153 99 94 10
  check ".(de)o&p <nick> access (O)", 52, 153 109 94 10
  check ".&ban <nick|mask> access (b)", 53, 153 119 94 10
  check ".&kick <nick> [msg] access (k)", 54, 153 129 94 10
  check ".&unban <mask> access (u)", 55, 153 139 94 10
  check "Access options throu&gh notice (a)", 56, 153 149 94 10

  button "&Add", 1000, 126 172 40 11
  button "&Cancel", 999, 168 172 40 11, cancel
  button "&Help", 998, 210 172 40 11
}
on *:DIALOG:_userlist.addUser:*:*:{
  if ($devent == INIT) {
    did -g $dname 17 $_color.bmpFile(-1)
    var %host = $_script.variableValue(Userlist,HostMask,To,Add), %editing = 0, %levtoadd = $_script.variableValue(Userlist,Level,To,Add)
    ; clear temp variables
    unset $_script.variableName(Userlist,Hostmask,To,Add)
    unset $_script.variableName(Userlist,Level,To,Add)
    did -a $dname 2 %host
    if (%host != $null) {
      ; if he\she is friend...
      if ($_userlist.isLevel(%host,50)) {
        did -c $dname 42
        var %flags = $_userlist.availableFlags, %x = 1, %user.flags = $_userlist.userInfo(%host).flags, %id = 45
        while ($gettok(%flags,%x,46)) { 
          if ($v1 isincs %user.flags) { did -c $dname %id }
          inc %id 
          inc %x 
        }
        did -a $dname 13 $_userlist.userInfo(%host).nick
        did -a $dname 14 $_userlist.userInfo(%host).chans
        did -a $dname 15 $_userlist.userInfo(%host).pass
        did -a $dname 16 $_userlist.userInfo(%host).comments
        %editing = 1
        goto common
      }
      ; else if he/she is shitlisted...
      elseif ($_userlist.isLevel(%host,50)) {
        did -c $dname 43
        did -a $dname 20 $_userlist.userInfo(%host).chans
        did -a $dname 21 $_userlist.userInfo(%host).reason
        %editing = 1
        goto common
      }
      else { did -c $dname $iif(%levtoadd == 10,43,42) }
      goto end
      :common
      did -a $dname 23 $_userlist.userInfo(%host).networks
      var %col = $_userlist.userInfo(%host).nickcol
      if (%col isnum 0-) { did -g $dname 17 $_color.bmpFile(%col) }
    }
    else { did -c $dname $iif(%levtoadd == 10,43,42) }
    :end
    _userlist.prepareDialogLevel
    dialog -t $dname Userlist - $iif(%editing,Edit %host,Add user)
  }
  elseif ($devent == SCLICK) {
    if ($did == 17) {
      tokenize 32 $did(17)
      var %c = $gettok($remove($gettok($2-,-1,92),.bmp),1,95), %scol = $_prompt.selectColor(%c)
      did -g $dname 17 $_color.bmpFile(%scol) 
    }
    elseif ($did == 24) {
      var %net = $_prompt.addNetwork(Userlist)
      if ($did(23) == *) { did -r $dname 23 }
      did -a $dname 23 $iif($did(23) != $null,$chr(44)) $+ %net
    }
    elseif ($did isnum 42-43) { _userlist.prepareDialogLevel }
    elseif ($did == 1000) {
      var %host = $did(2), %level = $iif($did(42).state,friend,shit)
      if (%host == $null) { 
        _prompt.error Hostmask to add is missing. Halted!"Userlist 
        return 
      }
      if (%level == shit) { 
        var %nets = $iif($did(23),$replace($v1,$chr(32),$chr(44)),*), %chans = $iif($did(20),$v1,*), %reason = $did(21), %nickcol = $left($nopath($did(17)),2)
        addshit %host %nets $replace(%chans,$chr(32),$chr(44)) %nickcol %reason
      }
      else {
        var %_flags = $_userlist.availableFlags, %id = 45, %x = 1, %f, %+flags, %-flags, %flags
        while (%id <= 56) { 
          %f = $gettok(%_flags,%x,46) 
          if ($did(%id).state) { %+flags = $addtokcs(%+flags,%f,32) }
          else { %-flags = $addtokcs(%-flags,%f,32) }
          inc %x 
          inc %id 
        } 
        var %nets = $iif($did(23),$replace($v1,$chr(32),$chr(44)),*), %flags = $iif(%+flags,+) $+ %+flags $+ $iif(%-flags,-) %-flags, %flags = $remove(%flags,$chr(32)), $&
          %nick = $iif($did(13),$gettok($v1,1,32),<none>), %chans = $iif($did(14),$replace($v1,$chr(32),$chr(44)),*), $&
          %pass = $iif($did(15),$gettok($v1,1,32),<none>), %comments = $did(16), %nickcol = $left($nopath($did(17)),2)
        addfriend %flags %host %nets %chans %nick %pass %nickcol %comments
      }
      dialog -c $dname
      _userlist.listUsers
    }
  }
}
alias -l _userlist.prepareDialogLevel {
  var %dname = _userlist.addUser, %lev = $iif($did(%dname,42).state,50,10)
  did $iif(%lev == 50,-e,-b) %dname 45,46,47,48,49,50,51,52,53,54,55,56 
  did $iif(%lev == 50,-v,-h) %dname 8,9,13,14 
  did $iif(%lev == 50,-h,-v) %dname 18,19,20,21 
  did $iif(%lev == 50,-e,-b) %dname 10,11,15,16
}
alias -l _userlist.importUsers {
  var %file = $$_prompt.selectFile($mircdir*.ini,Userlist - Select file to import users,UserlistImportFile), %isIni = $iif($right(%file,4) == .ini,1,0), %file = $_file.fixName(%file), $&
    %x = $iif(%isIni,0,1), %y = $iif(%isIni,$ini(%file,users,0),$lines(%file)), %line, %total = 0
  while (%x <= %y) {
    if (%isIni) { %line = $readini(%file,n,users,$+(n,%x)) }
    else { %line = $read(%file,%x) }
    if (;* !iswm %line) && ($gettok(%line,2-,58) != $null) { 
      .auser $gettok(%line,1,58) $v1
      inc %total
    }
    inc %x
  }
  _userlist.listUsers
  if (!%total) { _prompt.info No entries were found."Userlist }
  else { _prompt.info Imported %total user entries."Userlist }
}

alias -l _userlist.availableFlags {
  var %flags = o.v.c.s.e.p.V.O.b.k.u.a, %chr = $iif($1 isnum,$1,46)
  return $replace(%flags,$chr(46),$chr(%chr))
}
alias -l _userlist.levelToString {
  var %lev = $1
  goto %lev
  :100 | return Me
  :50 | return Friendly
  :10 | return Shitlisted
  :%lev | return Unknown
}
alias _userlist.isLevel {
  var %fulladdress = $1, %lev = $2, %u = $ulist(%fulladdress), %currlev = $level($ulist(%fulladdress))
  if (%currlev == %lev) { return %lev }
  elseif (%lev == $null) && ($istok(10.50,%currlev,46)) { return %currlev }
}
alias -l _userlist.validMask { 
  if ($1 != $null) { 
    if (*!*@* iswm $1) { return $1 }
    if ($int($_script.getOption(Userlist,DefaultMaskType)) isnum 0-19) && ($address($1,$v1)) { return $v1 }
    else { return $1 $+ !*@* }
  }
}
alias _userlist.userInfo {
  ;              level:host <flags> <networks> <channels|*> <nick> <password> <nickcolors> <comments>
  ;              level:host <networks> <channels|*> <reason>
  var %_inf = $ulist($1).info, %lev = $level($1), %return
  if (!$prop) { return %_inf }
  if (%lev == 50) { 
    var %n = $findtok(flags.networks.chans.nick.pass.nickcol.comments,$prop,1,46)
    if (%_inf) && (%n) { %return = $gettok(%_inf,$iif(%n == 7,%n $+ -,%n),32) }
  }
  elseif (%lev == 10) {
    if ($prop == networks) { %return = $gettok(%_inf,1,32) }
    elseif ($prop == chans) { %return = $gettok(%_inf,2,32) }
    elseif ($prop == nickcol) { %return = $gettok(%_inf,3,32) }
    elseif ($prop == reason) { %return = $gettok(%_inf,4-,32) }
  }
  return $iif(%return != $null && %return != <none>,$v1)
}
alias -l _userlist.addEcho {
  if (!$show) || ($2 == $null) { return }
  if ($dialog(_userlist)) { 
    if ($1 == -e) { _prompt.error $+($2-,"Userlist) } 
    else { _prompt.info $+($2-,"Userlist) }
  } 
  else { _themes.commandEcho addfriend $2- }
}
alias addfriend {
  if ((+* iswm $1) || (-* iswm $1)) && ($2 != $null) {
    var %echo = $iif($show,/,.) $+ _userlist.addEcho
    if (+* iswm $1) { var %+flags = $remove($gettok($1,1,45),+), %-flags = $gettok($1,2,45) } 
    else { var %-flags = $remove($gettok($1,1,43),-), %+flags = $gettok($1,2,43) }
    var %mask = $_userlist.validMask($2)
    if (!%-flags) && (!%+flags) { goto sintax }

    var %flags = $_userlist.userInfo(%mask).flags, %x = 1, %_flag 
    while ($mid(%-flags,%x,1)) { 
      var %flags = $removecs(%flags,$v1) 
      inc %x 
    }
    %x = 1 
    while ($mid(%+flags,%x,1)) { 
      %_flag = $v1 
      if (%_flag !isincs %flags) && ($istok($_userlist.availableFlags,%_flag,46)) { %flags = %flags $+ %_flag }
      inc %x 
    }
    if (!%flags) { %flags = <none> }

    var %nets = $iif($3,$3,$_userlist.userInfo(%mask).networks), %chans = $iif($4,$4,$_userlist.userInfo(%mask).chans), %nick = $iif($5,$5,$_userlist.userInfo(%mask).nick), $&
      %pass = $iif($6,$6,$_userlist.userInfo(%mask).pass), %nickcol = $iif($7 isnum,$7,$_userlist.userInfo(%mask).nickcol), %comments = $iif($8,$8-,$_userlist.userInfo(%mask).comments)

    .ruser %mask 
    .auser 50 %mask %flags $iif(%nets,%nets,*) $iif(%chans,%chans,*) $iif(%nick,%nick,<none>) $iif(%pass,%pass,<none>) $iif(%nickcol isnum 0-,$_color.toMircColor($v1),-1) %comments
    if ($show) { _themes.commandEcho addfriend Added %mask to userlist as a friend. }
    return $true
  }
  else { 
    :sintax 
    _themes.sintaxEcho addfriend <+ovcsepVObkua-ovcsepVObkua> <nick|mask> [networks|*] [channels|*] [nick] [password] [nickcolor] [comments] 
    return $false 
  }
}
alias addshit {
  if ($1) {
    var %mask = $_userlist.validMask($1), %nets = $iif($2,$2,$_userlist.userInfo(%mask).networks), %chans = $iif($3,$3,$_userlist.userInfo(%mask).chans), $&
      %nickcol = $iif($4 isnum,$4,$_userlist.userInfo(%mask).nickcol), %reason = $iif($5,$5-,$_userlist.userInfo(%mask).reason)
    .ruser %mask 
    .auser 10 %mask $iif(%nets,%nets,*) $iif(%chans,%chans,*) $iif(%nickcol isnum 0-,$_color.toMircColor(%nickcol),-1) %reason
    if ($show) { _themes.commandEcho addshit Added %mask to userlist as a shited user. }
    return $true
  }
  else { 
    _themes.sintaxEcho addshit <nick|mask> [networks|*] [channels|*] [nickcolor] [reason] 
    return $false 
  }
}
alias -l _userlist.checkChannel {
  var %chan = $2, %net = $_network.active, %chans = $_userlist.userInfo($1).chans, %nets = $_userlist.userInfo($1).networks
  if ((%nets == *) || ($istok(%nets,%net,44))) && ((%chans == *) || ($istok(%chans,%chan,44))) { return %chan }
}
alias -l _userlist.sendHelpNotice {
  var %cmds = IDENTIFY.NICK.PASS.CHANNELS.HELP, %nick = $1, %cmd = $2, %topic = $3
  if (%nick) && ($istok(%cmds,%cmd,46)) {
    goto %cmd
    :IDENTIFY | .notice %nick IDENTIFY - /notice <mynick> IDENTIFY <password> | return
    :NICK | .notice %nick NICK - /notice <mynick> NICK <newnick> | return
    :PASS | .notice %nick PASS - /notice <mynick> PASS <password> <newpass> | return
    :CHANNELS | .notice %nick CHANNELS - /notice <mynick> CHANNELS <#chan1,#chanN|*>
    :NETWORKS | .notice %nick NETWORKS - /notice <mynick> NETWORKS <network1,networkN|*>
    :HELP 
    if (%topic) && ($istok(%cmds,%topic,46)) { goto %topic }
    else { .notice %nick HELP - /notice <mynick> HELP <topic> (Topics: IDENTIFY, NICK, PASS, CHANNELS, NETWORKS) }
  }
}
alias -l _userlist.shitAction {
  if (!$2) { return }
  var %chan = $1, %nick = $2, %fulladdress = $3
  if ($__bantype isnum 0-19) && ($address(%fulladdress,$__bantype)) { var %banmask = $v1 }
  else { var %banmask = %nick $+ !*@* }
  if ($_userlist.userInfo(%fulladdress).reason) { var %reason = $v1 }
  elseif ($_script.getOption(Userlist,DefaultShitKick)) { var %reason = $v1 }
  else { var %reason = Shitlisted user! }
  if ($_channel.meOp(%chan)) {
    if ($_script.getOption(Userlist,ShittedBanned)) { _channel.mode +b %chan %banmask }
    if ($_script.getOption(Userlist,ShittedKicked)) && (%nick ison %chan) { _channel.massKick %chan %nick %reason }
    if ($_script.getOption(Userlist,ShittedDeopped)) && (%nick isop %chan) && ($nick != $me) { _channel.mode -o %chan %nick }
  }
  if ($_script.getOption(Userlist,ShittedIgnored)) { ignore %nick $__defaultIgnoreMask }
}
alias _userlist.friendIsIdentified { return $_script.variableValue(Userlist,FriendIdentified,$cid,$1) }

#_Userlist off
on *:CONNECT:{ var %m = $iif($__myAddress,.auser 100 $v1) }
on @*:JOIN:#:{
  var %flags = $_userlist.userInfo($fulladdress).flags
  if ($_userlist.checkChannel($fulladdress,$chan)) { var %chan = $v1 }
  else { return }
  if ($ulevel == 50) { 
    if ($_script.getOption(userlist,OppedVoicedIfIdentified)) && (!$_userlist.friendIsIdentified($nick)) { return }
    if (o isincs %flags) { _channel.mode +o %chan $nick }
    if (v isincs %flags) { _channel.mode +v %chan $nick }
  }
  elseif ($ulevel == 10) { _userlist.shitAction $chan $nick $fulladdress }
}
on @!*:OP:#:{ 
  var %fulladdress = $address($opnick,5)
  if ($_userlist.isLevel(%fulladdress,10)) { _userlist.shitAction $chan $opnick %fulladdress }
}
on @!*:DEOP:#:{
  if ($nick == $me) { return }
  var %fulladdress = $address($opnick,5), %flags = $_userlist.userInfo(%fulladdress).flags
  if ($_userlist.checkChannel(%fulladdress,$chan)) { var %chan = $v1 }
  else { return }
  if ($_userlist.isLevel(%fulladdress,50)) {
    if (p isincs %flags) { 
      if ($_script.getOption(Userlist,ProtectedIfIdentified)) && (!$_userlist.friendIsIdentified($opnick)) { goto next }
      _channel.mode -o %chan $nick 
      _channel.mode +o %chan $opnick 
    }
    :next
    if (o isincs %flags) { 
      if $_script.getOption(Userlist,OppedVoicedIfIdentified)) && (!$_userlist.friendIsIdentified($opnick)) { return }
      _channel.mode +o %chan $opnick
    }
  }
}
on @!*:DEVOICE:#:{
  if ($nick == $me) { return }
  var %fulladdress = $address($vnick,5), %flags = $_userlist.userInfo(%fulladdress).flags
  if ($_userlist.checkChannel(%fulladdress,$chan)) { var %chan = $v1 }
  else { return }
  if ($_userlist.isLevel(%fulladdress,50)) {
    if ($_script.getOption(Userlist,OppedVoicedIfIdentified)) && (!$_userlist.friendIsIdentified($vnick)) { return }
    if (o isincs %flags) { _channel.mode +v %chan $vnick }
  }
}
CTCP 50:*:?:{
  if ($1 != DCC) { return }
  var %flags = $_userlist.userInfo($fulladdress).flags
  if (c isincs %flags) && ($2 == CHAT) { 
    var %a.creq = $creq 
    .creq auto 
    .timer 1 2 .creq %a.creq  
  }
  elseif (s isincs %flags) && ($2 == SEND) { 
    var %a.sreq = $sreq 
    .sreq auto 
    .timer 1 2 .sreq %a.sreq 
  }
}
on @!*:KICK:#:{
  if (($_script.getOption(Userlist,ProtectedIfIdentified)) && (!$_userlist.friendIsIdentified($opnick))) || ($nick == $me) { return }
  var %fulladdress = $address($knick,5)
  if ($_userlist.isLevel(%fulladdress,50)) && (p isincs $_userlist.userInfo(%fulladdress).flags) { _channel.massKick $chan $nick Protected user } 
}
on @50:TEXT:.*:#:{
  var %cmds = .voice_.op_.kick_.ban_.unban_.devoice_.deop
  if ($istok(%cmds,$1,95)) {
    if ($_script.getOption(Userlist,AccessCommandsIfIdentified)) && (!$_userlist.friendIsIdentified($nick)) { 
      .notice $nick You need to identify yourself before use this commands. 
      return 
    }
    goto $1

    :.VOICE | :.DEVOICE | :.OP | :.DEOP
    if ($1 == .voice) { var %f = +v }
    elseif ($1 == .devoice) { var %f = -v }
    elseif ($1 == .op) { var %f = +o }
    else { var %f = -o }
    if ($2) {
      if ($2 ison $chan) { _channel.mode %f $chan $2 }
      else { .notice $nick Nick $2 isn't on $chan $+  } 
    }
    else { .notice $nick Usage: $lower($1) <nick> }
    return

    :.UNBAN
    if ($2) { 
      if ($_channel.isInBanList($chan,$2)) { _channel.mode -b $chan $2 }
      else { .notice $nick Mask $2 isn't on $chan Ban List } 
    }
    else { .notice $nick Usage: .unban <mask> }
    return

    :.BAN
    if ($2) { 
      if (*!*@* iswm $2) { var %mask = $2 }
      else { var %mask = $2 $+ !*@* }
      if ($__isInMyAddress(%mask)) { .notice $nick That mask ( $+ %mask $+ ) will affect me. Halted } 
      else { _channel.mode +b $chan $2 }
    }
    else { .notice $nick Usage: .ban <mask> }
    return

    :.KICK
    if ($2) { 
      if ($2 ison $chan) { _channel.massKick $chan $2 $iif($3,$3-,Kick requested by $nick) }
      else { .notice $nick Nick $2 isn't on $chan $+  }
    }
    else { .notice $nick Usage: .kick <nick> [msg] }
  }
}
on ^50:NOTICE:*:?:{
  var %cmds = .NETWORKS.IDENTIFY.NICK.PASS.CHANNELS.HELP, %flags = $_userlist.userInfo($fulladdress).flags
  if (!$istok(%cmds,$1,46)) { return }
  elseif (a isincs %flags) {
    haltdef
    if ($_script.getOption(Userlist,AccessOptionsIfIdentified)) && (!$_userlist.friendIsIdentified($nick)) && ($1 != IDENTIFY) { 
      .notice $nick You need to identify yourself to access options through NOTICE. 
      return 
    }
    var %i.flags = $iif($_userlist.userInfo($fulladdress).flags,+ $+ $v1,-ovcsepVObkua), %i.mask = $ulist($fulladdress), %i.chans = $iif($_userlist.userInfo($fulladdress).chans,$v1,*), $&
      %i.pass = $iif($_userlist.userInfo($fulladdress).pass,$v1,<none>), %i.nickcol = $iif($_userlist.userInfo($fulladdress).nickcol isnum 0-15,$v1,20), $&
      %i.nick = $iif($_userlist.userInfo($fulladdress).nick,$v1,<none>), %i.comments = $_userlist.userInfo($fulladdress).comments, $&
      %nets = $iif($_userlist.userInfo($fulladdress).networks,$v1,*)
    goto $1
    :NETWORKS
    if ($2 != $null) {
      .addfriend %i.flags %i.mask $replace($2-,$chr(32),$chr(44)) %i.chans %i.nick %i.pass %i.nickcol %i.comments 
    }
    else { _userlist.sendHelpNotice $nick NETWORKS }
    return
    :IDENTIFY
    if ($2) {
      if ($2 === %i.pass) && (%i.pass != <none>) { 
        set $_script.variableName(Userlist,FriendIdentified,$cid,$nick) 1 
        .notice $nick IDENTIFY - You've been identified.
      } 
      else { .notice $nick IDENTIFY - Wrong password (don't forget that is case-sensitive) }
    }
    else { _userlist.sendHelpNotice $nick IDENTIFY }
    return
    :NICK
    if ($2) { 
      .addfriend %i.flags %i.mask %nets %i.chans $2 %i.pass %i.nickcol %i.comments 
      .notice $nick NICK - Nick sucessfully changed to $2 $+ 
    }
    else { _userlist.sendHelpNotice $nick NICK }
    return
    :PASS
    if ($3) {
      if ($2 === %i.pass) && (%i.pass != <none>) {
        .addfriend %i.flags %i.mask %nets %i.chans %i.nick $3 %i.nickcol %i.comments 
        .notice $nick PASS - Password sucessfully changed to $3 $+ . Don't forget it. 
      }
      else { .notice $nick PASS - Wrong password (don't forget that is case-sensitive) }
    }
    else { _userlist.sendHelpNotice $nick PASS }
    return
    :CHANNELS
    if ($2) { 
      var %c = $replace($2-,$chr(32),$chr(44)) 
      .addfriend %i.flags %i.mask %nets %c %i.nick %i.nickcol %i.comments 
      .notice $nick CHANNELS - Changed channels ( $+ $iif(%c == *,all channels,%c)) $+ ) 
    }
    else { _userlist.sendHelpNotice $nick CHANNELS }
    return
    :HELP 
    _userlist.sendHelpNotice $nick HELP $2
  }
  else { .notice $nick You don't have access to options through NOTICE. }
  haltdef
}
#_Userlist end

; userlist options
dialog _userlist.options {
  title "Userlist options"
  size -1 -1 191 193
  option dbu

  check "&Enable userlist (all it's functions)", 100, 13 9 100 10

  box "&Friends should be identified to...", 102, 5 26 94 73
  check "...&access .commands", 103, 13 39 80 10
  check "...access &his options", 104, 13 50 80 10
  check "...&be auto-opped/voiced", 105, 13 61 80 10
  check "...be &protected", 106, 13 72 80 10
  check "...be p&rotections exempted", 107, 13 83 80 10

  box "&Shited users will be...", 108, 106 26 79 73
  check "...&kicked", 109, 115 39 63 10
  check "...ba&nned", 110, 115 50 63 10
  check "...&ignored", 111, 115 61 63 10
  check "...&deopped if opped", 112, 115 73 63 10

  box "", 113, 5 103 180 63
  text "&Default kick reason for shited users:", 114, 14 115 118 8
  edit "", 115, 13 123 163 11
  text "Default mask type:", 116, 14 139 76 8
  combo 117, 13 147 163 100, size drop

  button "&Ok", 1000, 61 174 40 11, ok
  button "&Cancel", 999, 103 174 40 11, cancel
  button "&Help", 998, 145 174 40 11
}
on *:DIALOG:_userlist.options:*:*:{
  if ($devent == INIT) {
    _dialog.listMasks $dname 117
    if ($_script.getOption(Userlist,EnableUserlist)) { did -c $dname 100 }
    else { did -b $dname 103,104,105,106,107,109,110,111,112,115,117 }
    if ($_script.getOption(Userlist,AccessCommandsIfIdentified)) { did -c $dname 103 } 
    if ($_script.getOption(Userlist,AccessOptionsIfIdentified)) { did -c $dname 104 }
    if ($_script.getOption(Userlist,OppedVoicesIfIdentified)) { did -c $dname 105 }
    if ($_script.getOption(Userlist,ProtectedIfIdentified)) { did -c $dname 106 }
    if ($_script.getOption(Userlist,ExemptedIfIdentified)) { did -c $dname 107 }
    if ($_script.getOption(Userlist,ShittedKicked)) { did -c $dname 109 }
    if ($_script.getOption(Userlist,ShittedBanned)) { did -c $dname 110 }
    if ($_script.getOption(Userlist,ShittedIgnored)) { did -c $dname 111 }
    if ($_script.getOption(Userlist,ShittedDeopped)) { did -c $dname 112 }
    did -a $dname 115 $iif($_script.getOption(Userlist,DefaultShitKick) != $null,$v1,Shitlisted user!)
    if ($_script.getOption(Userlist,DefaultMaskType) isnum 0-19) { did -c $dname 117 $calc($v1 + 1) }
    else { did -c $dname 117 21 }
  }
  elseif ($devent == SCLICK) {
    if ($did == 100) { did $iif($did(100).state,-e,-b) $dname 103,104,105,106,107,109,110,111,112,115,117 }
    if ($did == 1000) {
      var %» = _script.setOption Userlist
      if ($did(100).state) { 
        %» EnableUserlist 1 
        .enable #_Userlist
      } 
      else { 
        %» EnableUserlist 0
        .disable #_Userlist
      }
      %» AccessCommandsIfIdentified $did(103).state
      %» AccessOptionsIfIdentified $did(104).state
      %» OppedVoicesIfIdentified $did(105).state
      %» ProtectedIfIdentified $did(106).state
      %» ExemptedIfIdentified $did(107).state
      %» ShittedKicked $did(109).state
      %» ShittedBanned $did(110).state
      %» ShittedIgnored $did(111).state
      %» ShittedDeopped $did(112).state
      %» DefaultShitKick $did(115)
      %» DefaultMaskType $iif($did(117).sel isnum 1-20,$calc($v1 - 1),20)
    }
  }
  elseif ($devent == CLOSE) {
    if ($dialog(_userlist)) { dialog -v _userlist }
  }
}



;______________[ rgb ]__________________________________________

alias _rgb.selectColor {
  var %dname = _rgb.select
  if ($1 isnum) && ($2 isnum) && ($3 isnum) { set $_script.variableName(Rgb,ReturnType) 1 }
  else {
    unset $_script.variableName(Rgb,ReturnType)
    tokenize 44 $iif($1 isnum,$rgb($1), $+(0,$chr(44),0,$chr(44),0) )
  }
  set $_script.variableName(Rgb,CurrentColor) $1-3
  var %rgb = $dialog(%dname,%dname,-4)
  if (%rgb isnum) {
    if ($_script.variableValue(Rgb,ReturnType)) { return $rgb(%rgb) }
    return %rgb
  }
}
dialog _rgb.select {
  title ""
  size -1 -1 151 130
  option dbu
  box "", 1, 4 4 142 105
  scroll "", 2, 17 25 8 64, range 255
  scroll "", 3, 40 25 8 64, range 255
  scroll "", 4, 63 25 8 64, range 255
  edit "", 5, 12 91 18 12, read center
  edit "", 6, 35 91 18 12, read center
  edit "", 7, 58 91 18 12, read center
  text "rgb value", 9, 91 67 38 8, result center
  box "", 10, 87 61 46 16
  text "Red", 11, 16 15 10 8
  text "Green", 12, 37 15 15 8
  text "Blue", 13, 61 15 11 8
  button "&Select", 100, 61 114 41 11, ok
  button "&Cancel", 99, 104 114 41 11, cancel
  icon 8, 86 34 48 28
}
on *:DIALOG:_rgb.select:*:*:{
  if ($devent == INIT) {
    dialog -t $dname $_script.name - Select RGB color
    tokenize 32 $_script.variableValue(Rgb,CurrentColor)
    did -c $dname 2 $1
    did -c $dname 3 $2
    did -c $dname 4 $3
    did -f $dname 8
    _rgb.updateDialogValues
  }
  elseif ($devent == SCROLL) { _rgb.updateDialogValues }
}
alias -l _rgb.updateDialogValues {
  var %dname = _rgb.select, %r = $did(%dname,2).sel, %g = $did(%dname,3).sel, %b = $did(%dname,4).sel, %rgb = $rgb(%r,%g,%b)
  did -ra %dname 5 %r
  did -ra %dname 6 %g
  did -ra %dname 7 %b
  did -ra %dname 9 %rgb
  did -g %dname 8 $_rgb.buildColor(%rgb)
}
alias -l _rgb.buildColor {
  var %col = $1, %size = $calc($dbuw * 45) $calc($dbuh * 26), %file, %win = @_temp._rgb.buildColor
  window -c %win 
  window -hkp +d %win 0 0 %size
  var %file = $_script.directory(images,$null,_rgbSelectedColor.bmp)
  drawrect -fr %win %col 10 0 0 %size
  drawsave %win %file
  if ($isfile(%file)) { return %file }
}



;_____________[ lagbar ] ________________________________________

menu @Lagbar {
  uclick:{ .timerLAGBAR~MOVE off } 
  sclick:{ .timerLAGBAR~MOVE -m 0 1 _lagbar.mouse $calc($mouse.dx - $window($active).dx) $calc($mouse.dy - $window($active).dy) }
}
alias lagbar {
  if ($1 == $null) || (!$istok(on off,$1,32)) { _themes.sintaxEcho lagbar <on|off> } 
  else {
    var %win = @Lagbar
    _script.setOption Lagbar Enable $iif($1 == on,1,0) 
    _themes.commandEcho lagbar Lagbar $+(,$upper($1),) 
    _lagbar.work
    showmirc -s
    if ($window(%win)) { window -o %win }
  }
}
alias _lagbar.defaultPosition {
  var %p = $calc($window(-2).x + $window(-2).w - 300) $&
    $calc($window(-3).y - $iif($_mirc.iniOption(3,8),23,19) - $iif($_mirc.iniOption(4,21) == 1 && $_mirc.iniOption(5,23),$calc($_mirc.iniOption(5,24) + 1),0)) 
  return %p
}
alias _lagbar.setDefaultPosition {
  var %p = $_lagbar.defaultPosition, %win = @Lagbar
  if ($window(%win)) { window %win %p } 
  _script.setOption Lagbar WindowPosition %p
}
alias _lagbar.mouse {
  if ($mouse.key != 1) { .timerLAGBAR~MOVE off } 
  else {
    if ($calc($mouse.dy - $2) != -1) { var %p = $calc($mouse.dx - $1) $v1 }
    else { var %p = $calc($mouse.dx - $1) -2 }
    window @lagbar %p 
    _script.setOption Lagbar WindowPosition %p
  }
}
alias _lagbar.colors {
  if ($1 == background) { return $iif($_script.getOption(Lagbar,BackgroundColor) isnum,$v1,0) }
  if ($1 == bar) { return $iif($_script.getOption(Lagbar,BarColor) isnum,$v1,65535) }
  if ($1 == text) { return $iif($_script.getOption(Lagbar,TextColor) isnum,$v1,16753664) }
}
alias _lagbar.work {
  var %timer = LAGBAR~UPDATE, %win = @Lagbar
  if (!$_script.getOption(Lagbar,Enable)) { 
    if ($timer(%timer)) { .timer $+ %timer off }
    if ($window(%win)) { window -c %win }
    return
  }
  if (!$timer(%timer)) { .timer $+ %timer -i 0 1 _lagbar.work }
  if (!$window(%win)) { 
    window -pdha +dL %win $iif($_script.getOption(Lagbar,WindowPosition),$v1,$_lagbar.defaultPosition) 253 18
    window -ar %win 
  }
  drawrect -nrf %win $rgb(shadow) 1 0 0 249 16
  drawrect -nrf %win $_lagbar.colors(background) 1 1 1 247 13
  drawrect -n %win 1 1 1 1 249 15
  drawdot %win
  if ($_lag.time) {
    var %lag = $v1, %p = $left($_math.percentage(%lag,10),-1)
    if (%p >= 100) { drawrect -f %win $_lagbar.colors(bar) 1 2 2 246 12 }
    else { drawrect -rf %win $_lagbar.colors(bar) 1 2 2 $calc(246 * %p / 100) 12 }
    drawtext -ro %win $_lagbar.colors(text) "MS Sans Serif" 1 107 1 %lag
  }
}
on *:APPACTIVE:{ 
  var %win = @Lagbar, %timer = LAGBAR~UPDATE
  if ($window(%win)) { 
    if ($appactive) { window -o %win }
    else { window -uh %win }
    if (!$timer(%timer)) { .timer $+ %timer -i 0 1 _lagbar.work }
  }
}


;_____________[ perform ] ________________________________________

alias perform { _advanced.openDialog _perform.events perform }
dialog _perform.events {
  title "Perform on events"
  size -1 -1 223 207
  option dbu
  box "", 1, 5 3 213 40
  text "&Network:", 2, 12 15 25 8
  combo 3, 38 14 83 50, size drop
  button "&Add...", 4, 126 14 40 11
  button "&Remove", 5, 168 14 40 11
  check "&Use default event sets", 6, 38 27 75 10
  box "", 12, 5 46 213 135
  text "C&ommands to perform on:", 13, 12 58 69 8
  combo 14, 138 57 72 100, size drop
  edit "", 15, 11 69 199 89, multi return autohs autovs hsbar vsbar
  text "&Delay between commands (miliseconds):", 16, 12 164 102 8
  edit "", 17, 162 162 48 11, autohs right
  edit "", 1000, 21 30 0 0, hide disable autohs
  button "&Ok", 100, 94 189 40 11, ok
  button "&Cancel", 99, 136 189 40 11, cancel
  button "&Help", 98, 178 189 40 11
}
on *:DIALOG:_perform.events:*:*:{
  if ($devent == INIT) {
    hfree -w $_hash.prefixed(TEMP-perform-*-*)
    var %x = 1, %names = $_hash.allMatching(Perform-*-*), %nets = (Default)
    while ($gettok(%names,%x,32) != $null) {
      var %i = $_hash.notPrefixed($v1), %net = $gettok(%i,3-,45)
      %nets = $addtok(%nets,%net,32)
      _hash.toHash %i $+(TEMP-,%i)
      inc %x
    }
    didtok $dname 3 32 %nets
    if ($didwm(3,$_script.getOption(Perform,LastNetworkSelected))) { did -c $dname 3 $v1 }
    else { did -c $dname 3 1 }
    didtok $dname 14 46 $_perform.availableEvents($did(3))
    if ($didwm(14,$_script.getOption(Perform,LastEventSelected))) { did -c $dname 14 $v1 }
    set $_script.variableName(Perform,UseDefaultOnThisNets) $_script.getOption(Perform,UseDefaultOnThisNets)
    _perform.loadEvent -first
  }
  elseif ($devent == CLOSE) {
    _script.setOption Perform LastNetworkSelected $did(3)
    _script.setOption Perform LastEventSelected $did(14)
    unset $_script.variableName(Perform,*)
  }
  elseif ($devent == SCLICK) {
    if ($did == 3) {
      var %sel_event = $did(14).seltext, %net = $did(3).seltext
      if (%net == $null) { return }
      did -r $dname 14
      didtok $dname 14 46 $_perform.availableEvents(%net)
      if ($didwm(14,%sel_event)) { did -c $dname 14 $v1 }
      _perform.loadEvent
    }
    elseif ($did == 4) {
      var %net = $_prompt.addNetwork(Perform)
      if ($didwm(3,%net)) { did -c $dname 3 $v1 }
      else {
        did -ac $dname 3 %net
        did -u $dname 14
      }
      _perform.loadEvent
    }
    if ($did == 5) && ($did(3).seltext) {
      var %net = $v1, %sel = $did(3).sel, %prev_sel = $iif($calc(%sel - 1),$v1,1)
      if (%net != (Default)) && ($_prompt.yesNo(Do you really want to remove $+(',%net,') perform settings?"Perform)) {
        hfree -w $_hash.prefixed($+(TEMP-Perform-*-,%net))
        did -d $dname 3 $did(3).sel
        did -u $dname 14
        did -c $dname 3 %prev_sel
        set $_script.variableName(Perform,UseDefaultOnThisNets) $remtok($_script.variableValue(perform,UseDefaultOnThisNets),%net,1,32)
        _perform.loadEvent
      }
    }
    elseif ($did == 6) { 
      did $iif($did(6).state,-b,-e) $dname 14,15,17
      _perform.saveEvent
    }
    elseif ($did == 14) { _perform.loadEvent }
    elseif ($did == 100) {
      _perform.saveEvent 
      hfree -w $_hash.prefixed(Perform-*-*)
      var %x = 1, %hashs = $_hash.allMatching(TEMP-Perform-*-*), %i
      while ($gettok(%hashs,%x,32) != $null) {
        %i = $_hash.notPrefixed($v1)
        _hash.toHash -o %i $gettok(%i,2-,45)
        inc %x
      }
      _script.setOption Perform UseDefaultOnThisNets $_script.variableValue(Perform,UseDefaultOnThisNets)
    }
  }
}
alias -l _perform.availableEvents {
  var %e = Start.Exit. .Join (You join).Part (You part). .Kick (You kick).Kick (You're kicked).Ban (You ban).Ban (You're banned). .Channel text.Channel action.Private text.Private action. .Channel Notice.Private Notice. $&
    .Invite.Notify.UNotify. .Owner.Deowner.Op.Deop.Voice.Devoice. .Away.Back.
  if ($1 == (Default)) { return %e } 
  return $gettok(%e,4-,46)
}
alias -l _perform.loadEvent {
  if ($1 != -first) { _perform.saveEvent }
  var %dname = _perform.events, %net = $did(%dname,3), %event = $iif($remove($did(%dname,14),$chr(32)) != $null,$v1,<null>), %hash = $+(TEMP-Perform-,%event,-,%net)
  did -u $dname 6
  if (%net == (Default)) { did -b %dname 6 }
  else { did -e %dname 6 }
  did -r $dname 15
  if ($istok($_script.variableValue(Perform,UseDefaultOnThisNets),%net,32)) && (%net != (Default)) { 
    did -c %dname 6 
    did -b %dname 14,15,17
  }
  else { did -e %dname 14,15,17 }
  if (%net != $null) && (%event != $null) && (%event != <null>) {
    var %x = 1
    while ($_script.getOption(%hash,%x) != $null) {
      did -i %dname 15 %x $v1 
      inc %x
    }
    did -ra %dname 17 $iif($_script.getOption(%hash,DelayTime) isnum 1-,$v1,0)
  }
  did -ra %dname 1000 %hash
}
alias -l _perform.saveEvent {
  var %dname = _perform.events, %hash = $did(%dname,1000), %x = 1, %n = 1, %y = $did(%dname,15).lines, %net = $gettok(%hash,4-,45), $&
    %defs = $_script.variableValue(Perform,UseDefaultOnThisNets)
  set $_script.variableName(Perform,UseDefaultOnThisNets) $iif($did(%dname,6).state, $addtok(%defs,%net,32), $remtok(%defs,%net,1,32) )
  if (%hash == $null) { return }
  if ($hget($_hash.prefixed(%hash))) { hfree $v1 }
  while (%x <= %y) {
    if ($did(%dname,15,%x) != $null) { 
      _script.setOption %hash %n $v1 
      inc %n
    }
    inc %x
  }
  _script.setOption %hash DelayTime $gettok($did(%dname,17),1,32)
}
alias _perform.work {
  var %net = $_network.active, %event = $remove($1-,$chr(32))
  if ($istok($_script.getOption(Perform,UseDefaultOnThisNets), %net,32)) || (%net == $null) { %net = (Default) }
  if (!$istok($_perform.availableEvents(%net),%event,46)) { return }
  var %hash = $_hash.prefixed($+(Perform-,$remove(%event,$chr(32)),-,%net)), %x = 1, %file = $_script.directory(temporary,$null,Perform_play.txt)
  write -c %file
  while ($_script.getOption(%hash,%x) != $null) {
    write %file $v1
    inc %x
  }
  .play -cs %file $iif($int($_script.getOption(%hash,DelayTime)), $v1, 0)
}



;_____________[ logviewer ] ________________________________________

alias logs {
  var %win = @Logs, %ls
  if (!$findfile($logdir,*.log,1)) { 
    _prompt.info There are no logs available."Logs 
    return 
  } 
  else {
    if ($window(%win)) { window -c %win }
    window -ikSl18 %win -1 -1 
    %ls = $findfile($logdir,*.log,0,aline -l %win $nopath($1-)) 
    __echoicon %win $+(,%ls,) log $+ $iif(%ls != 1,s) listed from $+(,$logdir,)
    __echoicon %win To read a log double click in a file.
  }
}
menu @Logs {
  DCLICK:{
    clear $active 
    if ($sline($active,1)) { 
      var %c = $logdir $+ $sline($active,1) 
      loadbuf -p $active $_file.fixName(%c) 
    }
  }
  &Find text...:{ findtext -n $_prompt.input(Text to search:"~"Find text",tch"LogsViewerFindText) }
  -  
  &Remove selected file(s):{
    var %n = 1, %stotal = $sline($active,0), %log 
    if (!%stotal) { return } 
    while (%n <= %stotal) { 
      %log = $_file.fixName($logdir $+ $sline($active,%n) )
      dline -l $active $sline($active,%n).ln 
      .remove -b %log 
      __echoicon $active Removed $+(,$nopath(%log),) 
      inc %n 
    }
  }
  -
  Refre&sh:{ logs }
  &Close:{ window -c $active } 
}



;______________[ euro ]__________________________________________

dialog _euro.converter {
  title "Euro converter"
  size -1 -1 197 155
  option dbu
  tab "C&alculate", 4, 5 4 185 129
  text "C&ountry:", 7, 23 30 22 8, tab 4
  combo 8, 46 29 121 120, tab 4 size drop
  box "", 9, 11 47 173 80, tab 4
  text "Co&untry:", 10, 28 62 25 8, tab 4 right
  edit "", 11, 54 60 102 11, tab 4 read autohs
  text "Cu&rrency:", 12, 28 74 25 8, tab 4 right
  edit "", 13, 54 72 102 11, tab 4 read autohs
  edit "", 14, 18 93 44 11, tab 4 autohs
  text "Euro(s) equals to", 15, 65 95 43 8, tab 4
  edit "", 17, 113 93 44 11, tab 4 read autohs
  text "local(s)", 18, 160 95 22 8, tab 4
  edit "", 19, 18 107 44 11, tab 4 autohs
  text "Local(s) equals to", 20, 65 109 46 8, tab 4
  edit "", 22, 113 107 44 11, tab 4 read autohs
  text "euro(s)", 23, 160 109 22 8, tab 4
  tab "&Options", 5
  text "&Result rounded to decimal digit:", 26, 17 30 89 8, tab 5
  edit "", 27, 123 28 53 11, tab 5 autohs right
  check "&Say calculated result on active channel (if any)", 24, 17 40 125 10, tab 5
  check "S&ay calculated result on active query (if any)", 25, 17 50 126 10, tab 5
  box "C&ustom country (all parameters needed):", 28, 11 71 173 56, tab 5
  text "&Name:", 29, 16 86 39 8, tab 5 right
  edit "", 30, 57 85 73 11, tab 5 autohs
  text "&Initials:", 31, 137 86 17 8, tab 5
  edit "", 32, 154 85 22 11, tab 5 limit 3
  text "Cu&rrency:", 33, 16 98 39 8, tab 5 right
  edit "", 34, 57 97 119 11, tab 5 autohs
  text "&Exchange rate:", 35, 16 110 39 8, tab 5 right
  edit "", 36, 57 109 119 11, tab 5 autohs
  box "", 6, 11 21 173 45, tab 5

  button "&Close", 100, 151 139 40 11, cancel
  button "&Help", 1, 109 139 40 11
}
on *:DIALOG:_euro.converter:*:*:{
  if ($devent == INIT) {
    _euro.listCountries
    did -a $dname 27 $_euro.round
    if ($_script.getOption(Euro,SayResultToChannel)) { did -c $dname 24 }
    if ($_script.getOption(Euro,sayResultToQuery)) { did -c $dname 25 }
    did -a $dname 30 $_script.getOption(Euro,CustomName)
    did -a $dname 32 $_script.getOption(Euro,CustomInitials)
    did -a $dname 34 $_script.getOption(Euro,CustomCurrency) 
    did -a $dname 36 $_script.getOption(Euro,CustomRate)
  } 
  elseif ($devent == SCLICK) {
    if ($did == 4) { _euro.listCountries }
    elseif ($did == 8) { 
      _euro.loadCountry $_euro.countryData($did(8).sel) 
      _script.setOption LastCountrySelected $did(8).sel 
    }
    elseif ($did == 24) { _script.setOption Euro SayResultToChannel $did(24).state }
    elseif ($did == 25) { _script.setOption Euro SayResultToQuery $did(25).state }
  }
  elseif ($devent == EDIT) {
    if ($istok(14 19,$did,32)) {
      if ($did(8).sel) {
        var %d = $_euro.countryData($v1), %switch = $iif($did == 14,-l,-e), %init = $gettok(%d,1,95), %tocalc = $iif($did == 14,$did(14),$did(19)), $&
          %calc = $_euro.calculateConversion(%switch,%init,%tocalc,$_euro.round) 
        if (%calc != $null) {
          did -ra $dname $iif($did == 14,17,22) %calc
          var %curr =  $+ $left($gettok(%d,1,95),2) $+  $+ $right($gettok(%d,1,95),1), %country =  $+ $left($gettok(%d,2,95),1) $+  $+ $right($gettok(%d,2,95),-1), $&
            %msg =  $+ %tocalc $+  $iif(e isin %switch,%curr,euros) are %calc $+  $iif(e isin %switch,euros,%curr)) (Currency from %country $+ )
          if ($_script.getOption(Euro,SayResultToChannel)) && ($active ischan) { msg $active %msg }
          elseif ($_script.getOption(Euro,SayResultToChannel)) && ($query($active)) && ($active != $me) { msg $active %msg }
        }
        else { did -r $dname $iif($did == 14,17,22) }
      }
    }
    elseif ($did == 27) { _script.setOption Euro RoundTo $did(27) }
    elseif ($did == 30) { _script.setOption Euro CustomName $did(30) }
    elseif ($did == 32) { _script.setOption Euro CustomInitials $did(32) }
    elseif ($did == 34) { _script.setOption Euro CustomCurrency $did(34) }
    elseif ($did == 36) { _script.setOption Euro CustomRate $did(36) }
  }
}
alias euro {
  if ($isid) { return $_euro.calculateConversion($1,$2,$3) }
  elseif ($1 == $null) { _advanced.openDialog _euro.converter euro }
  else {
    if (-* !iswm $1) || ($3 !isnum 0-) || (!$_string.areValidFlags($remove($1,-),els)) { 
      :sintax 
      _themes.sintaxEcho euro <-els> <initials> <N> 
      return 
    }
    var %x = 1, %i 
    while ($_euro.countryData(%x)) { 
      %i = $v1 
      if ($gettok(%i,1,95) == $2) { 
        var %rate = $gettok(%i,4,95) 
        goto a 
      } 
      inc %x 
    }
    :a 
    if (!%rate) { 
      _themes.commandEcho euro Country ( $+ $2) $+ ) doesn't exist. Check countries list. 
      return 
    }
    if (e isincs $1) && (l !isincs $1) { var %calc = $_euro.calculateConversion($1,$2,$3,$_euro.round) } 
    elseif (l isincs $1) && (e !isincs $1) { var %calc = $_euro.calculateConversion($1,$2,$3,$_euro.round) }
    if (%calc == $null) { _themes.commandEcho euro Result cannot be found. Try again with the right parameters. }
    else {
      var %curr =  $+ $left($gettok(%i,1,95),2) $+  $+ $right($gettok(%i,1,95),1), $&
        %msg =  $+ $3 $+  $iif(e isin $1,%curr,euros) are %calc $+  $iif(e isin $1,euros,%curr)) - (Currency from $left($gettok(%i,2,95),1) $+  $+ $right($gettok(%i,2,95),-1) $+ )
      if (s isin $1) && (($active ischan) || ($query($active))) { msg $active %msg } 
      else { _themes.commandEcho euro %msg }
    }
  }
}
alias -l _euro.calculateConversion {
  if ($3 == $null) || ($3 !isnum 0-) || (!$_string.areValidFlags($remove($1,-),els)) { return } 
  var %x = 1, %i 
  while ($_euro.countryData(%x)) { 
    %i = $v1 
    if ($gettok(%i,1,95) == $2) { 
      var %data = %i 
      goto a 
    } 
    inc %x 
  }
  :a 
  if (!%data) { return } 
  var %rate = $gettok(%data,4,95), %calc
  if (e isincs $1) && (l !isincs $1) { %calc = $calc($3 / %rate) }
  elseif (l isincs $1) && (e !isincs $1) { %calc = $calc(%rate * $3) }
  if (%calc != $null) { return $round($v1,$iif($4 isnum 0-,$4,$_euro.round)) }
}
alias -l _euro.round { return $iif($int($_script.getOption(Euro,RoundTo)) isnum 0-,$v1,2) }
alias -l _euro.listCountries {
  var %dname = _euro.converter, %x = 1, %i, %l
  if (!$dialog(%dname)) { return }
  did -r %dname 8 
  while ($_euro.countryData(%x)) {
    %i = $v1 
    did -a %dname 8 ( $+ $gettok(%i,1,95) $+ ) $replace($gettok(%i,2-3,95),_,$chr(32)) ( $+ $gettok(%i,4,95) $+ ) 
    inc %x 
  }
  if ($did(%dname,8).sel) { %l = $v1 }
  else { %l = $iif($_euro.countryData($_script.getOption(Euro,LatSelectedCountry)),$v1,1) } 
  did -c %dname 8 %l
  _euro.loadCountry $_euro.countryData(%l)
}
alias -l _euro.loadCountry {
  var %dname = _euro.converter 
  did -ra %dname 11,13,14,17,19,22
  if ($1) { 
    did -a %dname 11 $gettok($1-,2,95) 
    did -a %dname 13 $gettok($1-,3,95) 
    did -a %dname 14 1 
    did -a %dname 17 $gettok($1-,4,95) 
    did -a %dname 19 $gettok($1-,4,95) 
    did -a %dname 22 1 
  }
}
alias -l _euro.countryData {
  if ($1 isnum 1-13) { goto $1 } 
  return
  :1 | return ATS_Austria_schilling_13.7603
  :2 | return BEF_Belgium_franc_40.3399
  :3 | return DEM_Germany_Mark_1.95583
  :4 | return NLG_The Netherlands_guilder_2.20371
  :5 | return FIM_Finland_markka_5.94573
  :6 | return FRF_France_franc_6.55957 
  :7 | return GRD_Greece_drachma_340.750
  :8 | return IEP_Ireland_pound_0.787564
  :9 | return ITL_Italy_lira_1936.27
  :10 | return LUF_Luxembourg_franc_40.3399
  :11 | return PTE_Portugal_escudo_200.482
  :12 | return ESP_Spain_peseta_166.386
  :13 
  var %nm = $_script.getOption(Euro,CustomName), %init = $_script.getOption(Euro,CustomInitials), %curr = $_script.getOption(Euro,CustomCurrency), $&
    %rate = $_script.getOption(Euro,CustomRate)
  if (%nm != $null) && ($len(%init) == 3) && (%curr) && (%rate isnum 0-) { return $+(%init,_,%nm,_,%curr,_,%rate) }
}




;______________[ httpDownload ]__________________________________________
;
; /_httpDownload.get <URL> <Port> <HandlerAlias> <DestinationPath> <ResumeType>
;
;
; Returners:
;
; SOCKOPEN             <sockname>
; SOCKOPEN_ERR   <sockname> <string>
; SOCKREAD             <sockname> <string>                          
; SOCKREAD_ERR   <sockname> <string>
; SOCKWRITE_ERR <sockname> <string>
; SOCKCLOSE           <sockname>
; SOCKCLOSE_ERR "download not concluded"
;
; Sockmarks:
;
; 1 -   URL
; 2 -   Site
; 3 -   Port
; 4 -   File
; 5 -   Filesize
; 6 -   Resume
;        0 - Don't resume
;        1 - Resume without ask
;        2 - Ask before resume
; 7 -   Download to folder
; 8 -   Handler alias
; 9 -   Localdir + File
; 10 - Download stat
;        0 - Downloading
;        1 - Getting headers
;        2 - Reading first line
; 11 - Resume capacibility
;        0 - Server don't support resume
;        1 - Server support resume
; 12 - Filetype (text / binary)
; 13 - Bytes received
; 14 - Bytes received from headers
;
alias _httpDownload.get {
  if ($5 == $null) || (!$_string.isUrl($1)) { goto error }
  var %url = $remove($1,http://), %site = $gettok($gettok(%url,1,47),1,58), %file = $gettok($1,-1,47), %port = $2, $&
    %alias = $3, %download_to = $replace($iif($right($4,1) == /,$4,$+($4,/)),/,\), %resume = $5, %__ = $chr(9)
  :sock 
  var %sock = HttpDownload^ $+ $rand(1,10000) 
  if ($sock(%sock)) { goto sock }
  if (%url == $null) || (%site == $null) || (%file == $null) { goto error }
  sockopen %sock %site %port
  sockmark %sock $+(,%url,%__,%site,%__,%port,%__,%file,%__,0,%__,%resume,%__,%download_to,%__,%alias,%__,$+(%download_to,%file),%__,2,%__,0,%__,-,%__,0)
  _file.makeDirectory %download_to
  return 1 
  :error 
  if ($show) { _themes.sintaxEcho _httpDownload.get <URL> <Port> <HandlerAlias> <DestinationPath> <ResumeType (0-2)> }
}
alias -l _httpDownload.markedAlias {
  var %alias = $_socket.sockmark($iif($1,$1,$sockname),8)
  return %alias
}
on *:SOCKOPEN:HttpDownload^*:{
  if ($sockerr) { 
    if ($_httpDownload.markedAlias($sockname)) { $v1 SOCKOPEN_ERR $sockname $sock($sockname).wsmsg }
  }
  else {
    var %sw = sockwrite -n $sockname, %remote = $remove($_socket.sockmark(1),$_socket.sockmark(2))
    %sw GET $replace(%remote,$chr(32),$+($chr(37),20)) HTTP/1.1
    %sw HEAD http:// $+ $_socket.sockmark(2) HTTP/1.1
    %sw Accept: *.*, */* 
    %sw User-Agent: $_script.name v $+ $_script.version
    if (($_socket.sockmark(6) == 1) && ($file($_socket.sockmark(9)).size > 0)) || (($_socket.sockmark(6) == 2) && ($file($_socket.sockmark(9)).size > 0) && ($_prompt.yesNo(File already exists. Resume it?))) { 
      %sw Range: bytes= $+ $file($_socket.sockmark(9)).size $+ -
    }
    else {
      .remove -b $_file.fixName($_socket.sockmark(9))
      .write -c $_socket.sockmark(9)
      %sw Range: bytes=0- 
    }
    %sw Host: $_socket.sockmark(2) $+ : $+ $_socket.sockmark(3)
    %sw Referrer: $_socket.sockmark(2)
    %sw Connection: Keep-Alive
    %sw $lf
    if ($_httpDownload.markedAlias($sockname)) { $v1 SOCKOPEN $sockname }
  }
}
on *:SOCKWRITE:HttpDownload^*:{ 
  if ($sockerr) {
    if ($_httpDownload.markedAlias($sockname)) { $v1 SOCKWRITE_ERR $sockname $sock($sockname).wsmsg }
  }
}
on *:SOCKREAD:HttpDownload^*:{
  var %buffer, %alias = $_httpDownload.markedAlias($sockname), %start
  if ($sockerr) { 
    if (%alias) { $v1 SOCKREAD_ERR $sockname $sock($sockname).wsmsg }
  }
  elseif ($_socket.sockmark(10)) {
    sockread %buffer 
    tokenize 32 %buffer
    if ($sockbr == 0) { return }
    if ($_socket.sockmark(10) == 2) {
      if (http/* iswm $1-) {
        if (4?? iswm $2) || (5?? iswm $2) { 
          if ($_httpDownload.markedAlias($sockname)) $v1 SOCKREAD_ERR $sockname $2- 
          return 
        } 
        elseif ($1 == 206) { 
          _sockets.sockmark 11 1 
          %start = 1 
        } 
        else { 
          _socket.sockmark 11 0 
          %start = 1
        }
        _socket.sockmark 10 1
        if (%start) && ($_httpDownload.markedAlias($sockname)) { $v1 SOCKREAD $sockname Starting download }
      }
      elseif ($_httpDownload.markedAlias($sockname)) { $v1 SOCKREAD_ERR $sockname No HTTP/1.1 support }
    }
    elseif (Content-length:* iswm $1-) { _socket.sockmark 5 $2 }
    elseif ($1- == $null) {
      if ($_socket.sockmark(6)) { 
        if ($file($_socket.sockmark(9)).size) && ($_socket.sockmark(11) == 0) { 
          if ($_httpDownload.markedAlias) { $v1 SOCKREAD_ERR No resume supported } 
        }
        elseif ($_httpDownload.markedAlias($sockname)) { $v1 SOCKREAD $sockname Resume started }
        _socket.sockmark 10 0
      }
    }
    elseif ($1 == Content-Type:) { 
      _socket.sockmark 10 0 
      _socket.sockmark 14 $sock($sockname).rcvd 
      _socket.sockmark 12 $iif(text/ isin $1-,text,binary) 
    }
  }
  else {
    if ($_socket.sockmark(12) == text) { 
      sockread %buffer 
      write $_file.fixName($_socket.sockmark(9)) $iif(%buffer != $null,%buffer,$lf) 
      if ($_httpDownload.markedAlias($sockname)) { $v1 SOCKREAD $sockname Downloading $iif(%buffer != $null,%buffer) }
    } 
    else {
      sockread 4096 &buffer 
      if ($sockbr == 0) { return } 
      bwrite $_file.fixName($_socket.sockmark(9)) -1 $bvar(&buffer,0) &buffer 
      if ($_httpDownload.markedAlias($sockname)) { $v1 SOCKREAD $sockname Downloading &buffer }
    }
    _socket.sockmark 13 $calc($sock($sockname).rcvd - $_socket.sockmark(14))
  }
}
on *:SOCKCLOSE:HttpDownload^*:{
  if ($_socket.sockmark(13) isnum 1-) && ($_socket.sockmark(5) isnum 1-) && ($_socket.sockmark(13) >= $_socket.sockmark(5)) { 
    if ($_httpDownload.markedAlias) { $v1 SOCKCLOSE $sockname }
  }
  elseif ($_httpDownload.markedAlias) { $v1 SOCKCLOSE_ERR $sockname Download no concluded }
}



;______________[ portscan ]__________________________________________

alias portscan { _advanced.openDialog _portscan portscan }
dialog _portscan {
  title "Portscan"
  size -1 -1 223 253
  option dbu
  box "", 1, 4 3 214 51
  text "&Host to scan:", 2, 11 15 35 8
  combo 3, 48 13 115 100, edit drop
  radio "&Port(s):", 4, 10 27 27 10
  edit "", 5, 48 26 104 11, autohs
  button "!", 6, 154 27 9 10
  radio "P&ort(s) file:", 7, 10 39 36 10
  edit "", 8, 48 38 104 11, autohs
  button "...", 9, 154 39 9 10
  button "&Start", 20, 171 19 40 11, default
  check "&Halt", 21, 171 31 40 11, push
  box "", 30, 4 56 214 18
  text "STATUS:", 10, 12 63 25 8
  text "Select host and ports to scan...", 31, 41 63 169 8
  box "", 40, 4 76 214 155
  list 41, 10 86 201 80, size extsel
  edit "", 42, 10 167 201 45, read multi hsbar vsbar
  button "&Telnet", 50, 11 213 40 11
  button "Cop&y host", 51, 53 213 40 11
  button "S&ave", 52, 129 213 40 11
  button "Cl&ear", 53, 171 213 40 11

  button "&Close", 100, 178 237 40 11, cancel
  button "&Help", 99, 136 237 40 11
}
on *:DIALOG:_portscan:*:*:{
  if ($devent == INIT) {
    ; _dialogs.mdxHeaders $dname 41 130,60,160 + 0 Host,+ 0 Port,+ 0 Description
    didtok $dname 3 126 $_script.getOption(Portscan,LastHosts)
    if ($_script.getOption(Portscan,ScanFrom) == file) { 
      did -c $dname 7
      did -b $dname 5,6
    }
    else {
      did -c $dname 4 
      did -b $dname 8,9
    }
  }
  elseif ($devent == SCLICK) {
    if ($did == 4) { 
      did -e $dname 5,6
      did -b $dname 8,9
    }
    elseif ($did == 6) { 
      did -ra $dname 5 11,19-21,23,25,43,53,59,79,80,109,110,113,135,137,138,144,512-515,517,543,1027-1029,1032,1080,3333,4000,5000,5580,6660-6670,7000-7005,8000,8080 
    }
    elseif ($did == 7) {
      did -e $dname 8,9
      did -b $dname 5,6
    }
    elseif ($did == 9) { did -ra $dname 8 $$_prompt.selectFile($mircdir*.txt,Portscan - Choose ports file,PortscanPortsFile) }
    elseif ($did == 20) {
      unset $_script.variableName(Portscan,*)
      var %host = $did(3), %win = @_temp.portscan.portsList, %x = 1
      if (!$_string.isHost(%host)) { 
        _portscan.status ERROR: Invalid host to scan.
        return
      }
      set $_script.variableName(Portscan,Host) %host
      if ($did(4).state) {
        if ($did(5) == $null) || ($remove($did(5),$chr(44),-) !isnum) { _portscan.status ERROR: Invalid ports to scan. }
        else {
          _portscan.status Preparing scan...
          set $_script.variableName(Portscan,File) normal
          var %ports = $did(5), %temp
          _window.open -h %win
          while ($gettok(%ports,%x,44)) {
            %temp = $v1
            if (- isin %temp) {
              var %y = 1, %_p = $_string.compressNumberToExtend(%temp,44)
              while ($gettok(%_p,%y,44)) {
                aline %win $v1
                inc %y
              }
            }
            elseif (%temp isnum) { aline %win %temp }
            inc %x
          }
        }
      }
      else {
        if (!$isfile($_file.fixName($did(8)))) { _portscan.status ERROR: Invalid ports file ( $+ $did(8) $+ ) }
        else {
          _portscan.status Preparing scan...
          set $_script.variableName(Portscan,Type) file 
          var %file = $_file.fixName($did(8)), %lines = $lines(%file), %temp
          _window.open -h %win
          while (%x <= %lines) {
            %temp = $read(%file,n,%x)
            if (- isin %temp) {
              var %y = 1, %_p = $_string.compressNumberToExtend(%temp,44)
              while ($gettok(%_p,%y,44)) {
                aline %win $v1
                inc %y
              }
            }
            elseif (%temp isnum) { aline %win %temp }
            inc %x
          }
        }
      }
      if ($window(%win)) {
        did -r $dname 41,42
        did -b $dname 20
        set $_script.variableName(Portscan,Scanning) 1
        _script.setOption Portscan LastHosts $addtok($_script.getOption(Portscan,LastHosts),%host,126)
        .timerPORTSCAN~SCAN -mio 0 50 _portscan.scan %win %host
      }
    }
    elseif ($did == 21) {
      if (!$_script.variableValue(Portscan,Scanning)) { did -u $dname 21 }
      var %win = @_temp.portscan.portsList
      if ($did(21).state) { 
        .timerPORTSCAN~SCAN off
        _portscan.status Scan halted!
      }
      else { 
        if ($window(%win)) && ($_script.variableValue(Portscan,Host) != $null) { .timerPORTSCAN~SCAN -mio 0 50 _portscan.scan %win $v1 }
      }
    }
    elseif ($did == 52) { _dialog.saveBufferTo $dname 42 -f }
    elseif ($did == 53) { did -r $dname 42 }
    elseif ($did == 100) { _portscan.end }
  }
}
alias -l _portscan.scan {
  var %dname = _portscan, %win = $1, %host = $2, %port, %total = $line(%win,0), %curr
  if (!$dialog(%dname)) { _portscan.end }
  else {
    inc $_script.variableName(Portscan,CurrentPort)
    if ($_script.variableValue(Portscan,CurrentPort) == 1) {
      _portscan.writeLog *** Scan started ( $+ $asctime $+ )...
      set $_script.variableName(Portscan,Ticks) $ticks
      set $_script.variableName(Portscan,TotalPorts) $line(%win,0)
    }
    %curr = $_script.variableValue(Portscan,CurrentPort)
    %port = $line(%win,%curr)
    if (%curr > %total) {
      _portscan.end
      return
    }
    _portscan.status Scanning port %port $+ ...
    sockopen $+(PORTSCAN^,%host,^,%port) %host %port
  }
}
alias -l _portscan.end {
  var %dname = _portscan
  window -c @_temp.portscan.portsList
  unset $_script.variableName(Portscan,Scanning)
  .timerPORTSCAN~SCAN off
  if ($dialog(%dname)) {
    if ($_script.variableValue(Portscan,Ticks) isnum) { var %t = $calc(($ticks - $v1) / 1000) }
    var %total = $_script.variableValue(Portscan,TotalPorts)
    _portscan.writeLog *** Finished with a total of $iif(%total isnum,%total,<n/a>) ports in $iif(%t,%t,<n/a>) seconds ( $+ $iif($round($calc(%total / %t),1) isnum,$v1,<n/a>) p\ps)
    _portscan.status Scan completed
    did -e %dname 20
  }
  unset $_script.variableName(Portscan,*)
}
alias -l _portscan.status {
  if ($dialog(_portscan)) { did -ra _portscan 31 $$1- }
}
alias -l _portscan.writeLog {
  var %dname = _portscan
  if ($dialog(%dname)) && ($1 != $null) { 
    if ($did(%dname,42).lines >= 500) { did -d %dname 42 1 }
    did -a %dname 42 $1- $crlf
  }
}
on *:SOCKOPEN:portscan^*^*:{
  var %dname = _portscan
  if (!$dialog(%dname)) { sockclose $sockname }
  else {
    tokenize 94 $sockname
    if ($sockerr) { _portscan.writeLog Host $2 Port $3 - $sock($sockname).wsmsg }
    else { 
      did -a %dname 41 $2 (Port: $3 - Description: $iif($_socket.portDescription($3),$v1,<none>) $+ )
      _portscan.writeLog *** FOUNDED Port $2 > $3
    }
    sockclose $sockname
  }
}



;______________[ notes ]__________________________________________

alias notes { _advanced.openDialog _notes notes }
dialog _notes {
  title "Notes"
  size -1 -1 303 217
  ;;; size -1 -1 303 309
  option dbu

  box "&Titles", 1, 6 4 117 188
  text "&Add note:", 2, 14 16 26 8
  combo 3, 41 15 74 50, size drop
  list 4, 13 27 102 145, size hsbar
  button "&Remove", 5, 32 173 40 11, disable
  button "&Edit title...", 6, 74 173 40 11, disable

  box "&Note: <none>", 10, 129 4 168 188
  edit "", 11, 136 15 153 157, multi autovs vsbar disable limit 900
  text "Limited to 900 characters including spaces", 12, 138 174 105 8, disable
  text "0 used", 13, 263 174 25 8, right disable

  button "&Ok", 100, 173 199 40 11, ok
  button "&Cancel", 99, 215 199 40 11, cancel
  button "&Help", 98, 257 199 40 11

  list 1000, 10 218 287 85, disable hide
}
on *:DIALOG:_notes:*:*:{
  if ($devent == EDIT) && ($did == 11) {
    var %x = 1, %data = ""
    while ($did(11,%x) != $null) {
      %data = %data $v1
      inc %x
    }
    did -ra $dname 13 $len(%data) used
    did -o $dname 1000 $did(4).sel $did(4).seltext $+ " $+ %data
  }
  elseif ($devent == INIT) {
    didtok $dname 3 44 New...,<Separator>
    var %x = 1
    while ($_script.getOption(Notes,$+(NoteTitle,%x)) != $null) {
      var %title = $v1, %data = $_script.getOption(Notes,$+(NoteData,%x))
      did -a $dname 1000 %title $+ " $+ %data
      did -a $dname 4 %title
      inc %x
    }
  }
  elseif ($devent == SCLICK) {
    if ($did == 3) {
      var %type = $did(3).sel, %line = $calc($iif($did(4).sel,$v1,$did(4).lines) + 1), %title = -
      if (%type == 1) { 
        var %title = $_prompt.input(New note title (limited to 50 characters):"~"Notes"htc"NewNoteTitle), %title = $remove($left(%title,50),")
        if (%title == -) { 
          _prompt.info Invalid note title. That symbol (-) represents a separator please choose another title."Notes
          return
        }
        elseif ($didwm(4,%title)) { 
          _prompt.info Invalid note title. Already exists one with that name please choose another."Notes
          return
        }
      }
      did -i $dname 1000 %line %title
      did -izc $dname 4 %line %title $+ 
      _notes.titleSelected
    }
    elseif ($did == 4) { _notes.titleSelected }
    elseif ($did == 5) {
      var %sel = $did(4).sel
      if (%sel != $null) { 
        did -d $dname 4,1000 $did(4).sel 
        %sel = $calc(%sel - 1)
        if (%sel) { did -c $dname 4 %sel }
        elseif ($did(4,1) != $null) { did -c $dname 4 1 }
      }
      _notes.titleSelected
    }
    elseif ($did == 6) {
      var %sel = $did(4).sel, %title = $_prompt.input(New note title (limited to 50 characters):"~"Notes"htc"EditNoteTitle), %title = $remove($left(%title,50),")
      if (%title == -) { 
        _prompt.info Invalid note title. That symbol (-) represents a separator please choose another title."Notes
        return
      }
      elseif ($didwm(4,%title)) { 
        _prompt.info Invalid note title. Already exists one with that name please choose another."Notes
        return
      }
      did -o $dname 4 %sel %title
      did -o $dname 1000 %sel %title $+ " $+ $gettok($did(1000,%sel).text,2-,34) 
    }
    elseif ($did == 100) {
      var %hash = $_hash.prefixed(Notes), %x = 1, %i
      hfree -w %hash NoteData*
      hfree -w %hash NoteTitle*
      while ($did(1000,%x) != $null) {
        %i = $v1
        _script.setOption Notes $+(NoteTitle,%x) $gettok(%i,1,34)
        _script.setOption Notes $+(NoteData,%x) $gettok(%i,2-,34)
        inc %x
      }
    }
  }
}
alias _notes.titleSelected {
  var %d = _notes
  if ($dialog(%d)) {
    did -z %d 4
    var %line = $did(%d,4).sel, %text = $did(%d,4).seltext
    if (%text == -) {
      did -e %d 5 
      did -b %d 6
      did -ra %d 10 &Note: <separator>
      did -rb %d 11
      did -b %d 12
      did -rab %d 13 0 used
    }
    elseif (%text != $null) {
      did -ra %d 10 &Note: %text
      did -e %d 5,6
      did -rae %d 11 $gettok($did(%d,1000,%line),2-,$asc("))
      did -e %d 12
      did -rae %d 13 $len($did(%d,11)) used
    }
    else {
      did -b %d 5,6
      did -ra %d 10 &Note: <none>
      did -rb %d 11
      did -b %d 12
      did -rab %d 13 0 used
    }
  }
}
