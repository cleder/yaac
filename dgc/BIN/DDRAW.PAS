unit ddraw ;

interface

uses OLE2, Windows ;

(*==========================================================================;
 *
 *  Copyright (C) 1994-1996 Microsoft Corporation.  All Rights Reserved.
 *
 *  File:       ddraw.h
 *  Content:    DirectDraw include file
 *
 *  DirectX 2 Delphi adaptation by Blake Stone
 *
 *    EMail:     bstone@dkw.com
 *    Home Page: http://www.dkw.com/bstone
 *
 ***************************************************************************)

(*
 * GUIDS used by DirectDraw objects
 *)

const
  CLSID_DirectDraw: TGUID = ( D1:$D7B70EE0;D2:$4340;D3:$11CF;D4:($B0,$63,$00,$20,$AF,$C2,$CD,$35));
  CLSID_DirectDrawClipper: TGUID = ( D1:$593817A0;D2:$7DB3;D3:$11CF;D4:($A2,$DE,$00,$AA,$00,$b9,$33,$56));
  IID_IDirectDraw: TGUID = ( D1:$6C14DB80;D2:$A733;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60));
  IID_IDirectDraw2: TGUID = ( D1:$B3A6F3E0;D2:$2B43;D3:$11CF;D4:($A2,$DE,$00,$AA,$00,$B9,$33,$56));
  IID_IDirectDrawSurface: TGUID = ( D1:$6C14DB81;D2:$A733;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60));
  IID_IDirectDrawSurface2: TGUID = ( D1:$57805885;D2:$6eec;D3:$11cf;D4:($94,$41,$a8,$23,$03,$c1,$0e,$27));
  IID_IDirectDrawPalette: TGUID = ( D1:$6C14DB84;D2:$A733;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60));
  IID_IDirectDrawClipper: TGUID = ( D1:$6C14DB85;D2:$A733;D3:$11CE;D4:($A5,$21,$00,$20,$AF,$0B,$E5,$60));

(*============================================================================
 *
 * DirectDraw Structures
 *
 * Various structures used to invoke DirectDraw.
 *
 *==========================================================================*)

const
  DD_ROP_SPACE = ( 256 div 32 ) ;       // space required to store ROP array

type
  IDirectDraw = class;
  IDirectDraw2 = class;
  IDirectDrawSurface = class;
  IDirectDrawSurface2 = class;
  IDirectDrawPalette = class;
  IDirectDrawClipper = class;

(*
 * DDCOLORKEY
 *)

  DDCOLORKEY = record
    dwColorSpaceLowValue: DWORD ;   // low boundary of color space that is to
                                    // be treated as Color Key, inclusive
    dwColorSpaceHighValue: DWORD ;  // high boundary of color space that is
                                    // to be treated as Color Key, inclusive
  end ;
//  LPDDCOLORKEY = ^DDCOLORKEY ;

(*
 * DDSCAPS
 *)

  DDSCAPS = record
     dwCaps: DWORD ;         // capabilities of surface wanted
  end ;
//  LPDDSCAPS = ^DDSCAPS ;

(*
 * DDCAPS
 *)

  DDCAPS = record
    dwSize: DWORD ;                 // size of the DDDRIVERCAPS structure
    dwCaps: DWORD ;                 // driver specific capabilities
    dwCaps2: DWORD ;                // more driver specific capabilites
    dwCKeyCaps: DWORD ;             // color key capabilities of the surface
    dwFXCaps: DWORD ;               // driver specific stretching and effects capabilites
    dwFXAlphaCaps: DWORD ;          // alpha driver specific capabilities
    dwPalCaps: DWORD ;              // palette capabilities
    dwSVCaps: DWORD ;               // stereo vision capabilities
    dwAlphaBltConstBitDepths: DWORD ;       // DDBD_2,4,8
    dwAlphaBltPixelBitDepths: DWORD ;       // DDBD_1,2,4,8
    dwAlphaBltSurfaceBitDepths: DWORD ;     // DDBD_1,2,4,8
    dwAlphaOverlayConstBitDepths: DWORD ;   // DDBD_2,4,8
    dwAlphaOverlayPixelBitDepths: DWORD ;   // DDBD_1,2,4,8
    dwAlphaOverlaySurfaceBitDepths: DWORD ; // DDBD_1,2,4,8
    dwZBufferBitDepths: DWORD ;             // DDBD_8,16,24,32
    dwVidMemTotal: DWORD ;          // total amount of video memory
    dwVidMemFree: DWORD ;           // amount of free video memory
    dwMaxVisibleOverlays: DWORD ;   // maximum number of visible overlays
    dwCurrVisibleOverlays: DWORD ;  // current number of visible overlays
    dwNumFourCCCodes: DWORD ;       // number of four cc codes
    dwAlignBoundarySrc: DWORD ;     // source rectangle alignment
    dwAlignSizeSrc: DWORD ;         // source rectangle byte size
    dwAlignBoundaryDest: DWORD ;    // dest rectangle alignment
    dwAlignSizeDest: DWORD ;        // dest rectangle byte size
    dwAlignStrideAlign: DWORD ;     // stride alignment
    dwRops: Array [ 0..DD_ROP_SPACE-1 ] of DWORD ;   // ROPS supported
    ddsCaps: DDSCAPS ;                // DDSCAPS structure has all the general capabilities
    dwMinOverlayStretch: DWORD ;    // minimum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    dwMaxOverlayStretch: DWORD ;    // maximum overlay stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    dwMinLiveVideoStretch: DWORD ;  // minimum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    dwMaxLiveVideoStretch: DWORD ;  // maximum live video stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    dwMinHwCodecStretch: DWORD ;    // minimum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    dwMaxHwCodecStretch: DWORD ;    // maximum hardware codec stretch factor multiplied by 1000, eg 1000 == 1.0, 1300 == 1.3
    dwReserved1: DWORD ;            // reserved
    dwReserved2: DWORD ;            // reserved
    dwReserved3: DWORD ;            // reserved
    dwSVBCaps: DWORD ;              // driver specific capabilities for System->Vmem blts
    dwSVBCKeyCaps: DWORD ;          // driver color key capabilities for System->Vmem blts
    dwSVBFXCaps: DWORD ;            // driver FX capabilities for System->Vmem blts
    dwSVBRops: Array [ 0..DD_ROP_SPACE-1 ] of DWORD ;// ROPS supported for System->Vmem blts
    dwVSBCaps: DWORD ;              // driver specific capabilities for Vmem->System blts
    dwVSBCKeyCaps: DWORD ;          // driver color key capabilities for Vmem->System blts
    dwVSBFXCaps: DWORD ;            // driver FX capabilities for Vmem->System blts
    dwVSBRops: Array [ 0..DD_ROP_SPACE-1 ] of DWORD ;// ROPS supported for Vmem->System blts
    dwSSBCaps: DWORD ;              // driver specific capabilities for System->System blts
    dwSSBCKeyCaps: DWORD ;          // driver color key capabilities for System->System blts
    dwSSBFXCaps: DWORD ;            // driver FX capabilities for System->System blts
    dwSSBRops: Array [ 0..DD_ROP_SPACE-1 ] of DWORD ;// ROPS supported for System->System blts
    dwReserved4: DWORD ;            // reserved
    dwReserved5: DWORD ;            // reserved
    dwReserved6: DWORD ;            // reserved
  end ;
//  LPDDCAPS = ^DDCAPS ;

(*
 * DDPIXELFORMAT
 *)

  DDPIXELFORMAT = record
    dwSize: DWORD ;                 // size of structure
    dwFlags: DWORD ;                // pixel format flags
    dwFourCC: DWORD ;               // (FOURCC code)
    case Integer of
    0: (
      dwRGBBitCount: DWORD ;          // how many bits per pixel (BD_4,8,16,24,32)
      dwRBitMask: DWORD ;             // mask for red bit
      dwGBitMask: DWORD ;             // mask for green bits
      dwBBitMask: DWORD ;             // mask for blue bits
      dwRGBAlphaBitMask: DWORD ;      // mask for alpha channel
      ) ;
    1: (
      dwYUVBitCount: DWORD ;          // how many bits per pixel (BD_4,8,16,24,32)
      dwYBitMask: DWORD ;             // mask for Y bits
      dwUBitMask: DWORD ;             // mask for U bits
      dwVBitMask: DWORD ;             // mask for V bits
      dwYUVAlphaBitMask: DWORD ;      // mask for alpha channel
      ) ;
    2: (
      dwZBufferBitDepth: DWORD ;      // how many bits for z buffers (BD_8,16,24,32)
      ) ;
    3: (
      dwAlphaBitDepth: DWORD ;        // how many bits for alpha channels (BD_1,2,4,8)
      ) ;
  end ;
//  LPDDPIXELFORMAT = ^DDPIXELFORMAT ;

(*
 * DDBLTFX
 * Used to pass override information to the DIRECTDRAWSURFACE callback Blt.
 *)

  DDBLTFX = record
    dwSize: DWORD ;                           // size of structure
    dwDDFX: DWORD ;                           // FX operations
    dwROP: DWORD ;                            // Win32 raster operations
    dwDDROP: DWORD ;                          // Raster operations new for DirectDraw
    dwRotationAngle: DWORD ;                  // Rotation angle for blt
    dwZBufferOpCode: DWORD ;                  // ZBuffer compares
    dwZBufferLow: DWORD ;                     // Low limit of Z buffer
    dwZBufferHigh: DWORD ;                    // High limit of Z buffer
    dwZBufferBaseDest: DWORD ;                // Destination base value
    dwZDestConstBitDepth: DWORD ;             // Bit depth used to specify Z constant for destination
    case Integer of
    0: (
      dwZDestConst: DWORD ;                   // Constant to use as Z buffer for dest
      dwZSrcConstBitDepth: DWORD ;            // Bit depth used to specify Z constant for source
      dwZSrcConst: DWORD ;                    // Constant to use as Z buffer for src
      dwAlphaEdgeBlendBitDepth: DWORD ;       // Bit depth used to specify constant for alpha edge blend
      dwAlphaEdgeBlend: DWORD ;               // Alpha for edge blending
      dwReserved: DWORD ;
      dwAlphaDestConstBitDepth: DWORD ;       // Bit depth used to specify alpha constant for destination
      dwAlphaDestConst: DWORD ;               // Constant to use as Alpha Channel
      dwAlphaSrcConstBitDepth: DWORD ;        // Bit depth used to specify alpha constant for source
      dwAlphaSrcConst: DWORD ;                // Constant to use as Alpha Channel
      dwFillColor: DWORD ;                    // color in RGB or Palettized
      ddckDestColorkey: DDCOLORKEY ;               // DestColorkey override
      ddckSrcColorkey: DDCOLORKEY ;                // SrcColorkey override
      ) ;
    1: (
      lpDDSZBufferDest: IDirectDrawSurface ;   // Surface to use as Z buffer for dest
      UNIONFILLER1b: DWORD ;
      lpDDSZBufferSrc: IDirectDrawSurface ;    // Surface to use as Z buffer for src
      UNIONFILLER1d: DWORD ;
      UNIONFILLER1e: DWORD ;
      UNIONFILLER1f: DWORD ;
      UNIONFILLER1g: DWORD ;
      lpDDSAlphaDest: IDirectDrawSurface ;     // Surface to use as Alpha Channel
      UNIONFILLER1i: DWORD ;
      lpDDSAlphaSrc: IDirectDrawSurface ;      // Surface to use as Alpha Channel
      dwFillDepth: DWORD ;                    // depth value for z-buffer
      ) ;
    2: (
      UNIONFILLER2a: DWORD ;
      UNIONFILLER2b: DWORD ;
      UNIONFILLER2c: DWORD ;
      UNIONFILLER2d: DWORD ;
      UNIONFILLER2e: DWORD ;
      UNIONFILLER2f: DWORD ;
      UNIONFILLER2g: DWORD ;
      UNIONFILLER2h: DWORD ;
      UNIONFILLER2i: DWORD ;
      UNIONFILLER2j: DWORD ;
      lpDDSPattern: IDirectDrawSurface ;       // Surface to use as pattern
      ) ;
  end ;
//  LPDDBLTFX = ^DDBLTFX ;

