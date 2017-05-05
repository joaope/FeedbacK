;_____________[ services ] ________________________________________

alias _services.available { return PTnet,Undernet,DALnet }
alias _services.getFile { return }
alias _services.getInfo {
  var %net = $1, %prop = $prop
  if (%net == $null) || (%prop == $null) { return }
  goto %net

  :PTnet
  goto %prop



}


;_____________[ math ]___________________________________________

alias _math.percentage {
  var %round = $iif($3 isnum 0-,$3,3), %calc = $calc(($$1 * 100) / $$2)
  return $round($iif(%calc,%calc,0),%round) $+ $iif($4 != 0,%) 
}

;_____________[ socket ] ________________________________________

alias _socket.sockmark {
  if ($sock($1)) { var %sock = $1, %par1 = $2, %par2 = $3- }
  else { var %sock = $sockname, %par1 = $1, %par2 = $2- }
  if ($sock(%sock)) { 
    if ($isid) { 
      if (%par1 != $null) { return $gettok($sock(%sock).mark,%par1,9) }
    } 
    elseif (%par2 != $null) { sockmark %sock $puttok($sock(%sock).mark,%par2,%par1,9) }
  }
}
alias _socket.portDescription {
  if ($prop == udp) { var %f = $_script.directory(Misc,iq,PortsUPD.txt) }
  else { var %f = $_script.directory(Misc,q,PortsTCP.txt) }
  if ($read(%f,-nw,$1 * *) != $null) { return $v1 }
  return <Unknown>
}



;______________[ color ]_______________________________________

alias _color.toMircColor { 
  if ($1 isnum) { 
    var %x = $calc($1 % 16) 
    return $right($+(00,%x),2) 
  }
}
alias _color.bmpFile {
  if ($_color.buildBmpFile($1)) { return $v1 }
}
alias _color.buildBmpFiles { 
  var %x = -1 
  while (%x <= 15) { 
    _color.buildBmpFile %x 
    inc %x 
  } 
}
alias _color.buildBmpFile {
  var %col = $_color.toMircColor($1), %col = $iif(%col isnum,%col,-1), %size = $calc($dbuw * 8) $calc($dbuh * 8), %file, %win = @_temp._color.buildBmpFile
  window -c %win 
  window -hkp +d %win 0 0 %size
  .timer -mi 1 1 window -c %win
  if (%col == -1) {
    %file = $_script.directory(images,$null,-1.bmp)
    if ($isfile(%file)) { return %file }
    drawrect -fr %win 11775903 10 0 0 %size
    drawline -r %win 0 2 0 0 14 14
    drawline -r %win 0 2 14 0 0 14
    drawsave %win %file
  }
  else {
    %file = $_script.directory(images,$null,$+(%col,_,$color(%col),.bmp))
    if ($isfile(%file)) { return %file }
    else {
      var %temp = $_script.directory(images)
      __dummy $findfile(%temp,$+(%col,_,*,.bmp),0, .remove $_file.fixName($1-))
    }
    drawrect -fr %win $color(%col) 10 0 0 %size
    drawsave %win %file
  }
  if ($isfile(%file)) { return %file }
}
alias _color.actualRgbColors {
  var %x = 0, %rgb
  while (%x <= 15) { 
    %rgb = $instok(%rgb,$rgb($color(%x)),0,32) 
    inc %x 
  } 
  return %rgb
}
alias _color.default { return 0,6,4,5,2,3,3,3,3,3,3,1,5,7,6,1,3,2,3,5,1,0,1,0,1,15,6,0 }
alias _color.defaultRgb { 
  return 255,255,255 0,0,0 0,0,128 0,144,0 255,0,0 128,0,0 160,0,160 255,128,0 255,255,0,0,255,0 0,144,144 0,255,255 0,0,255 255,0,255 128,128,128 208,208,208
}
alias _color.actualColors {
  var %x = 1, %cols
  while ($gettok($_color.items,%x,44)) { 
    %cols = $instok(%cols,$color($v1),%x,44) 
    inc %x 
  } 
  return %cols 
}
alias _color.items {
  return Background,Action text,CTCP text,Highlight text,Info text,Info2 text,Invite text,Join text, $&
    $+ Kick text,Mode text,Nick text,Normal text,Notice text,Notify text,Other text,Own text,Part text,Quit text, $&
    $+ Topic text,Wallops text,Whois text,Editbox,Editbox text,Listbox,Listbox text,Gray text,Title text,Inactive
}
alias _color.loadColors {
  var %y = $numtok($1-,44), %colors = $iif($1,$1,$_color.default), %x = 1, %colitems = $_color.items, %temp = $numtok(%colitems,44)
  if (%temp < %y) || (!%y) { %y = %temp }
  while (%x <= %y) { 
    color $gettok(%colitems,%x,44) $_color.toMircColor($gettok(%colors,%x,44))
    inc %x 
  }
  if ($numtok(%colors,44) < 28) && ($v1 >= 22) { color Inactive $gettok(%colors,22,44) }  
}
alias _color.loadRgbColors {
  if ($numtok($1-,32) != 16) { _color.loadDefaultRgbColors }
  else {
    var %rgb = $1-, %x = 0, %curr
    while (%x <= 15) {
      %curr = $gettok(%rgb,$calc(%x + 1),32)
      if (*,*,* !iswm %curr) { %curr = $_color.rgbNamedColors(%curr,%x) } 
      color %x [ $rgb( [ %curr ] ) ] 
      inc %x 
    }
  }
}
alias _color.loadDefaultRgbColors {
  var %x = 0 
  while (%x <= 15) { 
    color -r %x 
    inc %x 
  }
}
alias _color.rgbNamedColors {
  ; $_color.namedColors(<name>,[N])
  ; N is the Nth color box that you're changing. Specify it if you want alias 
  ; to return default value whenever color name isn't found

  var %name = $1
  goto %name

  :Aliceblue | return 240,248,255
  :Antiquewhite | return 250,235,215
  :Aqua | return 0,255,255
  :Aquamarine | return 127,255,212
  :Azure | return 240,255,255
  :Beige | return 245,245,220
  :Bisque | return 255,228,196
  :Black | return 0,0,0
  :Blanchedalmond | return 255,235,205
  :Blue | return 0,0,255
  :Blueviolet | return 138,43,226
  :Brown | return 165,42,42
  :Burlywood | return 222,184,135
  :Cadetblue | return 95,158,160
  :Chartreuse | return 127,255,0
  :Chocolate | return 210,105,30
  :Coral | return 255,127,80
  :Cornflowerblue | return 100,149,237
  :Cornsilk | return 255,248,220
  :Crimson | return 220,20,60
  :Cyan | return 0,255,255
  :Darkblue | return 0,0,139
  :Darkcyan | return 0,139,139
  :Darkgoldenrod | return 184,134,11
  :Darkgray | return 169,169,169
  :Darkgreen | return 0,100,0
  :Darkkhaki | return 189,183,107
  :Darkmagenta | return 139,0,139
  :Darkolivegreen | return 85,107,47
  :Darkorange | return 255,140,0
  :Darkorchid | return 153,50,204
  :Darkred | return 139,0,0
  :Darksalmon | return 233,150,122
  :Darkseagreen | return 143,188,143
  :Darkslateblue | return 72,61,139
  :Darkslategray | return 47,79,79
  :Darkturquoise | return 0,206,209
  :Darkviolet | return 148,0,211
  :Deeppink | return 255,20,147
  :Deepskyblue | return 0,191,255
  :Dimgray | return 105,105,105
  :Dodgerblue | return 30,144,255
  :Firebrick | return 178,34,34
  :Floralwhite | return 255,250,240
  :Forestgreen | return 34,139,34
  :Fuchsia | return 255,0,255
  :Gainsboro | return 220,220,220
  :Ghostwhite | return 248,248,255
  :Gold | return 255,215,0
  :Goldenrod | return 218,165,32
  :Gray | return 128,128,128
  :Green | return 0,128,0
  :Greenyellow | return 173,255,47
  :Honeydew | return 240,255,240
  :Hotpink | return 255,105,180
  :Indianred | return 205,92,92
  :Indigo | return 75,0,130
  :Ivory | return 255,255,240
  :Khaki | return 240,230,140
  :Lavender | return 230,230,250
  :Lavenderblush | return 255,240,245
  :Lawngreen | return 124,252,0
  :Lemonchiffon | return 255,250,205
  :Lightblue | return 173,216,230
  :Lightcoral | return 240,128,128
  :Lightcyan | return 224,255,255
  :Lightgoldenrodyellow | return 250,250,210
  :Lightgreen | return 144,238,144
  :Lightgrey | return 211,211,211
  :Lightpink | return 255,182,193
  :Lightsalmon | return 255,160,122
  :Lightseagreen | return 32,178,170
  :Lightskyblue | return 135,206,250
  :Lightslategray | return 119,136,153
  :Lightsteelblue | return 176,196,222
  :Lightyellow | return 255,255,224
  :Lime | return 0,255,0
  :Limegreen | return 50,205,50
  :Linen | return 250,240,230
  :Magenta | return 255,0,255
  :Maroon | return 128,0,0
  :Mediumauqamarine | return 102,205,170
  :Mediumblue | return 0,0,205
  :Mediumorchid | return 186,85,211
  :Mediumpurple | return 147,112,216
  :Mediumseagreen | return 60,179,113
  :Mediumslateblue | return 123,104,238
  :Mediumspringgreen | return 0,250,154
  :Mediumturquoise | return 72,209,204
  :Mediumvioletred | return 199,21,133
  :Midnightblue | return 25,25,112
  :Mintcream | return 245,255,250
  :Mistyrose | return 255,228,225
  :Moccasin | return 255,228,181
  :Navajowhite | return 255,222,173
  :Navy | return 0,0,128
  :Oldlace | return 253,245,230
  :Olive | return 128,128,0
  :Olivedrab | return 104,142,35
  :Orange | return 255,165,0
  :Orangered | return 255,69,0
  :Orchid | return 218,112,214
  :Palegoldenrod | return 238,232,170
  :Palegreen | return 152,251,152
  :Paleturquoise | return 175,238,238
  :Palevioletred | return 216,112,147
  :Papayawhip | return 255,239,213
  :Peachpuff | return 255,218,185
  :Peru | return 205,133,63
  :Pink | return 255,192,203
  :Plum | return 221,160,221
  :Powderblue | return 176,224,230
  :Purple | return 128,0,128
  :Red | return 255,0,0
  :Rosybrown | return 188,143,143
  :Royalblue | return 65,105,225
  :Saddlebrown | return 139,69,19
  :Salmon | return 250,128,114
  :Sandybrown | return 244,164,96
  :Seagreen | return 46,139,87
  :Seashell | return 255,245,238
  :Sienna | return 160,82,45
  :Silver | return 192,192,192
  :Skyblue | return 135,206,235
  :Slateblue | return 106,90,205
  :Slategray | return 112,128,144
  :Snow | return 255,250,250
  :Springgreen | return 0,255,127
  :Steelblue | return 70,130,180
  :Tan | return 210,180,140
  :Teal | return 0,128,128
  :Thistle | return 216,191,216
  :Tomato | return 255,99,71
  :Turquoise | return 64,224,208
  :Violet | return 238,130,238
  :Wheat | return 245,222,179
  :White | return 255,255,255
  :Whitesmoke | return 245,245,245
  :Yellow | return 255,255,0
  :YellowGreen | return 154,205,50
  :%name
  if ($2 isnum 0-) && ($gettok($_colors.defaultRgb,$calc($2 + 1),32)) { return $v1 }
}


