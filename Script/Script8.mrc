
;_____________[ settings ] ________________________________________

dialog _settings.options {
  title "Settings system options"
  size -1 -1 253 183
  option dbu

  tab "&Backup", 1000, 6 5 241 150
  text "&File:", 2, 17 31 12 8, tab 1000
  edit "", 3, 30 29 194 11, tab 1000 autohs
  button "...", 14, 226 29 9 11, tab 1000
  box "&Compilation", 5, 13 50 227 57, tab 1000
  check "C&ompile backup file every N times script is started:", 6, 20 62 140 10, tab 1000
  edit "", 7, 184 62 47 11, tab 1000 autohs right
  check "Co&mpile backup file every N times script is closed:", 8, 20 75 140 10, tab 1000
  edit "", 9, 184 75 47 11, tab 1000 autohs right
  check "&Hide compilation's progress bar on", 10, 20 88 140 10, tab 1000
  combo 11, 184 88 47 50, tab 1000 size drop
  box "&Import", 20, 13 111 227 37, tab 1000
  radio "&Delete all current settings before importing others", 21, 19 122 126 10, tab 1000
  radio "&Overwrite only", 22, 19 133 146 10, tab 1000

  tab "&Excluded sections", 500
  box "Exclude this sections (if you don't specify them):", 100, 13 23 227 125, tab 500
  text "&View/edit:", 101, 19 40 44 8, tab 500 right
  edit "", 102, 66 39 167 11, tab 500 autohs
  text "&Load:", 103, 19 55 44 8, tab 500 right
  edit "", 104, 66 54 167 11, tab 500 autohs
  text "&Save:", 105, 19 70 44 8, tab 500 right
  edit "", 106, 66 69 167 11, tab 500 autohs
  text "&Compile:", 107, 19 85 44 8, tab 500 right
  edit "", 108, 66 84 167 11, tab 500 autohs
  text "&Import:", 109, 19 100 44 8, tab 500 right
  edit "", 110, 66 99 167 11, tab 500 autohs
  text "&Reset:", 111, 19 115 44 8, tab 500 right
  edit "", 112, 66 114 167 11, tab 500 autohs
  text "R&eset to default:", 113, 19 130 44 8, tab 500 right
  edit "", 114, 66 129 167 11, tab 500 autohs

  button "&Ok", 2000, 123 164 40 11, ok
  button "&Cancel", 1999, 166 164 40 11, cancel
  button "&Help", 1998, 208 164 40 11
}
on *:DIALOG:_settings.options:*:*:{
  if ($devent == INIT) {

    ;BACKUP
    did -a $dname 3 $remove($_settings.backupFile,")
    if ($_script.getOption(Settings,BackupOnStart)) { did -c $dname 6 }
    else { did -b $dname 7 }
    did -a $dname 7 $_settings.backupStartN
    if ($_script.getOption(Settings,BackupOnClose)) { did -c $dname 8 }
    else { did -b $dname 9 }
    did -a $dname 9 $_settings.backupCloseN
    didtok $dname 11 44 start,close,always
    if ($_script.getOption(Settings,HideProgressBar)) { did -c $dname 10 }
    else { did -b $dname 11 }
    did -c $dname 11 $_settings.hideProgressBarOn
    if ($_script.getOption(Settings,BackupImportType)) { did -c $dname 21 }
    else { did -c $dname 22 }

    ;EXCLUDE
    var %secs = ViewEdit Load Save Compile Import Reset ResetToDefault, %x = 1, %i, %id = 102
    while ($gettok(%secs,%x,32)) {
      %i = $+(ExcludeOn,$v1)
      did -a $dname %id $_script.getOption(Settings,%i)
      inc %x
      inc %id 2
    }
    var %t = $_script.getOption(Settings,LastSelectedTab)
    .timer -mi 1 0 did -c $dname $iif($istok(1000 500,%t,32),%t,1000)
  }
  elseif ($devent == SCLICK) {
    if ($did == 6) { did $iif($did(6).state,-e,-b) $dname 7 }
    if ($did == 8) { did $iif($did(8).state,-e,-b) $dname 9 }
    if ($did == 10) { did $iif($did(10).state,-e,-b) $dname 11 }
    if ($did == 13) { did $iif($did(13).state,-b,-e) $dname 11,12 }
    if ($did == 14) {
      var %f = $_prompt.selectFile($_file.fixName($+($mircdir,*.ini)),Settings - Select backup file,SettingsBackupFile)
      if (%f != $null) { did -ra $dname 3 %f }
    }
    if ($did == 100) { did $iif($did(100).state,-e,-b) $dname 101 }
    if ($did == 102) { did $iif($did(102).state,-e,-b) $dname 103 }
    if ($did == 2000) {
      var %» = _script.setOption Settings

      ;BACKUP
      %» BackupFile $did(3) 
      %» BackupOnStart $did(6).state 
      %» BackupOnStartN $gettok($did(7),1,32) 
      %» BackupOnClose $did(8).state 
      %» BackupOnCloseN $gettok($did(9),1,32)
      %» HideProgressBar $did(10).state 
      %» HideProgressBarOn $did(11).sel 
      %» BackupImportType $did(21).state

      ;EXCLUDE
      var %secs = ViewEdit Load Save Compile Import Reset ResetToDefault, %x = 1, %i, %id = 102
      while ($gettok(%secs,%x,32)) {
        %i = $+(ExcludeOn,$v1)
        %» %i $did(%id)
        inc %x
        inc %id 2
      }
    }
  }
  elseif ($devent == CLOSE) {
    _script.setOption Settings LastSelectedTab $dialog($dname).tab
  }
}

; Internal alias to list current settings to a file in a special format to be used with default settings feature. 
; Bad coded but that's not important!
alias _settings.toMyFile {
  var %f = c:\sets.txt, %hashs = $_hash.allMatching(*,$null,TEMP-*), %x = 1, %y , %i
  write -c %f
  while ($gettok(%hashs,%x,32)) {
    %i = $v1
    %y = 1
    while ($hget(%i,%y).item != $null) {
      write %f _script.setOption $_hash.notPrefixed(%i) $hget(%i,%y).item $hget(%i,%y).data
      inc %y
    }
    inc %x
  }
  echo -a DONE!
}
alias _settings.hideProgressBarOn { return $iif($int($_script.getOption(Settings,HideProgressBarOn)) isnum 1-3,$v1,3) }
alias _settings.backupFile { return $_file.fixName($iif($_script.getOption(Settings,BackupFile),$v1,$+($mircdir,feedback_backup.ini))) }
alias _settings.backupStartN { return $iif($_script.getOption(Settings,BackupOnStartN) isnum 1-,$int($v1),40) }
alias _settings.backupCloseN { return $iif($_script.getOption(Settings,BackupOnCloseN) isnum 1-,$int($v1),20)  }
alias _settings.backupHandler {
  var %c = $iif(HASH2INI* iswm $1,1,0)
  if ($show) {
    if (*_ERR iswm $1) { _themes.commandEcho settings $iif(%c,No settings saved at this time.,Unable to use backup file. Please check options and compile another backup.) }
    elseif ($2 == Start) { 
      var %t = Making $iif(%c,compilation,import) $+ ... 
      _progress.inc 0 0 %t
    }
    elseif ($2 == Progress) && ($4 isnum) && ($5 isnum) { _progress.inc $4 $5 }
  }
}
alias _settings.dir { 
  var %dir = $_profiles.mainDirectory($null,Settings\).current
  if (!$isdir(%dir)) { _file.makeDirectory %dir }
  return $remove(%dir,")
}
alias _settings.onStart {
  ; I need to load settings hash before others because it has options
  ; that are needed before load all other settings.

  var %hash = $_hash.prefixed(settings), %setsFile = $_file.fixName($+($_settings.dir,%hash,.hsh))
  if ($isfile(%setsFile)) {
    hmake %hash $iif($calc($lines(%setsFile) / 2) >= 200,50,15)
    hload %hash %setsFile
  }
  .settings -l
}
alias settings {
  ; Usage: /settings <-eslrdcio> [Section1] [SectionN]
  ;             -e - View settings
  ;             -s - Save settings
  ;             -l  - Load settings
  ;             -r  - Reset all settings
  ;             -d - Reset all settings to default
  ;             -c - Compile backup file with all current settings
  ;             -i  - Import settings from backup file
  ;             -o - Opens settings options dialog
  ;             -f - Opens backup file if it exists
  ;             -t - Deletes backup file if exists

  var %flag = $remove($1,-), %exclude = $iif($2 != $null,$2-,$null), %echo = $iif($show,_themes.commandEcho settings,__dummy), %prog = $iif($show,_progress.inc,__dummy)
  if (%flag == $null) { %flag = o }
  if (!$_string.areValidFlags(%flag,eslrdcioft)) { _themes.sintaxEcho settings <-eslrdcio> [Section1] [SectionN] }
  elseif (? !iswm %flag) { %echo You can only use one flag at the same time. }
  else {
    goto %flag

    :T
    if ($_file.isFile($_settings.backupFile)) {
      var %f = $v1
      if ($_prompt.yesNo(Do you really want to delete settings backup file?"Settings)) {
        .remove -b %f
        %echo Backup file deleted. You may compile another using /settings -c command. 
      }
    }
    else { %echo No backup file available at this moment. You may compile it using /settings -c command. }
    return   

    :F 
    if ($_file.isFile($_settings.backupFile)) { edit $v1 }
    else { %echo No backup file available at this moment. You may compile it using /settings -c command. }
    return

    :O
    _advanced.openDialog _settings.options settings
    return

    :E
    var %win = @Settings, %_win = @_temp._settingsSorted, $&
      %all_hashs = $_hash.allMatching(*,$iif(%exclude != $null,$v1,$_script.getOption(Settings,ExcludeOnViewEdit)),TEMP-*), $&
      %hashs = $sorttok(%all_hashs,32), %tt = $numtok(%hashs,32)
    if (!%tt) { %echo No settings available at this moment. }
    else {
      %prog 0 0 Listing settings...
      _window.open -iBlCkh -t30,43 %win
      titlebar %win viewer/editor (Advanced users only)
      var %x = 1, %hash, %y = 1, %nc = $_window.noChar, %item
      ;  aline %win Edit settings only if you known what you are doing (Advanced users)
      aline %win %nc
      while ($gettok(%hashs,%x,32)) {
        %hash = $v1
        %prog %x %tt Listing settings ( $+ $_hash.notPrefixed(%hash) $+ )...
        aline %win ______[ $upper($_hash.notPrefixed(%hash)) ]_____________________________________________________________
        aline %win %nc
        if (!$hget(%hash,0).item) { aline %win (No items in this section) }
        else {
          aline %win Item $chr(9) Value
          aline %win %nc
          ; Sort hash items using %_win
          _window.open -hls %_win
          while ($hget(%hash,%y).item != $null) { aline %_win $v1 | inc %y }
          %y = 1
          ; Write items from %_win to %win
          while ($line(%_win,%y) != $null) {
            %item = $v1
            aline %win %item $chr(9) $hget(%hash,%item)
            inc %y
          }
          window -c %_win
        }
        :nextHash
        __repeatCommand 3 aline %win %nc
        %y = 1
        inc %x   
      }
      %prog
      window -awb %win
    }
    return

    :S
    if (%exclude == $null) { %exclude = $_script.getOption(Settings,ExcludeOnSave) }
    var %hashs = $_hash.allMatching(*,%exclude,TEMP-*)
    var %path = $_file.fixName($_settings.dir), %f = $findfile(%path,*.hsh,0,.remove $_file.fixName($1-)), %x = 1, %i, %tt = $numtok(%hashs,32)
    if (%hashs == $null) { %echo No settings to be saved. }
    else {
      %prog 0 0 Saving settings...
      while ($gettok(%hashs,%x,32)) {
        %i = $v1 
        %prog %x %tt
        hsave -o %i $_file.fixName($+(%path,%i,.hsh))
        inc %x 
      }
      %prog
      %echo All settings sucessfuly saved.
    }
  }
  return

  :L
  if (%exclude == $null) { %exclude = $_script.getOption(Settings,ExcludeOnLoad) }
  var %x = 1, %dir = $_settings.dir, %all = $_hash.prefixed(*), %fstr = $+(%all,.hsh), %tt = $findfile(%dir,%fstr,0)
  if (!%tt) { %echo No settings to be loaded. }
  else {
    %prog 0 %tt Loading settings...
    hfree -w %all
    while ($findfile(%dir,%fstr,%x) != $null) {
      var %file = $v1, %hn = $left($nopath(%file) ,-4), %file = $_file.fixName(%file), %l = $calc($lines(%file) / 2)
      %prog %x %tt 
      if (!$istok(%exclude,%hn,32)) {
        hmake %hn $iif(%l >= 200,50,15)
        hload %hn %file
      }
      inc %x
    }
    %prog
    %echo All settings sucessfuly loaded.
  }
  return

  :R | :D
  if ($show) && (!$_prompt.yesNo(If sections like 'Theme' and\or 'Stats' are not excluded current theme and\or script statistics will be lost. $+ $crlf $crlf $+ Exclude a section using settings options $&
    or indicate it when using /settings command (/settings -flags [section1] [sectionN]). $+ $crlf $crlf $+  Reset all script settings $iif(%flag == D,to default values) anyway?"Settings)) { return }
  if (%exclude == $null) { %exclude = $_script.getOption(Settings,$iif(%flag == D,ExcludeOnResetToDefault,ExcludeOnReset)) }
  var %x = 1, %all = $_hash.prefixed(*), %hashs = $_hash.allMatching(%all,%exclude,TEMP-*), %i
  while ($gettok(%hashs,%x,32)) {
    %i = $v1
    hfree %i
    inc %x
  }
  if (%flag == D) {
    _script.setOption CtcpRep CTCP_SCRIPT TEXT:<SCRIPTLOGO> v<SCRIPTVERSION> written by <SCRIPTAUTHOR> - <SCRIPTURL>
    _script.setOption CtcpRep CTCP_TIME TEXT:Current time here: <FULLDATE>
    _script.setOption CtcpRep CTCP_USERINFO IGNORE
    _script.setOption CtcpRep CTCP_VERSION TEXT:<SCRIPTLOGO> v<SCRIPTVERSION> written by <SCRIPTAUTHOR> - <SCRIPTURL>
    _script.setOption Nicklist OpState 1
    _script.setOption Nicklist OwnerState 1
    _script.setOption Nicklist IRCopState 1
    _script.setOption Nicklist EnemyState 1
    _script.setOption Nicklist RegularState 1
    _script.setOption Nicklist Enabled 1
    _script.setOption Nicklist VoiceState 1
    _script.setOption Nicklist FriendState 1
    _script.setOption Nicklist MeState 1
    _script.setOption Nicklist HopState 1
    _script.setOption Seen TriggerWord !Seen
    _script.setOption Seen Response-7 <REQUEST> was last seen <TIMEAGO> ago (<TIME>) on <LASTCHANNEL> (Event: <EVENT>)
    _script.setOption Seen EnableResponsesToHalfops 0
    _script.setOption Seen EnableResponsesToAll 1
    _script.setOption Seen EnableResponsesToNofitied 0
    _script.setOption Seen Response-4 <TOTAL> nicks matching your request but only <DISPLAYED> displayed (<NICKS>)
    _script.setOption Seen EnableResponses 1
    _script.setOption Seen EnableResponsesToRegulars 0
    _script.setOption Seen Response-5 <REQUEST> is on channel
    _script.setOption Seen WarnTriggerUseTo 1
    _script.setOption Seen KeepOnlyLastEntries 1000
    _script.setOption Seen DeleteOlderThanDays 30
    _script.setOption Seen Response-2 No nicks matching your request (<REQUEST>)
    _script.setOption Seen SecondsToWaitBeforeRequest 5
    _script.setOption Seen Response-3 <TOTAL> nicks matching your request (<NICKS>)
    _script.setOption Seen ResponseMethod 1
    _script.setOption Seen DeleteOlderThan 1
    _script.setOption Seen EnableSeen 1
    _script.setOption Seen EnableResponsesToOperators 0
    _script.setOption Seen KeepOnlyLast 0
    _script.setOption Seen Response-1 No nick matching your request (<REQUEST>)
    _script.setOption Seen Response-6 <REQUEST> is currently on others channels common to me (<COMCHANNELS>)
    _script.setOption Seen EnableResponsesToVoices 0
    _script.setOption Proto ChanTriggerNextPenalty 0
    _script.setOption Proto KickMessageFormat <SCRIPTLOGO> - <MESSAGE> (<CHANCOUNT>/<ALLCOUNT>)
    _script.setOption Proto PersFlashMirc 1
    _script.setOption Proto ChanExemptNonRegular 1
    _script.setOption Proto ChanExemptHalfops 0
    _script.setOption Proto ChanExemptOps 0
    _script.setOption Proto PersKickBanFromAllChannels 0
    _script.setOption Proto ChanDontTriggerIfLagHigherThan 5
    _script.setOption Proto ChanExemptOwners 0
    _script.setOption Proto DefaultKickMessage Don't mess with <CHANNEL>
    _script.setOption Proto ChanExemptIRCops 0
    _script.setOption Proto PersChangeNickTo <ME>_
    _script.setOption Proto PersChangeNick 0
    _script.setOption Proto ChanDeopOnServerop 0
    _script.setOption Proto PersNoticeFlooder 1
    _script.setOption Proto ChanModesWhenEmpty +nt
    _script.setOption Proto PersCloseAllFlooderWindows 0
    _script.setOption Proto ChanResetPenaltiesCountAfter 300
    _script.setOption Proto ChanDontTriggerIfLagHigher 0
    _script.setOption Proto PersNoticeFlooderText You trigger <OFFENCE> protection (Ignore seconds: <IGNORETIME>)
    _script.setOption Proto PersPlaySound 1
    _script.setOption Proto ChanKickOnBan 0
    _script.setOption Proto PersPlaySoundOnlyWhenAway 0
    _script.setOption Proto ChanResetPenaltiesCount 0
    _script.setOption Proto ChanTriggerNextPenaltyAfter 10
    _script.setOption Proto ChanExemptVoices 0
    _script.setOption Proto PersPermanentIgnore 1
    _script.setOption Settings BackupOnStart 0
    _script.setOption Settings BackupImportType 1
    _script.setOption Settings BackupOnClose 1
    _script.setOption Settings ExcludeOnResetToDefault Theme
    _script.setOption Settings BackupOnCloseN 20
    _script.setOption Settings BackupOnStartN 40
    _script.setOption Settings BackupFile feedback_backup.ini
    _script.setOption Settings HideProgressBarOn 3
    _script.setOption Settings HideProgressBar 1
    _script.setOption GeneralOptions-(Default) CloseOpenQueriesOnAway 0
    _script.setOption GeneralOptions-(Default) UpdateIBLOn 2
    _script.setOption GeneralOptions-(Default) ShowUnbannedNicks 0
    _script.setOption GeneralOptions-(Default) ShowPagersOnBack 1
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackExcept 0
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackChatsUsing 1
    _script.setOption GeneralOptions-(Default) SynchTimeOnJoin 0
    _script.setOption GeneralOptions-(Default) StatisticsOnJoin 1
    _script.setOption GeneralOptions-(Default) UseMsgInsteadOfRaw 0
    _script.setOption GeneralOptions-(Default) CheckLagEvery 3
    _script.setOption GeneralOptions-(Default) AutojoinDelay 5
    _script.setOption GeneralOptions-(Default) NickModesOnConnectTo +ir
    _script.setOption GeneralOptions-(Default) EnablePagerWhen 1
    _script.setOption GeneralOptions-(Default) ShowNotifiedChangeNick 0
    _script.setOption GeneralOptions-(Default) RemindAwayOnWords 0
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackExceptIdle 0
    _script.setOption GeneralOptions-(Default) QuitAwayOnAutoAway 0
    _script.setOption GeneralOptions-(Default) DisableBeepsWhileAway 0
    _script.setOption GeneralOptions-(Default) OnInviteDo 3
    _script.setOption GeneralOptions-(Default) WarnLagHigherThan 10
    _script.setOption GeneralOptions-(Default) AwayLogPrivateMessagesWhen 1
    _script.setOption GeneralOptions-(Default) EnablePager 1
    _script.setOption GeneralOptions-(Default) AskBeforeUpdateIAL 0
    _script.setOption GeneralOptions-(Default) ChangeNickOnAwayTo <ME>_
    _script.setOption GeneralOptions-(Default) DefaultClonesMask 2
    _script.setOption GeneralOptions-(Default) DefaultIgnoresMask 20
    _script.setOption GeneralOptions-(Default) ActivateAutoAwayAfter 15
    _script.setOption GeneralOptions-(Default) TitlebarText <Nick>_<Lag>_<Idle>
    _script.setOption GeneralOptions-(Default) CheckLag 1
    _script.setOption GeneralOptions-(Default) ShowNotifiedJoin 1
    _script.setOption GeneralOptions-(Default) DeleteLogOnAway 0
    _script.setOption GeneralOptions-(Default) LagCheckMethod 1
    _script.setOption GeneralOptions-(Default) RemindAway 0
    _script.setOption GeneralOptions-(Default) ServicesOnChannel 0
    _script.setOption GeneralOptions-(Default) AntidleWhileAway 0
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackExceptIdleHigher 5
    _script.setOption GeneralOptions-(Default) TopicOnJoin 1
    _script.setOption GeneralOptions-(Default) LoginOn 1
    _script.setOption GeneralOptions-(Default) NamesOnJoin 0
    _script.setOption GeneralOptions-(Default) AutoRegainNick 0
    _script.setOption GeneralOptions-(Default) AwayLogChannelsWhen 1
    _script.setOption GeneralOptions-(Default) CommomChannelsOnQuery 1
    _script.setOption GeneralOptions-(Default) CreationTimeOnJoin 0
    _script.setOption GeneralOptions-(Default) ShowBannedNicks 0
    _script.setOption GeneralOptions-(Default) ChangeNickOnAway 0
    _script.setOption GeneralOptions-(Default) AutojoinMode 0
    _script.setOption GeneralOptions-(Default) SaveLogsOnBack 0
    _script.setOption GeneralOptions-(Default) AnnounceAwayMessage is away: <REASON> (Log: <LOG> \ Pagers: <PAGER>)
    _script.setOption GeneralOptions-(Default) RemindAwayExcept 0
    _script.setOption GeneralOptions-(Default) AutoWhowasFailedWhois 1
    _script.setOption GeneralOptions-(Default) UpdateIALOn 2
    _script.setOption GeneralOptions-(Default) AskBeforeUpdateIALMoreThan 200
    _script.setOption GeneralOptions-(Default) DisableFlashingWhileAway 0
    _script.setOption GeneralOptions-(Default) ShowClonesInJoinLine 0
    _script.setOption GeneralOptions-(Default) DeleteNickPagersOnAway 0
    _script.setOption GeneralOptions-(Default) RemindAwayOnChannelHighlight 1
    _script.setOption GeneralOptions-(Default) PauseAntidleIfHigher 0
    _script.setOption GeneralOptions-(Default) PauseAntidleIfHigherThan 6
    _script.setOption GeneralOptions-(Default) RemindAwayTo 1
    _script.setOption GeneralOptions-(Default) DeopOnAway 0
    _script.setOption GeneralOptions-(Default) AutoDelayAmsgAme 1
    _script.setOption GeneralOptions-(Default) WarnLagHigher 1
    _script.setOption GeneralOptions-(Default) MaximumAntidleTime 20
    _script.setOption GeneralOptions-(Default) RemindAwayOnPrivateMessage 1
    _script.setOption GeneralOptions-(Default) ServicesOnNicklist 0
    _script.setOption GeneralOptions-(Default) WarnPagerReceivedWhen 4
    _script.setOption GeneralOptions-(Default) DontUpdateIALMoreThan 400
    _script.setOption GeneralOptions-(Default) ServicesOnStatus 0
    _script.setOption GeneralOptions-(Default) AskBeforeAutoRegain 0
    _script.setOption GeneralOptions-(Default) WarnPagerReceived 1
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackQueriesUsing 1
    _script.setOption GeneralOptions-(Default) UpdateTitlebar 1
    _script.setOption GeneralOptions-(Default) AnnounceBackMessage is back from away after <DURATION>
    _script.setOption GeneralOptions-(Default) CloseQueryOnChat 0
    _script.setOption GeneralOptions-(Default) AnnounceAwayBack 1
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackQueries 0
    _script.setOption GeneralOptions-(Default) CloseQueryOnQuitUnotify 0
    _script.setOption GeneralOptions-(Default) WarnBeforeAutoAway 0
    _script.setOption GeneralOptions-(Default) NickModesOnConnect 1
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackChats 0
    _script.setOption GeneralOptions-(Default) DisableSoundsWhileAway 0
    _script.setOption GeneralOptions-(Default) ShowAlphabeticSortedChannels 1
    _script.setOption GeneralOptions-(Default) EnableAntidle 0
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackChannels 1
    _script.setOption GeneralOptions-(Default) UpdateTitlebarEvery 3
    _script.setOption GeneralOptions-(Default) ActivateAutoAway 0
    _script.setOption GeneralOptions-(Default) DontUpdateIAL 0
    _script.setOption GeneralOptions-(Default) RemindAwayEvery 30
    _script.setOption GeneralOptions-(Default) AnnounceAwayBackChannelsUsing 1
    _script.setOption Advanced PasteClipboardToInput 0
    _script.setOption Advanced OpenLogWindowOnJoin 0
    _script.setOption Advanced ShowStartingEchos 1
    _script.setOption Advanced OpenLogWindowOn 0
    _script.setOption Advanced ShowCommandOnTitlebar 0
    _script.setOption Advanced OpenLogWindowOnQuery 0
    _script.setOption Advanced CloseStatusWindow 1
    _script.setOption Advanced ShowPopupsOnShiftKey 1
    _script.setOption Advanced StatusPopups Connection,Channels,Nicknames,Part,List Channels,Usermodes,Statistics,Quit,Restart,Exit
    _script.setOption Advanced MenubarPopups Options,Control Panel,Profiles,Userlist,Away,Files & Folders,Utilities,Sockets,Script,Help
    _script.setOption Advanced ChannelsPopups Central,Protections,Modes,Mass,CTCP,Hop,Part,Quit
    _script.setOption Advanced NicklistPopups Whois,Whois+,UWho,Query,Notified,Friendly,Shitlisted,CTCP,DCC,Control,Colors
    _script.setOption Themes LoadColors 1
    _script.setOption Themes CheckLoadedThemeOnStart 1
    _script.setOption Themes CacheInfos 1
    _script.setOption Themes AskForFont 1
    _script.setOption Themes LoadTimestamp 1
    _script.setOption Themes LoadBasecolors 1
    _script.setOption Themes LoadNicklist 1
    _script.setOption Themes LoadFonts 1
    _script.setOption Themes CachePreviews 1
    _script.setOption Themes LoadImages 1
    _script.setOption Themes LoadSounds 0
    _script.setOption FKeys s4 cprots
    _script.setOption FKeys s5 pprots
    _script.setOption FKeys s2 advanced
    _script.setOption FKeys s11 update
    _script.setOption FKeys s3 themes
    _script.setOption FKeys 1 helpd
    _script.setOption FKeys s8 userlist
    _script.setOption FKeys s1 general
    _script.setOption FKeys 12 showmirc -t
    _script.setOption FKeys 2 cpanel
    _script.setOption FKeys s6 proto
    _script.setOption FKeys s7 ignores
    _script.setOption FKeys s12 news
    _script.setOption Nickcomp Enabled 1
    _script.setOption Nickcomp StyleNumber 3
    _script.setOption Nickcomp Triggers :
    _script.setOption Nickcomp IfMoreThanOneNick 1
    _script.setOption Nickcomp CustomCompletion <NICK><TRIGGER>
    _script.setOption Userlist AccessCommandsIfIdentified 1
    _script.setOption Userlist EnableUserlist 1
    _script.setOption Userlist ShittedDeopped 0
    _script.setOption Userlist ShittedBanned 0
    _script.setOption Userlist OppedVoicesIfIdentified 1
    _script.setOption Userlist ShittedIgnored 1
    _script.setOption Userlist AccessOptionsIfIdentified 1
    _script.setOption Userlist DefaultShitKick You're shitlisted!
    _script.setOption Userlist ExemptedIfIdentified 1
    _script.setOption Userlist DefaultMaskType 20
    _script.setOption Userlist ShittedKicked 0
    _script.setOption Userlist ProtectedIfIdentified 1
  }
  _images.loadImages
  _nicklist.allChannels
  %echo All settings reseted $iif(%flag == D,to default)
  return

  :C
  var %ini = $_settings.backupFile, %exclude = $iif(%exclude != $null,%exclude,$_script.getOption(Settings,ExcludeOnCompile))
  write -c %ini
  var %show? = $iif(!$show || ($_script.getOption(Settings,HideProgressBar) && $_settings.hideProgressBarOn == 3),.)
  __dummy $_hash.toIni(%show? $+ _settings.backupHandler,$_settings.dir,%ini,TEMP-*,%exclude)
  %echo Script settings compilation finished. Use /settings -f to open it ( $+ $longfn(%ini) $+ )
  return

  :I
  var %setsdir = $_settings.dir, %fstr = $+($_hash.prefixed(*),.hsh), %exclude = $iif(%exclude,$v1,$_script.getOption(Settings,ExcludeOnImport)), %ini = $_settings.backupFile
  if ($_script.getOption(Settings,BackupImportType)) { var %f = $findfile(%setsdir,%fstr,0,.remove $_file.fixName($1-)) }
  __dummy $_hash.fromIni(-sf,$iif(!$show,.) $+ _settings.backupHandler,%ini,%setsdir,TEMP-*,%exclude)
  if ($result) { %echo Script settings import finished (from $longfn(%ini) $+ ) }
}
alias -l _settings.getSelectedSection {
  var %win = $1
  if ($window(%win)) && ($sline(%win,1).ln isnum 2-) {
    var %x = $v1, %sec, %line
    while (%x >= 2) {
      %line = $line(%win,%x)
      if (_*_[ * ]__*_ iswm %line) { 
        var %sec = $gettok(%line,2-,91), %sec = $gettok(%sec,1,93)
        break
      }
      dec %x
    }
    return %sec
  }
}
menu @Settings {
  $iif($_settings.getSelectedSection($active) == $null,$style(2)) &Section
  .&Add item...:{
    var %sec = $_settings.getSelectedSection($active), %it = $_prompt.input(Item to add to $+(',$upper(%sec),') section (one word only):"~"Settings"tch"ItemAddedToSettings), $&
      %val = $_prompt.input($+(',%it,') value:"~"Settings"tch"ValueAddedToSettings)
    _script.setOption %sec $gettok(%it,1,32) %val
    settings -e
  }
  .-
  .&Delete:{
    var %sec = $_settings.getSelectedSection($active)
    if ($_prompt.yesNo(Do you really want to delete all $+(',$upper(%sec),') section?"Settings)) { 
      _script.setOption %sec
      settings -e
    }
  }
  $iif(!$sline($active,1) || $_settings.getSelectedSection($active) == $null,$style(2)) &Items
  .$iif(& $chr(9) * !iswm $sline($active,1) || $sline($active,0) != 1 || Item $chr(9) Value == $sline($active,1),$style(2)) &Edit...:{
    var %sec = $_settings.getSelectedSection($active), %it = $gettok($sline($active,1),1,9)
    _script.setOption %sec %it $_prompt.input(New $+(',%it,') value from $+(',$upper(%sec),') section:"~"Settings"tch"ItemEditedOnSettings)
    settings -e
  }
  .-
  .$iif(& $chr(9) * !iswm $sline($active,1) || Item $chr(9) Value == $sline($active,1),$style(2)) &Delete selected:{
    if (!$_prompt.yesNo(Deleting selected items. Make sure you known what you're doing. Continue?"Settings)) { return }
    var %x = 1, %i, %sec = $_settings.getSelectedSection($active)
    while ($sline($active,%x) != $null) {
      %i = $v1
      if (& $chr(9) * iswm %i) { _script.setOption %sec $gettok(%i,1,9) }
      inc %x
    }
    settings -e
  }
  .$iif(!$hget($_hash.prefixed($_settings.getSelectedSection($active)),0).item,$syle(2)) Delete &all:{
    var %sec = $_settings.getSelectedSection($active)
    if (!$_prompt.yesNo(Deleting all $+(',$upper(%sec),') items. Make sure you known what you're doing. Continue?"Settings)) { return }
    hfree -w $_hash.prefixed(%sec) *
    settings -e
  }
  -
  &Refresh:{ settings -e }
}


;_____________[ progress ] ________________________________________

alias _progress.inc {
  var %win = @_ProgressBar, %bar = 210, %font = Tahoma, %fs = 10, %n = $round($calc($1 * %bar / $2),0), %text = $3-
  if (%n !isnum $+(0-,%bar)) { return }
  if (!$window(%win)) {
    var %w = 230, %h = 50
    window -pfarodhkBz +fL %win $calc(($window(-1).w - %w) / 2) $calc(($window(-1).h - %h) / 2) %w %h
    drawrect -fnr %win $rgb(face) 1 0 0 %w %h
    drawtext -nor %win $rgb(text) %font %fs 10 12 $iif(%text != $null,%text,Progress...)
    drawrect -nr %win $rgb(text) 1 10 26 212 10 ;;round black bar
    drawrect -fnr %win $rgb(hilight) 1 11 27 210 8 ;;white bar
    drawdot %win
    .timer 1 0 window -c %win
  }
  if (%n >= %bar) { 
    if ($window(%win)) { window -c %win }
    return
  }
  if (%text != $null) {
    var %w = 230, %h = 50
    drawrect -fnr %win $rgb(face) 1 0 0 %w %h
    drawtext -nor %win $rgb(text) %font %fs 10 12 $iif(%text != $null,%text,Progress...)
    drawrect -nr %win $rgb(text) 1 10 26 212 10 ;;round black bar
    drawrect -fnr %win $rgb(hilight) 1 11 27 210 8 ;;white bar
  }
  window -a %win
  drawrect -fnr %win $rgb(hilight) 1 11 27 208 8
  drawrect -finr %win $rgb(0,0,255) 0 11 27 %n 8
  drawdot %win
}


;_____________[ antidle ] ________________________________________

alias _antidle.work {
  var %cids = $_network.identifierString(cid), %x = 1
  while ($gettok(%cids,%x,32)) {
    scid -t1 $v1 _antidle.timerHandler $v1
    inc %x
  }
}
alias -l _antidle.maximumTime { return $iif($_goptions.get(MaximumAntidleTime) isnum 1-,$v1,20) }
alias -l _antidle.awayAffect {
  if ($away) && (!$_goptions.get(AntidleWhileAway)) { return 1 }
}
alias -l _antidle.lagSeconds { return $iif($_goptions.get(PauseAntidleIfHigherThan) isnum 1-,$v1,6) }
alias _antidle.timerHandler {
  var %cid = $1, %timer = $+(ANTIDLE,~,%cid), %net = $scid(%cid).network, %max = $_antidle.maximumTime
  if ($timer(%timer)) {

    if ($timer(%timer).delay != %max) { scid -t1 %cid .timer $+ %timer 0 %max _antidle.timerHandler %cid  }
    if (!$_goptions.get(EnableAntidle)) {
      .timer $+ %timer off
      return
    }
    if ($_antidle.awayAffect) || (($_goptions.get(PauseAntidleIfHigher)) && ($_lag.time >= $_antidle.lagSeconds)) { return }
    scid -t1 %cid resetidle
    scid -t1 %cid !.msg $scid(%cid).me ^_ANTIDLE_^
  }
  elseif ($_goptions.get(EnableAntidle)) { scid -t1 %cid .timer $+ %timer 0 %max _antidle.timerHandler %cid }
}
on me:^&*:OPEN:?:^_ANTIDLE_^:{ halt }
on ^*:TEXT:^_ANTIDLE_^:?:{
  if ($nick == $me) { halt }
}


;_____________[ autojoin ] ________________________________________

alias autojoin {
  var %chans = $_goptions.get(ChannelsToAutojoin), %mode = $_autojoin.mode, %delay = $_autojoin.delay
  if (!%mode) && ($1 == -HaltIfDisable) { return }
  if (%mode == 3) { _autojoin.synch %chans }
  else {
    var %x = 1
    while ($gettok(%chans,%x,59)) {
      var %i = $v1, %chan = $gettok(%i,1,32), %com = join -n %chan $left($right($gettok(%i,2,32),-1),-1)
      if (%chan !ischan) {
        if (%mode == 2) { .timerAUTOJOIN~DELAY~ $+ $cid $+ %x 1 $calc((%x - 1) * %delay) %com }
        else { %com }
      }
      inc %x
    }
  }
}
alias _autojoin.delay { return $iif($int($_goptions.get(AutojoinDelay)) isnum 1-,$v1,5) }
alias _autojoin.mode { return $iif($int($_goptions.get(AutojoinMode)) isnum 0-3,$v1,0) }
alias _autojoin.synch {
  if ($1 != $null) { 
    unset $_script.variableName(Autojoin,Synch,*)
    set $_script.variableName(Autojoin,Synch,Channels,$cid) $1-
  }
  inc $_script.variableName(Autojoin,Synch,Token,$cid)
  var %x = $gettok($_script.variableValue(Autojoin,Synch,Channels,$cid),$_script.variableValue(Autojoin,Synch,Token,$cid),59), $&
    %chan = $gettok(%x,1,32), %com = join -n %chan $remove($gettok(%x,2,32),$chr(40),$chr(41))
  if (%chan) { 
    if (%chan !ischan) { %com }
  } 
  else { unset $_script.variableName(Autojoin,Synch,*) } 
}



;______________[ fkeys ]__________________________________________

alias fkeys { _advanced.openDialog _fkeys fkeys }
dialog _fkeys {
  title "Function keys"
  size -1 -1 206 176
  option dbu

  box "", 1, 3 3 199 151
  button "&Default", 3, 72 136 40 11, disable
  button "D&efault to all", 4, 114 136 40 11
  button "&New...", 5, 156 136 40 11

  button "&Ok", 100, 78 160 40 11, ok
  button "&Cancel", 99, 120 160 40 11, cancel
  button "&Help", 98, 162 160 40 11

  list 51, 8 12 189 122, size hsbar
}
on *:DIALOG:_fkeys:*:*:{
  if ($devent == INIT) {
    var %_fkeys = $_fkeys.allKeys, %x = 1, %i
    while ($gettok(%_fkeys,%x,32)) {
      %i = $ifmatch
      did -a $dname 51 $_fkeys.formatedListString($_fkeys.fkeyToString(%i),$_fkeys.fkeyCommand(%i))
      inc %x
    }
    did -z $dname 51
  }
  elseif ($devent == SCLICK) {
    if ($did == 51) {
      if ($_fkeys.selectedFkey) {
        var %fkey = $v1
        if ($_fkeys.defaultCommand(%fkey) != $null) { did -e $dname 3 }
        else { did -b $dname 3 }
      }
    }
    elseif ($did == 3) {
      if ($_fkeys.selectedFkey) {
        var %fkey = $v1, %com
        if ($_fkeys.defaultCommand(%fkey)) {
          %com = $v1
          did -oc $dname 51 $did(51).sel $_fkeys.formatedListString($_fkeys.fkeyToString(%fkey),%com)
          did -z $dname 51
        }
      }
      else { did -b $dname $did }
    }
    elseif ($did == 4) {
      if ($_prompt.yesNo(Do you really want to set all function keys commands to default? $+ $crlf $crlf $+ Note: keys without default command will be cleaned"Function keys)) {
        var %sel = $iif($did(51).sel,$v1,1), %x = 1, %keys = $_fkeys.allKeys
        while ($gettok(%keys,%x,32)) {
          var %i = $v1, %def = $_fkeys.defaultCommand(%i)
          did -o $dname 51 %x $_fkeys.formatedListString($_fkeys.fkeyToString(%i),%def)
          inc %x
        }
        did -c $dname 51 %sel
        did -z $dname 51
      }
      dialog -v $dname
    }
    elseif ($did == 5) { _fkeys.addNewCommand }
    elseif ($did == 98) { helpd -t Function keys }
    elseif ($did == 100) {
      var %line = 1, %all = $_fkeys.allKeys
      while (%line <= 36) {
        tokenize 160 $did(51,%line)
        _script.setOption FKeys $gettok(%all,%line,32) $2
        inc %line
      }
    }
  }
  elseif ($devent == DCLICK) {
    if ($did == 51) { _fkeys.addNewCommand }
  }
}
alias -l _fkeys.formatedListString {
  var %col = 75, %key = $1, %com = $2, %m = 0
  if (Control isin %key) { %m = 2 }
  elseif (Shift isin %key) { %m = 1 }
  var %w = $calc(%col - $width(%key,MS Shell Dlg,-8)), %blanks = $str( , $int($calc(%w / $width($chr(160),MS Shell Dlg, -8) - %m)))
  return %key %blanks %com
}
alias -l _fkeys.addNewCommand {
  if ($_fkeys.selectedFkey) {
    var %dname = _fkeys, %key = $v1, %key.str = $_fkeys.fkeyToString(%key), %sel = $did(%dname,51).sel, %curr = $gettok($did(%dname,51).seltext,2,160), $&
      %new = $_prompt.input(New %key.str command (Cancel\Blank for none): " $eval(%curr,1) " Function key - Add command"tc"AddFKeyCommand)
    did -ocz %dname 51 %sel $_fkeys.formatedListString(%key.str,%new)
  }
}
alias -l _fkeys.selectedFkey {
  var %dname = _fkeys, %sel = $gettok($did(%dname,51).seltext,1,160)
  return $_fkeys.stringToFkey(%sel)
}
alias -l _fkeys.allKeys { return 1 2 3 4 5 6 7 8 9 10 11 12 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 s12 c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 }
alias -l _fkeys.fkeyToString {
  if ($1 isnum 1-12) { return F $+ $1 }
  return $replace($1,c,Control+F,s,Shift+F)
}
alias -l _fkeys.stringToFkey {
  if (f* iswm $1) { return $remove($1,f) }
  return $replace($1,Control+F,c,Shift+F,s) 
}
alias -l _fkeys.fkeyCommand { return $_script.getOption(FKeys,$1) }
alias -l _fkeys.defaultCommand {
  var %1 = $1
  goto $1
  :1 | return helpd
  :2 | return cpanel
  :12 | return showmirc -t
  :s1 | return general
  :s2 | return advanced
  :s3 | return themes
  :s4 | return cprots
  :s5 | return pprots
  :s6 | return proto
  :s7 | return ignores
  :s8 | return userlist
  :s11 | return update
  :s12 | return news
  :%1
}
alias _fkeys.addTemporaryKey {
  ;  $_fkeys.addKey(<key>,<seconds>,<command>)
  var %key = $1, %time = $int($2), %command = $3-
  if (%time !isnum 1-) || (!$istok($_fkeys.allKeys,%key,32)) || (%command == $null) { return }
  set -u $+ %time $_script.variableName(FKeys,Temporary,%key) %command
  return $_fkeys.fkeyToString(%key)
}
alias _fkeys.useKey {
  var %key = $1, %var = $_script.variableValue(FKeys,Temporary,%key)
  if (%var != $null) { 
    %var
    unset $_script.variableName(FKeys,Temporary,%key)
  }
  elseif ($_fkeys.fkeyCommand(%key) != $null) { $v1 }
}
alias F1 { _fkeys.useKey 1 }
alias F2 { _fkeys.useKey 2 }
alias F3 { _fkeys.useKey 3 }
alias F4 { _fkeys.useKey 4 }
alias F5 { _fkeys.useKey 5 }
alias F6 { _fkeys.useKey 6 }
alias F7 { _fkeys.useKey 7 }
alias F8 { _fkeys.useKey 8 }
alias F9 { _fkeys.useKey 9 }
alias F10 { _fkeys.useKey 10 }
alias F11 { _fkeys.useKey 11 }
alias F12 { _fkeys.useKey 12 }
alias sF1 { _fkeys.useKey s1 }
alias sF2 { _fkeys.useKey s2 }
alias sF3 { _fkeys.useKey s3 }
alias sF4 { _fkeys.useKey s4 }
alias sF5 { _fkeys.useKey s5 }
alias sF6 { _fkeys.useKey s6 }
alias sF7 { _fkeys.useKey s7 }
alias sF8 { _fkeys.useKey s8 }
alias sF9 { _fkeys.useKey s9 }
alias sF10 { _fkeys.useKey s10 }
alias sF11 { _fkeys.useKey s11 }
alias sF12 { _fkeys.useKey s12 }
alias cF1 { _fkeys.useKey c1 }
alias cF2 { _fkeys.useKey c2 }
alias cF3 { _fkeys.useKey c3 }
alias cF4 { _fkeys.useKey c4 }
alias cF5 { _fkeys.useKey c5 }
alias cF6 { _fkeys.useKey c6 }
alias cF7 { _fkeys.useKey c7 }
alias cF8 { _fkeys.useKey c8 }
alias cF9 { _fkeys.useKey c9 }
alias cF10 { _fkeys.useKey c10 }
alias cF11 { _fkeys.useKey c11 }
alias cF12 { _fkeys.useKey c12 }



;_____________[ stats ]__________________________________________

alias statistics { _advanced.openDialog _stats stats }
dialog _stats {
  title "Statistics"
  size -1 -1 243 199
  option dbu

  tab "&General", 1, 4 3 233 169
  box "", 2, 10 19 221 147, tab 1
  text "Script version:", 3, 17 31 60 8, tab 1 right
  edit "", 4, 79 30 100 11, tab 1 read autohs right
  text "Loaded aliases files:", 5, 17 42 60 8, tab 1 right
  edit "", 6, 79 41 100 11, tab 1 read autohs right
  text "Loaded remotes files:", 7, 17 53 60 8, tab 1 right
  edit "", 8, 79 52 100 11, tab 1 read autohs right
  text "Profiles available:", 9, 17 77 60 8, tab 1 right
  edit "", 10, 79 76 100 11, tab 1 read autohs right
  text "Profile loaded:", 11, 17 88 60 8, tab 1 right
  edit "", 12, 79 87 100 11, tab 1 read autohs right
  text "Themes available:", 13, 17 112 60 8, tab 1 right
  edit "", 14, 79 111 100 11, tab 1 read autohs right
  text "Theme loaded (scheme):", 15, 17 125 60 8, tab 1 right
  edit "", 16, 79 122 100 11, tab 1 read autohs right
  text "Script opens:", 17, 17 147 60 8, tab 1 right
  edit "", 18, 79 146 100 11, tab 1 read autohs right
  button "&Reset", 19, 182 146 40 11, tab 1

  tab "&Networks", 100
  text "(NOT AVAILABLE)", 101, 8 89 226 8, disable tab 100 center

  button "&Close", 1000, 155 181 40 11, ok
  button "&Help", 999, 197 181 40 11
}
on *:DIALOG:_stats:*:*:{
  if ($devent == INIT) { _stats.updateGeneral }
  elseif ($devent == SCLICK) {
    if ($did == 19) { _stats.resetInfo ScriptOpens }
  }
}
alias _stats.inc {
  var %i = $1, %opt = $_stats.getInfo(%i)
  inc %opt $iif($2 isnum,$2,1) 
  _stats.setOption %i %opt
}
alias _stats.setOption { _script.setOption Stats $1- }
alias _stats.getOption { return $_script.getOption(Stats,$1) }
alias _stats.resetInfo {
  _stats.setOption $1 
  if ($dialog(_stats)) {
    _stats.updateGeneral
  }
}
alias _stats.updateGeneral {
  var %d = _stats
  did -ra %d 4 $_stats.getInfo(ScriptVersion)
  did -ra %d 6 $_stats.getInfo(LoadedAliases)
  did -ra %d 8 $_stats.getInfo(LoadedRemotes)
  did -ra %d 10 $_stats.getInfo(ProfilesAvailable)
  did -ra %d 12 $_stats.getInfo(ProfileLoaded)
  did -ra %d 14 $_stats.getInfo(ThemesAvailable)
  did -ra %d 16 $_stats.getInfo(ThemeLoaded)
  var %temp = $_stats.getInfo(ScriptOpens)
  did -ra %d 18 %temp
  if (%temp == 0) { did -b %d 19 }
}
alias _stats.getInfo {
  var %i = $1
  if (%i == $null) { return }
  goto %i

  :ScriptVersion | return $_script.version $_string.surrounded($asctime($_script.versionTime))
  :LoadedAliases | return $alias(0)
  :LoadedRemotes | return $script(0)
  :ProfilesAvailable | return $_profiles.totalAvailable
  :ProfileLoaded | return $_profiles.currentLoaded 
  :ThemesAvailable | return $_themes.totalAvailable
  :ThemeLoaded | return $_themes.getText(Name) $_string.surrounded($_themes.currentLoadedScheme(name))
  :ScriptOpens | return $iif($int($_stats.getOption(%i)) isnum 1-,$v1,0)
  :%i
}



;_____________[ advanced ] ________________________________________

alias aoptions { _advanced.openDialog _advanced advanced }
alias advanced { aoptions }
dialog _advanced {
  title "Advanced options"
  size -1 -1 221 180
  option dbu

  tab "&Dialogs", 1, 4 4 211 152
  text "&Normal open:", 2, 12 25 42 8, tab 1
  list 3, 11 34 90 102, tab 1 sort size
  text "On &desktop:", 4, 120 25 44 8, tab 1
  list 5, 119 34 90 102, tab 1 sort size
  button ">", 6, 103 55 14 12, tab 1
  button "<", 7, 103 69 14 12, tab 1
  check "&Show [/commands] on dialog titlebar", 8, 13 140 110 10, tab 1
  button ">>", 9, 103 90 14 12, tab 1
  button "<<", 10, 103 104 14 12, tab 1

  tab "&Popups", 100
  text "Select windows popups items you want to show and add them to right combo.", 101, 13 26 194 8, tab 100
  text "&Menubar:", 120, 13 42 25 8, tab 100
  text "&Status:", 121, 13 54 25 8, tab 100
  text "&Nicklists:", 122, 13 66 25 8, tab 100
  text "&Channels:", 123, 13 78 25 8, tab 100
  text "&Queries:", 124, 13 90 25 8, tab 100
  combo 130, 40 41 48 100, tab 100 size drop
  combo 131, 40 53 48 100, tab 100 size drop
  combo 132, 40 65 48 100, tab 100 size drop
  combo 133, 40 77 48 100, tab 100 size drop
  combo 134, 40 89 48 100, disable tab 100 size drop
  button "&Add >>", 140, 91 41 31 11, tab 100
  button "&Add >>", 141, 91 53 31 11, tab 100
  button "&Add >>", 142, 91 65 31 11, tab 100
  button "&Add >>", 143, 91 77 31 11, tab 100
  button "&Add >>", 144, 91 89 31 11, disable tab 100
  combo 150, 126 41 48 100, tab 100 size drop
  combo 151, 126 53 48 100, tab 100 size drop
  combo 152, 126 65 48 100, tab 100 size drop
  combo 153, 126 77 48 100, tab 100 size drop
  combo 154, 126 89 48 100, disable tab 100 size drop
  button "&Remove", 160, 177 41 31 11, tab 100
  button "&Remove", 161, 177 53 31 11, tab 100
  button "&Remove", 162, 177 65 31 11, tab 100
  button "&Remove", 163, 177 77 31 11, tab 100
  button "&Remove", 164, 177 89 31 11, disable tab 100
  check "Hi&de nicklist and channel popups when not opped", 170, 13 120 145 10, tab 100
  check "Sho&w popups when holding shift button", 171, 13 130 140 10, tab 100
  text "&Presets:", 172, 13 107 25 8, tab 100
  combo 173, 40 106 48 50, tab 100 size drop
  check "&Show commands in front of each menu item", 174, 13 140 128 10, tab 100

  tab "&Toogles", 12
  check "Sho&w starting echos (showed anyway if any error during process)", 14, 13 25 175 10, tab 12
  check "&Paste current clipboarded text to input dialog", 15, 13 36 172 10, tab 12
  check "O&pen log window on...", 16, 13 47 79 10, tab 12
  check "...channel join", 17, 92 47 50 10, tab 12
  check "...query open", 18, 149 47 50 10, tab 12
  check "C&lose 'Status Window' on disconnect", 19, 13 58 105 10, tab 12

  button "&Ok", 1000, 91 163 40 11, ok
  button "&Cancel", 999, 133 163 40 11, cancel
  button "&Help", 998, 175 163 40 11
}
on *:DIALOG:_advanced:*:*:{
  if ($devent == INIT) {

    ;Dialogs
    var %dtop = $_script.getOption(Advanced,DialogsOnDesktop), %dlogs = $_advanced.longDialogNames, %x = 1, %i, %t = $_script.getOption(Advanced,LastSelectedTab)
    .timer -mi 1 0 did -c $dname $iif($istok(1 12 100,%t,32),%t,1)
    while ($gettok(%dlogs,%x,34)) {
      %i = $v1
      if ($istok(%dtop,%i,34)) { did -a $dname 5 %i }
      else { did -a $dname 3 %i }
      inc %x
    }

    ; Toogles
    if ($_script.getOption(Advanced,ShowCommandOnTitlebar)) { did -c $dname 8 }
    if ($_script.getOption(Advanced,ShowStartingEchos)) { did -c $dname 14 }
    if ($_script.getOption(Advanced,PasteClipboardToInput)) { did -c $dname 15 }
    if ($_script.getOption(Advanced,OpenLogWindowOnJoin)) { did -c $dname 17 }
    if ($_script.getOption(Advanced,OpenLogWindowOnQuery)) { did -c $dname 18 }
    if (($did(17).state) || ($did(18).state)) && ($_script.getOption(Advanced,OpenLogWindowOn)) { did -c $dname 16 }
    else { did -b $dname 17,18 }
    if ($_script.getOption(Advanced,CloseStatusWindow)) { did -c $dname 19 }

    ; Popups
    didtok $dname 173 44 All,Condensed,None
    var %t = $_advanced.popupsNames, %x = 1, %total = $numtok(%t,44)
    while (%x <= %total) {
      var %pop = $gettok(%t,%x,44), %combo1 = $calc(%x + 129), %combo2 = $calc(%x + 149), %y = 1, %saves = $_script.getOption(Advanced,$+(%pop,Popups)), $&
        %allitems = $_advanced.availablePopups(%pop)
      didtok $dname %combo1 44 %allitems
      didtok $dname %combo2 44 $str($+(-,$chr(44)),$numtok(%allitems,44))
      while ($gettok(%saves,%y,44) != $null) {
        var %item = $v1
        if ($findtok(%allitems,%item,1,44)) { did -o $dname %combo2 $v1 %item }
        inc %y
      }
      inc %x
    }
    if ($_script.getOption(Advanced,HidePopupsIfNotOpped)) { did -c $dname 170 }
    if ($_script.getOption(Advanced,ShowPopupsOnShiftKey)) { did -c $dname 171 }
    if ($_script.getOption(Advanced,ShowCommandOnMenu)) { did -c $dname 174 }
  }
  elseif ($devent == SCLICK) {
    if ($did == 6) && ($did(3).seltext) {
      did -ac $dname 5 $v1
      did -d $dname 3 $did(3).sel 
    }
    elseif ($did == 7) && ($did(5).seltext) {
      did -ac $dname 3 $v1
      did -d $dname 5 $did(5).sel
    }
    elseif ($did isnum 9-10) {
      did -r $dname 3,5
      didtok $dname $iif($did == 9,5,3) 34 $_advanced.longDialogNames
    }
    elseif ($did == 16) { did $iif($did(16).state,-e,-b) $dname 17,18 }
    elseif ($did isnum 140-144) {
      var %ntemp = $right($did,1), %combo1 = $calc(130 + %ntemp), %combo2 = $calc(150 + %ntemp)
      if ($did(%combo1).seltext != $null) { did -o $dname %combo2 $did(%combo1).sel $v1 }
    }
    elseif ($did isnum 160-164) {
      var %combo2 = $calc($did - 10)
      if ($did(%combo2).seltext != $null) { 
        did -o $dname %combo2 $did(%combo2).sel -
        did -u $dname %combo2
      }
    }
    elseif ($did == 172) {
      var %t = $_advanced.popupsNames, %x = 1, %total = $numtok(%t,44)
      while (%x <= %total) {
        %id = $calc(%x + 149)
        did -r $dname %id
        didtok $dname %id 44 $_advanced.availablePopups($gettok(%t,%x,44))
        inc %x
      }
    }
    elseif ($did == 173) {
      var %t = $_advanced.popupsNames, %x = 1, %total = $numtok(%t,44)
      if ($did($did).sel == 1) || ($v1 == 3) {
        var %temp = $v1
        ; All or None
        while (%x <= %total) {
          var %id = $calc(%x + 149), %allitems = $_advanced.availablePopups($gettok(%t,%x,44))
          did -r $dname %id
          didtok $dname %id 44 $iif(%temp == 1,  %allitems, $str($+(-,$chr(44)),$numtok(%allitems,44))  )
          inc %x
        }
      }
      elseif ($did($did).sel == 2) {
        did -r $dname 150,151,152,153
        didtok $dname 150 44 Options,-,Profiles,Userlist,-,-,Utilities,Sockets,Script,Help
        didtok $dname 151 44 Connection,Channels,Nicknames,-,-,-,-,Quit,-,Exit
        didtok $dname 152 44 -,Whois+,-,Query,Notified,Friendly,Shitlisted,-,DCC,Control,-
        didtok $dname 153 44 Central,Protections,Modes,Mass,-,-,Part,-
      }
    }
    elseif ($did == 1000) {
      var %» = _script.setOption Advanced

      ; Dialogs
      %» DialogsOnDesktop $didtok(5,34)
      %» ShowCommandOnTitlebar $did(8).state

      ; Popups
      var %t = $_advanced.popupsNames, %x = 1, %total = $numtok(%t,44)
      while (%x <= %total) {
        _script.setOption Advanced $+($gettok(%t,%x,44),Popups) $didtok($calc(%x + 149),44)
        inc %x
      }
      %» HidePopupsIfNotOpped $did(170).state
      %» ShowPopupsOnShiftKey $did(171).state
      %» ShowCommandOnMenu $did(174).state

      ; Toogles
      %» ShowStartingEchos $did(14).state
      %» PasteClipboardToInput $did(15).state
      %» OpenLogWindowOn $did(16).state
      %» OpenLogWindowOnJoin $did(17).state
      %» OpenLogWindowOnQuery $did(18).state
      %» CloseStatusWindow $did(19).state
    }
  }
  elseif ($devent == CLOSE) { _script.setOption Advanced LastSelectedTab $dialog($dname).tab }
}
alias _advanced.commandOnMenu {
  if ($_script.getOption(Advanced,ShowCommandOnMenu)) { return $chr(9) (/ $+ $$1 $+ ) }
}
alias _advanced.longDialogNames {
  return Control panel"General"Advanced"Themes"Images"Nicklist"Sounds"Echos"Personal protections"Channel protections"Protections options"Filters"Function keys"Nick completion" $+ $&
    Userlist"Userlist options"ID3"Perform"Ascii viewer"Euro converter"Portscan"Settings options"Help"Sound player"Sound player options"Notepad"Profiles" $+ $&
    Alarm options"Sockets statistics"Mixer"Seen options"Seen database"Notes"Pagers viewer"Away log viewer"Wizard"Statistics"News"CTCP Replies
}
alias _advanced.shortDialogNames {
  return _cpanel"_goptions.general"_advanced"_themes"_images"_nicklist"_sounds"_echos"_pprots"_cprots"_proto"_filters"_fkeys"_nickcomp" $+ $&
    _userlist"_userlist.options"_id3.viewer"_perform.events"_ascii"_euro.converter"_portscan"_settings.options"_help"_player"_player.options"_notepad"_profiles" $+ $&
    _alarm.options"_sstats"_mixer"_seen.options"_seen.database"_notes"_pagers.viewer"_awaylog"_wizard"_stats"_news"_ctcprep
}
alias _advanced.openDialog {
  var %d = $$1, %cmd = $2, %_d = $iif($3 != $null,$3,%d)
  if ($dialog(%_d)) { dialog -v %_d }
  else {
    var %long = $gettok($_advanced.longDialogNames, $findtok($_advanced.shortDialogNames,%d,1,34) , 34), %f
    if ($istok($_script.getOption(Advanced,DialogsOnDesktop),%long,34)) { %f = -md }
    else { %f = -mn }
    if ($prop == modal) { __dummy $dialog(%_d,%d,-4) }
    else { dialog %f %_d %d }
    if ($dialog(%_d)) && ($_script.getOption(Advanced,ShowCommandOnTitlebar)) && (%cmd != $null) {
      tokenize 45 $dialog(%_d).title
      dialog -t %_d $1 [[ $+ / $+ %cmd $+ ] $iif($2 != $null,- $2-)
    }
  }
}
alias _advanced.popupsNames { return Menubar,Status,Nicklist,Channels }
alias _advanced.availablePopups {
  goto $1
  :Menubar | return Options,Control Panel,Profiles,Userlist,Away,Files & Folders,Utilities,Sockets,Script,Help
  :Status | return Connection,Channels,Nicknames,Part,List Channels,Usermodes,Statistics,Quit,Restart,Exit
  :Nicklist | return Whois,Whois+,UWho,Query,Notified,Friendly,Shitlisted,CTCP,DCC,Control,Colors
  :Channels | return Central,Protections,Modes,Mass,CTCP,Hop,Part,Quit
}
alias _advanced.showPopup {
  var %pop = $1, %item = $2
  if ($mouse.key & 4) && ($_script.getOption(Advanced,ShowPopupsOnShiftKey)) { return 1 }
  if ($istok(Channel Nicklist,%pop,44)) && ($_script.getOption(Advanced,HidePopupsIfNotOpped)) && (!$_channel.meOp($active)) { return 0 }
  var %saves = $_script.getOption(Advanced,$+(%pop,Popups))
  if ($istok(%saves,%item,44)) { return 1 }
}


;_____________[ events ] ________________________________________

CTCP *:*:?:{
  _pager.received $nick $1-
  _ctcprep.onEvent Private $nick $1-
}
CTCP *:*:#:{
  _ctcprep.onEvent Channel $chan $1-
}
on ^*:TEXT:*:#: {
  _seen.onTrigger $chan $nick $1-
  _away.reminderHandler OnChannelText $chan $nick $1-

}
on ^*:TEXT:*:?:{
  _away.reminderHandler OnPrivateMessage $nick $nick $1-
}
on ^*:CHAT:*:{
  _away.reminderHandler OnPrivateMessage =$nick $nick $1-
}
on *:EXIT:{ 
  if ($_script.getOption(Settings,BackupOnClose)) { 
    var %n = $_settings.backupCloseN
    if (%n // $_script.getOption(Stats,StartCounter)) { $iif($_script.getOption(Settings,HideProgressBar) && $_settings.hideProgressBarOn !isnum 2-3,.) $+ settings -c }
  }
  .settings -s 
  titlebar - $_script.name (disconnected)
  _perform.work Exit
}
on *:START:{
  .ctcp on
  .remote on
  .raw on
  .events on

  _settings.onStart

  _stats.inc ScriptOpens
  var %starts = $_stats.getInfo(ScriptOpens)

  if ($_script.isFirstRuntime) { 
    showmirc -n
    presentation -c
    showmirc -x
    .timer -im 1 0 __dummy $wizard
  }

  if ($_script.getOption(Settings,BackupOnStart)) { 
    var %n = $_settings.backupStartN
    if (%n // %starts) { $iif($_script.getOption(Settings,HideProgressBar) && $_settings.hideProgressBarOn == 1 || $v1 == 3 ,.) $+ settings -c }
  }
  _themes.onStart
  _titlebar.work
  _profiles.onStart
  _perform.work Start

  if ($_script.getOption(Userlist,EnableUserlist)) { .enable #_Userlist }
  else { .disable #_Userlist }

  if (%n == 1) {
    _script.setOption About OpenOnStart 1
    about
  }
  elseif ($_script.getOption(About,OpenOnStart)) { about }

  if ($_script.getOption(Advanced,ShowStartingEchos)) {
    var %thm = $iif($_themes.getText(Name),$v1,<Default>), %schm = $iif($_themes.currentLoadedScheme(name) != $null,$v1,<no scheme>), $&
      %auth = $iif($_themes.getText(Author),$v1,$_script.author)
    echo -s [ $+ $_themes.basecolor(3,Profile) $+ ] Current loaded: $_profiles.currentLoaded
    echo -es [ $+ $_themes.basecolor(3,Theme) $+ ] Name: %thm ( $+ %schm $+ ) / Author: %auth 
    echo -se [ $+ $_themes.basecolor(3,Script) $+ ] $_script.logo v $+ $_script.version running with mIRCv $+ $version under windows $+ $os $+ : $_script.quote
  }
}
on *:QUIT:{
  if ($query($nick)) && ($_goptions.get(CloseQueryOnQuitUnotify)) { close -m $nick }
}
on *:CONNECT:{
  _login.onEvent 2
  _script.setOption Lag $cid
  _lag.work
  _lagbar.work
  _antidle.work
  _regainick.onConnect
  autojoin -HaltIfDisable
  _antidle.timerHandler $cid
  _away.autoAwayTimer
  umodes -d
  _connection.onConnectEvent 
}
on *:DISCONNECT:{ 
  titlebar - $_script.name (disconnected)
  if ($_script.getOption(Advanced,CloseStatusWindow)) { window -c "Status Window" }
}
on ^*:INVITE:#:{
  _invite.onEvent $nick $chan
}
on ^*:SNOTICE:*:{ 
  _filters.handleEvent SNotices $1-
}
on ^*:NOTICE:*:*:{ 
  _login.onEvent 3 $nick $1-
  if ($nick != $me) { _sounds.handle Notice }
}
on ^*:WALLOPS:*:{ 
  _filters.handleEvent Wallops $1- 
}
on ^*:JOIN:#:{
  _seen.addNickToTable $nick $address $chan Join $ctime
  if ($nick == $me) {
    set $_script.variableName(Joining,$cid,$chan) 1
    _recent.addItem -c $chan
    _perform.work Join (You join)
  } 
  else {
    _nicklist.nick $chan $nick $fulladdress
    if ($_goptions.get(ShowNotifiedJoin)) && ($nick isnotify) { _themes.infoEcho -a Notified user $nick was joined $chan $+  }
  }
}
on ^*:PART:#:{
  _seen.addNickToTable $nick $address $chan Part $ctime $1-
  if ($nick == $me) {
    _perform.work Part (You part)
  }
}
on ^*:NICK:{
  if ($newnick == $me) { _recent.addItem -n $newnick }
  if ($_goptions.get(ShowNotifiedChangeNick)) && ($nick isnotify) { _themes.infoEcho -a Notified user $nick was changed nick to $newnick $+  ( $+ $_channel.common($newnick) $+ ) }
}
on ^*:OP:#:{
  if ($opnick == $me) { 
    _sounds.handle OpSelf
    _ial.updateOnJoinOp Op $chan 
  }
  _nicklist.nick $chan $opnick $address($opnick,5)
}
on ^*:DEOP:#:{
  if ($opnick == $me) { _sounds.handle Deopself }
  _nicklist.nick $chan $opnick $address($opnick,5)
}
on ^*:VOICE:#:{
  _nicklist.nick $chan $vnick $address($vnick,5)
}
on ^*:DEVOICE:#:{
  _nicklist.nick $chan $vnick $address($vnick,5)
}
on ^*:KICK:#:{
  _seen.addNickToTable $knick $iif($address($knick,5) != $null,$gettok($v1,2,33),<Unknown>) $chan Kick $ctime $1- 
  if ($knick == $me) { 
    _sounds.handle KickSelf
    _perform.work Kick (You're kicked)
  }
  elseif ($nick == $me) {
    _perform.work Kick (You kick)
  }
  else { _sounds.handle Kick }
}
on ^*:NOTIFY:{
  _regainick.onNotify $nick
}
on ^*:UNOTIFY:{
  if ($query($nick)) && ($_goptions.get(CloseQueryOnQuitUnotify)) { close -m $nick }
  ; Last call because it can be halted
  _regainick.onUnotify $nick
}
on *:OPEN:=:*:{
  if ($query($nick)) && ($_goptions.get(CloseQueryOnChat)) { close -m $nick }
}
on *:OPEN:?:{
  _events.onQuery $nick
}
on ^*:BAN:#:{
  var %bnicks = $_channel.nicksMatchingAddress($chan,$banmask).etc
  if ($me isop $chan) && ($_goptions.get(ShowBannedNicks)) && (%bnicks != $null) {
    _themes.infoEcho $chan Banned nicks ( $+ $_channel.nicksMatchingAddress($chan,$banmask,0) $+ ): %bnicks
  }
  if ($istok(%bnicks,$me,32)) { 
    _sounds.handle BanSelf
    _perform.work Ban (You're banned)
  }
  elseif ($nick == $me) {
    _perform.work Ban (You ban)
  }
}
on ^*:UNBAN:#:{
  if ($me isop $chan) && ($_goptions.get(ShowUnbannedNicks)) && ($_channel.nicksMatchingAddress($chan,$banmask).etc != $null) {
    var %bnicks = $v1 
    _themes.infoEcho $chan Unbanned nicks ( $+ $_channel.nicksMatchingAddress($chan,$banmask,0) $+ ): %bnicks
  }
}
on ^*:SERVEROP:#:{
  _nicklist.nick $chan $opnick $address($opnick,5)
}
on ^*:OWNER:#:{
  _nicklist.nick $chan $opnick $address($opnick,5)
}
on ^*:DEOWNER:#:{
  _nicklist.nick $chan $opnick $address($opnick,5)
}
on *:INPUT:#:{ 
  set $_script.variableName(Events,OnInput,Text,$cid,$chan) $_nickcomp.handleInput($chan,$1-) 
}
/*
on *:INPUT:?:{ _awaylog.cancelCloseTimer PRIVATETEXT $active }
on *:INPUT:=:{ _awaylog.cancelCloseTimer CHAT $active }

on *:TEXT:*:#:{ _awaylog.saveEvent CHANTEXT $1- }
*/
on *:TEXT:*:?:{ _login.onEvent 4 $nick $1- }






RAW 301:*:{
  if (!$_script.variableValue(Whois,Active,$cid,$2)) { halt }
}

;Names !
RAW 353:*:{
  if (!$_script.variableValue(Names,Asking,$cid,$3)) { 
    halt 
  }
}
RAW 366:*:{ 
  _autojoin.synch
  if ($_script.variableValue(Joining,$cid,$2)) {
    unset $_script.variableName(Joining,$cid,$2)
    if ($_goptions.get(StatisticsOnJoin)) { chanstats -tovhu $2 }
    if ($_goptions.get(NamesOnJoin)) { names $chan }
    _ial.updateOnJoinOp Join $2
  }
  if (!$_script.variableValue(Names,Asking,$cid,$2)) { halt }
  else { unset $_script.variableName(Names,Asking,$cid,$2) }
}


; Away!
RAW 305:*:{ _away.unAwayEvent }
RAW 306:*:{ _away.nowAwayEvent }


; Topic!
RAW 332:*:{
  if (!$_goptions.get(TopicOnJoin)) { halt }
}
RAW 333:*:{
  if (!$_goptions.get(TopicOnJoin)) { halt }
}


; Whois!
RAW 318:*:{
  unset $_script.variableName(Whois,Active,$cid,$2)
  if ($_script.variableValue(Raw,NoSuchNickChannel,$cid,$2)) { 
    unset $_script.variableName(Raw,NoSuchNickChannel,$cid,$2)
    if ($_goptions.get(AutoWhowasFailedWhois)) { whois $2 $2 }
    halt
  }
}

; MOTD!
RAW 372:*:{
  if ($_mirc.iniOption(1,11)) { halt }
}
RAW 375:*:{
  if ($_mirc.iniOption(1,11)) { halt }
}
RAW 376:*:{
  if ($_mirc.iniOption(1,11)) { halt }
}


; Error replies
RAW 401:*:{ set $_script.variableName(Raw,NoSuchNickChannel,$cid,$2) 1 }
RAW 406:*:{ set $_script.variableName(Raw,WasNoSuchNick,$cid,$2) 1 }


; Whowas!
RAW 369:*:{
  if ($_script.variableValue(Raw,WasNoSuchNick,$cid,$2)) {
    unset $_script.variableName(Raw,WasNoSuchNick,$cid,$2)
    halt
  }
}


; Who!
RAW 352:*:{
  if ($_ial.isUpdating($2)) {
    if (* isin $7) { .ialmark $6 IRCop }
    halt 
  }
}
RAW 315:*:{
  _nicklist.channel $2
  if ($_ial.isUpdating($2)) { 
    unset $_script.variableName(IAL,Updating,$cid,$2)
    halt
  }
}

; Ban List!
RAW 367:*:{ halt }
RAW 368:*:{ halt }








alias _events.onQuery {
  var %n = $1, %t
  if (!$_goptions.get(CommomChannelsOnQuery)) || (!$query(%n)) { return }
  if (!$comchan(%n,0)) { %t = <none> }
  else { %t = $_channel.common(%n) }
  __echoicon %n Common channels: %t
  echo %n -
}


;_____________[ menu ] ________________________________________

menu Menubar {
  $iif($_advanced.showPopup(Menubar,Options),&Options)
  .&General... $_advanced.commandOnMenu(general):{ general }
  .&Advanced... $_advanced.commandOnMenu(advanced):{ aoptions }
  .-
  .&Themes
  ..&Load theme... $_advanced.commandOnMenu(themes):{ themes }
  ..-
  ..$iif(!$_themes.currentLoaded,$style(2)) &Current theme... $_advanced.commandOnMenu(themedit):{ themedit }
  ..$iif(!$_themes.currentLoaded,$style(2)) Current &schemes
  ...$submenu($_themes.schemesPopup($1))
  .-
  .&Images... $_advanced.commandOnMenu(images)...:{ images }
  .&Nicklist Colors... $_advanced.commandOnMenu(nlist):{ nlist }
  .Event &Sounds... $_advanced.commandOnMenu(sounds):{ sounds }
  .&Echos... $_advanced.commandOnMenu(echos):{ echos }
  .-
  .&Protections
  ..&Personal... $_advanced.commandOnMenu(pprots):{ pprots }
  ..&Channels... $_advanced.commandOnMenu(cprots):{ cprots }
  ..-
  ..&Options... $_advanced.commandOnMenu(proto):{ proto }
  .-
  .&CTCP Replies... $_advanced.commandOnMenu(ctcprep):{ ctcprep }
  .&Filters... $_advanced.commandOnMenu(filters):{ filters }
  .F&unction Keys... $_advanced.commandOnMenu(fkeys):{ fkeys }
  .&N&ick Completion... $_advanced.commandOnMenu(ncomp):{ nickcomp }
  .-
  .&Wizard... $_advanced.commandOnMenu(wizard):{ wizard }
  -
  $iif($_advanced.showPopup(Menubar,Control Panel),&Control Panel... $_advanced.commandOnMenu(cpanel)):{ cpanel }
  -
  $iif($_advanced.showPopup(Menubar,Profiles),&Profiles... $_advanced.commandOnMenu(profiles)):{ profiles }
  $iif($_advanced.showPopup(Menubar,Userlist),&Userlist)
  .&List... $_advanced.commandOnMenu(userlist):{ userlist }
  .-
  .&Options... $_advanced.commandOnMenu(userlist -o):{ userlisto }
  -
  $iif($_advanced.showPopup(Menubar,Away),&Away)
  .$iif(!$server || $away,$style(2)) &Set Away... $_advanced.commandOnMenu(away):{ away }
  .$iif(!$away,$style(2)) S&et Back $_advanced.CommandOnMenu(back):{ back }
  .-
  .$iif(!$server || $away,$style(2)) Se&t Quiet Away... $_advanced.commandOnMenu(.away):{ .away }
  .$iif(!$away,$style(2)) Set &Quiet Back $_advanced.CommandOnMenu(.back):{ .back }
  .-
  .&Pagers... $_advanced.commandOnMenu(pagers):{ pagers }
  .$style(2) &Away Log... $_advanced.commandOnMenu(awaylog):{ awaylog }
  .-
  .&Options... $_advanced.commandOnMenu(goptions):{ goptions -i away }
  -
  $iif($_advanced.showPopup(Menubar,Files & Folders),&Files && Folders)
  .&Files
  ..&Specify...:{ run $_file.fixName($$_prompt.selectFile($mircdir,Files - Select file to run:,FilesFoldersOpenFile)) }
  ..-
  ..&Add File...:{ _ff.addRecentFile }
  ..-
  ..$iif($_ff.recentFilesMenu(1) == $null,$style(2) (Empty List)):{ return }
  ..$submenu($_ff.recentFilesMenu($1))
  ..-
  ..$iif($_ff.recentFilesMenu(1) == $null,$style(2)) &Clear Nth File...:{ _ff.recentFilesMenu N }
  ..$iif($_ff.recentFilesMenu(1) == $null,$style(2)) Cl&ear All:{ _ff.recentFilesMenu }
  .-
  .F&olders
  ..&Specify...:{ explore }
  ..-
  ..&Add Folder...:{ _ff.addRecentFolder }
  ..-
  ..$iif($_ff.recentFoldersMenu(1) == $null,$style(2) (Empty List)):{ return }
  ..$submenu($_ff.recentFoldersMenu($1))
  ..-
  ..$iif($_ff.recentFoldersMenu(1) == $null,$style(2)) &Clear Nth Folder...:{ _ff.recentFoldersMenu N }
  ..$iif($_ff.recentFoldersMenu(1) == $null,$style(2)) Cl&ear All:{ _ff.recentFoldersMenu }
  .-
  .$submenu($_ff.miscFoldersMenu($1))
  .-
  .$submenu($_ff.drivesFoldersMenu($1))

  $iif($_advanced.showPopup(Menubar,Utilities),&Utilities)
  .&Alarm
  ..$time:{ return }
  ..-
  ..&Timed
  ...$iif($_alarm.isSetedTo != Off,$style(1) Turn off $chr(9) $+($chr(91),$v1,$chr(93))) :{ alarm -t off }
  ...-
  ...&Set Time... $_advanced.commandOnMenu(alarm -t):{ alarm -t }
  ..&Continuous
  ...$iif($_alarm.isSetedTo(continuous) != Off,$style(1) Turn Off $chr(9) [Every $v1 Minutes]) :{ alarm -c off } 
  ...-
  ...&Every 10 Minutes:{ alarm -c 10 }
  ...E&very 15 Minutes:{ alarm -c 15 }
  ...Eve&ry 30 Minutes:{ alarm -c 30 }
  ...Ever&y Hour:{ alarm -c 00 }
  ...-
  ...Every &N Minutes... $_advanced.commandOnMenu(alarm -c):{ alarm -c }
  ..-
  ..&Options... $_advanced.commandOnMenu(alarm -o):{ alarm -o }
  .-
  .&Sound Player
  ..&Open... $_advanced.commandOnMenu(player):{ player }
  ..-
  ..O&ptions... $_advanced.commandOnMenu(player -o):{ player -o }
  .&ID3 Viewer
  ..&Select File... $_advanced.commandOnMenu(id3):{ id3 }
  ..-
  ..$submenu($_id3.recentFilesMenu($1))
  ..$iif($_id3.recentFilesMenu(1) == $null,$style(2) (Empty List)):{ return }
  ..-
  ..$iif($_id3.recentFilesMenu(1) == $null,$style(2)) Cle&ar Nth File...:{ _id3.recentFilesMenu }
  ..$iif($_id3.recentFilesMenu(1) == $null,$style(2)) Cl&ear All:{ 
    if ($_prompt.yesNo(Are you sure?"Files)) { _id3.recentFilesMenu }
  }
  .&Mixer... $_advanced.commandOnMenu(mixer):{ mixer }
  .-
  .&Seen
  ..&Database... $_advanced.commandOnMenu(seen -d):{ seen -d }
  ..-
  ..&Options... $_advanced.commandOnMenu(seen -o):{ seen -o }
  .&Lagbar
  ..$iif($_script.getOption(Lagbar,Enable),$style(1)) &Show  $_advanced.commandOnMenu(lagbar $iif($_script.getOption(Lagbar,Enable),off,on)):{ 
    var %s = $iif($_script.getOption(Lagbar,Enable),off,on)
    lagbar %s
  }
  ..-
  ..&Background Color...	( $+ $_lagbar.colors(background) $+ ):{ _script.setOption Lagbar BackgroundColor $_rgb.selectColor($_lagbar.colors(background)) }
  ..B&ar Color...	( $+ $_lagbar.colors(bar) $+ ):{ _script.setOption Lagbar BarColor $_rgb.selectColor($_lagbar.colors(bar)) }
  ..&Text Color...	( $+ $_lagbar.colors(text) $+ ):{ _script.setOption Lagbar TextColor $_rgb.selectColor($_lagbar.colors(text)) }
  ..-
  ..$iif(!$window(@lagbar),$style(2)) &Default Position:{ _lagbar.setDefaultPosition }
  .&Perform... $_advanced.commandOnMenu(perform):{ perform }
  .-
  .&Notepad
  ..&New... $_advanced.commandOnMenu(notepad):{ notepad }
  ..-
  ..&Open
  ...&Select... $_advanced.commandOnMenu(notepad -o):{ notepad -o }
  ...-
  ...$submenu($_notepad.recentFilesMenuBar($1))
  ...$iif($_notepad.recentFilesMenuBar(1) == $null,$style(2) (Empty List)):{ return }  
  ...-
  ...$iif($_notepad.recentFilesMenuBar(1) == $null,$style(2)) &Clear Nth File...:{ _notepad.recentFilesMenuBar N }
  ...$iif($_notepad.recentFilesMenuBar(1) == $null,$style(2)) Cl&ear All:{ _notepad.recentFilesMenuBar }
  .&ASCII Viewer... $_advanced.commandOnMenu(ascii):{ ascii }
  .L&ogs Viewer... $_advanced.commandOnMenu(logs):{ logs }
  .N&otes... $_advanced.commandOnMenu(notes):{ notes }
  .Stat&istics... $_advanced.commandOnMenu(statistics):{ statistics }
  .-
  .&Country... $_advanced.commandOnMenu(country):{ country }
  .&Euro Converter... $_advanced.commandOnMenu(euro):{ euro }
  $iif($_advanced.showPopup(Menubar,Sockets),&Sockets)
  .&Statistics... $_advanced.commandOnMenu(statistics):{ sstats }
  .-
  .&Portscan... $_advanced.commandOnMenu(portscan):{ portscan }
  -
  $iif($_advanced.showPopup(Menubar,Script),S&cript)
  .&Check Integrity... $_advanced.commandOnMenu(integrity):{ integrity }
  .-
  .&Settings
  ..&View / Edit... $_advanced.commandOnMenu(settings -e):{ settings -e }
  ..-
  ..&Backup
  ...&Open... $_advanced.commandOnMenu(settings -f):{ settings -f }
  ...-
  ...&Compile $_advanced.commandOnMenu(settings -c):{ settings -c }
  ...&Import $_advanced.commandOnMenu(settings -i):{ settings -i }
  ...-
  ...&Delete... $_advanced.commandOnMenu(settings -t):{ settings -t }
  ..-
  ..&Load $_advanced.commandOnMenu(settings -l):{ settings -l }
  ..S&ave $_advanced.commandOnMenu(settings -s):{ settings -s }
  ..-
  ..&Reset... $_advanced.commandOnMenu(settings -r):{ settings -r }
  ..R&eset to Default... $_advanced.commandOnMenu(settings -d):{ settings -d }
  ..-
  ..&Options... $_advanced.commandOnMenu(settings -o):{ settings -o }
  .-
  .$iif(!$whatsnew,$style(2)) &Whatsnew... $_advanced.commandOnMenu(whatsnew):{ whatsnew }
  .$iif(!$readme,$style(2)) Read&me... $_advanced.commandOnMenu(readme):{ readme }
  .-
  .&Homepage... $_advanced.commandOnMenu(home):{ run $_script.home }
  .&Email... $_advanced.commandOnMenu(mailfb):{ run mailto: $_script.email }
  .-
  .$style(2) &News... $_advanced.commandOnMenu(news):{ news }
  .$style(2) &Update... $_advanced.commandOnMenu(update):{ update }
  .-
  .&Tips... $_advanced.commandOnMenu(tips):{ tips }
  .-
  .&Presentation... $_advanced.commandOnMenu(presentation):{ presentation }
  .&About... $_advanced.commandOnMenu(about):{ about }
  -
  $iif($_advanced.showPopup(Menubar,Help),$iif($r(0,100) == 69,&Help me not!,&Help...) $_advanced.commandOnMenu(helpd)):{ helpd }
}


menu @Settings,@MOTD-*,@Names-*,@SNotices-* {
  ;       Default windows menu (clipboard/close button)
  -
  $iif($sline($active,1) == $null || $sline($active,0) != 1,$style(2)) &Clipboard:{ clipboard $replace($strip($1-),$chr(9),-) }
  -
  Clo&se:{ window -c $active }
}

menu status {
  $iif($_advanced.showPopup(Status,Connection),&Connection)
  .&New Window
  ..&Specify... $_advanced.commandOnMenu(srv):{ srv -n }
  ..-
  ..$submenu($_connection.menusHandler($1).new)

  .&Current Window
  ..&Specify... $_advanced.commandOnMenu(srv -c):{ srv -c }
  ..-
  ..$submenu($_connection.menusHandler($1).current)
  .-
  .$iif(!$_connection.recent(0),$style(2) (Empty List)): { return }
  .$submenu($_connection.menusHandler($1).remove)
  .$iif($_connection.recent(0),$style(2) (Click to Remove)):{ return }
  .-
  .&Add to List...:{ _connection.addToList }
  .$iif($_connection.recent(0) == 0,$style(2)) C&lear all list...:{ _connection.clearList }
  .-
  .List limited to $_connection.listLimit servers...:{ _connection.setListLimit }
  -
  $iif($_advanced.showPopup(Status,Channels),$iif(!$server,$style(2)) C&hannels)
  .&Specify... $_advanced.commandOnMenu(join):{ join }
  .-
  .$submenu($_recent.menuHandler(c,$1))
  .$iif(!$_recent.item(c,0),$style(2) (Empty List)):{ return }
  .-
  .$iif($_recent.item(c,1) == $null,$style(2)) &Clear Nth Channel...:{ _recent.removeItem -c }
  .$iif($_recent.item(c,1) == $null,$style(2)) Clear &All...:{ _recent.removeItem -ac }
  .-
  .List limited to $_recent.listLimit(c) channels...:{ _recent.setListLimit -c }

  $iif($_advanced.showPopup(Status,Nicknames),&Nicknames)
  .&Specify... $_advanced.commandOnMenu(nick):{ nick }
  .-
  .$submenu($_recent.menuHandler(n,$1))
  .$iif(!$_recent.item(n,0),$style(2) (Empty List)):{ return }
  .-
  .$iif($_recent.item(n,1) == $null,$style(2)) &Clear Nth Nickname...:{ _recent.removeItem -n }
  .$iif($_recent.item(n,1) == $null,$style(2)) Clear &All...:{ _recent.removeItem -an }
  .-
  .List limited to $_recent.listLimit(n) nicknames...:{ _recent.setListLimit -n }
  -
  $iif($_advanced.showPopup(Status,Part),$iif(!$chan(0) || !$server,$style(2)) &Part)
  .$submenu($_channel.partChannelMenu($1))
  -
  $iif($_advanced.showPopup(Status,List Channels),$iif(!$server,$style(2)) &List Channels)
  .&With more than 5 users:{ list -min 5 }
  .W&ith more than 10 users:{ list -min 10 }
  .Wi&th more than 50 users:{ list -min 50 }
  .Wit&h more than 100 users:{ list -min 100 }
  .-
  .With &more than N users...:{ 
    var %n = $int($_prompt.inputNumber(1,3000,200,h,List current available channels with at least N users:,List channels))
    if ($int(%n) isnum 1-) { list -min $v1 }
  }
  $iif($_advanced.showPopup(Status,Usermodes),$iif(!$server,$style(2)) &Usermodes)
  .Set &Default $_advanced.commandOnMenu(umodes -d):{ umodes -d }
  .Set &Custom... $_advanced.commandOnMenu(umodes):{ umodes }
  .-
  .&Options...:{ goptions -ni $_network.active - Usermodes }

  $iif($_advanced.showPopup(Status,Statistics),$iif(!$server,$style(2)) &Statistics)
  .&MOTD $_advanced.commandOnMenu(motd)):{ motd }
  .-
  .&G-Lines $_advanced.commandOnMenu(stats g):{ stats g }
  .&K-Lines $_advanced.commandOnMenu(stats k):{ stats k }
  .&O-Lines $_advanced.commandOnMenu(stats o):{ stats o }
  .&I-Lines $_advanced.commandOnMenu(stats i):{ stats i }
  .-
  .&Commands $_advanced.commandOnMenu(stats m):{ stats m }
  .&Uptime $_advanced.commandOnMenu(stats u):{ stats u }
  .-
  .&Users $_advanced.commandOnMenu(lusers):{ lusers }
  .&Time $_advanced.commandOnMenu(time):{ time }
  .&Version $_advanced.commandOnMenu(version):{ version }
  .-
  .Cu&stom... $_advanced.commandOnMenu(stats):{ stats }
  -
  $iif($_advanced.showPopup(Status,Quit),$iif(!$server,$style(2)) &Quit)
  .&Current Connection... $_advanced.commandOnMenu(quit):{ quit $_prompt.input(Quit message:"~"Quit"tch"QuitMessageCurrent) }
  .&All Connections... $_advanced.commandOnMenu(aquit):{ aquit $_prompt.input(Quit message to all connections:"~"Quit"tch"QuitMessageAllConnections) }
  -
  $iif($_advanced.showPopup(Status,Restart),&Restart... $_advanced.commandOnMenu(restart)):{ restart }
  $iif($_advanced.showPopup(Status,Exit),&Exit... $_advanced.commandOnMenu(exit)):{ exit }
}

menu Channel {
  $iif($_advanced.showPopup(Channels,Central),$+($active,...) $_advanced.commandOnMenu(channel)):{ channel }
  -
  $iif($_advanced.showPopup(Channels,Protections),&Protections... $_advanced.commandOnMenu(cprots)):{ cprots }
  -
  $iif($_advanced.showPopup(Channels,Modes),$iif(!$_channel.meOp($active),$style(2)) &Modes)
  .$submenu($_channel.listModesOnMenu($1))
  $iif($_advanced.showPopup(Channels,Mass),$iif(!$_channel.meOp($active),$style(2)) M&ass)
  .&Op $_advanced.commandOnMenu(massop):{ mop }
  .&Deop $_advanced.commandOnMenu(massdeop):{ mdeop }
  .-
  .&Voice $_advanced.commandOnMenu(massvo):{ mvoice }
  .D&evoice $_advanced.commandOnMenu(massdevo):{ mdevoice }
  .-
  .&Kick
  ..&All $_advanced.commandOnMenu(mka):{ mka }
  ..-
  ..&Ops $_advanced.commandOnMenu(mko):{ mko }
  ..&Halfops $_advanced.commandOnMenu(mkh):{ mkh }
  ..&Voices $_advanced.commandOnMenu(mkv):{ mkv }
  ..-
  ..&Regular $_advanced.commandOnMenu(mkr):{ mkr }
  .Kick && &Ban
  ..&All $_advanced.commandOnMenu(mkba):{ mka }
  ..-
  ..&Ops $_advanced.commandOnMenu(mkbo):{ mkbo }
  ..&Halfops $_advanced.commandOnMenu(mkbh):{ mkbh }
  ..&Voices $_advanced.commandOnMenu(mkbv):{ mkbv }
  ..-
  ..&Regular $_advanced.commandOnMenu(mkbr):{ mkbr }

  $iif($_advanced.showPopup(Channels,Ctcp),&CTCP)
  .&Ping:{ ctcp $active PING }
  .&Script:{ ctcp $active SCRIPT }
  .&Time:{ ctcp $active TIME }
  .&Userinfo:{ ctcp $active USERINFO }
  .&Version:{ ctcp $active VERSION }
  .-
  .&Other...:{ ctcp $active $_prompt.input(CTCP to send to channel:"PING"CTCP - $active "tch"OtherCtcpToChannel) }
  -
  $iif($_advanced.showPopup(Channels,Hop),&Hop):{ hop }
  $iif($_advanced.showPopup(Channels,Part),$iif(!$chan(0) && $server != $null,$style(2)) &Part)
  .$submenu($_channel.partChannelMenu($1))
  -
  $iif($_advanced.showPopup(Channels,Quit),$iif(!$server,$style(2)) &Quit)
  .&Current Connection... $_advanced.commandOnMenu(quit):{ quit $_prompt.input(Quit message:"~"Quit"tch"QuitMessageCurrent) }
  .&All Connections... $_advanced.commandOnMenu(aquit):{ aquit $_prompt.input(Quit message to all connections:"~"Quit"tch"QuitMessageAllConnections) }
}


menu nicklist {
  $iif($_advanced.showPopup(Nicklist,Whois),    $iif($1 == $null,$style(2)) &Whois $_advanced.commandOnMenu(whois)   ):{ whois $1 }
  $iif($_advanced.showPopup(Nicklist,Whois+),   $iif($1 == $null,$style(2)) W&hois++ $_advanced.commandOnMenu(whois+)  ):{ whois $1 $1 }
  $iif($_advanced.showPopup(Nicklist,UWhoi),    $iif($1 == $null,$style(2)) &UWho... $_advanced.commandOnMenu(uwho)   ):{ uwho $1 }
  -
  $iif($_advanced.showPopup(Nicklist,Query),     $iif($1 == $null,$style(2)) &Query... $_advanced.commandOnMenu(query)):{ query $1 }
  -
  $iif($_advanced.showPopup(Nicklist,Notified),    $iif($1 == $null,$style(2),$iif($1 isnotify,$style(1))) &Notified $_advanced.commandOnMenu(notify)  ):{ notify $iif($1 isnotify,-r) $1 }
  $iif($_advanced.showPopup(Nicklist,Friendly),    $iif($1 == $null,$style(2),$iif($_userlist.isLevel($1,50),$style(1))) &Friendly $_advanced.commandOnMenu(addfriend)):{ $iif($_userlist.isLevel($1,50),ruser $ulist($1),_userlist.addUser $1 50) }
  $iif($_advanced.showPopup(Nicklist,Shitlisted),    $iif($1 == $null,$style(2),$iif($_userlist.isLevel($1,10),$style(1))) &Shitlisted $_advanced.commandOnMenu(addshit)):{ $iif($_userlist.isLevel($1,10),ruser $ulist($1),_userlist.addUser $1 10) }
  -
  $iif($_advanced.showPopup(Nicklist,CTCP),  $iif($1 == $null,$style(2)) &CTCP)
  .&Ping:{ ctcp $1 PING }
  .&Script:{ ctcp $1 SCRIPT }
  .&Time:{ ctcp $1 TIME }
  .&Userinfo:{ ctcp $1 USERINFO }
  .&Version:{ ctcp $1 VERSION }
  .-
  .&Other...:{ ctcp $1 $_prompt.input(CTCP to send to channel:"PING"CTCP - $1 "tch"OtherCtcpToNick) }
  $iif($_advanced.showPopup(Nicklist,DCC),     $iif($1 == $null,$style(2)) &DCC)
  .&Chat Session... $_advanced.commandOnMenu(chat):{ chat $1 }
  .-
  .&Send File... $_advanced.commandOnMenu(send):{ send $1 }
  -
  $iif($_advanced.showPopup(Nicklist,Control),    $iif(!$_channel.meOp($active) || $1 == $null,$style(2)) C&ontrol)
  .&Op $_advanced.commandOnMenu(op):{ op $snicks }
  .&Deop $_advanced.commandOnMenu(deop):{ deop $snicks }
  .-
  .&Voice $_advanced.commandOnMenu(voice):{ voice $snicks }
  .D&evoice $_advanced.commandOnMenu(devoice):{ devoice $snicks }
  -
  $iif($_advanced.showPopup(Nicklist,Colors),   Co&lors... $_advanced.commandOnMenu(nicklist)):{ nicklist }
}
