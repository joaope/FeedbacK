;___________[ awaylog ]___________________________________

; NOT COMPLETED

alias awaylog { _advanced.openDialog _awaylog awaylog }
dialog _awaylog {
  title "Awaylog viewer"
  size -1 -1 272 255
  option dbu

  list 1, 6 4 260 208, size
  button "&Flush...", 2, 183 213 40 11
  button "&List", 3, 225 213 40 11
  box "", 4, -9 228 300 50
  button "&Close", 5, 225 238 40 11, cancel

  list 999, 0 0 0 0, sort hide disable

  menu "&Events", 1000
  item "&All", 100
  item break, 200
  item "&Disconnects", 101
  item "&Notifies / Unotifies", 102
  item break, 201
  item "&DCC Sends (Fails)", 103
  item "D&CC Gets (Fails)", 104
  item break, 202
  item "&Channel messages", 105
  item break, 203
  item "&Kicks", 106
  item "&Bans / Unbans", 107
  item break, 204
  item "Se&rver Ops", 108
  item "&Ops / Deops", 109
  item "O&wners / Deowners", 110
  item "&Helps / Dehelps", 111
  item break, 205
  item "&Private messages", 112
}
on *:DIALOG:_awaylog:*:*:{
  if ($devent == INIT) {




  }
}

