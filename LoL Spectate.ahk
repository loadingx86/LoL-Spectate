#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

#Include JSON_to_obj.ahk

Loop RADS\solutions\lol_game_client_sln\releases\*, 2 
	path = RADS\solutions\lol_game_client_sln\releases\%A_LoopFileName%\deploy\
/*
IfNotExist, %path%\League of Legends.exe 
{
	MsgBox, 16, ERROR!, Game not found, place the app in the "Riot Games\League of Legends" folder!
	ExitApp
}
*/
Gui, font,, Verdana 
Gui,Add,Edit, x95 y15 w120 h21 Limit Center
Gui,Add,DropDownList, vindex x20 y15 w60, EUNE||EUW|NA|BR|TR|KR|JP|LAN|LAS|OCE|RU
Gui,Add,Button, x220 y14 w69 h23 glrun Default,Spectate
;Gui,Add,Button,x315 y5 w10 h38 gvadd,|
Gui,Show,w309 h50 , LoL - Spectate Anyone
regions := ["EUN1","EUW1","NA1","BR1","TR1","KR","JP1","LA1","LA2","OC1","RU"]

return

GuiClose:
ExitApp
Return

lrun:
Gui, Submit, Nohide

region := index
GuiControl, +AltSubmit, index
Gui, Submit, NoHide
pos := index
GuiControl, -AltSubmit, index

GuiControlGet, Edit1
if (Edit1 <> "")
{
	link1 := "https://" regions[pos] ".api.riotgames.com/lol/summoner/v3/summoners/by-name/" Edit1 "?api_key=apikey"
	;MsgBox % link1
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", link1, true)
	whr.Send()
	whr.WaitForResponse()
	
	if (whr.Status = 404){
		MsgBox, Summoner %Edit1% doesn't exist!
		Return
	}
	if (whr.Status != 200){
		MsgBox, 16, Error, Can't find Summoner info!
		Return
	}
	
	json := whr.ResponseText
	jsonobj := json_toobj(json)
	
	StringReplace , Edit1, Edit1, %A_Space%,,All
	
	sumid := jsonobj["id"]
	sumname := jsonobj["name"]
	
	link2 := "https://" regions[pos] ".api.riotgames.com/lol/spectator/v3/active-games/by-summoner/" sumid "?api_key=apikey"	
	;MsgBox % link2
	whr2 := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr2.Open("GET", link2, true)
	whr2.Send()
	whr2.WaitForResponse()
	
	if (whr2.Status = 404){
		MsgBox, %sumname% is not in an active match!
		Return
	}
	if (whr2.Status != 200){
		MsgBox, 16, Error, Can't find match info!
		Return
	}
	
	json2 := whr2.ResponseText
	jsonobj2 := json_toobj(json2)
	
	matchid := jsonobj2["gameId"]
	encrkey := jsonobj2["observers"]["encryptionKey"]
	;MsgBox % matchid
	;MsgBox % encrkey
	
	
	if (region = "EUNE")
		port = 8088
	else
		port = 80
	
	link4 := regions[pos]
	StringLower, link4, link4
	
	link1 = "League of Legends.exe" "8394" "LoLLauncher.exe" "" "replay spectator.%link4%.lol.riotgames.com:%port%
	link5 := regions[pos]
	
	streamurl = %link1% %encrkey% %matchid% %link5%"
	MsgBox % streamurl
	SetWorkingDir, %path%
	Run , %streamurl%
}
;ExitApp
return
