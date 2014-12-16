unit DataModule;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Types, JSON, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, FMX.Graphics;

type
  TItemUpdater = procedure ( aJSon : TJSONValue) of object;
  TClearMethod = procedure of object;

  IMain = interface
  ['{B9603B01-F571-4EF9-95E4-E919EA6296CF}']
    function UpdateProduct : TItemUpdater;
    function UpdateCustomer : TItemUpdater;
    function ClearProduct : TClearMethod;
    function ClearCustomer : TClearMethod;
  end;

  TdmData = class(TDataModule)
    Timer: TTimer;
    KanguruClient: TRESTClient;
    GetProductRequest: TRESTRequest;
    GetProductResponse: TRESTResponse;
    idImgLoader: TIdHTTP;
    GetCustomerRequest: TRESTRequest;
    GetCustomerResponse: TRESTResponse;
    procedure TimerTimer(Sender: TObject);
  private
    FMain : IMain;
    procedure Update( aResponse : TRESTResponse; aUpdater : TItemUpdater; aClearer : TClearMethod);
  public
    constructor Create( aMain : IMain); reintroduce;
    procedure LoadImage( aUrl : String; var aStream : TMemoryStream);
  end;

var
  dmData: TdmData;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TdmData }

constructor TdmData.Create(aMain: IMain);
begin
  inherited Create( nil);
  FMain := aMain;
end;

procedure TdmData.LoadImage(aUrl: String; var aStream: TMemoryStream);
begin
  aStream.Clear;
  idImgLoader.Get( aUrl, aStream);
end;

procedure TdmData.TimerTimer(Sender: TObject);
begin
  GetProductRequest.Execute;
  Update( GetProductResponse, FMain.UpdateProduct, FMain.ClearProduct);

  GetCustomerRequest.Execute;
  Update( GetCustomerResponse, FMain.UpdateCustomer, FMain.ClearCustomer);
end;

procedure TdmData.Update(aResponse: TRESTResponse; aUpdater: TItemUpdater;
  aClearer: TClearMethod);
begin
  if not( aResponse.StatusCode = 200) then exit;

  if aResponse.JSONText = 'null' then aClearer else aUpdater( aResponse.JSONValue);
end;

end.
