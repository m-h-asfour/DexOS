;=======================================================  ;
; Info                                       01/04/2011   ;
;-------------------------------------------------------  ;
;                                                         ;
; (c) Craig Bamford, All rights reserved.                 ;
;=======================================================  ;
bpp				    dd 0                  ;
FddRead 			    dd 0                  ;
FddWrite			    dd 0                  ;
ImageLoadAddrVar		    dd 0                  ;
GuiLoadAddrVar                      dd 0                  ;
CliLoadAddrVar                      dd 0                  ;
TopOfFreeMemoryInMB		    dd 0                  ;
TopOfFreeMemoryWithBase 	    dd 0                  ;
TopOfFreeMemoryWithOutBase	    dd 0                  ;
TopOfFreeLowMemoryWithBase	    dd 0                  ;
TopOfFreeLowMemoryWithOutBase	    dd 0                  ;
DescriptorsNumbers		    dd 0                  ;
ModListNumbers			    dd 0                  ;
MissChangTest			    db 0                  ;
CliOK                               db 0                  ;
GuiOK                               db 0                  ;
FileSysTypeNew                      db 0                  ;
FddTimer                            dw 0                  ;
FddTimerOn                          dw 0                  ;