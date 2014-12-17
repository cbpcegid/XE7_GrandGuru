unit ProductForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  DataModule, FMX.StdCtrls, FMX.Objects, FMX.ListView.Types, FMX.ListView, JSON;

type
  TfrmProduct = class(TForm, ICustomerManager, IProductManager)
    lstItems: TListView;
    lbSuggestions: TLabel;
    rcSuggestions: TRectangle;
    lbVoucherCredit: TLabel;
    lbCustomerName: TLabel;
    lbBonAchat: TLabel;
    lbVotrePrix: TLabel;
    lbFinalPrice: TLabel;
    rcCustomer: TRectangle;
    rcSuggestTop: TRectangle;
    rcDetail: TRectangle;
    imgProd: TImageControl;
    lbProdName: TLabel;
    lbPrixMagasin: TLabel;
    lbPrice: TLabel;
    rcCustomerCadre: TRectangle;
    rcSuggestCenter: TRectangle;
    rcLstHook: TRectangle;
    rcCadre: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fDM : TdmData;
    FproductId : Integer;
    FcustomerId : Integer;
    FProductPrice : Double;
    FCustomerVoucher : Double;

    procedure VisibleProduct( aVisible : Boolean);
    procedure VisibleCustomer( aVisible : Boolean);
    procedure VisibleFinalPrice( aVisible : Boolean);

    procedure UpdateFinalPrice;

    procedure UpdateProduct( aProduct : TJSONValue);
    procedure UpdateCustomer( aCustomer : TJSONValue);
    procedure ClearProduct;
    procedure ClearCustomer;
    {ICustomerManager}
    procedure ICustomerManager.UpdateItem = UpdateCustomer;
    procedure ICustomerManager.ClearItem = ClearCustomer;
    {IProductManager}
    procedure IProductManager.UpdateItem = UpdateProduct;
    procedure IProductManager.ClearItem = ClearProduct;
  public
  end;

var
  frmProduct: TfrmProduct;

implementation

uses Math;

{$R *.fmx}


procedure TfrmProduct.ClearProduct;
begin
  VisibleProduct( False);
  lstItems.Items.Clear;
  FproductId := -1;
  FProductPrice := 0.0;
end;

procedure TfrmProduct.ClearCustomer;
begin
  VisibleCustomer( False);
  FcustomerId := -1;
  FCustomerVoucher := 0.0;
end;

procedure TfrmProduct.FormCreate(Sender: TObject);
begin
  fDM := TdmData.Create( Self, Self);
  ClearProduct;
  ClearCustomer;
end;

procedure TfrmProduct.FormDestroy(Sender: TObject);
begin
  fDM.Free;
end;

procedure TfrmProduct.UpdateCustomer(aCustomer: TJSONValue);
begin
  if aCustomer.GetValue<integer>( 'Id') = FcustomerId then exit;

  FcustomerId := aCustomer.GetValue<integer>( 'Id');
  FCustomerVoucher := StrToFloat( aCustomer.GetValue<string>( 'LoyaltyVoucher'), TFormatSettings.Create('en-US'));

  lbCustomerName.Text := Format('%s %s', [aCustomer.GetValue<string>( 'FirstName'), aCustomer.GetValue<string>( 'LastName')]);
  lbVoucherCredit.Text := Format('%f €', [ FCustomerVoucher]);

  UpdateFinalPrice;

  VisibleCustomer( True);
end;

procedure TfrmProduct.UpdateFinalPrice;
var b : Boolean;
begin
  b := not(( Fcustomerid = -1) or( FproductId = -1));
  VisibleFinalPrice( b);
  if b then lbFinalPrice.Text := Format( '%f €',[ Max( 0, FProductPrice - FCustomerVoucher)]);
end;

procedure TfrmProduct.UpdateProduct(aProduct: TJSONValue);
var A : TJSONArray;
    i : Integer;
    M : TMemoryStream;
begin
  if aProduct.GetValue<integer>( 'Id') = FproductId then exit;

  FproductId := aProduct.GetValue<integer>( 'Id');

  M := TMemoryStream.Create;
  try
    lbProdName.Text := aProduct.GetValue<string>( 'Name');
    FProductPrice := StrToFloat( aProduct.GetValue<string>( 'Price'), TFormatSettings.Create('en-US'));

    lbPrice.Text := Format( '%f €', [ FProductPrice]);
    fDM.LoadImage( aProduct.GetValue<string>( 'ImageUri'), M);
    imgProd.Bitmap.LoadFromStream( M);

    A := aProduct.GetValue<TJSONArray>( 'RelatedProducts');

    lstItems.Items.Clear;
    for i := 0 to A.Count - 1 do
      with lstItems.Items.Add do begin
        Objects.FindObject( 'Footer');
        Text := Format( '%s%s%f €', [ A.Items[ i].GetValue<string>( 'Name'),
                                      Chr( 13) + Chr( 10),
                                      StrToFloat( A.Items[ i].GetValue<string>( 'Price'), TFormatSettings.Create('en-US'))]);
        fDM.LoadImage( A.Items[ i].GetValue<string>( 'ImageUri'), M);
        Bitmap.LoadFromStream( M);
      end;
  finally
    M.Free;
  end;

  UpdateFinalPrice;
  VisibleProduct( True);
end;

procedure TfrmProduct.VisibleCustomer(aVisible: Boolean);
begin
  rcCustomer.Visible := aVisible;
end;

procedure TfrmProduct.VisibleFinalPrice(aVisible: Boolean);
begin
  lbFinalPrice.Visible := aVisible;
  lbVotrePrix.Visible := aVisible;
end;

procedure TfrmProduct.VisibleProduct(aVisible: Boolean);
begin
  imgProd.Visible := aVisible;
  lbProdName.Visible := aVisible;
  lbPrice.Visible := aVisible;
  lbPrixMagasin.Visible := aVisible;
  rcSuggestions.Visible := aVisible;
end;

end.
