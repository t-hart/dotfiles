; Let virtual consoles and Emacs do their own thing
#If !WinActive("ahk_class VirtualConsoleClass") && !WinActive("ahk_class Emacs")
  ^h::
  SendInput {Blind}{Ctrl up}{Backspace}{Ctrl down}
  return

  ^w::Backspace
  return

  !w::
  SendInput ^w
  return
#If

!q::
SendInput !{f4}