;______________[ channel ]________________________________________

alias _channel.controlMode {
  ; /_channel.controlMode <+o|+v|-o|-v> <channel> <nick1> [nickN]
  var %sig = $left($1,1), %mode = $right($1,1), %chan = $2, %nicks = $replace($3-,$chr(44),$chr(32)), %max = $modespl, %i, %x = 1
  if (%chan !ischan) || (!$_channel.meOp(%chan)) || (%nicks == $null) { return }
  while ($_string.divideToken(%nicks,%max,%x,32) != $null) {
    %i = $v1
    .raw MODE %chan $+(%sig,$str(%mode,$numtok(%i,32))) %i
    inc %x
  }
} 
alias _channel.partChannelMenu {
  if ($1 !isnum) { return }
  var %total = $chan(0)
  if ($1 > %total) {
    if ($calc(%total + 1) == $1) { return - }
    if ($calc(%total + 2) == $1) { return $iif(!$chan(0),$style(2)) &All... $_advanced.commandOnMenu(partall) : partall }
  }
  else {
    return $chan($1) : part $chan($1)
  }
}
alias _channel.massKickBan {
  ; /_channel.massKickBan <channel> <nicks_affected>
  var %chan = $1, %x = 1, %affected = $2, %i, %kicks, %msg = $iif($3 != $null,$3-,$_script.logo - Mass kick!), %max = $modespl, %addrs
  if (%chan !ischan) || (!$_channel.meOp(%chan)) { return }
  while ($nick(%chan,%x,%affected) != $null) {
    %i = $v1
    if (%i != $me) { 
      %kicks = $addtok(%kicks,KICK %chan %i $+(:,%msg),10)
      %addrs = %addrs $address(%i,3)
    }
    if ($numtok(%addrs,32) == %max) {
      .raw $+(%kicks,$lf,MODE) %chan $+(+,$str(b,%max)) %addrs
      %kicks = ""
      %addrs = ""
    } 
    inc %x
  }
  if (%kicks) && (%addrs) { .raw $+(%kicks,$lf,MODE) %chan $+(+,$str(b,$numtok(%addrs,32))) %addrs }
}
alias _channel.massKick {
  ; /_channel.massKick <channel> <nicks_affected>
  var %chan = $1, %x = 1, %affected = $2, %i, %kicks, %msg = $iif($3 != $null,$3-,$_script.logo - Mass kick!)
  if (%chan !ischan) || (!$_channel.meOp(%chan)) { return }
  while ($nick(%chan,%x,%affected) != $null) {
    %i = $v1 
    if (%i != $me) { %kicks = $addtok(%kicks,KICK %chan %i $+(:,%msg),10) }
    if ($len(%kicks) > 800) {
      .raw %kicks
      %kicks = ""
    } 
    inc %x
  }
  if (%kicks) { .raw %kicks }
}
alias _channel.massMode {
  ; /_channel.massMode <channel> <mode> <nicks_affected>
  var %chan = $1, %signal = $iif(+ isin $2,+,-), %mode = $left($remove($2,+,-),1), %affected = $3, %nicks, %x = 1, %i, %max = $modespl
  if (%chan !ischan) || (!$_channel.meOp(%chan)) { return }
  while ($nick(%chan,%x,%affected) != $null) {
    %i = $v1
    if (%i != $me) { %nicks = %nicks %i }
    if ($numtok(%nicks,32) == %max) {
      .raw MODE %chan $+(%signal,$str(%mode,%max)) %nicks 
      %nicks = ""
    }
    inc %x
  }
  if (%nicks != $null) { .raw MODE %chan $+(%signal,$str(%mode,$numtok(%nicks,32))) %nicks }
}
alias _channel.which { return $iif($_channel.fixName($1) ischan,$1,$active) }
alias _channel.common {
  var %nick = $1, %x = 1, %c, %i
  while ($comchan(%nick,%x)) {
    %i = $v1
    if (%nick isowner %i) {
      %i = . $+ %i
    }
    elseif (%nick isop %i) {
      %i = @ $+ %i
    }
    elseif (%nick isvo %i) {
      %i = + $+ %i
    }
    %c = $addtok(%c,%i,32)
    inc %x
  }
  if ($prop == noSort) { return %c }
  return $_channel.sortChannels(%n,%c)
}
alias _channel.sortChannels {
  var %c = $iif($_goptions.get(ShowAlphabeticSortedChannels),$sorttok($2-,32),$2-), %x = $numtok(%c,32), %channels 
  if ($1 == $me) { return %c }
  while (%x) {
    var %chan = $_channel.fixName($right($gettok(%c,%x,32),-1))
    if (%chan ischan) { %channels = $iif($prop == noBold,%c,$+(,$gettok(%c,%x,32),)) %channels } 
    else { %channels = $gettok(%c,%x,32) %channels } 
    dec %x 
  } 
  return %channels
}
alias _channel.fixName { return $iif($left($1,1) isincs $chantypes,$1,$+($left($chantypes,1),$1)) }
alias _channel.meOp {
  var %chan = $_channel.fixName($1)
  if ($me isop %chan) || (o isin $usermode) || ($me ishop %chan) { return 1 }
}
alias _channel.isInBanList {
  if ($1 ischan) && ($2) { 
    var %x = 1 
    while ($ibl($1,%x)) { 
      if ($v1 == $2) { return 1 } 
      inc %x 
    } 
  }
}
alias _channel.nicksMatchingAddress {
  var %x = 1, %chan = $1, %add = $2, %y = $iif($int($3) isnum 0-,$v1,10000), %bnicks, %total = $ialchan(%add,%chan,0).nick, %listed
  if (%y == 0) { return %total }
  else {
    while (%x <= %y && $len(%bnicks) < 800 && $ialchan(%add,%chan,%x).nick != $null) {
      %bnicks = $addtok(%bnicks,$v1,32)
      inc %x
      inc %listed
    }
    return %bnicks $iif($prop == etc && %total > %listed,...)
  }
}
alias _channel.delayMessages {
  var %cmd = $1, %text = $2-, %delay = 1, %x = 1
  while ($chan(%x)) {
    .timer 1 $calc((%x + 1) * %delay) %cmd $v1 %text
    inc %x
  }
}
alias _channel.nicksMatchingString {
  if ($isid) {
    if ($2 == $null) { return }
    var %chan = $1, %wc = $2
  }
  else {
    if ($1 != $null) { 
      var %chan = $active, %wc = $1
    } 
    else { 
      _themes.sintaxEcho nm <parameter>
      return
    }
  }
  if (%chan !ischan) { return }
  var %x = 1,%nicks, %i
  while ($nick(%chan,%x)) {
    %i = $v1
    if (%wc iswm %i) { %nicks = $addtok(%nicks,%i,44) }
    inc %x
  }
  if ($isid) { return %nicks }
  _themes.commandEcho nm Searching for nick matchs on %chan $+ :
  var %x = 1, %f = 0, %total = $numtok(%nicks,44), %s = $iif(%total != 1,s), %i
  while ($gettok(%nicks,%x,44)) {
    %i = $v1
    _themes.commandEcho nm $+(%x,.) $iif(%i == $me,$+(,%i,),%i)
    inc %x 
  }
  _themes.commandEcho nm Scan complete ( $+ $iif(!%total,No matchs found,%total matching nick $+ %s found) $+ ).
}

