program Grandguru;

uses
  System.StartUpCopy,
  FMX.Forms,
  ProductForm in 'ProductForm.pas' {frmProduct},
  DataModule in 'DataModule.pas' {dmData: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  Application.FormFactor.Orientations := [TFormOrientation.Landscape];
  Application.CreateForm(TfrmProduct, frmProduct);
  Application.Run;
end.
