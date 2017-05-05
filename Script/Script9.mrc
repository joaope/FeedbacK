;______________[ themes ]__________________________________________

alias theme {
  ; /theme [-u | N] [filename]
  ; N is the number of scheme to be loaded
  ; -u unload current loaded theme
  var %n = $1, %file = $2-
  if (%n isnum 1-) && ($isfile(%file)) { }
  elseif ($isfile($1-)) { 
    %file = $1- 
    %n = 0
  }
  else {
    if ($1 == -start) { $_advanced.openDialog(_themes,themes).modal }
    else { _advanced.openDialog _themes themes }
    return
  }
  _themes.loadTheme %n %file
}
alias themes { theme }
alias schemes { theme }
; MTS PUBLIC ALIASES
alias mtsversion { return 1.1 }
alias theme.setting { return $_themes.getText($1) }
alias theme.load { theme $1- }
alias theme.schemes { theme }
; END

dialog _themes {
  title "Themes"
  size -1 -1 288 191
  option dbu

  text "&Folder:", 1, 5 8 25 8
  list 2, 4 16 73 123, size
  button "...", 3, 67 6 9 10
  text "&Schemes:", 4, 5 143 29 8
  combo 5, 4 151 73 50, size drop

  box "", 10, -20 -3 500 171
  icon 11, 92 21 182 13, $mircexe, 0

  list 2000, 0 0 0 0, disable hide

  tab "&Informations", 50, 85 3 197 157
  text "Author:", 51, 93 42 25 8, tab 50
  text "Email:", 52, 93 53 25 8, tab 50
  text "Website:", 53, 93 64 25 8, tab 50
  text "Name:", 54, 93 80 25 8, tab 50
  text "Version:", 55, 93 91 25 8, tab 50
  text "Schemes:", 56, 93 107 25 8, tab 50
  text "", 57, 122 42 153 8, tab 50
  link "", 58, 122 53 153 8, tab 50
  link "", 59, 122 64 153 8, tab 50
  text "", 60, 122 80 153 8, tab 50
  text "", 61, 122 91 153 8, tab 50
  text "", 62, 122 107 153 8, tab 50
  edit "", 63, 93 119 182 34, tab 50 read multi vsbar

  tab "&Preview", 100
  text "Select a theme and press 'Generate'...", 101, 93 80 183 8, tab 100 center
  icon 102, 92 41 182 95, $mircexe , 0, tab 100 hide
  button "&Generate", 103, 235 142 40 11, tab 100

  button "&Load", 1000, 159 174 40 11, ok
  button "&Close", 1001, 201 174 40 11, cancel
  button "&Help", 1002, 243 174 40 11

  menu "&On load", 200
  item "&Select all to load", 201, 200
  item break, 202, 200
  item "Load &colors (recommended)", 203, 200
  item "Load &basecolors", 204, 200
  item "Load &images", 205, 200
  item "Load &nicklist colors", 206, 200
  item "Load &fonts", 207, 200
  item "Load &timestamp settings", 208, 200
  item "Load &event sounds", 209, 200
  item break, 210, 200
  item "&Ask for font if doesn't exist", 211, 200
  item "Clear &windows buffer", 212, 200

  menu "C&ache", 300
  item "&Clean", 301, 300
  item break, 302, 300
  item "Cach&e themes previews", 303, 300
  item "Cac&he themes informations", 304, 300
  item break, 305, 300
  menu "&Preview file type", 306, 300
  item "&BMP", 307, 306
  item "&JPG", 308, 306
  menu "P&review file bit depth", 309, 300
  item "&1", 310, 309
  item "&4", 311, 309
  item "&8", 312, 309
  item "1&6", 313, 309
  item "&24", 314, 309
  item "&32", 315, 309
  menu "&Preview file quality (JPG only)", 316, 300
  item "&25", 317, 316
  item "&50", 318, 316
  item "&60", 319, 316
  item "&70", 320, 316
  item "&80", 321, 316
  item "&90", 322, 316
  item "&100", 323, 316
  item break, 324, 316
  item "&Other...", 325, 316

  menu "O&thers", 400
  item "&Check if any theme is loaded on start", 401, 400
  item break, 402, 400
  item "&Show load/unload echos on active", 403, 400
  item "S&how load/unload echos on status", 404, 400
  item "&Hide load/unload echos", 405, 400
  item break, 406, 400
  ;; item "Space for another option", 407, 400
  ;; item break, 408, 400
  item "&Edit current theme...", 409, 400
}
on *:DIALOG:_themes:*:*:{
  if ($devent == INIT) {
    _themes.listFolder
    var %thm = $_themes.currentLoaded, %check = 0
    dialog -t $dname $gettok($dialog($dname).title,1,45) - $iif(%thm != $null,$nopath($v1),<no theme loaded>)
    if ($didwm(2000,$remove(%thm,"))) { 
      did -c $dname 2 $v1
      %check = 1
    }
    elseif ($did(2,1) != $null) { did -c $dname 2 1 }
    _themes.writeInfo $iif($did(2).sel,$did(2000,$v1))
    if (%check) && ($didwm(5,$_themes.currentLoadedScheme(name))) { did -c $dname 5 $v1 }
    else { did -c $dname 5 1 }

    ; On load options
    if ($_script.getOption(Themes,LoadColors)) { did -c $dname 203 }
    if ($_script.getOption(Themes,LoadBasecolors)) { did -c $dname 204 }
    if ($_script.getOption(Themes,LoadImages)) { did -c $dname 205 }
    if ($_script.getOption(Themes,LoadNicklist)) { did -c $dname 206 }
    if ($_script.getOption(Themes,LoadFonts)) { did -c $dname 207 }
    if ($_script.getOption(Themes,LoadTimestamp)) { did -c $dname 208 }
    if ($_script.getOption(Themes,LoadSounds)) { did -c $dname 209 }
    if ($_script.getOption(Themes,AskForFont)) { did -c $dname 211 }
    if ($_script.getOption(Themes,ClearWindowsBuffer)) { did -c $dname 212 }

    ; Cache options
    if ($_script.getOption(Themes,CachePreviews)) { did -c $dname 303 }
    if ($_script.getOption(Themes,CacheInfos)) { did -c $dname 304 }
    did -c $dname $iif($_themes.previewFileType == JPG,308,307)
    did -c $dname $calc(309 + $findtok(1.4.8.16.24.32,$_themes.previewFileBitDepth,1,46))
    var %q = $_themes.previewFileQuality
    if ($findtok(25.50.60.70.80.90.100,%q,1,46)) { did -c $dname $calc(316 + $v1) }
    else { did -c $dname 325 }

    ; Other options
    if ($_script.getOption(Themes,CheckLoadedThemeOnStart)) { did -c $dname 401 }
    if ($_themes.loadUnloadEchosOn isnum 1-2) { did -c $dname $calc(402 + $v1) }
    else { did -c $dname 405 }
    if ($_script.getOption(Themes,ShowCurrentSchemesMenu)) { did -c $dname 407 }
  }
  ; LOAD THEME
  elseif (($devent == SCLICK) && ($did == 1000)) || (($devent == DCLICK) && ($did == 2)) {
    dialog -c $dname
    if ($did(2).sel) { .timer -m 1 0 _themes.loadTheme $iif($did(5).seltext && $did(5).sel, $calc($v1 - 1),0) $did(2000,$did(2).sel) }
  }
  elseif ($devent == SCLICK) {
    if ($did == 3) { _themes.changeFolder }
    elseif ($did == 2) {
      did -h $dname 102
      did -av $dname 101 Select a theme and press 'Generate'...
      if ($did(2).sel) {
        _themes.writeInfo $did(2000,$v1)
        if ($didwm(5,$_themes.currentLoadedScheme(name))) { did -c $dname 5 $v1 }
      }
    }
    elseif ($did == 5) {
      did -h $dname 102
      did -av $dname 101 Select a theme and press 'Generate'...
    }
    elseif ($did == 103) { .timer -im 1 0 _themes.generatePreview }
  }
  elseif ($devent == MENU) {
    ; Only-toogles-menu-items goes here
    var %options = LoadColors.LoadBasecolors.LoadImages.LoadNicklist.LoadFonts.LoadTimestamp.LoadSounds.AskForFont.ClearWindowsBuffer.CachePreviews.CacheInfos.CheckLoadedThemeOnStart, $&
      %ids = 203.204.205.206.207.208.209.211.212.303.304.401
    if ($istok(%ids,$did,46)) {
      var %option = $gettok(%options,$findtok(%ids,$did,1,46),46)
      if ($did($did).state) {
        did -u $dname $did
        _script.setOption Themes %option 0
      }
      else {
        did -c $dname $did
        _script.setOption Themes %option 1
      }
    }
    ; Select all to load
    elseif ($did == 201) {
      var %opts = Colors.Basecolors.Images.Nicklist.Fonts.Timestamp.Sounds, %i = 1
      while (%i <= 7) {
        _script.setOption Themes $+(Load,$gettok(%opts,%i,46)) 1
        did -c $dname $calc(%i + 202)
        inc %i
      }
    }
    ; Clean cache directory
    elseif ($did == 301) { _themes.cleanCache }
    ; Preview file type
    elseif ($did isnum 307-308) {
      did -u $dname 307,308
      did -c $dname $did
      _script.setOption Themes PreviewFileType $iif($did == 307,BMP,JPG)
    }
    ; Preview file bit depth
    elseif ($did isnum 310-315) {
      did -u $dname 310,311,312,313,314,315
      _script.setOption Themes PreviewFileBitDepth $remove($did($did),&)
      did -c $dname $did
    }
    ; Preview file quality
    elseif ($did isnum 317-325) {
      var %q, %curr = $_themes.previewFileQuality
      did -u $dname 317,318,319,320,321,322,323,325
      if ($did isnum 317-323) { %q = $remove($did($did),&) }
      else { %q = $_prompt.inputNumber(1,100,%curr,h,Preview file quality (JPGs only):,Themes - Preview) }
      %q = $iif($int(%q) isnum 1-100,$v1,%curr)
      _script.setOption Themes PreviewFileQuality %q
      if ($findtok(25.50.60.70.80.90.100,%q,1,46)) { did -c $dname $calc(316 + $v1) }
      else { did -c $dname 325 }
    }
    ; Load/Unload echos on
    elseif ($did isnum 403-405) {
      did -u $dname 403,404,405
      did -c $dname $did
      _script.setOption Themes LoadUnloadEchosOn $iif($did == 403,1,$iif($did == 404,2,0))
    }
    ; Edit current theme
    elseif ($did == 409) { themedit }
  }
}

alias -l _themes.previewFileType { return $iif($_script.getOption(Themes,PreviewFileType) == JPG,$v1,BMP) }
alias -l _themes.previewFileBitDepth { 
  var %b = $_script.getOption(Themes,PreviewFileBitDepth)
  return $iif($istok(1.4.8.16.24.32,%b,46),%b,32)
}
alias -l _themes.previewFileQuality { return $iif($int($_script.getOption(Themes,PreviewFileQuality)) isnum 1-100,$v1,100) }
alias -l _themes.loadUnloadEchosOn { return $iif($int($_script.getOption(Themes,LoadUnloadEchosOn)) isnum 0-2,$v1,1) }

alias -l _themes.dir { return $_script.directory(themes,q) }
alias -l _themes.cacheDir { return $_script.directory(cache,q) }
alias -l _themes.cacheFile { return $_script.directory(cache,$null,ThemesInfos.ini) }

alias -l _themes.changeFolder {
  var %folder = $$_prompt.selectDirectory($_file.fixName($_themes.folder),Themes - Select new folder,ThemesFolder)
  _script.setOption Themes Folder %folder
  _themes.listFolder
}
alias -l _themes.listFolder {
  var %dname = _themes, %folder = $_themes.folder
  did -r %dname 2,2000
  __dummy $findfile(%folder,*.mts,0,_themes.listFolder2 %dname $1-)
}
alias -l _themes.listFolder2 {
  did -a $1 2 $nopath($2-)
  did -a $1 2000 $2-
}
alias -l _themes.folder {
  var %ret
  if ($_file.isDirectory($_script.getOption(Themes,Folder))) { %ret = $v1 }
  else { %ret = $mircdir }
  _script.setOption Themes Folder %ret
  return %ret
}
alias -l _themes.totalAvailable { return $findfile($_themes.folder,*.mts,0) }
alias _themes.getSchemesNamesFromFile {
  var %x = 1, %f = $1-, %s = "", %ln
  if (!$isfile(%f)) { return }
  %ln = $read(%f,nw,[mts])
  while ($gettok($read(%f,nw, Scheme $+ %x *, %ln),2-,32) != $null) {
    %s = $addtok(%s,$v1,44)
    inc %x
  }
  return %s
}
alias -l _themes.cleanCache {
  __dummy $findfile($_themes.cacheDir,ThmPreview_*_*.*,0,.remove -b $_file.fixName($1-))
  .remove -b $_themes.cacheFile
}
alias -l _themes.writeInfo {
  var %dname = _themes, %thm = $longfn($1-), %hash = $hash(%thm,32), %cache = $_themes.cacheFile, %cache.it = $false, %ln = $read(%thm,nw,[mts]), %err, $&
    %_author, %_email, %_website, %_name, %_version, %_description, %_mtsversion, %_schemes

  did -r %dname 57,58,59,60,61,62,63
  did -br %dname 5
  did -b %dname 1000,103

  if (!$isfile(%thm)) || ($1 == $null) {
    _themes.writeThemeLabel (no theme selected)
    return
  }
  if ($readini(%cache, %hash,Filename) == %thm) && ($readini(%cache, %hash, FileCreation) == $file(%thm).ctime) {
    %_author = $readini(%cache,%hash,  Author)
    %_email = $readini(%cache,%hash,  Email)
    %_website = $readini(%cache,%hash,  Website)
    %_name = $readini(%cache,%hash,  Name)
    %_version = $readini(%cache,%hash, Version)
    %_description = $readini(%cache,%hash, Description)
    %_mtsversion = $readini(%cache,%hash, MtsVersion)
    %_schemes = $readini(%cache,%hash, Schemes)
  }
  else {
    %_author = $gettok($read(%thm,nw,  Author *, %ln),2-,32)
    %_email = $gettok($read(%thm,nw,  Email *),2,32)
    %_website = $gettok($read(%thm,nw, Website *, %ln),2,32)
    %_name = $gettok($read(%thm,nw, Name *, %ln),2-,32)
    %_version = $gettok($read(%thm,nw, Version *, %ln),2,32)
    %_description = $gettok($read(%thm,nw, Description *, %ln),2-,32)
    %_mtsversion = $gettok($read(%thm,nw, MtsVersion *, %ln),2,32)
    %_schemes = $_themes.getSchemesNamesFromFile(%thm)
    var %cache.it = $true
  }
  if (!%ln) { %err = Invalid theme (no main mTS section) }
  elseif (%_mtsversion == $null) { %err = Invalid theme (no mTS version specified) }
  elseif (!$istok(1 1.1 1.2 1.3,$calc(%_mtsversion),32)) { %err = mTS version %_mtsversion not supported }
  if (%err) {
    _themes.writeThemeLabel %err
    return
  }
  if (%cache.it) && ($_script.getOption(Themes,CacheInfos)) {
    var %dir = $_file.fixName($nofile(%cache))
    if (!$isdir(%dir)) { _file.makeDirectory %dir }
    .remini %cache %hash
    .writeini -n %cache %hash Filename %thm
    .writeini -n %cache %hash FileCreation $file(%thm).ctime
    if (%_author != $null) { writeini -n %cache %hash Author $v1 }
    if (%_email != $null) { .writeini -n %cache %hash Email $v1 }
    if (%_website != $null) { .writeini -n %cache %hash Website $v1 }
    if (%_name != $null) { .writeini -n %cache %hash Name $v1 }
    if (%_version != $null) { .writeini -n %cache %hash Version $v1 }
    if (%_description != $null) { .writeini -n %cache %hash Description $v1 }
    if (%_mtsversion != $null) { .writeini -n %cache %hash MtsVersion $v1 }
    if (%_schemes != $null) { .writeini -n %cache %hash Schemes $v1 }
  }
  _themes.writeThemeLabel $iif(%_name != $null,$v1,<n/a>) (by $iif(%_author != $null,$v1,<n/a>) $+ )
  did -a %dname 57 %_author
  did -a %dname 58 %_email
  did -a %dname 59 %_website
  did -a %dname 60 %_name
  did -a %dname 61 %_version ( $+ mTS v $+ %_mtsversion $+ )
  did -a %dname 62 $iif($numtok(%_schemes,44) > 0,$v1,No) schemes available
  did -a %dname 63 %_description
  didtok %dname 5 44 (none), $+ %_schemes
  if ($numtok(%_schemes,44) > 0) { did -e %dname 5 }
  var %currScheme = $_themes.currentLoadedScheme(name)
  if ($_file.equalsTo(%thm,$_themes.currentLoaded)) && ($did(%dname,5,%currScheme) != $null) { did -c $dname 5 %currScheme }
  else { did -c %dname 5 1 }

  did -e %dname 1000,103
}
alias _themes.writeThemeLabel {
  did -g _themes 11 $_dialog.labelFile(182,13,$1-)
}
alias _themes.currentLoaded {
  var %thm = $_file.fixName($_script.getOption(Theme,LoadedTheme)), %script = $_themes.scriptFilename
  if (!$isfile(%thm)) || ((%script) && (!$script($remove(%script,")))) || (!$hget($_hash.prefixed(Theme),0).item) { return }
  return %thm
}
alias _themes.currentLoadedScheme {
  var %s = $_script.getOption(Theme,LoadedScheme), %sn = $_script.getOption(Theme,$+(Scheme,%s))
  if (%sn != $null) {
    if ($1 == name) { return %sn }
    return %s
  }
  if ($1 == name) { return <no scheme> }
  return 0
}
alias _themes.basecolors {
  if ($1 isnum 1-4) {
    var %return = 20, %colors
    if ($prop == default) {
      %colors = $remove($_themes.getText(BaseColors),$chr(3))
      if ($gettok(%colors,$1,44) isnum) { %return = $v1 }
    }
    elseif ($_script.getOption(Theme,$+(BaseColor,$1)) isnum) { %return = $v1 }
  }
  return $_color.toMircColor(%return)
}
alias -l _themes.replaceBasecolors {
  set -u0 %::c1 $_themes.basecolors(1)
  set -u0 %::c2 $_themes.basecolors(2)
  set -u0 %::c3 $_themes.basecolors(3)
  set -u0 %::c4 $_themes.basecolors(4)
  return $replace($1-,<c1>,%::c1,<c2>,%::c2,<c3>,%::c3,<c4>,%::c4)
}
alias _themes.basecolor {
  if ($2) { return  $+ $_themes.basecolors($1) $+ $2- $+  }
  return $_themes.basecolors($1)
}
alias _themes.icon { 
  var %ret
  if ($_script.getOption(Theme,Prefix)) { %ret = $v1 }
  elseif ($_themes.getText(Prefix)) { %ret = $v1 }
  else { %ret = $_themes.basecolor(1,***) }
  return $_themes.replaceBasecolors(%ret)
}
; Check if Whois or Whowas events exists on theme file otherwise raws are all displayed
alias _themes.eventExists {
  var %t = $_themes.getText($1)
  if (%t != $null) && (%t != !Script) { return 1 }
}
alias _themes.parentext {
  var %ret 
  if ($_script.getOption(Theme,Parentext)) { %ret = $v1 }
  elseif ($_themes.getText(Parentext)) { %ret = $v1 }
  else { %ret = (<text>) }
  return $_themes.replaceBasecolors(%ret) 
}
alias -l _themes.eventOption {
  var %opts = $_mirc.iniData(events,$1)
  if (!%opts) { %opts = $_mirc.iniData(events, Default) }
  if (!%opts) { %opts = 0,0,0,0,0,0,0,0 }
  return $gettok(%opts,$2,44)
}
alias _themes.echos {
  var %event = $1
  goto %event

  :notify | :unotify
  var %col = $color(notify text), %win = @Notifies- $+ $_network.active $+ ( $+ $cid $+ )
  if ($_echos.get(notify) == @window) { 
    if (!$window(%win)) { window -akv %win }
    return aline -h %col %win
  }
  if ($_mirc.iniOption(3,24)) { return echo $color(notify text) -ti2 $+ $iif(!$_window.activeIsWindow && $_network.cidIsActive,a,s) }
  return echo $color(notify text) -i2ts

  :invite
  if ($_mirc.iniOption(3,26)) && (!$_window.activeIsWindow) && ($_network.cidIsActive) { set -u0 %:echo echo $color(invite text) -i2ta } 
  return echo $color(invite text) -ti2s

  :channotice
  var %e = $_echos.get(channotices), %win = @ChannelNotices- $+ $_network.active $+ ( $+ $cid $+ )
  if (%::chan ischan) {
    if (%e == default) {    
      if ($_mirc.iniOption(5,13)) && (!$_window.activeIsWindow) && ($_network.cidIsActive) { return echo $color(notice text) -mi2ta }
      return echo $color(notice text) -ti2m %::chan
    }
    elseif (%e == channel) { return echo $color(notice text) -ti2m %::chan }
    else { 
      if (!$window(%win)) { window -kav %win }
      return aline -h $color(notice text) %win 
    }
  }
  else {
    if (%e == @window) { 
      if (!$window(%win)) { window -kav %win }
      return aline -h $color(notice text) %win 
    }
    return echo $color(notice text) -ti2m $+ $iif($_mirc.iniOption(5,13) && !$_window.activeIsWindow && $_network.cidIsActive,a,s)
  }

  :usernotice
  var %e = $_echos.get(notices), %e_services = $_echos.get(servicenotices), %win = @Notices- $+ $_network.active $+ ( $+ $cid $+ ), $&
    %win_services = @ServicesNotices- $+ $_network.active $+ ( $+ $cid $+ )
  if ($_services($nick,$site)) {
    if  (%e_services == status) { return echo $color(notice text) -tmi2s }
    elseif (%e_services == active) && ($_network.cidIsActive) && (!$_window.activeIsWindow) { return echo $color(notice text) -ti2ma }
    else { 
      if (!$window(%win_services)) { window -kav %win_services }
      return aline -h $color(notice text) %win_services 
    }
  }
  elseif (%e == default) {
    if ($comchan(%::nick,0) == 1) { return echo $color(notice text) -mi2t $comchan($nick,1) } 
    elseif ($active != $comchan($nick,1)) { 
      if ($_mirc.iniOption(5,13)) { return echo $color(notice text) -tim2 $+ $iif(!$_window.activeIsWindow && $_network.cidIsActive,a,s) } 
    }
    return echo $color(notice text) -tsi2m
  }
  else {
    if (!$window(%win)) { window -kav %win } 
    return aline -h $color(notice text) %win
  }

  :wallop
  var %e = $_echos.get(wallops), %win = @Wallops- $+ $_network.active $+ ( $+ $cid $+ )
  if (%e == @window) { 
    if (!$window(%win)) { window -kav %win }
    set -u0 %:echo aline -h $color(wallops text) %win
  }
  else { return echo $color(wallops text) -ti2 $+ $iif(%e == active && ($_networks.cidIsActive && !$_window.activeIsWindow,a,s) }

  :snotice
  var %echo = $_echos.get(snotices), %win = @SNotices- $+ $_network.active $+ ( $+ $cid $+ )
  if (%echo == status) { return echo $color(notice text) -i2ts }
  elseif (%echo == active) && ($_networks.cidIsActive) && (!$_window.activeIsWindow) { return echo $color(notice text) -i2ta }
  else { 
    if (!$window(%win)) { window -lkav %win }
    return aline -h $color(notice text) %win
  }

  :ctcp
  var %echo = $_echos.get(ctcps), %win = @CTCPs- $+ $_network.active $+ ( $+ $cid $+ )
  if (%echo == @window) {
    if (!$window(%win)) { window -akv %win }
    return aline -h %win 
  }
  else {
    if (%::target ischan) { 
      if (%where == 1) { return echo $color(ctcp text) -ti2s }
      else { return echo $color(ctcp text) -ti2 %::target }
    }
    else { return echo $color(ctcp text) -ti2 $+ $iif($_network.cidIsActive && !$_window.activeIsWindow && $_mirc.iniOption(4,19),a,s) }
  }

  :whois
  var %col = $color(whois text), %win = @Whois- $+ $_network.active $+ ( $+ $cid $+ )
  if ($_echos.get(whois) == @window) { 
    if (!$window(%win)) { window -akv %win }
    return aline -h %col %win
  }
  elseif ($_mirc.iniOption(1,19)) && ($query(%::nick)) { return echo %col -ti2 %::nick }
  elseif ($_mirc.iniOption(2,26)) && (!$_window.activeIsWindow) && ($_network.cidIsActive) { return echo %col -ati2 }
  else { return echo $color(whois text) -sti2 }

  :motd
  var %win = @MOTD- $+ $server $+ ( $+ $cid $+ ), %echos = $_echos.get(motd)
  if (%echos == active) && (!$_window.activeIsWindow) && ($_network.cidIsActive) { return echo $color(normal text) -ti2a }
  elseif (%echos == @window) {
    if (!$window(%win)) { window -aklv %win }
    return aline -h %win
  }
  else { return echo $color(normal text) -ti2s }

  :names
  var %chan = $2, %e = $_echos.get(names), %win = @Names- $+ %chan $+ ( $+ $cid $+ )
  if (%e == @window) { 
    if (!$window(%win)) { _window.open -svl %win }
    return aline -h %win
  } 
  else { return echo -t $+ $iif(%e == status,s,a) }

  :%event
  return __dummy
}
alias -l _themes.generatePreview {
  var %dname = _themes, %thm = $_file.fixName($did(%dname,2000,$did(%dname,2).sel))

  did -vra %dname 101 Generating preview. Please wait...
  did -h %dname 102

  var %rgb.actual = $_color.actualRgbColors, %scheme = $iif($did(%dname,5).sel,$calc($v1 - 1),0), %hash = TEMP-ThemesPreview, %win = @_temp._themes.generatePreview, $&
    %background.actual = $_color.toMircColor($color(Background)), %colors.actual = $_color.actualColors, $&
    %script.actual = $_file.fixName($nofile($_themes.currentLoaded) $+ $_themes.getText(Script))

  var %cachedir = $_themes.cacheDir, %save_to = $_file.fixName(%cachedir $+ $+(ThmPreview_,$crc(%thm),_,%scheme,.,$_themes.previewFileType)), %cached = $false

  if ($isfile(%save_to)) { 
    %cached = $true
    goto did_preview
  }

  _script.setOption %hash
  _themes.themeToHash %hash mTS %thm
  if (%scheme) { _themes.themeToHash %hash $+(Scheme,%scheme) %thm }

  var %colors = $_script.getOption(%hash,Colors), %background = $_color.toMircColor($gettok(%colors,1,44)), %font = $_script.getOption(%hash,FontChan), $&
    %fontname = $gettok(%font,1,44), %fontsize = $gettok(%font,2,44), %bold = $iif($gettok(%font,3,44) == b,-b,-), $&
    %script = $_file.fixName($nofile(%thm) $+ $_script.getOption(%hash,Script)), %mtsversion = $_script.getOption(%hash,MTSVersion), $&
    %rgbcolors = $_script.getOption(%hash,RGBColors), %_fontname = $replace(%fontname,$chr(32),_), $&
    %timestamp = $iif($_script.getOption(%hash,Timestamp) == ON,$asctime($_script.getOption(%hash,TimestampFormat))), %basecolors = $_script.getOption(%hash,Basecolors)

  var %err
  if (!$isfile(%thm)) { %err = No such theme file. Halted }
  elseif (!$istok(1 1.1 1.2 1.3,$calc(%mtsversion),32)) { %err = Invalid mTS version. Halted }
  elseif (!$read(%thm,nw,[MTS])) { %err = No main mTS section. Halted }
  if (%err) { 
    did -ra %dname 101 %err 
    return
  }

  if (%rgbcolors != %rgbcolors.actual) || (%rgbcolors == $null) { _color.loadRgbColors %rgbcolors }
  if (%colors != %colors.actual) || (%colors == $null) { _color.loadColors %colors }

  window -pfhn +d %win -1 -1 358 190
  drawrect -fn %win %background 2 0 0 350 190

  if ($isfile(%script)) { .reload -rs %script }

  set $_script.variableName(Themes,PreviewTextPosition) 3

  set -u0 %::c1 $gettok(%basecolors,1,44)
  set -u0 %::c2 $gettok(%basecolors,2,44)
  set -u0 %::c3 $gettok(%basecolors,3,44)
  set -u0 %::c4 $gettok(%basecolors,4,44)
  set -u0 %::timestamp $replace(%timestamp,<c1>,%::c1,<c2>,%::c2,<c3>,%::c3,<c4>,%::c4)
  set -u0 %::pre $replace($iif($_script.getOption(%hash,Prefix),$v1,***),<c1>,%::c1,<c2>,%::c2,<c3>,%::c3,<c4>,%::c4)
  set -u0 %::me $me
  set -u0 %::chan #FeedbacK
  set -u0 %::target #FeedbacK
  set -u0 %::fromserver irc.feedback.pt
  if ($server) {
    set -u0 %::server $v1
    set -u0 %::port $port
  }
  else {
    set -u0 %::server irc.feedback.pt
    set -u0 %::port 6667
  }
  var %myaddress = preview@feedbackscript.cjb.net

  set -u0 %::nick $_script.author
  set -u0 %::address $_script.email
  _themes.previewEcho %hash %bold %win $color(Join) %background %_fontname %fontsize JoinSelf

  set -u0 %::nick $me
  set -u0 %::address %myaddress
  set -u0 %::text Welcome to FeedbacK. Enjoy your stay as much as possible.
  set -u0 %::value %::text
  _themes.previewEcho %hash %bold %win $color(Normal text) %background %_fontname %fontsize RAW.332

  set -u0 %::nick Juizo 
  set -u0 %::text $asctime(416275200)
  set -u0 %:value %::text
  _themes.previewEcho %hash %bold %win $color(Normal text) %background %_fontname %fontsize RAW.333

  set -u0 %::nick $_script.author 
  set -u0 %::address Pipoca@domain.com 
  _themes.previewEcho %hash %bold %win $color(Join) %background %_fontname %fontsize Join

  set -u0 %::nick ChanServ 
  set -u0 %::address services@ptnet.org 
  set -u0 %::modes +o $_script.author 
  set -u0 %::text +o $_script.author 
  set -u0 %::cmode @
  _themes.previewEcho %hash %bold %win $color(Mode text) %background %_fontname %fontsize Mode

  set -u0 %::nick $_script.author 
  set -u0 %::address Pipoca@domain.com 
  set -u0 %::modes +m 
  set -u0 %::text +m 
  set -u0 %::cmode @ 
  _themes.previewEcho %hash %bold %win $color(Mode text) %background %_fontname %fontsize Mode 

  set -u0 %::nick $me 
  set -u0 %::address %myaddess
  set -u0 %::cmode @ 
  set -u0 %::text what a heck are you doing?
  _themes.previewEcho %hash %bold %win $color(Own text) %background %_fontname %fontsize TextChanSelf

  set -u0 %::nick $me 
  set -u0 %::address %myaddress 
  set -u0 %::modes -m
  set -u0 %::text -m  
  set -u0 %::cmode @
  _themes.previewEcho %hash %bold %win $color(Mode text) %background %_fontname %fontsize Mode


  set -u0 %::nick $_script.author 
  set -u0 %::address Pipoca@domain.com 
  set -u0 %::cmode @ 
  set -u0 %::text pvt man, I can't explain u here 
  _themes.previewEcho %hash %bold %win $color(Other text) %background %_fontname %fontsize TextChan

  set -u0 %::address sex@maniac.pt 
  set -u0 %::chan #SexFree 
  set -u0 %::nick Chyntia 
  set -u0 %::cmode
  set -u0 %:comments - Press F5 to Join
  _themes.previewEcho %hash %bold %win $color(Invite text) %background %_fontname %fontsize Invite
  unset %:comments

  set -u0 %::nick $me
  set -u0 %::chan #Portugal
  set -u0 %::address %myaddress 
  set -u0 %::modes +b Cynthia!*@* 
  set -u0 %::text +b Cynthia!*@* 
  _themes.previewEcho %hash %bold %win $color(Mode text) %background %_fontname %fontsize Mode

  set -u0 %::nick $me 
  set -u0 %::address %myaddress 
  set -u0 %::cmode @ 
  set -u0 %::text Cynthia: I love xxx, I love you but, mass invites? errr ... bye 
  _themes.previewEcho %hash %bold %win $color(Own text) %background %_fontname %fontsize TextChanSelf

  set -u0 %::nick $me
  set -u0 %::address %myaddress
  set -u0 %::kaddress sex@maniac.pt 
  set -u0 %::knick Chyntia 
  set -u0 %::cmode @ 
  set -u0 %::text Banned: mass invites not allowed
  _themes.previewEcho %hash %bold %win $color(Kick text) %background %_fontname %fontsize Kick

  set -u0 %::text User has been banned 
  set -u0 %::nick Rob_ 
  set -u0 %::address suporte@ptnet.org
  _themes.previewEcho %hash %bold %win $color(Quit text) %background %_fontname %fontsize Quit

  set -u0 %::nick $me 
  set -u0 %::address %myaddress 
  set -u0 %::cmode @ 
  set -u0 %::text This preview is fucking idiot :-p
  _themes.previewEcho %hash %bold %win $color(Own text) %background %_fontname %fontsize TextChanSelf

  set -u0 %::text Theme author
  set -u0 %::nick $iif($_script.getOption(%hash,Author),$v1,Theme_Author)
  set -u0 %::address themes@irc-source.com
  _themes.previewEcho %hash %bold %win $color(Notify text) %background %_fontname %fontsize Notify

  set -u0 %::realname $iif($_script.getOption(%hash,Name),$v1,Theme) $+ 's author
  set -u0 %::chan @#FeedbacK #Portugal
  set -u0 %::wserver irc.feedback.pt
  set -u0 %::serverinfo FeedbacK's IRC server
  set -u0 %::isoper is not
  set -u0 %::isregd is
  set -u0 %::away Scripting, do not disturb.
  set -u0 %::text %::away
  if ($_script.getOption(%hash,RAW.311)) _themes.previewEcho %hash %bold %win $color(Whois text) %background %_fontname %fontsize RAW.311
  if ($_script.getOption(%hash,RAW.319)) _themes.previewEcho %hash %bold %win $color(Whois text) %background %_fontname %fontsize RAW.319
  if ($_script.getOption(%hash,RAW.312)) _themes.previewEcho %hash %bold %win $color(Whois text) %background %_fontname %fontsize RAW.312
  if ($_script.getOption(%hash,RAW.301)) _themes.previewEcho %hash %bold %win $color(Whois text) %background %_fontname %fontsize RAW.301
  if ($_script.getOption(%hash,RAW.318)) _themes.previewEcho %hash %bold %win $color(Whois text) %background %_fontname %fontsize RAW.318
  if (!$_script.getOption(%hash,RAW.318)) _themes.previewEcho %hash %bold %win $color(Whois text) %background %_fontname %fontsize Whois

  drawsave $+(-b,$_themes.previewFileBitDepth,q,$_themes.previewFileQuality) %win %save_to

  if (%colors.actual != %colors) { _color.loadColors $v1 }
  if (%rgb.actual != %rgbcolors) { _color.loadRgbColors $v1 }
  if (%script != %script.actual) && ($_file.isFile(%script)) { .timer -mi 1 0 .unload -rsn $v1 }

  :did_preview
  did -h %dname 101
  did -g %dname 102 %save_to
  did -v %dname 102
  if (!$_script.getOption(Themes,CachePreviews)) { .remove -b %save_to }

  window -c %win
}
alias -l _themes.previewEcho {
  ;  /_themes.previewEcho <hash> <-b> <win> <N color> <background color> <Font_name> <Fontsize> <Event>
  ;                                              1       2       3           4                    5                             6                  7               8       
  var %pos = $_script.variableValue(Themes,PreviewTextPosition), %font = $+(",$replace($6,_,$chr(32)),")
  set -u0 %:echo drawtext -npb $+ $iif(b isin $2,o)     $3-5      %font       $7         3       %pos    %::timestamp
  var %event = $_themes.evaluateString($_script.getOption($1,$8))
  set $_script.variableName(Themes,PreviewTextPosition) $calc(%pos + $height($iif(%event != $null,%event,<no preview>),%font,$+(-,$7)))
  if (%::text != $null) { set -u0 %::parentext $replace($_script.getOption($1,Parentext),<text>,%::text,<c1>,%::c1,<c2,%::c2,<c3>,%::c3,<c4>,%::c4) }
  if (!Script * iswm %event) { $eval($gettok(%event,2-,32),2) }
  elseif (RAW.??? iswm $8) && (%event == $null) {
    if ($_script.getOption($1,RAW.Other)) { %event = $v1 }
  }
  elseif (%event != $null) { %:echo $replace(%event,<c1>,%::c1,<c2>,%::c2,<c3>,%::c3,<c4>,%::c4) %:comments }
  else { %:echo <no preview> }
  unset %::parentext
}
alias _themes.text {
  set -u0 %::me $me
  set -u0 %::pre $_themes.icon
  set -u0 %::timestamp $timestamp
  set -u0 %::server $server
  set -u0 %::port $port 
  if (%::text != $null) { set -u0 %::parentext $replace($_themes.parentext,<text>,%::text) }
  else { unset %::parentext }
  var %event = $_themes.getText($1)
  if (RAW.??? iswm $1) && (%event == $null) { %event = $_themes.getText(RAW.Other) }
  %event = $_themes.replaceBasecolors($_themes.evaluateString(%event))
  if (%event != $null) { 
    if (!Script ?* iswm %event) {
      $eval($deltok(%event,1,32),2)
      return $true
    }
    else {
      %:echo %event $iif($2 != $null,$2-,%:comments)
      return $true
    }
  }
  else {
    return $false 
  }
}
alias _themes.evaluateString {
  var %a, %r = $cr % $+ ::\1 $lf, %e = $regsub($1-,/<([a-zA-Z0-9]+)>/g,%r,%a), %::lt = <, %::gt = >
  return $remove($replace($remove($eval(%a,2),$+($cr,$chr(32)),$+($chr(32),$lf),$+($cr,$chr(32),$lf)),^g,>,^l,<),$cr,$lf)
}
alias _themes.getText {
  if ($_script.getOption(Theme,$1) != $null) { return $_mirc.tagToControlCode($v1) }
  else {
    var %t = $1, %r = return
    goto %t

    :FontDefault | %r Verdana,10
    :FontChan | %r Verdana,10
    :FontQuery | %r Verdana,10

    :Prefix | %r <c1>(4$<c1>)
    :Timestamp | %r ON
    :TimestampFormat | %r (HH:nn:sstt)
    :ParenText | %r <c2>(2<text><c2>)

    :Echo | %r <pre> <text>
    :EchoTarget | %r <pre> [<target>] <text>
    :Error | %r 4[Error4] <text>
    :ServerError | %r 4[ServerError4] <text>

    :Join | %r <pre> <c1>[Join <chan>: <c2><nick> 10(<address>)]
    :JoinSelf | %r <pre> Now talking in <chan>
    :Rejoin | %r <pre> Rejoining <chan>...
    :Part | %r <pre> <c1>[Part <chan>: <c2><nick> <c1>(<address>)] <parentext>
    :Nick | %r <pre> <c4>[Nick change - (<nick> to <newnick>)]
    :NickSelf | %r <pre> <c4>[My nick change - (<nick> to <newnick>)]
    :Quit | %r <pre> <c1>[Quit: <nick> (<address>) <parentext>
    :Topic | %r <pre> <c2><nick> <c1>sets topic: <text>
    :Kick | %r <pre> <c2><knick><c1> was kicked from <chan> by <c2><nick> <parentext>
    :KickSelf | %r <pre> <c2><nick> <c1>kicked you from <c2><chan> <parentext>
    :Invite | %r <pre> You´ve been invited to <chan> by <nick>

    :Notify | %r [3Notify] <c2><nick> <c1>(<address>) <parentext> <c1>is on irc.
    :UNotify | %r [4UNotify] <c2><nick> <parentext> <c1>has left irc.

    :TextChan | %r <lt><cmode><nick><gt> <text>
    :TextChanSelf | %r <c3><lt><cmode><nick><c3><gt> <text>
    :TextQuery | %r <lt><nick><gt> <text>
    :TextQuerySelf | %r <c3><lt><nick><c3><gt> <text>
    :TextMsgSend | %r <c1>-> <c2><nick> <c1>- <text>

    :ActionQuery | %r 13* <nick> <text>
    :ActionQuerySelf | %r 6* <nick> <text>
    :ActionChan | %r 13* <cmode><nick> <text>
    :ActionChanSelf | %r 6* <cmode><nick> <text>

    :Mode | %r <pre> <c1><nick> sets mode: <c2><modes>
    :ModeUser | %r <pre> <c1><nick> sets mode: <c2><modes>

    :Notice | %r <pre> <c1>Notice / <c2><nick> - <c1><text> 
    :NoticeChan | %r <pre> <c1>Notice - <c2><cmode><nick> : <target> - <c1><text>
    :NoticeSend | %r <pre> <c1>-> -<c2><nick><c1>- <text>
    :NoticeServer | %r <pre> <c1>SNotice / <c2><nick> - <c1><text>

    :Ctcp | %r <pre> <c1>[<c2><nick><c1>] <c1><ctcp> <text>
    :CtcpChan | %r <pre> <c1>[<c2><cmode><nick><c1>/<c2><chan><c1>] <c1><ctcp> <text>
    :CtcpReply | %r <pre> <c1>[ <c2><nick> <c2><chan><c1>] <c1><ctcp> reply: <text>
    :CtcpSend | %r <pre> <c1>Sended CTCP (<ctcp>): <c2><nick> <c2><text>
    :CtcpChanSend | %r <pre> <c1>Sended channel CTCP (<ctcp>): <c2><chan> <c1><text>
    :CtcpReplySend | %r <pre> <c1>[ <c2><nick> <c1>] <c1>Sending CTCP reply to <nick> (<ctcp>): <text>

    :RAW.Other | %r <pre> <text>

    :DNS | %r <pre> <c1>Looking up <c2><nick><address><c1>...
    :DNSError | %r <pre> <c1>Unable to resolve <c2><address><nick>
    :DNSResolve | %r <pre> <c1>Resolved <c2><address> <c1>to <c2><raddress>

    :BaseColors | %r 10,07,04,06

    :%t
  }
}
alias _themes.loadTheme {
  var %folder = $_themes.folder, %thm = $_file.fixName($2-), %scheme = $iif($int($1) isnum 0-,$v1,0)

  if (!$isfile(%thm)) {
    if ($show) { _themes.commandEcho theme.load Specified theme not founded. }
  }
  else {
    var %prog_total = 11, %echos.on = "", %winhide = @_temp._themes.loadTheme_Hide
    window -hpBi +d %winhide 0 0 $window(-3).w $window(-3).h
    drawrect -nrf %winhide $rgb(128, 128, 128) 0  0 0 $window(-3).w $window(-3).h
    window -a %winhide
    _progress.inc 1 %prog_total Preparing theme load...
    if ($_script.getOption(Themes,ClearWindowsBuffer)) { clearall }
    if ($_themes.loadUnloadEchosOn) { %echos.on = $iif($v1 == 2,echo -s,echo -a) }
    if (%echos.on) {
      set -u0 %:echo $v1
      _themes.text UnLoad
    }

    _progress.inc 2 %prog_total Unloading previous theme...
    var %script = $nofile($_themes.currentLoaded) $+ $_themes.getText(Script)
    if ($script(%script)) { .unload -rsn $_file.fixName($v1) }
    _script.setOption Theme
    _script.setOption Theme LoadedTheme %thm
    _script.setOption Theme LoadedScheme %scheme

    _progress.inc 3 %prog_total Hashing theme...
    _themes.themeToHash Theme mTS %thm
    if (%scheme) { _themes.themeToHash Theme $+(Scheme,%scheme) %thm }
    _script.setOption Theme Prefix $_themes.getText(Prefix)
    _script.setOption Theme Parentext $_themes.getText(Parentext)

    _progress.inc 4 %prog_total Loading script...
    _themes.loadScript
    _progress.inc 5 %prog_total Loading basecolors...
    if ($_script.getOption(Themes,LoadBasecolors)) { _themes.loadBasecolors }
    _progress.inc 6 %prog_total Loading fonts...
    if ($_script.getOption(Themes,LoadFonts)) { _themes.loadFonts }
    _progress.inc 7 %prog_total Loading colors...
    if ($_script.getOption(Themes,LoadColors)) { 
      _color.loadRgbColors $_themes.getText(RGBColors)
      _color.loadColors $_themes.getText(Colors)
    }
    _color.buildBmpFiles
    _progress.inc 8 %prog_total Loading timestamp...
    if ($_script.getOption(Themes,LoadTimestamp)) { _themes.loadTimestamp }
    _progress.inc 9 %prog_total Loading nicklist...
    if ($_script.getOption(Themes,LoadNicklist)) { _themes.loadNicklist }
    _progress.inc 10 %prog_total Loading images...
    if ($_script.getOption(Themes,LoadImages)) { _themes.loadImages }
    _progress.inc 11 %prog_total Loading sounds...
    if ($_script.getOption(Themes,LoadSounds)) { _sounds.setDefaults }

    .enable #_Themes
    if (%echos.on) {
      set -u0 %:echo $v1
      _themes.text Load
    }
    window -c %winhide
  }
  set $_script.variableName(Themes,Current,Schemes,Names) $_themes.getSchemesNamesFromFile(%curr,$read(%curr,nw,[mts]))
  ;; if ($show) { _themes.commandEcho Theme Loaded  $+ $_themes.getText(Name) $+  theme ( $+ $_themes.currentLoadedScheme(name) $+ ) }
}
alias _themes.scriptFilename { 
  var %script = $_themes.getText(Script), %file = $nofile($_script.getOption(Theme,LoadedTheme)) $+ %script, %file = $_file.isFile(%file)
  return %file
}
alias -l _themes.loadScript {
  if ($_themes.scriptFilename) { .reload -rs $v1 }
}
alias _themes.loadImages {
  var %y = 1, %type, %types = $_images.types
  while ($gettok(%types,%y,46)) {
    %type = $v1
    if ($findtok(%types,%type,46)) {
      var %x = $v1, %txt = $_themes.getText($+(Image,%type)) 
      tokenize 32 %txt
      var %file = $nofile($_themes.currentLoaded) $+ $iif($2,$2-,$1-), %file = $_file.fixName(%file)
      if ($2) {
        if ($istok($_images.styles,$1,46)) && ($isfile(%file)) { 
          _script.setOption Images %type 1 
          _script.setOption Images $+(%type,File) $1 %file 
        }
        elseif ($isfile(%file)) { 
          _script.setOption Images %type 1 
          _script.setOption Images $+(%type,File) normal %file 
        }
        else { 
          _script.setOption Images %type 
          _script.setOption Images $+(%type,File) 
        }
      }
      elseif ($1) && ($isfile(%file)) { 
        _script.setOption Images %type 1 
        _script.setOption Images $+(%type,File) normal %file 
      }
      else { 
        _script.setOption Images %type 
        _script.setOption Images $+(%type,File) 
      }
    }
    else { 
      _script.setOption Images %type 
      _script.setOption Images $+(%type,File)
    }
    inc %y
  }
  if ($dialog(_images)) { _images.startDialog }
  _images.loadImages
}
alias -l _themes.loadNicklist {
  var %x = 1, %i 
  while ($gettok($_nicklist.types,%x,46)) { 
    %i = $v1 
    _script.setOption Nicklist %i $iif($_themes.getText($+(Cline,%i)) isnum,$v1,$color(Listbox text)) 
    inc %x 
  }
  _nicklist.allChannels
  if ($dialog(_nicklist)) { _nicklist.startDialog }
}
alias -l _themes.loadTimestamp {
  if ($_themes.getText(MTSVersion) == 1.0) {
    if ($_themes.getText(Timestamp) != $null) && ($v1 != off) {
      _script.setOption Theme TimestampFormat $v1
      _script.setOption Theme Timestamp ON
    }
    else { _script.setOption Theme Timestamp OFF }
  }
  var %stat = $_themes.getText(Timestamp), %format = $_themes.getText(TimestampFormat)
  .timestamp $iif($istok(on.off,%stat,46),%stat,off) 
  .timestamp -f $_themes.replaceBasecolors($iif(%format != $null,$v1,$timestampfmt))
}
alias -l _themes.loadBasecolors {
  var %cols = $remove($_themes.getText(BaseColors),$chr(3)), %x = 1
  while ($gettok(%cols,%x,44)) {
    _script.setOption Theme Basecolor $+ %x $_color.toMircColor($v1)
    inc %x
  }
}
alias _themes.fontExists {
  var %chr = 32
  while (%chr < 127) {
    if (($width($chr(%chr),$1-,100) != $width($chr(%chr),$1- bold,100)) || ($height($chr(%chr),$1-,100) != $height($chr(%chr),$1- bold,100))) { return 1 }
    inc %chr
  }
  return 0
}
alias -l _themes.selectRightFont {
  var %fonts = $1-, %x = 1, %_f, %font, %size, %bold
  while ($gettok(%fonts,%x,59)) {
    %_f = $v1
    %font = $gettok(%_f,1,44)
    %size = $gettok(%_f,2,44)
    %bold = $iif(b isin $gettok(%_f,3,44),b)
    if ($_themes.fontExists(%font)) { break }
    else { %font = }
    inc %x
  }
  if (%font) { return %font , %size , %bold }
  if ($_script.getOption(Themes,AskForFont)) { return $_prompt.selectFont }
}
alias -l _themes.loadFonts {
  var %wr = .writeini -n $_mirc.ini fonts, %_f, %size_font, %b, %x, %y, %changed = $false

  if ($_themes.selectRightFont($_themes.getText(FontDefault))) {
    %_f = $v1
    %size_font = $gettok(%_f,2,44) $gettok(%_f,1,44)
    %b = $iif(b isin $gettok(%_f,3,44),b)

    %x = 1
    while ($scon(%x)) {
      scon %x 
      font -s $+ %b %size_font
      %y = 1
      while ($window(%y)) {
        font -d $+ %b %size_font
        inc %y
      }
      inc %x
    }
    if ($window(Finger Window)) { font -g %size_font }
    else { _themes.writeIniFonts ffinger %b %size_font }

    _themes.writeIniFonts fdccs %b %size_font
    _themes.writeIniFonts fnotify %b %size_font
    _themes.writeIniFonts fwwwlist %b %size_font
    _themes.writeIniFonts flinks %b %size_font
    _themes.writeIniFonts fnotify %b %size_font
    _themes.writeIniFonts flist %b %size_font

    if (!$_themes.getText(FontChan)) { _script.setOption Theme FontChan %_f }
    if (!$_themes.getText(FontQuery)) { _script.setOption Theme FontQuery %_f }
  }

  if ($_themes.selectRightFont($_themes.getText(FontChan))) {
    %_f = $v1
    %size_font = $gettok(%_f,2,44) $gettok(%_f,1,44)
    %b = $iif($gettok(%_f,3,44) == b, b)

    %x = 1
    while ($scon(%x)) {
      scon %x
      %y = 1
      while ($chan(%y)) {
        %changed = $true
        font -d $+ %b $v1 %size_font
        inc %y
      }
      inc %x
    }
    if (!%changed) { _themes.writeIniFonts fchannel %b %size_font }
  }
  %changed = $false

  if ($_themes.selectRightFont($_themes.getText(FontQuery))) {
    %_f = $v1
    %size_font = $gettok(%_f,2,44) $gettok(%_f,1,44)
    %b = $iif($gettok(%_f,3,44) == b,b)

    %x = 1
    while ($scon(%x)) {
      scon %x
      %y = 1
      while ($query(%y)) {
        %changed = $true
        font -d $+ %b $v1 %size_font
        inc %y
      }
      %y = 1
      while ($chat(%y)) {
        %changed = $true
        font -d $+ %b = $+ $v1 %size_font
        inc %y
      }
      %y = 1
      while ($fserv(%y)) {
        %changed = $true
        font -d $+ %b = $+ $v1 %size_font
        inc %y
      }
      inc %x
    }
    if (!%changed) { _themes.writeIniFonts fquery %b %size_font }
    _themes.writeIniFonts fmessage %b %size_font
  }
  flushini $_mirc.ini
}
alias _themes.onStart {
  ;; if (!$_themes.currentLoaded) && ($_script.getOption(Themes,CheckLoadedThemeOnStart)) {
  if (!$_themes.currentLoaded) { theme -start }
}
alias -l _themes.writeIniFonts {
  ; alias idea from blue-elf
  var %win = @_temp._themes.writeIniFonts, %size, %font
  window -h %win
  if ($2 == b) {
    font -b %win $3- 
    %size = $calc($window(%win).fontsize + 700)
  }
  else {
    font %win $2-
    %size = $calc($window(%win).fontsize + 400)
  }
  %font = $window(%win).font
  window -c %win
  .writeini -n $_mirc.ini fonts $1 %font $+ , $+ %size $+ , $+ $iif(%font == Terminal,255,0)
}
alias -l _themes.themeToHash {
  var %hash = $1, %topic = $2, %thm = $_file.fixName($3-), %win = @_temp._themes.themeToHash, %x = 1
  if ($ini(%thm,%topic)) {
    window -h %win 
    loadbuf $+(-t,%topic) %win $shortfn(%thm) 
    while ($line(%win,%x)) { 
      tokenize 32 $v1 
      if (;* !iswm $1) && (& ?* iswm $1-) { _script.setOption %hash $1 $2- }
      inc %x 
    } 
    window -c %win 
  }
}

; Schemes popup
alias _themes.schemesPopup {
  if ($1 !isnum) { return }
  var %s = $_script.variableValue(Themes,Current,Schemes,Names), %curr = $_themes.currentLoaded, %
  if (!%s) { set $_script.variableName(Themes,Current,Schemes,Names) $_themes.getSchemesNamesFromFile(%curr,$read(%curr,nw,[mts])) }
  if ($1 == 1) { return $iif($_themes.currentLoadedScheme == 0,$style(1)) &None : _themes.loadTheme 0 %curr }
  if ($1 == 2) { return - }
  var %n = $calc($1 - 2), %currSchm = $gettok(%s,%n,44)
  if (%currSchm != $null) { return $iif(%n == $_themes.currentLoadedScheme,$style(1)) $+(&,%n,.) %currSchm : _themes.loadTheme %n %curr }
}
alias _themes.getSchemesNamesFromFile {
  var %x = 1, %f = $1-, %s = "", %ln
  if (!$isfile(%f)) { return }
  %ln = $read(%f,nw,[mts])
  while ($gettok($read(%f,nw, Scheme $+ %x *, %ln),2-,32) != $null) {
    %s = $addtok(%s,$v1,44)
    inc %x
  }
  return %s
}


; Edit current theme
alias themedit {
  if ($_themes.currentLoaded == $null) {
    _prompt.info No theme loaded at this time! $crlf $crlf $+ Use Themes dialog (/themes) to load one."Themes
    return 
  }
  if ($dialog(_themes)) { __dummy $_advanced.openDialog(_themes.current,themedit).modal }
  else { _advanced.openDialog _themes.current themedit }
}
dialog _themes.current {
  title "Current theme"
  size -1 -1 204 172
  option dbu

  button "&Edit", 1000, 74 155 40 11, ok
  button "&Cancel", 1001, 116 155 40 11, cancel
  button "&Help", 1002, 158 155 40 11

  box "", 306, 5 5 193 26
  box "", 313, 5 105 193 44
  box "", 319, 5 33 193 69

  text "&Basecolors:", 301, 15 16 29 8, right
  icon 302, 60 16 8 8,  $mircexe, 1
  icon 303, 78 16 8 8,  $mircexe, 1
  icon 304, 96 16 8 8,  $mircexe, 1
  icon 305, 114 16 8 8,  $mircexe, 1
  button "&Defaults", 307, 149 15 40 11

  text "&Prefix:", 308, 15 44 29 8, right
  edit "", 309, 46 42 93 11, autohs
  text "P&arentext:", 310, 15 58 29 8, right
  edit "", 311, 46 56 93 11, autohs
  text "You can use the same tags used on mTS engine (<c1>, <c2>, <c3>, <c4>, etc.). On parentext <text> represents message to be surrounded by parenthesis.", 312, 14 75 174 21
  button "D&efault", 317, 149 42 40 11
  button "De&fault", 318, 149 56 40 11

  button "Edit &theme file", 314, 13 116 41 11, disable
  button "Edit &script file", 315, 13 130 41 11, disable
  text "After editing one of this files you must reload theme in order to changes take effect.", 316, 72 118 96 20
}
on *:DIALOG:_themes.current:*:*:{
  if ($devent == INIT) {
    var %x = 1, %thm = $_themes.currentLoaded
    while (%x <= 4) {
      var %col = $_script.getOption(Theme,$+(Basecolor,%x))
      did -g $dname $calc(301 + %x) $_color.bmpFile(%col)
      inc %x
    }
    did -a $dname 309 $_themes.icon
    did -a $dname 311 $_themes.parentext
    if (%thm != $null) { did -e $dname 314 }
    if ($_themes.getText(Script)) { did -e $dname 315 }
  }
  elseif ($devent == SCLICK) {
    if ($did isnum 302-305) {
      var %did = $did, %t = $+(Basecolor,$calc($did - 301)), %col = $_script.getOption(Theme,%t), %new = $_prompt.selectColor(%col)
      did -g $dname %did $_color.bmpFile(%new)
    }
    elseif ($did == 307) {
      var %x = 1, %cols = $_themes.getText(Basecolors), %i
      while ($gettok(%cols,%x,44)) {
        %i = $v1
        did -g $dname $calc(301 + %x) $_color.bmpFile(%i)
        inc %x
      }
    }
    elseif ($did == 314) {
      if ($_file.isFile($_themes.currentLoaded)) { edit $v1 }
    }
    elseif ($did == 315) {
      var %f = $nofile($_themes.currentLoaded) $+ $_themes.getText(Script), %f = $_file.fixName(%f)
      if ($isfile(%f)) { edit %f }
    }
    if ($did == 317) {
      if ($_themes.getText(Prefix) != $null) { did -ra $dname 309  $v1 }
    }
    elseif ($did == 318) {
      if  ($_themes.getText(Parentext) != $null) { did -ra $dname 311 $v1 }
    }
    elseif ($did == 1000) {
      var %» = _script.setOption Theme, %i = 1, %id
      while (%i <= 4) {
        %id = $calc(301 + %i)
        %» $+(Basecolor,%i) $gettok($nopath($did(%id)),1,95)
        inc %i
      }
      %» Prefix $did(309)
      %» Parentext $did(311)
    }
  }
}

; ###############################################################################################################################
; ################################################ E V E N T S ######################################################################
; ###############################################################################################################################

on *:START:{ .timestamp -f $_themes.replaceBasecolors($iif($_themes.getText(TimestampFormat),$v1,[HH:nn])) }
on &^*:JOIN:#:{
  haltdef
  var %where = $_themes.eventOption($chan,1)
  if (%where == 2) { return }
  set -u0 %::cnick $nick($chan,$nick).color
  set -u0 %::target $target
  set -u0 %::nick $nick
  set -u0 %::chan $chan
  set -u0 %:echo echo $color(join text) -ti2 $+ $iif(%where == 1,s) $iif(%where != 1,$chan)
  set -u0 %::address $address
  set -u0 %::cmode $__pnick($chan,$nick)
  if ($nick == $me) {
    if ($_script.variableValue(Rejoining,$cid,$chan)) || ($chan($chan).status == kicked) { _themes.text Rejoin }
    else { _themes.text JoinSelf } 
  }
  else { _themes.text Join }
}
on &^*:PART:#:{
  haltdef
  var %where = $_themes.eventOption($chan,2)
  if ($nick == $me) || (%where == 2) { return }
  set -u0 %::cnick $nick($chan,$nick).color
  set -u0 %::target $target
  set -u0 %::nick $nick
  set -u0 %::chan $chan
  set -u0 %::address $address
  set -u0 %::text $strip($1-,o)
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %:echo echo $color(part text) -i2t $+ $iif(%where == 1,s) $chan
  _themes.text Part
}
on &^*:NICK:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::newnick $newnick
  set -u0 %::address $address
  if ($nick == $me) { 
    set -u0 %:echo echo $color(nick text) -ti2s
    _themes.text NickSelf
  }
  var %x = 1, %where = $_themes.eventOption($chan,7)
  while ($comchan(%::newnick,%x)) {
    set -u0 %::chan $v1
    set -u0 %::cmode $__pnick(%::chan,$newnick)
    set -u0 %::cnick $nick(%::chan,$newnick).color
    if (%where == 0) {
      set -u0 %:echo echo $color(nick text) -ti2 %::chan
      if (%::newnick == $me) { _themes.text NickSelf }
      else { _themes.text Nick }
    }
    inc %x 
  }
}
on &^*:TEXT:*:#:{
  haltdef
  set -u0 %::address $address
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %::text $strip($1-,o)
  set -u0 %::target $target
  set -u0 %:echo echo $color(normal text) -i2mbftl $chan 
  set -u0 %::chan $chan
  set -u0 %::nick $nick
  set -u0 %::cnick $nick($chan,$newnick).color
  _themes.text TexTChan
}
on &^*:TEXT:*:?:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %::text $strip($1-,o)
  set -u0 %::target $target
  var %echo = echo $color(Normal text) -ti2m
  if ($query(%::nick)) {
    set -u0 %:echo %echo %::nick
    _themes.text TextQuery
  }
  else {
    if ($window(Message window)) { set -u0 %:echo %echo $+ d }
    elseif ($_network.cidIsActive) && (!$_window.activeIsWindow) { set -u0 %:echo %echo $+ a }
    else { set -u0 %:echo %echo $+ s } 
    _themes.text TextMsg
  }
}
on &^*:QUIT:{
  haltdef
  var %where = $_themes.eventOption($chan,3), %x = 1
  if (%where == 3) { return }
  set -u0 %::nick $nick
  set -u0 %::text $strip($1-,o)
  set -u0 %::address $address
  while ($comchan($nick,%x)) {
    set -u0 %::chan $v1
    if (%where == 0) || (%where == 2) {
      set -u0 %:echo echo $color(quit text) -i2t %::chan
      _themes.text Quit
    }
    inc %x
  }
  unset %::chan
  if (%where == 1) || (%where == 2) {
    set -u0 %:echo echo $color(quit text) -sti2
    _themes.text Quit
  }
}
alias msg {
  if ($isid) || ((!$server) && (=* !iswm $1)) || ($2 == $null) { return }
  !.msg $1-
  if (!$show) { return }
  set -u0 %::target $1
  set -u0 %::text $2- 
  set -u0 %::nick $me
  if (%::target ischan) || ($query(%::target)) || ($_string.isChat(%::target)) || (=* iswm %::target) { 
    set -u0 %:echo echo $color(own text) -ti2 %::target
    if (%::target ischan) {
      set -u0 %::cnick $nick(%::target,$me).color
      set -u0 %::cmode $__pnick(%::target,$me)
      _themes.text TextChanSelf 
    }
    else { _themes.text TextQuerySelf }
  }
  else { 
    set -u0 %:echo echo $color(own text) -ti2 $+ $iif($_window.activeIsWindow,s,a) 
    _themes.text TextMsgSend 
  }
}
alias say {
  if (!$isid) && (($active ischan) || ($query($active))) && ($server) && (=* !iswm $active) || (!$0) { msg $active $1- }
}
alias amsg {
  if ($isid) || (!$server) || (!$0) || (!$chan(0)) { return }
  if ($_goptions.get(AutoDelayAmsgAme)) { _channel.delayMessages msg $1- }
  else {
    !.amsg $1-
    if (!$show) { return }
    set -u0 %::text $1- 
    set -u0 %::nick $me 
    var %x
    while ($chan(%x)) {  
      set -u0 %::chan $v1
      set -u0 %::cnick $nick(%::chan,$me).color
      set -u0 %::cmode $__pnick(%::chan,$me) 
      set -u0 %:echo echo $color(own text) -i2t %::chan 
      _themes.text TexChanSelf 
      inc %x
    }
  }
}
alias me { describe $active $1- }
alias action { describe $active $1- }
alias describe {
  set -u0 %::target $1
  if (!$server) || ($2 == $null) || ((%::target !ischan) && (!$query(%::target))) && (=* !iswm %::target) { return }
  !.describe %::target $2-
  set -u0 %::text $2-
  set -u0 %::nick $me
  set -u0 %:echo echo $color(action text) -i2t %::target
  if (%::target ischan) { _themes.text ActionChanSelf }
  else { _themes.text ActionQuerySelf }
}
alias ame {
  if (!$server) || (!$chan(0)) || ($1 == $null) { return }
  if ($_goptions.get(AutoDelayAmsgAme)) { _channel.delayMessages describe $1- }
  else {
    set -u0 %::text $1-
    set -u0 %::nick $me
    var %x = 1
    while ($chan(%x)) { 
      set -u0 %::chan $v1
      set -u0 %::cnick $nick(%::chan,$me).color
      set -u0 %::cmode $__pnick(%::chan,$me)
      set -u0 %:echo echo $color(action text) -ti2 %::chan 
      _themes.text ActionChanSelf 
      inc %x
    }
  }
}
on &*:INPUT:*:{
  if (($_mirc.commandChar !iswm $1) || ($ctrlenter)) && ($1 != $null) && ((=* iswm $active) || ($active ischan) || ($query($active))) {
    haltdef
    msg $active $iif($_script.variableValue(Events,OnInput,Text,$cid,$chan) != $null,$v1,$1-)
  }
}
on &^*:ERROR:*:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::text $2-
  set -u0 %:echo echo $color(other text) -ti2s
  _themes.text ServerError
}
on &^*:RAWMODE:#:{
  haltdef
  var %where = $_themes.eventOption($chan,4)
  if (%where == 2) { return }
  set -u0 %::address $address
  set -u0 %::target $target
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %::cnick $nick($chan,$nick).color
  set -u0 %::chan $chan
  set -u0 %::nick $nick
  set -u0 %::modes $1-
  set -u0 %::text $1-
  if (%where == 1) { set -u0 %:echo echo $color(mode text) -ti2s }
  else { set -u0 %:echo echo $color(mode text) -ti2 $chan }
  _themes.text Mode
}
on &^*:USERMODE:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %:echo echo $color(mode text) -i2sta
  set -u0 %::modes $1-
  set -u0 %::text $1-
  _themes.text ModeUser
}
on &^*:OP:#:{ haltdef }
on &^*:DEOP:#:{ haltdef }
on &^*:VOICE:#:{ haldef }
on &^*:DEVOICE:#:{ haltdef }
on &^*:BAN:#:{ haltdef }
on &^*:UNBAN:#:{ haltdef }
on &^*:SERVERMODE:#:{ haltdef }
on &^*:SERVEROP:{ haltdef }
on &^*:TOPIC:#:{
  haltdef
  var %where = $_themes.eventOption($chan,5)
  if (%where == 2) { return }
  if (%where == 1) { set -u0 %:echo echo $color(topic text) -ti2s }
  else { set -u0 %:echo echo $color(topic text) -ti2 $chan }
  set -u0 %::target $target
  set -u0 %::nick $nick
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %::cnick $nick($chan,$nick).color
  set -u0 %::text $1-
  set -u0 %::chan $chan
  _themes.text Topic
}
on &^*:KICK:#:{
  haltdef
  var %where = $_themes.eventOption($chan,8)
  if ($knick != $me) && (%where == 2) { return }
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %::cnick $nick($nick,$chan).color
  set -u0 %::address $address
  set -u0 %::kaddress $gettok($address($knick,5),2,33)
  set -u0 %::knick $knick
  set -u0 %::nick $nick
  set -u0 %::chan $chan
  set -u0 %::target $target
  set -u0 %::text $strip($1-,o)
  if (%where == 1) { set -u0 %:echo echo $color(kick text) -ti2s }
  else { set -u0 %:echo echo $color(kick text) -ti2 $chan }
  if ($knick == $me) {
    _themes.text KickSelf
    if (%where == 1) { set -u0 %:echo echo $color(kick text) -i2t $chan }
    else { set -u0 %:echo echo $color(kick text) -eti2s }
    _themes.text KickSelf
  }
  else { _themes.text Kick }
}
on &^*:ACTION:*:#:{
  haltdef
  set -u0 %::chan $chan
  set -u0 %::nick $nick
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %::cnick $nick($chan,$nick).color
  set -u0 %::address $address
  set -u0 %::text $strip($1-,o)
  set -u0 %::target $target
  set -u0 %:echo echo $color(action text) -ti2bfml $chan
  _themes.text ActionChan
}
on &^*:ACTION:*:?:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %::target $target
  set -u0 %::cmode $__pnick($chan,$nick)
  set %::text $strip($1-,o)
  var %echo = echo $color(action text) -ti2m
  if ($query($nick)) {
    set -u0 %:echo %echo $nick
    _themes.text ActionQuery
  }
  else {
    if ($window(Message window)) { set -u0 %:echo %echo $+ d }
    elseif ($_network.cidIsActive) && (!$_mirc.iniOption(4,5)) { set -u0 %:echo %echo $+ a }
    else { set -u0 %:echo %echo $+ s } 
    _themes.text ActionQuery
  }
}
on &^*:NOTIFY:{
  haltdef
  if ($_mirc.iniOption(2,16)) { return }
  set -u0 %::address $address
  set -u0 %::nick $nick
  set -u0 %::text $notify($nick).note
  set -u0 %:echo $_themes.echos(notify)
  _themes.text Notify
}
on &^*:UNOTIFY:{
  haltdef
  if ($_mirc.iniOption(2,16)) { return }
  set -u0 %::address $address
  set -u0 %::nick $nick
  set -u0 %::text $notify($nick).note
  set -u0 %:echo $_themes.echos(unotify)
  _themes.text UNotify
}
on &^*:INVITE:#:{
  haltdef
  set -u0 %::target $target
  set -u0 %::chan $chan
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %:echo $_themes.echos(invite)
  set -u0 %:comments $_script.variableValue(Invite,Echo,Comments,$cid,$nick,$chan)
  _themes.text Invite
}
on &^*:NOTICE:*:#:{
  haltdef
  set -u0 %::target $target
  set -u0 %::text $strip($1-,o)
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %::chan $chan
  set -u0 %::cnick $nick($chan,$nick).color
  set -u0 %::cmode $__pnick($chan,$nick)
  set -u0 %:echo $_themes.echos(channotice)
  _themes.text NoticeChan
}
on &^*:NOTICE:*:?:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %::text $strip($1-,o)
  set -u0 %::target $target
  set -u0 %:echo $_themes.echos(usernotice)
  _themes.text Notice
}
on &^*:WALLOPS:*:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %::text $strip($1-,o)
  set -u0 %::target $target
  set -u0 %:echo $_themes.echos(wallop)
  _themes.text Wallop
}
on &^*:SNOTICE:*:{
  haltdef
  set -u0 %::nick $nick
  set -u0 %::target $target
  set -u0 %::text $strip($1-,o)
  set -u0 %:echo $_themes.echos(snotice)
  _themes.text NoticeServer
}
on &^*:CHAT:*:{
  haltdef
  set -u0 %::address $address
  set -u0 %::target $target
  set -u0 %::nick $nick
  if (ACTION* iswm $1-) { 
    set -u0 %::text $strip($mid($1-,8,-1),o)
    set -u0 %:echo echo $color(action text) -i2tmlbf =$nick 
  }
  else { 
    set -u0 %::text $strip($1-,o)
    set -u0 %:echo echo $color(normal text) -i2tmlbf =$nick 
  }
  _themes.text TextQuery
}
CTCP &^*:*:*:{
  if ((DCC * iswm $1-) && ($target == $me)) { return }
  haltdef
  var %where = $_themes.eventOption($chan,6)
  set -u0 %::ctcp $1
  set -u0 %::nick $nick
  set -u0 %::address $address
  set -u0 %::target $target
  set -u0 %::text $2-
  set -u0 %:echo $_themes.echos(ctcp)
  if (%::target ischan) { _themes.text CtcpChan }
  else { _themes.text Ctcp }
}
on &*:CTCPREPLY:*:{
  haltdef
  set -u0 %::ctcp $upper($1)
  set -u0 %::nick $nick
  set -u0 %::target $target
  set -u0 %::address $address
  set -u0 %::chan $chan
  if ($1 == PING) && ($2- isnum) && ($2 < $ctime) { set -u0 %::text $duration($calc($ctime - $2)) }
  else { set -u0 %::text $2- }
  set -u0 %:echo echo $color(ctcp text) -ti2 $+ $iif($_network.cidIsActive && !$_window.activeIsWindow && $_mirc.iniOption(4,19),a,s)
  _themes.text CtcpReply
}
on &*:DNS:{
  haltdef
  set -u0 %:echo echo $color(info text) -i2t $+ $iif($_network.cidIsActive && !$_window.activeIsWindow,a,s)
  var %x = 1, %y = $dns(0)
  if (%y) {
    while (%x <= %y) {
      set -u0 %::nick $nick
      set -u0 %::address $dns(%x)
      set -u0 %::iaddress $dns(%x).ip
      set -u0 %::naddress $dns(%x).addr
      set -u0 %::raddress $remtok($dns(%x).ip $dns(%x).addr,$dns(%x),1,32)
      _themes.text DNSResolve
      inc %x
    }
  }
  else { _themes.text DNSError }
}
alias dns {
  if ($isid) || (!$server) { return }
  !.dns $1-
  if ($show) { 
    var %flag, %host = $1
    if ($istok(-h.-c,$1,46)) { 
      %flag = $1
      %host = $2
    }
    if (%flag != -h) && (. !isin %host) && ($address(%host,5)) { %host = $gettok($v1,2,64) }
    set -u0 %::address %host
    set -u0 %::nick %::address
    set -u0 %:echo echo $color(info text) -i2t $+ $iif(!$_window.activeIsWindow && $_network.cidIsActive,a,s)
    _themes.text DNS
  }
}
alias ctcpreply {
  if ($2 == $null) || (!$server) || ($isid) { return }
  !.ctcpreply $1-
  if ($show) {
    set -u0 %::target $1
    set -u0 %::nick $1
    set -u0 %::text $3-
    set -u0 %::ctcp $2
    set -u1 %:echo echo $color(ctcp text) -ti2 $+ $iif(!$_window.activeIsWindow && $_networks.cidIActive,a,s)
    _themes.text CtcpReplySend
  }
}
alias ctcp {
  if ($2 == $null) || (!$server) { return }
  !.ctcp $1-
  if ($show) {
    set -u0 %::target $1
    set -u0 %::nick $1 
    set -u0 %::chan $1 
    set -u0 %::ctcp $upper($2) 
    set -u0 %::text $3- 
    set -u0 %:echo echo $color(ctcp text) -ti2 $+ $iif(!$_window.activeIsWindow && $_network.cidIsActive,a,s)
    if ($1 ischan) { _themes.text CtcpChanSend }
    else { _themes.text CtcpSend }
  }
}
alias notice {
  if ($isid) || (!$server) || ($2 == $null) { return }
  !notice $1-
  if ($show) {
    set -u0 %::text $2-
    set -u0 %::nick $1
    set -u0 %::chan $1
    set -u0 %::target $1
    set -u0 %:echo echo $color(notice text) -ti2 $+ $iif(!$_window.activeIsWindow && $_network.cidIsActive,a,s)
    if ($1 ischan) { _themes.text NoticeSelfChan }
    else { _themes.text NoticeSelf }
  }
}
; Whois / Whowas
raw &311:*:{
  unset %::chan %::away %::ishelper %::isregd %::idletime %::realname %::serverinfo %::signontime
  set %::numeric $numeric
  set %::nick $2
  set %::address $3 $+ @ $+ $4
  set %::realname $6-
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.311 }
  halt
}
raw &314:*:{
  set %::numeric $numeric
  set %::nick $2
  set %::address $3 $+ @ $+ $4
  set %::realname $6-
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whowas)) { _themes.text RAW.314 }
  halt
}
raw &319:*:{
  set %::numeric $numeric
  set %::nick $2
  set %::chan $_channel.sortChannels(%::nick,$3-)
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.319 }
  halt
}
raw &312:*:{
  set %::nick $2
  set %::numeric $numeric
  set %::wserver $3
  set %::serverinfo $4-
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.312 }
  halt
}
raw &301:*:{
  set %::nick $2
  set %::numeric $numeric
  set %::away $3- 
  set %::text $3-
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.301 }
  halt
}
raw &307:*:{
  set %::numeric $numeric
  set %::isregd is
  set %::nick $2
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.307 }
  halt
}
raw &313:*:{
  set %::numeric $numeric
  set %::isoper is
  set %::nick $2
  set %::operline $3-
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.313 }
  halt
}
raw &317:*:{
  set %::nick $2
  set %::numeric $numeric
  set %::idletime $3
  set %::signontime $asctime($4)
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.317 }
  halt
}
raw &318:*:{
  set %::numeric $numeric
  set %::nick $2
  set %:echo $_themes.echos(whois)
  if ($_themes.eventExists(Whois)) { _themes.text Whois }
  else { _themes.text RAW.318 }
  halt
}
raw &369:*:{
  set %:echo $_themes.echos(whois)
  set %::numeric $numeric
  set %::nick $2
  if ($_themes.eventExists(Whowas)) { _themes.text Whowas }
  else { _themes.text RAW.369 }
  halt
}
; (this raw should be documented was a WHOIS event raw)
raw &310:*:{
  ;var not documented
  set %::ishelper is
  set %::numeric $numeric
  set %::nick $2
  set %::text $3-
  set %:echo $_themes.echos(whois)
  if (!$_themes.eventExists(Whois)) { _themes.text RAW.310 }
  halt
}
; (this raw should be documented was a WHOWAS event raw)
raw &406:*:{
  set %::numeric $numeric
  set %::nick $2
  set %::text $3-
  set %:echo $_themes.echos(whois)
  _themes.text RAW.406
  halt
}
#_Themes on
; The rest of the raws
raw &*:*:{
  var %raw = $right($+(00,$numeric),3)
  set %::numeric %raw
  set %::fromserver $nick
  set %::target $target

  goto %raw

  ;; TOPIC 
  :332 | set %:echo echo -ti2 $2 | set %::chan $2 | set %::text $3- | goto end
  :333 | set %:echo echo -ti2 $2 | set %::chan $2 | set %::nick $3 | set %::text $asctime($4) | goto end

  ;; NAMES
  :353
  set %::chan $3
  set %:echo $_themes.echos(names,%::chan)
  if ($4) { var %txt = $4- }
  else { 
    unset $_script.variableName(Names,Asking,$cid,%::chan)
    var %txt = No visible (-i) nicks. 
  }
  var %win = $+(@Names-,%::chan,$chr(40),$cid,$chr(41)), %e = $_echos.get(names)
  if (No visible * iswm %txt) { goto print }
  if ($_script.getOption(Echos,ParseNicksOnNames))  {
    var %max = $iif($_script.getOption(Echos,ParseNicksOnNamesN) isnum 1-,$v1,30), %x = 1, %nicks
    while ($_string.divideToken(%txt,%max,%x,32)) {
      set -u0 %::text $v1
      _themes.text RAW.353
      if (!$result) { __echoicon -sti2 %::chan -> %::text }
      inc %x
    }
  }
  else {
    :print 
    set -u0 %::text %txt
    _themes.text RAW.353
    if (!$result) { __echoicon -sti2 %::chan -> %::text }
  }
  goto end
  :366 | set %:echo $_themes.echos(names,$2) | set %::chan $2 | set %::text $3- | goto end

  ;; MOTD
  :372 | :375 | :376
  set %::text $2-
  set %:echo $_themes.echos(motd)
  goto end

  ;; USEHOST
  :302
  set %:echo echo -ti2 $+ $iif($_networks.cidIsActive && !$_window.activeIsWindow,a,s) 
  var %x = 1
  while ($gettok($2-,%x,32)) {
    var %i = $v1, %nick = $gettok(%i,1,61), %address = %nick $+ ! $+ $right($gettok(%i,2,61),-1)
    if (%nick == $me) && (*!*@* iswm %address) { set $_script.variableName(MyAddress,$_network.active,$me) %address }
    if ($right(%nick,1) == $chr(42)) { 
      set %::value $chr(42) 
      set %::nick $left(%nick,-1) 
    } 
    else { 
      set %::value $left($gettok(%i,2,61),1) 
      set %::nick %nick
    }
    set %::address $gettok(%address,2-,33)
    inc %x
  }
  goto end

  ;; MISC
  :002 | set %:echo echo -si2t | set %::value $8- | goto end
  :003 | set %:echo echo -sti2 | set %::value $6- | goto end
  :004 | set %:echo echo -sti2 | set %::value $3 | set %::users $4 | set %::modes $4 | set %::text $5 | goto end
  :221 | set %:echo echo -ati2 | set %::nick $me | set %::modes $2 | goto end
  :250 | set %:echo echo -sti2 | set %::value $5 | goto end
  :251 | set %:echo echo -sti2 | set %::users $4 | set %::text $iif($6 isnum,$6,7) | set %::value $11 | goto end
  :252 | set %:echo echo -sti2 | set %::value $2 | goto end
  :253 | set %:echo echo -sti2 | set %::value $2 | goto end
  :254 | set %:echo echo -sti2 | set %::value $2 | goto end
  :255 | set %:echo echo -sti2 | set %::users $4 | set %::value $7 | goto end
  :265 | set %:echo echo -sti2 | set %::users $5 | set %::value $7 | goto end
  :266 | set %:echo echo -sti2 | set %::users $5 | set %::value $7 | goto end
  :404 | set %:echo echo -ati2 | set %::text $3- | set %::value $3- | goto end

  :%raw 
  echo -sti2 $_themes.icon $2- 
  halt

  :end 
  _themes.text $+(RAW.,%raw) 
  if (!$result) { 
    :none
    echo -sti2 $_themes.icon $2- 
  }
  halt
}
alias _themes.infoEcho {
  var %where = $iif($_window.activeIsWindow,-s,$1), %text = $2-
  if (%where == $null) || (%text == $null) { return }
  echo %where $_themes.basecolor(2,[) $+ Info $+ $_themes.basecolor(2,]) $_themes.basecolor(1,%text) 
}
alias _themes.commandEcho { 
  echo $iif($_window.activeIsWindow,-s,-a) $_themes.basecolor(2,[) $+ / $+ $1 $+  $+ $_themes.basecolor(2,]) $2-
}
alias _themes.sintaxEcho {
  if ($1 != $null) { echo $color(info text) $iif($_window.activeIsWindow,-s,-a) [ $+ $_themes.basecolor(3,Sintax) $+ ]  $+ $upper($1) $+  - / $+ $1- }
}
alias _themes.errorEcho {
  set -u0 %:echo echo $color(info2 text) $iif($_window.activeIsWindow,-st,-at) 
  set -u0 %::text $1- 
  _themes.text Error
  if (!$result) { %:echo $_themes.basecolor(3,[) $+ Info $+ $_themes.basecolor(3,]) $_themes.basecolor(1,%::text) }
  _sounds.handle Error
}


#_Themes end
alias __echoicon {
  if (@* iswm $1) { 
    set -u0 %:echo aline -h $color(info text) $1 $_mirc.timestamp
    set -u0 %::text $2- 
  }
  elseif (-* iswm $1) { 
    var %1 = $iif($_window.activeIsWindow && a isin $1,$replace($1,a,s),$1) 
    set -u0 %:echo echo $color(info text) $iif(-* iswm %1,%1 $+ t,-t $1) 
    set -u0 %::text $2- 
  }
  else { 
    set -u0 %:echo echo $color(info text) -t $1 
    set -u0 %::text $2-
  }
  _themes.text Echo 
  if (!$result) { %:echo $_themes.icon %::text }
}
