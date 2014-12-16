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
    Label2: TLabel;
    Label3: TLabel;
    lbFinalPrice: TLabel;
    rcCustomer: TRectangle;
    rcCustomerCadre: TRectangle;
    Label1: TLabel;
    Panel2: TPanel;
    Rectangle1: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fDM : TdmData;
    FproductId : Integer;
    FcustomerId : Integer;
    procedure VisibleProduct( aVisible : Boolean);
    procedure VisibleCustomer( aVisible : Boolean);

    procedure InnerUpdateProduct( aProduct : TJSONValue);
    procedure InnerUpdateCustomer( aCustomer : TJSONValue);
    procedure InnerClearProduct;
    procedure InnerClearCustomer;
    {IMain}
    function UpdateProduct : TItemUpdater;
    function UpdateCustomer : TItemUpdater;
    function ClearProduct : TClearMethod;
    function ClearCustomer : TClearMethod;

    procedure UpdateFinalPrice;
  public
  end;

var
  frmProduct: TfrmProduct;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}

function TfrmProduct.ClearCustomer: TClearMethod;
begin
  Result := InnerClearCustomer;
end;

procedure TfrmProduct.InnerClearProduct;
begin
  VisibleProduct( False);
  lstItems.Items.Clear;
  FproductId := -1;
end;

function TfrmProduct.ClearProduct: TClearMethod;
begin
  Result := InnerClearProduct;
end;

procedure TfrmProduct.InnerClearCustomer;
begin
  VisibleCustomer( False);
  FcustomerId := -1;
end;

procedure TfrmProduct.FormCreate(Sender: TObject);
var i : Integer;
    K : TListViewItem;
begin
  fDM := TdmData.Create( Self);
  InnerClearProduct;
  InnerClearCustomer;
end;

procedure TfrmProduct.FormDestroy(Sender: TObject);
begin
  fDM.Free;
end;

procedure TfrmProduct.InnerUpdateCustomer(aCustomer: TJSONValue);
begin
  if aCustomer.GetValue<integer>( 'Id') = FcustomerId then exit;

  FcustomerId := aCustomer.GetValue<integer>( 'Id');

  lbCustomerName.Text := Format('%s %s', [aCustomer.GetValue<string>( 'FirstName'), aCustomer.GetValue<string>( 'LastName')]);
  lbVoucherCredit.Text := aCustomer.GetValue<string>( 'LoyaltyVoucher');

  UpdateFinalPrice;

  VisibleCustomer( True);
end;

function TfrmProduct.UpdateCustomer: TItemUpdater;
begin
  Result := InnerUpdateCustomer;
end;

procedure TfrmProduct.UpdateFinalPrice;
begin
  if ((Fcustomerid <> -1) and (FproductId <> -1)) then
  begin
    lbFinalPrice.Text := FloatToStr(StrToFloat(lbPrice.Text, TFormatSettings.Create('en-US')) - StrToFloat(lbVoucherCredit.Text, TFormatSettings.Create('en-US')));
    lbFinalPrice.Visible := True;
    Label3.Visible := True;
  end
  else
  begin
    lbFinalPrice.Visible := False;
    Label3.Visible := False;
  end;
end;

procedure TfrmProduct.InnerUpdateProduct(aProduct: TJSONValue);
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

  UpdateFinalPrice;

  VisibleProduct( True);
end;

function TfrmProduct.UpdateProduct: TItemUpdater;
begin
  Result := InnerUpdateProduct;
end;

procedure TfrmProduct.VisibleCustomer(aVisible: Boolean);
begin
  rcCustomer.Visible := aVisible;
end;

procedure TfrmProduct.VisibleProduct(aVisible: Boolean);
begin
  imgProd.Visible := aVisible;
  lbProdName.Visible := aVisible;
  lbPrice.Visible := aVisible;
  label1.Visible := aVisible;
  rcSuggestions.Visible := aVisible;
end;

end.
