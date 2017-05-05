;___________[ proto ]____________________________________

alias proto { 
  var %t
  if ($1 == -p) { %t = 1000 }
  elseif ($1 == -c) { %t == 500 }
  elseif ($1 == -b) { %t = 800 }
  if (%t) { _proto.setOption LastSelectedTab %t }
  _advanced.openDialog _proto proto 
}
dialog _proto {
  title "Protections options"
  size -1 -1 180 255
  option dbu notheme

  tab "&Personal", 1000, 4 4 171 226

  box "O&n flood:", 50, 10 22 160 157, tab 1000
  check "&Always ignore permanently", 51, 17 33 82 10, tab 1000
  check "&Kick and ban flooder from all possible channels", 52, 17 44 132 10, tab 1000
  check "Clo&se all windows related to flooder (DCC's and query)", 53, 17 55 144 10, tab 1000

  check "C&hange nick to:", 54, 17 78 49 10, tab 1000
  edit "", 55, 67 78 54 11, tab 1000 autohs
  button "A&dd tag...", 56, 124 78 37 11, tab 1000
  check "&Flash mIRC's window (if not active)", 57, 17 89 110 10, tab 1000
  check "Pl&ay sound (beep if no file selected)", 58, 17 100 100 10, tab 1000
  check "&if away", 59, 122 100 33 10, tab 1000
  button "<p&ush to select sound file>", 60, 26 112 125 11, tab 1000
  button "!", 61, 152 112 9 11, tab 1000

  check "Sen&d notice to flooder:", 62, 17 135 82 10, tab 1000
  edit "", 63, 26 146 135 11, tab 1000 autohs
  button "Add &tag...", 64, 85 159 37 11, tab 1000
  button "De&fault", 65, 124 159 37 11, tab 1000

  box "&Exempted users:", 66, 10 183 160 41, tab 1000
  edit "", 67, 17 195 145 11, tab 1000 autohs
  text "(Network1:Nick1,NickN NetworkN:Nick1,NickN)", 68, 19 208 142 8, tab 1000 right

  tab "&Channels", 500
  box "&Exempted users:", 3, 10 22 160 72, tab 500
  check "Channel opera&tors", 4, 17 33 67 10, tab 500
  check "C&hannel owners", 5, 17 44 67 10, tab 500
  check "Ch&annel halfops", 6, 17 55 67 10, tab 500
  check "&Voiced users", 7, 17 66 67 10, tab 500
  check "&IRCops", 8, 17 77 67 10, tab 500
  check "A&ny non-regular user", 9, 97 33 67 10, tab 500
  box "&Penalties:", 10, 10 98 160 51, tab 500
  check "&Don't trigger if lag higher than", 11, 17 109 85 10, tab 500
  edit "", 12, 102 109 35 11, tab 500 autohs right
  text "seconds", 13, 139 110 25 8, tab 500
  check "Trigger ne&xt penalty after", 14, 17 120 84 10, tab 500
  edit "", 15, 102 120 35 11, tab 500 autohs right
  text "seconds", 16, 139 122 25 8, tab 500
  check "&Reset all actions after", 17, 17 131 85 10, tab 500
  edit "", 18, 102 131 35 11, tab 500 autohs right
  text "seconds", 19, 139 133 25 8, tab 500
  box "&If channel is empty on join:", 21, 10 152 160 42, tab 500
  text "&Set modes:", 22, 18 165 30 8, tab 500
  edit "", 23, 49 163 111 11, tab 500 autohs
  text "To&pic:", 24, 18 177 25 8, tab 500
  edit "", 25, 49 175 111 11, tab 500 autohs
  box "&Misc:", 26, 10 197 160 27, tab 500
  check "Deop o&n serverop", 27, 17 208 59 10, tab 500
  check "&Kick on ban", 28, 96 208 52 10, tab 500

  tab "&Both", 800
  box "&Kick message:", 101, 10 22 160 88, tab 800
  text "&Default:", 102, 18 36 22 8, tab 800
  edit "", 103, 17 44 144 11, tab 800 autohs
  button "Add &tag...", 104, 85 56 37 11, tab 800
  button "De&fault", 105, 124 56 37 11, tab 800

  text "&Format:", 106, 18 71 25 8, tab 800
  edit "", 107, 17 80 144 11, tab 800 autohs
  button "&Add tag...", 108, 85 92 37 11, tab 800
  button "D&efault", 109, 124 92 37 11, tab 800

  edit "", 1500, 0 0 0 0, autohs hide disable ;Temp sound file

  button "&Ok", 2000, 51 238 40 11, ok
  button "&Cancel", 1999, 93 238 40 11, cancel
  button "&Help", 1998, 135 238 40 11
}
on *:DIALOG:_proto:*:*:{
  if ($devent == INIT) {
    var %t = $_proto.getOption(LastSelectedTab)
    .timer -mi 1 0 did -c $dname $iif($istok(800 500 1000,$_proto.getOption(LastSelectedTab),32),%t,1000)

    ; Personal 
    if ($_proto.getOption(PersPermanentIgnore)) { did -c $dname 51 }
    if ($_proto.getOption(PersKickBanFromAllChannels)) { did -c $dname 52 }
    if ($_proto.getOption(PersCloseAllFlooderWindows)) { did -c $dname 53 }
    if ($_proto.getOption(PersChangeNick)) { did -c $dname 54 }
    else { did -b $dname 55,56 }
    did -a $dname 55 $_proto.changeNickTo
    if ($_proto.getOption(PersFlashMirc)) { did -c $dname 57 }
    if ($_proto.getOption(PersPlaySound)) { did -c $dname 58 }
    else { did -b $dname 59,60,61 }
    if ($_proto.getOption(PersPlaySoundOnlyWhenAway)) { did -c $dname 59 }
    if ($_file.isFile($_proto.getOption(PersPlaySoundFile))) {
      var %f = $v1
      did -a $dname 60 $_dialog.shorterFilename(50,%f)
      did -a $dname 1500 $remove(%f,")
    }
    if ($_proto.getOption(PersNoticeFlooder)) { did -c $dname 62 }
    else { did -b $dname 63,64,65 }
    did -a $dname 63 $_proto.flooderNotice
    did -a $dname 67 $_proto.getOption(PersExemptedUsers)

    ; Channel
    if ($_proto.getOption(ChanExemptOps)) { did -c $dname 4 }
    if ($_proto.getOption(ChanExemptOwners)) { did -c $dname 5 }
    if ($_proto.getOption(ChanExemptHalfops)) { did -c $dname 6 }
    if ($_proto.getOption(ChanExemptVoices)) { did -c $dname 7 }
    if ($_proto.getOption(ChanExemptIRCops)) { did -c $dname 8 }
    if ($_proto.getOption(ChanExemptNonRegular)) { 
      did -c $dname 9 
      did -b $dname 4,5,6,7,8
    }
    if ($_proto.getOption(ChanDontTriggerIfLagHigher)) { did -c $dname 11 }
    else { did -b $dname 12 }
    if ($_proto.getOption(ChanTriggerNextPenalty)) { did -c $dname 14 }
    else { did -b $dname 15 }
    if ($_proto.getOption(ChanResetPenaltiesCount)) { did -c $dname 17 }
    else { did -b $dname 18 }
    did -a $dname 12 $iif($int($_proto.getOption(ChanDontTriggerIfLagHigherThan)) isnum 1-,$v1,5)
    did -a $dname 15 $iif($int($_proto.getOption(ChanTriggerNextPenaltyAfter)) isnum 1-,$v1,10)
    did -a $dname 18 $iif($int($_proto.getOption(ChanResetPenaltiesCountAfter)) isnum 1-,$v1,300)
    did -a $dname 23 $_proto.getOption(ChanModesWhenEmpty)
    did -a $dname 25 $_proto.getOption(ChanTopicWhenEmpty)
    if ($_proto.getOption(ChanDeopOnServerop)) { did -c $dname 27 }
    if ($_proto.getOption(ChanKickOnBan)) { did -c $dname 28 } 

    ; Both
    did -ra $dname 103 $_proto.defaultKickMessage
    did -ra $dname 107 $_proto.kickMessageFormat
  }
  elseif ($devent == SCLICK) {
    if ($did == 9) { did $iif($did(9).state,-b,-e) $dname 4,5,6,7,8 }
    elseif ($did == 11) { did $iif($did(11).state,-e,-b) $dname 12 }
    elseif ($did == 14) { did $iif($did(14).state,-e,-b) $dname 15 }
    elseif ($did == 17) { did $iif($did(17).state,-e,-b) $dname 18 }
    elseif ($did == 54) { did $iif($did(54).state,-e,-b) $dname 55,56 }
    elseif ($did == 56) { _tags.add $dname 55 }
    elseif ($did == 58) { did $iif($did(58).state,-e,-b) $dname 59,60,61 }
    elseif ($did == 60) {
      var %f = $_prompt.selectFile($mircdir*.wav,Protections options - Select sound,OptProtsAddSoundPersonal)
      if (!%f) {
        did -ra $dname 60 <&push to select sound file>
        did -r $dname 1500
      }
      else {
        did -ra $dname 60 $_dialog.shorterFilename(50,%f)
        did -ra $dname 1500 %f
      }
    }
    elseif ($did == 61) {
      if ($_file.isFile($did(1500))) { splay $v1 }
    }
    elseif ($did == 62) { did $iif($did(62).state,-e,-b) $dname 63,64,65 }
    elseif ($did == 64) { _tags.add $dname 63 PROTO_NOTICE_FLOODER &Notice flooder: }
    elseif ($did == 65) { did -ra $dname 63 You trigger <OFFENCE> protection (Ignore seconds: <IGNORETIME>) }
    elseif ($did == 105) { did -ra $dname 103 Don't mess with <CHANNEL> }
    elseif ($did == 108) || ($did == 104) { _tags.add $dname $iif($did == 104,103,107) PROTO_KICK_MESSAGE &Kick message: }
    elseif ($did == 109) { did -ra $dname 107 <SCRIPTLOGO> - <MESSAGE> (<CHANCOUNT>/<ALLCOUNT>) }
    elseif ($did == 2000) {
      var %» = _script.setOption Proto
      ; Personal
      %» PersPermanentIgnore $did(51).state
      %» PersKickBanFromAllChannels $did(52).state
      %» PersCloseAllFlooderWindows $did(53).state
      %» PersChangeNick $did(54).state
      %» PersChangeNickTo $did(55)
      %» PersFlashMirc $did(57).state
      %» PersPlaySound $did(58).state
      %» PersPlaySoundOnlyWhenAway $did(59).state
      %» PersPlaySoundFile $did(1500)
      %» PersNoticeFlooder $did(62).state
      %» PersNoticeFlooderText $did(63)
      %» PersExemptedUsers $did(67)

      ; Channel
      %» ChanExemptOps $did(4).state
      %» ChanExemptOwners $did(5).state
      %» ChanExemptHalfops $did(6).state
      %» ChanExemptVoices $did(7).state
      %» ChanExemptIRCops $did(8).state
      %» ChanExemptNonRegular $did(9).state
      %» ChanDontTriggerIfLagHigher $did(11).state
      %» ChanTriggerNextPenalty $did(14).state
      %» ChanResetPenaltiesCount $did(17).state
      %» ChanDontTriggerIfLagHigherThan $did(12)
      %» ChanTriggerNextPenaltyAfter $did(15)
      %» ChanResetPenaltiesCountAfter $did(18)
      %» ChanModesWhenEmpty $did(23)
      %» ChanTopicWhenEmpty $did(25)
      %» ChanDeopOnServerop $did(27).state
      %» ChanKickOnBan $did(28).state

      ; Misc
      %» DefaultKickMessage $did(103)
      %» KickMessageFormat $did(107)
    }
  }
  elseif ($devent == CLOSE) { _script.setOption Proto LastSelectedTab $dialog($dname).tab }
}
alias _proto.setOption { _script.setOption Proto $1- }
alias _proto.getOption { return $_script.getOption(Proto,$1) }
alias _proto.defaultKickMessage { 
  var %r = $iif($_proto.getOption(DefaultKickMessage) != $null,$v1,Don't mess with <CHANNEL>)
  if ($1) { return $_tags.evaluateDefault(%r) }
  return %r
}
alias _proto.kickMessageFormat {
  var %r = $iif($_proto.getOption(KickMessageFormat) != $null,$v1,<SCRIPTLOGO> - <MESSAGE> (<CHANCOUNT>/<ALLCOUNT>)) 
  if ($1) { return $_tags.evaluateDefaults(%r) }
  return %r
}
alias _proto.changeNickTo {
  var %r =  $iif($_proto.getOption(PersChangeNickTo) != $null,$v1,<ME>_)
  if ($1) { return $_tags.evaluateDefault(%r) }
  return %r
}
alias _proto.flooderNotice {
  var %r = $iif($_proto.getOption(PersNoticeFlooderText) != $null,$v1,You trigger <OFFENCE> protection (Ignore seconds: <IGNORETIME>))
  if ($1) { return $_tags.evaluateDefaults(%r) }
  return %r
}




;______________[ pprot ]__________________________________________

alias pprot { pprots }
alias pprots { _advanced.openDialog _pprots pprots }
dialog _pprots {
  title "Personal protections"
  size -1 -1 308 230
  option dbu

  box "", 1, -10 23 400 4
  text "&Network:", 2, 50 9 23 8
  combo 3, 76 8 85 50, sort size drop
  button "&Add...", 4, 164 8 40 11
  button "&Remove", 5, 206 8 40 11

  check "&Text flood (lines) protection", 8, 10 35 95 10
  check "T&ext flood (chars) protection", 9, 10 45 95 10
  check "&Invite flood protection", 10, 10 59 95 10
  check "Notic&e flood (notices) protection", 11, 10 73 95 10
  check "Notice &flood (chars) protection", 12, 10 83 95 10
  check "CTC&P flood protection", 13, 10 97 95 10
  check "CTCP &reply flood protection", 14, 10 107 95 10
  check "Query f&lood protection", 15, 10 121 95 10
  check "Chat te&xt flood (lines) protection", 16, 10 135 95 10
  check "&Chat text flood (chars) protection", 17, 10 145 95 10

  edit "", 18, 105 35 30 11, autohs right
  edit "", 19, 105 45 30 11, autohs right
  edit "", 20, 105 59 30 11, autohs right
  edit "", 21, 105 73 30 11, autohs right
  edit "", 22, 105 83 30 11, autohs right
  edit "", 23, 105 97 30 11, autohs right
  edit "", 24, 105 107 30 11, autohs right
  edit "", 25, 105 121 30 11, autohs right
  edit "", 26, 105 135 30 11, autohs right
  edit "", 27, 105 145 30 11, autohs right

  text "lines in", 28, 137 37 26 8
  text "chars in", 29, 137 47 26 8
  text "invites in", 30, 137 61 26 8
  text "notices in", 31, 137 75 26 8
  text "chars in", 32, 137 85 26 8
  text "ctcps in", 33, 137 99 26 8
  text "replies in", 34, 137 109 26 8
  text "queries in", 35, 137 123 26 8
  text "lines in", 36, 137 137 26 8
  text "chars in", 37, 137 147 26 8

  edit "", 38, 163 35 30 11, autohs right
  edit "", 39, 163 45 30 11, autohs right
  edit "", 40, 163 59 30 11, autohs right
  edit "", 41, 163 73 30 11, autohs right
  edit "", 42, 163 83 30 11, autohs right
  edit "", 43, 163 97 30 11, autohs right
  edit "", 44, 163 107 30 11, autohs right
  edit "", 45, 163 121 30 11, autohs right
  edit "", 46, 163 135 30 11, autohs right
  edit "", 47, 163 145 30 11, autohs right

  edit "", 48, 246 35 30 11, autohs right
  edit "", 49, 246 45 30 11, autohs right
  edit "", 50, 246 59 30 11, autohs right
  edit "", 51, 246 73 30 11, autohs right
  edit "", 52, 246 83 30 11, autohs right
  edit "", 53, 246 97 30 11, autohs right
  edit "", 54, 246 107 30 11, autohs right
  edit "", 55, 246 121 30 11, autohs right
  edit "", 56, 246 135 30 11, autohs right
  edit "", 57, 246 145 30 11, autohs right
  edit "", 58, 246 159 30 11, autohs right

  text "seconds, ignore for", 69, 195 37 50 8
  text "seconds, ignore for", 70, 195 47 50 8
  text "seconds, ignore for", 71, 195 61 50 8
  text "seconds, ignore for", 72, 195 75 50 8
  text "seconds, ignore for", 73, 195 85 50 8
  text "seconds, ignore for", 74, 195 99 50 8
  text "seconds, ignore for", 75, 195 109 50 8
  text "seconds, ignore for", 76, 195 123 50 8
  text "seconds, ignore for", 77, 195 137 50 8
  text "seconds, ignore for", 78, 195 147 50 8

  text "seconds", 88, 278 36 25 8
  text "seconds", 89, 278 47 25 8
  text "seconds", 90, 278 61 25 8
  text "seconds", 91, 278 74 25 8
  text "seconds", 92, 278 85 25 8
  text "seconds", 93, 278 98 25 8
  text "seconds", 94, 278 109 25 8
  text "seconds", 95, 278 123 25 8
  text "seconds", 96, 278 137 25 8
  text "seconds", 97, 278 147 25 8
  text "seconds", 98, 278 161 25 8

  check "Anti-spa&mming protection", 100, 10 159 92 10
  button "Spam li&st", 101, 105 160 35 10
  text "ignore for", 102, 195 161 46 8, right

  text "&Presets:", 500, 226 189 20 8
  combo 501, 248 188 50 50, size drop
  box "", 502, -10 176 400 29
  button "All checks o&n", 503, 10 186 43 12
  button "All checks o&ff", 504, 55 186 43 12

  button "&Ok", 1000, 174 212 40 11, ok
  button "&Cancel", 999, 216 212 40 11, cancel
  button "&Help", 998, 258 212 40 11
  button "Opt&ions...", 997, 132 212 40 11

  edit "", 2000, 0 2 0 0, hide disable autohs
}
on *:DIALOG:_pprots:*:*:{
  if ($devent == INIT) {
    hfree -w $_hash.prefixed(TEMP-PProts-*)
    var %x = 1, %names = $_hash.allMatching(PProts-&), %i, %nets = (Default)
    while ($gettok(%names,%x,32) != $null) {
      %i = $_hash.notPrefixed($v1)
      %nets = $addtok(%nets,$gettok(%i,2-,45),32)
      _hash.toHash %i $+(TEMP-PProts-,$gettok(%i,2-,45))
      inc %x
    }
    didtok $dname 3 32 %nets
    didtok $dname 501 44 Lenient,Normal,Strict,-,Import...
    if ($didwm(3,$_script.getOption(PProts,LastNetworkSelected))) { did -c $dname 3 $v1 }
    else { did -c $dname 3 1 }
    _pprots.loadSettings
  }
  elseif ($devent == SCLICK) {
    if ($did == 3) { _pprots.loadSettings }
    elseif ($did == 4) {
      var %net = $$_prompt.addNetwork(Protections)
      if ($didwm(3,%net)) { did -c $dname 3 $v1 }
      else { did -ca $dname 3 %net }
      _pprots.loadSettings
    }
    elseif ($did == 5) {
      if ($did(3).seltext != $null) {
        var %text = $v1
        if (%text != $chr(40) $+ Default $+ $chr(41)) && ($_prompt.yesNo(Do you really want to remove $+(',%text,') settings?"Personal protections)) {
          _script.setOption $+(TEMP-PProts-,%text)
          set $_script.variableName(PProts,Dialog,NetworksToRemove) $addtok($_script.variableValue(PProts,Dialog,NetworksToRemove),%text,32)
          did -d $dname 3 $did(3).sel
          did -c $dname 3 1
          did -r $dname 2000
          _pprots.loadSettings
        }
        dialog -v $dname
      }   
    }
    elseif ($did isnum 8-17) || ($did == 100) { _pprots.checks $did }
    elseif ($did == 101) { _pprots.editSpamList }
    elseif ($did isnum 503-504) {
      var %id = 8, %s = $iif($did == 503,-c,-u)
      while (%id <= 17) {
        did %s $dname %id
        _pprots.checks %id
        inc %id
      }
      did %s $dname 100
      _pprots.checks 100
    }
    elseif ($did == 501) {
      var %sel = $did(501).sel
      if (%sel isnum 1-3) {
        var %x = 1, %prots = $_pprots.protectionsString, %check = 8, %prot
        while ($gettok(%prots,%x,32) != $null) {
          %prot = $v1
          did -ra $dname $calc(%check + 10) $_pprots.defaultValues($+(%prot,X),%sel)
          did -ra $dname $calc(%check + 30) $_pprots.defaultValues($+(%prot,IN),%sel)
          did -ra $dname $calc(%check + 40) $_pprots.defaultValues($+(%prot,FOR),%sel)
          inc %x
          inc %check
        }
        did -ra $dname $calc(%check + 40) $_pprots.defaultValues(AntiSpamFOR,%sel)
      }
      elseif (%sel == 5) { _pprots.importValues }
    }
    elseif ($did == 997) { proto -p }
    elseif ($did == 1000) {
      if ($did(2000) != $null) { _pprots.saveSettings $v1 }
      var %x = 1, %hashs = $_hash.allMatching(TEMP-PProts-&), %i
      while ($gettok(%hashs,%x,32) != $null) {
        %i = $_hash.notPrefixed($v1)
        _hash.toHash -o %i $gettok(%i,2-,45)
        inc %x
      } 
      var %rem = $_script.variableValue(PProts,Dialog,NetworksToRemove), %x = 1, %i
      while ($gettok(%rem,%x,32) != $null) {
        %i = $v1
        hfree -w $_hash.prefixed($+(*,PProts-,%i))
        inc %x
      }
    }
  }
  elseif ($devent == CLOSE) {
    _script.setOption PProts LastNetworkSelected $did(3).seltext
    hfree -w $_hash.prefixed(TEMP-PProts-*) 
  }
}
alias -l _pprots.checks {
  var %dname = _pprots, %did = $1, %ids, %s = $iif($did(%dname,%did).state,-e,-b)
  if (%did == 100) { did %s %dname 101,58 }
  elseif (%did isnum 8-17) {
    %ids = $+($calc(%did + 10), $chr(44) ,$calc(%did + 30), $chr(44) ,$calc(%did + 40))
    did %s %dname %ids
  }
}
alias -l _pprots.protectionsString { 
  return TextFloodLines TextFloodChars InviteFlood NoticeFloodNotices NoticeFloodChars CTCPFlood CTCPReplyFlood QueryFlood ChatTextFloodLines ChatTextFloodChars
}
alias -l _pprots.defaultValues {
  var %val = $1, %x = $2, %r
  if (%x !isnum 1-3) || (%val == $null) { return }
  goto %val
  :TextFloodLinesX | %r = 15.12.9 | goto e
  :TextFloodLinesIN | %r = 15.10.8 | goto e
  :TextFloodLinesFOR | %r = 60.60.60 | goto e
  :TextFloodCharsX | %r = 1500.1200.900 | goto e
  :TextFloodCharsIN | %r = 15.10.8 | goto e
  :TextFloodCharsFOR | %r = 60.60.60 | goto e
  :InviteFloodX | %r = 4.3.2 | goto e
  :InviteFloodIN | %r = 15.10.8 | goto e
  :InviteFloodFOR | %r = 60.60.60 | goto e
  :NoticeFloodNoticesX | %r = 18.15.12 | goto e
  :NoticeFloodNoticesIN | %r = 15.10.8 | goto e
  :NoticeFloodNoticesFOR | %r = 40.40.40 | goto e
  :NoticeFloodCharsX | %r = 1800.1500.1200 | goto e
  :NoticeFloodCharsIN | %r = 15.10.8 | goto e
  :NoticeFloodCharsFOR | %r = 40.40.40 | goto e
  :CTCPFloodX | %r = 4.3.2 | goto e
  :CTCPFloodIN | %r = 15.10.8 | goto e
  :CTCPFloodFOR | %r = 90.90.90 | goto e
  :CTCPReplyFloodX | %r = 15.12.9 | goto e
  :CTCPReplyFloodIN | %r = 15.10.8 | goto e
  :CTCPReplyFloodFOR | %r = 90.90.90 | goto e
  :QueryFloodX | %r = 4.3.2 | goto e
  :QueryFloodIN | %r = 15.10.8 | goto e
  :QueryFloodFOR | %r = 15.15.15 | goto e 
  :ChatTextFloodLinesX | %r = 70.50.20 | goto e
  :ChatTextFloodLinesIN | %r = 15.10.8 | goto e
  :ChatTextFloodLinesFOR | %r = 60.60.60 | goto e
  :ChatTextFloodCharsX | %r = 5000.4000.3000 | goto e
  :ChatTextFloodCharsIN | %r = 15.10.8 | goto e
  :ChatTextFloodCharsFOR | %r = 60.60.60 | goto e
  :AntiSpamFOR | %r = 50.50.50
  :%val
  :e
  return $gettok(%r,%x,46)
}
alias -l _pprots.loadSettings {
  var %dname = _pprots, %net = $did(%dname,3).seltext, %hash = $+(TEMP-PProts-,%net), %x = 1, %checks = 8,9,10,11,12,13,14,15,16,17, %prots = $_pprots.protectionsString
  did $iif(%net == (Default),-b,-e) %dname 5 
  if ($did(%dname,2000) != $null) { _pprots.saveSettings $v1 }
  if (%net == $null) { return }
  did -u %dname %checks $+ ,100
  while ($gettok(%checks,%x,44) != $null) {
    var %id = $v1, %prot = $gettok(%prots,%x,32), %str1 = $+(%prot,X), %str2 = $+(%prot,IN), %str3 = $+(%prot,FOR)
    if ($_script.getOption(%hash,%prot)) { did -c %dname %id }
    did -ra %dname $calc(%id + 10) $iif($int($_script.getOption(%hash,%str1)), $v1 ,$_pprots.defaultValues(%str1,2))
    did -ra %dname $calc(%id + 30) $iif($int($_script.getOption(%hash,%str2)), $v1, $_pprots.defaultValues(%str2,2))
    did -ra %dname $calc(%id + 40) $iif($int($_script.getOption(%hash,%str3)), $v1, $_pprots.defaultValues(%str3,2))
    _pprots.checks %id
    inc %x
  }
  did -ra %dname 58 $iif($int($_script.getOption(%hash,AntiSpamFOR)), $v1, $_pprots.defaultValues(AntiSpamFOR,2))
  if ($_script.getOption(%hash,AntiSpam)) { did -c %dname 100 }
  _pprots.checks 100

  did -ra %dname 2000 %net
}
alias -l _pprots.saveSettings {
  var %dname = _pprots, %net = $1, %hash = $+(TEMP-PProts-,%net), %prots = $_pprots.protectionsString, %checks = 8,9,10,11,12,13,14,15,16,17, %x = 1, %» = _script.setOption %hash
  while ($gettok(%checks,%x,44) != $null) {
    var %id = $v1, %prot = $gettok(%prots,%x,32)
    %» %prot $did(%dname,%id).state
    %» $+(%prot,X) $did(%dname, $calc(%id + 10))
    %» $+(%prot,IN) $did(%dname, $calc(%id + 30))
    %» $+(%prot,FOR) $did(%dname, $calc(%id + 40))
    inc %x
  }
  %» AntiSpam $did(%dname,100).state
  %» AntiSpamFOR $did(%dname,58)
}
dialog _pprots.import {
  title "Import protection settings"
  size -1 -1 140 99
  option dbu
  text "&Settings from:", 2, 12 11 36 8
  combo 3, 49 10 77 50, size drop
  box "&Import:", 4, 4 26 131 50
  check "Protections states (On/Off)", 6, 12 37 118 10
  check "&Numeric values (N lines, chars in N seconds)", 7, 12 48 118 10
  check "I&gnores values (ignore for N seconds)", 8, 12 59 118 10
  button "&Import", 9, 52 83 40 11, disable ok
  button "&Cancel", 10, 94 83 40 11, cancel
  edit "0", 2000, 0 0 0 0, hide result
}
on *:DIALOG:_pprots.import:*:*:{
  if ($devent == INIT) {
    var %net = $_script.variableValue(PProts,ImportSettingsTo)
    dialog -t $dname %net - Import settings
    var %nets = $didtok(_pprots,3,32)
    didtok $dname 3 32 $remtok(%nets,%net,1,32)
  }
  elseif ($devent == SCLICK) {
    if ($did == 3) || ($did isnum 6-8) {
      if ($did(3).seltext != $null) && (($did(6).state) || ($did(7).state) || ($did(8).state)) { did -e $dname 9 }
      else { did -b $dname 9 }
    }
    if ($did == 9) {
      var %net = $did(3).seltext, %netTo = $_script.variableValue(PProts,ImportSettingsTo)
      if (%net == $null) || (%netTo == $null) { return }
      var %hash1 = $_hash.prefixed($+(TEMP-PProts-,%net)), %hash2 = $_hash.prefixed($+(TEMP-PProts-,%netTo)), %x = 1, %prots = $_pprots.protectionsString
      if ($did(6).state) {
        while ($gettok(%prots,%x,32) != $null) {
          hadd -m %hash2 $v1 $hget(%hash1,$v1)
          inc %x
        }
        hadd -m %hash2 AntiSpam $hget(%hash1,AntiSpam)
      }
      if ($did(7).state) {
        %x = 1
        while ($gettok(%prots,%x,32) != $null) {
          hadd -m %hash2 $+($v1,IN) $hget(%hash1,$+($v1,IN))
          inc %x
        }
        %x = 1
        while ($gettok(%prots,%x,32) != $null) {
          hadd -m %hash2 $+($v1,X) $hget(%hash1,$+($v1,X))
          inc %x
        }
      }
      if ($did(8).state) {
        %x = 1
        while ($gettok(%prots,%x,32) != $null) {
          hadd -m %hash2 $+($v1,FOR) $hget(%hash1,$+($v1,FOR))
          inc %x
        }
        hadd -m %hash2 AntiSpamFOR $hget(%hash1,AntiSpamFOR)
      }
      did -ra $dname 2000 1
    }
  }
}
alias -l _pprots.importValues { 
  var %dname = _pprots, %_dname = _pprots.import, %net = $did(%dname,3).seltext
  if (%net == $null) { return }
  if ($dialog(%_dname)) { 
    dialog -v %_dname
    return
  }
  if ($did(%dname,3).lines <= 1) {
    _prompt.info No settings available to import."Personal protections
    return
  }
  if ($did(%dname,2000) != $null) { _pprots.saveSettings }
  set -u $_script.variableName(PProts,ImportSettingsTo) %net
  __dummy $dialog(%_dname,%_dname,-4)
  did -r %dname 2000
  _pprots.loadSettings
}
alias _pprots.editSpamList {
  var %d = _pprots.spamList
  if ($dialog(%d)) || ($did(_pprots,3).seltext == $null) { return }
  var %s = $dialog(%d,%d,-4)
}
dialog _pprots.spamList {
  title "Spam list"
  size -1 -1 140 145
  option dbu

  box "", 1, 4 4 131 118
  list 2, 9 13 76 103, size
  button "&Add...", 3, 88 37 40 11
  button "&Remove", 4, 88 49 40 11
  button "&Edit...", 5, 88 77 40 11

  button "&Ok", 100, 52 128 40 11, ok
  button "&Cancel", 99, 94 128 40 11, cancel

  edit "", 500, 0 0 0 0, autohs hide disable
}
on *:DIALOG:_pprots.spamLIst:*:*:{
  if ($devent == INIT) {
    var %net = $did(_pprots,3).seltext, %data = $_script.getOption($+(TEMP-PProts-,%net),AntiSpamListData)
    dialog -t $dname $+(%net,'s) spam list
    did -a $dname 500 %net
    didtok $dname 2 34 %data
  }
  elseif ($devent == DCLICK) && ($did == 2) { goto edit }
  elseif ($devent == SCLICK) {
    if ($did == 3) {
      var %t = $$_prompt.input(Spam string to add:"~"Spam list"tc"PProtsAddToSpamList)
      %t = $remove(%t,")
      if ($didwm(2,%t)) { _prompt.info $+(',%t,') already on spam list. Halted."Spam list }
      else { did -a $dname 2 %t }
    }
    elseif ($did == 4) {
      if ($did(2).sel) {
        var %i = $v1 
        did -d $dname 2 %i
        %i = $calc(%i - 1)
        if ($did(2,%i) != $null) { did -c $dname 2 %i }
        elseif ($did(2,1) != $null) { did -c $dname 2 1 }
      }
    }
    elseif ($did == 5) {
      :edit
      if ($did(2).seltext != $null) {
        var %_curr = $v1, %t = $_prompt.input(Spam string to replace selected:" %_curr "Spam list"tch"PProtsAddToSpamList), %i = $did(2).sel
        %t = $remove(%t,")
        if ($didwm(2,%t)) && (%t != %_curr) { _prompt.info $+(',%t,') already on spam list. Halted."Spam list }
        else { did -oc $dname 2 %i %t }
      }
    }
    elseif ($did == 100) {
      var %net = $did(500), %hash = TEMP-PProts- $+ %net
      if (%net == $null) { return } 
      _script.setOption %hash AntiSpamListData $didtok(2,34)
    }
  }
}

; Let's rock'n'roll !!
/*
:TextFloodLinesX | %r = 15.12.9 | goto e
:TextFloodLinesIN | %r = 15.10.8 | goto e
:TextFloodLinesFOR | %r = 60.60.60 | goto e
:TextFloodCharsX | %r = 1500.1200.900 | goto e
:TextFloodCharsIN | %r = 15.10.8 | goto e
:TextFloodCharsFOR | %r = 60.60.60 | goto e
:InviteFloodX | %r = 4.3.2 | goto e
:InviteFloodIN | %r = 15.10.8 | goto e
:InviteFloodFOR | %r = 60.60.60 | goto e
:NoticeFloodNoticesX | %r = 18.15.12 | goto e
:NoticeFloodNoticesIN | %r = 15.10.8 | goto e
:NoticeFloodNoticesFOR | %r = 40.40.40 | goto e
:NoticeFloodCharsX | %r = 1800.1500.1200 | goto e
:NoticeFloodCharsIN | %r = 15.10.8 | goto e
:NoticeFloodCharsFOR | %r = 40.40.40 | goto e
:CTCPFloodX | %r = 4.3.2 | goto e
:CTCPFloodIN | %r = 15.10.8 | goto e
:CTCPFloodFOR | %r = 90.90.90 | goto e
:CTCPReplyFloodX | %r = 15.12.9 | goto e
:CTCPReplyFloodIN | %r = 15.10.8 | goto e
:CTCPReplyFloodFOR | %r = 90.90.90 | goto e
:QueryFloodX | %r = 4.3.2 | goto e
:QueryFloodIN | %r = 15.10.8 | goto e
:QueryFloodFOR | %r = 15.15.15 | goto e 
:ChatTextFloodLinesX | %r = 70.50.20 | goto e
:ChatTextFloodLinesIN | %r = 15.10.8 | goto e
:ChatTextFloodLinesFOR | %r = 60.60.60 | goto e
:ChatTextFloodCharsX | %r = 5000.4000.3000 | goto e
:ChatTextFloodCharsIN | %r = 15.10.8 | goto e
:ChatTextFloodCharsFOR | %r = 60.60.60 | goto e
:AntiSpamFOR | %r = 50.50.50
*/

alias _pprots.getOption {
  var %h = PProts- $+ $_network.active
  if (!$_hash.exists(%h)) { %h = PProts-(Default) }
  return $_script.getOption(%h,$1)
}
alias _pprots.getOptionNumber {
  var %val = $int($_pprots.getOption($1))
  if (%val isnum 1-) { return %val }
  return $_pprots.defaultValues($1,2)
}

alias _pprots.onTextEvent {

  ; Lines
  if ($_pprots.getOption(TextFloodLines)) {
    var %timer = $+(PProts^TextFloodLines^Reset,^,$cid,^,$nick) 
    if (!$timer(%timer)) { .timer $+ %timer 1 $_pprots.getOptionNumber(TextFloodLinesIN) unset $_script.variableName(PProts,TextFloodLines,Count,$cid,$nick) }
    var %curr = $_script.variableValue(PProts,TextFloodLines,Count,$cid,$nick)
    inc %curr
    if (%curr >= $_pprots.getOptionNumber(TextFloodLinesX)) { 
      .timer $+ %timer off
      unset $_script.variableName(PProts,TextFloodLines,Count,$cid,$nick) 
      _pprots.performPenalty $nick $fulladdress $_pprots.getOptionNumber(TextFloodLinesFOR) Text Flood Lines
    }
  }
}
