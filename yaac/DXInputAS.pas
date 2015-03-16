unit DXInputAS;  // 15-MAR-99 as (Arne Schäpers)
{ Einfache Hilfsklassen für DirectInput - wie üblich
  Minimalismus pur.

  DirectInput-Objekte für Tastatur und Maus (DIKeyboard, DIMouse)
  werden per Initialization erzeugt, DIJoy1 (und evtl. DIJoy2)
  erst auf Anforderung (Routine CreateJoysticks bzw. Thread
  TDIJoyEnumerator mit Callback)
}

interface
uses Windows, SysUtils, Forms, Classes, DInput;

type
  TDIDevice = class(TComponent)
  private
    FCoopLevel: Cardinal; CoopLevelChanged: Boolean;
    FElements: TList;  // EnumObjects
    FProductName: String;  // GetDeviceInfo, tszProductName
  protected
    procedure SetCoopLevel(Value: Cardinal);
    // nur intern aufgerufen. Wer hier eigene GUIDs einsetzen
    // will, braucht eh eine weitere Ableitung wg. Data
    procedure CreateDIObject(GUID: TGUID; Dataformat: PDIDataFormat);
    function GetElementCount: Integer;
    function GetElements(Index: Integer): PDIDeviceObjectInstance;
  public
    DIObject: IDirectInputDevice2;
    DICaps: TDIDevCaps;  // bei Create gesetzt
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Acquire: HResult; // = SetCooperativeLevel, Acquire
    procedure Unacquire;
    function Poll: HResult;  // = Acquire, Poll
    // Bereiche und Einzelwerte: dwType = ID des Geräteteils
    // oder -1 für das gesamte Gerät
    function SetRangeProperty(PropGUID: PGUID;
      Min,Max, dwType: Integer): HResult;
    function SetDWordProperty(PropGUID: PGUID;
      Value, dwType: Integer): HResult;
    // wird erst beim nächsten Acquire/Poll eingesetzt
    property CooperativeLevel: Cardinal read FCoopLevel
       write SetCoopLevel;
    property ProductName: String read FProductName;
    // Geräteteile und Informationen darüber (EnumObjects)
    property ElementCount: Integer read GetElementCount;
    property Elements[Index: Integer]: PDIDeviceObjectInstance
      read GetElements;
  end;

  TDIKeyboard = class(TDIDevice)
    public
      Data: TDIKeyboardState;
    public
      constructor Create(AOwner: TComponent); override;
      function Poll: HResult;  // = inherited + GetDeviceState
    end;

  TDIMouse = class(TDIDevice)
    public
      Data: TDIMouseState;
    public
      constructor Create(AOwner: TComponent); override;
      function Poll: HResult; // = inherited + GetDeviceState
    end;

  TDIJoy = class(TDIDevice)
     private
       FGUID: TGUID;
       FForceFeedback: Boolean;
     protected
       procedure SetGUID(const GUID: TGUID);
     public
       Data: TDIJoyState;
    public
      constructor Create(AOwner: TComponent); override;
      property GUID: TGUID read FGUID write SetGUID;
      function Poll: HResult;
      property ForceFeedback: Boolean read FForceFeedback;
    end;

  // Abzählen von Joysticks im Hintergrund
  TDIJoyEnumerator = class(TThread)
    protected
      FCallback: TNotifyEvent;
      procedure DoCallback;  // Synchronize
      procedure Execute; override;
    public
      JoyCount: Integer;
      constructor Create(Callback: TNotifyEvent);
  end;


function CheckDIRes(Res: HResult; const Msg: String): Boolean;
function CreateJoysticks: Integer;

// Makro für Einzelwerte, läuft über die ID (Element[x].dwType);
// ObjType-1 = DIPH_DEVICE, d.h. gesamtes Gerät
function PropDWord(Value, ObjType: Integer): TDIPropDWord;
// Makro für Bereiche, läuft ebenfalls über die ID
function PropRange(vMin,vMax,ObjType: Integer): TDIPropRange;

// Create: Initialization, Destroy: Finalization
var
  DirectInput: IDirectInput2;
  DIKeyboard: TDIKeyboard;
  DIMouse: TDIMouse;
  // Erst nach expliziter Anforderung per CreateJoysticks/Thread
  DIJoy1, DIJoy2: TDIJoy;

implementation

