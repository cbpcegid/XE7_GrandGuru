unit ProductForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  DataModule, FMX.StdCtrls, FMX.Objects, FMX.ListView.Types, FMX.ListView, JSON;

type
  TfrmProduct = class(TForm, IMain)
    imgProd: TImageControl;
    lbPrice: TLabel;
    lstItems: TListView;
    lbProdName: TLabel;
    lbSuggestions: TLabel;
    rcSuggestions: TRectangle;
    lbVoucherCredit: TLabel;
    lbCustomerName: TLabel;
    gbCustomer: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    lbFinalPrice: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fDM : TdmData;
    FproductId : Integer;
    FcustomerId : Integer;
    procedure VisibleProduct( aVisible : Boolean);
    procedure VisibleCustomer( aVisible : Boolean);
    {IMain}
    procedure UpdateProduct( aProduct : TJSONValue);
    procedure UpdateCustomer( aCustomer : TJSONValue);
    function ImgProduct : TBitmap;
    procedure ClearProduct;
    procedure ClearCustomer;
  public
  end;

var
  frmProduct: TfrmProduct;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}

procedure TfrmProduct.ClearProduct;
begin
  VisibleProduct( False);
  FproductId := -1;
  lstItems.Items.Clear;
//  lstItems.
end;

procedure TfrmProduct.ClearCustomer;
begin
  VisibleCustomer( False);
  FcustomerId := -1;
end;

procedure TfrmProduct.FormCreate(Sender: TObject);
var i : Integer;
    K : TListViewItem;
begin
  fDM := TdmData.Create( Self);
  ClearProduct;
  ClearCustomer;
end;

procedure TfrmProduct.FormDestroy(Sender: TObject);
begin
  fDM.Free;
end;

function TfrmProduct.ImgProduct: TBitmap;
begin
  Result := imgProd.Bitmap;
end;

procedure TfrmProduct.UpdateCustomer(aCustomer: TJSONValue);
begin
  if aCustomer.GetValue<integer>( 'Id') = FcustomerId then exit;

  FcustomerId := aCustomer.GetValue<integer>( 'Id');

  lbCustomerName.Text := Format('%s %s', [aCustomer.GetValue<string>( 'FirstName'), aCustomer.GetValue<string>( 'LastName')]);
  lbVoucherCredit.Text := aCustomer.GetValue<string>( 'LoyaltyVoucher');
  //lbFinalPrice.Text := aProduct.GetValue<double>( 'Price') - aCustomer.GetValue<double>( 'LoyaltyVoucher');

  VisibleCustomer( True);
end;

procedure TfrmProduct.UpdateProduct(aProduct: TJSONValue);
var A : TJSONArray;
    K : TListViewItem;
    i : Integer;
    M : TMemoryStream;
begin
  if aProduct.GetValue<integer>( 'Id') = FproductId then exit;

  FproductId := aProduct.GetValue<integer>( 'Id');

  M := TMemoryStream.Create;
  try
    lbProdName.Text := aProduct.GetValue<string>( 'Name');
    lbPrice.Text := aProduct.GetValue<string>( 'Price');

    fDM.LoadImage( aProduct.GetValue<string>( 'ImageUri'), M);
    imgProd.Bitmap.LoadFromStream( M);

    A := aProduct.GetValue<TJSONArray>( 'RelatedProducts');

    for i := 0 to A.Count - 1 do begin
      K := lstItems.Items.Add;
      with A.Items[ i] do begin
        K.Objects.FindObject( 'Footer');
        K.Text := Format( '%s' + chr(13) + chr(10) + '%s €', [ GetValue<string>( 'Name'), GetValue<string>( 'Price')]);

        fDM.LoadImage( GetValue<string>( 'ImageUri'), M);
        K.Bitmap.LoadFromStream( M);
      end;
    end;
  finally
    M.Free;
  end;

  VisibleProduct( True);
end;

procedure TfrmProduct.VisibleCustomer(aVisible: Boolean);
begin
  gbCustomer.Visible := aVisible;
end;

procedure TfrmProduct.VisibleProduct(aVisible: Boolean);
begin
  imgProd.Visible := aVisible;
  lbProdName.Visible := aVisible;
  lbPrice.Visible := aVisible;
  rcSuggestions.Visible := aVisible;
end;

end.