alias _channel.listModesOnMenu {
  if ($1 !isnum) { return }
  var %modes = t.n.i.m.p.s, %names = Only ops set &topic.&No external messages.&Invite only.&Moderated.&Private.&Secret, %cmodes = $gettok($chan($active).mode,1,32)
  if ($gettok(%modes,$1,46)) {
    var %_m = $v1
    return $iif(%_m isincs %cmodes,$style(1)) $gettok(%names,$1,46) $chr(9) $_string.surrounded(%_m) : mode $active $iif(%_m isincs %cmodes,$+(-,%_m),$+(+,%_m))
  } 
  var %i = $numtok(%modes,46)
  if ($1 == $calc(%i + 1)) { return - }
  if ($1 == $calc(%i + 2)) {
    if (k isincs %cmodes) { return $style(1) &Key... $chr(9) $_string.surrounded(k $chan($active).key) : mode $active -k $chan($active).key }
    return &Key... $chr(9) $_string.surrounded(k $chan($active).key) : mode $active +k $!_prompt.input(New channel key for $active $+ :" $chan($active).key "Channel Modes"tch"ChannelModeChangeKey)
  }
  if ($1 == $calc(%i + 3)) {
    if (l isincs %cmodes) { return $style(1) &Limit... $chr(9) $_string.surrounded(l $chan($active).limit) : mode $active -l }
    return &Limit... $chr(9) $_string.surrounded(l $chan($active).limit) : mode $active +l $!_prompt.input(New channel limit for $active $+ :" $chan($active).limit "Channel Modes"tch"ChannelModeChangeLimit)
  }
  if ($1 == $calc(%i + 4)) { return - }
  if ($1 == $calc(%i + 5)) { return $iif(!%cmodes,$style(2)) &Clean all modes $chr(9) $_string.surrounded($chan($active).mode) : mode $active $replace($chan($active).mode,+,-) }
  if ($1 == $calc(%i + 6)) { return Set &others... : mode $active $!_prompt.input(New channel modes (Eg.: +modes-modes):"~"Channel Modes"tch"SetOtherChannelModes) }
}



;_____________[ strings ]_________________________________________

