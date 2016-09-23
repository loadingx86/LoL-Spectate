#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

#Include JSON_to_obj.ahk

Gui, font,, Verdana 
;Gui, +ToolWindow ;AlwaysOnTop
Gui,Add,Edit, x95 y15 w120 h21 Limit Center
Gui,Add,DropDownList, vindex x20 y15 w60, EUNE||EUW|NA|BR|TR|KR|JP|LAN|LAS|OCE|RU
Gui,Add,Button, x220 y14 w69 h23 glrun Default,Spectate
;Gui,Add,Button,x315 y5 w10 h38 gvadd,|
Gui,Show,w309 h50 , LoL - Spectate Anyone
regions := ["EUN1","EUW1","NA1","BR1","TR1","KR","JP1","LA1","LA2","OC1","RU"]

Loop RADS\solutions\lol_game_client_sln\releases\*, 2
	path = RADS\solutions\lol_game_client_sln\releases\%A_LoopFileName%\deploy\

IfNotExist, %path%\League of Legends.exe 
{
	MsgBox, 16, ERROR!, Game not found, place the app in the "Riot Games\League of Legends" folder!
	ExitApp
}
	
lrestart:
return

GuiClose:
ExitApp
return

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
	link := "https://" region ".api.pvp.net/api/lol/" region "/v1.4/summoner/by-name/" Edit1 "?api_key=<yourapikey>"
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", link, true)
	whr.Send()
	whr.WaitForResponse()
	
	if (whr.Status = 404){
		MsgBox, Summoner %Edit1% doesn't exist!
		Goto,lrestart
	}
	if (whr.Status != 200){
		MsgBox, 16, Error, Can't find Summoner info!
		Goto,lrestart
	}
	
	json := whr.ResponseText
	jsonobj := json_toobj(json)
	
	StringReplace , Edit1, Edit1, %A_Space%,,All
	sumid := jsonobj[Edit1]["id"]
	sumname := jsonobj[Edit1]["name"]
	
	link := "https://" region ".api.pvp.net/observer-mode/rest/consumer/getSpectatorGameInfo/" regions[pos] "/" sumid "?api_key=<yourapikey>"
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", link, true)
	whr.Send()
	whr.WaitForResponse()
	
	if (whr.Status = 404){
		MsgBox, %sumname% is not in an active match!
		Goto,lrestart
	}
	if (whr.Status != 200){
		MsgBox, 16, Error, Can't find match info!
		Goto,lrestart
	}
	
	json := whr.ResponseText
	jsonobj := json_toobj(json)
	
	matchid := jsonobj["gameId"]
	encrkey := jsonobj["observers"]["encryptionKey"]
	
	if (region = "EUNE")
		port = 8088
	else
		port = 80
	
	link1 = "League of Legends.exe" "8394" "LoLLauncher.exe" "" "spectator spectator.%region%.lol.riotgames.com:%port%
	link4 := regions[pos]
	streamurl = %link1% %encrkey% %matchid% %link4%"
	SetWorkingDir, %path%
	Run , %streamurl%
}
ExitApp
return