procedure CheckDIInit;
begin
  if DirectInput = nil then
    raise Exception.Create('DirectInput not initialized');
end;

function CheckDIRes(Res: HResult; const Msg: String): Boolean;
begin
  Result := SUCCEEDED(Res);
  if not Result then raise Exception.Create(Msg+': '+ErrorString(Res));
end;

constructor TDIDevice.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FElements := TList.Create;
  CooperativeLevel := DISCL_BACKGROUND or DISCL_NONEXCLUSIVE;
end;

destructor TDIDevice.Destroy;
var x: Integer;
begin
  if DIObject <> nil then Unacquire;
  DIObject := nil;  // doppelt genäht hält besser
  for x := 0 to FElements.Count-1 do
    Dispose(PDIDeviceObjectInstance(FElements[x]));
  FElements.Free;
end;

function TDIDevice.GetElementCount: Integer;
begin
  Result := FElements.Count;
end;

function TDIDevice.GetElements(Index: Integer): PDIDeviceObjectInstance;
begin
  Result := FElements[Index];
end;

procedure TDIDevice.SetCoopLevel(Value: Cardinal);
begin
  if Value <> FCoopLevel then CoopLevelChanged := True;
  FCoopLevel := Value;
end;

function TDIDevice.Acquire: HResult;
begin
  if CoopLevelChanged then
  begin
    DIObject.Unacquire;  // DInput weigert sich sonst
    CheckDIRes(DIObject.SetCooperativeLevel
     (Application.MainForm.Handle, CooperativeLevel),
     'SetCooperativeLevel');
    CoopLevelChanged := False;
  end;
  Result := DIObject.Acquire;
end;

procedure TDIDevice.Unacquire;
begin
  DIObject.Unacquire;
end;

function TDIDevice.Poll: HResult;
begin
  Result := Acquire;
  // kein Test auf DIDC_POLLEDDEVICE, das macht Poll
  // sowie noch einmal
  if SUCCEEDED(Result) and (DICaps.dwFlags and DIDC_POLLEDDEVICE <> 0)
    then Result := DIObject.Poll;
end;

// Makro für Einzelwerte, läuft über die ID (Element[x].dwType)
function PropDWord(Value, ObjType: Integer): TDIPropDWord;
begin
  FillChar(Result,SizeOf(Result),0);
  Result.dwData := Value;
  with Result.diph do
  begin
    dwSize := SizeOf(Result); dwHeaderSize := SizeOf(Result.diph);
    if ObjType = -1 then dwHow := DIPH_DEVICE  // dwObj = 0
    else
    begin
      dwHow := DIPH_BYID; dwObj := ObjType;
    end;
  end;
end;

// Makro für Bereiche, läuft ebenfalls über die ID
function PropRange(vMin,vMax,ObjType: Integer): TDIPropRange;
begin
  FillChar(Result,SizeOf(Result),0);
  Result.lMin := vMin; Result.lMax := vMax;
  with Result.diph do
  begin
    dwSize := SizeOf(Result); dwHeaderSize := SizeOf(Result.diph);
    if ObjType = -1 then dwHow := DIPH_DEVICE  // dwObj = 0
    else
    begin
      dwHow := DIPH_BYID; dwObj := ObjType;
    end;
  end;
end;

function TDIDevice.SetRangeProperty(PropGUID: PGUID; Min,Max,dwType: Integer): HResult;
begin
  Result := DIObject.SetProperty(PropGUID,PropRange(Min,Max,dwType).diph);
end;

function TDIDevice.SetDWordProperty(PropGUID: PGUID; Value, dwType: Integer): HResult;
begin
  Result := DIObject.SetProperty(PropGUID,PropDWord(Value,dwType).diph);
end;

function DIElemEnumProc(var lpddoi: TDIDeviceObjectInstance;
  pvRef: Pointer): Integer; stdcall;
var NewElem: PDIDeviceObjectInstance;
begin
  New(NewElem); NewElem^ := lpddoi; TList(pvRef).Add(NewElem);
  Result := DIENUM_CONTINUE; // = 1. TRUE wäre $FFFFFFFF;
end;