alias _string.toBold { return $+(,$1-,) }
alias _string.isChat {
  if ($chat($remove($1-,=))) { return 1 }
}
alias _string.isHost {
  if ($remove($1,.,_,-) isalnum) && ($chr(32) !isin $1) { return $1 }
}
alias _string.isUrl {
  if ($numtok($1-,46) > 1) && (($left($1-,7) == http:\\) || ($left($1-,7) == http://) || ($left($1-,4) == www.)) { return 1 }
}
alias _string.surrounded { return $iif($1 != $null,$+($chr(40),$1-,$chr(41))) }
alias _string.areValidFlags {
  if ($2 == $null) { return } 
  var %flags = $remove($1,-), %_flags = $remove($2,-), %x = 1 
  while ($mid(%flags,%x,1)) { 
    if ($v1 !isincs %_flags) { return }
    inc %x 
  } 
  return 1
}
alias _string.compressNumberToExtend {
  var %1 = $gettok($1,1,45), %2 = $gettok($1,2,45), %chr = $iif($2 isnum,$2,44), %string
  if (%1 isnum) && (%2 isnum) {
    while (%1 <= %2) {
      %string = $addtok(%string,%1,%chr)
      inc %1
    }
    return %string
  }
  return $1-
}
alias _string.removeNumbers { return $remove($1-,0,1,2,3,4,5,6,7,8,9) }
alias _string.wildtokPosition {
  if ($0 < 4) { return }
  var %w = $wildtok($1,$2,$3,$4)
  if ($3 == 0) { return %w }
  return $findtok($1,%w,$3,$4)
}
alias _string.wildcarded {
  var %w = $replace($1-,$chr(32),*) 
  return $+(*,%w,*)
}
alias _string.compare {
  if ($0 < 2) { return }
  else {
    var %x = 1, %len1 = $len($1), %len2 = $len($2), %div, %div2_upper, %div2
    if (%len2 > %len1) { %div = %len2 }
    else { %div = %len1 }
    while ($mid($1,%x,1)) {
      var %mid1 = $v1, %mid2 = $mid($2,%x,1)
      if (%mid1 == %mid2) { 
        inc %div2 
        if (%mid1 === %mid2) { inc %div2_upper }
      }
      inc %x
    }
    if (r* iswm $3) { %round = $right($3,-1) }
    elseif (*r* iswm $3) { %round = $gettok($3,2,114) }
    var %round = $iif(%round isnum 0-,$v1,3)
    return $round($calc(($iif(c isin $3,%div2_upper,%div2) / %div) * 100),%round) $+ $iif(p isin $3,%)
  }
}
alias _string.capitalize {
  if ($prop == all) { 
    var %x = 1, %text = ""
    tokenize 32 $1-
    while ($eval($+($,%x),2) != $null) {
      var %wd = $v1, %text = %text $+($upper($left(%wd,1)),$iif($len(%wd) != 1,$lower($right(%wd,-1))))
      inc %x
    }
    return %text
  } 
  if ($prop == first) { return $+($upper($left($1,1)),$iif($len($1) != 1,$lower($right($1,-1)))) $lower($2-) }
}
alias _string.divideToken {
  if ($4) {
    ;     $_string.divideToken(<text>,<number>,<position>,<C>) 
    var %p1 = $calc($2 * $3 - ($2 - 1)), %p2 = $calc($2 * $3) 
    return $gettok($1,$+(%p1,-,%p2),$4) 
  }
}



;______________[ script ]________________________________________

alias _script.publicAliases {
  ; Internal alias to list all public aliases available. Nice to write commands help file!
  var %win = @_temp._script.publicAliases, %x = 1, %coms
  _window.open -hs %win
  while ($_script.file(%x)) {
    filter -fw $v1 %win alias & $chr(123) $+ *
    inc %x
  }
  %x = 1
  while ($line(%win,%x)) {
    tokenize 32 $v1
    if (_* !iswm $2) { %coms = $addtok(%coms,$2,126) }
    inc %x
  }
  return $sorttok(%coms,126)
}
alias _script.featureNotAvailable { _prompt.info Feature not yet added. $+ $crlf $crlf $+ Please check last news through script website (/home) to see last available version and features added. $+ $crlf $crlf $+ Current script version : $_script.version " $+ $1 }
alias _script.prepareFirstRuntime {
  ; Reset all settings because first runtime wizard will ask user to set them to default
  ; Theme is reseted to and will be asked on first runtime too.
  settings -r
  unset %*
  set $_script.variableName(Script,First,Runtime) 1
}
alias _script.isFirstRuntime {
  var %i = $_script.variableValue(Script,First,Runtime)
  unset $_script.variableName(Script,First,Runtime)
  return %i
}
alias _script.supportedMircVersion { return 6.16 }
alias _script.whatsnewFile { return $_file.fixName($+($mircdir,Whatsnew.txt)) }
alias _script.name { return FeedbacK }
alias _script.logo { return FeedbacK }
alias _script.version { return 3.00b2 }
alias _script.versionTime { return 1120526249 }
alias _script.author { return Mal-Functi }
alias _script.email { return jotex@sapo.pt }
alias _script.home { return http:\\www.feedbackscript.has.it }
alias _script.getOption { return $hget($_hash.prefixed($1),$2) }
alias _script.deleteRecentOption {
  if ($1 != $null) && ($2 != $null) && ($int($1) isnum 1-) { 
    var %n = $v1
    _script.setOption $2 $3 $deltok($_script.getOption($2,$3),%n,59)
  }
}
alias _script.quote { return Always try to survive. To live is no funny anymore. } 
alias _script.setRecentOption {
  ; <N> <hash> <item> <data>
  if ($0 < 4) { return }
  var %data = $remtok($_script.getOption($2,$3),$4-,59)
  if ($1 == 0) { _script.setOption $2-3 $+($4-,;,%data) }
  else {
    %data = $gettok(%data,$+(1-,$1),59)
    if ($numtok(%data,59) == $1) { _script.setOption $2-3 $+($4-,;,$deltok(%data,$1,59)) }
    else { _script.setOption $2-3 $+($4-,;,%data) }
  } 
}
alias _script.setOption {
  var %h = $_hash.prefixed($1)
  if ($2 == $null) { 
    if ($hget(%h)) { hfree %h }
  }
  elseif ($3 == $null) { 
    if ($hget(%h)) { hdel %h $2 }
  } 
  else { 
    if (!$hget(%h)) { hmake %h 15 }
    hadd %h $2- 
  }
}
alias _script.variableName { return $+(%,+_,$replace($1-,$chr(32),.)) }
alias _script.variableValue { return $eval($+(%,+_,$replace($1-,$chr(32),.)),2) }
alias _script.directory {
  ;  Used to return script directories (all but profile ones)
  ; $_script.directory(<type>,<flags>,[file])
  ;     Flags:
  ;               i  - returns dir only if it exists
  ;               q  - returns dir without quotes (")
  ;     
  ;     [file] is added to directory string
  ;     Types available (if full name isn't specified the first partial match is used):
  ;              - images - All media files
  ;              - temporary - Temporary-that-can-be-safely-deleted files
  ;              - misc - All other files
  ;              - themes - Default themes directory
  ;              - cache - Cached files like previews and infos
  ;              - services - Network services files
  ;              - script - Script files

  var %dir, %flags = $2
  if ($_string.wildtokPosition(images temporary misc themes cache services script,$_string.wildcarded($1),1,32)) { 
    var %pos = $v1, %dirs = Script\Images\?Script\Temporary\?Script\Misc\?Themes\?Script\Cache\?Script\Services\?Script\, %dir = $mircdir $+ $gettok(%dirs,%pos,63), %dirf = %dir $+ $3-
  }
  if (i isincs %flags) && (!$exists(%dirf)) { return }
  _file.makeDirectory %dir
  if (q isincs %flags) { return %dirf }
  return $_file.fixName(%dirf)
}
alias _script.file {
  var %total = 10
  if ($1 == 0) { return %total }
  elseif ($int($1) isnum $+(1-,%total)) {
    var %n = $v1, %f = $+(Script,$calc(%n - 1),.mrc)
    return $_script.directory(Script,$null,%f)
  }
}


;______________[ hash ]________________________________________

alias _hash.string {
  var %hashs = $1-, %y = 1
  while ($gettok(%hashs,%y,32)) {
    var %i = $v1, %string = $addtok(%string,$_hash.prefixed(%i),32)
    inc %y
  }
  return %string
}
alias _hash.exists { return $hget($_hash.prefixed($1)) }
alias _hash.isPrefixed {
  if (FB-* iswm $1) { return $true }
}
alias _hash.prefixed {
  var %h = $1
  if (FB-* iswm %h) || (%h == $null) { return %h }
  return $+(FB-,%h)
}
alias _hash.notPrefixed { return $iif(FB-* iswm $1,$gettok($1,2-,45),$1) }
alias _hash.toHash {
  ; /_hashs.toHash [-o] <From hash> <To hash>
  if (-* iswm $1) { var %flags = $1, %hash1 = $2, %hash2 = $3 }
  else { var %flags, %hash1 = $1, %hash2 = $2 } 
  if (%hash1 == $null) || (%hash2 == $null) { return }
  var %hash1 = $_hash.prefixed(%hash1), %hash2 = $_hash.prefixed(%hash2)
  if ($hget(%hash1)) {
    if (!$hget(%hash1,0).item) {
      if ($hget(%hash2)) { hfree %hash2 }
    }
    else {
      if (o isincs %flags) && ($hget(%hash2)) { hfree %hash2 }
      var %x = 1
      while ($hget(%hash1,%x).item) {
        hadd -m %hash2 $v1 $hget(%hash1,%x).data
        inc %x
      }
    }
  }
}
alias _hash.allMatching {
  var %chr = 32, %exclude = $_hash.string($2), %exclude2 = $_hash.prefixed($3), %text = $_hash.prefixed($1), %x = 1, %ret
  while ($hget(%x)) {
    var %i = $v1
    if ($_hash.isPrefixed(%i)) { 
      if (%text iswm %i) && (!$istok(%exclude,%i,32)) && (%exclude2 !iswm %i) { %ret = $addtok(%ret,%i,%chr) }
    }
    inc %x
  }
  return %ret
}
alias _hash.fromIni {
  ;     Usage:    /_hash.fromIni [-s] <handler> <inifile> <dir> [<exclude wildcard> <exclude strings>]
  if (-* iswm $1) {
    if ($isalias($iif(.* iswm $2,$right($2,-1),$2))) { var %handler = $2 }
    var %file = $_file.fixName($3), %dir = $_file.fixName($4), %flags = $1, %excludeW = $_hash.prefixed($5), %excludeS = $_hash.string($6-)
  } 
  else { 
    if ($isalias($iif(.* iswm $1,$right($1,-1),$1))) { var %handler = $1 } 
    var %file = $_file.fixName($2), %dir = $_file.fixName($3), %excludeW = $_hash.prefixed($4), %excludeS = $_script.string($5-)
  }
  %dir = $remove(%dir,")
  if ($isfile(%file)) && ($3) {
    if (%dir) && (!$isdir(%dir)) { _file.makeDirectory %dir }
    if (%handler) { $v1 INI2HASH Start compilation... }
    var %x = 1, %y = $ini(%file,0)
    while (%x <= %y) {
      var %x2 = 1, %y2 = $ini(%file,%x,0), %topic = $ini(%file,%x), %hash_name = $_hash.prefixed(%topic)
      if (%handler) { $v1 INI2HASH Progress %hash_name %x %y }
      if (%excludeW iswm %hash_name) || ($istok(%excludeS,%hash_name,32)) { goto inc }
      while (%x2 <= %y2) {
        var %item = $ini(%file,%x,%x2)
        hadd -m %hash_name %item $_mirc.tagToControlCode($readini(%file,%topic,%item))
        inc %x2

      }
      if (s isin %flags) { hsave -o %hash_name %dir $+ \ $+ %hash_name $+ .hsh }
      :inc
      inc %x
    }
    if (%handler) { 
      $v1 INI2HASH Finished 
      return 1
    }
  }
  elseif (%handler) { $v1 INI2HASH_ERR No ini file }
}
alias _hash.toIni {
  ;     Usage:     /_hash.toIni <handler> <hashsdir> <inifile> [<exclude wildcard> <exclude strings>]
  if ($isalias($iif(.* iswm $1,$right($1,-1),$1))) { var %handler = $1 } 
  var %dir = $_file.fixName($2), %ini = $_file.fixName($3), %excludeW = $_hash.prefixed($4), %excludeS = $_hash.string($5-)
  var %total = $findfile(%dir,*.hsh,0), %x = 1
  if (!%total) { 
    if (%handler) { $v1 HASH2INI_ERR No hash tables }
  }
  else {
    if (%handler) { $v1 HASH2INI Start compilation... }
    write -c %ini
    while ($findfile(%dir,*.hsh,%x)) {
      var %x2 = 1, %file = $v1, %hash_name = $left($nopath(%file),-4)
      if (%handler) { $v1 HASH2INI Progress %hash_name %x %total }
      if ($istok(%excludeS,%hash_name,32)) || (%excludeW iswm %hash_name) { goto inc }
      while ($hget(%hash_name,%x2).item) {
        var %item = $v1
        var %data = $hget(%hash_name,%item)
        if (%data != $null) { writeini -n %ini %hash_name %item $_mirc.controlCodeToTag(%data) }
        inc %x2
      }
      :inc
      inc %x
    }
    if (%handler) { $v1 HASH2INI Finished }
  }
}


;______________[ titlebar ]__________________________________________

alias _titlebar.items {
  if ($1 isnum 1-15) { goto $v1 } 
  return
  :1 | return [[ $+ $me $+ ] 
  :2 | return [[ $+ $usermode $+ ] 
  :3 | return [[ $+ $iif($_lag.time,$v1 $+ secs,??) $+ ]
  :4 | return [[ $+ $iif($_network.active,$v1,none) $+ ] 
  :5 | return [[ $+ $active $+ ]
  :6 | return $iif($away,[Away],[Not Away])
  :7 | return [[ $+ $duration($scid($activecid).idle) $+ ]
  :8 | return [[ $+ $asctime(HH:nn:ss) $+ ]
  :9 | return [[ $+ $uptime(system,2) $+ ]
  :10 | return [[ $+ $uptime(server,2) $+ ]
  :11 | return [[ $+ $uptime(mirc,2) $+ ]
  :12 | return [[ $+ $date $+ ]
  :13 | return [[ $+ $_script.name $+ ]
  :14 | return [[ $+ $_profiles.currentLoaded $+ ]
  :15 | if ($active ischan) { return [[ $+ $nick($active,0) - $+(@,$nick($active,0,o),\,$chr(37),$nick($active,0,h),\,+,$nick($active,0,v),\,$nick($active,0,r)) $+ ] }
}
alias _titlebar.updateTime { return $iif($int($_goptions.get(UpdateTitlebarEvery)) isnum 1-,$v1,3) }
alias _titlebar.work {
  var %time = $_titlebar.updateTime
  if (!$timer(TITLEBAR)) || (%time != $timer(TITLEBAR).delay) { .timerTITLEBAR -i 0 %time _titlebar.work }
  if (!$server) { titlebar - $_script.name (disconnected) }
  else { 
    if ($_goptions.get(UpdateTitlebar)) && ($_titlebar.data != $null) { titlebar - $v1 }
    else { titlebar - $_script.name (connected) }
  }
}
alias _titlebar.data {
  return $replace($_goptions.get(TitlebarText),<nick>,$_titlebar.items(1),<usermode>,$_titlebar.items(2),<lag>,$_titlebar.items(3),<network>,$_titlebar.items(4), $&
    <active window>,$_titlebar.items(5),<away status>,$_titlebar.items(6),<idle>,$_titlebar.items(7),<time>,$_titlebar.items(8),<system uptime>,$_titlebar.items(9), $&
    <server uptime>,$_titlebar.items(10),<mirc uptime>,$_titlebar.items(11),<date>,$_titlebar.items(12),<script name>,$_titlebar.items(13),_,$chr(32),<profile>,$_titlebar.items(14), $&
    <channel statistics>,$_titlebar.items(15))
}



;______________[ network ]__________________________________________

alias _network.cidIsActive {
  var %cid = $iif($1 isnum,$1,$cid)
  if (%cid == $activecid) { return 1 }
}
alias _network.active {
  if (!$server) { return }
  if ($network != $null) && ($v1 !isnum) { return $v1 }
  if ($server($server).group != $null) && ($v1 !isnum) { return $v1 }
  if ($_network.serverAssociatedToNetwork($server) != $null) { return $v1 }
  if ($1 == ask) && ($_prompt.confirmation(You need to associate current server with a network in order to continue. Associate now?)) { return $_prompt.associateServerToNetwork } 
  if ($1 != ask) || (!$server) { return (Default) }
}
alias _network.getAll {
  var %win = @_temp._network.getAll, %x = 1, %i, %total = $server(0)
  if ($window(%win)) { return %win }
  elseif (!%total) { return }
  window -hsl %win
  _progress.inc 0 0 Listing available networks...
  while ($server(%x).group) {
    %i = $v1
    if (%i !isnum) && (!$fline(%win,%i,1)) { aline %win %i }
    _progress.inc %x %total
    inc %x
  }
  return %win
}
alias _network.identifierString {
  var %ident = $$1, %chr = $iif($2 isnum,$2,32), %x = 1, %str, %y = $scon(0)
  while (%x <= %y) {
    %str = $addtok(%str,$scon(%x). [ $+ [ %ident ] ],%chr)
    inc %x
  }
  return %str
}


;______________[ prompt ]__________________________________________

;; Select directory
alias _prompt.selectDirectory {
  var %hash = PromptSelDirectory, %dir = $iif($isdir($1),$1,$mircdir), %title = $iif($2 != $null,$2,Select directory), %item = $3
  if ($_file.isDirectory($_script.getOption(%hash,%item))) { %dir = $v1 }
  var %temp = $sdir(%dir,%title)
  if (%item != $null) && ($isdir(%temp)) { _script.setOption %hash %item %temp }
  return %temp
}
;; Select file
alias _prompt.selectFile {
  var %hash = PromptSelFile, %dir = $iif($isdir($1),$1,$mircdir), %title = $iif($2 != $null,$2,Select file), %item = $3
  if ($_file.isDirectory($_script.getOption(%hash,%item))) { %dir = $v1 }
  var %temp = $sfile(%dir,%title,&Select), %nofile = $nofile(%temp)
  if (%item != $null) && ($isdir(%nofile)) { _script.setOption %hash %item %nofile }
  return %temp
}
;;Select font
alias _prompt.selectFont {
  var %win = @_temp._prompt.selectFont
  window -pfh +d %win 50 50 1 1 cancel 13
  if ($1) { font $iif(b isin $3,-b) %win $2 $1 }
  window -a %win
  font
  if ($window(%win).font == cancel) {
    window -c %win
    return
  }
  if ($prop == font) { return %font }
  if ($prop == size) { return %size }
  if ($prop == bold) { return $iif($window(%win).fontbold,$true,$false) }
  .timer -mi 1 0 window -c %win
  return $window(%win).font $+ , $+ $window(%win).fontsize $iif($window(%win).fontbold,$+ $chr(44) $+ bold)
}

;;Error
alias _prompt.error {
  var %text = $gettok($1-,1,34), %tbar = $iif($gettok($1-,2-,34),$v1,$_script.name) - ERROR
  if (%text != $null) { .timer -m 1 0 __dummy $input(%text,owdu,%tbar) }
}
;;Info
alias _prompt.info {
  var %text = $gettok($1-,1,34), %tbar = $iif($gettok($1-,2-,34),$v1,$_script.name) - Info
  if (%text != $null) { .timer -m 1 0 __dummy $input(%text,oidu,%tbar) }
}
;;Add Network
dialog _prompt.addNetwork {
  title "Add network"
  size -1 -1 119 46
  option dbu
  box "", 1, 2 1 115 27
  button "&Select", 2, 34 32 40 11, default ok
  button "&Cancel", 3, 76 32 40 11, cancel
  combo 4, 7 10 105 110, result sort size edit drop
}
alias _prompt.addNetwork {
  var %dname = _prompt.addNetwork, %net
  set -u0 $_script.variableName(Prompt,AddNetwork,Titlebar) $iif($1 != $null,$1-,$_script.name) - Add network
  if ($dialog(%dname)) { return }
  %net = $dialog(%dname,%dname,-4)
  if (%net != $null) { return $gettok($v1,1,32) }
  if ($prop != go) { halt } 
}
on *:DIALOG:_prompt.addNetwork:*:*:{
  if ($devent == init) {
    dialog -t $dname $_script.variableValue(Prompt,AddNetwork,Titlebar)
    if ($_network.getAll) { filter -wo $v1 $dname 4 }
    if ($didwm(4,$_network.active)) { did -c $dname 4 $v1 }
    else { did -c $dname 4 1 }
  }
  elseif ($devent == edit) && ($did == 4) { did $iif($did(4) != $null,-e,-b) $dname 2 }
}
;; Yes / No confirmation
alias _prompt.yesNo { 
  var %text = $gettok($1-,1,34), %tbar = $iif($gettok($1-,2-,34),$v1,$_script.name) - Confirmation
  if (%text != $null) { return $input(%text,yqu,%tbar) }
}
;; Yes / No / Cancel question
alias _prompt.yesNoCancel { 
  var %text = $gettok($1-,1,34), %tbar = $iif($gettok($1-,2-,34),$v1,$_script.name) - Question
  if (%text != $null) { return $input(%text,nqvu,%tbar) }
}
;; Input number
dialog _prompt.inputNumber {
  title "Input number"
  size -1 -1 212 70
  option dbu
  box "", 1, 4 3 203 44
  scroll "", 2, 11 23 147 8, horizontal
  edit "", 3, 161 22 39 11, result autohs right
  text "Select number:", 4, 11 13 188 8
  text "<Min>", 5, 12 34 57 8
  text "<Max>", 6, 132 34 25 8, right
  button "&Ok", 100, 125 53 40 11, ok
  button "&Cancel", 99, 167 53 40 11, cancel
  edit "", 1000, 0 0 0 0, hide disable autohs
}
on *:DIALOG:_prompt.inputNumber:*:*:{
  if ($devent == EDIT) {
    if ($did(3) isnum $did(1000)) { var %sel = $v1 }
    elseif ($did(3) == $null) {
      %sel = $gettok($did(1000),1,45)
      did -ra $dname 3 %sel
    }
    else { 
      did -ra $dname 3 $left($did(3),-1)
      %sel = $did(3)
    }
    did -c $dname 2 %sel
  }
  elseif ($devent == SCROLL) { did -ra $dname 3 $did(2).sel }
  elseif ($devent == INIT) {
    _prompt.inputNumberFill
  }
  elseif ($devent == SCLICK) && ($did == 100) { set $_script.variableName(Prompt,InputNumber,Return) $did(2).sel }
}
alias _prompt.inputNumber {
  ; Usage: $_prompt.inputNumber(<MinRange>,<MaxRange>,<NumberToSelect>,<-h>,<InforText>,<TitleText>)
  if ($isid) {
    unset $_script.variableName(Prompt,InputNumber,Return)
    set -u0 $_script.variableName(Prompt,InputNumber,Infos) $+($1,",$2,",$3,",$4,",$5,",$6)
    __dummy $dialog(_prompt.inputNumber,_prompt.inputNumber,-4)
    return $iif($_script.variableValue(Prompt,InputNumber,Return) isnum $+($1,-,$2),$v1,$iif(h !isin $4,$3))
  }
}
alias -l _prompt.inputNumberFill {
  var %d = _prompt.inputNumber
  tokenize 34 $_script.variableValue(Prompt,InputNumber,Infos)
  did -ra %d 4 $5
  did -ra %d 5 $1
  did -ra %d 6 $2
  dialog -t %d $6
  did -z %d 2 $1 $2
  var %sel = $iif($int($3) isnum $+($1,-,$2),$v1,$1)
  did -c %d 2 %sel
  did -a %d 3 %sel
  did -ra %d 1000 $+($1,-,$2)
}

;; Select color
alias _prompt.selectColor {
  if ($isid) {
    set -u $_script.variableName(Prompt,SColor,Current) $_color.bmpFile($iif($1 isnum 0-,$1,-1))
    __dummy $dialog(_prompt.scolor,_prompt.scolor,-4) 
    if ($_script.variableValue(Prompt,SColor,Return) isnum) { return $iif($v1 isnum 0-,$_color.toMircColor($v1),-1) }
    else { return $1 }
  }
}
dialog _prompt.scolor {
  title "Select color"
  size -1 -1 60 43
  option dbu
  box "", 1, 1 26 58 4
  icon 2, 1 2 9 9,  $mircexe, 0, noborder
  icon 3, 8 2 9 9,  $mircexe, 0, noborder
  icon 4, 15 2 9 9,  $mircexe, 0, noborder
  icon 5, 22 2 9 9,  $mircexe, 0, noborder
  icon 6, 29 2 9 9,  $mircexe, 0, noborder
  icon 7, 36 2 9 9,  $mircexe, 0, noborder
  icon 8, 43 2 9 9,  $mircexe, 0, noborder
  icon 9, 50 2 9 9,  $mircexe, 0, noborder
  icon 10, 1 9 9 9,  $mircexe, 0, noborder
  icon 11, 8 9 9 9,  $mircexe, 0, noborder
  icon 12, 15 9 9 9,  $mircexe, 0, noborder
  icon 13, 22 9 9 9,  $mircexe, 0, noborder
  icon 14, 29 9 9 9,  $mircexe, 0, noborder
  icon 15, 36 9 9 9,  $mircexe, 0, noborder
  icon 16, 43 9 9 9,  $mircexe, 0, noborder
  icon 17, 50 9 9 9,  $mircexe, 0, noborder
  text "None:", 20, 33 20 15 6, disable
  icon 21, 50 19 9 9,  $mircexe, 0, noborder
  text "Current:", 22, 29 32 20 6, disable
  icon 23, 50 31 9 9,  $mircexe, 0, noborder
  button "", 25, 0 0 0 0, hide disable cancel
}
on *:DIALOG:_prompt.scolor:*:*:{
  if ($devent == INIT) { 
    dialog -s $dname $mouse.mx $calc($mouse.my + 60) -1 -1
    var %x = 0
    while (%x <= 15) {
      did -g $dname $calc(%x + 2) $_color.bmpFile(%x)
      inc %x
    }
    did -g $dname 21 $_color.bmpFile(-1)
    did -g $dname 23 $_script.variableValue(Prompt.SColor,Current)
  }
  elseif ($devent == SCLICK)  {
    var %col
    if ($did isnum 2-17) { %col = $calc($did - 2) }
    elseif ($did == 21) { %col = -1 }
    else { %col = }
    set -u1 $_script.variableName(Prompt,SColor,Return) %col
    dialog -x $dname
  }
}
;;Input
dialog -l _prompt.input {
  title "Input text"
  size -1 -1 255 51
  option dbu

  text "", 50, 5 5 245 14

  combo 1, 5 20 245 100, drop edit hide disable  ;; COMBO TEXT
  combo 2, 5 20 245 100, drop edit hide disable  ;; COMBO NUMBERS
  edit "", 3, 5 20 245 11, autohs hide disable     ;; EDIT TEXT
  edit "", 4, 5 20 245 11, autohs hide disable     ;; EDIT NUMBERS
  edit "", 5, 5 20 245 11, autohs hide disable     ;; EDIT PASSWORDS

  button "&Ok", 100, 168 35 40 11, ok disable
  button "&Cancel", 99, 210 35 40 11, cancel

  button "", 98, 244 14 5 5, disable
}
alias _prompt.input {
  ; Usage: $_prompt.input(<Description>"<PossibleText>"<Titlebar>"<tnpcdwhiN>"[Wildcard]"[Hash])
  ; Flags:
  ;     t   - Regular text can be inputed
  ;     n  - Only numbers can be inputed (negative and/or with floating point)
  ;     p  - Same as regular text but for passwords (combo doesn't work here because you can't view inputed text)
  ;     c  - A combo is showed instead of an editbox listing all recent itens inputed (an hash with that itens was to be specified)
  ;     d  - Don't disable 'Ok' button if no text inputed
  ;     w - Returns inputed text only if it matches with specified [Wildcard]
  ;     h  - Halts script if text is null
  ;     iN - Inputed text can't be longer that N words
  ; Notes:
  ;     1  - Need parameters, rounded by <> can be replaced by '~' and default parameters will be used
  ;     2  - Will be added 'Prompt-' before hash name (if [hash] it's 'NicksToIdentify' hash will be called Prompt-NicksToIdentify)
  ;     3  - Default input it's always a text editbox (-t)
  ;     4  - (X) *SHIT Very important* I have no control under text edition on a combo so I can't limit number of characters or make 
  ;           it a number-only combo. So combos are just for regular text :\ ... Khaled's turn :p

  var %dname = _prompt.input
  if ($dialog(%dname)) { halt } 
  if ($isid) { 
    unset $_script.variableName(Prompt,Input,*)
    set -u $_script.variableName(Prompt,Input,Parameters) $replace($1-,&,&&)
    var %flags = $_prompt.inputParameter(flags), %id
    if (t isincs %flags) {
      if (c isincs %flags) && (!$_prompt.inputParameter(wordLimit)) { %id = 1 }
      else { %id = 3 }
    }
    elseif (n isincs %flags) {
      ;; if (c isincs %flags) { %id = 2 }   (X)
      ;; else { %id = 4 }
      %id = 4
    }
    elseif (p isincs %flags) { %id = 5 }
    else { %id = 3 }
    set -u $_script.variableName(Prompt,Input,ControlID) %id
    __dummy $dialog(%dname,%dname,-4)
    var %ret = $_prompt.inputParameter(returnText)
    if (w isincs $_prompt.inputParameter(flags)) { return $iif(%ret iswm $_prompt.inputParameter(wildcardText),%ret) }
    elseif (%ret != $null) { return %ret }
    if (h isincs $_prompt.inputParameter(flags)) { halt }
  }
}
alias -l _prompt.inputParameter {
  var %p = $1
  tokenize 34 $_script.variableValue(Prompt,Input,Parameters)
  goto %p
  :controlID | return $iif($int($_script.variableValue(Prompt,Input,ControlID)) isnum 1-5,$v1,3)
  :descriptionText | return $iif($1 != ~ && $1 != $null,$1,Text:)
  :possibleText | return $iif($2 != ~ && $2 != $null,$2)
  :titlebarText | return $iif($3 != ~ && $3 != $null,$3,$_script.name - Input)
  :flags | return $remove($4,-)
  :wordLimit
  var %f = $4
  if (i isincs %f) { return $iif($int($gettok(%f,2-,105)) isnum 1-,$v1) }
  :wildcardText | return $iif(w isincs $4,$5)
  :hash | return $iif(c isincs $4,PromptInput- $+ $iif(w isincs $4,$6,$5))
  :returnText | return $_script.variableValue(Prompt,Input,ReturnText)
  :%p
}
on *:DIALOG:_prompt.input:*:*:{
  if ($devent == INIT) {
    var %flags = $_prompt.inputParameter(flags), %lim = $_prompt.inputParameter(wordLimit), %id = $_prompt.inputParameter(ControlID), %tbar
    if (d isincs %flags) { did -et $dname 100 }
    else { did -t $dname 99 }
    if (n isincs %flags) && (%lim) { %tbar = (number limited to %lim word $+ $iif(%lim != 1,s) $+ ) }
    elseif (%lim) { %tbar = (limited to %lim word $+ $iif(%lim != 1,s) $+ ) }
    elseif (n isincs %flags) { %tbar = (limited to digits) }
    dialog -t $dname $_prompt.inputParameter(titlebarText) %tbar
    did -ra $dname 50 $_prompt.inputParameter(descriptionText)
    var %x = 1, %hash = $_prompt.inputParameter(hash)
    if (c isincs %flags) && (%hash != $null) {
      while ($_script.getOption(%hash,%x) != $null) {
        did -a $dname %id $v1
        inc %x
      }
      if (%x > 1) { did -e $dname 98 }
    }
    else { did -h $dname 98 }
    if ($_prompt.inputParameter(possibleText) != $null) {
      var %temp = $v1
      did -et $dname 100
      if ($didwm(%id,%temp)) { did -c $dname %id $v1 }
      else { did -ac $dname %id %temp }
    }
    elseif ($_script.getOption(Advanced,PasteClipboardToInput)) && ($cb != $null) {
      did -et $dname 100
      var %cb = $iif(%lim || p isincs %flags,$gettok($cb,1,32),$cb)
      if ($didwm(%id,%cb)) { did -c $dname %id $v1 }
      else { did -ac $dname %id %cb }
    }
    did -fve $dname %id
  }
  elseif ($devent == SCLICK) {
    if ($did == $_prompt.inputParameter(ControlID)) {
      if (d !isincs $_prompt.inputParameter(flags)) {
        if ($did($did).text != $null) { did -et $dname 100 }
        else {
          did -b $dname 100
          did -t $dname 99
        }
      }
    }
    elseif ($did == 98) {
      var %id = $_prompt.inputParameter(ControlID) 
      _script.setOption $_prompt.inputParameter(Hash)
      did -r $dname %id
      did -b $dname 98
      if (d !isincs $_prompt.inputParameter(flags)) {
        if ($did(%id).text != $null) { did -et $dname 100 }
        else {
          did -b $dname 100
          did -t $dname 99
        }
      }
    }
    elseif ($did == 100) { 
      var %id = $_prompt.inputParameter(ControlID), %text = $did(%id).text 
      set $_script.variableName(Prompt,Input,ReturnText) %text
      if (c isincs $_prompt.inputParameter(flags)) && ($_prompt.inputParameter(hash) != $null) {
        var %hash = $_hash.prefixed($v1), %x = 1, %y = 1, %i
        _script.setOption %hash
        while ($did(%id,%x) != $null) {
          %i = $v1
          if (!$hfind(%hash,%i,1).data != $null) {
            _script.setOption %hash %y %i
            inc %y 
          }
          inc %x
        }
        if (!$hfind(%hash,%text,1).data) _script.setOption %hash %y %text
      } 
    }
  }
  elseif ($devent == EDIT) {
    var %f = $_prompt.inputParameter(flags), %id = $_prompt.inputParameter(controlID), %text = $did(%id).text, %lim = $_prompt.inputParameter(wordLimit), %l
    if ($chr(32) isin %text) && ((n isincs %f) || ($numtok(%text,32) <= %lim) || (p isincs %f)) { %l = -1 }
    elseif (n isincs %f) && (%text != -) && (%text !isnum) { %l = -1 }
    ;; elseif ($len(%text) > %lim) { %l = %lim }
    if (%l) { did -ra $dname %id $left(%text,%l) }
    if (d isincs %f) { return }
    if ($did(%id).text == $null) {
      did -b $dname 100
      did -t $dname 99
    }
    else {
      did -et $dname 100
    }
  }
}


;______________[ dialog ]__________________________________________

alias _dialog.labelFile {
  ; dialog icon height must be always 13 to fit right
  var %w = $1, %h = $2, %text = $3-, $&
    %win = @_temp._dialog.labelFile, %file = $_script.directory(Images,$null,$+(DialogLabel_,$crc($+(%text,-,%w,-,%h),0),.jpg)), %size = $calc($dbuw * %w) $calc($dbuh * %h)
  if ($isfile(%file)) { return %file }
  window -c %win 
  window -hkp +d %win 0 0 %size
  drawrect -fr %win 6956042 10 0 0 %size
  drawtext -rpb %win 16777215 6956042 Arial 16 7 3 $+(,%text,)
  drawsave %win %file
  return %file
}
alias _dialog.whichRadioIsSelected {
  var %dname = $1, %ids = $_string.compressNumberToExtend($2), %x = 1, %def = $3, %id
  if (!$dialog(%dname)) { return %def }
  while ($gettok(%ids,%x,44)) {
    %id = $v1
    if ($did(%dname,$v1).state) { return %id }
    inc %x
  }
  return %def
}
alias _dialog.invertListSelections {
  if ($1 == -m) { var %dname = $2, %id = $3 }
  else { var %dname = $1, %id = $2 }
  if (!$dialog(%dname)) { return }
  var %selines, %x = 1
  while ($did(%dname,%id,%x).sel) {
    %selines = $addtok(%selines,$v1,44)
    inc %x
  }
  var %x = $iif($1 == -m,2,1), %y = $did(%dname,%id,0).lines
  while (%x <= %y) {
    did $iif(!$istok(%selines,%x,44),-ck,-uk) %dname %id %x
    inc %x
  }
}
alias _dialog.upDownArrows {
  var %dname = $2, %id = $3, %flags = $1
  if (!$dialog(%dname)) { return }
  var %sel = $did(%dname,%id).sel, %seltext = $did(%dname,%id).seltext
  if (((d isin %flags) && (%sel == $did(%dname,%id).lines)) || ((u isin %flags) && (%sel == 1))) || (!%sel) { return }
  did -d %dname %id %sel
  did -ci %dname %id $calc(%sel $iif(u isin %flags,-,+) 1) %seltext
}
alias _dialog.listMasks {
  if ($1 == -r) { var %dname = $2, %ids = $3 } 
  else { var %dname = $1, %ids = $2 }
  if (!$dialog(%dname)) { return }
  var %n = 0, %address = nick!ident@feedbackscript.has.it 
  while (%n <= 19) { 
    did -a %dname %ids ( $+ %n $+ ) $mask(%address,%n) 
    inc %n 
  }
  if ($1 != -r) { did -a %dname %ids NICK }
}
alias _dialog.shorterFilename {
  var %size = $1, %file = $remove($2,")
  var %chr = $iif($3 isnum,$3,92)
  if (%size !isnum) || (%file == $null) { return %file }
  if ($width(%file,MS Shell Dlg,-8) > $calc($dbuw * %size)) {
    %file = $puttok(%file,...,2,%chr)
    while ($width(%file,MS Shell Dlg,-8) > $calc($dbuw * 134)) {
      %file = $deltok(%file, 3,%chr) 
      if ($numtok(%file,%chr) <= 3) { break }
    }
  }
  return %file
}
alias _dialog.saveBufferTo {
  var %dname = $1, %id = $2, %parm = $remove($3,-), %4 = $4-
  if (!$dialog(%dname)) { return }
  if (w isincs %parm) {
    var %win = $_window.fixName(%4)
    _windows.open %win
    filter -iw %dname %id %win
    goto end
  }
  elseif (f isincs %parm) {
    if (%4) { var %file = $_file.fixName(%4) }
    else { var %file = $_file.fixName($$_prompt.selectFile($mircdir*.txt,File to save,SaveDialogBufferToFile)) }
    write -c %file
    if ($isfile(%file)) {
      if ($lines(%file)) && ($_prompt.yesNo(Clear file text before save?)) { .write -c %file }
      filter -if %dname %id %file
      goto end
    }
  }
  return
  :end
  if ($show) { _prompt.info Buffer saved to ' $+ $iif(%4,%4,%file) $+ ' }
}


;______________[ lag ]__________________________________________

alias _lag.time {
  var %cid = $iif($scid($1) isnum,$1,$activecid)
  if ($_script.getOption(Lag,%cid) isnum) { return $v1 }
}
alias _lag.warnTime { return $iif($int($_goptions.get($scid($1).network,WarnLagHigherThan)) isnum 1-,$v1,20) }
alias _lag.method {
  if ($_goptions.get($scid($1).network,LagCheckMethod) isnum 1-3) { return $v1 }
  return 1
}
alias _lag.work {
  _script.setOption Lag
  var %x = 1, %y = $scon(0), %cids = $_network.identifierString(cid)
  while (%x <= %y) {
    _lag.checkIt $gettok(%cids,%x,32)
    inc %x
  }
}
alias _lag.checkInterval { return $iif($_goptions.get($1,CheckLagEvery) isnum 1-,$v1,2) }
alias _lag.checkIt {
  var %cid = $iif($1 isnum,$1,$cid), %timer = $+(LAG~,%cid), %net = $scid(%cid).network
  if (!$_goptions.get(%net,CheckLag)) || (!$scid(%cid).server) { .timer $+ %timer off }
  else {
    .timer $+ %timer off
    scid -t1 %cid .timer $+ %timer 0 $_lag.checkInterval(%net) _lag.checkCommand %cid
  }
}
alias _lag.checkCommand {
  var %cid = $$1
  goto $_lag.method(%cid)
  :1
  scid -t1 %cid .raw NOTICE $me :SELF^LAG^CHECK $ticks %cid
  return
  :2
  scid -t1 $1 .ctcp $me SELF^LAG^CHECK $ticks %cid
  return
  scid -t1 $1 .raw PRIVMSG $me :SELF^LAG^CHECK $ticks %cid $+ 
  return
  :3
  scid -t1 $1 .raw CHECK^SELF^L^ $+ $ticks $+ ^ $+ %cid
}
alias _lag.setLag {
  var %lag = $calc(($ticks - $1) / 1000), %cid = $2, %time = $_lag.warnTime(%cid)
  if (!%cid) { return }
  _script.setOption Lag %cid $calc(($ticks - $1) / 1000)
  if ($_goptions.get(WarnLagHigher)) && (%lag >= %time) && (!$_script.variableValue(Lag,AlreadyWarned,%cid)) {
    .timer -m 1 1 _prompt.info Your LAG on $scid($cid).network is seems higher than normal ( $+ %lag $+ s). Please consider reconnect."Lag
    set -u30 $_script.variableName(Lag,AlreadyWarned,%cid) 1
  }
}
on me^*:NOTICE:SELF^LAG^CHECK * *:?:{
  haltdef
  _lag.setLag $2 $3
}
ctcp *:SELF^LAG^CHECK * *:*:{
  if ($nick == $me) {
    haltdef
    _lag.setLag $2 $3
  }
}
raw 421:*CHECK^SELF^L^*^* *:{
  haltdef
  var %t = $gettok($2,4,94), %cid = $gettok($2,5,94)
  if (%t isnum) && (%cid isnum) { _lag.setLag %t %cid }
}



;_____________[ file ]_________________________________________

alias _file.isSound {
  var %e = $right($remove($1-,"),3)
  if ($istok(wma.ogg.mp3.mid.wav,%e,46)) { return 1 }
}
alias _file.isDirectory {
  var %d = $_file.fixName($1-)
  if ($isdir(%d)) { return %d }
}
alias _file.makeDirectory {
  tokenize 92 $1-
  var %x = 1, %d = ""
  while ($eval($+($,%x),2) != $null) {
    %d = %d $+ $v1 $+ \
    if (!$isdir(%d)) { mkdir $_file.fixName(%d) }
    inc %x
  }
}
alias _file.isExtension {
  var %ext = $2, %file = $remove($1,"), %_ext = $gettok(%file,-1,46)
  if (%ext == %_ext) { return %file }
}
alias _file.fixName {
  var %file = $remove($replace($1-,/,\),")
  while (\\ isin %mfile) { %mfile = $replace(%file,\\,\) }
  if ($chr(32) isin %file) && ("*" !iswm %file) { return $+(",$remove(%file,"),") }
  return $1-
}
alias _file.isFile {
  var %f = $_file.fixName($1-)
  if ($isfile(%f)) { return %f }
}
alias _file.equalsTo {
  if ($crc($1) == $crc($2)) { return 1 }
}
alias _file.copyDirectory {
  var %from = $remove($1,"), %to = $remove($2,"), %wild = $iif($3 == $null,*,$3), %flags = $4, %win = @_temp._file.copyDirectory
  if (!$isdir(%from)) { return }
  _window.open -hl %win
  _file.makeDirectory %to
  __dummy $_file.copyDirectory2(%from,%to,%wild,%flags)
  __dummy $finddir(%from,*,0,%win)
  while ($line(%win,0)) {
    _file.makeDirectory $_file.fixName( $replace($line(%win,1),%from,%to) )
    __dummy $_file.copyDirectory2($line(%win,1),$replace($line(%win,1),%from,%to),%wild,%flags)
    dline %win 1
  }
  close -@ %win
  return 1
}
alias _file.copyDirectory2 {
  var %from = $1, %to = $2, %wild = $3, %flags = $4, %win = @_temp._file.copyDirectory2
  _window.open -lh %win
  __dummy $findfile(%from,*,0,1,%win)
  while ($line(%win,0)) {
    var %copy = $false, %_fromtemp = $line(%win,1), %_totemp = $replace(%_fromtemp,%from,%to)
    if (o isin %flags) {
      if (!$isfile(%_totemp)) { %copy = $true }
    }
    else { %copy = $true }
    if (%copy) { .copy -o $_file.fixName(%_fromtemp) $_file.fixName(%_totemp) }
    dline %win 1
  }
  close -@ %win
}



;_____________[ windows ] ________________________________________

alias _window.open {
  var %x = 1, %win, %i
  while ($gettok($1-,%x,32)) {
    %i = $v1
    if (@* iswm %i) { 
      %win = %i
      break
    }
    inc %x
  }
  if ($window(%win)) { window -c %win }
  window $1-
}
alias _window.fixName { return $iif($left($1,1) != @,$+(@,$1),$1) }
alias _window.activeIsWindow {
  if (@* iswm $active) { return 1 }
}
alias _window.noChar {
  var %win = $iif($1 != $null,$1-,@_window.noChar)
  if (!$window(%win)) { window -h %win }
  var %font = $window(%win).font
  if ($1 == $null) { window -c %win }
  if ($istok(Terminal IBMPC,%font,32)) { return $chr(254) }
  return $chr(160)
}



;_____________[ mirc ] ________________________________________

alias _mirc.tagToControlCode { return $replace($1-,<K>,,<B>,,<U>,,<R>,) }
alias _mirc.controlCodeToTag { return $replace($1-,,<K>,,<B>,,<U>,,<R>) }

alias _mirc.ini { return $_file.fixName($mircini) }
alias _mirc.exe { return $_file.fixName($mircexe) }
alias _mirc.iniData {
  if ($2) { return $readini($_mirc.ini,n,$1,$2) }
}
alias _mirc.iniOption { return $gettok($readini($_mirc.ini,n,options,$+(n,$$1)),$$2,44) }
alias _mirc.timestamp { 
  if ($_mirc.iniOption(4,12)) { return $asctime($timestampfmt) }
}
alias _mirc.commandChar { return $iif($_mirc.iniData(text,commandchar) != $null,$v1,/) $+ * }
alias _mirc.dir { return $_file.fixName($mircdir) }



;______________[ about ]__________________________________________

dialog _about {
  title "About"
  size -1 -1 201 118
  option dbu
  box "", 1, 4 3 193 110
  icon 2, 146 13 43 41,  $mircexe, 0
  text "", 3, 30 15 106 16
  text "", 5, 30 41 77 8
  icon 6, 9 13 15 15,  $mircexe, 0
  text "", 7, 30 58 107 16
  button "Author!", 9, 151 58 35 11, ok
  link "", 10, 52 84 122 8
  link "", 12, 52 96 123 8
  check "", 13, 10 99 8 10
  text "Home:", 4, 30 84 20 8
  text "Email:", 8, 30 96 20 8
}
alias about { _advanced.openDialog _about about }
on *:DIALOG:_about:*:*:{
  if ($devent == CLOSE) { _script.setOption about OpenOnStart $did(13).state }
  elseif ($devent == SCLICK) {
    if ($did isnum 9-10) { home }
    elseif ($did == 12) { .run mailto: $_feedback.email }
    elseif ($did == 13) { _script.setOption About OpenOnStart $did(13).state }
    else { dialog -x $dname }
  } 
  elseif ($devent == INIT) {
    if ($rand(1,10) == 5) { did -h $dname 1 }
    var %whore = (5 seconds to expire)
    dialog -t $dname About $_script.name $iif($rand(1,100) == 69,%whore)
    did -g $dname 2 $iif($_script.directory(images,m,face.png),$v1,$mircexe)
    did -g $dname 6 $iif($_script.directory(images,m,script.ico),$v1,mircexe)
    if ($_script.getOption(About,OpenOnStart)) { did -c $dname 13 }
    did -a $dname 3 $_script.name $+ ® v $+ $_script.version $+ $crlf $+ With mIRC® v $+ $version under Windows $+ $os
    did -a $dname 5 Written by $_script.author (PTnet)
    did -a $dname 7 Copyright © 2000- $+ $asctime(yyyy) $_script.author Co. Ltd $+ $crlf $+ All Rights Reserved 
    did -a $dname 10 $_script.home
    did -a $dname 12 $_script.email
  }
}



;_____________[ presentation ] ________________________________________

alias -l _presentation.drawTextFlashing {
  var %win = @Presentation, %x = 1, %fontype = Verdana, %fontsize = 35, %posX = 34, %posY = 120, %feedback = $_script.name, %1stColor = 0
  while (%x <= 8) {
    if (!$window(%win)) { return }
    var %letter = $mid(%feedback,%x,1), %rgb = 0, %posX = %posX + 23
    while (%rgb <= 255) { 
      drawtext -pr %win $rgb(%1stColor,0,%rgb) %fontype %fontsize %posX %posY $+(,%letter,) 
      inc %rgb
    }
    while (%rgb >= 0) { 
      drawtext -rp %win $rgb(%1stColor,0,%rgb) %fontype %fontsize %posX %posY $+(,%letter,) 
      dec %rgb 
    }
    drawtext -rp %win $rgb(%1stColor,0,255) %fontype %fontsize %posX %posY $+(,%letter,) 
    inc %x
  }
}
alias -l _presentation.drawLine {
  var %win = @Presentation, %w = 1, %init.pos = 58 159, %h = 4
  while (%w <= 188) {
    if (!$window(%win)) { return }
    drawrect -fr %win $rgb(255,218,51) 1 %init.pos %w %h 
    inc %w
    .timer -m 200 1 __dummy
  }
}
alias -l _presentation.drawBy {
  var %win = @Presentation, %pos = 155 165, %fontype = Verdana, %fontsize = 12, %x = 1, %col
  while (%x <= 400) {
    if (!$window(%win)) { return }
    drawtext -pr %win $iif(2 // %x,$rgb(0,0,255),0) %fontype %fontsize %pos by $_script.author $+ 
    inc %x
  }
}
alias -l _presentation.drawNet {
  var %win = @Presentation, %x = 300 , %y = 0, %x2 = 0, %y2 = 300, %count = 1, %size, %c
  if (!$window(%win)) { return }
  while (%x > 0) {
    if (%count == 4) { %size = 2 } 
    else { %size = 1 }
    drawline -r %win $rgb(255,0,0) %size 0 %y %x 0 
    drawline -r %win $rgb(255,0,0) %size %x2 300 300 %y2
    inc %y 10  
    dec %x 10
    dec %y2 10 
    inc %x2 10
    if (%count == 4) { %count = 1 } 
    else { inc %count }
    %c = 1 
    while (%c <= 2000) { inc %c }
  }
} 
alias presentation {
  var %win = @Presentation, %w = 300, %h = 300
  _window.open -pfarodhkBz +fL %win $calc(($window(-1).w - %w) / 2) $calc(($window(-1).h - %h) / 2) %w %h
  _presentation.drawNet
  _presentation.drawTextFlashing
  _presentation.drawLine 
  _presentation.drawBy
  if ($1 == -c) && ($window(%win)) { window -c %win } 
}
menu @Presentation {
  sclick:{ window -c $active }
}



;______________[ filters ]__________________________________________

alias filters { _advanced.openDialog _filters filters }
dialog _filters {
  title "Filters"
  size -1 -1 179 170
  option dbu

  box "", 1, 5 19 169 128
  edit "", 2, 11 64 112 11, autohs
  list 3, 11 75 112 65, sort size
  button "&Add...", 4, 128 81 40 11
  button "&Update", 5, 128 93 40 11
  button "Dele&te", 6, 128 105 40 11
  button "De&lete all", 7, 128 122 40 11
  check "&Enable filter", 8, 13 30 100 7
  check "&Filter all", 9, 13 40 37 7
  check "&Don't filter if my nick is in text", 2999, 13 50 80 10
  edit "", 3000, -4 0 0 0, hide disable autohs

  button "&Ok", 1000, 50 153 40 11, ok
  button "&Cancel", 999, 92 153 40 11, cancel
  button "&Help", 998, 134 153 40 11

  radio "&SNotices", 500, 6 6 50 12, push
  radio "&Wallops", 501, 59 6 50 12, push
}
on *:DIALOG:_filters:*:*:{
  if ($devent == INIT) {
    _hash.toHash -o Filters TEMP-Filters
    var %t = $_filters.types, %last = $_script.getOption(Filters,LastFilterSelected), %last = $iif($istok(%t,%last,59),%last,$gettok(%t,1,59))
    _filters.loadSettings %last
    did -c $dname $calc($findtok(%t,%last,1,59) + 499)
  }
  elseif ($devent == SCLICK) {
    if ($did == 3) {
      if ($did(3).seltext != $null) { did -ra $dname 2 $v1 }
    }
    elseif ($did == 4) {
      if ($did(2) != $null) { 
        var %txt = $remove($did(2),;) 
        if (!$istok($didtok(3,59),%txt,59)) { did -ca $dname 3 %txt } 
        did -r $dname 2 
      }  
    }
    elseif ($did == 5) {
      if ($did(3).seltext) && ($did(2)) { 
        did -o $dname 3 $did(3).sel $remove($v1,;) 
        did -r $dname 2 
      }
    }
    elseif ($did == 6) {
      if ($did(3).sel) { did -d $dname 3 $v1 }
    }
    elseif ($did == 7) {
      if ($did(3,1)) && ($_prompt.yesNo(Are you sure you want do delete all listed text to filter?"Filters)) { did -r $dname 3 }
      dialog -v $dname
    }
    elseif ($did == 8) { did $iif($did(8).state,-e,-b) $dname 1,2,3,4,5,6,7,9,2999 }
    elseif ($did isnum 500-501) { _filters.loadSettings $remove($did($did),&) }
    elseif ($did == 1000) { 
      _filters.saveSettings
      _hash.toHash -o TEMP-Filters Filters
    } 
  }
  elseif ($devent == EDIT) {
    if ($did == 2) && (!$did(5).enable) && ($did(3).sel) { did -e $dname 5 }
  }
  elseif ($devent == CLOSE) {
    _script.setOption Filters LastFilterSelected $iif($did(501).state,Wallops,SNotices)
  }
}
alias -l _filters.isStringToFilter {
  var %x = 1, %i, %text = $_script.getOption(Filters,$+($1,_text)) 
  while ($gettok(%text,%x,59)) { 
    %i = $v1 
    if (%i iswm $2-) || (%i isin $2-) { return 1 }
    inc %x 
  }
}
alias -l _filters.types { return snotices;wallops }
alias -l _filters.loadSettings {
  var %dname = _filters
  _filters.saveSettings
  if ($istok($_filters.types,$1,59)) {
    var %hash = TEMP-Filters, %all = $_script.getOption(%hash,$+($1,FilterAll)), %text = $_script.getOption(%hash,$+($1,FilterText)), %filter = $_script.getOption(%hash,$1), $&
      %mnick = $_script.getOption(%hash,$+($1,DontFilterIfMyNick))
    did -ra %dname 8 &Enable $1 filter
    did -r %dname 2,3 
    didtok %dname 3 59 %text 
    if (%filter) { 
      did -c %dname 8 
      did -e %dname 1,2,3,4,5,6,7,9,2999
    }
    else { 
      did -u %dname 8 
      did -b %dname 1,2,3,4,5,6,7,9,2999
    } 
    did $iif(%all,-c,-u) %dname 9
    did $iif(%mnick,-c,-u) %dname 2999
    did -ra %dname 3000 $1
  }
}
alias -l _filters.saveSettings {
  var %dname = _filters, %type = $did(%dname,3000), %all = $+(%type,FilterAll), %text = $+(%type,FilterText), %x = 1, %hash = TEMP-Filters, %mnick = $+(%type,DontFilterIfMyNick), $&
    %» = _script.setOption %hash
  if (%type == $null) { return }
  if ($istok($_filters.types,%type,59)) && ($dialog(%dname)) { 
    while ($did(%dname,3,%x) != $null) {
      var %filters = $addtok(%filters,$v1,59)
      inc %x 
    } 
    %» %text %filters
    %» %type $did(%dname,8).state 
    %» %all $did(%dname,9).state
    %» %mnick $did(%dname,2999).state
  }
}
alias _filters.handleEvent {
  var %event = $1, %all = $+(%event,FilterAll), %text = $2-, %mnick = $+(%event,DontFilterIfMyNick)
  if ($_script.getOption(Filters,%event)) {
    if ($_script.getOption(Filters,%all)) { halt }
    if ($_script.getOption(Filters,%mnick)) && ($me isin %text) { return }
    if ($_script.getOption(Filters,snotices)) && ($_filters.isStringToFilter(snotices,%text)) { halt }
  }
}