(*
 * DDOVERLAYFX
 *)

  DDOVERLAYFX = record
    dwSize: DWORD ;                         // size of structure
    dwAlphaEdgeBlendBitDepth: DWORD ;       // Bit depth used to specify constant for alpha edge blend
    dwAlphaEdgeBlend: DWORD ;               // Constant to use as alpha for edge blend
    dwReserved: DWORD ;
    dwAlphaDestConstBitDepth: DWORD ;       // Bit depth used to specify alpha constant for destination
    case Integer of
    0: (
      dwAlphaDestConst: DWORD ;               // Constant to use as alpha channel for dest
      dwAlphaSrcConstBitDepth: DWORD ;        // Bit depth used to specify alpha constant for source
      dwAlphaSrcConst: DWORD ;                // Constant to use as alpha channel for src
      dckDestColorkey: DDCOLORKEY ;                // DestColorkey override
      dckSrcColorkey: DDCOLORKEY ;                 // DestColorkey override
      dwDDFX: DWORD ;                         // Overlay FX
      dwFlags: DWORD ;                        // flags
      ) ;
    1: (
      lpDDSAlphaDest: IDirectDrawSurface ;     // Surface to use as alpha channel for dest
      UNIONFILLER1b: DWORD ;
      lpDDSAlphaSrc: IDirectDrawSurface ;      // Surface to use as alpha channel for src
      ) ;
  end ;
//  LPDDOVERLAYFX = ^DDOVERLAYFX ;

(*
 * DDBLTBATCH: BltBatch entry structure
 *)

  DDBLTBATCH = record
    lprDest: ^TRect ;
    lpDDSSrc: IDirectDrawSurface ;
    lprSrc: ^TRect ;
    dwFlags: DWORD ;
    lpDDBltFx: ^DDBLTFX ;
  end ;
//  LPDDBLTBATCH = ^DDBLTBATCH ;

(*
 * DDSURFACEDESC
 *)

  DDSURFACEDESC = record
    dwSize: DWORD ;                 // size of the DDSURFACEDESC structure
    dwFlags: DWORD ;                // determines what fields are valid
    dwHeight: DWORD ;               // height of surface to be created
    dwWidth: DWORD ;                // width of input surface
    lPitch: LongInt ;                 // distance to start of next line (return value only)
    dwBackBufferCount: DWORD ;      // number of back buffers requested
    case Integer of
    0: (
      dwMipMapCount: DWORD ;          // number of mip-map levels requested
      dwAlphaBitDepth: DWORD ;        // depth of alpha buffer requested
      dwReserved: DWORD ;             // reserved
      lpSurface: Pointer ;              // pointer to the associated surface memory
      ddckCKDestOverlay: DDCOLORKEY ;      // color key for destination overlay use
      ddckCKDestBlt: DDCOLORKEY ;          // color key for destination blt use
      ddckCKSrcOverlay: DDCOLORKEY ;       // color key for source overlay use
      ddckCKSrcBlt: DDCOLORKEY ;           // color key for source blt use
      ddpfPixelFormat: DDPIXELFORMAT ;        // pixel format description of the surface
      ddsCaps: DDSCAPS ;                // direct draw surface capabilities
      ) ;
    1: (
      dwZBufferBitDepth: DWORD ;      // depth of Z buffer requested
      ) ;
    2: (
      dwRefreshRate: DWORD ;          // refresh rate (used when display mode is described)
      ) ;
  end ;
//  LPDDSURFACEDESC = ^DDSURFACEDESC ;

(*
 * callbacks
 *)

// typedef DWORD   (FAR PASCAL *LPCLIPPERCALLBACK)(IDirectDrawClipper lpDDClipper, HWND hWnd, DWORD code, LPVOID lpContext );
// #ifdef STREAMING
// typedef DWORD   (FAR PASCAL *LPSURFACESTREAMINGCALLBACK)(DWORD);
// #endif
  LPDDENUMMODESCALLBACK = function ( const lpDDSurfaceDesc: DDSURFACEDESC ;
      lpContext: Pointer ): HRESULT ;
  LPDDENUMSURFACESCALLBACK = function ( lpDDSurface: IDirectDrawSurface ;
      const lpDDSurfaceDesc: DDSURFACEDESC ; lpContext: Pointer ): HRESULT ;

(*
 * INTERACES FOLLOW:
 *      IDirectDraw
 *      IDirectDrawClipper
 *      IDirectDrawPalette
 *      IDirectDrawSurface
 *)

