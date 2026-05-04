unit Unit1;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, SQLite3Conn, SQLDB, DB, Forms, Controls, Graphics,
    Dialogs, ExtCtrls, DBGrids, StdCtrls;

type

    { TForm1 }

    TForm1 = class(TForm)
        btnInserir: TButton;
        btnAlterar: TButton;
        btnDeletar: TButton;
        btnCancelar: TButton;
        btnSalvar: TButton;
        btnPesquisar: TButton;
        DataSource1: TDataSource;
        DBGrid1: TDBGrid;
        Edit1: TEdit;
        edtNome: TEdit;
        edtEmail: TEdit;
        edtTelefone: TEdit;
        Label1: TLabel;
        Label2: TLabel;
        Label3: TLabel;
        Panel1: TPanel;
        Panel2: TPanel;
        Panel3: TPanel;
        SQLite3Connection1: TSQLite3Connection;
        SQLQuery1: TSQLQuery;
        SQLTransaction1: TSQLTransaction;
        procedure btnAlterarClick(Sender: TObject);
        procedure btnCancelarClick(Sender: TObject);
        procedure btnDeletarClick(Sender: TObject);
        procedure btnInserirClick(Sender: TObject);
        procedure btnPesquisarClick(Sender: TObject);
        procedure btnSalvarClick(Sender: TObject);
        procedure FormCreate(Sender: TObject);
        procedure ConfigurarGrid;
        procedure limparedits;
    private

    public

    end;

var
    Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
    ConfigurarGrid;
    SQLite3Connection1.DatabaseName := 'dados.db';
    SQLite3Connection1.Open;

    SQLQuery1.SQL.Text :=
        'CREATE TABLE IF NOT EXISTS clientes (id INTEGER PRIMARY KEY AUTOINCREMENT, nome varchar(50), email varchar(50), telefone varchar(50))';
    SQLQuery1.ExecSQL;

    SQLQuery1.SQL.Text := 'SELECT * FROM clientes';
    SQLQuery1.Open;
    DataSource1.DataSet := SQLQuery1;
end;

procedure TForm1.btnPesquisarClick(Sender: TObject);
begin
    SQLQuery1.Close;
    SQLQuery1.SQL.Text := 'SELECT * FROM clientes WHERE nome LIKE :nome';
    SQLQuery1.Params.ParamByName('nome').AsString := '%' + Edit1.Text + '%';
    SQLQuery1.Open;
end;

procedure TForm1.btnSalvarClick(Sender: TObject);
begin
      try
        SQLQuery1.FieldByName('nome').AsString := edtNome.Text;
        SQLQuery1.FieldByName('email').AsString := edtEmail.Text;
        SQLQuery1.FieldByName('telefone').AsString := edtTelefone.Text;
        SQLQuery1.Post;

        // Aplica e comita
        SQLQuery1.ApplyUpdates;
        SQLTransaction1.Commit;

        // Recarrega o grid
        SQLQuery1.Close;
        SQLQuery1.Open;

        ShowMessage('Registro gravado com sucesso!');

      except
        on E: Exception do
          begin
            SQLTransaction1.Rollback;
            ShowMessage('Erro ao gravar: ' + E.Message);
          end;
      end;
      limparedits;
end;

procedure TForm1.btnInserirClick(Sender: TObject);
begin
    limparedits;
    SQLQuery1.Append;
    edtNome.SetFocus;
end;

procedure TForm1.btnAlterarClick(Sender: TObject);
begin
    limparedits;
    SQLQuery1.Edit;
    edtNome.Text := SQLQuery1.FieldByName('nome').Value;
    edtEmail.Text := SQLQuery1.FieldByName('email').Value;
    edtTelefone.Text := SQLQuery1.FieldByName('telefone').Value;
end;

procedure TForm1.btnCancelarClick(Sender: TObject);
begin
    SQLQuery1.Cancel;
    limparedits;
end;

procedure TForm1.btnDeletarClick(Sender: TObject);
begin
    if MessageDlg('Excluir registro?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        SQLQuery1.Delete;
        SQLQuery1.ApplyUpdates;
        SQLTransaction1.Commit;
      end;
    SQLQuery1.Close;
    SQLQuery1.Open;
end;

procedure TForm1.ConfigurarGrid;
begin
    DBGrid1.Columns.Clear;

    with DBGrid1.Columns.Add do
      begin
        FieldName := 'id';
        Title.Caption := 'Código';
        Width := 60;
        ReadOnly := True;
      end;

    with DBGrid1.Columns.Add do
      begin
        FieldName := 'nome';
        Title.Caption := 'Nome';
        Width := 200;
      end;

    with DBGrid1.Columns.Add do
      begin
        FieldName := 'email';
        Title.Caption := 'E-mail';
        Width := 180;
      end;

    with DBGrid1.Columns.Add do
      begin
        FieldName := 'telefone';
        Title.Caption := 'Telefone';
        Width := 100;
      end;

    // Deixar grid com altura da linha maior
    DBGrid1.DefaultRowHeight := 20;

    // Tirar borda 3D
    DBGrid1.BorderStyle := bsSingle;

end;

procedure TForm1.limparedits;
begin
    edtNome.Clear;
    edtEmail.Clear;
    edtTelefone.Clear;
end;

end.
