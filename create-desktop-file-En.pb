
Global UserIntLang$
If ExamineEnvironmentVariables()
    While NextEnvironmentVariable()
    	If Left(EnvironmentVariableName(), 4) = "LANG"
; 		    LANG=ru_RU.UTF-8
; 		   	LANGUAGE=ru
			UserIntLang$ = Left(EnvironmentVariableValue(), 2)
			Break
		EndIf
    Wend
EndIf

#CountStrLang = 20
Global Dim Lng.s(#CountStrLang)

Lng(1) = "Create desktop file"
Lng(2) = "Shortcut name"
Lng(3) = "Executable file"
Lng(4) = "Icon"
Lng(5) = "Category"
Lng(6) = "Comment"
Lng(7) = ~"Drag the shortcut\n(desktop file) here"
Lng(8) = "Add keys: "
Lng(9) = " Not add a shortcut to the program menu DE "
Lng(10) = "Run in the terminal"
Lng(11) = "Create in the folder: "
Lng(12) = "~/Desktop"
Lng(13) = "Create"
Lng(14) = "Creates a shortcut"
Lng(15) = "Open file "
Lng(16) = "Desktop-file"
Lng(17) = "Executable"
Lng(18) = "Icons"
Lng(19) = "Warning"
Lng(20) = "Do you want to overwrite an existing file?"

If UserIntLang$ = "ru"
	Lng(1) = "Создать desktop файл"
	Lng(2) = "Имя ярлыка"
	Lng(3) = "Исполняемый файл"
	Lng(4) = "Иконка"
	Lng(5) = "Категория"
	Lng(6) = "Комментарий"
	Lng(7) = ~"Перетащи сюда\nярлык (desktop-файл)"
	Lng(8) = "Добавить ключи:"
	Lng(9) = "Не добавлять ярлык в меню программ DE"
	Lng(10) = "Запускать в терминале"
	Lng(11) = "Создать в папке:"
	Lng(12) = "~/Рабочий стол"
	Lng(13) = "Создать"
	Lng(14) = "Создаёт ярлык"
	Lng(15) = "Открыть файл"
	Lng(16) = "Desktop-файл"
	Lng(17) = "Исполняемый"
	Lng(18) = "Значки"
	Lng(19) = "Предупреждение"
	Lng(20) = "Вы хотите перезаписать существующий файл?"
EndIf




EnableExplicit
UseGIFImageDecoder()
XIncludeFile "func.pbi"

;- ● Declare
Declare fill(t$, t2)
Declare SaveINI(Key$, t2)
Declare ReadFileR(Path$, PostProcessing = 1)
Declare AddDesktop(tmp$)
Declare AddIcon(tmp$)
Declare AddExec(tmp$)
Declare CreateINI(tmp$)
Declare SizeWindowHandler()

#Window = 0

;- ● Enumeration
Enumeration
	#StrG1
	#StrG2
	#StrG3
	#StrG4
	#StrG5
	#TxtG8
	
	#TxtG1
	#TxtG2
	#TxtG3
	#TxtG4
	#TxtG5
	
	#TxtG6
	#TxtG7
	#Cmb
	
	#ChNoDisplay
	#ChTerminal
	
	#BtnOpenIcon
	#BtnOpenDesktop
	#BtnOpenExec
	#BtnCreate
	#BtnINI
	#BtnOpnFile
	#Countdown
EndEnumeration

Structure Field
	Event.i
	Key.s
	Valie.s
EndStructure

;- ● Global / Define
Global NewList Fields.Field()

Global ini$
Global iconPath$ = "/usr/share/icons/"
Global CurPath$
Global w = 350
Global h = 330
Global b, w2
Global FontHeight = 35
Global FontHeight2 = 35

Define w3, h3
Define h_step
Define tmp$, tmp2$, i, w_field
Define AppPath$ = "/usr/share/applications/"
Define ExecPath$ = "/usr/bin/"

DataSection
	CompilerIf  #PB_Compiler_OS = #PB_OS_Linux
		IconTitle:
		IncludeBinary "images" + #PS$ + "desktop-file.gif"
		IconTitleend:
	CompilerEndIf
	Icon1:
	IncludeBinary "images" + #PS$ + "1.gif"
	Icon1end:
; 	Icon2:
; 	IncludeBinary "images" + #PS$ + "2.gif"
; 	Icon2end:
; 	Icon3:
; 	IncludeBinary "images" + #PS$ + "3.gif"
; 	Icon3end:
	ini:
	IncludeBinary "sample-En+.ini"
	iniend:
; 	ini2:
; 	IncludeBinary "Desktop.ini"
; 	ini2end:
EndDataSection

CompilerIf  #PB_Compiler_OS = #PB_OS_Linux
	CatchImage(0, ?IconTitle)
CompilerEndIf
CatchImage(1, ?Icon1)
; CatchImage(2, ?Icon2)
; CatchImage(3, ?Icon3)

;- ini
Define ini_name$ = "create-desktop-file"
ini$ = GetPathPart(ProgramFilename()) + ini_name$ + ".ini"
If FileSize(ini$) < 8
	; 	Если рядом с прогой файла нет, то прога не портабельная и ищем конфиг в папках конфигов
	; 		Создаём в AppData\Roaming, если в текущей не удалось
	CompilerSelect #PB_Compiler_OS
		CompilerCase #PB_OS_Windows
			ini$ = GetUserDirectory(#PB_Directory_ProgramData) + ini_name$ + #PS$ + ini_name$ + ".ini"
		CompilerCase #PB_OS_Linux
			ini$ = GetHomeDirectory() + ".config/" + ini_name$ + #PS$ + ini_name$ + ".ini"
	CompilerEndSelect
	; 	Создаёт ini если не существует
	If FileSize(ini$) < 8 And ForceDirectories(GetPathPart(ini$))
		SaveFile_Buff(ini$, ?ini, ?iniend - ?ini)
	EndIf
EndIf
; Debug ini$
If FileSize(ini$) > 3 And OpenPreferences(ini$)
	If PreferenceGroup("Set")
		; 	ini$ = ReadPreferenceString("ini$", ini$)
		h = ReadPreferenceInteger("WinHeight", h)
		w = ReadPreferenceInteger("WinWidth", w)
		FontHeight = ReadPreferenceInteger("FontHeight", 35)
		ClosePreferences()
	EndIf
EndIf
w3 = w
h3 = h

;-┌──GUI──┐
If OpenWindow(#Window, 0, 0, w, h, Lng(1), #PB_Window_SystemMenu | #PB_Window_SizeGadget | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
	CompilerIf  #PB_Compiler_OS = #PB_OS_Linux
		gtk_window_set_icon_(WindowID(#Window), ImageID(0)) ; назначаем иконку в заголовке
	CompilerEndIf
	
	h_step = 4
	b = w / 4
	w2 = w - 5
	w_field = w - b
	TextGadget(#TxtG1, 4, h_step, b - 5, FontHeight, Lng(2), #PB_Text_Border )
	StringGadget(#StrG1, b, h_step, w2 - FontHeight - b, FontHeight, "")
	ButtonImageGadget(#BtnOpenDesktop, w2 -  FontHeight, h_step, FontHeight, FontHeight, ImageID(1))
	
	h_step + FontHeight
	TextGadget(#TxtG2, 4, h_step, b - 5, FontHeight, Lng(3), #PB_Text_Border)
	StringGadget(#StrG2, b, h_step, w2 - FontHeight - b, FontHeight, "")
	ButtonImageGadget(#BtnOpenExec, w2 -  FontHeight, h_step, FontHeight, FontHeight, ImageID(1))
	
	h_step + FontHeight
	TextGadget(#TxtG3, 4, h_step, b - 5, FontHeight, Lng(4), #PB_Text_Border)
	StringGadget(#StrG3, b, h_step, w2 - FontHeight - b, FontHeight, "")
	ButtonImageGadget(#BtnOpenIcon, w2 -  FontHeight, h_step, FontHeight, FontHeight, ImageID(1))
	
	h_step + FontHeight
	TextGadget(#TxtG4, 4, h_step, b - 5, FontHeight, Lng(5), #PB_Text_Border)
; 	StringGadget(#StrG4, b, h_step, w_field, FontHeight, "")
	
	ComboBoxGadget(#StrG4, b, h_step, w2 - b, FontHeight, #PB_ComboBox_Editable)
	ResizeGadget(#StrG4, #PB_Ignore, #PB_Ignore, w2 - b, #PB_Ignore)
	AddGadgetItem(#StrG4, -1, "")
	If OpenPreferences(ini$)
		If PreferenceGroup("Categories")
		   ExaminePreferenceKeys()
	    	While  NextPreferenceKey()
	    		AddGadgetItem(#StrG4, -1, PreferenceKeyName())
	        Wend
		EndIf
		ClosePreferences()
		If CountGadgetItems(#StrG4) < 2
			AddGadgetItem(#StrG4, -1, "Development")
			AddGadgetItem(#StrG4, -1, "Education")
			AddGadgetItem(#StrG4, -1, "Game")
			AddGadgetItem(#StrG4, -1, "Graphics")
			AddGadgetItem(#StrG4, -1, "Network")
			AddGadgetItem(#StrG4, -1, "AudioVideo")
			AddGadgetItem(#StrG4, -1, "Office")
			AddGadgetItem(#StrG4, -1, "System")
			AddGadgetItem(#StrG4, -1, "Other")
			AddGadgetItem(#StrG4, -1, "Utility")
			AddGadgetItem(#StrG4, -1, "Preferences")
			AddGadgetItem(#StrG4, -1, "Administration")
		EndIf
; 	Else
; 		AddGadgetItem(#StrG4, -1, "Development")
; 		AddGadgetItem(#StrG4, -1, "Education")
; 		AddGadgetItem(#StrG4, -1, "Game")
; 		AddGadgetItem(#StrG4, -1, "Graphics")
; 		AddGadgetItem(#StrG4, -1, "Network")
; 		AddGadgetItem(#StrG4, -1, "AudioVideo")
; 		AddGadgetItem(#StrG4, -1, "Office")
; 		AddGadgetItem(#StrG4, -1, "System")
; 		AddGadgetItem(#StrG4, -1, "Other")
; 		AddGadgetItem(#StrG4, -1, "Utility")
; 		AddGadgetItem(#StrG4, -1, "Preferences")
; 		AddGadgetItem(#StrG4, -1, "Administration")
	EndIf
	SetGadgetState(#StrG4, 0)

	
	h_step + FontHeight
	TextGadget(#TxtG5, 4, h_step, b - 5, FontHeight, Lng(6), #PB_Text_Border)
	StringGadget(#StrG5, b, h_step, w2 - b, FontHeight, "")
	
	i = #Countdown
	If OpenPreferences(ini$)
		If PreferenceGroup("Field")
			ExaminePreferenceKeys()
			While NextPreferenceKey()
				If AddElement(Fields())
					Fields()\Key = PreferenceKeyName()
					Fields()\Valie = PreferenceKeyValue()
					h_step + FontHeight
					i + 1
					TextGadget(i, 4, h_step, b - 5, FontHeight, Fields()\Valie, #PB_Text_Border)
					i + 1
					Fields()\Event = i
					StringGadget(i, b, h_step, w2 - b, FontHeight, "")
				EndIf
			Wend
		EndIf
		ClosePreferences()
	EndIf
	h_step + FontHeight
	TextGadget(#TxtG8, b, h_step, w2 - b, FontHeight * 3, Lng(7), #PB_Text_Border |  #PB_Text_Center)
	
	
; 	h_step + 40
	TextGadget(#TxtG6, 4, h_step, b - 5, FontHeight - 7, Lng(8))
	
	h_step + FontHeight
	CheckBoxGadget(#ChNoDisplay, 10, h_step, b - 15, FontHeight - 13, "NoDisplay = true")
	GadgetToolTip(#ChNoDisplay, Lng(9))
	h_step + FontHeight
	CheckBoxGadget(#ChTerminal, 10, h_step, b - 15, FontHeight - 13, "Terminal = true")
	GadgetToolTip(#ChTerminal, Lng(10))
	
	h_step + FontHeight
	TextGadget(#TxtG7, 4, h_step, b - 5, FontHeight, Lng(11), #PB_Text_Border)
	
	ComboBoxGadget(#Cmb, b, h_step, w2 - b, FontHeight)
	ResizeGadget(#StrG4, #PB_Ignore, #PB_Ignore, w2 - b, #PB_Ignore)
	If OpenPreferences(ini$)
		If PreferenceGroup("Path")
		   ExaminePreferenceKeys()
	    	While  NextPreferenceKey()
	    		AddGadgetItem(#Cmb, -1, PreferenceKeyName())
	        Wend
		EndIf
		ClosePreferences()
		If CountGadgetItems(#Cmb) = 0
			AddGadgetItem(#Cmb, -1, "~/.local/share/applications")
			AddGadgetItem(#Cmb, -1, "~/.config/autostart")
			AddGadgetItem(#Cmb, -1, Lng(12))
			AddGadgetItem(#Cmb, -1, "~/Desktop")
; 		AddGadgetItem(#Cmb, -1, "/usr/share/applications")
		EndIf
; 	Else
; 		AddGadgetItem(#Cmb, -1, "~/.local/share/applications")
; 		AddGadgetItem(#Cmb, -1, "~/.config/autostart")
; 		AddGadgetItem(#Cmb, -1, Lng(12))
; 		AddGadgetItem(#Cmb, -1, "~/Desktop")
; 		AddGadgetItem(#Cmb, -1, "/usr/share/applications")
	EndIf
	If CountGadgetItems(#Cmb) > 0
		SetGadgetState(#Cmb, 0)
	EndIf
	
	h_step + FontHeight
	ButtonGadget(#BtnCreate, (w - b) / 2, h_step, b, FontHeight, Lng(13))
	GadgetToolTip(#BtnCreate, Lng(14))
	ButtonGadget(#BtnINI, 4, h_step, FontHeight, FontHeight, "ini")
	ButtonGadget(#BtnOpnFile, w - b / 2, h_step, b / 2, FontHeight, ".desktop")
	GadgetToolTip(#BtnOpnFile, "Open *.desktop")
	HideGadget(#BtnOpnFile, 1)
	
	EnableGadgetDrop(#TxtG8, #PB_Drop_Files, #PB_Drag_Copy)
	EnableGadgetDrop(#StrG1, #PB_Drop_Files, #PB_Drag_Copy)
	EnableGadgetDrop(#StrG2, #PB_Drop_Files, #PB_Drag_Copy)
	EnableGadgetDrop(#StrG3, #PB_Drop_Files, #PB_Drag_Copy)
	
	; 	Начало Help
	#Menu = 0
	#mHelp = 0
	If CreatePopupMenu(#Menu)
		MenuItem(#mHelp, "Reference" + #TAB$ + "F1")
	EndIf
	AddKeyboardShortcut(#Window, #PB_Shortcut_F1, #mHelp) ; Help
; 	Конец Help
	
	BindEvent(#PB_Event_SizeWindow, @SizeWindowHandler())
	ResizeWindow(#Window, #PB_Ignore, #PB_Ignore, w , h_step + FontHeight + 5)
	WindowBounds(#Window, 450, 390 + ListSize(Fields()) * 17, #PB_Ignore, #PB_Ignore)
	
; 	Если прописаны ассоциации файлов (mime), то открываем файл переданный через параметры
	If CountProgramParameters()
		tmp$ = ProgramParameter()
		If FileSize(tmp$) > 0
			AddDesktop(tmp$)
		EndIf
	EndIf


;-┌──Loop──┐
	Repeat
		Select WaitWindowEvent()
; 			Case #PB_Event_SizeWindow
			Case #PB_Event_GadgetDrop ; событие перетаскивания
				Select EventGadget()
					Case #StrG3
						tmp$ = EventDropFiles()
						AddIcon(tmp$)
					Case #TxtG8, #StrG1 ; гаджеты, которые получили событие перетаскивания файлов/папок
						tmp$ = EventDropFiles()
						AddDesktop(tmp$)
					Case #TxtG2, #StrG2
						tmp$ = EventDropFiles()
						AddExec(tmp$)
; 					Case #Cmb
; 						Continue
; 					Case #StrG4 To 1000
; 						Debug "fuf" ; попытка запретить бросать в другие поля
; 						Continue
; 					Default
; 						Debug "fuf1"
; 						Continue
				EndSelect
;- ├ Gadget
			Case #PB_Event_Gadget
				Select EventGadget()
					Case #BtnOpenDesktop
						tmp$ = OpenFileRequester(Lng(15), AppPath$, Lng(16) + "|*.desktop", 0)
						If Asc(tmp$)
							AddDesktop(tmp$)
							AppPath$ = tmp$
						EndIf
					Case #BtnOpenExec
						tmp$ = OpenFileRequester(Lng(15), ExecPath$, Lng(17) + "|*", 0)
						If Asc(tmp$)
							SetGadgetText(#StrG2 , tmp$)
							ExecPath$ = tmp$
						EndIf
					Case #BtnOpenIcon
						tmp$ = OpenFileRequester(Lng(15), iconPath$, Lng(18) + " (png, gif, svg)|*.png;*.gif;*.svg", 0)
						If Asc(tmp$)
							SetGadgetText(#StrG3 , tmp$)
							iconPath$ = tmp$
						EndIf
					Case #BtnOpnFile
						If Asc(CurPath$) And FileSize(CurPath$) > 0
							If Not RunProgram("geany", Chr(34) + CurPath$ + Chr(34), "")
								RunProgram("gedit", Chr(34) + CurPath$ + Chr(34), "")
							EndIf
						EndIf
					Case #BtnINI
						RunProgram("xdg-open", Chr(34) + ini$ + Chr(34), "")
					Case #BtnCreate
						tmp$ = GetGadgetText(#Cmb)
						If Left(tmp$, 2) = "~/"
							tmp$ = ReplaceString(tmp$, "~/", GetHomeDirectory(),  #PB_String_CaseSensitive, 1, 1)
; 							tmp$ = toUTF8(tmp$)
						EndIf
						If Asc(CurPath$)
							tmp$ + "/" + GetFilePart(CurPath$, #PB_FileSystem_NoExtension) + ".desktop"
						Else
							tmp$ + "/" + GetGadgetText(#StrG1) + ".desktop"
						EndIf
						
						tmp$ = SaveFileRequester("Save", tmp$, "*.desktop|*.desktop", 0)
						If Asc(tmp$)
							If Right(tmp$, 8) <> ".desktop" ; случай если вы забыли ввести расширение файла, чтобы он был ассоциированный
								tmp$ + ".desktop"
							EndIf
						Else
						    Continue
						EndIf
						
; 						If FileSize(tmp$) = -1 And OpenPreferences(tmp$)
; 						MessageRequester("", tmp$)
; 						If CreatePreferences(tmp$)
						If FileSize(tmp$) = -1
; 								SaveFile_Buff(tmp$, ?ini2, (?ini2end - ?ini) - 2)
; 							If Not SaveFile_Buff(tmp$, ?ini2, (?ini2end - ?ini))
; 							If Not SaveFile_Buff(tmp$, ?ini2, (?ini2end - ?ini)/2 + 4)
; 								Continue
; 							EndIf
							If Not CreateINI(tmp$)
								Continue
							EndIf
						Else
							If #PB_MessageRequester_Yes = MessageRequester("Warning", "Do you want to overwrite an existing file?", #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning)
								ReadFileR(tmp$, 0)
							Else
								Continue
							EndIf
						EndIf
; 						Continue
						If OpenPreferences(tmp$, #PB_Preference_NoSpace | #PB_Preference_GroupSeparator)
							If PreferenceGroup("Desktop Entry")
								WritePreferenceString("Version" , "1.0")
								WritePreferenceString("Type" , "Application")
; 								MessageRequester("", tmp$)
								SaveINI("Name", #StrG1)
								SaveINI("Exec", #StrG2)
								SaveINI("Icon", #StrG3)
								SaveINI("Categories", #StrG4)
								SaveINI("Comment", #StrG5)
								ForEach Fields()
									SaveINI(Fields()\Key, Fields()\Event)
								Next
								If GetGadgetState(#ChNoDisplay) & #PB_Checkbox_Checked
									WritePreferenceString("NoDisplay", "true")
								EndIf
								If GetGadgetState(#ChTerminal) & #PB_Checkbox_Checked
									WritePreferenceString("Terminal", "true")
								EndIf
							EndIf
							ClosePreferences()
							ReadFileR(tmp$)
							CurPath$ = tmp$
						EndIf
				EndSelect
;- ├ Menu
			Case #PB_Event_Menu
				If EventMenu() = #mHelp
					tmp$ = "/usr/share/doc/create-desktop-file/Readme.txt"
					If FileSize(tmp$) > 0
						RunProgram("xdg-open", tmp$, GetPathPart(tmp$))
					EndIf
				EndIf
			Case #PB_Event_CloseWindow
				; 				Сохранение размеров окна только при его изменении относительно стартовых значений
				If w3 <> w Or h3 <> h
					If FileSize(ini$) > 3 And OpenPreferences(ini$,  #PB_Preference_GroupSeparator | #PB_Preference_NoSpace)
						If PreferenceGroup("Set")
							WritePreferenceInteger("WinHeight", h)
							WritePreferenceInteger("WinWidth", w)
							WritePreferenceInteger("FontHeight", FontHeight2)
							ClosePreferences()
						EndIf
					EndIf
				EndIf
				CloseWindow(#Window)
				Break
		EndSelect
	ForEver
EndIf
;-└──Loop──┘



Procedure SizeWindowHandler()
	Protected b, w2, i
	w = WindowWidth(#Window)
	h = WindowHeight(#Window)
	FontHeight2 = h / (10 + ListSize(Fields()))
	b = w / 4
	w2 = w - 5
	; 				Debug h
	For i = #TxtG1 To #TxtG5
		ResizeGadget(i, #PB_Ignore, FontHeight2 * (i - #TxtG1), b - 5, FontHeight2)
	Next
	For i = #StrG1 To #StrG3
		ResizeGadget(i, b, FontHeight2 * (i - #StrG1), w2 - FontHeight2 - b, FontHeight2)
	Next
	For i = #StrG4 To #StrG5
		ResizeGadget(i, b, FontHeight2 * (i - #StrG4 + 3), w2 - b, FontHeight2)
	Next
	i = 5
	ForEach Fields()
		ResizeGadget(Fields()\Event - 1, #PB_Ignore, FontHeight2 * i, b - 5, FontHeight2)
		ResizeGadget(Fields()\Event, b, FontHeight2 * i, w2 - b, FontHeight2)
		i + 1
	Next
	
	ResizeGadget(#BtnOpenDesktop, w2 -  FontHeight2, 0, FontHeight2, FontHeight2)
	ResizeGadget(#BtnOpenIcon, w2 -  FontHeight2, FontHeight2 * 2, FontHeight2, FontHeight2)
	ResizeGadget(#BtnOpenExec, w2 -  FontHeight2, FontHeight2, FontHeight2, FontHeight2)
	
	ResizeGadget(#TxtG8, b, FontHeight2 * i, w2 - b, FontHeight2 * 3)
	
	ResizeGadget(#TxtG6, #PB_Ignore, FontHeight2 * (i + 0), b - 7, FontHeight2 - 7)
	ResizeGadget(#ChNoDisplay, #PB_Ignore, FontHeight2 * (i + 1), b - 15, FontHeight2 - 13)
	ResizeGadget(#ChTerminal, #PB_Ignore, FontHeight2 * (i + 2), b - 15, FontHeight2 - 13)
	
	ResizeGadget(#TxtG7, #PB_Ignore, FontHeight2 * (i + 3), b - 5, FontHeight2)
	ResizeGadget(#Cmb, b, FontHeight2 * (i + 3), w2 - b, FontHeight2)
	
	ResizeGadget(#BtnCreate, (w - b) / 2, FontHeight2 * (i + 4), b, FontHeight2)
	ResizeGadget(#BtnOpnFile, w2  -  b / 2, FontHeight2 * (i + 4), b / 2, FontHeight2)
	ResizeGadget(#BtnINI, 4, FontHeight2 * (i + 4), FontHeight2, FontHeight2)
EndProcedure





Procedure CreateINI(tmp$)
	If CreatePreferences(tmp$, #PB_Preference_NoSpace | #PB_Preference_GroupSeparator)
		PreferenceGroup("Desktop Entry")
		WritePreferenceString("Version" , "1.0")
		WritePreferenceString("Type" , "Application")
		ClosePreferences()
		ProcedureReturn 1
	Else
		ProcedureReturn 0
	EndIf
EndProcedure


Procedure AddIcon(tmp$)
	Protected Ext$
	Ext$ = GetExtensionPart(tmp$)
	If Ext$ = "desktop"
		If FileSize(tmp$) > 3 And OpenPreferences(tmp$)
			If PreferenceGroup("Desktop Entry")
				fill("Icon", #StrG3)
			EndIf
			ClosePreferences()
		EndIf
	ElseIf FindString(",png,gif,svg,", "," + Ext$ + ",")
		SetGadgetText(#StrG3 , tmp$)
		iconPath$ = tmp$
	EndIf
EndProcedure

Procedure AddExec(tmp$)
	Protected Ext$
	Ext$ = GetExtensionPart(tmp$)
	If Ext$ = "desktop"
		If FileSize(tmp$) > 3 And OpenPreferences(tmp$)
			If PreferenceGroup("Desktop Entry")
				fill("Exec", #StrG2)
			EndIf
			ClosePreferences()
		EndIf
	Else
; 		If Left(tmp$, 7) = "file://"
; 			tmp$ = Mid(tmp$, 8)
; 		EndIf
		SetGadgetText(#StrG2 , tmp$)
; 		ExecPath$ = tmp$
	EndIf
EndProcedure

Procedure AddDesktop(tmp$)
	If GetExtensionPart(tmp$) = "desktop"
		If FileSize(tmp$) > 3 And OpenPreferences(tmp$)
			If PreferenceGroup("Desktop Entry")
				fill("Name", #StrG1)
				fill("Exec", #StrG2)
				fill("Icon", #StrG3)
				fill("Categories", #StrG4)
				fill("Comment", #StrG5)
				ForEach Fields()
					fill(Fields()\Key, Fields()\Event)
				Next
				CurPath$ = tmp$
				HideGadget(#BtnOpnFile, 0)
			EndIf
			ClosePreferences()
		EndIf
	EndIf
EndProcedure


Procedure ReadFileR(Path$, PostProcessing = 1)
	Protected length, *mem, id
	id = ReadFile(#PB_Any, Path$)
	If id
		length = Lof(id)                            ; получаем длину открытого файла
		If length
			*mem = AllocateMemory(length)        ; выделяем необходимую память
			If *mem
				If PostProcessing
					FileSeek(id, 3, #PB_Absolute) ; ставим указатель после метки BOM, чтобы записать потом без BOM
					ReadData(id, *mem, length - 3)	  ; считаем все данные в память
				Else
					ReadData(id, *mem, length)	  ; считаем все данные в память
				EndIf
				
				CloseFile(id)
; 				MessageRequester("", "|" + PeekS(*mem + 1, length -4, #PB_UTF8) + "|")
				
				If DeleteFile(Path$, #PB_FileSystem_Force)
					id = CreateFile(#PB_Any, Path$, #PB_UTF8)
					If id
						If Not PostProcessing
							WriteStringFormat(id, #PB_UTF8)
							FileSeek(id, 3, #PB_Absolute) ; ставим указатель после метки BOM, чтобы записать потом без BOM
							Length + 3
							WriteData(id , *mem, Length - 3)
						Else
							WriteData(id , *mem + 1, Length - 4)
						EndIf
						
						CloseFile(id)
						CompilerIf  #PB_Compiler_OS = #PB_OS_Linux
							SetFileAttributes(Path$, #PB_FileSystem_ReadAll | #PB_FileSystem_WriteAll | #PB_FileSystem_ExecAll | #PB_FileSystem_ReadUser | #PB_FileSystem_WriteUser | #PB_FileSystem_ExecUser | #PB_FileSystem_ReadGroup | #PB_FileSystem_WriteGroup | #PB_FileSystem_ExecGroup)
						CompilerEndIf
					EndIf
				EndIf
				FreeMemory(*mem)
			EndIf
		EndIf
	EndIf
EndProcedure

Procedure SaveINI(Key$, t2)
	Protected SBLen, *mem, t$
	t$ = GetGadgetText(t2)
	If Asc(t$)
; 		t$ = toUTF8(t$)
; 		SetClipboardText(t$)
; 		SBLen = StringByteLength(t$, #PB_UTF8) + 2
; 		*mem = AllocateMemory(SBLen)
; 		If *mem
; 			PokeS(*mem, t$, SBLen, #PB_UTF8)
; 			t$ = PeekS(*mem, SBLen,  #PB_Ascii)
; 			FreeMemory(*mem)
; 		EndIf
		WritePreferenceString(Key$ , t$)
	EndIf
EndProcedure

Procedure fill(t$, t2)
	Protected SBLen, *mem
; 	fill("Icon", #StrG3)
; 	MessageRequester(Str(t2), "|" + t$ + "|")
	t$ = ReadPreferenceString(t$, "")
	If Asc(t$)
		CompilerSelect #PB_Compiler_OS
			CompilerCase #PB_OS_Windows
; 				SBLen = StringByteLength(t$, #PB_Ascii)
; 				*mem = UTF8(t$)
; 				If *mem
; ; 					PokeS(*mem, t$, SBLen, #PB_Ascii)
; 					t$ = PeekS(*mem, SBLen,  #PB_UTF8)
; 					FreeMemory(*mem)
; 				EndIf
			CompilerCase #PB_OS_Linux
				SBLen = StringByteLength(t$, #PB_Ascii) + 1
				*mem = AllocateMemory(SBLen)
				If *mem
					PokeS(*mem, t$, SBLen, #PB_Ascii)
					t$ = PeekS(*mem, SBLen,  #PB_UTF8)
					FreeMemory(*mem)
				EndIf
		CompilerEndSelect
		SetGadgetText(t2 , t$)
	Else
		SetGadgetText(t2 , "")
	EndIf
EndProcedure
; IDE Options = PureBasic 6.10 LTS (Linux - x64)
; CursorPosition = 116
; FirstLine = 116
; Folding = -P-
; EnableXP
; Executable = create-desktop-file
; Compiler = PureBasic 6.10 LTS - C Backend (Linux - x64)