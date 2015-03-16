{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 

unit dsound ;

interface

uses OLE2, Windows, MMSystem ;

(*==========================================================================;
 *
 *  Copyright (C) 1995,1996 Microsoft Corporation.  All Rights Reserved.
 *
 *  File:       dsound.h
 *  Content:    DirectSound include file
 *
 *  DirectX 2 Delphi adaptation by Blake Stone
 *
 *    EMail:     bstone@dkw.com
 *    Home Page: http://www.dkw.com/bstone
 *
 ***************************************************************************)

const
  // Direct Sound Component GUID    {47D4D946-62E8-11cf-93BC-444553540000}
  CLSID_DirectSound: TGUID = ( D1:$47d4d946;D2:$62e8;D3:$11cf;D4:($93,$bc,$44,$45,$53,$54,$0,$0)) ;
  // DirectSound 279afa83-4981-11ce-a521-0020af0be560
  IID_IDirectSound: TGUID = ( D1:$279AFA83;D2:$4981;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60)) ;
  // DirectSoundBuffer 279afa85-4981-11ce-a521-0020af0be560
  IID_IDirectSoundBuffer: TGUID = ( D1:$279AFA85;D2:$4981;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60)) ;

//==========================================================================;
//
//                            Structures...
//
//==========================================================================;

type
  IDirectSound = class ;
  IDirectSoundBuffer = class ;

// typedef struct IDirectSound           *LPDIRECTSOUND;
// typedef struct IDirectSoundBuffer     *LPDIRECTSOUNDBUFFER;
// typedef struct IDirectSoundBuffer    **LPLPDIRECTSOUNDBUFFER;

  DSCAPS = record
    dwSize: DWORD ;
    dwFlags: DWORD ;
    dwMinSecondarySampleRate: DWORD ;
    dwMaxSecondarySampleRate: DWORD ;
    dwPrimaryBuffers: DWORD ;
    dwMaxHwMixingAllBuffers: DWORD ;
    dwMaxHwMixingStaticBuffers: DWORD ;
    dwMaxHwMixingStreamingBuffers: DWORD ;
    dwFreeHwMixingAllBuffers: DWORD ;
    dwFreeHwMixingStaticBuffers: DWORD ;
    dwFreeHwMixingStreamingBuffers: DWORD ;
    dwMaxHw3DAllBuffers: DWORD ;
    dwMaxHw3DStaticBuffers: DWORD ;
    dwMaxHw3DStreamingBuffers: DWORD ;
    dwFreeHw3DAllBuffers: DWORD ;
    dwFreeHw3DStaticBuffers: DWORD ;
    dwFreeHw3DStreamingBuffers: DWORD ;
    dwTotalHwMemBytes: DWORD ;
    dwFreeHwMemBytes: DWORD ;
    dwMaxContigFreeHwMemBytes: DWORD ;
    dwUnlockTransferRateHwBuffers: DWORD ;
    dwPlayCpuOverheadSwBuffers: DWORD ;
    dwReserved1: DWORD ;
    dwReserved2: DWORD ;
  end ;
//  LPDSCAPS = ^DSCAPS ;

  DSBCAPS = record
    dwSize: DWORD ;
    dwFlags: DWORD ;
    dwBufferBytes: DWORD ;
    dwUnlockTransferRate: DWORD ;
    dwPlayCpuOverhead: DWORD ;
  end ;
//  LPDSBCAPS = ^DSBCAPS ;

  DSBUFFERDESC = record
    dwSize: DWORD ;
    dwFlags: DWORD ;
    dwBufferBytes: DWORD ;
    dwReserved: DWORD ;
    lpwfxFormat: PWaveFormatEx ;
  end ;
//  LPDSBUFFERDESC = ^DSBUFFERDESC ;