procedure TDIDevice.CreateDIObject(GUID: TGUID; DataFormat: PDIDataFormat);
var DIDevice1: IDirectInputDevice; DevInfo: TDiDeviceInstance;
begin
  CheckDIInit;
  CheckDIRes(DirectInput.CreateDevice(GUID,DIDevice1,nil),'CreateDevice');
  CheckDIRes(DIDevice1.QueryInterface(IID_IDirectInputDevice2,DIObject),
    'QueryInterface for DirectInputDevice2');
  DICaps.dwSize := SizeOf(DICaps);
  CheckDIRes(DIObject.GetCapabilities(DICaps),'DIDevice.GetCapabilities');
  CheckDIRes(DIObject.SetDataFormat(DataFormat^),'SetDataFormat');
  CheckDIRes(DIObject.EnumObjects(DIElemEnumProc,FElements,DIDFT_ALL),'EnumObjects');
  DevInfo.dwSize := SizeOf(DevInfo);
  CheckDIRes(DIObject.GetDeviceInfo(DevInfo),'GetDeviceInfo');
  FProductName := StrPas(DevInfo.tszProductName);
end;

constructor TDIKeyboard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateDIObject(Guid_SysKeyboard,@c_dfDIKeyboard);
end;

function TDIKeyboard.Poll: HResult;
begin
  Result := inherited Poll;
  if SUCCEEDED(Result) then
    Result := DIObject.GetDeviceState(SizeOf(Data),@Data);
end;

constructor TDIMouse.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateDIObject(Guid_SysMouse,@c_dfDIMouse);
end;

function TDIMouse.Poll: HResult;
begin
  Result := inherited Poll;
  if SUCCEEDED(Result) then
    Result := DIObject.GetDeviceState(SizeOf(Data),@Data);
end;

constructor TDIJoy.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CooperativeLevel := DISCL_FOREGROUND or DISCL_EXCLUSIVE;
end;

procedure TDIJoy.SetGUID(const GUID: TGUID);
begin
  FGUID := GUID;
  CreateDIObject(FGUID, @c_dfDIJoystick);
  FForceFeedback := DiCaps.dwFlags and DIDC_FORCEFEEDBACK <> 0;
end;

function TDIJoy.Poll: HResult;
begin
  Result := inherited Poll;
  if SUCCEEDED(Result) then
    Result := DIObject.GetDeviceState(SizeOf(Data),@Data);
end;

function EnumDevicesCallback(var lpddi: TDIDeviceInstance;
    pvRef: Pointer): Integer; stdcall;
begin
  if DIJoy1 = nil then
  begin
    DIJoy1 := TDIJoy.Create(Application);
    DIJoy1.SetGUID(lpddi.guidInstance);
  end else if DIJoy2 = nil then
  begin
    DIJoy2 := TDIJoy.Create(Application);
    DIJoy2.SetGUID(lpddi.guidInstance);
  end;
  Inc(PInteger(pvRef)^);
  if DIJoy2 <> nil then Result := DIENUM_STOP
    else Result := DIENUM_CONTINUE;
end;

function CreateJoysticks: Integer;
begin
  Result := 0; if DirectInput = nil then Exit;
  if DIJoy1 <> nil then raise Exception.Create('CreateJoysticks called twice');
  DirectInput.EnumDevices(DIDEVTYPE_JOYSTICK, EnumDevicesCallback, @Result, DIEDFL_ATTACHEDONLY);
end;

// Thread-Wrapper für Abzählungen im Hintergrund
constructor TDIJoyEnumerator.Create(Callback: TNotifyEvent);
begin
  inherited Create(False); FreeOnTerminate := True;
  FCallback := Callback;
  Suspended := False;
end;

procedure TDIJoyEnumerator.Execute;
begin
  JoyCount := CreateJoysticks;
  Synchronize(DoCallback);
end;

procedure TDIJoyEnumerator.DoCallback;
begin
  if Assigned(FCallback) then FCallback(Self);
end;

procedure CreateDirectInput;
var DI1: IDirectInput;
begin
  if not Assigned(DirectInputCreate) then Exit;
  if SUCCEEDED(DirectInputCreate(hInstance,DIRECTINPUT_VERSION,DI1,nil)) then
    DI1.QueryInterface(IID_IDirectInput2,DirectInput);
end;

initialization
  CreateDirectInput;
  if DirectInput <> nil then
  begin
    DIKeyboard := TDIKeyboard.Create(Application);
    DIMouse := TDIMouse.Create(Application);
  end;

finalization
  DirectInput := nil;
end.
