;=========================================================;
; Pm StartUp Settings                          01/04/2011 ;
;---------------------------------------------------------;
;                                                         ;
; (c) Craig Bamford, All rights reserved.                 ;
;=========================================================;

;=========================================================;
;  GetBootDrive                                           ;
;=========================================================; 
GetBootDrive:						  ;
	pushad						  ;
	cmp	[BootNumber],80h			  ;
	je	Hddloaded1				  ;
	cmp	[BootNumber],2				  ;
	je	Hddloaded				  ;
	cmp	[BootNumber],0				  ;
	jne	GetBootDriveError			  ;
	mov	byte[DefaultDriveNumber],0
	mov	byte[BootDrive],'A'			  ;
	mov	byte[FileSysTypeNew],12 		  ;
	jmp	@f					  ;
Hddloaded:						  ;
	mov	[BootNumber],80h			  ;
Hddloaded1:						  ;
	mov	byte[BootDrive],'C'			  ;
	mov	byte[FileSysTypeNew],16 		  ;
	mov	byte[DefaultDriveNumber],2		  ;
;=========================================================;
;  Exit OK                                                ;
;=========================================================; 
@@:							  ;
	popad						  ;
	clc						  ;
	ret						  ;
;=========================================================;
;  Exit Error                                             ;
;=========================================================; 
GetBootDriveError:					  ;
	mov	byte[FileSysTypeNew],0			  ;
	popad						  ;
	stc						  ;
	ret						  ;

;=========================================================;
;  Path Command                                           ;
;=========================================================; 
SetPath:						  ;
	pushad						  ;
	mov	  al,byte[BootDrive]			  ;
	mov	  edi,PathAddress			  ;
	stosb						  ;
	mov	  al,':'				  ;
	stosb						  ;
	mov	  al,'\'				  ;
	stosb						  ;
	mov	  al, 0 				  ;
	stosb						  ;
	popad						  ;
	ret						  ;

;=========================================================;
;  LoadFatRoot                                            ;
;=========================================================; 
LoadFatRoot:						  ;
	pushad						  ;
	mov	al,[BootNumber] 			  ;
	mov	byte[Drive],al				  ;
	call	LoadMBR 				  ;
	jc	LoadFatRootError			  ;
	call	DirFillRootUSB				  ;
	jc	LoadFatRootError			  ;
	popad						  ;
	clc						  ;
	ret						  ;
;=========================================================;
;  Error                                                  ;
;=========================================================; 
LoadFatRootError:					  ;
	popad						  ;
	stc						  ;
	ret						  ;

;=========================================================;
; Set Memory Vars                                         ;
;=========================================================;
SetMemoryVars:						  ;
	pushad						  ;
	mov   [ModListNumbers],1			  ;
	mov   [DescriptorsNumbers],6			  ;
	mov   eax,dword[TotalMemoryMB]			  ;
	mov   dword[TopOfFreeMemoryInMB],eax		  ;
	shl   eax,10					  ;
	shl   eax,10					  ;
	mov   dword[TopOfFreeMemoryWithBase],eax	  ;
	sub   eax,[BaseAddOn]				  ;
	mov   dword[TopOfFreeMemoryWithOutBase],eax	  ;
	mov   dword[TopOfFreeLowMemoryWithBase],0x200000  ;
	mov   dword[TopOfFreeLowMemoryWithOutBase],0x200000
	mov   eax,dword[TopOfFreeLowMemoryWithBase]	  ;
	sub   eax,[BaseAddOn]				  ;
	mov   dword[TopOfFreeLowMemoryWithOutBase],eax	  ;
	popad						  ;
	ret						  ;

;=========================================================;
;  data                                                   ;
;=========================================================; 
   PathAddress:   db 132 dup(' ')			  ;
		   db 0 				  ;