//
// IDirectSound
//

  IDirectSound = class ( IUnknown )
    (*** IDirectSound methods ***)
    function CreateSoundBuffer ( const lpDSBufferDesc: DSBUFFERDESC ;
        var lplpDirectSoundBuffer: IDirectSoundBuffer ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetCaps ( const lpDSCaps: DSCAPS ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function DuplicateSoundBuffer ( lpDsbOriginal: IDirectSoundBuffer ;
         var lplpDsbDuplicate: IDirectSoundBuffer ): HRESULT ; virtual ;
         stdcall ; abstract ;
    function SetCooperativeLevel ( hWnd: HWND ; dwFlags: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Compact: HRESULT ; virtual ; stdcall ; abstract ;
    function GetSpeakerConfig ( var lpdwSpeakerConfig: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function SetSpeakerConfig ( dwSpeakerConfig: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Initialize ( lpGuid: PGUID ): HRESULT ; virtual ;
        stdcall ; abstract ;
  end ;

//
// IDirectSoundBuffer
//

  IDirectSoundBuffer = class ( IUnknown )
    (*** IDirectSoundBuffer methods ***)
    function GetCaps ( const lpDSBufferCaps: DSBCAPS ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function GetCurrentPosition ( var dwCurrentPlayCursor: DWORD ;
        var lpdwCurrentWriteCursor: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetFormat ( const lpwfxFormat: TWaveFormatEx ;
        dwSizeAllocated: DWORD ; var lpdwSizeWritten: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetVolume ( var lplVolume: LongInt ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function GetPan ( var lplPan: LongInt ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetFrequency ( var lpdwFrequency: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function GetStatus ( var lpdwStatus: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function Initialize ( lpDirectSound: IDirectSound ;
        const lpDSBufferDesc: DSBUFFERDESC  ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function Lock ( dwWriteCursor: DWORD ; dwWriteBytes: DWORD ;
        var lplpvAudioPtr1: Pointer ; var lpdwAudioBytes1: DWORD ;
        var lplpvAudioPtr2: Pointer ; var lpdwAudioBytes2: DWORD ;
        dwFlags: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function Play ( dwReserved1, dwReserved2, dwFlags: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function SetCurrentPosition ( dwNewPosition: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function SetFormat ( const lpfxFormat: TWaveFormatEx ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function SetVolume ( lVolume: LongInt ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function SetPan ( lPan: LongInt ): HRESULT ; virtual ; stdcall ; abstract ;
    function SetFrequency ( dwFrequency: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function Stop: HRESULT ; virtual ; stdcall ; abstract ;
    function Unlock ( lpvAudioPtr1: Pointer ; dwAudioBytes1: DWORD ;
        lpvAudioPtr2: Pointer ; dwAudioBytes2: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function Restore: HRESULT ; virtual ; stdcall ; abstract ;
  end ;

(*
 * Return Codes
 *)

const
  DS_OK                           = 0 ;

(*
 * The call failed because resources (such as a priority level)
 *  were already being used by another caller.
 *)
  DSERR_ALLOCATED                 = $88780000 + 10 ;
(*
 * The control (vol,pan,etc.) requested by the caller is not available.
 *)
  DSERR_CONTROLUNAVAIL            = $88780000 + 30 ;
(*
 * An invalid parameter was passed to the returning function
 *)
  DSERR_INVALIDPARAM              = E_INVALIDARG ;
(*
 * This call is not valid for the current state of this object
 *)
  DSERR_INVALIDCALL               = $88780000 + 50 ;
(*
 * An undetermined error occured inside the DSound subsystem
 *)
  DSERR_GENERIC                   = E_FAIL ;
(*
 * The caller does not have the priority level required for the function to
 * succeed.
 *)
  DSERR_PRIOLEVELNEEDED           = $88780000 + 70 ;
(*
 * The DSound subsystem couldn't allocate sufficient memory to complete the
 * caller's request.
 *)
  DSERR_OUTOFMEMORY               = E_OUTOFMEMORY ;
(*
 * The specified WAVE format is not supported
 *)
  DSERR_BADFORMAT                 = $88780000 + 100 ;
(*
 * The function called is not supported at this time
 *)
  DSERR_UNSUPPORTED               = E_NOTIMPL ;
(*
 * No sound driver is available for use
 *)
  DSERR_NODRIVER                  = $88780000 + 120 ;
(*
 * This object is already initialized
 *)
  DSERR_ALREADYINITIALIZED        = $88780000 + 130 ;
(*
 * This object does not support aggregation
 *)
  DSERR_NOAGGREGATION             = CLASS_E_NOAGGREGATION ;
(*
 * The buffer memory has been lost, and must be Restored.
 *)
  DSERR_BUFFERLOST                = $88780000 + 150 ;
(*
 * Another app has a higher priority level, preventing this call from
 * succeeding.
 *)
  DSERR_OTHERAPPHASPRIO           = $88780000 + 160 ;
(*
 * The Initialize() member on the Direct Sound Object has not been
 * called or called successfully before calls to other members.
 *)
  DSERR_UNINITIALIZED             = $88780000 + 170 ;

//==========================================================================;
//
//                               Flags...
//
//==========================================================================;

  DSCAPS_PRIMARYMONO          = $00000001 ;
  DSCAPS_PRIMARYSTEREO        = $00000002 ;
  DSCAPS_PRIMARY8BIT          = $00000004 ;
  DSCAPS_PRIMARY16BIT         = $00000008 ;
  DSCAPS_CONTINUOUSRATE       = $00000010 ;
  DSCAPS_EMULDRIVER           = $00000020 ;
  DSCAPS_CERTIFIED            = $00000040 ;
  DSCAPS_SECONDARYMONO        = $00000100 ;
  DSCAPS_SECONDARYSTEREO      = $00000200 ;
  DSCAPS_SECONDARY8BIT        = $00000400 ;
  DSCAPS_SECONDARY16BIT       = $00000800 ;

  DSBPLAY_LOOPING             = $00000001 ;

  DSBSTATUS_PLAYING           = $00000001 ;
  DSBSTATUS_BUFFERLOST        = $00000002 ;
  DSBSTATUS_LOOPING           = $00000004 ;

  DSBLOCK_FROMWRITECURSOR     = $00000001 ;

  DSSCL_NORMAL                = 1 ;
  DSSCL_PRIORITY              = 2 ;
  DSSCL_EXCLUSIVE             = 3 ;
  DSSCL_WRITEPRIMARY          = 4 ;

  DSBCAPS_PRIMARYBUFFER       = $00000001 ;
  DSBCAPS_STATIC              = $00000002 ;
  DSBCAPS_LOCHARDWARE         = $00000004 ;
  DSBCAPS_LOCSOFTWARE         = $00000008 ;
  DSBCAPS_CTRLFREQUENCY       = $00000020 ;
  DSBCAPS_CTRLPAN             = $00000040 ;
  DSBCAPS_CTRLVOLUME          = $00000080 ;
  DSBCAPS_CTRLDEFAULT         = $000000E0 ;  // Pan + volume + frequency.
  DSBCAPS_CTRLALL             = $000000E0 ;  // All control capabilities
  DSBCAPS_STICKYFOCUS         = $00004000 ;
  DSBCAPS_GETCURRENTPOSITION2 = $00010000 ;  // More accurate play cursor under emulation

  DSSPEAKER_HEADPHONE         = 1 ;
  DSSPEAKER_MONO              = 2 ;
  DSSPEAKER_QUAD              = 3 ;
  DSSPEAKER_STEREO            = 4 ;
  DSSPEAKER_SURROUND          = 5 ;

type
  LPDSENUMCALLBACK = function ( lpGuid: PGUID ; lpstrDescription: LPSTR ;
      lpstrModule: LPSTR ; lpContext: Pointer ): BOOL ;

function DirectSoundCreate ( lpGuid: PGUID ; var ppDS: IDirectSound ;
    pUnkOuter: IUnknown ): HRESULT ; stdcall ;
function DirectSoundEnumerate ( lpCallback: LPDSENUMCALLBACK ;
    lpContext: Pointer ): HRESULT ; stdcall ;

implementation

function DirectSoundEnumerate ; external 'DSOUND.DLL'
    name 'DirectSoundEnumerateA' ;
function DirectSoundCreate ; external 'DSOUND.DLL' ;

end.