alias _awaylog.saveEvent {
  if (!$away) && (!$1) { return }
  var %event = $1, %save = _script.setOption $_awaylog.hashName $ctime $1 $+($chr(91),$_network.active,$chr(93))
  goto %event

  :DISCONNECT | :FILESENT | :SENDFAIL | :FILERCVD | :GETFAIL | :NOTIFY | :UNOTIFY
  if (!$_goptions.get(AwayLogMiscEvents)) { return }
  goto $+(%event,_2)
  :DISCONNECT_2 | %save You disconnected from $+($server,:,$port) with nickname $nick | goto end
  :FILESENT_2 | %save Sent $filename to $nick successful | goto end
  :SENDFAIL_2 | %save Failed to send $filename to $nick | goto end
  :FILERCVD_2 | %save Received $filename from $nick | goto end
  :GETFAIL_2 | %save Failed to get $filename from $nick | goto end
  :NOTIFY_2 | %save  Notified nick $nick is on IRC $_string.surrounded($notify($nick).note) | goto end
  :UNOTIFY_2 | %save Notified nick $nick left IRC $_string.surrounded($notify($nick).note) | goto end

  :CHANTEXT | :KICK | :BAN | :UNBAN | :SERVEROP | :OP | :DEOP | :OWNER | :DEOWNER | :HELP | :DEHELP
  var %w = $_awaylog.logChannelsWhen
  if (%w == 1) { return }
  elseif (%w == 3) && (($me !isop) && ($me !isvoice) && ($me !ishop)) { return }
  elseif (%w == 2) && ( (!$istok($nick $opnick $vnick $hnick $knick ,$me,32)) && (!$highlight($1-))) { return }
  goto $+(%event,_2)
  :CHANTEXT_2 | %save Message from $nick on $chan $+ : $strip($2-) | goto end
  :KICK_2 
  if ($knick == $me) { %save You're kicked from $chan by $nick $_string.surrounded($2-) }
  elseif ($nick == $me) { %save You kicked $nick from $chan $_string.surrounded($2-) }
  else { %save $nick was kicked from $chan $_string.surrounded($2-) }
  goto end
  :BAN_2 | :UNBAN_2
  var %bnicks = $_channel.nicksMatchingAddress($chan,$banmask)
  if (%w == 2) && (!$istok(%bnicks,$me,32)) { return }
  %save $nick $iif(%event == ban,banned,unbanned) $banmask from $chan $_string.surrounded(%bnicks) 
  goto end
  :SERVEROP_2 | :DEOP_2 | :OP_2 | :OWNER_2 | :DEOWNER_2
  var %temp = $iif(DE* iswm %event,deopped,opped)
  if ($opnick == $me) { %save You've been %temp by $nick on $chan }
  elseif ($nick == $me) { %save You've %temp $opnick on $chan }
  else { %save $opnick was been %temp by $nick on $chan }
  goto end
  :HELP_2 | :DEHELP_2
  var %temp = $iif(%event == help,halfopped,dehalfopped)
  if ($hnick == $me) { %save You've been %temp by $nick on $chan }
  elseif ($nick == $me) { %save You've %temp $hnick on $chan }
  else { %save $hnick was been %temp on $chan }
  goto end

  :PRIVATETEXT | :CHAT
  var %w = $_awaylog.logPrivateMessageWhen
  if (%w == 1) { return }
  %save $nick message to $iif(%event == chat,chat:,query:) $2-
  var %c = .close $iif(%event == chat,-m,-c) $nick
  if (%w == 2) { goto end }
  elseif (%w == 3) { %c }
  elseif (%w == 4) { .timer $+ $+(AWAYLOG^CLOSE^WINDOW^,%event,^$cid,^,$nick) 1 15 %c }

  :end
  ;; Something goes here!
}
alias _awaylog.cancelCloseTimer { .timer $+ $+(AWAYLOG^CLOSE^WINDOW^,$1,^,$cid,^,$2) off } 
alias _awaylog.hashName { return $_hash.prefixed(AwayLogEvents) }
alias _awaylog.getOption { return $_script.getOption(Awaylog,$1) }
alias _awaylog.setOption { _script.setOption Awaylog $1- }
alias _awaylog.logChannelsWhen { return $iif($int($_goptions.get(AwayLogChannelsWhen)) isnum 1-4,$v1,1) }
alias _awaylog.logPrivateMessageWhen { return $iif($int($_goptions.get(AwayLogPrivateMessagesWhen)) isnum 1-4,$v1,1) }








;____________[ pager ]____________________________________

alias pagers { 
  var %d = _pagers.viewer, %param = $1, %flags = $_string.removeNumbers(%param), %num = $int($right(%param,-2))
  if (%param != $null) {
    if (!$_string.areValidFlags(%flags,v)) || (%num !isnum) { 
      _themes.sintaxEcho pagers [-vN] 
      return
    }
    if (%num !isnum 0-) { 
      _themes.commandEcho pagers Specify a number higher or equal to zero (where zero selects last pager)
      return
    }
  }
  if (%num) { set $_script.variableName(Pagers,SelectOnInit) %num }
  _advanced.openDialog %d pagers
}
dialog _pagers.viewer {
  title "Pagers viewer"
  size -1 -1 235 113
  option dbu

  box "&Pager 0 of 0", 1, 4 3 227 87
  text "&From:", 2, 11 15 18 8
  edit "", 3, 30 14 81 11, read autohs
  text "&Network:", 4, 118 15 25 8
  edit "", 5, 143 14 81 11, read autohs
  text "&When:", 6, 11 28 18 8
  edit "", 7, 30 27 194 11, read autohs
  edit "", 8, 30 40 194 43, read multi vsbar

  button "< &Previous", 9, 5 96 40 11, disable
  button "&Next >", 10, 47 96 40 11, disable

  button "&Options...", 100, 107 96 40 11
  button "&Close", 99, 149 96 40 11, ok
  button "&Help", 98, 191 96 40 11

  list 1000, 0 0 0 0, hide disable sort
}
on *:DIALOG:_pagers.viewer:*:*:{
  if ($devent == INIT) {
    _pagers.list
    _pagers.select $iif($_script.variableName(Pagers,SelectOnInit) isnum 0-,$v1,0)
  }
  elseif ($devent == SCLICK) {
    if ($did == 9) { _pagers.select -p }
    elseif ($did == 10) { _pagers.select -n }
    elseif ($did == 100) { goptions -i - Pager }
  }
}
alias _pagers.list {
  var %d = _pagers.viewer, %x = 1, %hash = $_hash.prefixed(Pagers)
  if (!$dialog(%d)) { return }
  did -r %d 1000
  while ($hget(%hash,%x).item != $null) {
    did -a %d 1000 $v1 $hget(%hash,$v1)
    inc %x
  }
}
alias _pagers.selected { 
  var %d = _pagers.viewer
  if ($dialog(%d)) { return $gettok($did(%d,1),2,32) }
  return 0
}
alias _pagers.total { 
  var %d = _pagers.viewer
  if ($dialog(%d)) { return $did(%d,1000).lines }
  return 0
}
alias _pagers.select {
  var %d = _pagers.viewer, %total = $_pagers.total, %select, %sel = $_pagers.selected
  if (!$dialog(%d)) { return }
  if ($1 isnum 0-) { %select = $int($1) }
  elseif ($1 == -n) { %select = $calc(%sel + 1) }
  elseif ($1 == -p) { %select = $calc(%sel - 1) }
  else { %select = 1 }
  if (%select == 0) { %select = %total }
  if (!%total) {
    did -ra %d 1 No pagers
    did -b %d 9,10
  }
  else {
    if (%select > %total) { %select = 1 }
    elseif (%select < 0) { %select = %total }
    tokenize 32 $did(%d,1000,%select)
    did -ra %d 1 Pager %select of %total
    did -ra %d 3 $iif($2 != $null,$2,<not available>)
    did -ra %d 5 $iif($3 != $null,$3,<not available >)
    did -ra %d 7 $iif($1 isnum,$asctime($1),<not available>)
    did -ra %d 8 $iif($4 != $null,$4-,<not available>)
    did -e %d 9,10
  }
}
alias _pager.received {
  var %when = $iif($int($_goptions.get(EnablePagerWhen)) isnum 1-3,$v1,1)
  if ($2 != PAGE) || ($3 == $null) || ((%when == 1) && (!$away)) || ((%when == 2) && ($away)) { return }
  _script.setOption Pagers $ctime $1 $_network.active $3-
  if ($away) { inc $_script.variableName(Pagers,ReceivedWhileAway,$cid) }
  var %d = _pagers.viewer
  if ($_goptions.get(WarnPagerReceived)) {
    var %warn = $iif($int($_goptions.get(WarnPagerReceivedWhen)) isnum 1-4,$v1,1), $&
      %msg = Pager received from $1 ( $+ $iif($len($3-) <= 30,$3-,$+($left($3-,30),...)) $+ ). $iif(!$dialog(%d),Use /pagers to view it.)
    if (%warn == 1) { .timer 1 0 _prompt.info $+(%msg,"Pagers) }
    else {
      var %f = $iif(%warn == 2 || (%warn == 4),s) $+ $iif(%warn isnum 3-4,a), %f = $+(-,%f)
      _themes.infoEcho %f Pagers: %msg
    }
  }
  if ($dialog(%d)) { 
    _pagers.list
    _pagers.select 0
  }
}
alias _pagers.onAway {
  if ($_goptions.get(DeletePagersOnAway)) { _script.setOption Pagers }
}
alias _pager.onBack {
  if ($_goptions.get(ShowPagersOnBack)) && ($_script.variableName(Pager,ReceivedWhileAway,$cid) isnum 1-) { pagers }
  unset $_script.variableName(Pagers,ReceivedWhileAway,$cid)
}


;____________[ away ]____________________________________

alias _away.announceMessages {
  if ($1 == Away) { 
    return $iif($prop != default && $_goptions.get(AnnounceAwayMessage) != $null,$v1,is away: <REASON> (Log: <LOG> \ Pagers: <PAGER>))
  }
  elseif ($1 == Back) { return $iif($prop != default && $_goptions.get(AnnounceBackMessage) != $null,$v1,is back from away after <DURATION>) }
}
alias _away.setQuietVariable { set $_script.variableName(Away,Quiet,$cid) 1 }
alias _away.unsetQuietVariable { unset $_script.variableName(Away,Quiet,$cid) }
alias _away.isQuiet { return $_script.variableValue(Away,Quiet,$cid) }
alias _away.announceChannelsUsing { return $_away.numberToMessageCommand($iif($int($_goptions.get(AnnounceAwayBackChannelsUsing)) isnum 1-3,$v1,1)) }
alias _away.announceQueriesUsing { return $_away.numberToMessageCommand($iif($int($_goptions.get(AnnounceAwayBackQueriesUsing)) isnum 1-3,$v1,1)) }
alias _away.announceChatsUsing { return $_away.numberToMessageCommand($iif($int($_goptions.get(AnnounceAwayBackChatsUsing)) isnum 1-3,$v1,1)) }
alias _away.numberToMessageCommand {
  var %n = $int($1)
  return $iif(%n == 2,msg,$iif(%n == 3,notice,describe))
}
alias _away.evaluatedAnnounceMessage {
  var %msg = $_tags.evaluateDefaults($_away.announceMessages($1)), %ctime = $calc($ctime - $awaytime), $&
    %log = $iif($_away.logChannelsWhen > 1 || $_away.logPrivateMessageWhen > 1,On,Off), %pager = $iif($_goptions.get(EnablePager),On,Off)
  return $eval($replacecs(%msg, $&
    <REASON>,$awaymsg, $&
    <CTIME>,%ctime, $&
    <SINCE>,$asctime(%ctime), $&
    <TIME>,$awaytime, $&
    <DURATION>,$duration($awaytime), $&
    <LOG>,%log, $&
    <PAGER>,%pager),2)
}
alias away {
  if (!$server) { return }
  var %quiet = 0
  if ($away) && ($1 != $null) {
    %quiet = 1
    .raw AWAY : $+ $1- 
  }
  elseif (!$away) {
    %quiet = $iif($show,0,1)
    .raw AWAY : $+ $iif($1- != $null,$v1,$_prompt.input(Away reason:"~"Away"-tch"AwayReason))
  }
  else {
    %quiet = $iif($show,0,1)
    .raw AWAY
  }
  $iif(%quiet,_away.setQuietVariable,_away.unsetQuietVariable)
}
alias back {
  if ($away) { $iif($show,away,away) }
}
alias _away.autoAwayTimer {
  var %timer = AWAY~AUTOCHECK~ $+ $cid
  if (!$server) || (!$_goptions.get(ActivateAutoAway)) || ($away) { .timer $+ %timer off }
  else {
    var %countdiag = _away.autoAwayCountDown- $+ $cid
    if (!$timer(%timer)) { .timer $+ %timer 0 30 _away.autoAwayTimer }
    if ($dialog(%countdiag)) { return }
    var %min = $iif($int($_goptions.get(ActivateAutoAwayAfter)) isnum 1-,$v1,15)
    if ($calc($idle / 60) >= %min) { _away.setAutoAway %min }
  }
}
alias _away.setAutoAway {
  var %min = $1, %cmd = $iif($_goptions.get(QuitAwayOnAutoAway),.away,away) automatic away after %min minute $+ $iif(%min != 1,s) of idle time
  if ($_goptions.get(WarnBeforeAutoAway)) { _away.autoAwayCountDown %cmd }
  else { %cmd }
}
alias _away.autoAwayCountDown {
  var %d = _away.autoawayCountDown, %dn = $+(%d,-,$cid)
  if ($dialog(%d)) { return }
  else { 
    set -u1 $_script.variableName(Away,AutoCountDownCommand) $1-
    dialog -mn %dn %d
  } 
}
dialog _away.autoAwayCountDown {
  title "Away - Automatic"
  size -1 -1 126 50
  option dbu
  text "Setting automatic away in:", 1, 9 13 66 8
  text "15 seconds", 2, 81 13 34 8, right    ;seconds
  box "", 3, 3 3 119 26
  button "&Set", 100, 39 34 40 11, ok
  button "&Cancel", 99, 81 34 40 11, cancel
  edit "", 1000, 0 0 0 0, autohs disable hide
  edit "14", 999, 0 0 0 0, autohs hide disable
}
on *:DIALOG:_away.autoAwayCountDown-*:*:*:{
  if ($devent == INIT) {
    did -a $dname 1000 $_script.variableValue(Away,AutoCountDownCommand)
    .timerAWAY~AUTOCOUNTDOWN~ $+ $cid 15 1 _away.autoAwayCountDownTimer $dname
  }
  elseif ($devent == SCLICK) {
    if ($did == 100) { $iif($did(1000) != $null,$v1) }
  }
}
alias _away.autoAwayCountDownTimer {
  var %d = $1, %timer = AWAY~AUTOCOUNTDOWN~ $+ $cid
  if (!$dialog(%d)) { .timer $+ %timer off }
  else {
    var %left = $iif($did(%d,999) isnum 0-,$v1,15)
    did -ra %d 2 %left seconds
    if (%left == 0) {
      .timer $+ %timer off
      if ($did(%d,1000) != $null) { $v1 }
      dialog -x %d
    }
    else {
      dec %left
      did -ra %d 999 %left
    }
  }
}
alias _away.unAwayEvent {
  if ($_goptions.get(AnnounceAwayBack)) && (!$_away.isQuiet) { _away.performAnnounces Back }
  var %nick = $_script.variableValue(Away,OriginalNick,$cid)
  if (%nick != $null) && (%nick != $me) { nick %nick }
  unset $_script.variableName(Away,OriginalNick,$cid)
  .timer 1 1 _away.autoAwayTimer
  _pager.onBack
  umodes -d
}
alias _away.nowAwayEvent {
  if ($_goptions.get(AnnounceAwayBack)) && (!$_away.isQuiet) { _away.performAnnounces Away }
  if ($_goptions.get(DeopOnAway)) && ($chan(0)) {
    var %x = 1, %i
    while ($chan(%x) != $null) {
      %i = $v1
      if ($me isop %i) && (!$istok($_goptions.get(DeopOnAwayExcept),%i,32)) { mode %i -o $me }
      inc %x
    }
  }
  if ($_goptions.get(CloseOpenQueriesOnAway)) { close -m }
  if ($_goptions.get(ChangeNickOnAway)) {
    var %nick = $_tags.evaluateDefaults($iif($_goptions.get(ChangeNickOnAwayTo) != $null,$v1,<ME>_))
    set $_script.variableName(Away,OriginalNick,$cid) $me
    nick %nick
  }
  unset $_script.variableName(Away,Quiet,$cid)
  _away.reminderTimer
  _pagers.onAway
  umodes -d
}
alias _away.isAnnounceException {
  if ($prop == idle) {
    var %minutes = $calc($nick($1,$me).idle / 60)
    if ($_goptions.get(AnnounceAwayBackExceptIdle)) && (%minutes > $iif($int($_goptions.get(AnnounceAwayBackExceptIdleHigher)) isnum 1-,$v1,5)) { return 1 }
  }
  elseif ($_goptions.get(AnnounceAwayBackExcept)) && ($istok($_goptions.get(AnnounceAwayBackExceptTo),$1,32)) { return 1 }
}
alias _away.performAnnounces { 
  var %msg = $_away.evaluatedAnnounceMessage($1), %i, %flags = $2
  ; Channels
  if ($_goptions.get(AnnounceAwayBackChannels) || c isin %flags) && ($chan(0)) {
    var %x = 1, %cmd = $_away.announceChannelsUsing
    while ($chan(%x) != $null) {
      %i = $v1
      if (!$_away.isAnnounceException(%i)) && (!$_away.isAnnounceException(%i).idle) { %cmd %i %msg }
      inc %x
    }
  }
  ; Queries
  if ($_goptions.get(AnnounceAwayBackQueries) || q isin %flags) && ($query(0)) {
    var %x = 1, %cmd = $_away.announceQueriesUsing
    while ($query(%x) != $null) {
      %i = $v1
      if (!$_away.isAnnounceException(%i)) { %cmd %i %msg }
      inc %x
    }
  }
  ; Chats
  if ($_goptions.get(AnnounceAwayBackChats) || h isin %flags) && ($chat(0)) {
    var %x = 1, %cmd = $_away.announceChatsUsing
    while ($chat(%x) != $null) {
      if (!$_away.isAnnounceException(%i)) { %cmd %i %msg }
      inc %x
    }
  }
}
alias _away.reminderHandler {
  if (!$away) || (($_goptions.get(RemindAwayExcept)) && ($istok($_goptions.get(RemindAwayExceptThis),$2,32))) { return }
  var %remind = 0, %nick = $3, %text = $4-
  goto $1

  :OnChannelText
  if ($_goptions.get(RemindAwayOnChannelHighlight)) && ($highlight(%text)) { %remind = 1 }
  elseif ($_goptions.get(RemindAwayOnWords)) {
    var %x = 1, %words = $_goptions.get(RemindAwayOnThisWords)
    while ($gettok(%words,%x,32) != $null) {
      %i = $v1
      if ($istok(%text,%i,32)) {
        %remind = 1
        break
      }
      inc %x
    }
  }
  if (%remind) { .notice %nick $_away.evaluatedAnnounceMessage(Away) }
  return

  :OnPrivateMessage
  if ($_goptions.get(RemindAwayOnPrivateMessage)) { %remind = 1 }

  :end
  if (%remind) { .notice %nick $_away.evaluatedAnnounceMessage(Away) }
}
alias _away.reminderTimer {
  var %timer = AWAY~REMINDER~ $+ $cid
  if (!$away) || (!$_goptions.get(RemindAway)) { .timer $+ %timer off }
  else {
    var %every = $calc($iif($int($_goptions.get(RemindAwayEvery)) isnum 1-,$v1,30) * 60), %to = $iif($int($_goptions.get(RemindAwayTo)) isnum 1-3,$v1,1), $&
      %flags = $iif(%to == 1,-c,$iif(%to == 2,-qh,-cqh))
    if (!$timer(%timer)) || ($timer(%timer).delay != %every) || ($gettok($timer(%timer).com,3,23) != %flags)  { .timer $+ %timer 0 %every _away.performAnnounces Away %flags }
  }
}


;___________[ images ]____________________________________

alias bars { images }
alias images { _advanced.openDialog _images images }
alias backgrounds { images }
dialog _images {
  title "Images"
  size -1 -1 276 189
  option dbu
  box "&Backgrounds:", 1, 4 5 268 65
  box "B&ars:", 2, 4 75 268 53
  check "&Status", 10, 11 17 37 10
  check "&Channels", 11, 11 29 37 10
  check "&Queries", 12, 11 41 37 10
  check "&Main", 13, 11 53 37 10
  check "&Toolbar", 14, 11 87 37 10
  check "B&uttons", 15, 11 99 37 10
  check "S&witchbar", 16, 11 111 37 10
  edit "", 20, 48 16 123 11, autohs
  edit "", 21, 48 28 123 11, autohs
  edit "", 22, 48 40 123 11, autohs
  edit "", 23, 48 52 123 11, autohs
  edit "", 24, 48 86 123 11, autohs
  edit "", 25, 48 98 123 11, autohs
  edit "", 26, 48 110 123 11, autohs
  button "...", 30, 173 16 9 11
  button "...", 31, 173 28 9 11
  button "...", 32, 173 40 9 11
  button "...", 33, 173 52 9 11
  button "...", 34, 173 86 9 11
  button "...", 35, 173 98 9 11
  button "...", 36, 173 110 9 11
  button "&Theme default", 40, 225 16 40 11
  button "T&heme default", 41, 225 28 40 11
  button "Th&eme default", 42, 225 40 40 11
  button "The&me default", 43, 225 52 40 11
  button "Theme &default", 44, 225 86 40 11
  button "Theme de&fault", 45, 225 98 40 11
  button "Theme defau&lt", 46, 225 110 40 11
  combo 50, 184 16 38 100, size drop
  combo 51, 184 28 38 100, size drop
  combo 52, 184 40 38 100, size drop
  combo 53, 184 52 38 100, size drop
  button "&Ok", 1000, 147 171 40 11, ok
  button "&Cancel", 999, 189 171 40 11, cancel
  button "&Help", 998, 231 171 40 11
  button "...e&nabled", 500, 11 145 40 11
  button "...disable&d", 501, 53 145 40 11
  button "...to defaul&t", 502, 95 145 40 11
  box "&All..", 3, 4 133 268 30
}
on *:DIALOG:_images:*:*:{
  if ($devent == INIT) {
    didtok $dname 50,51,52,53 46 $_images.styles
    _images.startDialog
  }
  elseif ($devent == SCLICK) {
    if ($did isnum 10-16) { _images.dialogEnables $did }
    elseif ($did isnum 30-36) { _images.selectImage $calc($did -10) }
    elseif ($did isnum 40-46) { _images.setDefault $gettok($_images.types,$calc($did - 39),46) }
    elseif ($did isnum 500-501) {
      var %id = 10, %f = $iif($did == 500,-c,-u)
      while (%id <= 16) {
        did %f $dname %id
        _images.dialogEnables %id
        inc %id
      }
    }
    elseif ($did == 502) {
      var %types = $_images.types, %x = 1
      while ($gettok(%types,%x,46)) {
        _images.setDefault $v1
        inc %x
      }
    }
    elseif ($did == 998) { helpd -t images }
    elseif ($did == 1000) {
      var %x = 1 
      while (%x <= 7) {
        var %type = $gettok($_images.types,%x,46)
        _script.setOption Images %type $did($calc(%x + 9)).state
        if (%x isnum 1-4) { _script.setOption Images $+(%type,File) $iif($did($calc(%x + 49)).seltext != $null,$v1,none) $did($calc(%x + 19)) }
        else { _script.setOption Images $+(%type,File) none $did($calc(%x + 19)) }
        inc %x
      }
      _images.loadImages
    }
  }
}
alias _images.styles {
  var %styles = Center.Fill.Normal.Stretch.Tile.Photo, %chr = $iif($1 isnum,$1,46)
  return $replace(%styles,$chr(46),$chr(%chr))
}
alias _images.types {
  var %types = Status.Chan.Query.mIRC.Toolbar.Buttons.Switchbar, %chr = $iif($1 isnum,$1,46)
  return $replace(%types,$chr(46),$chr(%chr))
}
alias _images.startDialog {
  var %x = 1, %types = $_images.types, %dname = _images 
  while ($gettok(%types,%x,46)) {
    var %type = $v1, %state = $_script.getOption(Images,%type), %file = $_script.getOption(Images,$+(%type,File))
    if (%state) { 
      did -c %dname $calc(%x + 9) 
      _images.dialogEnables $calc(%x + 9) 
    }
    else {
      did -u %dname $calc(%x + 9)
      did -b %dname $calc(%x +19) $+ , $+ $calc(%x + 29) $+ , $+ $calc(%x + 39) $+ , $+ $iif(%x isnum 1-4,$calc(%x + 49)) 
    }
    tokenize 32 %file
    did -ra %dname $calc(%x + 19) $remove($2-,")
    if (%x isnum 1-4) { 
      if ($istok($_images.styles,$1,46)) { did -c %dname $calc(%x + 49) $didwm(%dname,$calc(%x + 49),$1) }
      else { did -c %dname $calc(%x + 49) 3 }
    }
    inc %x
  }
}
alias -l _images.dialogEnables {
  var %did = $1, %dname = _images, %d
  if (%did isnum 10-13) { %d = $calc(%did + 10) $+ , $+ $calc(%did + 20) $+ , $+ $calc(%did + 30) $+ , $+ $calc(%did + 40) }
  else { %d = $calc(%did + 10) $+ , $+ $calc(%did + 20) $+ , $+ $calc(%did + 30) }
  did $iif($did(%dname,%did).state,-e,-b) %dname %d 
}
alias -l _images.setDefault {
  var %types = $_images.types, %dname = _images
  if ($findtok(%types,$1,46)) {
    var %x = $v1, %type = $gettok(%types,%x,46), %txt = $_themes.getText($+(Image,%type)), %edit = $calc(%x + 19), %combo = $calc(%x + 49)
    tokenize 32 %txt 
    var %file = $nofile($_themes.currentLoaded) $+ $iif($2,$2-,$1-), %file = $_file.fixName(%file) 
    if ($2) {
      if (%x isnum 1-4) { 
        if ($istok($_images.styles,$1,46)) { did -c %dname %combo $didwm(%dname,%combo,$1) }
        else { did -c %dname %combo 3 }
      }
      if ($_file.isFile(%file)) { did -ra %dname %edit $remove($v1,") }
    }
    elseif ($1) && ($_file.isFile(%file)) { did -ra %dname %edit $remove($v1,") }
    else { did -r %dname %edit }
  }
}
alias -l _images.selectImage {
  var %d = $_prompt.selectFile(*.bmp,Images - Select file,ImagesAddImage), %ext = $right(%d,3) 
  if ($isfile(%d)) { 
    if ($istok(jpg.png.bmp,%ext,46)) { did -ra images $1 %d }
    else { _prompt.error Invalid file extension. Only *.jpg *.png and *.bmp allowed."Images }
  }
}
alias -l _images.flag { return $gettok(c.f.n.r.t.p,$findtok($_images.styles,$1,46),46) }
alias _images.loadImages {
  if ($_script.getOption(Images,Status)) {
    var %all = $_script.getOption(Images,StatusFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = -s $+ $_images.flag($gettok(%all,1,32))
    if ($isfile(%file)) { background %sw %file }
  }
  else { background -sx } 
  if ($_script.getOption(Images,Chan)) {
    var %all = $_script.getOption(Images,ChanFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = - $+ $_images.flag($gettok(%all,1,32)), %x = 1, %y = 1
    if ($isfile(%file)) {
      while ($scon(%y)) {
        scon %y
        while ($chan(%x)) {
          background %sw $v1 %file
          inc %x 
        }
        inc %y
      }
    }
  }
  else { 
    var %x = 1, %y = 1
    while ($scon(%y)) {
      scon %y
      while ($chan(%x)) { 
        background -x $v1 
        inc %x 
      } 
      inc %y
    }
  }
  if ($_script.getOption(Images,Query)) {
    var %all = $_script.getOption(Images,QueryFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = -e $+ $_images.flag($gettok(%all,1,32)), %x = 1, %y = 1
    if ($isfile(%file)) {
      while ($scon(%y)) {
        scon %y
        while ($query(%x)) { 
          background %sw $v1 %file 
          inc %x 
        }
        inc %y
      }
    }
  }
  else { 
    var %x = 1, %y = 1
    while ($scon(%y)) {
      while ($query(%x)) { 
        background -xe $v1 
        inc %x
      } 
      inc %y
    }
  }
  if ($_script.getOption(Images,Mirc)) {
    var %all = $_script.getOption(Images,MircFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = -m $+ $_images.flag($gettok(%all,1,32))
    if ($isfile(%file)) { background %sw %file }
  }
  else { background -mx }
  if ($_script.getOption(Images,Toolbar)) {
    var %all = $_script.getOption(Images,ToolbarFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = -l $+ $_images.flag($gettok(%all,1,32))
    if ($isfile(%file)) { background %sw %file }
  }
  else { background -lx }
  if ($_script.getOption(Images,Buttons)) {
    var %all = $_script.getOption(Images,ButtonsFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = -u $+ $_images.flag($gettok(%all,1,32))
    if ($isfile(%file)) { background %sw %file }
  }
  else { background -ux }
  if ($_script.getOption(Images,Switchbar)) {
    var %all = $_script.getOption(Images,SwitchbarFile), %file = $_file.fixName($gettok(%all,2-,32)), %sw = -h $+ $_images.flag($gettok(%all,1,32))
    if ($isfile(%file)) { background %sw %file }
  }
  else { background -hx }
}


;___________[ Nicklist ]___________________________________________

alias nicklist { _advanced.openDialog _nicklist nlist }
alias nlist { nicklist }
dialog _nicklist {
  title "Nicklist colors"
  size -1 -1 134 167
  option dbu

  check "&Enable nicklist coloring", 2, 13 13 72 10
  check "O&perators", 3, 13 30 37 10
  check "&Voices", 4, 13 42 37 10
  check "&Regular", 5, 13 54 37 10
  check "&Me", 6, 13 66 37 10
  check "O&wners", 7, 13 78 37 10
  check "Hal&fops", 8, 13 90 37 10
  check "&Notified", 9, 13 102 37 10
  check "I&gnored", 10, 13 114 37 10
  check "&IRCop", 11, 13 126 37 10
  icon 12, 57 31 8 8
  icon 13, 57 43 8 8
  icon 14, 57 55 8 8
  icon 15, 57 67 8 8
  icon 16, 57 79 8 8
  icon 17, 57 91 8 8
  icon 18, 57 103 8 8
  icon 19, 57 115 8 8
  icon 20, 57 127 8 8

  button "&Default colors", 21, 81 87 40 11
  button "&All checks on", 22, 81 111 40 11
  button "A&ll checks off", 23, 81 124 40 11

  box "", 24, 5 4 124 138

  button "&Ok", 100, 5 149 40 11, ok
  button "&Cancel", 99, 47 149 40 11, cancel
  button "&Help", 98, 89 149 40 11
}
on *:DIALOG:_nicklist:*:*:{
  if ($devent == INIT) {
    _color.buildBmpFiles
    if ($_script.getOption(Nicklist,Enabled)) { did -c $dname 2 }
    else { did -b $dname 3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 }
    _nicklist.startDialog
    _nicklist.currentsToVar
  }
  elseif ($devent == SCLICK) {
    if ($did == 2) { did $iif($did(2).state,-e,-b) $dname 3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23 }
    elseif ($did isnum 12-20) {
      tokenize 32 $did($did)
      var %did = $did, %c = $gettok($remove($gettok($2-,-1,92),.bmp),1,95), %x = $calc($did - 11), %m = $gettok($_nicklist.types,%x,46), %scol = $_prompt.selectColor(%c)
      _script.setOption Nicklist %m %scol 
      if (%scol isnum 0-) { did -g $dname %did $_color.bmpFile(%scol) }
      else { did -g $dname %did $_color.bmpFile(-1) }
    }
    elseif ($did == 21) { _nicklist.setDefaults }
    elseif ($did isnum 22-23) { did $iif($did == 22,-c,-u) $dname 3,4,5,6,7,8,9,10,11 }
    elseif ($did == 100) { 
      unset $_script.variableName(Nicklist,*)
      _script.setOption Nicklist Enabled $did(2).state 
      var %x = 1, %types = $_nicklist.types, %check = 3
      while (%x <= 9) { 
        _script.setOption Nicklist $+($gettok(%types,%x,46),State) $did(%check).state 
        inc %x 
        inc %check
      }
      _nicklist.allChannels
    }
    elseif ($did == 99) {
      if ($_script.variableValue(Nicklist,CurrentColors)) { 
        var %cols = $v1, %i = 1, %types = $_nicklist.types 
        while (%i <= 9) { 
          _script.setOption Nicklist $gettok(%types,%i,46) $gettok(%cols,%i,46) 
          inc %i 
        } 
      }
      unset $_script.variableName(Nicklist,*)
    }
  }
}
alias _nicklist.startDialog {
  var %x = 1, %dname = _nicklist, %check = 3, %icon = 12, %type, %types = $_nicklist.types
  while (%x <= 9) {
    %type = $gettok(%types,%x,46)
    if ($_script.getOption(Nicklist,%type $+ State)) { did -c %dname %check }
    if ($_script.getOption(Nicklist,%type) isnum 0-) { did -g %dname %icon $_color.bmpFile($v1) } 
    else { did -g %dname %icon $_color.bmpFile(-1) }
    inc %x
    inc %check
    inc %icon
  }
}
alias _nicklist.types {
  var %types = Op.Voice.Regular.Me.Owner.Hop.Friend.Enemy.IRCop, %chr = $iif($1 isnum,$1,46)
  return $replace(%types,$chr(46),$chr(%chr))
}
alias _nicklist.setDefaults {
  var %x = 1, %types = $_nicklist.types, %i
  while ($gettok(%types,%x,46)) {
    %i = $v1
    if ($_themes.getText($+(Cline, %i)) isnum 0-) { _script.setOption Nicklist %i $v1 }
    else { _script.setOption Nicklist %i $color(Listbox text) }
    inc %x
  }
  _nicklist.startDialog
}
alias -l _nicklist.currentsToVar {
  unset $_script.variableName(Nicklist,CurrentColors)
  var %x = 1 
  while (%x <= 9) { 
    var %m = $gettok($_nicklist.types,%x,46), %col = $iif($_script.getOption(Nicklist,%m) isnum 0-,$v1,-1) 
    set $_script.variableName(Nicklist,CurrentColors) $instok($_script.variableValue(Nicklist,CurrentColors),%col,%x,46) 
    inc %x
  }
}
;  Nicklist coloring routines (ClineAway *missing* on mTS)
alias -l _nicklist.nickColor {
  var %nick = $2, %chan = $1, %def = $color(Listbox text), %ret, %address = $3
  if (%chan ischan) {
    if (!$_script.getOption(Nicklist,Enabled)) { return %def }
    if (%nick == $me) { %ret = $iif($_script.getOption(Nicklist,MeState) && $_script.getOption(Nicklist,Me) isnum,$v1) }
    elseif ($_userlist.isLevel(%address)) { %ret = $_userlist.userInfo($3).nickcol }
    elseif ($istok($ial(%nick).mark,IRCop,32)) { %ret = $iif($_script.getOption(Nicklist,IrcopState) && $_script.getOption(Nicklist,Ircop) isnum,$v1) }
    elseif (%nick isignore) { %ret = $iif($_script.getOption(Nicklist,EnemyState) && $_script.getOption(Nicklist,Enemy) isnum,$v1) }
    elseif (%nick isnotify) { %ret = $iif($_script.getOption(Nicklist,FriendState) && $_script.getOption(Nicklist,Friend) isnum,$v1) }
    elseif (%nick ishop %chan) { %ret = $iif($_script.getOption(Nicklist,HopState) && $_script.getOption(Nicklist,Hop) isnum,$v1) }
    elseif (%nick isowner %chan) { %ret = $iif($_script.getOption(Nicklist,OwnerState) && $_script.getOption(Nicklist,Owner) isnum,$v1) }
    elseif (%nick isop %chan) { %ret = $iif($_script.getOption(Nicklist,OpState) && $_script.getOption(Nicklist,Op) isnum,$v1) }
    elseif (%nick isvoice %chan) { %ret = $iif($_script.getOption(Nicklist,VoiceState) && $_script.getOption(Nicklist,Voice) isnum,$v1) }
    else { %ret = $iif($_script.getOption(Nicklist,RegularState) && $_script.getOption(Nicklist,Regular) isnum,$v1) }

    if (%ret isnum 0-) { return $_color.toMircColor(%ret) }
    return %def
  }
}
alias _nicklist.allChannels { 
  var %x = 1, %y = 1, %z = 1, %chan
  if (!$_script.getOption(Nicklist,Enabled)) { return }
  while ($scon(%y)) {
    scon %y
    %z = 1
    while ($chan(%z) != $null) {
      _nicklist.channel $v1
      inc %z
    }
    inc %y
  }
}
alias _nicklist.channel {
  var %chan = $1, %x = 1
  if (%chan !ischan) { return }
  while ($nick(%chan,%x) != $null) {
    _nicklist.nick %chan $v1 $address($v1,5) 
    inc %x
  }
}
alias _nicklist.nick {  
  if ($1 ischan) && ($2 ison $1) { cline $_nicklist.nickColor($1,$2,$3) $1 $nick($1,$2) }
}



;____________[ sounds ]_____________________________________

alias sounds { _sounds.handle }
dialog _sounds {
  title "Event sounds"
  size -1 -1 246 173
  option dbu
  list 2, 10 43 53 98, sort size
  box "Setting up: <none>", 3, 4 32 237 117
  radio "D&on't play sound file", 4, 73 46 63 10
  radio "&Play theme default sound file", 5, 73 75 85 10
  button "<non&e>", 6, 81 87 141 11, disable
  button "!", 7, 223 87 9 11
  radio "Choo&se custom sound file", 8, 73 106 74 10
  button "<clic&k to set>", 9, 81 118 141 11
  button "!", 10, 223 118 9 11
  radio "&Beep", 11, 73 60 50 10
  edit "", 50, 7 31 0 0, hide
  box "", 12, 4 4 237 24
  check "&Enable event sounds", 97, 10 13 66 10
  button "&Default to all", 98, 193 12 40 11
  button "&Cancel", 99, 159 156 40 11, cancel
  button "&Ok", 100, 117 156 40 11, ok
  button "&Help", 101, 201 156 40 11
}
on *:DIALOG:_sounds:*:*:{
  if ($devent == INIT) {
    _hash.toHash -o Sounds TEMP-Sounds
    _sounds.dialogEnables 
    didtok $dname 2 44 $_sounds.types
    if ($_script.getOption(TEMP-Sounds,Enabled)) { did -c $dname 97 }
    else { 
      did -b $dname 2,3,4,5,6,7,8,9,10,11
      did -b $dname 98 
    } 
  }
  elseif ($devent == SCLICK) {
    if ($did == 2) {
      if ($did(2).seltext) {
        var %type = $v1
        did -ra $dname 3 Setting up: %type
        _sounds.saveSound
        _sounds.dialogEnables 
        did -ra $dname 50 %type 
        _sounds.fillSet $_script.getOption(TEMP-Sounds,$+(Snd,%type)) 
      }
    }
    elseif ($istok(4.5.8.11,$did,46)) { _sounds.dialogEnables }
    elseif ($did == 6) {
      if ($did(2).seltext) { 
        var %s = $+(Snd,$v1) 
        if ($_themes.getText(%s)) { did -ra $dname 6 $v1 }
        else { did -ra $dname 6 <non&e> }
      }    
    }
    elseif ($did == 7) { 
      var %f = $nofile($_themes.currentLoaded) $+ $did(6), %f = $_file.fixName(%f)
      if ($isfile(%f)) && ($_file.isSound(%f)) { .splay %f }
    }
    elseif ($did == 9) { 
      var %f = $_file.fixName($_prompt.selectFile($wavedir*.wav,Sounds - Select file,SoundsAddCustomSound))
      if ($_file.isSound(%f)) && ($isfile(%f)) { did -ra $dname 9 $remove(%f,") }
    }
    elseif ($did == 10) { 
      var %f = $_file.fixName($did(9)) 
      if ($isfile(%f)) && ($_file.isSound(%f)) { .splay %f }
    }
    elseif ($did == 97) { 
      if ($did(97).state) { 
        did -e $dname 2,3,4,5,7,8,9,10,11
        did -e $dname 98 
      } 
      else { 
        did -b $dname 2,3,4,5,7,8,9,10,11
        did -b $dname 98 
      } 
    }
    elseif ($did == 98) { _sounds.setDefaults }
    elseif ($did == 100) { 
      _sounds.saveSound
      _script.setOption TEMP-Sounds Enabled $did(97).state
      _hash.toHash -o TEMP-Sounds Sounds      
    }
    elseif ($did == 101) { helpd -t sounds }
  }
}
alias _sounds.handle {
  if ($1 == $null) { _advanced.openDialog _sounds sounds }
  else {
    if ($insong) || ($inwave) || ($inmidi) || (!$_script.getOption(Sounds,Enabled)) { return } 
    if ($istok($_sounds.types,$1,44)) { 
      tokenize 32 $_script.getOption(Sounds,$+(Snd,$1))
      var %f
      if ($1 == default) { %f = $nofile($_themes.currentLoaded) $+ $2- } 
      elseif ($1 == custom) { %f = $2- }
      elseif ($1 == beep) {
        beep
        return
      }
      %f = $_file.fixName(%f)
      if ($isfile(%f)) && ($_file.isSound(%f)) { 
        if ($_goptions.get(DisableSoundsWhileAway)) && ($away) { return }
        .splay %f 
      }
    }
  }
}
alias -l _sounds.types {
  var %t = Notice,Join,JoinSelf,Part,PartSelf,Kick,KickSelf,OpSelf,DeopSelf,BanSelf,Invite,Notify,UNotify,Error,Start,Connect,Disconnect,Open,DCC,Dialog,Away,Back,Pager, $&
    %chr = $iif($1 isnum,$1,44)
  return $replace(%t,$chr(44),$chr(%chr))
}
alias -l _sounds.dialogEnables {
  var %dname = _sounds
  if ($did(%dname,4).state) || ($did(%dname,11).state) { did -b %dname 7,9,10 }
  elseif ($did(%dname,5).state) { 
    did -b %dname 9,10
    did -e %dname 7 
  } 
  elseif ($did(%dname,8).state) { 
    did -b %dname 7 
    did -e %dname 9,10
  } 
  elseif (!$did(%dname,2).sel) { did -b %dname 4,5,7,8,9,10,11 } 
  else { did -e %dname 4,5,7,8,9,10,11 }
}
alias -l _sounds.saveSound {
  var %dname = _sounds, %hash = TEMP-Sounds, %type = $did(%dname,50)
  if ($istok($_sounds.types,%type,44)) { %type = $+(Snd,%type) }
  if (%type == $null) { return }
  if ($did(%dname,5).state) { _script.setOption %hash %type default $did(%dname,6) }
  elseif ($did(%dname,8).state) { _script.setOption %hash %type custom $did(%dname,9) }
  elseif ($did(%dname,11).state) { _script.setOption %hash %type beep }
  else { _script.setOption %hash %type }
}
alias _sounds.setDefaults {
  var %x = 1, %types = $_sounds.types, %dname = sounds, %hash = TEMP-Sounds
  while ($gettok(%types,%x,44)) { 
    var %t = $+(Snd,$v1)
    if ($_themes.getText(%t)) { _script.setOption %hash %t default $v1 }
    else { _script.setOption %hash %t }
    inc %x 
  } 
  if ($dialog(%dname)) && ($did(%dname,2).seltext) { _sounds.fillSet $_script.setOption(%hash,$+(Snd,$v1)) }
}
alias -l _sounds.fillSet {
  var %dname = _sounds
  did -u %dname 4,5,8,11
  if ($1 == default) {  
    did -c %dname 5 
    did -ra %dname 6 $iif($2,$2-,<non&e>) 
    did -ra %dname 9 <clic&k to set>  
  } 
  elseif ($1 == custom) { 
    did -c %dname 8 
    did -ra %dname 9 $iif($2,$2-,<clic&k to set>) 
    did -ra %dname 6 <non&e> 
  } 
  else { 
    did -c %dname $iif($1 == beep,11,4) 
    did -ra %dname 6 <non&e> 
    did -ra %dname 9 <clic&k to set>
  }
  _sounds.dialogEnables
}



;_____________[ echos ]________________________________________

alias echos { _advanced.openDialog _echos echos }
dialog _echos {
  title "Echos"
  size -1 -1 186 175
  option dbu
  box "", 1, 5 4 175 103
  text "&Names:", 151, 11 16 24 8, right
  combo 152, 37 15 40 50, size drop
  text "Wh&ois:", 153, 84 16 45 8, right
  combo 154, 132 15 40 50, size drop
  text "&SNotices:", 155, 11 34 24 8, right
  combo 156, 37 33 40 50, size drop
  text "Ch&annel notices:", 157, 84 35 45 8, right
  combo 158, 132 33 40 50, size drop
  text "N&otices:", 159, 11 53 24 8, right
  combo 160, 37 51 40 50, size drop
  text "S&ervices notices:", 161, 84 53 45 8, right
  combo 162, 132 51 40 50, size drop
  text "No&tify:", 163, 11 70 24 8, right
  combo 164, 37 69 40 50, size drop
  text "CTC&P:", 165, 84 70 45 8, right
  combo 166, 132 69 40 50, size drop
  text "&Wallops:", 167, 11 87 24 8, right
  combo 168, 37 86 40 50, size drop
  text "&MOTD:", 169, 84 87 45 8, right
  combo 170, 132 86 40 50, size drop
  box "", 190, 5 111 175 38
  check "&Use @windows to print all echos", 191, 13 122 102 10
  check "Ma&ximum of nicks per line on names echo", 192, 13 133 113 10
  edit "", 193, 132 133 40 11, autohs right
  button "&Ok", 1000, 56 157 40 11, ok
  button "&Cancel", 999, 98 157 40 11, cancel
  button "&Help", 998, 140 157 40 11
}
on *:DIALOG:_echos:*:*:{
  if ($devent == INIT) {
    _echos.StartDialog 
    if ($_script.getOption(Echos,UseWindowsToAllEchos)) {
      did -b $dname 152,154,156,158,160,162,164,166,168,170
      did -c $dname 191
    } 
    if ($_script.getOption(Echos,ParseNicksOnNames)) { did -c $dname 192 }
    else { did -b $dname 193 }
    did -a $dname 193 $iif($int($_script.getOption(Echos,ParseNicksOnNamesN)) isnum 1-,$v1,30)
  }
  if ($devent == SCLICK) {
    if ($did == 191) { did $iif($did(191).state,-b,-e) $dname 152,154,156,158,160,162,164,166,168,170 }
    elseif ($did == 192) { did $iif($did(192).state,-e,-b) $dname 193 }
    elseif ($did == 998) { helpd -t Echos }
    elseif ($did == 1000) {
      var %id = 152, %x = 1, %» = _script.setOption Echos
      while ($gettok($_echos.types,%x,46)) { 
        %» $v1 $did(%id) 
        inc %x 
        inc %id 2 
      }
      %» UseWindowsToAllEchos $did(191).state 
      %» ParseNicksOnNames $did(192).state 
      %» ParseNicksOnNamesN $did(193)
    }
  }
}
alias -l _echos.types return Names.Whois.SNotices.ChanNotices.Notices.ServiceNotices.Notify.Ctcps.Wallops.Motd
alias -l _echos.toWhere {
  if (!$istok($_echos.types,$1,46)) { return } 
  goto $1
  :names | return Active.Status.@Window
  :whois | return Default.@Window
  :snotices | return Active.Status.@Window
  :channotices | return Default.Channel.@Window
  :notices | return Default.@Window
  :servicenotices | return Active.Status.@Window
  :notify | return Default.@Window
  :ctcps | return Default.@Window
  :wallops | return Status.Active.@Window
  :motd | return Status.Active.@Window
}
alias -l _echos.StartDialog {
  var %id = 152, %dname = _echos, %echos = $_echos.types, %x = 1, %y = $numtok(%echos,46)
  while (%x <= %y) { 
    var %echo = $gettok(%echos,%x,46), %type = $_echos.toWhere(%echo) 
    if (%type) { 
      didtok %dname %id 46 %type 
      did -c %dname %id $didwm(%dname,%id,$_echos.get(-s,%echo)) 
    } 
    inc %id 2 
    inc %x
  }
}
alias _echos.get {
  var %type = $iif(-* iswm $1,$2,$1), %flag = $iif(-* iswm $1,$1), %ret = $_script.getOption(Echos,%type)
  if (!$istok($_echos.types,%type,46)) { return }
  if ($_script.getOption(Echos,UseWindowsToAllEchos)) && (!%flag) { return @Window }
  if (%ret) && ($istok($_echos.toWhere(%type),%ret,46)) { return %ret }
  if (%type == names) { return Status }
  if (%type == whois) { return Default }
  if (%type == snotices) { return @Window }
  if (%type == channotices) { return Channel }
  if (%type == notices) { return Default }
  if (%type == servicenotices) { return Status }
  if (%type == notify) { return Default }
  if (%type == ctcps) { return Default }
  if (%type == wallops) { return Status }
  if (%type == motd) { return @Window }
}




;_____________[ nick completion ]________________________________________

alias ncomp { _advanced.openDialog _nickcomp ncomp }
alias nickcomp { ncomp }
dialog _nickcomp {
  title "Nick completion"
  size -1 -1 184 223
  option dbu

  box "&Options:", 50, 4 5 176 58
  check "&Enable nick completion", 51, 13 17 105 10
  text "&If more than one nick matching:", 52, 13 32 79 8
  combo 53, 94 31 77 50, size drop
  text "&Trigger(s):", 54, 13 47 32 8
  edit "", 55, 94 45 77 11, autohs

  box "&Style:", 56, 4 69 176 130

  radio "", 1, 12 84 10 10
  radio "", 2, 97 84 10 10
  radio "", 3, 12 108 10 10
  radio "", 4, 97 108 10 10
  radio "", 5, 12 132 10 10
  radio "", 6, 97 132 10 10
  radio "C&ustom completion", 7, 12 156 68 10

  icon 11, 25 80 60 15
  icon 12, 110 80 60 15
  icon 13, 25 104 60 15
  icon 14, 110 104 60 15
  icon 15, 25 128 60 15
  icon 16, 110 129 60 15
  icon 17, 110 170 60 15

  edit "", 57, 20 166 85 11, autohs
  button "&Add tag...", 58, 65 179 40 11

  button "&Ok", 1000, 56 206 40 11, ok
  button "&Cancel", 999, 98 206 40 11, cancel
  button "&Help", 998, 140 206 40 11
}
on *:DIALOG:_nickcomp:*:*:{
  if ($devent == INIT) {
    if ($_script.getOption(NickComp,Enabled)) { did -c $dname 51 }
    didtok $dname 53 95 Ask for right match _Use first match _Echo error and halt _Don't complete
    did -c $dname 53 $_nickcomp.ifMoreThanOneNick
    did -c $dname $_nickcomp.styleNumber
    did -a $dname 55 $_nickcomp.triggers
    did -a $dname 57 $_nickcomp.styleString(7)
    var %x = 1
    while (%x <= 7) {
      did -g $dname $calc(%x + 10) $_nickcomp.previewFile(%x,$_script.author,:,$_nickcomp.styleString(%x))
      inc %x
    }
  }
  elseif ($devent == SCLICK) {
    if ($did == 58) { _tags.add $dname 57 NICKCOMP_CUSTOM_STYLE &Nick Completion: }
    elseif ($did == 1000) {
      var %» = _script.setOption Nickcomp
      %» Enabled $did(51).state
      %» IfMoreThanOneNick $did(53).sel
      %» StyleNumber $_dialog.whichRadioIsSelected($dname,1-7,1)
      %» Triggers $did(55)
      %» CustomCompletion $did(57)
    }
  }
  elseif ($devent == EDIT) {
    if ($did == 57) { did -g $dname 17 $_nickcomp.previewFile(7,$_script.author,:,$did(57)) } 
  }
}
alias _nickcomp.ifMoreThanOneNick { return $iif($int($_script.getOption(NickComp,IfMoreThanOneNick)) isnum 1-4,$v1,1) }
alias _nickcomp.triggers { return $iif($_script.getOption(Nickcomp,Triggers) != $null,$v1,:) }
alias _nickcomp.styleNumber { return $iif($int($_script.getOption(Nickcomp,StyleNumber)) isnum 1-7,$v1,1) }
alias _nickcomp.styleString { 
  goto $iif($int($1) isnum 1-7,$v1,7)

  :1 | return <NICK><TRIGGER>
  :2 | return <NICK><TRIGGER>
  :3 | return <NICK><TRIGGER>
  :4 | return <FIRST><MIDDLE><LAST><TRIGGER>
  :5 | return <FIRST><MIDDLE><LAST><TRIGGER>
  :6 | return <FIRST><MIDDLE><LAST><TRIGGER>
  :7
  if ($_script.getOption(Nickcomp,CustomCompletion) != $null) { return $v1 }
  else { goto 1 }
}
alias _nickcomp.evaluateStyleString {
  ;; <nick> <trigger> <string>
  var %nick = $1, %trig = $2, %string = $3, %f = $left(%nick,1), %l = $right(%nick,1), %mid = $iif($len(%nick) >= 3,$right($left(%nick,-1),-1))
  return $eval($_tags.evaluateDefaults($replacecs(%string,<NICK>,%nick,<TRIGGER>,%trig,<FIRST>,%f,<LAST>,%l,<MIDDLE>,%mid)),2)
}
alias _nickcomp.previewFile {
  var %file = $_script.directory(Images,$null,$+(NickcompPreview,$1,.bmp)), $&
    %nick = $2, %trig = $3, %str = $_nickcomp.evaluateStyleString(%nick,%trig,$4-), %win = @_temp._nickcomp.previewFile, $&
    %font = MS Sans Serif, %size = $calc($dbuw * 60) $calc($dbuh * 15)
  window -c %win 
  window -hkp +d %win 0 0 %size
  drawrect -fr %win 16777215 10 0 0 %size
  drawtext -bpr %win 0 16777215 $+(",%font,") 15     10 7   $iif(%str == $null,$chr(160),%str)
  drawsave %win %file
  return %file
}
alias _nickcomp.handleInput {
  var %chan = $1, %text = $2-
  tokenize 32 %text
  var %t = $right($1,1)
  if (%t isin $_nickcomp.triggers) && ($_script.getOption(NickComp,Enabled)) && ($_mirc.commandChar !iswm $1) && ($len($1) > 1) {
    var %trig = $asc(%t), %nick = $left($1,-1), %wcard = $+(%nick,*), %x = 1, %matchs = $remtok($_channel.nicksMatchingString(%chan,%wcard),$me,1,44), $&
      %string = $_nickcomp.styleString($_nickcomp.styleNumber)
    if ($numtok(%matchs,44) == 1) { goto 2 }
    elseif (%matchs == $null) { return %text }
    else { goto $_nickcomp.ifMoreThanOneNick }
    :1
    if ($_nickcomp.matchDialog(%matchs) != $null) { return $_nickcomp.evaluateStyleString($v1,%t,%string) $2- }
    return %text
    :2
    return $_nickcomp.evaluateStyleString($gettok(%matchs,1,32),%t,%string) $2-
    :3
    _themes.errorEcho More than one matching nick on channel. Input halted.
    halt
    :4 
    return %text
  }
}
alias _nickcomp.matchDialog {
  if ($1 != $null) { 
    var %d = _nickcomp.matchs
    unset $_script.variableName(Nickcomp,Matchs,*)
    set -u $_script.variableName(NickComp,Matchs,Nicks) $1-
    __dummy $dialog(%d,%d,4)
    return $_script.variableValue(Nickcomp,Matchs,Return)
  }
}
dialog _nickcomp.matchs {
  title "Match nicks"
  size -1 -1 85 91
  option dbu
  list 1, 4 5 76 72, result size
  text "(Double click to select)", 2, 6 80 73 6, center
  button "", 3, 0 0 0 0, hide ok
}
on *:DIALOG:_nickcomp.matchs:INIT:*:{ 
  didtok $dname 1 44 $_script.variableValue(Nickcomp,Matchs,Nicks)
  did -z $dname 1
}
on *:DIALOG:_nickcomp.matchs:DCLICK:1:{ 
  set $_script.variableName(Nickcomp,Matchs,Return) $did($did).seltext 
  dialog -k $dname 
}



;_____________[ aliases ]________________________________________

alias _aliases.rawOrMsgOnServices { return $iif($_goptions.get(UseMsgInsteadOfRaw),.msg,.raw) } 
alias ns {
  if ($server) { $_aliases.rawOrMsgOnServices nickserv $1- }
}
alias cs {
  if ($server) { $_aliases.rawOrMsgOnServices chanserv $1- }
}
alias ms {
  if ($server) { $_aliases.rawOrMsgOnServices memoserv $1- }
}
alias os {
  if ($server) { $_aliases.rawOrMsgOnServices operserv $1- }
}
alias hs {
  if ($server) { $_aliases.rawOrMsgOnServices helpserv $1- }
}
alias chat {
  var %n = $iif($1 != $null,$1,$_prompt.input(Nick to chat with:"~"DCC Chat"tch"NickToChat))
  dcc chat %n
}
alias send { dcc send $1 }

alias op { _channel.controlMode +o $_channel.which $1- }
alias deop { _channel.controlMode -o $_channel.which $1- }
alias voice { _channel.controlMode +v $_channel.which $1- }
alias devoice { _channel.controlMode -v $_channel.which $1- }

alias mop { _channel.massMode $_channel.which($1) +o vr }
alias mdeop { _channel.massMode $_channel.which($1) -o o }
alias mvoice { _channel.massMode $iif($1 ischan,$1,$active) +v r }
alias mdevoice { _channel.massMode $iif($1 ischan,$1,$active) -v v }
alias mk { _channel.massKick $_channel.which($1) a }
alias mka { _channel.massKick $_channel.which($1) a }
alias mko { _channel.massKick $_channel.which($1) o }
alias mkh { _channel.massKick $_channel.which($1) h }
alias mkv { _channel.massKick $_channel.which($1) v }
alias mkr { _channel.massKick $_channel.which($1) r }
alias mkb { _channel.massKickBan $_channel.which($1) a }
alias mkba { _channel.massKickBan $_channel.which($1) a }
alias mkbo { _channel.massKickBan $_channel.which($1) o }
alias mkbh { _channel.massKickBan $_channel.which($1) h }
alias mkbv { _channel.massKickBan $_channel.which($1) v }
alias mkbr { _channel.massKickBan $_channel.which($1) r }
alias whois+ {
  if ($server == $null) { return }
  var %n = $iif($1 != $null,$1,$_prompt.input(Nick to whois:"~"Whois"-tch"NickToWois))
  %n = $gettok(%n,1,32)
  set $_script.variableName(Whois,Active,$cid,%n) 1
  !.whois %n %n
}
alias whois {
  if ($server == $null) { return }
  var %n = $iif($1 != $null,$1,$_prompt.input(Nick to whois:"~"Whois"-tch"NickToWois))
  %n = $gettok(%n,1,32)
  set $_script.variableName(Whois,Active,$cid,%n) 1
  !.whois %n $2
}
alias srv {
  if (-* iswm $1) { var %flags = $1, %server = $2, %port = $3 }
  else { var %flags = -n, %server = $1, %port = $2 }
  if (!$_string.areValidFlags(%flags,-nc)) { 
    if ($show) { _themes.sintaxEcho srv [-nc] [server] [port] }
    return
  }
  if (%server == $null) { 
    var %rc = $gettok($_connection.recent(1),1-2,32), $&
      %t = $_prompt.input(Server to connect (followed by port number or default 6667 will be used):" %rc "Connection"tch"NewConnectionServer), %server = $gettok(%t,1,32), %p = $gettok(%t,2,32) 
  }
  if (%port !isnum 0-) { %port = 6667 }
  server $iif(n isincs %flags,-m) %server %port
}
alias w { whois $1- }
alias names {
  var %chan = $iif($1,$_channel.fixName($1),$active)
  if (%chan ischan) && ($server) {
    set $_script.variableName(Names,Asking,$cid,%chan) 1
    !.names %chan
  }
}
alias motd {
  if ($server) { .raw MOTD }
}
alias time {
  if ($server) { .raw TIME }
}
alias version {
  if ($server) { .raw VERSION }
}
alias lusers {
  if ($server) { lusers }
}
alias stats {
  if (!$server) { return }
  var %s = $iif($1,$1,$_prompt.input(Request to be maded to server (one letter only):"~"Server Statistics"tch"CustomServerStatistic))
  if (? !iswm %s) { _themes.commandEcho stats One letter only. Halted! }
  else { stats %s }
}
alias notify {
  var %echo = $iif($show,_themes.commandEcho notify,__dummy)
  if ($istok(on off,$1,32)) { 
    !.notify $1 
    %echo notify Notify turned $upper($1)) $+ .
  }
  elseif ($1 == -r) && ($2) { 
    if ($notify($2)) {
      !.notify $1- 
      %echo $+(,$2,) removed from notify list. 
    } 
    else { %echo  $2 not in notify list. }
  }
  elseif ($1 == -h) || ($1 == -s) { 
    if ($server) { !.notify $1 }
    else { %echo Not connected to server. }
  }
  elseif ($1 != $null) { 
    if ($notify($1)) { %echo  $1 already in notify list. } 
    else {
      !.notify $1- 
      %echo Added $1 to notify list $iif($2 != $null,$chr(40) $+ $2- $+ $chr(41))
      var %i = 1 
      while ($comchan($1,%i)) {
        _nicklist.nick $v1 $1 
        inc %i 
      } 
    }
  }
  elseif ($1 == $null) { 
    if ($server) { !.notify } 
    else { %echo Not connected to server }
  }
}
alias query {
  if ($1 == $null) || (!$server) { return }
  var %echos = $false
  if (!$query($1)) { %echos = $true }
  !.query $1
  if (%echos) { _events.onQuery $1 }
  if ($2 != $null) { msg $1- }
}
alias _aliases.scriptFile { 
  var %f = $_file.fixName($+($mircdir,$1,.txt)), %com = $lower($1)
  if ($isid) { return $_file.isFile(%f) }
  if ($3 != $null) || (($2 != $null) && (-* !iswm $2)) || (!$_string.areValidFlags($2,ow)) { _themes.sintaxEcho %com [-ow] }
  else {
    if (!$isfile(%f)) { _themes.commandEcho %com No %com file available ( $+ %f $+ ) }
    else {
      var %flags = $iif($2 != $null,$2,o), %win = $+(@,%com)
      if (o isin %flags) { notepad %f }
      if (w isin %flags) { 
        window -al %win 
        loadbuf %win %f 
      }
    }
  }
}
alias all {
  if ($1 != $null) {
    scid -a $1- 
    scid -r
  }
  else { _themes.sintaxEcho all [command] }
}
alias aquit { scid -at1 quit $1- }
alias quit {
  if (!$server) { return }
  !quit $iif($1 != $null,$1-,$_script.name v $+ $_script.version coded by $_script.author)
}
alias whatsnew { 
  if ($isid) { return $_aliases.scriptFile(Whatsnew) }
  else { _aliases.scriptFile Whatsnew $1- }
}
alias readme {
  if ($isid) { return $_aliases.scriptFile(Readme) }
  else { _aliases.scriptFile Readme $1- }
}
alias restart {
  if (!$show) || ($_prompt.yesNo(Are you sure that you want to restart script now?"Restart)) { 
    .timer -m 1 1 .exit 
    .timer -m 1 1 run $_file.fixName($mircexe)
  }
}
alias chanstats {
  if (!$server) { return }
  var %flags = $1, %chan = $iif($1 != $null,$2,$1), %t, %o, %v, %h, %u, %echo
  if (%flags == $null) { %flags = -tovhu }
  if (%chan !ischan) && ($active ischan) { %chan = $active }
  if (%chan !ischan) { 
    _themes.commandEcho chanstats Invalid channel specified ( $+ %chan $+ )
    return
  }
  if (!$_string.areValidFlags(%flags,mtovhu)) { 
    _themes.sintaxEcho chanstats [-mtovhu] [#channel] 
    return
  }
  else {
    var %msg = $iif(m isincs %flags,$true,$false), %total = $nick(%chan,0)
    if (t isincs %flags) { %echo = [Total: $nick(%chan,0) $+ ] }
    if (o isincs %flags) { %echo = %echo [Ops: $nick(%chan,0,o) ( $+ $_math.percentage($nick(%chan,0,o),%total,0) $+ )] }
    if (v isincs %flags) { %echo = %echo [Voices: $nick(%chan,0,v) ( $+ $_math.percentage($nick(%chan,0,v),%total,0) $+ )] }
    if (h isincs %flags) { %echo = %echo [Halfops: $nick(%chan,0,h) ( $+ $_math.percentage($nick(%chan,0,h),%total,0) $+ )] }
    if (u isincs %flags) { %echo = %echo [Users: $nick(%chan,0,r) ( $+ $_math.percentage($nick(%chan,0,r),%total,0) $+ )] }
    if (!%echo) { 
      .timer -im 1 1 chanstats -t $+ $iif(%msg,m) %chan
      return 
    }
    %echo = Chanstats: %echo
    if (%msg) { msg %chan %echo }
    else { __echoicon %chan %echo }
  }
}
alias beep {
  if ($_goptions.get(DisableBeepsWhileAway)) && ($away) { return }
  !beep $1-
}
alias flash {
  if ($_goptions.get(DisableFlashingWhileAway)) && ($away) { return }
  !flash $1-
}
alias join {
  var %f = ""
  if (!$server) { return }
  if (-* iswm $1) { var %f = $1, %c = $2 }
  else { var %c = $1 }
  if (%c == $null) { %c = $_prompt.input(Specify channel to join:"~"Join"tch"JoinChannel) }
  !join %f $_channel.fixName(%c)
}
alias j { join $1- }
alias nick { 
  var %n $iif($1 != $null,$1,$_prompt.input(Specify new nick:"~"Nick"tch"NickChange)) 
  _recent.addItem -n %n
  set -u0 %::nick $me
  !.nick %n
  if ($show) && (!$chan(0)) {
    set -u0 %::newnick %n
    set -u0 %:echo echo $color(nick text) -ti2s
    _themes.text NickSelf
  }
}
alias exit {
  if ($show) && (!$_prompt.yesNo(Do you really want to exit $+($_script.name,?) "Exit)) { return }
  !exit
}
alias home { .run $_script.home }
alias umodes {
  ; /umodes [-d|+modes-modes]
  ; If no parameters it will prompt you for input
  ; If -d options defaults (or away) modes will be used

  ; if (!$server) { return }
  if ($1 == -d) {
    if ($away) { var %modes = $_goptions.get(UsermodesAway), %others = $_goptions.get(UsermodesAwayOthers) }
    else { var %modes = $_goptions.get(UsermodesDefault), %others = $_goptions.get(UsermodesDefaultOthers) }
    var %modes = $remove($gettok(%modes,1,32) $+ $gettok(%others,1,32),+,-), %curr = $remove($usermodes,+), %- = "", %x = 1,%temp
    ; Remove any current mode not to be added using - character
    while ($mid(%curr,%x,1) != $null) {
      %temp = $v1
      if (%temp !isincs %modes) { %- = %- $+ %temp }
      inc %x
    }    
    .raw MODE $me $+(+,%modes,-,%-)
  }
  else {
    if ($1 == $null) { var %modes = $_prompt.input(Set usermodes (Format: +modes-modes):" $usermode "Usermodes"tch"SetUsermodes) }
    else { var %modes = $1 }
    .raw MODE $me %modes
  }
}
alias integrity {
  ; Weird alias because it should allow to verify if all script files are properly loaded
  ; but this file has to be loaded or it will not work!

  var %x = 1, %file, %cmd = $iif($isalias(_themes.commandEcho),_themes.commandEcho integrity,echo $color(Info) -ati), %errors = 0, %fixs = 0
  if ($show) { %cmd Searching for not working script files... }
  while ($_script.file(%x)) {
    %file = $remove($ifmatch,")
    if (!$script(%file)) || ($script(%x) != %file) {
      inc %errors
      %cmd $_string.toBold($ord(%x)) script file not properly loaded. Fixing...
      if (!$isfile(%file)) { %cmd File not founded $_string.surrounded(%file) $+ . You should download and/or install script again! }
      else { 
        .reload -rs $+ %x $_file.fixName(%file)
        %cmd $_string.toBold($ord(%x)) script file sucessfuly fixed.
        inc %fixs
      }
    }
    inc %x
  }
  if ($show) { %cmd Integrity check finished $iif(!%errors,without errors founded.,$iif(%fixs < %errors,with some errors not fixed.,with all errors fixed.))  }
}











; MESSED UP ALIASES BEGING FOR A RE-WRITE AND/OR A PLACE TO STAY

alias __pnick { return $iif($_mirc.iniOption(2,30), $remove($nick($1,$2).pnick ,$2)) }
alias __dummy { }
alias __repeatCommand {
  var %n = $iif($int($1) isnum 1-,$v1,1), %cmd = $2-
  if (%cmd) {
    while (%n) {
      %cmd
      dec %n
    }
  }
}
alias __sleep {
  var %a = $ticks $+ .wsf
  write %a <job id="js"><script language="jscript">WScript.Sleep( $+ $$1 $+ );</script></job>
  .comopen %a WScript.Shell
  if !$comerr { .comclose %a $com(%a,Run,3,bstr,%a,uint,0,bool,true) }
  .remove %a
}
alias __gub {
  var %i = ""
  if ($1 == 1) { %i = &0VEG87(_```` } 
  elseif ($1 == 2) { %i = &4&EP;V-A```` }
  elseif ($1 == 3) { %i = 066]U)W)E(&%N(&ED:71O=``` }
  return $decode(%i)
}
alias __myAddress { return $address($me,5) }
alias __isInMyAddress {
  if ($1 iswm $__myAddress) { return 1 }
}
alias __ticks {
  if ($1 != $null) {
    var %ticks = $ticks, %end
    $1-
    %end = $calc(($ticks - %ticks) / 1000)
    if (!$isid) {
      linesep
      echo $color(highlight) -aq » Time: %end $+ s
      echo $color(highlight) -aq » Command: $1-
      echo $color(highlight) -aq » Result: $iif($result != $null,$v1,<none>) 
    }
    return %end
  }
}
alias __bantype { return 0 }
alias __defaultIgnoreType { return 1 }
alias __maxNicksKick { return 10 }
