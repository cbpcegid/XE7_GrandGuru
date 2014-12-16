unit DataModule;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Types, JSON, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, FMX.Graphics;

type
  IMain = interface
  ['{B9603B01-F571-4EF9-95E4-E919EA6296CF}']
    procedure UpdateProduct ( aProduct : TJSONValue);
    procedure UpdateCustomer ( aCustomer : TJSONValue);
    function ImgProduct : TBitmap;
    procedure ClearProduct;
    procedure ClearCustomer;
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
  if (GetProductRequest.Response.StatusCode = 200) then begin
//    Timer.Enabled := False;
    if not( GetProductResponse.JSONText = 'null') then FMain.UpdateProduct( GetProductResponse.JSONValue)
    else FMain.ClearProduct;
  end;

  GetCustomerRequest.Execute;
  if (GetCustomerRequest.Response.StatusCode = 200) then begin
//    Timer.Enabled := False;
    if not( GetCustomerResponse.JSONText = 'null') then FMain.UpdateCustomer( GetCustomerResponse.JSONValue)
    else FMain.ClearCustomer;
  end;
end;

end.
