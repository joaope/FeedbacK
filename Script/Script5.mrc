;___________[ seen ]____________________________________

alias seendata { seen -d } 
alias seenopt { seen -o }
alias seen {
  var %f = $1
  if (!$_string.areValidFlags(%f,od)) || ($2 != $null) { _themes.sintaxEcho seen [-od] }
  else {
    if (!%f) { %f = d }
    if (o isincs %f) { _advanced.openDialog _seen.options seenopt }
    if (d isincs %f) { _advanced.openDialog _seen.database seendata }
  }
}
dialog _seen.options {
  title "Seen options"
  size -1 -1 265 223
  option dbu

  tab "O&ptions", 100, 4 4 255 193

  box "", 101, 10 21 243 39, tab 100
  check "&Enable seen system except on these networks:", 102, 18 31 140 10, tab 100
  edit "", 103, 26 41 217 11, tab 100 autohs

  box "&Maintainance:", 104, 10 63 243 40, tab 100
  check "O&n connect delete all entries older than (days):", 105, 18 74 125 10, tab 100
  edit "", 106, 175 74 68 11, tab 100 autohs right
  check "On connec&t only keep last (entries):", 107, 18 86 124 10, tab 100
  edit "", 108, 175 86 68 11, tab 100 autohs right

  box "Tri&gger responses:", 109, 10 106 243 85, tab 100
  check "&Enable trigger responses to these users:", 110, 18 118 112 10, tab 100
  combo 111, 175 118 68 100, tab 100 size drop
  text "&Response method:", 112, 19 133 64 8, tab 100
  combo 113, 175 132 68 100, tab 100 size drop
  text "T&rigger word:", 114, 19 159 58 8, tab 100
  edit "", 115, 175 158 68 11, tab 100 autohs
  text "&Warn me when someone uses trigger echoing to:", 116, 19 146 131 8, tab 100
  combo 117, 175 145 68 100, tab 100 size drop
  text "&Seconds to wait before allowing another request:", 118, 19 173 122 8, tab 100
  edit "", 119, 175 171 68 11, tab 100 autohs right

  tab "Re&sponses", 200

  box "", 18, 10 21 243 170, tab 200

  text "&No matching nick stored:", 19, 19 32 88 8, tab 200
  text "No &matching wildcarded request:", 20, 19 54 132 8, tab 200
  text "N&icks matching wildcarded request:", 21, 19 76 132 8, tab 200
  text "&Too much nicks matching wildcarded request:", 22, 19 98 120 8, tab 200
  text "Nic&k is on channel (where trigger has been inputed):", 23, 19 120 154 8, tab 200
  text "Nick is on ot&her channel(s) (common to you):", 24, 19 142 137 8, tab 200
  text "Nick &was last seen:", 25, 19 164 85 8, tab 200

  edit "", 30, 18 40 143 11, tab 200 autohs
  edit "", 31, 18 62 143 11, tab 200 autohs
  edit "", 32, 18 84 143 11, tab 200 autohs
  edit "", 33, 18 106 143 11, tab 200 autohs
  edit "", 34, 18 128 143 11, tab 200 autohs
  edit "", 35, 18 150 143 11, tab 200 autohs
  edit "", 36, 18 172 143 11, tab 200 autohs

  button "&Default", 40, 205 40 40 11, tab 200
  button "&Default", 41, 205 62 40 11, tab 200
  button "&Default", 42, 205 84 40 11, tab 200
  button "&Default", 43, 205 106 40 11, tab 200
  button "&Default", 44, 205 128 40 11, tab 200
  button "&Default", 45, 205 150 40 11, tab 200
  button "&Default", 46, 205 172 40 11, tab 200

  button "&Add tag...", 1, 163 40 40 11, tab 200
  button "&Add tag...", 2, 163 62 40 11, tab 200
  button "&Add tag...", 3, 163 84 40 11, tab 200
  button "&Add tag...", 4, 163 106 40 11, tab 200
  button "&Add tag...", 5, 163 128 40 11, tab 200
  button "&Add tag...", 6, 163 150 40 11, tab 200
  button "&Add tag...", 7, 163 172 40 11, tab 200

  button "&Ok", 1000, 135 205 40 11, ok
  button "&Cancel", 999, 177 205 40 11, cancel
  button "&Help", 998, 219 205 40 11
}
on *:DIALOG:_seen.options:*:*:{
  if ($devent == INIT) {
    if ($_seen.getOption(EnableSeen)) { did -c $dname 102 }
    else { did -b $dname 103 } 
    did -a $dname 103 $_seen.getOption(EnableExceptNetworks)
    if ($_seen.getOption(DeleteEntriesOlderThan)) { did -c $dname 105 }
    else { did -b $dname 106 }
    did -a $dname 106 $_seen.deleteOlderThanDays
    if ($_seen.getOption(KeepOnlyLast)) { did -c $dname 107 }
    else { did -b $dname 108 }
    did -a $dname 108 $_seen.keepOnlyLastEntries
    if ($_seen.getOption(EnableResponses)) { did -c $dname 110 }
    else { did -b $dname 111,112,113,114,115,116,117,118,119 }
    var %x = 1, %strings = All.-.Operators.Voices.Halfops.Regulars.Nofitied, %lastsel = $iif($did(111).sel isnum 1-7 && $v1 != 2,$v1,1)
    did -r $dname 111
    while ($gettok(%strings,%x,46)) {
      var %i = $v1
      if (%i == -) { did -a $dname 111 %i }
      elseif ($_seen.getOption($+(EnableResponsesTo,%i))) { did -a $dname 111 $+($chr(91),X,$chr(93)) %i }
      else { did -a $dname 111 $+($chr(91),$str($chr(160),2),$chr(93)) %i }
      inc %x
    }
    did -c $dname 111 %lastsel
    didtok $dname 113 46 Channel message.Private message.Channel notice.Private notice
    did -c $dname 113 $_seen.responseMethod
    did -a $dname 115 $_seen.triggerWord
    didtok $dname 117 44 <None>,Status,Channel,Active
    did -c $dname 117 $_seen.warnTriggerUseTo
    did -a $dname 119 $_seen.secondsToWaitBeforeRequest
    var %x = 1, %id = 30, %resp
    while (%x <= 7) {
      did -a $dname %id $_seen.response(%x)
      inc %x
      inc %id
    }
    var %t = $_seen.getOption(LastSelectedOptionsTab)
    .timer -mi 1 0 did -c $dname $iif($istok(100 200,%t,32),%t,100)
  }
  elseif ($devent == SCLICK) {
    if ($did isnum 1-7) { _tags.add $dname $calc($did + 29) SEEN_RESPONSE_ $+ $did &Seen response: }
    elseif ($did == 102) { did $iif($did(102).state,-e,-b) $dname 103 }
    elseif ($did == 105) { did $iif($did(105).state,-e,-b) $dname 106 }
    elseif ($did == 107) { did $iif($did(107).state,-e,-b) $dname 108 }
    elseif ($did == 110) { did $iif($did(110).state,-e,-b) $dname 111,112,113,114,115,116,117,118,119 }
    elseif ($did == 111) {
      if ($did(111).seltext) {
        var %text = $v1, %user = $gettok(%text,-1,32), %sel = $did(111).sel
        if (%sel == 2) {
          did -c $dname 111 1 
          return
        }
        if (X isincs %text) { did -o $dname 111 %sel $+($chr(91),$str($chr(160),2),$chr(93)) %user }
        else { did -o $dname 111 %sel $+($chr(91),X,$chr(93)) %user }
        did -c $dname 111 %sel
      }
    }
    elseif ($did isnum 40-46) { did -ra $dname $calc($did - 10) $_seen.defaultResponses($calc($did - 39)) }
    elseif ($did == 1000) {
      var %» = _seen.setOption
      %» EnableSeen $did(102).state
      %» EnableExceptNetworks $did(103)
      %» DeleteOlderThan $did(105).state
      %» DeleteOlderThanDays $did(106)
      %» KeepOnlyLast $did(107).state
      %» KeepOnlyLastEntries $did(108)
      %» EnableResponses $did(110).state
      var %x = 1, %i
      while ($did(111,%x)) {
        %i = $v1
        if (%i != -) { %» $+(EnableResponsesTo,$gettok(%i,-1,32)) $iif(X isincs %i,1,0) }
        inc %x
      }
      %» ResponseMethod $did(113).sel
      %» TriggerWord $did(115)
      %» WarnTriggerUseTo $did(117).sel
      %» SecondsToWaitBeforeRequest $did(119)
      var %x = 1, %id = 30
      while (%x <= 7) {
        %» $+(Response-,%x) $did(%id)
        inc %x
        inc %id
      }
    }
  }
  elseif ($devent == CLOSE) { _seen.setOption LastSelectedOptionsTab $dialog($dname).tab }
}
alias _seen.setOption { _script.setOption Seen $1 $2- }
alias _seen.getOption { return $_script.getOption(Seen,$1) }
alias _seen.deleteOlderThanDays { return $iif($int($_seen.getOption(DeleteOlderThanDays)) isnum 1-,$v1,30) }
alias _seen.keepOnlyLastEntries { return $iif($int($_seen.getOption(KeepOnlyLastEntries)) isnum 1-,$v1,1000) }
alias _seen.responseMethod { return $iif($int($_seen.getOption(ResponseMethod)) isnum 1-4,$v1,1) }
alias _seen.triggerWord { return $gettok($iif($_seen.getOption(TriggerWord) != $null,$v1,!Seen),1,32) }
alias _seen.warnTriggerUseTo { return $iif($int($_seen.getOption(WarnTriggerUseTo)) isnum 1-4,$v1,1) }
alias _seen.secondsToWaitBeforeRequest { return $iif($int($_seen.getOption(SecondsToWaitBeforeRequest)) isnum 1-,$v1,5) }
alias _seen.defaultResponses {
  var %x = $1
  goto %x
  :1 | return No nick matching your request (<REQUEST>)
  :2 | return No nicks matching your request (<REQUEST>)
  :3 | return <TOTAL> nicks matching your request (<NICKS>)
  :4 | return <TOTAL> nicks matching your request but only <DISPLAYED> displayed (<NICKS>)
  :5 | return <REQUEST> is on channel
  :6 | return <REQUEST> is currently on others channels common to me (<COMCHANNELS>)
  :7 | return <REQUEST> was last seen <TIMEAGO> ago (<TIME>) on <LASTCHANNEL> (Event: <EVENT>)
  :%x
}
alias _seen.response {
  var %i = $int($1)
  if (%i isnum 1-7) { return $iif($_seen.getOption($+(Response,%i)) != $null,$v1,$_seen.defaultResponses(%i)) }
}
alias _seen.addNickToTable {
  var %net = $_network.active
  if ($0 < 5) || (%net == $null) || (!$_seen.getOption(EnableSeen)) || ($istok($_seen.getOption(EnableExceptNetworks),%net,32)) { return }
  _script.setOption $+(Seen-,%net) $1-
}
dialog _seen.database {
  title "Seen database"
  size -1 -1 247 264
  ;; size -1 -1 437 264
  option dbu

  list 1, 5 7 90 196, size extsel sort
  button "&Remove", 2, 6 205 40 11, disable
  button "R&emove all...", 3, 54 205 40 11, disable

  box "Information:", 4, 101 99 141 118
  text "Nick:", 5, 108 113 25 8
  text "Address:", 6, 108 128 25 8
  text "Channel:", 7, 108 143 25 8
  text "Event:", 8, 108 158 25 8
  text "Seen time:", 9, 108 173 28 8
  text "Message:", 10, 108 188 25 8
  text "-", 11, 138 113 97 8
  text "-", 12, 138 128 97 8
  text "-", 13, 138 143 97 8
  text "-", 14, 138 158 97 8
  text "-", 15, 138 173 97 8
  text "-", 16, 138 188 97 22

  box "&Filter:", 20, 101 4 141 91
  text "&Network:", 21, 108 17 25 8
  combo 22, 136 16 98 50, size drop
  text "&Nick:", 23, 108 32 25 8
  edit "", 24, 135 30 99 11, autohs
  text "C&hannel:", 25, 108 47 25 8
  edit "", 26, 135 45 99 11, autohs
  text "&Address:", 27, 108 62 25 8
  edit "", 28, 135 60 99 11, autohs

  button "&Scan", 50, 194 77 40 11, disable

  list 1000, 249 7 178 232, size sort hide disable

  box "", 80, 6 220 236 19
  text "STATUS:", 81, 12 227 224 8

  button "&Close", 100, 160 246 40 11, cancel
  button "&Help", 99, 202 246 40 11
}
on *:DIALOG:_seen.database:*:*:{
  if ($devent == INIT) {
    var %tables = $_hash.allMatching(Seen-*), %x = 1, %total = 0, %total_nicks = 0, %networks
    while ($gettok(%tables,%x,32)) {
      var %hash = $v1, %net = $gettok($_hash.notPrefixed(%hash),2-,45)
      if ($hget(%hash,0).item) {
        inc %total_nicks $v1
        inc %total
        %networks = %networks %net
      }
      else { hfree -w %hash }
      inc %x
    }
    if (%total > 1) { var %temp = s }
    if (%total_nicks > 1) { var %_temp = s }
    if (%total) { _seen.databaseStatus %total network $+ %temp to scan with a total of %total_nicks nick $+ %_temp entrie $+ %_temp $+ . Select one to scan... }
    else { _seen.databaseStatus No networks available to scan. }
    didtok $dname 22 32 %networks
  }
  elseif ($devent == SCLICK) {
    if ($did == 22) { did $iif($did(22).seltext != $null,-e,-b) $dname 50 }
    elseif ($did == 50) {
      var %net = $did(22).seltext, %hash = $_hash.prefixed($+(Seen-,%net))
      did -r $dname 1,1000
      did -ra $dname 11,12,13,14,15,16 -
      if (!$hget(%hash,0).item) {
        hfree -w %hash
        _seen.databaseStatus No entries on this network ( $+ %net $+ ). Deleted!
        did -d $dname 22 $did(22).sel
        did -u $dname 22
        did -b $dname 2,3,50
      }
      else {
        var %filter_nick = $iif($did(24) != $null,$v1,*), %filter_channel = $iif($did(26) != $null,$_channel.fixName($v1),*), %filter_address = $iif($did(28) != $null,$v1,*),  %x = 1, %total = 0
        _seen.databaseStatus Scanning %net $+ ...  
        while ($hget(%hash,%x).item != $null) {
          var %nick = $v1, %data = $hget(%hash,%nick)
          tokenize 32 %data
          if (%filter_nick iswm %nick) && (%filter_channel iswm $2) && (%filter_address iswm $1) {
            did -a $dname 1 %nick
            did -a $dname 1000 %nick $1-
            inc %total
          }
          inc %x
        }
        did -e $dname 3
        if (%total) { _seen.databaseStatus %total nick $+ $iif(%total != 1,s) listed from %net network. }
        else { 
          _seen.databaseStatus No nicks founded.
          did -b $dname 2
        }
      }
    }
    elseif ($did == 1) {
      var %nick = $did(1).seltext
      if (%nick != $null) {
        tokenize 32 $did(1000,$did(1).sel)
        if ($0 < 5) { goto noinfo }
        did -ra $dname 11 $1
        did -ra $dname 12 $2
        did -ra $dname 13 $3
        did -ra $dname 14 $4
        did -ra $dname 15 $asctime($5) 
        did -ra $dname 16 $iif($6 != $null,$6-,<No $4 message>) 
        did -e $dname 2
        _seen.databaseStatus %nick $+ 's information listed.
      }
      else {
        :noinfo
        did -b $dname 2
        did -ra $dname 11,12,13,14,15,16 -
        _seen.databaseStatus Select nick to view it's information...
      }
    }
    elseif ($did == 2) {
      var %x = $did(1,0).sel, %total = 0, %net = $did(22).seltext, %hash = $+(Seen-,%net), %sel
      if (%net == $null) { goto end }
      while ($did(1,%x).sel) {
        %sel = $v1
        _script.setOption %hash $did(1,%sel)
        did -d $dname 1,1000 %sel
        dec %x
        inc %total
      }
      :end
      did -ra $dname 11,12,13,14,15,16 -
      did -b $dname 2
      if (!$did(1).lines) { 
        did -b $dname 3,50 
        if (%net != $null) {
          did -d $dname 22 $did(22).sel
          did -u $dname 22
          _seen.databaseStatus All $+(%net,'s) nicks deleted. Network removed from list. 
        }
      }
      else { _seen.databaseStatus %total nick $+ $iif(%total != 1,s) deleted from entries. }
    }
    elseif ($did == 3) {
      var %net = $did(22).seltext, %x = 1, %hash = Seen- $+ %net
      if ($_prompt.yesNo(Do you really want to remove all nick entries from selected network?"Seen)) {
        if (%net != $null) {
          _script.setOption %hash
          _seen.databaseStatus All %net entries deleted. Network removed from list.
          did -d $dname 22 $did(22).sel
        }
        else { _seen.databaseStatus No network available. Please select again... }
        did -r $dname 1,1000
        did -u $dname 22
        did -b $dname 2,3,50
      }
    }
  }
}
alias _seen.databaseStatus {
  var %d = _seen.database, %t = $iif($1 != $null,$1-,Ready!)
  if ($dialog(%d)) { did -ra %d 81 STATUS: %t }
}
; Response
alias _seen.checkIfValidNickToResponse {
  var %chan = $1, %nick = $2
  if ($_seen.getOption(EnableResponsesToAll)) { return 1 }
  elseif ($_seen.getOption(EnableResponsesToOperators)) && (%nick isop %chan) { return 1 }
  elseif ($_seen.getOption(EnableResponsesToVoices)) && (%nick isvo %chan) { return 1 }
  elseif ($_seen.getOption(EnableResponsesToHalfops)) && (%nick ishop %chan) { return 1 }
  elseif ($_seen.getOption(EnableResponsesToRegulars)) && (%nick isreg %chan) { return 1 }
  elseif ($_seen.getOption(EnableResponsesToNotified)) && (%nick isnotify %chan) { return 1 }
}
alias _seen.onTrigger {
  var %chan = $1, %nick = $2, %text = $3-, %net = $_network.active
  if ($_script.variableValue(Seen,AwaitingBeforeAllowRequests,$cid)) || ($_seen.triggerWord * !iswm %text) || (%net == $null) || (!$_seen.getOption(EnableSeen)) || ($istok($_seen.getOption(EnableExceptNetworks),%net,32)) { return }
  if ($_seen.getOption(EnableResponses)) && ($_seen.checkIfValidNickToResponse(%chan,%nick)) {
    var %request = $gettok(%text,2,32), %response = "", %hash = $_hash.prefixed($+(Seen-,%net))
    if (* isin %request) || (? isin %request) || (* isin %request) {
      var %total = $hfind(%hash,%request,0,w)
      if (!%total) {
        %response = $_seen.response(2)
        goto SendResponse
      }
      else {
        var %x = 1, %displayed = 0, %nicks = "", %i
        while ($hfind(%hash,%request,%x,w) != $null) {
          %i = $v1
          if ($len(%nicks) <= 300) {
            inc %displayed
            %nicks = %nicks %i
          }
          inc %x
        }
        if (%displayed < %total) {
          %response = $replacecs($_seen.response(4),<NICKS>,%nicks,<TOTAL>,%total,<DISPLAYED>,%displayed)
          goto SendResponse
        }
        else {
          %response = $replacecs($_seen.response(3),<NICKS>,%nicks,<TOTAL>,%total)
          goto SendResponse
        }
      }
    }
    else {
      if (%request ison %chan) {
        %response = $_seen.response(5)
        goto SendResponse
      }
      elseif ($_channel.common(%request).noSort != $null) {
        var %common = $v1, %response = $replacecs($_seen.response(6),<COMCHANNELS>,%common)
        goto SendResponse
      }
      elseif ($_script.getOption(%hash,%request) != $null) {
        tokenize 32 $v1
        if (*@* !iswm $1) || ($2 == $null) || (!$istok(Join Part Kick,$3,32)) || ($4 !isnum 1-) {
          _script.setOption %hash %request
          goto NotFinded
        }
        %response = $replacecs($_seen.response(7),<TIME>,$asctime($4),<TIMEAGO>,$duration($calc($ctime - $4)),<DATE>,$date($4),<CTIME>,$4, $&
          <EVENT>,$3,<ADDRESS>,$1,<LASTCHANNEL>,$2) 
        goto SendResponse
      }
      else {
        :NotFinded
        %response = $_seen.response(1)
        goto SendResponse
      }
    }
  }
  return
  :SendResponse
  var %met = $_seen.responseMethod, %cmd = $iif(%met isnum 1-2,msg,notice) $iif(%met == 1 || %met == 3,%chan,%nick), %response = $_tags.evaluateDefaults(%response)
  .timer 1 0 %cmd $eval($replacecs(%response,<CHANNEL>,%chan,<NICK>,%nick,<REQUEST>,%request),2)
  set $+(-u,$_seen.secondsToWaitBeforeRequest) $_script.variableName(Seen,AwaitingBeforeAllowRequests,$cid) 1
}

alias _seen.maintainence {
  ; -o  Delete older than N days
  ; -l   Keep only last N entries

  var %net = $_network.active, %hash = $_hash.prefixed($+(Seen-,%net)), %deleted = 0, %total = $hget(%hash,0).item
  if (%net == $null) || (!%total) { return }
  _themes.commandEcho seen Performing maintainence tasks...
  if (o isin $1) {
    var %older = $calc($ctime - ($_seen.deleteOlderThanDays * 86400)), %x = %total, %i
    while (%x) {
      %i = $hget(%hash,%x).item
      tokenize 32 $hget(%hash,%i)
      if ($4 <= %older) { 
        hdel %hash %i  
        inc %deleted 
      }
      dec %x
    }
  }
  if (l isin $1) {


  }
  _themes.commandEcho seen Maintainence finished $iif(%deleted,with a total of %deleted $iif(%deleted != 1,entries,entry) deleted,without entries deleted)
}














































;___________[ cprots ]____________________________________

alias cprot { cprots }
alias cprots { _advanced.openDialog _cprots cprots }
dialog _cprots {
  title "Channel protections"
  size -1 -1 327 233
  ;; size -1 -1 460 233
  option dbu

  text "&Channels:", 1, 56 12 27 8
  combo 2, 84 11 101 50, size drop
  button "&Add...", 3, 188 11 40 11
  button "&Remove", 4, 230 11 40 11

  box "", 5, -17 28 600 150
  list 6, 5 39 71 131, size

  box "", 8, 203 36 1 134
  text "&Penalties:", 9, 211 39 90 8
  combo 10, 211 47 65 150, size drop sort
  list 11, 210 59 66 110, size
  button "A&dd", 12, 281 73 40 11
  button "R&emove", 13, 281 85 40 11
  button "&Up", 14, 281 111 40 11
  button "&Down", 15, 281 123 40 11
  button "&Edit...", 16, 281 149 40 11

  box "", 17, -50 174 600 30
  button "Selec&t all", 18, 6 185 40 11
  button "Unse&lect all", 19, 48 185 40 11
  text "&Presets:", 20, 105 187 22 8
  combo 21, 127 186 47 50, size drop

  tab "_no selection_", 100, -50 -50 600 500
  text "(NO OPTION SELECTED)", 101, 88 100 104 8, disable tab 100 center

  tab "__TEXT FLOOD__", 120
  check "E&nable 'Text Flood' protection", 121, 85 48 98 10, tab 120
  text "Nu&mber of lines:", 122, 86 70 44 8, tab 120
  text "Num&ber of characters:", 123, 86 83 57 8, tab 120
  text "&Seconds:", 124, 86 96 37 8, tab 120
  edit "", 125, 144 68 50 11, tab 120 autohs right
  edit "", 126, 144 81 50 11, tab 120 autohs right
  edit "", 127, 144 94 50 11, tab 120 autohs right

  tab "__NOTICE FLOOD__", 140
  check "E&nable 'Notice Flood' protection", 141, 85 48 98 10, tab 140
  text "Nu&mber of notices:", 142, 86 70 57 8, tab 140
  text "Num&ber of characters:", 143, 86 83 57 8, tab 140
  text "&Seconds:", 144, 86 96 37 8, tab 140
  edit "", 145, 144 68 50 11, tab 140 autohs right
  edit "", 146, 144 81 50 11, tab 140 autohs right
  edit "", 147, 144 94 50 11, tab 140 autohs right

  tab "__CTCP FLOOD__", 160
  check "E&nable 'CTCP Flood' protection", 161, 85 48 98 10, tab 160
  text "Nu&mber of CTCPs:", 162, 86 70 44 8, tab 160
  text "Num&ber of characters:", 163, 86 83 57 8, tab 160
  text "&Seconds:", 164, 86 96 37 8, tab 160
  edit "", 165, 144 68 50 11, tab 160 autohs right
  edit "", 166, 144 81 50 11, tab 160 autohs right
  edit "", 167, 144 94 50 11, tab 160 autohs right
  text "Don't punish this CTCPs:", 168, 86 118 83 8, tab 160
  edit "", 169, 85 126 109 11, tab 160 autohs

  tab "__CAPS FLOOD__", 180
  check "E&nable 'Caps Flood' protection", 181, 85 48 98 10, tab 180
  text "Nu&mber of lines:", 182, 86 70 57 8, tab 180
  text "&Percentage (%) of caps:", 183, 86 83 57 8, tab 180
  text "&Seconds:", 184, 86 96 37 8, tab 180
  edit "", 185, 144 68 50 11, tab 180 autohs right
  edit "", 186, 144 81 50 11, tab 180 autohs right
  edit "", 187, 144 94 50 11, tab 180 autohs right

  tab "__REPEAT FLOOD__", 200
  check "E&nable 'Repeat Flood' protection", 201, 85 48 98 10, tab 200
  text "Nu&mber of lines:", 202, 86 70 44 8, tab 200
  text "&Seconds:", 203, 86 83 57 8, tab 200
  edit "", 204, 144 68 50 11, tab 200 autohs right
  edit "", 205, 144 81 50 11, tab 200 autohs right

  tab "__CONTROL CODES FLOOD__", 220
  check "E&nable 'Control Codes Flood' protection", 221, 85 48 108 10, tab 220
  text "Nu&mber of lines:", 222, 86 70 44 8, tab 220
  text "Num&ber of codes:", 223, 86 83 57 8, tab 220
  text "&Seconds:", 224, 86 96 37 8, tab 220
  edit "", 225, 144 68 50 11, tab 220 autohs right
  edit "", 226, 144 81 50 11, tab 220 autohs right
  edit "", 227, 144 94 50 11, tab 220 autohs right

  tab "__COLORS FLOOD__", 240
  check "E&nable 'Colors Flood' protection", 241, 85 48 108 10, tab 240
  text "Nu&mber of lines:", 242, 86 70 44 8, tab 240
  text "Num&ber of codes:", 243, 86 83 57 8, tab 240
  text "&Seconds:", 244, 86 96 37 8, tab 240
  edit "", 245, 144 68 50 11, tab 240 autohs right
  edit "", 246, 144 81 50 11, tab 240 autohs right
  edit "", 247, 144 94 50 11, tab 240 autohs right

  tab "__JOINS FLOOD__", 280
  check "E&nable 'Joins Flood' protection", 281, 85 48 98 10, tab 280
  text "Nu&mber of joins:", 282, 86 70 44 8, tab 280
  text "&Seconds:", 283, 86 83 57 8, tab 280
  edit "", 284, 144 68 50 11, tab 280 autohs right
  edit "", 285, 144 81 50 11, tab 280 autohs right

  tab "__NICKS FLOOD__", 300
  check "E&nable 'Nicks Flood' protection", 301, 85 48 98 10, tab 300
  text "Nu&mber of nicks:", 302, 86 70 44 8, tab 300
  text "&Seconds:", 303, 86 83 57 8, tab 300
  edit "", 304, 144 68 50 11, tab 300 autohs right
  edit "", 305, 144 81 50 11, tab 300 autohs right

  tab "__CLONES__", 320
  check "E&nable 'Clones' protection", 321, 85 48 108 10, tab 320
  text "Ma&ximum of clones:", 322, 86 70 57 8, tab 320
  edit "", 323, 144 68 50 11, tab 320 autohs right

  tab "__MASS DEOP__", 360
  check "E&nable 'Mass Deop' protection", 361, 85 48 98 10, tab 360
  text "Nu&mber of deops:", 362, 86 70 57 8, tab 360
  text "&Seconds:", 363, 86 83 57 8, tab 360
  edit "", 364, 144 68 50 11, tab 360 autohs right
  edit "", 365, 144 81 50 11, tab 360 autohs right

  tab "__MASS KICK__", 380
  check "E&nable 'Mass Kick' protection", 381, 85 48 98 10, tab 380
  text "Nu&mber of kicks:", 382, 86 70 57 8, tab 380
  text "&Seconds:", 383, 86 83 57 8, tab 380
  edit "", 384, 144 68 50 11, tab 380 autohs right
  edit "", 385, 144 81 50 11, tab 380 autohs right

  tab "__MASS BAN__", 400
  check "E&nable 'Mass Ban' protection (bans)", 401, 85 48 98 10, tab 400
  text "Nu&mber of bans:", 402, 86 70 57 8, tab 400
  text "&Seconds:", 403, 86 83 57 8, tab 400
  edit "", 404, 144 68 50 11, tab 400 autohs right
  edit "", 405, 144 81 50 11, tab 400 autohs right
  check "E&nable 'Mass Ban' protection (users)", 406, 85 110 108 10, tab 400
  text "Nu&mber of users:", 407, 86 132 57 8, tab 400
  text "&Seconds:", 408, 86 145 57 8, tab 400
  edit "", 409, 144 143 50 11, tab 400 autohs right
  edit "", 410, 144 130 50 11, tab 400 autohs right

  tab "__NETHACK__", 420
  check "E&nable 'Nethack' protection", 421, 85 48 98 10, tab 420

  tab "__BAD WORDS__", 440
  check "E&nable 'Bad Words' protection", 441, 85 48 98 10, tab 440
  list 442, 84 59 70 98, tab 440 size sort
  button "&Add...", 443, 158 73 40 11, tab 440
  button "Re&move", 444, 158 85 40 11, tab 440
  button "Ed&it...", 445, 158 111 40 11, tab 440

  tab "__BAD HOSTMAKS__", 460
  check "E&nable 'Bad Hostmasks' protection", 461, 85 48 98 10, tab 460
  list 462, 84 59 70 98, tab 460 size sort
  button "&Add...", 463, 158 73 40 11, tab 460
  button "Re&move", 464, 158 85 40 11, tab 460
  button "Ed&it...", 465, 158 111 40 11, tab 460

  tab "__BAD FILES__", 480
  check "E&nable 'Bad Files' protection", 481, 85 48 98 10, tab 480
  list 482, 84 59 70 98, tab 480 size sort
  button "&Add...", 483, 158 73 40 11, tab 480
  button "Re&move", 484, 158 85 40 11, tab 480
  button "Ed&it...", 485, 158 111 40 11, tab 480

  edit "", 1000, 0 0 0 0, autohs hide disable ;; LAST CHANNEL (NETWORK)
  edit "", 1001, 0 0 0 0, autohs hide disable ;; LAST PROTECTION (-S)
  list 1002, 344 44 106 122, size hide disable ;; PENALTIES INFOS

  button "&Ok", 2000, 197 214 40 11, ok
  button "&Cancel", 1999, 239 214 40 11, cancel
  button "&Help", 1998, 281 214 40 11
}

on *:DIALOG:_cprots:*:*:{
  if ($devent == DCLICK) {
    if ($did == 11) {
      if ($did(1002).seltext) && ($did(16).enabled) { _cprots.editPenalty }
    }
  }
  elseif ($devent == INIT) {
    didtok $dname 21 44 Lenient,Normal,Strict,-,Import...
    didtok $dname 6 44 $_cprots.protectionTypes
    didtok $dname 10 44 $_cprots.penaltyTypes(-s)

    var %x = 1, %str = ""
    hfree -w $_hash.prefixed(TEMP-CProt=*=*)
    while ($hget(%x)) {
      var %hash = $_cprots.isHash($v1)
      tokenize 61 %hash
      if (%hash) { 
        _hash.toHash %hash $+(TEMP-,%hash) 
        %str = $addtok(%str, $gettok($2,1,32) $+($chr(40),$gettok($3,1,32),$chr(41)) ,9)
      }
      inc %x
    }
    var %glob = Global (All), %str = $addtok(%str,%glob,9)
    didtok $dname 2 9 %str
    var %i = $didwm(2,$_script.getOption(CProts,LastSelectedChannel))
    did -c $dname 2 $iif(%i,%i,1)

    var %last = $_script.getOption(CProts,LastSelectedProtection)
    if ($didwm(6,%last)) { did -c $dname 6 $v1 }
    _cprots.selectProtection -t

    did -ra $dname 1000 $_cprots.stringToSave

    _cprots.loadPenalties
    _cprots.loadSettings

    unset $_script.variableName(CProts,Dialog,*)
  }
  elseif ($devent == SCLICK) {
    if ($did == 2) { 
      _cprots.loadPenalties
      _cprots.loadSettings
    }
    elseif ($did == 3) {
      var %c = $$_cprots.addNetworkAndChannel, %str = $gettok(%c,1,32) ( $+ $gettok(%c,2,32) $+ )
      if ($didwm(2,%str)) { did -c $dname 2 $v1 }
      else { did -ac $dname 2 %str }
      _cprots.loadPenalties
      _cprots.loadSettings
      dialog -v $dname
    }
    elseif ($did == 4) {
      if ($did(2).seltext != $null) {
        var %text = $v1
        if (%text != Global (All)) && ($_prompt.yesNo(Do you really want to remove $+(',%text,') settings?"Channel protections)) {
          var %h = CProt= $+ $gettok(%text,1,32) $+ = $+ $left($right($gettok(%text,2,32),-1),-1)
          _script.setOption $+(TEMP-,%h)
          set $_script.variableName(CProts,Dialog,ChannelsToRemove) $addtok($_script.variableValue(CProts,Dialog,ChannelsToRemove),%h,32)
          var %nextsel = $calc($did(2).sel - 1)
          did -d $dname 2 $did(2).sel
          did -c $dname 2 $iif($did(2,%nextsel) != $null,%nextsel,1)
          did -r $dname 1000,1001
          _cprots.loadPenalties
          _cprots.loadSettings
        }
        dialog -v $dname
      }
    }
    elseif ($did == 6) {
      _cprots.selectProtection -t
      _cprots.loadPenalties
    }
    elseif ($did == 10) { did $iif($did(10).seltext,-e,-b) $dname 12 }
    elseif ($did == 11) {
      if ($did(11).sel) { did -c $dname 1002 $v1 }    
      else { did -u $dname 1002 }
      if ($numtok($did(1002).seltext,34) >= 2) { did -e $dname 16 }
      else { did -b $dname 16 }
    }
    elseif ($did == 12) {
      if ($did(10).seltext != $null) {
        var %pen = $v1
        did -a $dname 1002 $_cprots.defaultPenaltyValues(%pen)
        _cprots.orderPenaltiesInList
      }
    }
    elseif ($did == 13) {
      if ($did(11).sel) {
        var %s = $v1
        did -d $dname 11,1002 %s
        %s = $calc(%s - 1)
        if ($did(11,%s) != $null) { did -c $dname 11,1002 %s }
        elseif ($did(11.1) != $null) { did -c $dname 11,1002 }
        else { did -u $dname 11,1002 }
        _cprots.orderPenaltiesInList
      }
    }
    elseif ($did isnum 14-15) {
      var %s = $iif($did == 14,-u,-d)
      _dialog.upDownArrows %s $dname 11 
      _dialog.upDownArrows %s $dname 1002
      _cprots.orderPenaltiesInList
    }
    elseif ($did == 16) {
      if ($did(1002).seltext) { _cprots.editPenalty }
    }
    elseif ($did isnum 18-19) { did $iif($did == 18,-c,-u) $dname 121,141,161,181,201,221,241,281,301,321,361,381,401,406,421,441,461,481 }
    elseif ($istok($_cprots.tabs,$did,44)) || ($did == 100) { _cprots.selectProtection -l }
    elseif ($istok(443.444.445.463.464.465.483.484.485,$did,46)) {
      var %r = $right($did,1), %m = $mid($did,2,1)
      if (%m == 4) { var %list = 442, %temp = Bad word to add:, %_temp = AddBadWordToChannelsList }
      elseif (%m == 6) { var %list = 462, %temp = Bad hostmask to add:, %_temp = AddBadHostmaskToChannelsList }
      else { var %list = 482, %temp = Bad file to add:, %_temp = AddBadFileToChannelsList }
      if (%r == 3) || (%r == 5) {
        var %_sel = $did(%list).sel
        if (%r == 5) && (!%_sel) { return }
        var %inp = $_prompt.input(%temp $+ " $+ $iif(%r == 5,$did(%list).seltext,~) $+ " $+ Channel Protections"tch $+ " $+ %_temp), %inp = $remove(%inp,;)
        if (%r == 5) { did -o $dname %list %_sel %inp }
        else { 
          if ($didwm(%list,%inp)) { _prompt.error Text already on list. Halted"Channel Protections }
          else { did -a $dname %list %inp }
        }
      }
      elseif (%r == 4) && ($did(%list).sel) { did -d $dname %list $v1 }
    }
    elseif ($did == 2000) {
      _cprots.savePenalties
      _cprots.saveSettings

      var %x = 1, %hashs = $_hash.allMatching(TEMP-CProt=*=*), %i
      while ($gettok(%hashs,%x,32) != $null) {
        %i = $v1
        _hash.toHash -o %i $gettok($_hash.notPrefixed(%i),2-,45)
        inc %x
      } 
      var %rem = $_script.variableValue(CProts,Dialog,ChannelsToRemove), %x = 1, %i
      while ($gettok(%rem,%x,32) != $null) {
        %i = $v1
        hfree -w $_hash.prefixed(%i)
        inc %x
      }
    }
  }
  elseif ($devent == CLOSE) {
    _script.setOption CProts LastSelectedProtection $did(6).seltext
    _script.setOption CProts LastSelectedChannel $did(2).seltext
  }
}
alias -l _cprots.protectionTypes {
  var %types = Text Flood,Notice Flood,CTCP Flood,Caps Flood,Repeat Flood,_ $+ $&
    ,Control Codes Flood,Colors Flood,_ $+ $&
    ,Joins Flood,Nicks Flood,_ $+ $&
    ,Clones,_ $+ $&
    ,Mass Deop,Mass Kick,Mass Ban,Nethack,_ $+ $&
    ,Bad Words,Bad Hostmaks,Bad Files
  return $replace(%types,_,$chr(32))
}
alias -l _cprots.selectProtection {
  var %dname = _cprots
  if ($1 == -t) { 
    var %tab = $gettok($_cprots.tabs,$findtok($_cprots.protectionTypes,$did(%dname,6).seltext,1,44),44)
    .timer -mi 1 0 _cprots.selectProtection2 %dname $iif(%tab isnum,%tab,100)
  }
  elseif ($1 == -l) { 
    var %item = $gettok($_cprots.protectionTypes,$findtok($_cprots.tabs,$dialog(%dname).tab,1,44),44)
    if ($didwm(%dname,6,%item)) { did -c %dname 6 $v1 }
    else {
      did -u %dname 6
    }
  }
  did -ra %dname 9 $iif($did(%dname,6).seltext != $null && $v1 != $chr(32),$+(',$v1,') &penalties:,&Penalties:)
}
alias -l _cprots.selectProtection2 {
  did -c $1 $2
  if ($dialog($1).tab == 100) { did -b $1 10,11,12,13,14,15,16 }
  else { did -e $1 10,11,12,13,14,15,16 }
}
alias -l _cprots.penaltyTypes { 
  var %t = Warn (Channel),Warn (Me),Warn (Offender),Kick,Ban,Ban (Temporary),Kick Ban,Deop,Ignore,Channel Modes,Channel Topic,Change Nick,Sound,Flash mIRC,Custom
  if ($1 == $null) { return $remove(%t,$chr(32)) }
  return %t
}
alias -l _cprots.tabs { return 120,140,160,180,200, ,220,240, ,280,300, ,320, ,360,380,400,420, ,440,460,480 }
alias -l _cprots.isHash { 
  var %h = $_hash.notPrefixed($1)
  if (CProt=*=* iswm %h) { return %h } 
}
alias -l _cprots.stringToSave {
  var %d = _cprots, %str = $did(%d,2), %save = CProt= $+ $gettok(%str,1,32) $+ = $+ $left($right($gettok(%str,2,32),-1),-1)
  if ($_cprots.isHash(%save)) { 
    %save = $_hash.prefixed(TEMP- $+ %save)
    if (!$hget(%save)) { hmake %save 5 }
    if ($1 != plusprotection) { return $iif($1 != hash,_script.setOption) %save }
    if ($did(%d,6).seltext != $null) { return _script.setOption %save $v1 }
  }
}
alias -l _cprots.isNum { return $iif($int($2) isnum 1-,$v1,$1) }
alias -l _cprots.loadPenalties {
  _cprots.savePenalties
  var %h = $_cprots.stringToSave(hash), %_h = $remove($did(1001),$chr(32)), %x = 1, %d = _cprots
  did -r %d 11,1002
  if (!%h) || (!%_h) { return }
  %h = $_hash.prefixed(%h)
  while ($hget(%h,$+(%_h,Penalty,%x))) {
    did -a %d 1002 $v1
    inc %x
  }
  _cprots.orderPenaltiesInList
}
alias -l _cprots.savePenalties {
  var %dname = _cprots, %x = 1, %» = $gettok($did(1000),2,32), %_» = $remove($did(1001),$chr(32))
  did -ra %dname 1001 $did(%dname,6).seltext
  if (!%») || (!%_») { return }
  hdel -w %» $+(%_»,Penalty,*)
  var %x = 1
  while ($did(%dname,1002,%x)) {
    _script.setOption %» $+(%_»,Penalty,%x) $v1
    inc %x
  }
}
alias -l _cprots.loadSettings {
  _cprots.saveSettings
  var %h = $_cprots.stringToSave(hash), %d = _cprots
  if (%h == $null) { return }
  %h = $_hash.prefixed(%h)

  did -u %d 121,141,161,181,201,221,241,281,301,321,361,381,401,406,421,441,461,481
  did -r %d 442,462,482

  if ($hget(%h,TextFloodEnabled)) { did -c %d 121 }
  did -ra %d 125 $_cprots.isNum(5,$hget(%h,TextFloodLines))
  did -ra %d 126 $_cprots.isNum(300,$hget(%h,TextFloodCharacters))
  did -ra %d 127 $_cprots.isNum(7,$hget(%h,TextFloodSeconds))

  if ($hget(%h,NoticeFloodEnabled)) { did -c %d 141 }
  did -ra %d 145 $_cprots.isNum(5,$hget(%h,NoticeFloodNotices))
  did -ra %d 146 $_cprots.isNum(400,$hget(%h,NoticeFloodCharacters))
  did -ra %d 147 $_cprots.isNum(7,$hget(%h,NoticeFloodSeconds))

  if ($hget(%h,CTCPFloodEnabled)) { did -c %d 161 }
  did -ra %d 165 $_cprots.isNum(5,$hget(%h,CTCPFloodCtcps))
  did -ra %d 166 $_cprots.isNum(400,$hget(%h,CTCPFloodCharacters))
  did -ra %d 167 $_cprots.isNum(7,$hget(%h,CTCPFloodSeconds))
  did -ra %d 169 $hget(%h,CTCPFloodDontPunishCtcps)

  if ($hget(%h,CapsFloodEnabled)) { did -c %d 181 }
  did -ra %d 185 $_cprots.isNum(5,$hget(%h,CapsFloodLines))
  did -ra %d 186 $_cprots.isNum(80,$hget(%h,CapsFloodPercentage))
  did -ra %d 187 $_cprots.isNum(7,$hget(%h,CapsFloodSeconds))

  if ($hget(%h,RepeatFloodEnabled)) { did -c %d 201 }
  did -ra %d 204 $_cprots.isNum(5,$hget(%h,RepeatFloodLines))
  did -ra %d 205 $_cprots.isNum(7,$hget(%h,RepeatFloodSeconds))

  if ($hget(%h,ControlCodesFloodEnabled)) { did -c %d 221 }
  did -ra %d 225 $_cprots.isNum(3,$hget(%h,ControlCodesFloodLines))
  did -ra %d 226 $_cprots.isNum(40,$hget(%h,ControlCodesFloodCodes))
  did -ra %d 227 $_cprots.isNum(7,$hget(%h,ControlCodesFloodSeconds))

  if ($hget(%h,ColorsFloodEnabled)) { did -c %d 241 }
  did -ra %d 245 $_cprots.isNum(3,$hget(%h,ColorsFloodLines))
  did -ra %d 246 $_cprots.isNum(20,$hget(%h,ColorsFloodCodes))
  did -ra %d 247 $_cprots.isNum(7,$hget(%h,ColorsFloodSeconds))

  if ($hget(%h,JoinsFloodEnabled)) { did -c %d 281 }
  did -ra %d 284 $_cprots.isNum(6,$hget(%h,JoinsFloodJoins))
  did -ra %d 285 $_cprots.isNum(7,$hget(%h,JoinsFloodSeconds))

  if ($hget(%h,NicksFloodEnabled)) { did -c %d 301 }
  did -ra %d 304 $_cprots.isNum(3,$hget(%h,NicksFloodNicks))
  did -ra %d 305 $_cprots.isNum(7,$hget(%h,NicksFloodSeconds))

  if ($hget(%h,ClonesEnabled)) { did -c %d 321 }
  did -ra %d 323 $_cprots.isNum(5,$hget(%h,ClonesMaximumNumber))

  if ($hget(%h,MassDeopEnabled)) { did -c %d 361 }
  did -ra %d 364 $_cprots.isNum(6,$hget(%h,MassDeopDeops))
  did -ra %d 365 $_cprots.isNum(7,$hget(%h,MassDeopSeconds))

  if ($hget(%h,MassKickEnabled)) { did -c %d 381 }
  did -ra %d 384 $_cprots.isNum(4,$hget(%h,MassKickKicks))
  did -ra %d 385 $_cprots.isNum(7,$hget(%h,MassKickSeconds))

  if ($hget(%h,MassBanEnabled)) { did -c %d 401 }
  did -ra %d 404 $_cprots.isNum(3,$hget(%h,MassBanBans))
  did -ra %d 405 $_cprots.isNum(7,$hget(%h,MassBanSeconds))
  if ($hget(%h,MassBanUsersEnabled)) { did -c %d 406 }
  did -ra %d 409 $_cprots.isNum(6,$hget(%h,MassBanBans))
  did -ra %d 410 $_cprots.isNum(7,$hget(%h,MassBanSeconds))

  if ($hget(%h,Nethack)) { did -c %d 421 }

  if ($hget(%h,BadWordsEnabled)) { did -c %d 441 }
  didtok %d 442 59 $hget(%h,BadWordsWords)

  if ($hget(%h,BadHostMasksEnabled)) { did -c %d 461 }
  didtok %d 462 59 $hget(%h,BadHostMasksHosts)

  if ($hget(%h,BadFilesEnabled)) { did -c %d 481 }
  didtok %d 482 59 $hget(%h,BadFilesHosts)
}
alias -l _cprots.saveSettings {
  var %dname = _cprots, %x = 1, %» = $did(1000)
  did -ra %dname 1000 $_cprots.stringToSave
  if (!%») { return }

  %» TextFloodEnabled $did(%dname,121).state
  %» TextFloodLines $did(%dname,125)
  %» TextFloodCharacters $did(%dname,126)
  %» TextFloodSeconds $did(%dname,127)

  %» NoticeFloodEnabled $did(%dname,141).state
  %» NoticeFloodNotices $did(%dname,145)
  %» NoticeFloodCharacters $did(%dname,146)
  %» NoticeFloodSeconds $did(%dname,147)

  %» CTCPFloodEnabled $did(%dname,161).state
  %» CTCPFloodCtcps $did(%dname,165)
  %» CTCPFloodCharacters $did(%dname,166)
  %» CTCPFloodSeconds $did(%dname,167)
  %» CTCPFloodDontPunishCtcps $did(%dname,169)

  %» CapsFloodEnabled $did(%dname,181).state
  %» CapsFloodLines $did(%dname,185)
  %» CapsFloodPercentage $did(%dname,186)
  %» CapsFloodSeconds $did(%dname,187)

  %» RepeatFloodEnabled $did(%dname,201).state
  %» RepeatFloodLines $did(%dname,204)
  %» RepeatFloodSeconds $did(%dname,205)

  %» ControlCodesFloodEnabled $did(%dname,221).state
  %» ControlCodesFloodLines $did(%dname,225)
  %» ControlCodesFloodCodes $did(%dname,226)
  %» ControlCodesFloodSeconds $did(%dname,227)

  %» ColorsFloodEnabled $did(%dname,241).state
  %» ColorsFloodLines $did(%dname,245)
  %» ColorsFloodCodes $did(%dname,246)
  %» ColorsFloodSeconds $did(%dname,247)

  %» JoinsFloodEnabled $did(%dname,281).state
  %» JoinsFloodJoins $did(%dname,284)
  %» JoinsFloodSeconds $did(%dname,285)

  %» NicksFloodEnabled $did(%dname,301).state
  %» NicksFloodNicks $did(%dname.304)
  %» NicksFloodSeconds $did(%dname,305)

  %» ClonesEnabled $did(%dname,321).state
  %» ClonesMaximumNumber $did(%dname,323).state

  %» MassDeopEnabled $did(%dname,361).state
  %» MassDeopDeops $did(%dname.364)
  %» MassDeopSeconds $did(%dname,365)

  %» MassKickEnabled $did(%dname,381).state
  %» MassKickKicks $did(%dname.384)
  %» MassKickSeconds $did(%dname,385)

  %» MassBanEnabled $did(%dname,401).state
  %» MassBanBans $did(%dname.404)
  %» MassBanSeconds $did(%dname,405)
  %» MassBanUsersEnabled $did(%dname,406).state
  %» MassBanUsersUsers $did(%dname,409)
  %» MassBanUsersSeconds $did(%dname,410)

  %» Nethack $did(%dname,421).state

  %» BadWordsEnabled $did(%dname,441).state
  %» BadWordsWords $didtok(%dname,442,59)

  %» BadHostMasksEnabled $did(%dname,461).state
  %» BadHostmasksHosts $didtok(%dname,462,59)

  %» BadFilesEnabled $did(%dname,481).state
  %» BadFilesFiles $didtok(%dname,482,32)
}
alias _cprots.defaultPenaltyValues {

  ;; Format:
  ;; Warn (channel)"<Method>"<WarnOnlyOps>"<Message>
  ;; Warn (me)"<Message>
  ;; Warn (offender)"<Method>"<Message>
  ;; Kick"<Message>
  ;; Ban"<Type>
  ;; Ban (Temporary)"<Type>"<Seconds>
  ;; Kick Ban"<Bantype>"<Message>
  ;; Deop
  ;; Ignore"<Masktype>"<Seconds>"<Flags>
  ;; Channel Modes"<Modes>
  ;; Channel Topic"<Topic>
  ;; Change Nick"<Nick>
  ;; Sound"<File>
  ;; Flash mIRC
  ;; Custom"<Command>

  var %pen = $remove($1-,$chr(32))
  if (%pen) { goto %pen }
  return
  :Warn(channel) | return Warn (channel)"1"0" $+ $_cprots.defaults(WarnChannel)
  :Warn(me) | return Warn (me)" $+ $_cprots.defaults(WarnMe)
  :Warn(offender) | return Warn (offender)"1" $+ $_cprots.defaults(WarnOffender)
  :Kick | return Kick" $+ $_cprots.defaults(Kick)
  :Ban | return Ban"20
  :Ban(Temporary) | return Ban (Temporary)"20"120
  :KickBan | return Kick Ban"20" $+ $_cprots.defaults(KickBan)
  :Deop | return Deop
  :Ignore | return Ignore"20"120"pc
  :ChannelModes | return Channel Modes" $+ $_cprots.defaults(ChannelModes)
  :ChannelTopic | return Channel Topic" $+ $_cprots.defaults(ChannelTopic)
  :ChangeNick | return Change Nick" $+ $_cprots.defaults(ChangeNick)
  :Sound | return Sound"<none>
  :FlashmIRC | return Flash mIRC
  :Custom | return Custom" $+ $_cprots.defaults(CustomCommand)
  :%pen
}
alias _cprots.orderPenaltiesInList {
  var %d = _cprots, %x = 1, %i
  did -r %d 11
  while ($did(%d,1002,%x) != $null) {
    %i = $v1
    did -a %d 11 ( $+ %x $+ ) $gettok(%i,1,34)
    inc %x
  }
  if ($did(1002).sel) { did -c %d 11 $v1 }
}
alias _cprots.editPenalty {
  var %d = _cprots.editPenalty
  if ($dialog(%d)) { return }
  var %s = $dialog(%d,%d,-4)
}
dialog _cprots.editPenalty {
  title "Edit penalty"
  size -1 -1 201 83
  option dbu

  tab "__EMPTY__", 2000, -50 -50 500 500
  text "", 2001, 2 20 197 22, disable tab 2000 center

  box "", 2100, -50 56 500 50
  button "&Ok", 2101, 112 66 40 11, ok
  button "&Cancel", 2102, 154 66 40 11, cancel
  edit "", 2103, 0 0 0 0, autohs disable hide

  tab "__WARN (CHANNEL)__", 1
  text "&Warn method:", 100, 8 13 39 8, tab 1
  combo 101, 47 12 63 50, tab 1 size drop
  check "&Only operators", 102, 114 12 50 10, tab 1
  text "&Message:", 103, 8 26 27 8, tab 1
  edit "", 104, 47 25 146 11, tab 1 autohs
  button "&Add tag...", 105, 151 38 40 11, tab 1

  tab "__WARN (ME)__", 2
  text "&Message:", 200, 8 21 27 8, tab 2
  edit "", 201, 46 20 146 11, tab 2 autohs
  button "&Add tag...", 202, 151 33 40 11, tab 2

  tab "__WARN (OFFENDER)__", 3
  text "&Warn method:", 300, 8 13 39 8, tab 3
  combo 301, 47 12 63 50, tab 3 size drop
  text "&Message:", 302, 8 26 27 8, tab 3
  edit "", 303, 47 25 146 11, tab 3 autohs
  button "&Add tag...", 304, 151 38 40 11, tab 3

  tab "__KICK__", 4
  text "&Message:", 400, 8 21 27 8, tab 4
  edit "", 401, 46 20 146 11, tab 4 autohs
  button "&Add tag...", 402, 151 33 40 11, tab 4

  tab "__BAN__", 5
  text "&Mask type:", 500, 22 26 35 8, tab 5
  combo 501, 59 25 115 100, tab 5 size drop

  tab "__BAN (TEMPORARY)__", 6
  text "&Mask type:", 600, 22 20 35 8, tab 6
  combo 601, 58 19 115 100, tab 6 size drop
  text "&Time:", 602, 22 33 25 8, tab 6
  edit "", 603, 58 32 50 11, tab 6 autohs right
  text "seconds", 604, 110 34 25 8, tab 6

  tab "__KICK BAN__", 7
  text "&Mask type:", 700, 8 14 35 8, tab 7
  combo 701, 44 13 148 100, tab 7 size drop
  text "M&essage:", 702, 8 27 25 8, tab 7
  edit "", 703, 44 26 148 11, tab 7 autohs
  button "&Add tag...", 704, 151 38 40 11, tab 7

  tab "__IGNORE__", 9 
  text "&Ignore", 900, 8 10 19 8, tab 9
  combo 901, 27 9 107 100, tab 9 size drop
  edit "", 902, 135 9 36 11, tab 9 autohs right
  text "seconds", 903, 174 10 23 8, tab 9
  check "&Private", 904, 27 27 40 10, tab 9
  check "C&hannel", 905, 27 39 40 10, tab 9
  check "&Notices", 906, 74 27 40 10, tab 9
  check "C&TCP's", 907, 74 39 40 10, tab 9
  check "In&vites", 908, 121 27 46 10, tab 9
  check "Cont&rol codes", 909, 121 39 46 10, tab 9
  check "&DCC's", 910, 170 27 44 10, tab 9

  tab "__CHANNEL MODES__", 10
  text "&Modes:", 1000, 22 26 35 8, tab 10
  edit "", 1001, 59 25 115 11, tab 10 autohs

  tab "__CHANNEL TOPIC__", 11
  text "&Topic:", 1100, 8 21 27 8, tab 11
  edit "", 1101, 46 20 146 11, tab 11 autohs
  button "&Add tag...", 1102, 151 33 40 11, tab 11

  tab "__CHANGE NICK__", 12
  text "&Nick:", 1200, 8 21 27 8, tab 12
  edit "", 1201, 46 20 146 11, tab 12 autohs
  button "&Add tag...", 1202, 151 33 40 11, tab 12

  tab "__SOUND__", 13
  button "<push to select sound file>", 1301, 16 25 160 11, tab 13
  button "!", 1302, 177 25 8 11, tab 13
  edit "", 1303, 0 0 0 0, tab 13 autohs disable hide

  tab "__CUSTOM__", 15
  text "&Command:", 1500, 8 21 27 8, tab 15
  edit "", 1501, 46 20 146 11, tab 15 autohs
  button "&Add tag...", 1502, 151 33 40 11, tab 15
}
on *:DIALOG:_cprots.editPenalty:*:*:{
  if ($devent == INIT) {
    did -f $dname 2101
    did -ra $dname 2103 2000
    did -ra $dname 2001 (NOT EDITABLE PENALTY) $+ $crlf $crlf $+ (Closing dialog)
    var %d = _cprots, %id = 1002
    if (!$dialog(%d)) { goto close }
    var %data = $did(%d,%id).seltext, %penalty = $gettok(%data,1,34), %types = $_cprots.penaltyTypes(1), $&
      %tab = $iif($findtok(%types,%penalty,1,44) isnum 1- $+ $numtok(%types,44), $v1, 2000)
    if (%tab == 2000) || (%tab == 8) || (%tab == 14) {
      :close
      .timer -i 1 1 dialog -c $dname
      return
    }
    did -ra $dname 2103 %tab
    dialog -t $dname Channel protections - $+(',%penalty,') penalty
    .timer -mi 1 0 did -c $dname %tab
    tokenize 34 %data
    goto %tab
    :1
    didtok $dname 101 44 Message,Action,Notice
    did -c $dname 101 $iif($int($2) isnum 1-3,$v1,1)
    if ($3) { did -c $dname 102 }
    did -a $dname 104 $4-
    return
    :2
    did -a $dname 201 $2-
    return
    :3
    didtok $dname 301 44 Message,Action,Notice
    did -c $dname 301 $iif($int($2) isnum 1-3,$v1,1)
    did -a $dname 303 $3-
    return
    :4
    did -a $dname 401 $2-
    return
    :5
    _dialog.listMasks $dname 501
    did -c $dname 501 $iif($int($2) isnum 0-19,$calc($v1 + 1),21)
    return
    :6
    _dialog.listMasks $dname 601
    did -c $dname 601 $iif($int($2) isnum 0-19,$calc($v1 + 1),21)
    did -a $dname 603 $iif($int($3) isnum 1-,$v1,120)
    return
    :7
    _dialog.listMasks $dname 701
    did -c $dname 701 $iif($int($2) isnum 0-19,$calc($v1 + 1),21)
    did -a $dname 703 $3-
    return
    :9
    _dialog.listMasks $dname 901
    did -c $dname 901 $iif($int($2) isnum 0-19,$calc($v1 + 1),21)
    did -a $dname 902 $iif($int($3) isnum 1-,$v1,120)
    var %f = $4, %d = did -c $dname
    if (p isincs %f) { %d 904 }
    if (c isincs %f) { %d 905 }
    if (n isincs %f) { %d 906 }
    if (t isincs %f) { %d 907 }
    if (i isincs %f) { %d 908 }
    if (k isincs %f) { %d 909 }
    if (d isincs %f) { %d 910 }
    return
    :10
    did -a $dname 1001 $2-
    return
    :11
    did -a $dname 1101 $2-
    return
    :12
    did -a $dname 1201 $2
    return
    :13
    if ($_file.isFile($2-)) {
      var %f = $v1
      did -a $dname 1301 $_dialog.shorterFilename(50,%f)
      did -a $dname 1303 $remove(%f,")
    }
    :15
    did -a $dname 1501 $2-
    :%tab
  }
  elseif ($devent == SCLICK) {
    if ($did isnum 1-15) || ($did == 2000) { .timer -mi 1 0 did -c $dname $did(2103) }
    elseif ($did == 1301) {
      var %f = $_prompt.selectFile($mircdir*.wav,Channel protections - Select sound,CProtsAddSoundPenalty)
      if (!%f) {
        did -ra $dname 1301 <push to select sound file>
        did -r $dname 1303
      }
      else {
        did -ra $dname 1301 $_dialog.shorterFilename(50,%f)
        did -ra $dname 1303 %f
      }
    }
    elseif ($did == 1302) {
      if ($_file.isFile($did(1303))) { splay $v1 }
    }
    elseif ($istok(105.202.304.402.704.1102.1202.1502,$did,46)) { _tags.add $dname $calc($did - 1) CPROTS_PENALTIES &Penalties: }
    elseif ($did == 2101) {
      var %d = _cprots, %id = 1002
      if (!$dialog(%d)) { return }
      var %sel = $did(%d,%id).sel 
      if (!%sel) { return }
      else {
        var %tab = $dialog($dname).tab, %end
        goto %tab
        :1 | %end = Warn (channel)" $+ $iif($did(101).sel isnum 1-3,$v1,1) $+ " $+ $did(102).state $+ " $iif($did(104) != $null,$v1,$_cprots.defaults(WarnChannel)) | goto end
        :2 | %end = Warn (me)" $+ $iif($did(201) != $null,$v1,$_cprots.defaults(WarnMe)) | goto end
        :3 | %end = Warn (offender)" $+ $iif($did($dname,301).sel isnum 1-3,$v1,1) $+ " $+ $iif($did(303) != $null,$v1,$_cprots.defaults(WarnOffender)) | goto end
        :4 | %end = Kick" $+ $iif($did(401) != $null,$v1,$_cprots.defaults(Kick)) | goto end
        :5 | %end = Ban" $+ $iif($did(501).sel isnum 1-20,$calc($v1 - 1),20) | goto end
        :6 | %end = Ban (Temporary)" $+ $iif($did(601).sel isnum 1-20,$calc($v1 - 1),20) $+ " $+ $iif($int($did(603)) isnum 1-,$v1,120) | goto end
        :7 | %end = Kick Ban" $+ $iif($did(701).sel isnum 1-20,$calc($v1 - 1),20) $+ " $+ $iif($did(703) != $null,$v1,$_cprots.defaults(KickBan))
        :9 | %end = Ignore" $+ $iif($did(901).sel isnum 1-20,$calc($v1 - 1),20) $+ " $+ $iif($int($did(902)) isnum 1-,$v1,120) $+ "
        var %f = ""
        if ($did(904).state) { %f = p }
        if ($did(905).state) { %f = %f $+ c }
        if ($did(906).state) { %f = %f $+ n }
        if ($did(907).state) { %f = %f $+ t }
        if ($did(908).state) { %f = %f $+ i }
        if ($did(909).state) { %f = %f $+ k }
        if ($did(910).state) { %f = %f $+ d }
        %end = %end $+ %f
        goto end
        :10 | %end = Channel Modes" $+ $iif($did(1001) != $null,$v1,$_cprots.defaults(ChannelModes)) | goto end
        :11 | %end = Channel Topic" $+ $iif($did(1101) != $null,$v1,$_cprots.defaults(ChannelTopic)) | goto end
        :12 | %end = Change Nick" $+ $iif($did(1201) != $null,$v1,$_cprots.defaults(ChangeNick)) | goto end
        :13 | %end = Sound" $+ $did(1303) | goto end
        :15 | %end = Custom" $+ $iif($did(1501) != $null,$v1,$_cprots.defaults(CustomCommand))
        :end | did -o %d %id %sel %end | did -c %d 11, $+ %id %sel
        :%tab
      }
    }
  }
}
alias _cprots.defaults {
  var %g = $1, %r = return
  if (%g) { goto %g }
  return
  :WarnChannel | %r <NICK> has triggered a penalty for the <PENALTY>st time. (Reason: <OFFENCE>)
  :WarnMe | %r <NICK> has triggered a penalty for the <PENALTY>st time on <CHANNEL> (Reason: <OFFENCE>)
  :WarnOffender | %r You've triggered a penalty for the <PENALTY>st time on <CHANNEL> (Reason: <OFFENCE>)
  :Kick | %r <OFFENCE> triggered by you.
  :KickBan | %r <OFFENCE> triggered by you. Out!
  :ChannelModes | %r +i
  :ChannelTopic | %r Everyone shooting <NICK> right to his head.
  :ChangeNick | %r <ME>_
  :CustomCommand | %r /beep
}
dialog _cprots.addNetworkAndChannel {
  title "Add to Channel Protections"
  size -1 -1 147 70
  option dbu
  box "", 1, 3 3 141 44
  text "C&hannel:", 2, 11 15 25 8
  combo 3, 42 13 95 100, sort size edit drop
  text "&Network:", 4, 11 30 25 8
  combo 5, 42 29 95 100, sort size edit drop
  button "&Add", 100, 62 54 40 11, disable ok
  button "&Cancel", 99, 104 54 40 11, cancel
}
on *:DIALOG:_cprots.addNetworkAndChannel:*:*:{
  if ($devent == INIT) {
    if ($_network.getAll) { filter -wo $v1 $dname 5 }
    if ($didwm(5,$_network.active)) { did -c $dname 5 $v1 }
    did -a $dname 3 (Global)
    var %x = 1 
    while ($chan(%x) != $null) { 
      did -a $dname 3 $v1 
      inc %x 
    }
  }
  elseif ($devent == SCLICK) && ($did == 100) { 
    set -u2 $_script.variableName(CProts,AddNetworkAndChannel) $iif($gettok($did(3),1,32) != $null && $v1 != (Global),$_channel.fixName($v1),Global) $gettok($did(5),1,32)
  }
  elseif ($devent == EDIT) || ($devent == SCLICK) { 
    if ($did(5) != $null) && ($did(3) != $null) { did -e $dname 100 }
    else { did -b $dname 100 }
  }
}
alias _cprots.addNetworkAndChannel {
  __dummy $dialog(_cprots.addNetworkAndChannel,_cprots.addNetworkAndChannel,-3)
  var %temp = $_script.variableValue(CProts,AddNetworkAndChannel)
  if ($numtok(%temp,32) == 2) { return %temp }
}