(*
 * IDirectDraw
 *)

  IDirectDraw = class ( IUnknown )
    (*** IDirectDraw methods ***)
    function Compact: HRESULT ; virtual ; stdcall ; abstract ;
    function CreateClipper ( dwFlags: DWORD ;
        var lplpDDClipper: IDirectDrawClipper ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function CreatePalette ( dwFlags: DWORD ; lpColorTable: PPaletteEntry ;
        var lplpDDPalette: IDirectDrawPalette ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function CreateSurface ( const lpDDSurfaceDesc: DDSURFACEDESC ;
        var lplpDDSurface: IDirectDrawSurface ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function DuplicateSurface ( lpDDSurface: IDirectDrawSurface ;
        var lplpDupDDSurface: IDirectDrawSurface ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function EnumDisplayModes ( dwFlags: DWORD ;
        const lpDDSurfaceDesc: DDSURFACEDESC ; lpContext: Pointer ;
        lpEnumModesCallback: LPDDENUMMODESCALLBACK ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function EnumSurfaces ( dwFlags: DWORD ; const lpDDSD: DDSURFACEDESC ;
        lpContext: Pointer ; lpEnumCallback: LPDDENUMSURFACESCALLBACK ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function FlipToGDISurface: HRESULT ; virtual ; stdcall ; abstract ;
    function GetCaps ( var lpDDDriverCaps: DDCAPS ;
        var lpDDHELCaps: DDCAPS ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetDisplayMode ( var lpDDSurfaceDesc: DDSURFACEDESC ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetFourCCCodes ( var lpNumCodes, lpCodes: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetGDISurface ( var lplpGDIDDSSurface: IDirectDrawSurface ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function GetMonitorFrequency ( var lpdwFrequency: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetScanLine ( var lpdwScanLine: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function GetVerticalBlankStatus ( var lpbIsInVB: BOOL ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Initialize ( lpGUID: PGUID ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function RestoreDisplayMode: HRESULT ; virtual ; stdcall ; abstract ;
    function SetCooperativeLevel ( hWnd: HWND ; dwFlags: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    (*** Warning!  SetDisplayMode differs between DirectDraw 1 and DirectDraw 2 ***)
    function SetDisplayMode ( dwWidth: DWORD ; dwHeight: DWORD ;
        dwBpp: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function WaitForVerticalBlank ( dwFlags: DWORD ; hEvent: THandle ):
        HRESULT ; virtual ; stdcall ; abstract ;
  end ;

  IDirectDraw2 = class ( IUnknown )
    (*** IDirectDraw methods ***)
    function Compact: HRESULT ; virtual ; stdcall ; abstract ;
    function CreateClipper ( dwFlags: DWORD ;
        var lplpDDClipper: IDirectDrawClipper ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function CreatePalette ( dwFlags: DWORD ; lpColorTable: PPaletteEntry ;
        var lplpDDPalette: IDirectDrawPalette ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function CreateSurface ( const lpDDSurfaceDesc: DDSURFACEDESC ;
        var lplpDDSurface: IDirectDrawSurface ;
        pUnkOuter: IUnknown ): HRESULT ; virtual ; stdcall ; abstract ;
    function DuplicateSurface ( lpDDSurface: IDirectDrawSurface ;
        var lplpDupDDSurface: IDirectDrawSurface ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function EnumDisplayModes ( dwFlags: DWORD ;
        const lpDDSurfaceDesc: DDSURFACEDESC ; lpContext: Pointer ;
        lpEnumModesCallback: LPDDENUMMODESCALLBACK ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function EnumSurfaces ( dwFlags: DWORD ; const lpDDSD: DDSURFACEDESC ;
        lpContext: Pointer ; lpEnumCallback: LPDDENUMSURFACESCALLBACK ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function FlipToGDISurface: HRESULT ; virtual ; stdcall ; abstract ;
    function GetCaps ( var lpDDDriverCaps: DDCAPS ;
        var lpDDHELCaps: DDCAPS ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetDisplayMode ( var lpDDSurfaceDesc: DDSURFACEDESC ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetFourCCCodes ( var lpNumCodes, lpCodes: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetGDISurface ( var lplpGDIDDSSurface: IDirectDrawSurface ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function GetMonitorFrequency ( var lpdwFrequency: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetScanLine ( var lpdwScanLine: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function GetVerticalBlankStatus ( var lpbIsInVB: BOOL ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function Initialize ( lpGUID: PGUID ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function RestoreDisplayMode: HRESULT ; virtual ; stdcall ; abstract ;
    function SetCooperativeLevel ( hWnd: HWND ; dwFlags: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    (*** Warning!  SetDisplayMode differs between DirectDraw 1 and DirectDraw 2 ***)
    function SetDisplayMode ( dwWidth: DWORD ; dwHeight: DWORD ; dwBPP: DWORD ;
        dwRefreshRate: DWORD ; dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function WaitForVerticalBlank ( dwFlags: DWORD ; hEvent: THandle ):
        HRESULT ; virtual ; stdcall ; abstract ;
    (*** Added in the v2 interface ***)
    function GetAvailableVidMem ( var lpDDSCaps: DDSCAPS ;
        var lpdwTotal, lpdwFree: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
  end ;

(*
 * IDirectDrawPalette
 *)

  IDirectDrawPalette = class ( IUnknown )
    (*** IDirectDrawPalette methods ***)
    function GetCaps ( var lpdwCaps: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetEntries ( dwFlags: DWORD ; dwBase: DWORD ; dwNumEntries: DWORD ;
        lpEntries: PPaletteEntry ): HRESULT ; virtual ; stdcall ; abstract ;
    function Initialize ( lpDD: IDirectDraw ; dwFlags: DWORD ;
        lpDDColorTable: PPaletteEntry ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function SetEntries ( dwFlags: DWORD ; dwStartingEntry: DWORD ;
        dwCount: DWORD ; lpEntries: PPaletteEntry ): HRESULT ; virtual ;
        stdcall ; abstract ;
  end ;

(*
 * IDirectDrawClipper
 *)

  IDirectDrawClipper = class ( IUnknown )
    (*** IDirectDrawClipper methods ***)
    function GetClipList ( const lpRect: TRect ; lpClipList: PRgnData ;
        var lpdwSize: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetHWnd ( var lphWnd: HWND ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function Initialize ( lpDD: IDirectDraw ; dwFlags: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function IsClipListChanged ( var lpbChanged: BOOL ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function SetClipList ( lpClipList: PRgnData ; dwFlags: DWORD ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function SetHWnd ( dwFlags: DWORD ; hWnd: HWND ): HRESULT ; virtual ;
        stdcall ; abstract ;
  end ;

(*
 * IDirectDrawSurface and related interfaces
 *)

  IDirectDrawSurface = class ( IUnknown )
    (*** IDirectDrawSurface methods ***)
    function AddAttachedSurface ( lpDDSAttachedSurface: IDirectDrawSurface ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function AddOverlayDirtyRect ( const lpRect: TRect ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function Blt ( const lpDestRect: TRect ;
        lpDDSrcSurface: IDirectDrawSurface ; const lpSrcRect: TRect ;
        dwFlags: DWORD ; const lpDDBltFx: DDBLTFX ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function BltBatch ( const lpDDBltBatch: DDBLTBATCH ; dwCount: DWORD ;
        dwFlags: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function BltFast ( dwX: DWORD ; dwY: DWORD ;
        lpDDSrcSurface: IDirectDrawSurface ; const lpSrcRect: TRect ;
        dwTrans: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function DeleteAttachedSurface ( dwFlags: DWORD ;
        lpDDSAttachedSurface: IDirectDrawSurface): HRESULT ; virtual ;
        stdcall ; abstract ;
    function EnumAttachedSurfaces ( lpContext: Pointer ;
        lpEnumSurfacesCallback: LPDDENUMSURFACESCALLBACK): HRESULT ; virtual ;
        stdcall ; abstract ;
    function EnumOverlayZOrders ( dwFlags: DWORD ; lpContext: Pointer ;
        lpfnCallback: LPDDENUMSURFACESCALLBACK ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function Flip ( lpDDSurfaceTargetOverride: IDirectDrawSurface ;
        dwFlags: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetAttachedSurface ( var lpDDSCaps: DDSCAPS ;
        var lplpDDAttachedSurface: IDirectDrawSurface ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetBltStatus ( dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetCaps ( var lpDDSCaps: DDSCAPS ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetClipper ( var lplpDDClipper: IDirectDrawClipper ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetColorKey ( dwFlags: DWORD ; var lpDDColorKey: DDCOLORKEY ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function GetDC ( var lphDC: HDC ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetFlipStatus ( dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetOverlayPosition ( var lplX, lplY: LongInt ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetPalette ( var lplpDDPalette: IDirectDrawPalette ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetPixelFormat ( var lpDDPixelFormat: DDPIXELFORMAT ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetSurfaceDesc ( var lpDDSurfaceDesc: DDSURFACEDESC ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Initialize ( lpDD: IDirectDraw ;
        const lpDDSurfaceDesc: DDSURFACEDESC ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function IsLost: HRESULT ; virtual ; stdcall ; abstract ;
    function Lock ( const lpDestRect: TRect ; var lpDDSurfaceDesc:
        DDSURFACEDESC ; dwFlags: DWORD ; hEvent: THandle ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function ReleaseDC ( hDC: HDC ): HRESULT ; virtual ; stdcall ; abstract ;
    function Restore: HRESULT ; virtual ; stdcall ; abstract ;
    function SetClipper ( lpDDClipper: IDirectDrawClipper ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function SetColorKey ( dwFlags: DWORD ; const lpDDColorKey: DDCOLORKEY ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function SetOverlayPosition ( lX, lY: LongInt ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function SetPalette ( lpDDPalette: IDirectDrawPalette ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Unlock ( lpSurfaceData: Pointer ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function UpdateOverlay ( const lpSrcRect: TRect ;
        lpDDDestSurface: IDirectDrawSurface ; const lpDestRect: TRect ;
        dwFlags: DWORD ; const lpDDOverlayFx: DDOVERLAYFX ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function UpdateOverlayDisplay ( dwFlags: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function UpdateOverlayZOrder ( dwFlags: DWORD ;
        lpDDSReference: IDirectDrawSurface): HRESULT ; virtual ;
        stdcall ; abstract ;
  end ;

(*
 * IDirectDrawSurface2 and related interfaces
 *)

  IDirectDrawSurface2 = class ( IUnknown )
    (*** IDirectDrawSurface methods ***)
    function AddAttachedSurface ( lpDDSAttachedSurface: IDirectDrawSurface ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function AddOverlayDirtyRect ( const lpRect: TRect ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function Blt ( const lpDestRect: TRect ; lpDDSrcSurface: IDirectDrawSurface ;
        const lpSrcRect: TRect ; dwFlags: DWORD ; const lpDDBltFx: DDBLTFX):
        HRESULT ; virtual ; stdcall ; abstract ;
    function BltBatch ( const lpDDBltBatch: DDBLTBATCH ; dwCount: DWORD ;
        dwFlags: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function BltFast ( dwX: DWORD ; dwY: DWORD ;
        lpDDSrcSurface: IDirectDrawSurface ; const lpSrcRect: TRect ;
        dwTrans: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function DeleteAttachedSurface ( dwFlags: DWORD ;
        lpDDSAttachedSurface: IDirectDrawSurface): HRESULT ; virtual ;
        stdcall ; abstract ;
    function EnumAttachedSurfaces ( lpContext: Pointer ;
        lpEnumSurfacesCallback: LPDDENUMSURFACESCALLBACK): HRESULT ; virtual ;
        stdcall ; abstract ;
    function EnumOverlayZOrders ( dwFlags: DWORD ; lpContext: Pointer ;
        lpfnCallback: LPDDENUMSURFACESCALLBACK ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function Flip ( lpDDSurfaceTargetOverride: IDirectDrawSurface ;
        dwFlags: DWORD ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetAttachedSurface ( var lpDDSCaps: DDSCAPS ;
        var lplpDDAttachedSurface: IDirectDrawSurface ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetBltStatus ( dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetCaps ( var lpDDSCaps: DDSCAPS ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetClipper ( var lplpDDClipper: IDirectDrawClipper ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetColorKey ( dwFlags: DWORD ; var lpDDColorKey: DDCOLORKEY ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function GetDC ( var lphDC: HDC ): HRESULT ; virtual ; stdcall ; abstract ;
    function GetFlipStatus ( dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function GetOverlayPosition ( var lplX, lplY: LongInt ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetPalette ( var lplpDDPalette: IDirectDrawPalette): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetPixelFormat ( var lpDDPixelFormat: DDPIXELFORMAT ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function GetSurfaceDesc ( var lpDDSurfaceDesc: DDSURFACEDESC ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Initialize ( lpDD: IDirectDraw ;
        const lpDDSurfaceDesc: DDSURFACEDESC ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function IsLost: HRESULT ; virtual ; stdcall ; abstract ;
    function Lock ( const lpDestRect: TRect ;
        const lpDDSurfaceDesc: DDSURFACEDESC ; dwFlags: DWORD ;
        hEvent: THandle ): HRESULT ; virtual ; stdcall ; abstract ;
    function ReleaseDC ( hDC: HDC ): HRESULT ; virtual ; stdcall ; abstract ;
    function Restore: HRESULT ; virtual ; stdcall ; abstract ;
    function SetClipper ( lpDDClipper: IDirectDrawClipper ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function SetColorKey ( dwFlags: DWORD ; const lpDDColorKey: DDCOLORKEY ):
        HRESULT ; virtual ; stdcall ; abstract ;
    function SetOverlayPosition ( lX, lY: LongInt ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function SetPalette ( lpDDPalette: IDirectDrawPalette ): HRESULT ;
        virtual ; stdcall ; abstract ;
    function Unlock ( lpSurfaceData: Pointer ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function UpdateOverlay ( const lpSrcRect: TRect ;
        lpDDDestSurface: IDirectDrawSurface ; const lpDestRect: TRect ;
        dwFlags: DWORD ; const lpDDOverlayFx: DDOVERLAYFX ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function UpdateOverlayDisplay ( dwFlags: DWORD ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function UpdateOverlayZOrder ( dwFlags: DWORD ;
        lpDDSReference: IDirectDrawSurface): HRESULT ; virtual ;
        stdcall ; abstract ;
    (*** Added in the v2 interface ***)
    function GetDDInterface ( var lplpDD: IDirectDraw ): HRESULT ; virtual ;
        stdcall ; abstract ;
    function PageLock ( dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
    function PageUnlock ( dwFlags: DWORD ): HRESULT ; virtual ; stdcall ;
        abstract ;
  end ;

const

(*
 * ddsCaps field is valid.
 *)

  DDSD_CAPS               = $00000001 ;     // default

(*
 * dwHeight field is valid.
 *)

  DDSD_HEIGHT             = $00000002 ;

(*
 * dwWidth field is valid.
 *)

  DDSD_WIDTH              = $00000004 ;

(*
 * lPitch is valid.
 *)

  DDSD_PITCH              = $00000008 ;

(*
 * dwBackBufferCount is valid.
 *)

  DDSD_BACKBUFFERCOUNT    = $00000020 ;

(*
 * dwZBufferBitDepth is valid.
 *)

  DDSD_ZBUFFERBITDEPTH    = $00000040 ;

(*
 * dwAlphaBitDepth is valid.
 *)

  DDSD_ALPHABITDEPTH      = $00000080 ;



(*
 * ddpfPixelFormat is valid.
 *)

  DDSD_PIXELFORMAT        = $00001000 ;

(*
 * ddckCKDestOverlay is valid.
 *)

  DDSD_CKDESTOVERLAY      = $00002000 ;

(*
 * ddckCKDestBlt is valid.
 *)

  DDSD_CKDESTBLT          = $00004000 ;

(*
 * ddckCKSrcOverlay is valid.
 *)

  DDSD_CKSRCOVERLAY       = $00008000 ;

(*
 * ddckCKSrcBlt is valid.
 *)

  DDSD_CKSRCBLT           = $00010000 ;

(*
 * dwMipMapCount is valid.
 *)

  DDSD_MIPMAPCOUNT        = $00020000 ;

 (*
  * dwRefreshRate is valid
  *)

  DDSD_REFRESHRATE        = $00040000 ;


(*
 * All input fields are valid.
 *)

  DDSD_ALL                = $0007f9ee ;


(*============================================================================
 *
 * Direct Draw Capability Flags
 *
 * These flags are used to describe the capabilities of a given Surface.
 * All flags are bit flags.
 *
 *==========================================================================*)

(****************************************************************************
 *
 * DIRECTDRAWSURFACE CAPABILITY FLAGS
 *
 ****************************************************************************)
(*
 * This bit currently has no meaning.
 *)

  DDSCAPS_3D                              = $00000001 ;

(*
 * Indicates that this surface contains alpha information.  The pixel
 * format must be interrogated to determine whether this surface
 * contains only alpha information or alpha information interlaced
 * with pixel color data (e.g. RGBA or YUVA).
 *)

  DDSCAPS_ALPHA                           = $00000002 ;

(*
 * Indicates that this surface is a backbuffer.  It is generally
 * set by CreateSurface when the DDSCAPS_FLIP capability bit is set.
 * It indicates that this surface is THE back buffer of a surface
 * flipping structure.  DirectDraw supports N surfaces in a
 * surface flipping structure.  Only the surface that immediately
 * precedeces the DDSCAPS_FRONTBUFFER has this capability bit set.
 * The other surfaces are identified as back buffers by the presence
 * of the DDSCAPS_FLIP capability, their attachment order, and the
 * absence of the DDSCAPS_FRONTBUFFER and DDSCAPS_BACKBUFFER
 * capabilities.  The bit is sent to CreateSurface when a standalone
 * back buffer is being created.  This surface could be attached to
 * a front buffer and/or back buffers to form a flipping surface
 * structure after the CreateSurface call.  See AddAttachments for
 * a detailed description of the behaviors in this case.
 *)

  DDSCAPS_BACKBUFFER                      = $00000004 ;

(*
 * Indicates a complex surface structure is being described.  A
 * complex surface structure results in the creation of more than
 * one surface.  The additional surfaces are attached to the root
 * surface.  The complex structure can only be destroyed by
 * destroying the root.
 *)

  DDSCAPS_COMPLEX                         = $00000008 ;

(*
 * Indicates that this surface is a part of a surface flipping structure.
 * When it is passed to CreateSurface the DDSCAPS_FRONTBUFFER and
 * DDSCAP_BACKBUFFER bits are not set.  They are set by CreateSurface
 * on the resulting creations.  The dwBackBufferCount field in the
 * DDSURFACEDESC structure must be set to at least 1 in order for
 * the CreateSurface call to succeed.  The DDSCAPS_COMPLEX capability
 * must always be set with creating multiple surfaces through CreateSurface.
 *)

  DDSCAPS_FLIP                            = $00000010 ;

(*
 * Indicates that this surface is THE front buffer of a surface flipping
 * structure.  It is generally set by CreateSurface when the DDSCAPS_FLIP
 * capability bit is set.
 * If this capability is sent to CreateSurface then a standalonw front buffer
 * is created.  This surface will not have the DDSCAPS_FLIP capability.
 * It can be attached to other back buffers to form a flipping structure.
 * See AddAttachments for a detailed description of the behaviors in this
 * case.
 *)

  DDSCAPS_FRONTBUFFER                     = $00000020 ;

(*
 * Indicates that this surface is any offscreen surface that is not an overlay,
 * texture, zbuffer, front buffer, back buffer, or alpha surface.  It is used
 * to identify plain vanilla surfaces.
 *)

  DDSCAPS_OFFSCREENPLAIN                  = $00000040 ;

(*
 * Indicates that this surface is an overlay.  It may or may not be directly visible
 * depending on whether or not it is currently being overlayed onto the primary
 * surface.  DDSCAPS_VISIBLE can be used to determine whether or not it is being
 * overlayed at the moment.
 *)

  DDSCAPS_OVERLAY                         = $00000080 ;

(*
 * Indicates that unique DirectDrawPalette objects can be created and
 * attached to this surface.
 *)

  DDSCAPS_PALETTE                         = $00000100 ;

(*
 * Indicates that this surface is the primary surface.  The primary
 * surface represents what the user is seeing at the moment.
 *)

  DDSCAPS_PRIMARYSURFACE                  = $00000200 ;

(*
 * Indicates that this surface is the primary surface for the left eye.
 * The primary surface for the left eye represents what the user is seeing
 * at the moment with the users left eye.  When this surface is created the
 * DDSCAPS_PRIMARYSURFACE represents what the user is seeing with the users
 * right eye.
 *)

  DDSCAPS_PRIMARYSURFACELEFT              = $00000400 ;

(*
 * Indicates that this surface memory was allocated in system memory
 *)

  DDSCAPS_SYSTEMMEMORY                    = $00000800 ;

(*
 * Indicates that this surface can be used as a 3D texture.  It does not
 * indicate whether or not the surface is being used for that purpose.
 *)

  DDSCAPS_TEXTURE                         = $00001000 ;

(*
 * Indicates that a surface may be a destination for 3D rendering.  This
 * bit must be set in order to query for a Direct3D Device Interface
 * from this surface.
 *)

  DDSCAPS_3DDEVICE                        = $00002000 ;

(*
 * Indicates that this surface exists in video memory.
 *)

  DDSCAPS_VIDEOMEMORY                     = $00004000 ;

(*
 * Indicates that changes made to this surface are immediately visible.
 * It is always set for the primary surface and is set for overlays while
 * they are being overlayed and texture maps while they are being textured.
 *)

  DDSCAPS_VISIBLE                         = $00008000 ;

(*
 * Indicates that only writes are permitted to the surface.  Read accesses
 * from the surface may or may not generate a protection fault, but the
 * results of a read from this surface will not be meaningful.  READ ONLY.
 *)

  DDSCAPS_WRITEONLY                       = $00010000 ;

(*
 * Indicates that this surface is a z buffer. A z buffer does not contain
 * displayable information.  Instead it contains bit depth information that is
 * used to determine which pixels are visible and which are obscured.
 *)

  DDSCAPS_ZBUFFER                         = $00020000 ;

(*
 * Indicates surface will have a DC associated long term
 *)

  DDSCAPS_OWNDC                           = $00040000 ;

(*
 * Indicates surface should be able to receive live video
 *)

  DDSCAPS_LIVEVIDEO                       = $00080000 ;

(*
 * Indicates surface should be able to have a stream decompressed
 * to it by the hardware.
 *)

  DDSCAPS_HWCODEC                         = $00100000 ;

(*
 * Surface is a 320x200 or 320x240 ModeX surface
 *)

  DDSCAPS_MODEX                           = $00200000 ;

(*
 * Indicates surface is one level of a mip-map. This surface will
 * be attached to other DDSCAPS_MIPMAP surfaces to form the mip-map.
 * This can be done explicitly, by creating a number of surfaces and
 * attaching them with AddAttachedSurface or by implicitly by CreateSurface.
 * If this bit is set then DDSCAPS_TEXTURE must also be set.
 *)

  DDSCAPS_MIPMAP                          = $00400000 ;



(*
 * Indicates that memory for the surface is not allocated until the surface
 * is loaded (via the Direct3D texture Load() function).
 *)

  DDSCAPS_ALLOCONLOAD                     = $04000000 ;



 (****************************************************************************
 *
 * DIRECTDRAW DRIVER CAPABILITY FLAGS
 *
 ****************************************************************************)

(*
 * Display hardware has 3D acceleration.
 *)

  DDCAPS_3D                       = $00000001 ;

(*
 * Indicates that DirectDraw will support only dest rectangles that are aligned
 * on DIRECTDRAWCAPS.dwAlignBoundaryDest boundaries of the surface, respectively.
 * READ ONLY.
 *)

  DDCAPS_ALIGNBOUNDARYDEST        = $00000002 ;

(*
 * Indicates that DirectDraw will support only source rectangles  whose sizes in 
 * BYTEs are DIRECTDRAWCAPS.dwAlignSizeDest multiples, respectively.  READ ONLY.
 *)

  DDCAPS_ALIGNSIZEDEST            = $00000004 ;
(*
 * Indicates that DirectDraw will support only source rectangles that are aligned
 * on DIRECTDRAWCAPS.dwAlignBoundarySrc boundaries of the surface, respectively.
 * READ ONLY.
 *)

  DDCAPS_ALIGNBOUNDARYSRC         = $00000008 ;

(*
 * Indicates that DirectDraw will support only source rectangles  whose sizes in 
 * BYTEs are DIRECTDRAWCAPS.dwAlignSizeSrc multiples, respectively.  READ ONLY.
 *)

  DDCAPS_ALIGNSIZESRC             = $00000010 ;

(*
 * Indicates that DirectDraw will create video memory surfaces that have a stride 
 * alignment equal to DIRECTDRAWCAPS.dwAlignStride.  READ ONLY.
 *)

  DDCAPS_ALIGNSTRIDE              = $00000020 ;

(*
 * Display hardware is capable of blt operations.
 *)

  DDCAPS_BLT                      = $00000040 ;

(*
 * Display hardware is capable of asynchronous blt operations.
 *)

  DDCAPS_BLTQUEUE                 = $00000080 ;

(*
 * Display hardware is capable of color space conversions during the blt operation.
 *)

  DDCAPS_BLTFOURCC                = $00000100 ;

(*
 * Display hardware is capable of stretching during blt operations.
 *)

  DDCAPS_BLTSTRETCH               = $00000200 ;

(*
 * Display hardware is shared with GDI.
 *)

  DDCAPS_GDI                      = $00000400 ;

(*
 * Display hardware can overlay.
 *)

  DDCAPS_OVERLAY                  = $00000800 ;

(*
 * Set if display hardware supports overlays but can not clip them.
 *)

  DDCAPS_OVERLAYCANTCLIP          = $00001000 ;

(*
 * Indicates that overlay hardware is capable of color space conversions during
 * the overlay operation.
 *)

  DDCAPS_OVERLAYFOURCC            = $00002000 ;

(*
 * Indicates that stretching can be done by the overlay hardware.
 *)

  DDCAPS_OVERLAYSTRETCH           = $00004000 ;

(*
 * Indicates that unique DirectDrawPalettes can be created for DirectDrawSurfaces
 * other than the primary surface.
 *)

  DDCAPS_PALETTE                  = $00008000 ;

(*
 * Indicates that palette changes can be syncd with the veritcal refresh.
 *)

  DDCAPS_PALETTEVSYNC             = $00010000 ;

(*
 * Display hardware can return the current scan line.
 *)

  DDCAPS_READSCANLINE             = $00020000 ;

(*
 * Display hardware has stereo vision capabilities.  DDSCAPS_PRIMARYSURFACELEFT 
 * can be created.
 *)

  DDCAPS_STEREOVIEW               = $00040000 ;

(*
 * Display hardware is capable of generating a vertical blank interrupt.
 *)

  DDCAPS_VBI                      = $00080000 ;

(*
 * Supports the use of z buffers with blt operations.
 *)

  DDCAPS_ZBLTS                    = $00100000 ;

(*
 * Supports Z Ordering of overlays.
 *)

  DDCAPS_ZOVERLAYS                = $00200000 ;

(*
 * Supports color key
 *)

  DDCAPS_COLORKEY                 = $00400000 ;

(*
 * Supports alpha surfaces
 *)

  DDCAPS_ALPHA                    = $00800000 ;

(*
 * colorkey is hardware assisted(DDCAPS_COLORKEY will also be set)
 *)

  DDCAPS_COLORKEYHWASSIST         = $01000000 ;

(*
 * no hardware support at all
 *)

  DDCAPS_NOHARDWARE               = $02000000 ;

(*
 * Display hardware is capable of color fill with bltter
 *)

  DDCAPS_BLTCOLORFILL             = $04000000 ;

(*
 * Display hardware is bank switched, and potentially very slow at
 * random access to VRAM.
 *)

  DDCAPS_BANKSWITCHED             = $08000000 ;

(*
 * Display hardware is capable of depth filling Z-buffers with bltter
 *)

  DDCAPS_BLTDEPTHFILL             = $10000000 ;

(*
 * Display hardware is capable of clipping while bltting.
 *)

  DDCAPS_CANCLIP                  = $20000000 ;

(*
 * Display hardware is capable of clipping while stretch bltting.
 *)

  DDCAPS_CANCLIPSTRETCHED         = $40000000 ;

(*
 * Display hardware is capable of bltting to or from system memory
 *)

  DDCAPS_CANBLTSYSMEM             = $80000000 ;


 (****************************************************************************
 *
 * MORE DIRECTDRAW DRIVER CAPABILITY FLAGS (dwCaps2)
 *
 ****************************************************************************)

(*
 * Display hardware is certified
 *)

  DDCAPS2_CERTIFIED               = $00000001 ;

(*
 * Driver cannot interleave 2D operations (lock and blt) to surfaces with
 * Direct3D rendering operations between calls to BeginScene() and EndScene()
 *)

  DDCAPS2_NO2DDURING3DSCENE       = $00000002 ;

(****************************************************************************
 *
 * DIRECTDRAW FX ALPHA CAPABILITY FLAGS
 *
 ****************************************************************************)

(*
 * Supports alpha blending around the edge of a source color keyed surface.
 * For Blt.
 *)

  DDFXALPHACAPS_BLTALPHAEDGEBLEND         = $00000001 ;

(*
 * Supports alpha information in the pixel format.  The bit depth of alpha 
 * information in the pixel format can be 1,2,4, or 8.  The alpha value becomes
 * more opaque as the alpha value increases.  (0 is transparent.)
 * For Blt.
 *)

  DDFXALPHACAPS_BLTALPHAPIXELS            = $00000002 ;

(*
 * Supports alpha information in the pixel format.  The bit depth of alpha 
 * information in the pixel format can be 1,2,4, or 8.  The alpha value 
 * becomes more transparent as the alpha value increases.  (0 is opaque.) 
 * This flag can only be set if DDCAPS_ALPHA is set.
 * For Blt.
 *)

  DDFXALPHACAPS_BLTALPHAPIXELSNEG         = $00000004 ;

(*
 * Supports alpha only surfaces.  The bit depth of an alpha only surface can be
 * 1,2,4, or 8.  The alpha value becomes more opaque as the alpha value increases.
 * (0 is transparent.)
 * For Blt.
 *)

  DDFXALPHACAPS_BLTALPHASURFACES          = $00000008 ;

(*
 * The depth of the alpha channel data can range can be 1,2,4, or 8.
 * The NEG suffix indicates that this alpha channel becomes more transparent
 * as the alpha value increases. (0 is opaque.)  This flag can only be set if
 * DDCAPS_ALPHA is set.
 * For Blt.
 *)

  DDFXALPHACAPS_BLTALPHASURFACESNEG       = $00000010 ;

(*
 * Supports alpha blending around the edge of a source color keyed surface.
 * For Overlays.
 *)

  DDFXALPHACAPS_OVERLAYALPHAEDGEBLEND     = $00000020 ;

(*
 * Supports alpha information in the pixel format.  The bit depth of alpha 
 * information in the pixel format can be 1,2,4, or 8.  The alpha value becomes
 * more opaque as the alpha value increases.  (0 is transparent.)
 * For Overlays.
 *)

  DDFXALPHACAPS_OVERLAYALPHAPIXELS        = $00000040 ;

(*
 * Supports alpha information in the pixel format.  The bit depth of alpha 
 * information in the pixel format can be 1,2,4, or 8.  The alpha value 
 * becomes more transparent as the alpha value increases.  (0 is opaque.) 
 * This flag can only be set if DDCAPS_ALPHA is set.
 * For Overlays.
 *)

  DDFXALPHACAPS_OVERLAYALPHAPIXELSNEG     = $00000080 ;

(*
 * Supports alpha only surfaces.  The bit depth of an alpha only surface can be
 * 1,2,4, or 8.  The alpha value becomes more opaque as the alpha value increases.
 * (0 is transparent.)
 * For Overlays.
 *)

  DDFXALPHACAPS_OVERLAYALPHASURFACES      = $00000100 ;

(*
 * The depth of the alpha channel data can range can be 1,2,4, or 8.  
 * The NEG suffix indicates that this alpha channel becomes more transparent
 * as the alpha value increases. (0 is opaque.)  This flag can only be set if
 * DDCAPS_ALPHA is set.
 * For Overlays.
 *)

  DDFXALPHACAPS_OVERLAYALPHASURFACESNEG   = $00000200 ;

(****************************************************************************
 *
 * DIRECTDRAW FX CAPABILITY FLAGS
 *
 ****************************************************************************)

(*
 * Uses arithmetic operations to stretch and shrink surfaces during blt
 * rather than pixel doubling techniques.  Along the Y axis.
 *)

  DDFXCAPS_BLTARITHSTRETCHY       = $00000020 ;

(*
 * Uses arithmetic operations to stretch during blt
 * rather than pixel doubling techniques.  Along the Y axis. Only
 * works for x1, x2, etc.
 *)

  DDFXCAPS_BLTARITHSTRETCHYN      = $00000010 ;

(*
 * Supports mirroring left to right in blt.
 *)

  DDFXCAPS_BLTMIRRORLEFTRIGHT     = $00000040 ;

(*
 * Supports mirroring top to bottom in blt.
 *)

  DDFXCAPS_BLTMIRRORUPDOWN        = $00000080 ;

(*
 * Supports arbitrary rotation for blts.
 *)

  DDFXCAPS_BLTROTATION            = $00000100 ;

(*
 * Supports 90 degree rotations for blts.
 *)

  DDFXCAPS_BLTROTATION90          = $00000200 ;

(*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * x axis (horizontal direction) for blts.
 *)

  DDFXCAPS_BLTSHRINKX             = $00000400 ;

(*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the x axis (horizontal direction) for blts.
 *)

  DDFXCAPS_BLTSHRINKXN            = $00000800 ;

(*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * y axis (horizontal direction) for blts.  
 *)

  DDFXCAPS_BLTSHRINKY             = $00001000 ;

(*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the y axis (vertical direction) for blts.
 *)

  DDFXCAPS_BLTSHRINKYN            = $00002000 ;

(*
 * DirectDraw supports arbitrary stretching of a surface along the
 * x axis (horizontal direction) for blts.
 *)

  DDFXCAPS_BLTSTRETCHX            = $00004000 ;

(*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the x axis (horizontal direction) for blts.
 *)

  DDFXCAPS_BLTSTRETCHXN           = $00008000 ;

(*
 * DirectDraw supports arbitrary stretching of a surface along the
 * y axis (horizontal direction) for blts.  
 *)

  DDFXCAPS_BLTSTRETCHY            = $00010000 ;

(*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the y axis (vertical direction) for blts.  
 *)

  DDFXCAPS_BLTSTRETCHYN           = $00020000 ;

(*
 * Uses arithmetic operations to stretch and shrink surfaces during 
 * overlay rather than pixel doubling techniques.  Along the Y axis 
 * for overlays.
 *)

  DDFXCAPS_OVERLAYARITHSTRETCHY   = $00040000 ;

(*
 * Uses arithmetic operations to stretch surfaces during 
 * overlay rather than pixel doubling techniques.  Along the Y axis 
 * for overlays. Only works for x1, x2, etc.
 *)

  DDFXCAPS_OVERLAYARITHSTRETCHYN  = $00000008 ;

(*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * x axis (horizontal direction) for overlays.
 *)

  DDFXCAPS_OVERLAYSHRINKX         = $00080000 ;

(*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the x axis (horizontal direction) for overlays.
 *)

  DDFXCAPS_OVERLAYSHRINKXN        = $00100000 ;

(*
 * DirectDraw supports arbitrary shrinking of a surface along the
 * y axis (horizontal direction) for overlays.  
 *)

  DDFXCAPS_OVERLAYSHRINKY         = $00200000 ;

(*
 * DirectDraw supports integer shrinking (1x,2x,) of a surface
 * along the y axis (vertical direction) for overlays.  
 *)

  DDFXCAPS_OVERLAYSHRINKYN        = $00400000 ;

(*
 * DirectDraw supports arbitrary stretching of a surface along the
 * x axis (horizontal direction) for overlays.
 *)

  DDFXCAPS_OVERLAYSTRETCHX        = $00800000 ;

(*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the x axis (horizontal direction) for overlays.
 *)

  DDFXCAPS_OVERLAYSTRETCHXN       = $01000000 ;

(*
 * DirectDraw supports arbitrary stretching of a surface along the
 * y axis (horizontal direction) for overlays.  
 *)

  DDFXCAPS_OVERLAYSTRETCHY        = $02000000 ;

(*
 * DirectDraw supports integer stretching (1x,2x,) of a surface
 * along the y axis (vertical direction) for overlays.  
 *)

  DDFXCAPS_OVERLAYSTRETCHYN       = $04000000 ;

(*
 * DirectDraw supports mirroring of overlays across the vertical axis
 *)

  DDFXCAPS_OVERLAYMIRRORLEFTRIGHT = $08000000 ;

(*
 * DirectDraw supports mirroring of overlays across the horizontal axis
 *)

  DDFXCAPS_OVERLAYMIRRORUPDOWN    = $10000000 ;

(****************************************************************************
 *
 * DIRECTDRAW STEREO VIEW CAPABILITIES
 *
 ****************************************************************************)

(*
 * The stereo view is accomplished via enigma encoding.
 *)

  DDSVCAPS_ENIGMA                 = $00000001 ;

(*
 * The stereo view is accomplished via high frequency flickering.
 *)

  DDSVCAPS_FLICKER                = $00000002 ;

(*
 * The stereo view is accomplished via red and blue filters applied
 * to the left and right eyes.  All images must adapt their colorspaces
 * for this process.
 *)

  DDSVCAPS_REDBLUE                = $00000004 ;

(*
 * The stereo view is accomplished with split screen technology.
 *)

  DDSVCAPS_SPLIT                  = $00000008 ;

(****************************************************************************
 *
 * DIRECTDRAWPALETTE CAPABILITIES
 *
 ****************************************************************************)

(*
 * Index is 4 bits.  There are sixteen color entries in the palette table.
 *)

  DDPCAPS_4BIT                    = $00000001 ;

(*
 * Index is onto a 8 bit color index.  This field is only valid with the
 * DDPCAPS_1BIT, DDPCAPS_2BIT or DDPCAPS_4BIT capability and the target
 * surface is in 8bpp. Each color entry is one byte long and is an index
 * into destination surface's 8bpp palette.
 *)

  DDPCAPS_8BITENTRIES             = $00000002 ;

(*
 * Index is 8 bits.  There are 256 color entries in the palette table.
 *)

  DDPCAPS_8BIT                    = $00000004 ;

(*
 * Indicates that this DIRECTDRAWPALETTE should use the palette color array
 * passed into the lpDDColorArray parameter to initialize the DIRECTDRAWPALETTE
 * object.
 *)

  DDPCAPS_INITIALIZE              = $00000008 ;

(*
 * This palette is the one attached to the primary surface.  Changing this
 * table has immediate effect on the display unless DDPSETPAL_VSYNC is specified
 * and supported.
 *)

  DDPCAPS_PRIMARYSURFACE          = $00000010 ;

(*
 * This palette is the one attached to the primary surface left.  Changing
 * this table has immediate effect on the display for the left eye unless
 * DDPSETPAL_VSYNC is specified and supported.
 *)

  DDPCAPS_PRIMARYSURFACELEFT      = $00000020 ;

(*
 * This palette can have all 256 entries defined
 *)

  DDPCAPS_ALLOW256                = $00000040 ;

(*
 * This palette can have modifications to it synced with the monitors
 * refresh rate.
 *)

  DDPCAPS_VSYNC                   = $00000080 ;

(*
 * Index is 1 bit.  There are two color entries in the palette table.
 *)

  DDPCAPS_1BIT                    = $00000100 ;

(*
 * Index is 2 bit.  There are four color entries in the palette table.
 *)

  DDPCAPS_2BIT                    = $00000200 ;


(****************************************************************************
 *
 * DIRECTDRAWPALETTE SETENTRY CONSTANTS
 *
 ****************************************************************************)


(****************************************************************************
 *
 * DIRECTDRAWPALETTE GETENTRY CONSTANTS
 *
 ****************************************************************************)

(* 0 is the only legal value *)

(****************************************************************************
 *
 * DIRECTDRAWSURFACE SETPALETTE CONSTANTS
 *
 ****************************************************************************)


(****************************************************************************
 *
 * DIRECTDRAW BITDEPTH CONSTANTS
 *
 * NOTE:  These are only used to indicate supported bit depths.   These
 * are flags only, they are not to be used as an actual bit depth.   The
 * absolute numbers 1, 2, 4, 8, 16, 24 and 32 are used to indicate actual
 * bit depths in a surface or for changing the display mode.
 *
 ****************************************************************************)

(*
 * 1 bit per pixel.
 *)

  DDBD_1                  = $00004000 ;

(*
 * 2 bits per pixel.
 *)

  DDBD_2                  = $00002000 ;

(*
 * 4 bits per pixel.
 *)

  DDBD_4                  = $00001000 ;

(*
 * 8 bits per pixel.
 *)

  DDBD_8                  = $00000800 ;

(*
 * 16 bits per pixel.
 *)

  DDBD_16                 = $00000400 ;

(*
 * 24 bits per pixel.
 *)

  DDBD_24                 = $00000200 ;

(*
 * 32 bits per pixel.
 *)

  DDBD_32                 = $00000100 ;

(****************************************************************************
 *
 * DIRECTDRAWSURFACE SET/GET COLOR KEY FLAGS
 *
 ****************************************************************************)

(*
 * Set if the structure contains a color space.  Not set if the structure
 * contains a single color key.
 *)

  DDCKEY_COLORSPACE       = $00000001 ;

(*
 * Set if the structure specifies a color key or color space which is to be
 * used as a destination color key for blt operations.
 *)

  DDCKEY_DESTBLT          = $00000002 ;

(*
 * Set if the structure specifies a color key or color space which is to be
 * used as a destination color key for overlay operations.
 *)

  DDCKEY_DESTOVERLAY      = $00000004 ;

(*
 * Set if the structure specifies a color key or color space which is to be
 * used as a source color key for blt operations.
 *)

  DDCKEY_SRCBLT           = $00000008 ;

(*
 * Set if the structure specifies a color key or color space which is to be
 * used as a source color key for overlay operations.
 *)

  DDCKEY_SRCOVERLAY       = $00000010 ;


(****************************************************************************
 *
 * DIRECTDRAW COLOR KEY CAPABILITY FLAGS
 *
 ****************************************************************************)

(*
 * Supports transparent blting using a color key to identify the replaceable 
 * bits of the destination surface for RGB colors.
 *)

  DDCKEYCAPS_DESTBLT                      = $00000001 ;

(*
 * Supports transparent blting using a color space to identify the replaceable
 * bits of the destination surface for RGB colors.
 *)

  DDCKEYCAPS_DESTBLTCLRSPACE              = $00000002 ;

(*
 * Supports transparent blting using a color space to identify the replaceable
 * bits of the destination surface for YUV colors.
 *)

  DDCKEYCAPS_DESTBLTCLRSPACEYUV           = $00000004 ;

(*
 * Supports transparent blting using a color key to identify the replaceable 
 * bits of the destination surface for YUV colors.
 *)

  DDCKEYCAPS_DESTBLTYUV                   = $00000008 ;

(*
 * Supports overlaying using colorkeying of the replaceable bits of the surface
 * being overlayed for RGB colors.
 *)

  DDCKEYCAPS_DESTOVERLAY                  = $00000010 ;

(*
 * Supports a color space as the color key for the destination for RGB colors.
 *)

  DDCKEYCAPS_DESTOVERLAYCLRSPACE          = $00000020 ;

(*
 * Supports a color space as the color key for the destination for YUV colors.
 *)

  DDCKEYCAPS_DESTOVERLAYCLRSPACEYUV       = $00000040 ;

(*
 * Supports only one active destination color key value for visible overlay
 * surfaces.
 *)

  DDCKEYCAPS_DESTOVERLAYONEACTIVE         = $00000080 ;

(*
 * Supports overlaying using colorkeying of the replaceable bits of the 
 * surface being overlayed for YUV colors.
 *)

  DDCKEYCAPS_DESTOVERLAYYUV               = $00000100 ;

(*
 * Supports transparent blting using the color key for the source with
 * this surface for RGB colors.
 *)

  DDCKEYCAPS_SRCBLT                       = $00000200 ;

(*
 * Supports transparent blting using a color space for the source with
 * this surface for RGB colors.
 *)

  DDCKEYCAPS_SRCBLTCLRSPACE               = $00000400 ;

(*
 * Supports transparent blting using a color space for the source with
 * this surface for YUV colors.
 *)

  DDCKEYCAPS_SRCBLTCLRSPACEYUV            = $00000800 ;

(*
 * Supports transparent blting using the color key for the source with
 * this surface for YUV colors.
 *)

  DDCKEYCAPS_SRCBLTYUV                    = $00001000 ;

(*
 * Supports overlays using the color key for the source with this
 * overlay surface for RGB colors.
 *)

  DDCKEYCAPS_SRCOVERLAY                   = $00002000 ;

(*
 * Supports overlays using a color space as the source color key for
 * the overlay surface for RGB colors.
 *)

  DDCKEYCAPS_SRCOVERLAYCLRSPACE           = $00004000 ;

(*
 * Supports overlays using a color space as the source color key for
 * the overlay surface for YUV colors.
 *)

  DDCKEYCAPS_SRCOVERLAYCLRSPACEYUV        = $00008000 ;

(*
 * Supports only one active source color key value for visible
 * overlay surfaces.
 *)

  DDCKEYCAPS_SRCOVERLAYONEACTIVE          = $00010000 ;

(*
 * Supports overlays using the color key for the source with this
 * overlay surface for YUV colors.
 *)

  DDCKEYCAPS_SRCOVERLAYYUV                = $00020000 ;

(*
 * there are no bandwidth trade-offs for using colorkey with an overlay
 *)

  DDCKEYCAPS_NOCOSTOVERLAY                = $00040000 ;


(****************************************************************************
 *
 * DIRECTDRAW PIXELFORMAT FLAGS
 *
 ****************************************************************************)

(*
 * The surface has alpha channel information in the pixel format.
 *)

  DDPF_ALPHAPIXELS                        = $00000001 ;

(*
 * The pixel format contains alpha only information
 *)

  DDPF_ALPHA                              = $00000002 ;

(*
 * The FourCC code is valid.
 *)

  DDPF_FOURCC                             = $00000004 ;

(*
 * The surface is 4-bit color indexed.
 *)

  DDPF_PALETTEINDEXED4                    = $00000008 ;

(*
 * The surface is indexed into a palette which stores indices
 * into the destination surface's 8-bit palette.
 *)

  DDPF_PALETTEINDEXEDTO8                  = $00000010 ;

(*
 * The surface is 8-bit color indexed.
 *)

  DDPF_PALETTEINDEXED8                    = $00000020 ;

(*
 * The RGB data in the pixel format structure is valid.
 *)

  DDPF_RGB                                = $00000040 ;

(*
 * The surface will accept pixel data in the format specified
 * and compress it during the write.
 *)

  DDPF_COMPRESSED                         = $00000080 ;

(*
 * The surface will accept RGB data and translate it during
 * the write to YUV data.  The format of the data to be written
 * will be contained in the pixel format structure.  The DDPF_RGB
 * flag will be set. 
 *)

  DDPF_RGBTOYUV                           = $00000100 ;

(*
 * pixel format is YUV - YUV data in pixel format struct is valid
 *)

  DDPF_YUV                                = $00000200 ;

(*
 * pixel format is a z buffer only surface
 *)

  DDPF_ZBUFFER                            = $00000400 ;

(*
 * The surface is 1-bit color indexed.
 *)

  DDPF_PALETTEINDEXED1                    = $00000800 ;

(*
 * The surface is 2-bit color indexed.
 *)

  DDPF_PALETTEINDEXED2                    = $00001000 ;

(*===========================================================================
 *
 *
 * DIRECTDRAW CALLBACK FLAGS
 *
 *
 *==========================================================================*)

(****************************************************************************
 *
 * DIRECTDRAW ENUMSURFACES FLAGS
 *
 ****************************************************************************)

(*
 * Enumerate all of the surfaces that meet the search criterion.
 *)

  DDENUMSURFACES_ALL                      = $00000001 ;

(*
 * A search hit is a surface that matches the surface description.
 *)

  DDENUMSURFACES_MATCH                    = $00000002 ;

(*
 * A search hit is a surface that does not match the surface description.
 *)

  DDENUMSURFACES_NOMATCH                  = $00000004 ;

(*
 * Enumerate the first surface that can be created which meets the search criterion.
 *)

  DDENUMSURFACES_CANBECREATED             = $00000008 ;

(*
 * Enumerate the surfaces that already exist that meet the search criterion.
 *)

  DDENUMSURFACES_DOESEXIST                = $00000010 ;


(****************************************************************************
 *
 * DIRECTDRAW ENUMDISPLAYMODES FLAGS
 *
 ****************************************************************************)

(*
 * Enumerate Modes with different refresh rates.  EnumDisplayModes guarantees
 * that a particular mode will be enumerated only once.  This flag specifies whether
 * the refresh rate is taken into account when determining if a mode is unique.
 *)

  DDEDM_REFRESHRATES                      = $00000001 ;


(****************************************************************************
 *
 * DIRECTDRAW SETCOOPERATIVELEVEL FLAGS
 *
 ****************************************************************************)

(*
 * Exclusive mode owner will be responsible for the entire primary surface.
 * GDI can be ignored. used with DD
 *)

  DDSCL_FULLSCREEN                        = $00000001 ;

(*
 * allow CTRL_ALT_DEL to work while in fullscreen exclusive mode 
 *)

  DDSCL_ALLOWREBOOT                       = $00000002 ;

(*
 * prevents DDRAW from modifying the application window.
 * prevents DDRAW from minimize/restore the application window on activation.
 *)

  DDSCL_NOWINDOWCHANGES                   = $00000004 ;

(*
 * app wants to work as a regular Windows application
 *)

  DDSCL_NORMAL                            = $00000008 ;

(*
 * app wants exclusive access
 *)

  DDSCL_EXCLUSIVE                         = $00000010 ;


(*
 * app can deal with non-windows display modes
 *)

  DDSCL_ALLOWMODEX                        = $00000040 ;


(****************************************************************************
 *
 * DIRECTDRAW BLT FLAGS
 *
 ****************************************************************************)

(*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the destination surface as the alpha channel for this blt.
 *)

  DDBLT_ALPHADEST                         = $00000001 ;

(*
 * Use the dwConstAlphaDest field in the DDBLTFX structure as the alpha channel
 * for the destination surface for this blt.
 *)

  DDBLT_ALPHADESTCONSTOVERRIDE            = $00000002 ;

(*
 * The NEG suffix indicates that the destination surface becomes more
 * transparent as the alpha value increases. (0 is opaque)
 *)

  DDBLT_ALPHADESTNEG                      = $00000004 ;

(*
 * Use the lpDDSAlphaDest field in the DDBLTFX structure as the alpha
 * channel for the destination for this blt.
 *)

  DDBLT_ALPHADESTSURFACEOVERRIDE          = $00000008 ;

(*
 * Use the dwAlphaEdgeBlend field in the DDBLTFX structure as the alpha channel
 * for the edges of the image that border the color key colors.
 *)

  DDBLT_ALPHAEDGEBLEND                    = $00000010 ;

(*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the source surface as the alpha channel for this blt.
 *)

  DDBLT_ALPHASRC                          = $00000020 ;

(*
 * Use the dwConstAlphaSrc field in the DDBLTFX structure as the alpha channel
 * for the source for this blt.
 *)

  DDBLT_ALPHASRCCONSTOVERRIDE             = $00000040 ;

(*
 * The NEG suffix indicates that the source surface becomes more transparent
 * as the alpha value increases. (0 is opaque)
 *)

  DDBLT_ALPHASRCNEG                       = $00000080 ;

(*
 * Use the lpDDSAlphaSrc field in the DDBLTFX structure as the alpha channel
 * for the source for this blt. 
 *)

  DDBLT_ALPHASRCSURFACEOVERRIDE           = $00000100 ;

(*
 * Do this blt asynchronously through the FIFO in the order received.  If
 * there is no room in the hardware FIFO fail the call.
 *)

  DDBLT_ASYNC                             = $00000200 ;

(*
 * Uses the dwFillColor field in the DDBLTFX structure as the RGB color
 * to fill the destination rectangle on the destination surface with.
 *)

  DDBLT_COLORFILL                         = $00000400 ;

(*
 * Uses the dwDDFX field in the DDBLTFX structure to specify the effects
 * to use for the blt.
 *)

  DDBLT_DDFX                              = $00000800 ;

(*
 * Uses the dwDDROPS field in the DDBLTFX structure to specify the ROPS
 * that are not part of the Win32 API.
 *)

  DDBLT_DDROPS                            = $00001000 ;

(*
 * Use the color key associated with the destination surface.
 *)

  DDBLT_KEYDEST                           = $00002000 ;

(*
 * Use the dckDestColorkey field in the DDBLTFX structure as the color key
 * for the destination surface.
 *)

  DDBLT_KEYDESTOVERRIDE                   = $00004000 ;

(*
 * Use the color key associated with the source surface.
 *)

  DDBLT_KEYSRC                            = $00008000 ;

(*
 * Use the dckSrcColorkey field in the DDBLTFX structure as the color key
 * for the source surface.
 *)

  DDBLT_KEYSRCOVERRIDE                    = $00010000 ;

(*
 * Use the dwROP field in the DDBLTFX structure for the raster operation
 * for this blt.  These ROPs are the same as the ones defined in the Win32 API.
 *)

  DDBLT_ROP                               = $00020000 ;

(*
 * Use the dwRotationAngle field in the DDBLTFX structure as the angle
 * (specified in 1/100th of a degree) to rotate the surface.
 *)

  DDBLT_ROTATIONANGLE                     = $00040000 ;

(*
 * Z-buffered blt using the z-buffers attached to the source and destination
 * surfaces and the dwZBufferOpCode field in the DDBLTFX structure as the
 * z-buffer opcode.
 *)

  DDBLT_ZBUFFER                           = $00080000 ;

(*
 * Z-buffered blt using the dwConstDest Zfield and the dwZBufferOpCode field
 * in the DDBLTFX structure as the z-buffer and z-buffer opcode respectively
 * for the destination.
 *)

  DDBLT_ZBUFFERDESTCONSTOVERRIDE          = $00100000 ;

(*
 * Z-buffered blt using the lpDDSDestZBuffer field and the dwZBufferOpCode
 * field in the DDBLTFX structure as the z-buffer and z-buffer opcode
 * respectively for the destination.
 *)

  DDBLT_ZBUFFERDESTOVERRIDE               = $00200000 ;

(*
 * Z-buffered blt using the dwConstSrcZ field and the dwZBufferOpCode field
 * in the DDBLTFX structure as the z-buffer and z-buffer opcode respectively
 * for the source.
 *)

  DDBLT_ZBUFFERSRCCONSTOVERRIDE           = $00400000 ;

(*
 * Z-buffered blt using the lpDDSSrcZBuffer field and the dwZBufferOpCode
 * field in the DDBLTFX structure as the z-buffer and z-buffer opcode
 * respectively for the source.
 *)

  DDBLT_ZBUFFERSRCOVERRIDE                = $00800000 ;

(*
 * wait until the device is ready to handle the blt
 * this will cause blt to not return DDERR_WASSTILLDRAWING
 *)

  DDBLT_WAIT                              = $01000000 ;

(*
 * Uses the dwFillDepth field in the DDBLTFX structure as the depth value
 * to fill the destination rectangle on the destination Z-buffer surface
 * with.
 *)

  DDBLT_DEPTHFILL                         = $02000000 ;


(****************************************************************************
 *
 * BLTFAST FLAGS
 *
 ****************************************************************************)


  DDBLTFAST_NOCOLORKEY                    = $00000000 ;

  DDBLTFAST_SRCCOLORKEY                   = $00000001 ;

  DDBLTFAST_DESTCOLORKEY                  = $00000002 ;

  DDBLTFAST_WAIT                          = $00000010 ;

(****************************************************************************
 *
 * FLIP FLAGS
 *
 ****************************************************************************)


  DDFLIP_WAIT                          = $00000001 ;


(****************************************************************************
 *
 * DIRECTDRAW SURFACE OVERLAY FLAGS
 *
 ****************************************************************************)

(*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the destination surface as the alpha channel for the
 * destination overlay.
 *)

  DDOVER_ALPHADEST                        = $00000001 ;

(*
 * Use the dwConstAlphaDest field in the DDOVERLAYFX structure as the
 * destination alpha channel for this overlay.
 *)

  DDOVER_ALPHADESTCONSTOVERRIDE           = $00000002 ;

(*
 * The NEG suffix indicates that the destination surface becomes more
 * transparent as the alpha value increases. 
 *)

  DDOVER_ALPHADESTNEG                     = $00000004 ;

(*
 * Use the lpDDSAlphaDest field in the DDOVERLAYFX structure as the alpha
 * channel destination for this overlay.
 *)

  DDOVER_ALPHADESTSURFACEOVERRIDE         = $00000008 ;

(*
 * Use the dwAlphaEdgeBlend field in the DDOVERLAYFX structure as the alpha
 * channel for the edges of the image that border the color key colors.
 *)

  DDOVER_ALPHAEDGEBLEND                   = $00000010 ;

(*
 * Use the alpha information in the pixel format or the alpha channel surface
 * attached to the source surface as the source alpha channel for this overlay.
 *)

  DDOVER_ALPHASRC                         = $00000020 ;

(*
 * Use the dwConstAlphaSrc field in the DDOVERLAYFX structure as the source
 * alpha channel for this overlay.
 *)

  DDOVER_ALPHASRCCONSTOVERRIDE            = $00000040 ;

(*
 * The NEG suffix indicates that the source surface becomes more transparent
 * as the alpha value increases.
 *)

  DDOVER_ALPHASRCNEG                      = $00000080 ;

(*
 * Use the lpDDSAlphaSrc field in the DDOVERLAYFX structure as the alpha channel
 * source for this overlay.
 *)

  DDOVER_ALPHASRCSURFACEOVERRIDE          = $00000100 ;

(*
 * Turn this overlay off.
 *)

  DDOVER_HIDE                             = $00000200 ;

(*
 * Use the color key associated with the destination surface.
 *)

  DDOVER_KEYDEST                          = $00000400 ;

(*
 * Use the dckDestColorkey field in the DDOVERLAYFX structure as the color key
 * for the destination surface
 *)

  DDOVER_KEYDESTOVERRIDE                  = $00000800 ;

(*
 * Use the color key associated with the source surface.
 *)

  DDOVER_KEYSRC                           = $00001000 ;

(*
 * Use the dckSrcColorkey field in the DDOVERLAYFX structure as the color key
 * for the source surface.
 *)

  DDOVER_KEYSRCOVERRIDE                   = $00002000 ;

(*
 * Turn this overlay on.
 *)

  DDOVER_SHOW                             = $00004000 ;

(*
 * Add a dirty rect to an emulated overlayed surface.
 *)

  DDOVER_ADDDIRTYRECT                     = $00008000 ;

(*
 * Redraw all dirty rects on an emulated overlayed surface.
 *)

  DDOVER_REFRESHDIRTYRECTS                = $00010000 ;

(*
 * Redraw the entire surface on an emulated overlayed surface.
 *)

  DDOVER_REFRESHALL                      = $00020000 ;


(*
 * Use the overlay FX flags to define special overlay FX
 *)

  DDOVER_DDFX                             = $00080000 ;


(****************************************************************************
 *
 * DIRECTDRAWSURFACE LOCK FLAGS
 *
 ****************************************************************************)

(*
 * The default.  Set to indicate that Lock should return a valid memory pointer
 * to the top of the specified rectangle.  If no rectangle is specified then a
 * pointer to the top of the surface is returned.
 *)

  DDLOCK_SURFACEMEMORYPTR                 = $00000000 ;    // = default

(*
 * Set to indicate that Lock should wait until it can obtain a valid memory
 * pointer before returning.  If this bit is set, Lock will never return 
 * DDERR_WASSTILLDRAWING.
 *)

  DDLOCK_WAIT                             = $00000001 ;

(*
 * Set if an event handle is being passed to Lock.  Lock will trigger the event
 * when it can return the surface memory pointer requested.
 *)

  DDLOCK_EVENT                            = $00000002 ;

(*
 * Indicates that the surface being locked will only be read from.
 *)

  DDLOCK_READONLY                         = $00000010 ;

(*
 * Indicates that the surface being locked will only be written to
 *)

  DDLOCK_WRITEONLY                        = $00000020 ;


(****************************************************************************
 *
 * DIRECTDRAWSURFACE PAGELOCK FLAGS
 *
 ****************************************************************************)

(*
 * No flags defined at present
 *)


(****************************************************************************
 *
 * DIRECTDRAWSURFACE PAGEUNLOCK FLAGS
 *
 ****************************************************************************)

(*
 * No flags defined at present
 *)


(****************************************************************************
 *
 * DIRECTDRAWSURFACE BLT FX FLAGS
 *
 ****************************************************************************)

(*
 * If stretching, use arithmetic stretching along the Y axis for this blt.
 *)

  DDBLTFX_ARITHSTRETCHY                   = $00000001 ;

(*
 * Do this blt mirroring the surface left to right.  Spin the
 * surface around its y-axis.
 *)

  DDBLTFX_MIRRORLEFTRIGHT                 = $00000002 ;

(*
 * Do this blt mirroring the surface up and down.  Spin the surface
 * around its x-axis.
 *)

  DDBLTFX_MIRRORUPDOWN                    = $00000004 ;

(*
 * Schedule this blt to avoid tearing.
 *)

  DDBLTFX_NOTEARING                       = $00000008 ;

(*
 * Do this blt rotating the surface one hundred and eighty degrees.
 *)

  DDBLTFX_ROTATE180                       = $00000010 ;

(*
 * Do this blt rotating the surface two hundred and seventy degrees.
 *)

  DDBLTFX_ROTATE270                       = $00000020 ;

(*
 * Do this blt rotating the surface ninety degrees.
 *)

  DDBLTFX_ROTATE90                        = $00000040 ;

(*
 * Do this z blt using dwZBufferLow and dwZBufferHigh as  range values
 * specified to limit the bits copied from the source surface.
 *)

  DDBLTFX_ZBUFFERRANGE                    = $00000080 ;

(*
 * Do this z blt adding the dwZBufferBaseDest to each of the sources z values
 * before comparing it with the desting z values.
 *)

  DDBLTFX_ZBUFFERBASEDEST                 = $00000100 ;

(****************************************************************************
 *
 * DIRECTDRAWSURFACE OVERLAY FX FLAGS
 *
 ****************************************************************************)

(*
 * If stretching, use arithmetic stretching along the Y axis for this overlay.
 *)

  DDOVERFX_ARITHSTRETCHY                  = $00000001 ;

(*
 * Mirror the overlay across the vertical axis
 *)

  DDOVERFX_MIRRORLEFTRIGHT                = $00000002 ;

(*
 * Mirror the overlay across the horizontal axis
 *)

  DDOVERFX_MIRRORUPDOWN                   = $00000004 ;

(****************************************************************************
 *
 * DIRECTDRAW WAITFORVERTICALBLANK FLAGS
 *
 ****************************************************************************)

(*
 * return when the vertical blank interval begins
 *)

  DDWAITVB_BLOCKBEGIN                     = $00000001 ;

(*
 * set up an event to trigger when the vertical blank begins
 *)

  DDWAITVB_BLOCKBEGINEVENT                = $00000002 ;

(*
 * return when the vertical blank interval ends and display begins
 *)

  DDWAITVB_BLOCKEND                       = $00000004 ;

(****************************************************************************
 *
 * DIRECTDRAW GETFLIPSTATUS FLAGS
 *
 ****************************************************************************)

(*
 * is it OK to flip now?
 *)

  DDGFS_CANFLIP                   = $00000001 ;

(*
 * is the last flip finished?
 *)

  DDGFS_ISFLIPDONE                = $00000002 ;

(****************************************************************************
 *
 * DIRECTDRAW GETBLTSTATUS FLAGS
 *
 ****************************************************************************)

(*
 * is it OK to blt now?
 *)

  DDGBS_CANBLT                    = $00000001 ;

(*
 * is the blt to the surface finished?
 *)

  DDGBS_ISBLTDONE                 = $00000002 ;


(****************************************************************************
 *
 * DIRECTDRAW ENUMOVERLAYZORDER FLAGS
 *
 ****************************************************************************)

(*
 * Enumerate overlays back to front.
 *)

  DDENUMOVERLAYZ_BACKTOFRONT      = $00000000 ;

(*
 * Enumerate overlays front to back
 *)

  DDENUMOVERLAYZ_FRONTTOBACK      = $00000001 ;

(****************************************************************************
 *
 * DIRECTDRAW UPDATEOVERLAYZORDER FLAGS
 *
 ****************************************************************************)

(*
 * Send overlay to front
 *)

  DDOVERZ_SENDTOFRONT             = $00000000 ;

(*
 * Send overlay to back
 *)

  DDOVERZ_SENDTOBACK              = $00000001 ;

(*
 * Move Overlay forward
 *)

  DDOVERZ_MOVEFORWARD             = $00000002 ;

(*
 * Move Overlay backward
 *)

  DDOVERZ_MOVEBACKWARD            = $00000003 ;

(*
 * Move Overlay in front of relative surface
 *)

  DDOVERZ_INSERTINFRONTOF         = $00000004 ;

(*
 * Move Overlay in back of relative surface
 *)

  DDOVERZ_INSERTINBACKOF          = $00000005 ;

(*===========================================================================
 *
 *
 * DIRECTDRAW RETURN CODES
 *
 * The return values from DirectDraw Commands and Surface that return an HRESULT
 * are codes from DirectDraw concerning the results of the action
 * requested by DirectDraw.
 *
 *==========================================================================*)

(*
 * Status is OK
 *
 * Issued by: DirectDraw Commands and all callbacks
 *)

  DD_OK                                  = 0 ;

(****************************************************************************
 *
 * DIRECTDRAW ENUMCALLBACK RETURN VALUES
 *
 * EnumCallback returns are used to control the flow of the DIRECTDRAW and
 * DIRECTDRAWSURFACE object enumerations.   They can only be returned by
 * enumeration callback routines.
 *
 ****************************************************************************)

(*
 * stop the enumeration
 *)

  DDENUMRET_CANCEL                        = 0 ;

(*
 * continue the enumeration
 *)

  DDENUMRET_OK                            = 1 ;

(****************************************************************************
 *
 * DIRECTDRAW ERRORS
 *
 * Errors are represented by negative values and cannot be combined.
 *
 ****************************************************************************)

(*
 * This object is already initialized
 *)
  DDERR_ALREADYINITIALIZED                = $88760000 + 5 ;

(*
 * This surface can not be attached to the requested surface.
 *)
  DDERR_CANNOTATTACHSURFACE               = $88760000 + 10 ;

(*
 * This surface can not be detached from the requested surface.
 *)
  DDERR_CANNOTDETACHSURFACE               = $88760000 + 20 ;

(*
 * Support is currently not available.
 *)
  DDERR_CURRENTLYNOTAVAIL                 = $88760000 + 40 ;

(*
 * An exception was encountered while performing the requested operation
 *)
  DDERR_EXCEPTION                         = $88760000 + 55 ;

(*
 * Generic failure.
 *)

  DDERR_GENERIC                           = E_FAIL ;

(*
 * Height of rectangle provided is not a multiple of reqd alignment
 *)
  DDERR_HEIGHTALIGN                       = $88760000 + 90 ;

(*
 * Unable to match primary surface creation request with existing
 * primary surface.
 *)
  DDERR_INCOMPATIBLEPRIMARY               = $88760000 + 95 ;

(*
 * One or more of the caps bits passed to the callback are incorrect.
 *)
  DDERR_INVALIDCAPS                       = $88760000 + 100 ;

(*
 * DirectDraw does not support provided Cliplist.
 *)

  DDERR_INVALIDCLIPLIST                   = $88760000 + 110 ;

(*
 * DirectDraw does not support the requested mode
 *)

  DDERR_INVALIDMODE                       = $88760000 + 120 ;

(*
 * DirectDraw received a pointer that was an invalid DIRECTDRAW object.
 *)

  DDERR_INVALIDOBJECT                     = $88760000 + 130 ;

(*
 * One or more of the parameters passed to the callback function are
 * incorrect.
 *)


  DDERR_INVALIDPARAMS                     = E_INVALIDARG ;

(*
 * pixel format was invalid as specified
 *)

  DDERR_INVALIDPIXELFORMAT                = $88760000 + 145 ;

(*
 * Rectangle provided was invalid.
 *)

  DDERR_INVALIDRECT                       = $88760000 + 150 ;

(*
 * Operation could not be carried out because one or more surfaces are locked
 *)

  DDERR_LOCKEDSURFACES                    = $88760000 + 160 ;

(*
 * There is no 3D present.
 *)

  DDERR_NO3D                              = $88760000 + 170 ;

(*
 * Operation could not be carried out because there is no alpha accleration
 * hardware present or available.
 *)

  DDERR_NOALPHAHW                         = $88760000 + 180 ;


(*
 * no clip list available
 *)

  DDERR_NOCLIPLIST                        = $88760000 + 205 ;

(*
 * Operation could not be carried out because there is no color conversion
 * hardware present or available.
 *)

  DDERR_NOCOLORCONVHW                     = $88760000 + 210 ;

(*
 * Create function called without DirectDraw object method SetCooperativeLevel
 * being called.
 *)

  DDERR_NOCOOPERATIVELEVELSET             = $88760000 + 212 ;

(*
 * Surface doesn't currently have a color key
 *)

  DDERR_NOCOLORKEY                        = $88760000 + 215 ;

(*
 * Operation could not be carried out because there is no hardware support
 * of the dest color key.
 *)

  DDERR_NOCOLORKEYHW                      = $88760000 + 220 ;

(*
 * No DirectDraw support possible with current display driver
 *)

  DDERR_NODIRECTDRAWSUPPORT               = $88760000 + 222 ;

(*
 * Operation requires the application to have exclusive mode but the
 * application does not have exclusive mode.
 *)

  DDERR_NOEXCLUSIVEMODE                   = $88760000 + 225 ;

(*
 * Flipping visible surfaces is not supported.
 *)

  DDERR_NOFLIPHW                          = $88760000 + 230 ;

(*
 * There is no GDI present.
 *)

  DDERR_NOGDI                             = $88760000 + 240 ;

(*
 * Operation could not be carried out because there is no hardware present
 * or available.
 *)

  DDERR_NOMIRRORHW                        = $88760000 + 250 ;

(*
 * Requested item was not found
 *)

  DDERR_NOTFOUND                          = $88760000 + 255 ;

(*
 * Operation could not be carried out because there is no overlay hardware
 * present or available.
 *)

  DDERR_NOOVERLAYHW                       = $88760000 + 260 ;

(*
 * Operation could not be carried out because there is no appropriate raster
 * op hardware present or available.
 *)

  DDERR_NORASTEROPHW                      = $88760000 + 280 ;

(*
 * Operation could not be carried out because there is no rotation hardware
 * present or available.
 *)

  DDERR_NOROTATIONHW                      = $88760000 + 290 ;

(*
 * Operation could not be carried out because there is no hardware support
 * for stretching
 *)

  DDERR_NOSTRETCHHW                       = $88760000 + 310 ;

(*
 * DirectDrawSurface is not in 4 bit color palette and the requested operation
 * requires 4 bit color palette.
 *)

  DDERR_NOT4BITCOLOR                      = $88760000 + 316 ;

(*
 * DirectDrawSurface is not in 4 bit color index palette and the requested
 * operation requires 4 bit color index palette.
 *)

  DDERR_NOT4BITCOLORINDEX                 = $88760000 + 317 ;

(*
 * DirectDraw Surface is not in 8 bit color mode and the requested operation
 * requires 8 bit color.
 *)

  DDERR_NOT8BITCOLOR                      = $88760000 + 320 ;

(*
 * Operation could not be carried out because there is no texture mapping
 * hardware present or available.
 *)

  DDERR_NOTEXTUREHW                       = $88760000 + 330 ;

(*
 * Operation could not be carried out because there is no hardware support
 * for vertical blank synchronized operations.
 *)

  DDERR_NOVSYNCHW                         = $88760000 + 335 ;

(*
 * Operation could not be carried out because there is no hardware support
 * for zbuffer blting.
 *)

  DDERR_NOZBUFFERHW                       = $88760000 + 340 ;

(*
 * Overlay surfaces could not be z layered based on their BltOrder because
 * the hardware does not support z layering of overlays.
 *)

  DDERR_NOZOVERLAYHW                      = $88760000 + 350 ;

(*
 * The hardware needed for the requested operation has already been
 * allocated.
 *)

  DDERR_OUTOFCAPS                         = $88760000 + 360 ;

(*
 * DirectDraw does not have enough memory to perform the operation.
 *)


  DDERR_OUTOFMEMORY                       = E_OUTOFMEMORY ;

(*
 * DirectDraw does not have enough memory to perform the operation.
 *)

  DDERR_OUTOFVIDEOMEMORY                  = $88760000 + 380 ;

(*
 * hardware does not support clipped overlays
 *)

  DDERR_OVERLAYCANTCLIP                   = $88760000 + 382 ;

(*
 * Can only have ony color key active at one time for overlays
 *)

  DDERR_OVERLAYCOLORKEYONLYONEACTIVE      = $88760000 + 384 ;

(*
 * Access to this palette is being refused because the palette is already
 * locked by another thread.
 *)

  DDERR_PALETTEBUSY                       = $88760000 + 387 ;

(*
 * No src color key specified for this operation.
 *)

  DDERR_COLORKEYNOTSET                    = $88760000 + 400 ;

(*
 * This surface is already attached to the surface it is being attached to.
 *)

  DDERR_SURFACEALREADYATTACHED            = $88760000 + 410 ;

(*
 * This surface is already a dependency of the surface it is being made a
 * dependency of.
 *)

  DDERR_SURFACEALREADYDEPENDENT           = $88760000 + 420 ;

(*
 * Access to this surface is being refused because the surface is already
 * locked by another thread.
 *)

  DDERR_SURFACEBUSY                       = $88760000 + 430 ;

(*
 * Access to this surface is being refused because no driver exists
 * which can supply a pointer to the surface.
 * This is most likely to happen when attempting to lock the primary
 * surface when no DCI provider is present.
 *)

  DDERR_CANTLOCKSURFACE                   = $88760000 + 435 ;

(*
 * Access to Surface refused because Surface is obscured.
 *)

  DDERR_SURFACEISOBSCURED                 = $88760000 + 440 ;

(*
 * Access to this surface is being refused because the surface is gone.
 * The DIRECTDRAWSURFACE object representing this surface should
 * have Restore called on it.
 *)

  DDERR_SURFACELOST                       = $88760000 + 450 ;

(*
 * The requested surface is not attached.
 *)

  DDERR_SURFACENOTATTACHED                = $88760000 + 460 ;

(*
 * Height requested by DirectDraw is too large.
 *)

  DDERR_TOOBIGHEIGHT                      = $88760000 + 470 ;

(*
 * Size requested by DirectDraw is too large --  The individual height and
 * width are OK.
 *)

  DDERR_TOOBIGSIZE                        = $88760000 + 480 ;

(*
 * Width requested by DirectDraw is too large.
 *)

  DDERR_TOOBIGWIDTH                       = $88760000 + 490 ;

(*
 * Action not supported.
 *)


  DDERR_UNSUPPORTED                       = E_NOTIMPL ;

(*
 * FOURCC format requested is unsupported by DirectDraw
 *)

  DDERR_UNSUPPORTEDFORMAT                 = $88760000 + 510 ;

(*
 * Bitmask in the pixel format requested is unsupported by DirectDraw
 *)

  DDERR_UNSUPPORTEDMASK                   = $88760000 + 520 ;

(*
 * vertical blank is in progress
 *)

  DDERR_VERTICALBLANKINPROGRESS           = $88760000 + 537 ;

(*
 * Informs DirectDraw that the previous Blt which is transfering information
 * to or from this Surface is incomplete.
 *)

  DDERR_WASSTILLDRAWING                   = $88760000 + 540 ;

(*
 * Rectangle provided was not horizontally aligned on reqd. boundary
 *)

  DDERR_XALIGN                            = $88760000 + 560 ;

(*
 * The GUID passed to DirectDrawCreate is not a valid DirectDraw driver
 * identifier.
 *)

  DDERR_INVALIDDIRECTDRAWGUID             = $88760000 + 561 ;

(*
 * A DirectDraw object representing this driver has already been created
 * for this process.
 *)

  DDERR_DIRECTDRAWALREADYCREATED          = $88760000 + 562 ;

(*
 * A hardware only DirectDraw object creation was attempted but the driver
 * did not support any hardware.
 *)

  DDERR_NODIRECTDRAWHW                    = $88760000 + 563 ;

(*
 * this process already has created a primary surface
 *)

  DDERR_PRIMARYSURFACEALREADYEXISTS       = $88760000 + 564 ;

(*
 * software emulation not available.
 *)

  DDERR_NOEMULATION                       = $88760000 + 565 ;

(*
 * region passed to Clipper::GetClipList is too small.
 *)

  DDERR_REGIONTOOSMALL                    = $88760000 + 566 ;

(*
 * an attempt was made to set a clip list for a clipper objec that
 * is already monitoring an hwnd.
 *)

  DDERR_CLIPPERISUSINGHWND                = $88760000 + 567 ;

(*
 * No clipper object attached to surface object
 *)

  DDERR_NOCLIPPERATTACHED                 = $88760000 + 568 ;

(*
 * Clipper notification requires an HWND or
 * no HWND has previously been set as the CooperativeLevel HWND.
 *)

  DDERR_NOHWND                            = $88760000 + 569 ;

(*
 * HWND used by DirectDraw CooperativeLevel has been subclassed,
 * this prevents DirectDraw from restoring state.
 *)

  DDERR_HWNDSUBCLASSED                    = $88760000 + 570 ;

(*
 * The CooperativeLevel HWND has already been set.
 * It can not be reset while the process has surfaces or palettes created.
 *)

  DDERR_HWNDALREADYSET                    = $88760000 + 571 ;

(*
 * No palette object attached to this surface.
 *)

  DDERR_NOPALETTEATTACHED                 = $88760000 + 572 ;

(*
 * No hardware support for 16 or 256 color palettes.
 *)

  DDERR_NOPALETTEHW                       = $88760000 + 573 ;

(*
 * If a clipper object is attached to the source surface passed into a
 * BltFast call.
 *)

  DDERR_BLTFASTCANTCLIP                   = $88760000 + 574 ;

(*
 * No blter.
 *)

  DDERR_NOBLTHW                           = $88760000 + 575 ;

(*
 * No DirectDraw ROP hardware.
 *)

  DDERR_NODDROPSHW                        = $88760000 + 576 ;

(*
 * returned when GetOverlayPosition is called on a hidden overlay
 *)

  DDERR_OVERLAYNOTVISIBLE                 = $88760000 + 577 ;

(*
 * returned when GetOverlayPosition is called on a overlay that UpdateOverlay
 * has never been called on to establish a destionation.
 *)

  DDERR_NOOVERLAYDEST                     = $88760000 + 578 ;

(*
 * returned when the position of the overlay on the destionation is no longer
 * legal for that destionation.
 *)

  DDERR_INVALIDPOSITION                   = $88760000 + 579 ;

(*
 * returned when an overlay member is called for a non-overlay surface
 *)

  DDERR_NOTAOVERLAYSURFACE                = $88760000 + 580 ;

(*
 * An attempt was made to set the cooperative level when it was already
 * set to exclusive.
 *)

  DDERR_EXCLUSIVEMODEALREADYSET           = $88760000 + 581 ;

(*
 * An attempt has been made to flip a surface that is not flippable.
 *)

  DDERR_NOTFLIPPABLE                      = $88760000 + 582 ;

(*
 * Can't duplicate primary & 3D surfaces, or surfaces that are implicitly
 * created.
 *)

  DDERR_CANTDUPLICATE                     = $88760000 + 583 ;

(*
 * Surface was not locked.  An attempt to unlock a surface that was not
 * locked at all, or by this process, has been attempted.
 *)

  DDERR_NOTLOCKED                         = $88760000 + 584 ;

(*
 * Windows can not create any more DCs
 *)

  DDERR_CANTCREATEDC                      = $88760000 + 585 ;

(*
 * No DC was ever created for this surface.
 *)

  DDERR_NODC                              = $88760000 + 586 ;

(*
 * This surface can not be restored because it was created in a different
 * mode.
 *)

  DDERR_WRONGMODE                         = $88760000 + 587 ;

(*
 * This surface can not be restored because it is an implicitly created
 * surface.
 *)

  DDERR_IMPLICITLYCREATED                 = $88760000 + 588 ;

(*
 * The surface being used is not a palette-based surface
 *)

  DDERR_NOTPALETTIZED                     = $88760000 + 589 ;

(*
 * The display is currently in an unsupported mode
 *)

  DDERR_UNSUPPORTEDMODE                   = $88760000 + 590 ;

(*
 * Operation could not be carried out because there is no mip-map
 * texture mapping hardware present or available.
 *)

  DDERR_NOMIPMAPHW                        = $88760000 + 591 ;

(*
 * The requested action could not be performed because the surface was of
 * the wrong type.
 *)

  DDERR_INVALIDSURFACETYPE                = $88760000 + 592 ;

(*
 * A DC has already been returned for this surface. Only one DC can be
 * retrieved per surface.
 *)

  DDERR_DCALREADYCREATED                  = $88760000 + 620 ;

(*
 * The attempt to page lock a surface failed.
 *)

  DDERR_CANTPAGELOCK                      = $88760000 + 640 ;

(*
 * The attempt to page unlock a surface failed.
 *)

  DDERR_CANTPAGEUNLOCK                    = $88760000 + 660 ;

(*
 * An attempt was made to page unlock a surface with no outstanding page locks.
 *)

  DDERR_NOTPAGELOCKED                     = $88760000 + 680 ;

(*
 * An attempt was made to invoke an interface member of a DirectDraw object
 * created by CoCreateInstance() before it was initialized.
 *)

  DDERR_NOTINITIALIZED                    = CO_E_NOTINITIALIZED ;

(* Alpha bit depth constants *)

(*
 * API's
 *
 * BWS: Note that UNICODE versions of some functions were dropped
 * during translation
 *)

type
  LPDDENUMCALLBACK = function ( lpGUID: PGUID ; lpDriverDescription: LPSTR ;
      lpDriverName: LPSTR ; lpContext: Pointer ): BOOL ;

const
  REGSTR_KEY_DDHW_DESCRIPTION = 'Description' ;
  REGSTR_KEY_DDHW_DRIVERNAME  = 'DriverName' ;
  REGSTR_PATH_DDHW            = 'Hardware\DirectDrawDrivers' ;

  DDCREATE_HARDWAREONLY       = $00000001 ;
  DDCREATE_EMULATIONONLY      = $00000002 ;

function DirectDrawEnumerate ( lpCallback: LPDDENUMCALLBACK ;
    lpContext: Pointer ): HRESULT ; stdcall ;
function DirectDrawCreate ( lpGUID: PGUID ; var lplpDD: IDirectDraw ;
    pUnkOuter: IUnknown ): HRESULT ; stdcall ;
function DirectDrawCreateClipper ( dwFlags: DWORD ;
    var lplpDDClipper: IDirectDrawClipper ;
    pUnkOuter: IUnknown ): HRESULT ; stdcall ;

// #ifdef WINNT
// function NtDirectDrawCreate ( lpGUID: PGUID ; var lplpDD: THandle ;
//     pUnkOuter: IUnknown ): HRESULT ; stdcall ;
// #endif

implementation

function DirectDrawEnumerate ; external 'DDRAW.DLL' name 'DirectDrawEnumerateA' ;
function DirectDrawCreate ; external 'DDRAW.DLL' ;
function DirectDrawCreateClipper ; external 'DDRAW.DLL' ;
// function NtDirectDrawCreate ; external 'DDRAW.DLL' ;

end.

