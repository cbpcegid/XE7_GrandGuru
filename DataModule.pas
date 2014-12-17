unit DataModule;

interface

uses
  System.SysUtils, System.Classes, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, FMX.Types, JSON, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, FMX.Graphics;

type
  IItemManager = interface
  ['{8D045BCF-EA3B-4DD1-B2DD-6A96817A9A96}']
    procedure ClearItem;
    procedure UpdateItem( aJSon : TJSONValue);
  end;

  IProductManager = interface( IItemManager)
  ['{A621F290-A97B-419F-91CB-B4BB09C7E333}']
  end;

  ICustomerManager = interface( IItemManager)
  ['{101F8D82-93E9-43DE-9781-F0F33556D89F}']
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
    FCustomer : ICustomerManager;
    FProduct : IProductManager;

    procedure Update( aResponse : TRESTResponse; aManager : IItemManager);
  public
    constructor Create( aProductManager : IProductManager; aCustomerManager : ICustomerManager); reintroduce;
    procedure LoadImage( aUrl : String; var aStream : TMemoryStream);
  end;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

{ TdmData }

constructor TdmData.Create(aProductManager: IProductManager;
  aCustomerManager: ICustomerManager);
begin
  inherited Create( nil);
  FProduct := aProductManager;
  FCustomer := aCustomerManager;
end;

procedure TdmData.LoadImage(aUrl: String; var aStream: TMemoryStream);
begin
  aStream.Clear;
  idImgLoader.Get( aUrl, aStream);
end;

procedure TdmData.TimerTimer(Sender: TObject);
begin
  GetProductRequest.Execute;
  Update( GetProductResponse, FProduct);

  GetCustomerRequest.Execute;
  Update( GetCustomerResponse, FCustomer);
end;

procedure TdmData.Update(aResponse: TRESTResponse; aManager: IItemManager);
begin
  if not( aResponse.StatusCode = 200) then exit;
  if aResponse.JSONText = 'null' then aManager.ClearItem else aManager.UpdateItem( aResponse.JSONValue);
end;


end.
