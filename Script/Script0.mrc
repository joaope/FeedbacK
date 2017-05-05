;_____________[ goptions ] ________________________________________

alias options { goptions }
alias general { goptions }
alias goptions {
  var %d = _goptions.general, %flags = $1
  var %tabs = $_goptions.tabsNumbers, %net = $_script.getOption(GeneralOptions,LastNetworkSelected), %item = $gettok(%tabs,$_script.getOption(GeneralOptions,LastTabSelected),46)
  if (-* iswm %flags) {
    if (!$_string.areValidFlags(%flags,ni)) { goto s }
    if (n isin %flags) {
      %net = $2 
      if (%net == $null) { goto s }
      else { var %_temp = 1 }
    }
    if (i isin %flags) {
      if ($findtok($_goptions.tabsDescription,$iif(%_temp,$3-,$2-),1,46)) { %item = $gettok($_goptions.tabsNumbers,$v1,46) }
      if (%item == $null) { goto s }
    }
  }
  elseif ($1 != $null) { goto s }
  set -u $_script.variableName(GeneralOptions,InitialNetwork) %net
  set -u $_script.variableName(GeneralOptions,InitialTab) $iif(%item,%item,50)
  _advanced.openDialog %d general
  return
  :s
  _themes.sintaxEcho goptions [-ni] [network] [item] 
}
dialog _goptions.general {
  title "General options"
  size -1 -1 313 261
  option dbu

  text "&Network:", 1, 59 10 24 8
  combo 2, 84 9 88 50, size drop
  button "&Add...", 3, 174 9 40 11
  button "&Remove", 4, 216 9 40 11
  box "", 5, -50 24 400 209
  list 6, 4 34 65 192, size

  edit "", 3000, 0 0 0 0, hide disable autohs

  button "&Ok", 2000, 182 242 40 11, ok
  button "&Cancel", 1999, 224 242 40 11, cancel
  button "&Help", 1998, 266 242 40 11

  tab "<none>", 40, -50 -26 400 400
  text "(NO OPTION SELECTED)", 7, 161 136 100 8, disable tab 40

  tab "IRC", 50
  box "&Queries:", 51, 85 82 115 74, tab 50
  check "&Show common channels on open", 52, 92 93 100 10, tab 50
  check "&Close window on user quit / unotify", 53, 92 105 100 10, tab 50
  check "C&lose window on chat open", 54, 92 117 100 10, tab 50
  box "On &join:", 57, 206 82 94 74, tab 50
  check "S&how channel names", 58, 213 93 80 10, tab 50
  check "Sho&w channel topic", 59, 213 105 80 10, tab 50
  check "Show ch&annel statistics", 60, 213 117 80 10, tab 50
  check "Show s&ynch time", 61, 213 129 80 10, tab 50
  check "Show c&reation time", 62, 213 141 80 10, tab 50
  box "On &invite:", 63, 85 160 215 46, tab 50
  radio "I&gnore always", 64, 91 171 117 10, tab 50
  radio "Ignore only if mIRC's auto-join &disable", 65, 91 181 117 10, tab 50
  radio "Show &me FKey (if mIRC's auto-join disable)", 66, 91 191 117 10, tab 50

  tab "AUTOJOIN", 100
  text "&Channels:", 101, 107 62 51 8, tab 100
  list 102, 106 70 127 78, tab 100 size
  button "A&dd..", 103, 236 75 40 11, tab 100
  button "R&emove", 104, 236 88 40 11, tab 100
  button "&Up", 105, 236 119 40 11, tab 100
  button "D&own", 106, 236 132 40 11, tab 100
  text "&Password:", 107, 107 151 27 8, tab 100
  edit "", 108, 134 149 99 11, tab 100 autohs
  box "Join mode:", 109, 102 165 178 57, tab 100
  radio "Disabled", 110, 108 175 53 10, tab 100
  radio "Normal", 111, 108 186 50 10, tab 100
  radio "With a delay of", 112, 108 197 48 10, tab 100
  edit "", 113, 157 197 43 11, tab 100 autohs right
  text "seconds", 114, 202 198 25 8, tab 100
  radio "Wait for synch before continue", 115, 108 208 89 10, tab 100

  tab "LOGIN", 150
  text "Nicks to lo&gin:", 151, 102 60 44 8, tab 150
  list 152, 101 68 138 75, tab 150 size
  button "A&dd...", 153, 242 91 40 11, tab 150
  button " Re&move", 154, 242 104 40 11, tab 150
  text "Pass&word:", 155, 102 145 27 8, tab 150
  edit "", 156, 131 144 108 11, tab 150 autohs
  box "", 157, 96 156 192 67, tab 150
  text "&Login on:", 158, 102 167 41 8, tab 150 right
  combo 159, 147 166 92 50, tab 150 size drop
  text "R&equest string:", 160, 102 180 41 8, tab 150 right
  edit "", 161, 147 179 92 11, tab 150 autohs
  text "L&ogin command:", 162, 102 193 41 8, tab 150 right
  edit "", 163, 147 192 92 11, tab 150 autohs
  button "Add &tag...", 164, 242 192 40 11, tab 150
  text "Service nick:", 165, 102 206 41 8, tab 150 right
  edit "", 166, 147 205 92 11, tab 150 autohs

  tab "SERVICES", 200
  text "&Use services popups from:", 201, 121 84 66 8, disable tab 200
  combo 202, 188 83 75 50, disable tab 200 size drop
  box "&Options:", 203, 116 100 153 60, disable tab 200
  check "&Show status popups", 204, 122 111 128 10, disable tab 200
  check "S&how channel popups", 205, 122 122 128 10, disable tab 200
  check "Sh&ow nicklist popups", 206, 122 133 128 10, disable tab 200
  check "Us&e /msg ????Serv instead of /raw ????Serv", 207, 122 144 128 10, disable tab 200
  text "N&ick(s):", 208, 119 170 23 8, disable tab 200 right
  edit "", 209, 144 169 120 11, disable tab 200 autohs
  text "Si&te(s):", 210, 119 185 23 8, disable tab 200 right
  edit "", 211, 144 184 120 11, disable tab 200 autohs

  tab "OPTIONS", 250
  box "Default &mask types:", 253, 107 80 168 46, tab 250
  text "&Clones:", 254, 114 93 21 8, tab 250 right
  combo 255, 137 92 131 100, tab 250 size drop
  text "&Ignores:", 256, 114 109 22 8, tab 250 right
  combo 257, 137 108 131 100, tab 250 size drop
  box "Ni&ck regain system:", 258, 108 135 167 41, tab 250
  check "&Auto regain permanent nick:", 259, 115 147 79 10, tab 250
  edit "", 260, 195 147 72 11, tab 250 autohs
  check "As&k before regaining", 261, 115 160 108 10, tab 250

  tab "USERMODES", 300
  text "&Invisible:", 301, 117 105 30 8, tab 300
  text "&Global Ops:", 302, 117 115 30 8, tab 300
  text "H&elper:", 303, 117 125 30 8, tab 300
  text "Wallo&ps:", 304, 117 142 30 8, tab 300
  text "&SNotices:", 305, 117 152 30 8, tab 300
  text "Othe&rs:", 306, 117 170 30 8, tab 300
  box "&Default", 307, 149 93 55 93, tab 300
  check "+i", 308, 156 104 40 10, tab 300
  check "+g", 309, 156 114 40 10, tab 300
  check "+h", 310, 156 124 40 10, tab 300
  check "+w", 311, 156 141 40 10, tab 300
  check "+s", 312, 156 151 40 10, tab 300
  edit "", 313, 156 168 41 11, tab 300
  box "&Away", 314, 210 93 55 93, tab 300
  check "+s", 315, 217 151 40 10, tab 300
  check "+w", 316, 217 141 40 10, tab 300
  check "+h", 317, 217 124 40 10, tab 300
  check "+g", 318, 217 114 40 10, tab 300
  check "+i", 319, 217 104 40 10, tab 300
  edit "", 320, 217 168 41 11, tab 300

  tab "LISTS", 350
  box "&Internal Address List (IAL):", 351, 103 97 177 54, tab 350
  text "&Update IAL", 352, 110 110 35 8, tab 350
  combo 353, 222 109 52 50, tab 350 size drop
  check "&Ask before update if users are more than", 354, 110 122 111 10, tab 350
  edit "", 355, 222 122 52 11, tab 350 autohs right
  check "&Don't update if users are more than", 356, 110 134 110 10, tab 350
  edit "", 357, 222 134 52 11, tab 350 autohs right
  box "I&nternal Ban List (IBL):", 358, 103 156 177 30, tab 350
  text "U&pdate IBL", 359, 110 169 32 8, tab 350
  combo 360, 222 168 52 50, tab 350 size drop

  tab "OTHERS", 400
  box "&Show...", 401, 114 87 155 82, tab 400
  check "...&when notified users joins a channel", 402, 121 99 145 10, tab 400
  check "...&change of a notified nick occurs (same channel only)", 403, 121 110 145 10, tab 400
  check "...&banned nicks on ban (when opped only)", 404, 121 121 145 10, tab 400
  check "...&unbanned nicks on unban (when opped only)", 405, 121 132 145 10, tab 400
  check "...c&lones in join line", 406, 121 143 145 10, disable tab 400
  check "...al&phabetic sorted channels", 407, 121 154 145 10, tab 400
  check "A&uto /whowas (when failed /whois)", 408, 121 174 142 10, tab 400
  check "Au&to delay /amsg and /ame commands", 409, 121 185 143 10, tab 400

  tab "AWAY", 450
  box "&Automatic away:", 451, 94 75 125 52, tab 450
  check "A&ctivate after", 452, 100 86 45 10, tab 450
  edit "", 453, 145 86 46 11, tab 450 autohs right
  text "minutes", 454, 193 88 23 8, tab 450
  check "&Warn me before setting", 455, 100 99 104 10, tab 450
  check "&Quiet away (without announcing)", 456, 100 112 108 10, tab 450
  box "D&isabled while away:", 457, 226 75 63 52, tab 450
  check "&Sounds", 458, 232 86 50 10, tab 450
  check "&Beeps", 459, 232 99 50 10, tab 450
  check "&Flashing", 460, 232 112 33 10, tab 450
  box "&Options:", 461, 94 132 195 73, tab 450
  check "C&lose open queries when away", 462, 100 143 117 10, tab 450
  check "&Deop me when away except this channels:", 463, 100 154 126 10, tab 450
  edit "", 464, 108 164 175 11, tab 450 autohs
  check "C&hange nick when away to:", 465, 100 177 145 10, tab 450
  edit "", 466, 108 187 132 11, tab 450 autohs
  button "Add &tag...", 467, 243 187 40 11, tab 450

  tab "ANNOUNCE", 500
  box "", 501, 100 55 182 61, tab 500
  check "&Announce away / back to...", 502, 107 64 79 10, tab 500
  check "...channels using", 503, 117 76 54 10, tab 500
  combo 504, 221 77 54 50, tab 500 size drop
  check "...&queries using", 505, 117 88 50 10, tab 500
  combo 506, 221 89 54 50, tab 500 size drop
  check "...&chats using", 507, 117 100 50 10, tab 500
  combo 508, 221 101 54 50, tab 500 size drop
  box "&Messages:", 509, 100 119 182 68, tab 500
  text "A&way:", 510, 105 132 18 8, tab 500 right
  edit "", 511, 124 131 152 11, tab 500 autohs
  button "A&dd tag...", 512, 193 143 40 11, tab 500
  button "D&efault", 513, 235 143 40 11, tab 500
  text "&Back:", 514, 105 159 18 8, tab 500 right
  edit "", 515, 124 158 152 11, tab 500 autohs
  button "Add &tag...", 516, 193 170 40 11, tab 500
  button "De&fault", 517, 235 170 40 11, tab 500
  check "E&xcept this #channels, queries and =chats:", 518, 107 192 119 10, tab 500
  edit "", 519, 115 202 160 11, tab 500 autohs
  check "&Except channels with idle higher than", 520, 107 215 100 10, tab 500
  edit "", 521, 207 215 47 11, tab 500 autohs right
  text "minutes", 522, 256 217 20 8, tab 500

  tab "PAGER", 550
  box "&Options:", 551, 107 97 169 63, tab 550
  check "&Enable pager receiver", 552, 114 108 65 10, tab 550
  combo 553, 219 108 49 50, tab 550 size drop
  check "&Warn me when a pager is received to", 554, 114 120 102 10, tab 550
  combo 555, 219 120 49 50, tab 550 size drop
  check "&Delete pagers on away", 556, 114 132 100 10, tab 550
  check "&Show pagers on back", 557, 114 144 73 10, tab 550
  button "&Pagers viewer...", 558, 166 171 50 11, tab 550

  tab "LOG", 600
  box "&Channel events:", 601, 126 60 133 51, disable tab 600
  radio "&Disable", 602, 132 70 120 10, disable group tab 600
  radio "&Only when involving you", 603, 132 79 120 10, disable tab 600
  radio "O&nly when you're opped / voices / halfoped", 604, 132 88 120 10, disable tab 600
  radio "A&lways", 605, 132 97 120 10, disable tab 600
  box "&Private messages (queries and chats):", 606, 126 115 133 52, disable tab 600
  radio "Disa&ble", 607, 132 126 50 10, disable group tab 600
  radio "And d&o nothing", 608, 132 135 120 10, disable tab 600
  radio "And clo&se window", 609, 132 144 120 10, disable tab 600
  radio "And clos&e window only if you don't react", 610, 132 153 120 10, disable tab 600
  check "Dele&te log on away", 611, 132 202 69 10, disable tab 600
  check "Save log to a file to logs directory on back", 612, 132 212 123 10, disable tab 600
  box "Misc (Disconnects, Notifies and File Transfers):", 8, 126 171 133 27, disable tab 600
  check "Al&ways", 9, 132 183 121 10, disable tab 600

  tab "REMINDER", 650
  box "R&emind people you're away (using announce message)...", 651, 110 91 164 72, tab 650
  check "...e&very ", 652, 118 103 32 10, tab 650
  edit "", 653, 150 103 27 11, tab 650 autohs right
  text "minutes to", 654, 179 105 27 8, tab 650
  combo 655, 207 103 60 50, tab 650 size drop
  check "...&when they send you a private message", 656, 118 114 117 10, tab 650
  check "...w&hen they trigger your mIRC's highlight on channel", 657, 118 125 141 10, tab 650
  check "...whe&n someone uses any of this words:", 658, 118 136 138 10, tab 650
  edit "", 659, 126 146 141 11, tab 650 autohs
  check "&Don't remind this #channels, queries and =chats:", 660, 118 170 138 10, tab 650
  edit "", 661, 126 180 141 11, tab 650 autohs

  tab "ANTIDLE", 700
  box "&Options:", 701, 113 111 163 54, tab 700
  check "&Enable antidle", 702, 120 122 46 10, tab 700
  check "&while away", 703, 168 122 41 10, tab 700
  check "&Pause antidle if lag higher than", 704, 120 134 86 10, tab 700
  edit "", 705, 206 134 42 11, tab 700 autohs right
  text "&Maximum seconds of idle time:", 706, 121 149 76 8, tab 700
  edit "", 707, 206 147 42 11, tab 700 autohs right
  text "seconds", 16, 250 135 23 8, tab 700

  tab "LAG CHECKING", 750
  box "&Options:", 751, 113 111 157 54, tab 750
  check "&Check lag every", 752, 119 122 51 10, tab 750
  edit "", 753, 199 123 40 11, tab 750 autohs right
  text "seconds", 754, 241 124 25 8, tab 750
  check "&Warn me if lag is higher than", 755, 119 134 80 10, tab 750
  edit "", 756, 199 134 40 11, tab 750 autohs right
  text "seconds", 757, 241 136 25 8, tab 750
  text "Lag check method:", 758, 120 148 48 8, tab 750
  combo 759, 200 146 39 50, tab 750 drop

  tab "TITLEBAR", 800
  box "&Options:", 801, 98 74 185 27, tab 800
  check "&Enable titlebar update every", 802, 105 85 80 10, tab 800
  edit "", 803, 185 85 50 11, tab 800 autohs right
  text "seconds", 804, 237 87 25 8, tab 800
  box "&Items:", 805, 98 105 185 105, tab 800
  list 806, 103 115 58 89, tab 800 sort size
  button ">", 807, 163 145 12 11, tab 800
  button "<", 808, 163 158 12 11, tab 800
  list 809, 177 115 58 89, tab 800 size
  button "&Up", 810, 237 145 40 11, tab 800
  button "&Down", 811, 237 158 40 11, tab 800

  icon 2001, 81 35 220 13, $mircexe, 0, tab 50
  icon 2002, 81 35 220 13, $mircexe, 0, tab 100
  icon 2003, 81 35 220 13, $mircexe, 0, tab 150
  icon 2004, 81 35 220 13, $mircexe, 0, tab 200
  icon 2005, 81 35 220 13, $mircexe, 0, tab 250
  icon 2006, 81 35 220 13, $mircexe, 0, tab 300
  icon 2007, 81 35 220 13, $mircexe, 0, tab 350
  icon 2008, 81 35 220 13, $mircexe, 0, tab 400
  icon 2009, 81 35 220 13, $mircexe, 0, tab 450
  icon 2010, 81 35 220 13, $mircexe, 0, tab 500
  icon 2011, 81 35 220 13, $mircexe, 0, tab 550
  icon 2012, 81 35 220 13, $mircexe, 0, tab 600
  icon 2013, 81 35 220 13, $mircexe, 0, tab 650
  icon 2014, 81 35 220 13, $mircexe, 0, tab 700
  icon 2015, 81 35 220 13, $mircexe, 0, tab 750
  icon 2016, 81 35 220 13, $mircexe, 0, tab 800
}
on *:DIALOG:_goptions.general:*:*:{
  if ($devent == EDIT) {
    ; __AUTOJOIN__
    if ($did == 108) {
      var %c = $did(102).seltext
      if (%c == $null) {
        if ($did(102).sel) { did -d $dname 102 $v1 }
        did -b $dname 104,105,106,108
        did -r $dname 108
      }
      else {
        var %t = $did(108).text, %chr = $right(%t,1)
        if ($chr(32) isin %t) || (%chr == $chr(40)) || (%chr == $chr(41)) || (%chr == $chr(59)) {
          did -ra $dname 108 $left(%t,-1)
          return
        }
        did -oc $dname 102 $did(102).sel $gettok(%c,1,32) $iif(%t != $null,$+($chr(40),%t,$chr(41)))
      }
    }

    ; __LOGIN__
    elseif ($did == 156) {
      var %c = $did(152).seltext
      if (%c == $null) {
        if ($did(152).sel) { did -d $dname 152 $v1 }
        did -b $dname 154,156
        did -r $dname 156
      }
      else {
        var %t = $did(156).text, %chr = $right(%t,1)
        if ($chr(32) isin %t) || (%chr == $chr(40)) || (%chr == $chr(41)) || (%chr == $chr(59)) {
          did -ra $dname 156 $left(%t,-1)
          return
        }
        did -oc $dname 152 $did(152).sel $gettok(%c,1,32) $iif(%t != $null,$+($chr(40),%t,$chr(41)))
      }
    }
  }
  elseif ($devent == INIT) {
    unset $_script.variableName(GeneralOptions,Dialog,*)

    _goptions.listLabels

    didtok $dname 6 46 $_goptions.tabsDescription
    didtok $dname 159 44 (Never),Connect,Notice,Private message
    didtok $dname 202 44 $_services.available
    _dialog.listMasks -r $dname 255
    _dialog.listMasks $dname 257
    didtok $dname 353,360 44 (Never),On join,On op
    didtok $dname 504,506,508 44 action,message,notice
    didtok $dname 553 44 when away,when not away,always
    didtok $dname 555 44 prompt,status,active,status/active
    didtok $dname 655 44 channels,queries and chats,everywhere
    didtok $dname 759 44 Notice,CTCP,Raws

    hfree -w $_hash.prefixed(TEMP-GeneralOptions-*)
    var %x = 1, %names = $_hash.allMatching(GeneralOptions-&), %i, %nets = (Default)
    while ($gettok(%names,%x,32) != $null) {
      %i = $v1
      %nets = $addtok(%nets,$gettok(%i,3-,45),32)
      _hash.toHash %i $+(TEMP-,$gettok(%i,2-,45))
      inc %x
    }
    didtok $dname 2 32 %nets
    var %netToOpen =  $_script.variableValue(GeneralOptions,InitialNetwork)

    if ($didwm(2,%netToOpen)) { did -c $dname 2 $v1 }
    else { did -c $dname 2 1 }
    _goptions.selectOptionsTab $dname $_script.variableValue(GeneralOptions,InitialTab)

    _goptions.loadNetworkOptions
  }
  elseif ($devent == SCLICK) {
    if ($did == 2) { _goptions.loadNetworkOptions }
    elseif ($did == 3) {
      var %net = $$_prompt.addNetwork(General options)
      if ($didwm(2,%net)) { did -c $dname 2 $v1 }
      else { did -ca $dname 2 %net }
      _goptions.loadNetworkOptions
    }
    elseif ($did == 4) && ($did(2).seltext != $null) {
      var %text = $v1
      if (%text != (Default)) && ($_prompt.yesNo(Do you really want to remove $+(',%text,') settings?"General options)) {
        _script.setOption $+(TEMP-GeneralOptions-,%text)
        set $_script.variableName(GeneralOptions,dialog,networksToRemove) $addtok($_script.variableValue(GeneralOptions,dialog,networksToRemove),%text,32)
        did -d $dname 2 $did(2).sel
        did -c $dname 2 1
        did -r $dname 3000
        _goptions.loadNetworkOptions
      }
      dialog -v $dname
    }
    elseif ($did == 6) { _goptions.selectOptionsTab $dname $did(6).seltext }
    elseif ($istok($_goptions.tabsNumbers,$did,46)) { _goptions.selectOptionsTab $dname $did }

    ; __AUTOJOIN__
    elseif ($did == 102) {
      var %s = $did(102).seltext
      if (%s != $null) {
        did -e $dname 104,105,106,108
        did -ra $dname 108 $right($left($gettok(%s,2,32),-1),-1)
      }
      else {
        did -r $dname 108
        did -b $dname 104,105,106,108
      }
    }
    elseif ($did == 103) {
      var %c = $_prompt.input(<Channel> [password] to add:"~"Autojoin - Add channel"tch"AutojoinAddChannel), %chan = $gettok($_channel.fixName(%c),1,32), $&
        %pass = $remove($gettok(%c,2,32),$chr(40),$chr(41),;)
      if ($didwm(102,%chan)) || ($didwm(102,%chan *)) {
        _prompt.info Channel already listed. Halted."Autojoin
        return
      }
      did -a $dname 102 %chan $iif(%pass != $null,$+($chr(40),%pass,$chr(41)))
    }
    elseif ($did == 104) {
      if ($did(102).sel) { did -d $dname 102 $v1 }
      did -b $dname 104,105,106,108
      did -r $dname 108
    }
    elseif ($did isnum 105-106) { _dialog.upDownArrows $iif($did == 105,-u,-d) $dname 102 }
    elseif ($istok(109.110.111.112.115,$did,46)) { did $iif($did == 112,-e,-b) $dname 113 }

    ; __LOGIN__
    elseif ($did == 152) {
      var %s = $did(152).seltext
      if (%s != $null) {
        did -e $dname 154,156
        did -ra $dname 156 $right($left($gettok(%s,2,32),-1),-1)
      }
      else {
        did -r $dname 156
        did -b $dname 154,156
      }
    }
    elseif ($did == 153) {
      var %n = $_prompt.input(Nick to add:"~"Login - Add"tch"LoginAddNick), %p = $_prompt.input($+(%n,'s) password to login:"~"Login - Add"ph), %n = $remove(%n,$chr(40),$chr(41),;)
      if ($didwm(152,%n *)) {
        _prompt.info Nick already listed. Halted."Login
        return
      }
      did -a $dname 152 %n ( $+ %p $+ )
    }
    elseif ($did == 154) {
      if ($did(152).sel) { did -d $dname 152 $v1 }
      did -b $dname 154,156
      did -r $dname 156
    }
    elseif ($did == 159) { _goptions.loginOnSelected }
    elseif ($did == 164) { _tags.add $dname 163 LOGIN_COMMAND &Nick login: }

    ; __OPTIONS__
    elseif ($did == 259) { did $iif($did(259).state,-e,-b) $dname 260 }

    ; __LISTS__
    elseif ($did == 354) { did $iif($did(354).state,-e,-b) $dname 355 }
    elseif ($did == 356) { did $iif($did(356).state,-e,-b) $dname 357 }

    ; __AWAY__
    elseif ($did == 452) { did $iif($did(452).state,-e,-b) $dname 453 }
    elseif ($did == 463) { did $iif($did(463).state,-e,-b) $dname 464 }
    elseif ($did == 465) { did $iif($did(465).state,-e,-b) $dname 466 }
    elseif ($did == 467) { _tags.add $dname 466 }

    ; __ANNOUNCE__
    elseif ($did == 502) {
      if (!$did(502).state) { did -b $dname 503,504,505,506,507,508 }
      else {
        did -e $dname 503,505,507
        if ($did(503).state) { did -e $dname 504 }
        if ($did(505).state) { did -e $dname 506 }
        if ($did(507).state) { did -e $dname 508 }
      }
    }
    elseif ($did == 503) { did $iif($did(503).state,-e,-b) $dname 504 }
    elseif ($did == 505) { did $iif($did(505).state,-e,-b) $dname 506 }
    elseif ($did == 507) { did $iif($did(507).state,-e,-b) $dname 508 }
    elseif ($istok(512 516,$did,32)) { _tags.add $dname $calc($did - 1) AWAY_BACK_ANNOUNCE $iif($did == 512,A&way,&Back) announce: }
    elseif ($did == 513) { did -ra $dname 511 $_away.announceMessages(Away).default }
    elseif ($did == 517) { did -ra $dname 515 $_away.announceMessages(Back).default }
    elseif ($did == 518) { did $iif($did(518).state,-e,-b) $dname 519 }
    elseif ($did == 520) { did $iif($did(520).state,-e,-b) $dname 521 }

    ; __PAGER__
    elseif ($did == 552) { did $iif($did(552).state,-e,-b) $dname 553 }
    elseif ($did == 554) { did $iif($did(554).state,-e,-b) $dname 555 }
    elseif ($did == 558) { pagers }

    ; __REMINDER__
    elseif ($did == 652) { did $iif($did(652).state,-e,-b) $dname 653,655 }
    elseif ($did == 658) { did $iif($did(658).state,-e,-b) $dname 659 }
    elseif ($did == 660) { did $iif($did(660).state,-e,-b) $dname 661 }

    ; __ANTIDLE__
    elseif ($did == 702) { did $iif($did(702).state,-e,-b) $dname 703 }
    elseif ($did == 704) { did $iif($did(704).state,-e,-b) $dname 705 }

    ; __LAG CHECKING__
    elseif ($did == 752) { did $iif($did(752).state,-e,-b) $dname 753 }
    elseif ($did == 755) { did $iif($did(755).state,-e,-b) $dname 756 }

    ; __TITLEBAR__
    elseif ($did = 802) { did $iif($did(802).state,-e,-b) $dname 803 }
    elseif ($did == 807) && ($did(806).seltext) {
      did -ac $dname 809 $v1
      did -d $dname 806 $did(806).sel 
    }
    elseif ($did == 808) && ($did(809).seltext) {
      did -ac $dname 806 $v1
      did -d $dname 809 $did(809).sel
    }
    elseif ($did isnum 810-811) { _dialog.upDownArrows $iif($did == 810,-u,-d) $dname 809 }

    elseif ($did == 2000) {
      _goptions.saveNetworkOptions -p
      var %x = 1, %hashs = $_hash.allMatching(TEMP-GeneralOptions-&), %i
      while ($gettok(%hashs,%x,32) != $null) {
        %i = $v1
        _hash.toHash -o %i $gettok($_hash.notPrefixed(%i),2-,45)
        inc %x
      } 
      var %rem = $_script.variableValue(GeneralOptions,Dialog,networksToRemove), %x = 1, %i
      while ($gettok(%rem,%x,32) != $null) {
        %i = $v1
        hfree -w $_hash.prefixed($+(*,GeneralOptions-,%i))
        inc %x
      }

      ; Perform actions only on Ok button
      if ($server) { umodes -d }
    }
  }
  elseif ($devent == CLOSE) {
    _script.setOption GeneralOptions LastNetworkSelected $did(2).seltext
    _script.setOption GeneralOptions LastTabSelected $did(6).sel
    _lag.work
    _titlebar.work
    _antidle.work
    _away.autoAwayTimer
    _away.reminderTimer
    _regainick.onConnect
  }
}
alias -l _goptions.loginOnSelected {
  var %d = _goptions.general, %sel = $did(%d,159).sel
  if (%sel == 1) { did -b %d 161,163,164,166 }
  elseif (%sel == 2) {
    did -b %d 161,166
    did -e %d 163,164
  }
  else { did -e %d 161,163,164,166 }
}
alias _goptions.get {
  var %h, %opt
  if ($2 != $null) { 
    %h = $1
    %opt = $2
  }
  else {
    %h = $iif($_hash.exists($+(GeneralOptions-,$_network.active)) != $null,$v1,GeneralOptions-(Default))
    %opt = $1
  }
  %h = $iif($_hash.exists($+(GeneralOptions-,%h)) != $null,$v1,GeneralOptions-(Default))
  return $_script.getOption(%h,%opt) 
}
alias -l _goptions.loadNetworkOptions {
  var %dname = _goptions.general, %net = $did(%dname,2), %_net = %net

  did $iif(%_net == (Default),-b,-e) %dname 4
  _goptions.saveNetworkOptions
  if (%net == $null) { return }
  %net = $_hash.prefixed($+(TEMP-GeneralOptions-,%net))

  ; __IRC__
  did -u %dname 52,53,54,58,59,60,61,62,64,65,66
  if ($hget(%net,CommomChannelsOnQuery)) { did -c %dname 52 }
  if ($hget(%net,CloseQueryOnQuitUnotify)) { did -c %dname 53 }
  if ($hget(%net,CloseQueryOnChat)) { did -c %dname 54 }
  if ($hget(%net,NamesOnJoin)) { did -c %dname 58 }
  if ($hget(%net,TopicOnJoin)) { did -c %dname 59 }
  if ($hget(%net,StatisticsOnJoin)) { did -c %dname 60 }
  if ($hget(%net,SynchTimeOnJoin)) { did -c %dname 61 }
  if ($hget(%net,CreationTimeOnJoin)) { did -c %dname 62 }
  did -c %dname $calc(63 + $iif($int($hget(%net,OnInviteDo)) isnum 1-3,$v1,3))

  ; __AUTOJOIN__
  did -r %dname 102
  did -u %dname 110,111,112,115
  did -b %dname 104,105,106,108
  didtok %dname 102 59 $hget(%net,ChannelsToAutojoin)
  var %m = $calc($iif($int($hget(%net,AutojoinMode)) isnum 0-3,$v1,0) + 1)
  did -c %dname $gettok(110 111 112 115,%m,32)
  did $iif(%m == 3,-e,-b) %dname 113
  did -ra %dname 113 $iif($int($hget(%net,AutojoinDelay)) isnum 1-,$v1,5)

  ; __LOGIN__
  did -r %dname 152,156
  did -b %dname 154,156
  didtok %dname 152 59 $hget(%net,NicksToLogin)
  did -c %dname 159 $iif($int($hget(%net,LoginOn)) isnum 1-4,$v1,1)
  did -ra %dname 161 $hget(%net,LoginRequestString)
  did -ra %dname 163 $hget(%net,LoginCommand)
  did -ra %dname 166 $hget(%net,LoginServiceNick)
  _goptions.loginOnSelected

  ; __SERVICES__
  did -u %dname 202,204,205,206,207
  if ($didwm(202,$hget(%net,ServicesPopups))) { did -c %dname 202 $v1 }
  if ($hget(%net,ServicesOnStatus)) { did -c %dname 204 }
  if ($hget(%net,ServicesOnChannel)) { did -c %dname 205 }
  if ($hget(%net,ServicesOnNicklist)) { did -c %dname 206 }
  if ($hget(%net,UseMsgInsteadOfRaw)) { did -c %dname 207 }
  did -ra %dname 209 $hget(%net,ServicesNicks)
  did -ra %dname 211 $hget(%net,ServicesSites)

  ; __OPTIONS__
  did -u %dname 259,261
  did -c %dname 255 $iif($hget(%net,DefaultClonesMask) isnum 0-19,$calc($v1 + 1),3)
  did -c %dname 257 $iif($hget(%net,DefaultIgnoresMask) isnum 0-19,$calc($v1 + 1),21)
  if ($hget(%net,AutoRegainNick)) { 
    did -c %dname 259
    did -e %dname 260
  }
  else { did -b %dname 260 }
  did -ra %dname 260 $hget(%net,AutoRegainThisNick)
  if ($hget(%net,AskBeforeAutoRegain)) { did -c %dname 261 } 

  ; __USERMODES__
  did -u %dname 308,309,310,311,312,315,316,317,318,319
  var %x = 1
  while (%x <= 2) {
    if (%x == 1) { var %modes = $hget(%net,UsermodesDefault), %others = $hget(%net,UsermodesDefaultOthers), %cid = 308, %eid = 313 }
    else { var %modes = $hget(%net,UsermodesAway), %others = $hget(%net,UsermodesAwayOthers), %cid = 315, %eid = 320 }
    var %m = i,g,h,w,s, %y = 1
    while ($gettok(%m,%y,44)) {
      if ($v1 isincs %modes) { did -c %dname %cid }
      inc %y
      inc %cid
    }
    did -ra %dname %eid $gettok(%others,1,32)
    inc %x
  }

  ; __LISTS__
  did -u %dname 354,356
  did -b %dname 355,357
  did -c %dname 353 $iif($int($hget(%net,UpdateIALOn)) isnum 1-3,$v1,1)
  if ($hget(%net,AskBeforeUpdateIAL)) { 
    did -c %dname 354
    did -e %dname 355
  }
  did -ra %dname 355 $iif($int($hget(%net,AskBeforeUpdateIALMoreThan)) isnum 1-,$v1,200)
  if ($hget(%net,DontUpdateIAL)) {
    did -c %dname 356
    did -e %dname 357
  }
  did -ra %dname 357 $iif($int($hget(%net,DonUpdateIALMoreThan)) isnum 1-,$v1,400)
  did -c %dname 360 $iif($int($hget(%net,UpdateIBLOn)) isnum 1-3,$v1,1)

  ; __OTHERS__
  did -u %dname 402,403,404,405,406,407,408,409
  if ($hget(%net,ShowNotifiedJoin)) { did -c %dname 402 }
  if ($hget(%net,ShowNotifiedChangeNick)) { did -c %dname 403 }
  if ($hget(%net,ShowBannedNicks)) { did -c %dname 404 }
  if ($hget(%net,ShowUnbannedNicks)) { did -c %dname 405 }
  if ($hget(%net,ShowClonesInJoinLine)) { did -c %dname 406 }
  if ($hget(%net,ShowAlphabeticSortedChannels)) { did -c %dname 407 }
  if ($hget(%net,AutoWhowasFailedWhois)) { did -c %dname 408 }
  if ($hget(%net,AutoDelayAmsgAme)) { did -c %dname 409 }

  ; __AWAY__
  did -u %dname 452,455,456,458,459,460,462,463,465
  if ($hget(%net,ActivateAutoAway)) {
    did -c %dname 452
    did -e %dname 453
  }
  else { did -b %dname 453 }
  did -ra %dname 453 $iif($int($hget(%net,ActivateAutoAwayAfter)) isnum 1-,$v1,15)
  if ($hget(%net,WarnBeforeAutoAway)) { did -c %dname 455 }
  if ($hget(%net,QuietAwayOnAutoAway)) { did -c %dname 456 }
  if ($hget(%net,DisableSoundsWhileAway)) { did -c %dname 458 }
  if ($hget(%net,DisableBeepsWhileAway)) { did -c %dname 459 }
  if ($hget(%net,DisableFlashingWhileAway)) { did -c %dname 460 }
  if ($hget(%net,CloseOpenQueriesOnAway)) { did -c %dname 462 }
  if ($hget(%net,DeopOnAway)) { 
    did -c %dname 463
    did -e %dname 464
  }
  else { did -b %dname 464 }
  did -ra %dname 464 $hget(%net,DeopOnAwayExcept)
  if ($hget(%net,ChangeNickOnAway)) { 
    did -c %dname 465
    did -e %dname 466
  }
  else { did -b %dname 466 }
  did -ra %dname 466 $iif($hget(%net,ChangeNickOnAwayTo) != $null,$v1,<ME>_)

  ; __ANNOUNCE__
  did -u %dname 502,503,505,507,518,520
  if ($hget(%net,AnnounceAwayBack)) {
    did -c %dname 502
    did -e %dname 503,504,505,506,507,508
  }
  else { did -b %dname 503,504,505,506,507,508 }
  if ($hget(%net,AnnounceAwayBackChannels)) { did -c %dname 503 }
  if ($hget(%net,AnnounceAwayBackQueries)) { did -c %dname 505 }
  if ($hget(%net,AnnounceAwayBackChats)) { did -c %dname 507 }
  did -c %dname 504 $iif($int($hget(%net,AnnounceAwayBackChannelsUsing)) isnum 1-3,$v1,1)
  did -c %dname 506 $iif($int($hget(%net,AnnounceAwayBackQueriesUsing)) isnum 1-3,$v1,1)
  did -c %dname 508 $iif($int($hget(%net,AnnounceAwayBackChatsUsing)) isnum 1-3,$v1,1)
  if ($did(%dname,502).state) {
    if ($did(%dname,503).state) { did -e %dname 504 }
    else { did -b %dname 504 }
    if ($did(%dname,505).state) { did -e %dname 506 }
    else { did -b %dname 506 }
    if ($did(%dname,507).state) { did -e %dname 508 }
    else { did -b %dname 508 }
  }
  did -ra %dname 511 $iif($hget(%net,AnnounceAwayMessage) != $null,$v1,$_away.announceMessages(Away).default)
  did -ra %dname 515 $iif($hget(%net,AnnounceBackMessage) != $null,$v1,$_away.announceMessages(Back).default)
  if ($hget(%net,AnnounceAwayBackExcept)) {
    did -c %dname 518
    did -e %dname 519
  }
  else { did -b %dname 519 } 
  did -ra %dname 519 $hget(%net,AnnounceAwayBackExceptTo)
  if ($hget(%net,AnnounceAwayBackExceptIdle)) {
    did -c %dname 520
    did -e %dname 521
  }
  else { did -b %dname 521 } 
  did -ra %dname 521 $iif($int($hget(%net,AnnounceAwayBackExceptIdleHigher)) isnum 1-,$v1,5)

  ; __PAGER__
  did -u %dname 552,554,556,557
  if ($hget(%net,EnablePager)) {
    did -c %dname 552
    did -e %dname 553
  }
  else { did -b %dname 553 }
  did -c %dname 553 $iif($int($hget(%net,EnablePagerWhen)) isnum 1-3,$v1,1)
  if ($hget(%net,WarnPagerReceived)) {
    did -c %dname 554
    did -e %dname 555
  }
  else { did -b %dname 555 }
  did -c %dname 555 $iif($int($hget(%net,WarnPagerReceivedWhen)) isnum 1-4,$v1,1)
  if ($hget(%net,DeletePagersOnAway)) { did -c %dname 556 }
  if ($hget(%net,ShowPagersOnBack)) { did -c %dname 557 }

  ; __LOG__
  did -u %dname 602,603,604,605,607,608,609,610,611,612
  did -c %dname $calc(601 + $iif($int($hget(%net,AwayLogChannelsWhen)) isnum 1-4,$v1,1))
  did -c %dname $calc(606 + $iif($int($hget(%net,AwayLogPrivateMessagesWhen)) isnum 1-4,$v1,1))
  if ($hget(%net,DeleteLogOnAway)) { did -c %dname 611 }
  if ($hget(%net,SaveLogsOnBack)) { did -c %dname 612 }

  ; __REMINDER__
  did -u %dname 652,656,657,658.660
  if ($hget(%net,RemindAway)) {
    did -c %dname 652
    did -e %dname 653,655
  }
  else { did -b %dname 653,655 }
  did -ra %dname 653 $iif($int($hget(%net,RemindAwayEvery)) isnum 1-,$v1,30)
  did -c %dname 655 $iif($int($hget(%net,RemindAwayTo)) isnum 1-3,$v1,1)
  if ($hget(%net,RemindAwayOnPrivateMessage)) { did -c %dname 656 }
  if ($hget(%net,RemindAwayOnChannelHighlight)) { did -c %dname 657 }
  if ($hget(%net,RemindAwayOnWords)) {
    did -c %dname 658
    did -e %dname 659
  }
  else { did -b %dname 659 }
  did -ra %dname 659 $hget(%net,RemindAwayOnThisWords)
  if ($hget(%net,RemindAwayExcept)) {
    did -c %dname 660
    did -e %dname 661
  }
  else { did -b %dname 661 }
  did -ra %dname 661 $hget(%net,RemindAwayExceptThis)

  ; __ANTIDLE__
  did -u %dname 702,704
  if ($hget(%net,EnableAntidle)) {
    did -c %dname 702
    did -e %dname 703
  }
  else { did -b %dname 703 }
  did $iif($hget(%net,AntidleWhileAway),-c,-u) %dname 703
  if ($hget(%net,PauseAntidleIfHigher)) {
    did -c %dname 704
    did -e %dname 705
  }
  else { did -b %dname 705 }
  did -ra %dname 705 $iif($int($hget(%net,PauseAntidleIfHigherThan)) isnum 1-,$v1,6)
  did -ra %dname 707 $iif($int($hget(%net,MaximumAntidleTime)) isnum 1-,$v1,20)

  ; __LAG CHECKING__
  did -u %dname 752,755
  if ($hget(%net,CheckLag)) {
    did -c %dname 752
    did -e %dname 753
  }
  else { did -b %dname 753 }
  did -ra %dname 753 $iif($int($hget(%net,CheckLagEvery)) isnum 1-,$v1,3)
  if ($hget(%net,WarnLagHigher)) {
    did -c %dname 755
    did -e %dname 756
  }
  else { did -b %dname 756 }
  did -ra %dname 756 $iif($int($hget(%net,WarnLagHigherThan)) isnum 1-,$v1,10)
  did -c %dname 759 $iif($int($hget(%net,LagCheckMethod)) isnum 1-3,$v1,1)

  ; __TITLEBAR__
  did -r %dname 806,809
  if ($hget(%net,UpdateTitlebar)) { 
    did -c %dname 802
    did -e %dname 803
  }
  else {
    did -u %dname 802
    did -b %dname 803
  }
  did -ra %dname 803 $iif($int($hget(%net,UpdateTitlebarEvery)) isnum 1-,$v1,3)
  didtok %dname 809 95 $remove($hget(%net,TitlebarText),<,>)
  var %m = Nick_Usermode_Lag_Network_Active window_Away status_Idle_Time_System uptime_Server uptime_mIRC uptime_Date_Script name_Profile_Channel Statistics, %x = 1, %i 
  while (%x <= 15) { 
    %i = $gettok(%m,%x,95) 
    if (!$didwm(%dname,809,%i)) { did -a %dname 806 %i } 
    inc %x 
  }

  did -ra %dname 3000 %_net
}
alias -l _goptions.saveNetworkOptions { 
  var %dname = _goptions.general, %_net = $did(%dname,3000), %item = $+(TEMP-GeneralOptions-,%_net), %» = _script.setOption %item
  if (%_net == $null) || (!$dialog(%dname)) { return }

  ; __IRC__
  %» CommomChannelsOnQuery $did(52).state
  %» CloseQueryOnQuitUnotify $did(53).state
  %» CloseQueryOnChat $did(54).state
  %» NamesOnJoin $did(58).state
  %» TopicOnJoin $did(59).state
  %» StatisticsOnJoin $did(60).state
  %» SynchTimeOnJoin $did(61).state
  %» CreationTimeOnJoin $did(62).state
  %» OnInviteDo $iif($did(64).state,1,$iif($did(65).state,2,3))

  ; __AUTOJOIN__
  %» ChannelsToAutojoin $didtok(%dname,102,59)
  var %m = 0
  if ($did(%dname,111).state) { %m = 1 }
  elseif ($did(%dname,112).state) { %m = 2 }
  elseif ($did(%dname,115).state) { %m = 3 }
  %» AutojoinMode %m
  %» AutojoinDelay $did(%dname,113)

  ; __LOGIN__
  %» NicksToLogin $didtok(%dname,152,59)
  %» LoginOn $did(%dname,159).sel
  %» LoginRequestString $did(%dname,161)
  %» LoginCommand $did(%dname,163)
  %» LoginServiceNick $did(%dname,166)

  ; __OPTIONS__
  %» DefaultClonesMask $calc($did(%dname,255).sel - 1)
  %» DefaultIgnoresMask $calc($did(%dname,257).sel - 1)
  %» AutoRegainNick $did(%dname,259).state
  %» AutoRegainThisNick $did(%dname,260)
  %» AskBeforeAutoRegain $did(%dname,261).state

  ; __USERMODES__
  var %x = 1
  while (%x <= 2) {
    if (%x == 1) { var %cid = 308, %eid = 313, %m1 = UsermodesDefault, %m2 = UsermodesDefaultOthers }
    else { var %cid = 315, %eid = 320, %m1 = UsermodesAway, %m2 = UsermodesAwayOthers }
    var %mds = i,g,h,w,s, %y = 1, %temp, %final = ""
    while ($gettok(%mds,%y,44)) {
      %temp = $v1
      if ($did(%dname,%cid).state) { %final = %final $+ %temp }
      inc %y 
      inc %cid
    }
    %» %m1 %final
    %» %m2 $did(%dname,%eid)
    inc %x
  }

  ; __SERVICES__
  %» ServicesPopups $did(%dname,202).seltext
  %» ServicesOnStatus $did(%dname,204).state
  %» ServicesOnChannel $did(%dname,205).state
  %» ServicesOnNicklist $did(%dname,206).state
  %» UseMsgInsteadOfRaw $did(%dname,207).state
  %» ServicesNicks $did(%dname,209)
  %» ServicesSites $did(%dname,211)

  ; __LISTS__
  %» UpdateIALOn $did(%dname,353).sel
  %» AskBeforeUpdateIAL $did(%dname,354).state
  %» AskBeforeUpdateIALMoreThan $did(%dname,355)
  %» DontUpdateIAL $did(%dname,356).state
  %» DontUpdateIALMoreThan $did(%dname,357)
  %» UpdateIBLOn $did(%dname,360).sel

  ; __OTHERS__
  %» ShowNotifiedJoin $did(%dname,402).state
  %» ShowNotifiedChangeNick $did(%dname,403).state
  %» ShowBannedNicks $did(%dname,404).state
  %» ShowUnbannedNicks $did(%dname,405).state
  %» ShowClonesInJoinLine $did(%dname,406).state
  %» ShowAlphabeticSortedChannels $did(%dname,407).state
  %» AutoWhowasFailedWhois $did(%dname,408).state
  %» AutoDelayAmsgAme $did(%dname,409).state

  ; __AWAY__
  %» ActivateAutoAway $did(%dname,452).state
  %» ActivateAutoAwayAfter $did(%dname,453)
  %» WarnBeforeAutoAway $did(%dname,455).state
  %» QuietAwayOnAutoAway $did(%dname,456).state
  %» DisableSoundsWhileAway $did(%dname,458).state
  %» DisableBeepsWhileAway $did(%dname,459).state
  %» DisableFlashingWhileAway $did(%dname,460).state
  %» CloseOpenQueriesOnAway $did(%dname,462).state
  %» DeopOnAway $did(%dname,463).state
  %» DeopOnAwayExcept $did(%dname,464)
  %» ChangeNickOnAway $did(%dname,465).state
  %» ChangeNickOnAwayTo $did(%dname,466)

  ; __ANNOUNCE__
  %» AnnounceAwayBack $did(%dname,502).state
  %» AnnounceAwayBackChannels $did(%dname,503).state
  %» AnnounceAwayBackQueries $did(%dname,505).state
  %» AnnounceAwayBackChats $did(%dname,507).state
  %» AnnounceAwayBackChannelsUsing $did(%dname,504).sel
  %» AnnounceAwayBackQueriesUsing $did(%dname,506).sel
  %» AnnounceAwayBackChatsUsing $did(%dname,508).sel
  %» AnnounceAwayMessage $did(%dname,511)
  %» AnnounceBackMessage $did(%dname,515)
  %» AnnounceAwayBackExcept $did(%dname,518).state
  %» AnnounceAwayBackExceptTo $did(%dname,519)
  %» AnnounceAwayBackExceptIdle $did(%dname,520).state
  %» AnnounceAwayBackExceptIdleHigher $did(%dname,521)

  ; __PAGER__
  %» EnablePager $did(%dname,552).state
  %» EnablePagerWhen $did(%dname,553).sel
  %» WarnPagerReceived $did(%dname,554).state
  %» WarnPagerReceivedWhen $did(%dname,555).sel
  %» DeleteNickPagersOnAway $did(%dname,556).state
  %» ShowPagersOnBack $did(%dname,557).state

  ; __LOG__
  var %l
  if ($did(%dname,602).state) { %l = 1 }
  elseif ($did(%dname,603).state) { %l = 2 }
  elseif ($did(%dname,604).state) { %l = 3 }
  else { %l = 4 }
  %» AwayLogChannelsWhen %l
  if ($did(%dname,607).state) { %l = 1 }
  elseif ($did(%dname,608).state) { %l = 2 }
  elseif ($did(%dname,609).state) { %l = 3 }
  else { %l = 4 }
  %» AwayLogPrivateMessagesWhen %l
  %» DeleteLogOnAway $did(%dname,611).state
  %» SaveLogsOnBack $did(%dname,612).state

  ; __REMINDER__
  %» RemindAway $did(%dname,652).state
  %» RemindAwayEvery $did(%dname,653)
  %» RemindAwayTo $did(%dname,655).sel
  %» RemindAwayOnPrivateMessage $did(%dname,656).state
  %» RemindAwayOnChannelHighlight $did(%dname,657).state
  %» RemindAwayOnWords $did(%dname,658).state
  %» RemindAwayOnThisWords $did(%dname,659)
  %» RemindAwayExcept $did(%dname,660).state
  %» RemindAwayExceptThis $did(%dname,661)

  ; __ANTIDLE__
  %» EnableAntidle $did(%dname,702).state
  %» AntidleWhileAway $did(%dname,703).state
  %» PauseAntidleIfHigher $did(%dname,704).state
  %» PauseAntidleIfHigherThan $did(%dname,705)
  %» MaximumAntidleTime $did(%dname,707)

  ; __LAG CHECKING__
  %» CheckLag $did(%dname,752).state
  %» CheckLagEvery $did(%dname,753)
  %» WarnLagHigher $did(%dname,755).state
  %» WarnLagHigherThan $did(%dname,756)
  %» LagCheckMethod $did(%dname,759).sel

  ; __TITLEBAR__
  %» UpdateTitlebar $did(%dname,802).state
  %» UpdateTitlebarEvery $did(%dname,803)
  var %x = 1 
  while ($did(%dname,809,%x) != $null) { 
    var %tag = < $+ $v1 $+ >, %text = $addtok(%text,%tag,95) 
    inc %x 
  } 
  %» TitlebarText %text
}
alias -l _goptions.tabsNumbers { return 50.100.150.200.250.300.350.400. .450.500.550.600.650. .700.750.800 }
alias -l _goptions.tabsDescription { return IRC.- Autojoin.- Nick login.- Services.- Options.- Usermodes.- Lists.- Others. .Away.- Announcer.- Pager.- Logging.- Reminder. .Antidle.Lag checking.Titlebar }
alias -l _goptions.selectOptionsTab {
  var %dname = $1, %sel = $2-
  if ($dialog(%dname)) {
    var %tabs = $_goptions.tabsNumbers, %desc = $_goptions.tabsDescription
    if ($findtok(%tabs,%sel,1,46)) {
      var %n = $v1
      did -c %dname 6 %n
      .timer -omi 1 0 did -c %dname $gettok(%tabs,%n,46)
    }
    elseif ($findtok(%desc,%sel,1,46)) { did -c %dname $gettok(%tabs,$v1,46) }
    else { did -c %dname 40 }
  }
}
alias -l _goptions.listLabels {
  var %t = IRC,IRC - Autojoin,IRC - Nick login,IRC - Services,IRC - Options,IRC - Usermodes,IRC - Lists,IRC - Others,Away,Away - Announcer,Away - Pager,Away - Logging,Away - Reminder,Antidle,Lag checking,Titlebar, %x = 1, $&
    %total = $numtok(%t,44)
  while (%x <= %total) {
    did -g _goptions.general $calc(2000 + %x) $_dialog.labelFile(220,13,$gettok(%t,%x,44))
    inc %x
  }
}


;__________________[ wizard ]_________________________________________

alias wizard { 
  if ($isid) { $_advanced.openDialog(_wizard,wizard,_wizard).modal }
  else { _advanced.openDialog _wizard wizard }
}

dialog _wizard {
  title "First Runtime Wizard"
  size -1 -1 222 173
  option dbu

  box "", 1000, -12 142 300 48
  button "&Cancel", 1001, 76 154 40 11, cancel
  button "<< &Back", 1002, 132 154 40 11, disable
  button "&Next >>", 1003, 174 154 40 11, default
  text "Press 'Next' button to continue", 1004, 10 130 200 8

  tab "Tab 1", 100, -50 -50 398 399
  text "Welcome!", 101, 10 10 200 8, tab 100
  text "This wizard allow you to configure must important script settings that can affect the way script behaves. Because this it a first runtime dialog some options like 'Set default settings' should be on or you'll have to configure all by yourself.", 102, 10 28 200 29, tab 100
  text "After this dialog script will ask you to load a mTS theme. If you want to set up all script at you own way use Menubar\Options menu.", 103, 10 62 200 30, tab 100 hide

  tab "Tab 2", 200
  text "If this is your first runtime you should select this option to avoid set up all script by yourself.", 201, 10 10 200 14, tab 200
  check "&Set script settings to default (recommended)", 202, 11 27 137 10, tab 200
  text "Script let you to compile all settings into a single file that can be imported later. This is a useful feature to avoid lost of data during a forced mIRC exit for example. You can compile it whenever you want using /settings command or program script to do it for you on start and/or exit.", 203, 10 45 200 28, tab 200
  check "C&ompile backup file every N times script is started:", 204, 11 91 133 10, tab 200
  edit "40", 205, 147 91 50 11, tab 200 autohs right disable
  check "Co&mpile backup file every N times script is closed:", 206, 11 104 133 10, tab 200
  edit "20", 207, 147 104 50 11, tab 200 autohs right

  tab "Tab 3", 300
  check "&Enable automatic away after", 301, 11 10 80 10, tab 300
  edit "15", 302, 92 10 41 11, tab 300 autohs right disable
  text "minutes of idle time", 303, 135 11 64 8, tab 300
  check "&Warn me before setting", 304, 21 23 132 10, tab 300 disable
  check "&Quit away (without announcing)", 305, 21 34 150 10, tab 300 disable
  text "You can find some problems using lag checking in some networks. Maybe notices are the best method to use but in some cases raws are more efficient", 306, 10 57 200 14, tab 300
  check "C&heck lag every", 307, 11 75 50 10, tab 300
  edit "3", 308, 61 75 41 11, tab 300 autohs right
  text "seconds using", 309, 104 76 35 8, tab 300
  combo 310, 140 75 41 50, tab 300 size drop
  text "You can avoid channel idle kicks turning on antidle.", 311, 10 97 200 8, tab 300
  check "Ena&ble antidle avoiding more than", 312, 11 109 92 10, tab 300
  edit "20", 313, 104 109 41 11, tab 300 autohs right disable
  text "seconds of idle time", 314, 147 110 63 8, tab 300

  tab "Tab 4", 400
  text "Miscelaneous important toogles.", 401, 10 10 200 8, tab 400
  check "A&uto delay /amsg and /ame commands", 402, 11 22 150 10, tab 400
  check "C&heck if any theme is loaded on start", 403, 11 33 150 10, tab 400
  check "&Show commands in front of each menu item", 404, 11 44 150 10, tab 400
  check "Sh&ow [/commands] on dialog titlebar", 405, 11 55 150 10, tab 400
  ;; check "&Restart script now", 406, 11 87 84 10, tab 400
}
on *:DIALOG:_wizard:*:*:{
  if ($devent == INIT) {
    did -ra $dname 101 Welcome to $_script.name $+ !
    if ($dialog($dname).modal) { did -v $dname 103 }
    did -c $dname 202,206,304,307,402,403,405
    didtok $dname 310 44 Notice,CTCP,Raws
    did -c $dname 310 1
  }
  elseif ($devent == SCLICK) {
    if ($did == 204) { did $iif($did(204).state,-e,-b) $dname 205 }
    elseif ($did == 206) { did $iif($did(206).state,-e,-b) $dname 207 }
    elseif ($did == 301) { did $iif($did(301).state,-e,-b) $dname 302,304,305 }
    elseif ($did == 307) { did $iif($did(307).state,-e,-b) $dname 308,310 }
    elseif ($did == 312) { did $iif($did(312).state,-e,b) $dname 313 }

    elseif ($did == 1002) {
      var %ctab = $dialog($dname).tab, %ntab = $calc(%ctab - 100)
      did -c $dname %ntab
      if (%ctab == $_wizard.lastTab) { did -ra $dname 1003 &Next >> }
      if (%ntab == 100) { 
        did -b $dname $did
        did -t $dname 1003
        did -ra $dname 1004 Press 'Next' button to continue
      }
    }
    elseif ($did == 1003) {
      var %ctab = $dialog($dname).tab
      if (%ctab == $_wizard.lastTab) { _wizard.applySettings } 
      else {
        var %ntab = $calc(%ctab + 100)
        did -c $dname %ntab
        did -e $dname 1002
        if (%ntab == $_wizard.lastTab) {
          did -ra $dname 1003 &Apply
          did -ra $dname 1004 Press 'Apply' to close dialog and set all options
        }
      }
    }
  }
}
alias -l _wizard.lastTab { return 400 }
alias -l _wizard.applySettings {
  var %d = _wizard, %s = _script.setOption Settings

  if ($did(%d,202).state) { .settings -d }
  %s BackupOnStart $did(%d,204).state
  %s BackupOnStartN $did(%d,205)
  %s BackupOnClose $did(%d,206).state
  %s BackupOnCloseN $did(%d,207)

  %s = _script.setOption GeneralOptions-(Default)
  %s ActivateAutoAway $did(%d,301).state
  %s ActivateAutoAwayAfter $did(%d,302)
  %s WarnBeforeAutoAway $did(%d,304).state
  %s QuietAwayOnAutoAway $did(%d,305).state
  %s CheckLag $did(%d,307).state
  %s CheckLagEvery $did(%d,308)
  %s LagCheckMethod $did(%d,310).sel
  %s EnableAntidle $did(%d,312).state
  %s MaximumAntidleTime $di(%d,313)

  %s = _script.setOption
  %s GeneralOptions-(Default) AutoDelayAmsgAme $did(%d,402).state
  %s Themes CheckLoadedThemeOnStart $did(%d,403).state
  %s Advanced ShowCommandOnMenu $did(%d,404).state
  %s Advanced ShowCommandOnTitlebar $did(%d,405).state
  ;; var %restart = $did(%d,406).state

  dialog -x %d
  ;; if (%restart) { .restart }
}



;_____________[ connection ]____________________________________

alias _connection.recent {
  var %n = $iif($1 isnum $+(1-,$_connection.listLimit),$int($1),0), %srvs = $_script.getOption(Connection,List)
  if (%n == 0) { return $numtok(%srvs,59) }
  return $gettok($gettok(%srvs,%n,59),1-2,32)
}
alias _connection.onConnectEvent { _script.setRecentOption $_connection.listLimit Connection List $server $port }
alias _connection.menusHandler {
  var %n = $1
  if (%n > $_connection.listLimit) { return }
  if ($_connection.recent(%n) != $null) { 
    var %t = $v1, %srv = $gettok(%t,1,32), %port = $gettok(%t,2,32)
    if ($prop == remove) { return $+(%n,.) %srv $chr(9) $_string.surrounded($iif(%port isnum 0-,$ifmatch,6667)) : _connection.removeRecent %n }
    return $+(%n,.) %srv $chr(9) $_string.surrounded($iif(%port isnum 0-,$ifmatch,6667)) : srv $iif($prop == new,-n,-c) %srv %port
  }
}
alias _connection.removeRecent {
  var %n = $1
  if ($_connection.recent(%n)) { 
    _script.deleteRecentOption %n Connection List
    _themes.infoEcho -a Deleted $+(,$ord(%n),) server from servers connection list.  
  }
}
alias _connection.clearList {
  if ($_prompt.yesNo(Do you really want to delete servers connection list?"Connection)) { _script.setOption Connection List }
}
alias _connection.addToList {
  var %t = $_prompt.input(Server to add to servers connection list (followed by port number or default 6667 will be used):" $iif($server,$server $port) "Connection"tc"AddToConnectionList), $&
    %srv = $gettok(%t,1,32), %p = $iif($int($gettok(%t,2,32)) isnum 0-,$v1,6667)
  if (%srv != $null) { 
    _script.setRecentOption $_connection.listLimit Connection List %srv %p
    _themes.infoEcho -a Added $+(,%srv,) (Port: $+(,%p,) $+ ) to servers connection list. 
  }
}
alias _connection.setListLimit {
  var %n = $int($iif($int($1) isnum 1-,$1,$_prompt.inputNumber(1,50,$_connection.listLimit,h,New limit to servers connection list length:,Connection)))
  if (%n isnum 1-) { _script.setOption Connection ListLimit %n }
}
alias _connection.listLimit { return $iif($int($_script.getOption(Connection,ListLimit)) isnum 1-,$v1,15) }


;______________[ recent ]_______________________________

alias _recent.listLimit { 
  if ($int($_script.getOption(Recent,$iif(c isin $1,ChannelsListLimit,NicksListLimit))) isnum 1-) { return $v1 }
  return 15
}
alias _recent.setListLimit {
  var %l = $int($_prompt.inputNumber(1,50,$_recent.listLimit($1),h,New $iif(c isin $1,channels,nicks) recent list length:,Recent))
  if (%l isnum 1-) { _script.setOption Recent $iif(c isin $1,ChannelsListLimit,NicksListLimit) %l }
}
alias _recent.addItem { _script.setRecentOption $_recent.listLimit($1) Recent $iif(c isin $1,ChannelsList,NicksList) $iif(c isin $1,$_channel.fixName($2),$2) }
alias _recent.item {
  var %n = $iif($int($2) isnum $+(0-,$_recent.listLimit($1)),$v1), %list = $_script.getOption(Recent,$iif(c isin $1,ChannelsList,NicksList))
  if (%n == 0) { return $numtok(%list,59) }
  return $gettok(%list,%n,59)
}
alias _recent.removeItem {
  var %h = $iif(c isin $1,ChannelsList,NicksList), %tmp = $iif(c isin $1,channels,nicks)
  if (a isincs $1) {
    if ($_recent.item($1,0)) && ($_prompt.yesNo(Do you really want to delete %tmp recent list?"Recent)) {
      _script.setOption Recent %h
      _themes.infoEcho -a Deleted recent %tmp list.
    }
  }
  else {
    var %n = $_prompt.inputNumber(1,$_recent.listLimit($1),-,h,Item number to remove from %tmp recent list:,Recent)
    if ($_recent.item($1,%n)) {
      _script.deleteRecentOption %n Recent %h 
      _themes.infoEcho -a Deleted $_string.toBold($ord(%n)) item from %tmp recent list.
    }
  }
}
alias _recent.menuHandler {
  var %n = $2, %flg = $1
  if (%n > $_recent.listLimit(%flg)) { return }
  if ($_recent.item(%flg,%n) != $null) { 
    %tmp = $v1
    return $+(%n,.) %tmp : $iif(c isin %flg,join,nick) %tmp
  }
}



;______________[ news ]_____________________________________________

alias news { _script.featureNotAvailable News }
dialog _news {
  title "News"
  size -1 -1 301 153
  option dbu

  radio "&All", 1, 6 7 24 10
  radio "&Not readed", 2, 35 7 43 10
  list 3, 5 18 290 91, size
  box "", 4, 5 111 290 19
  text "News status", 5, 11 118 279 8

  button "&Get news", 100, 212 136 40 11
  button "&Close", 99, 255 136 40 11, cancel
}
on *:DIALOG:_news:*:*:{
  if ($devent == INIT) {
    did -c $dname $_news.toGet
    _news.status Ready to get available news. $iif($_news.lastTimeCheched,Last check: $asctime($v1) $+ .)
    _news.listFile
  }
  elseif ($devent == SCLICK) {
    if ($did isnum 1-2) {
      _script.setOption News ToGet $did
      _news.listFile
    }
    elseif ($did == 100) { _news.get }
  }
}
alias _news.status {
  if ($dialog(_news)) { did -ra _news 5 STATUS: $iif($1 != $null,$1-,News status) }
}
alias _news.toGet { return $iif($int($_script.getOption(News,ToGet)) isnum 1-2,$v1,1) }
alias _news.lastTimeChecked { return $iif($_script.getOption(News,LastCheck) isnum 1-,$v1,0)  }
alias _news.get {
  var %d = _news
  if (!$dialog(%d)) { return }
  did -b %d 100
  __dummy $_httpDownload.get($_news.address,80,_news.getHandler,$_script.directory(temporary,q), 0)
}

alias _news.address { return http://student.dei.uc.pt/~jcorreia/sites/FeedbacK/updates/ }
alias _news.file { return news.txt }
alias _news.completeAddress { return $+($_news.address,$_news.file) }
alias _news.completeFile { return $_script.directory(temporary,$null,$_news.file) }
alias _news.getHandler {
  tokenize 32 $1-
  var %d = _news
  if (!$dialog(%d)) { 
    sockclose $1 
    return
  }
  if (*_ERR iswm $1) {
    _news.status Error while getting news file $_string.surrounded($3-) $+ . Please try back later!
    did -e %d 100
  }
  elseif ($1 == SOCKOPEN) { _news.status Opening connection to server... }
  elseif ($1 == SOCKREAD) {
    if ($2 == Starting) { _news.status Starting news file download... }
    elseif ($2 == Downloading) { _news.status Downloading news file... }
  }
  else {
    _news.status Download concluded. Listing news...
    _scipt.setOption News LastCheck $ctime
    _news.listFile
    did -e %d 100
  }
}
alias _news.listFile {
  var %f = $_news.completeFile, %t = $_news.toGet, %d = _news
  if (!$dialog(%d)) { return }
  did -r %d 3
  if (!$isfile(%f)) { _news.status News file not available. Please try to downloaded it again! } 
  else {
    var %x = 1
    while ($read(%f,%x) != $null) {
      tokenize 32 $v1
      if (%t == 1) || ($1 >= $_news.lastTimeChecked) { did -a %d 3 $_string.surrounded($asctime($1)) $2-  }
      inc %x
    }
    _news.status Available news file listed.
  }
}



;_____________[ update ]___________________________

alias update { _script.featureNotAvailable Update }
