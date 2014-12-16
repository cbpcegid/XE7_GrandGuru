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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fDM : TdmData;
    Fid : Integer;
    procedure VisibleProduct( aVisible : Boolean);
    {IMain}
    procedure UpdateProduct( aProduct : TJSONValue);
    function ImgProduct : TBitmap;
    procedure Clear;
  public
  end;

var
  frmProduct: TfrmProduct;

implementation

{$R *.fmx}
{$R *.LgXhdpiTb.fmx ANDROID}

procedure TfrmProduct.Clear;
begin
  VisibleProduct( False);
  Fid := -1;
  lstItems.Items.Clear;
//  lstItems.
end;

procedure TfrmProduct.FormCreate(Sender: TObject);
var i : Integer;
    K : TListViewItem;
begin
  fDM := TdmData.Create( Self);
  Clear;
end;

procedure TfrmProduct.FormDestroy(Sender: TObject);
begin
  fDM.Free;
end;

function TfrmProduct.ImgProduct: TBitmap;
begin
  Result := imgProd.Bitmap;
end;

procedure TfrmProduct.UpdateProduct(aProduct: TJSONValue);
var A : TJSONArray;
    K : TListViewItem;
    i : Integer;
    M : TMemoryStream;
begin
  if aProduct.GetValue<integer>( 'Id') = Fid then exit;

  Fid := aProduct.GetValue<integer>( 'Id');

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

procedure TfrmProduct.VisibleProduct(aVisible: Boolean);
begin
// pouet
  imgProd.Visible := aVisible;
  lbProdName.Visible := aVisible;
  lbPrice.Visible := aVisible;
  rcSuggestions.Visible := aVisible;
end;

end.
