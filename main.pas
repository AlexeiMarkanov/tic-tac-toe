unit main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Grids,
  Vcl.StdActns, System.ImageList, Vcl.ImgList, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    StringGrid1: TStringGrid;
    ActionList1: TActionList;
    ANewGame: TAction;
    AShowPos: TAction;
    ImageList1: TImageList;
    EditDelete1: TEditDelete;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    procedure ANewGameExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$WriteableConst On}          // http://www.delphibasics.ru/Const.php

Type
  SquareType = (EMPTY,CROSS,NULL);
  PosType = array [0..8] of SquareType;
Const
  pos: PosType = (
                    EMPTY, EMPTY,EMPTY,
                    EMPTY, EMPTY,EMPTY,
                    EMPTY, EMPTY,EMPTY
                  );
  function EndGame (z:SquareType): boolean;
  begin
    {
    0,1,2,
    3,4,5,
    6,7,8
    }
    EndGame:=true;
    if (pos[0]=z) and (pos[1]=z) and (pos[2]=z) then exit;
    if (pos[3]=z) and (pos[4]=z) and (pos[5]=z) then exit;
    if (pos[6]=z) and (pos[7]=z) and (pos[8]=z) then exit;
    if (pos[0]=z) and (pos[3]=z) and (pos[6]=z) then exit;
    if (pos[1]=z) and (pos[4]=z) and (pos[7]=z) then exit;
    if (pos[2]=z) and (pos[5]=z) and (pos[8]=z) then exit;
    if (pos[0]=z) and (pos[4]=z) and (pos[8]=z) then exit;
    if (pos[6]=z) and (pos[4]=z) and (pos[2]=z) then exit;
    EndGame:=false;
  end;

{сюда вернем лучший ход}
var retPos: PosType;

  function Search(s: SquareType;
                  alpha, beta:integer; { минимум и максимум}
                  ply:integer {глубина}
                  ):integer;
  var
    n,tmp:integer;
    f,opS: SquareType;
    findMove: boolean;
  begin
    {определим цвет фигур противника}
    if s=NULL then opS:=CROSS else opS:=NULL;

    {если есть замкнута€ лини€, проведем оценку}
    if EndGame(opS) then
    begin {противник замкнул линию это ваш проигрыш}
      Search:=-1;
      Exit;
    end;

    {пока не нашли не одной свободной клетки}
    findMove:=false;

    {переберем все клетки доски}
    for n:=0 to 8 do
    begin
      f:=pos[n];
      if f = EMPTY then
      begin
        findMove:=true;
        {сделали ход}
        pos[n]:=s;  {чтобы это сделать надо http://www.delphibasics.ru/Const.php}
        {просчет}
        tmp:= - Search(opS,-beta,-alpha,ply+1);
        if tmp > alpha then
        begin
          alpha:=tmp;
          if ply = 0 then
            Move(pos,retPos,sizeOf(PosType));
        end;
        {восстановим позицию}
        pos[n]:=EMPTY;
        if alpha >= beta then break;
      end;
    end;

    if not findMove then Search:=0 {Ќичь€}
     else Search:=alpha;

  end;

  {возвращает true, если конец игры}
  function GameOver:boolean;
  var n:integer;
  begin
  GameOver:=false;
  if EndGame(CROSS) or EndGame(NULL) then GameOver:=true
   else
    begin
      for n:=0 to 8 do if pos[n] = EMPTY then exit;
      GameOver:=true;
    end;
  end;

{определ€ем номер €чейки по двум координатам}
{избыточно и непрофессионально}
  function MatrixToLine(Col,Row:integer):integer;
  begin
    if (Col=0) and (Row=0) then begin result:=0; exit; end;
    if (Col=1) and (Row=0) then begin result:=1; exit; end;
    if (Col=2) and (Row=0) then begin result:=2; exit; end;
    if (Col=0) and (Row=1) then begin result:=3; exit; end;
    if (Col=1) and (Row=1) then begin result:=4; exit; end;
    if (Col=2) and (Row=1) then begin result:=5; exit; end;
    if (Col=0) and (Row=2) then begin result:=6; exit; end;
    if (Col=1) and (Row=2) then begin result:=7; exit; end;
    if (Col=2) and (Row=2) then begin result:=8; exit; end;
    result:=-1;
  end;




  procedure ShowPos(SG:TSTringGrid);
      function Ch(n:integer):char;
      begin
        if Pos[n]= CROSS then Ch:=' '
          else if Pos[n]=NULL then Ch :=' '
          else Ch:=' ';
      end;
  begin
    SG.Cells[0,0]:=ch(0); SG.Cells[1,0]:=ch(1); SG.Cells[2,0]:=ch(2);
    SG.Cells[0,1]:=ch(3); SG.Cells[1,1]:=ch(4); SG.Cells[2,1]:=ch(5);
    SG.Cells[0,2]:=ch(6); SG.Cells[1,2]:=ch(7); SG.Cells[2,2]:=ch(8);
  end;

  procedure ShowGameOver(res:string);
  var n:integer;
  begin
    ShowMessage('»гра окончена, '+res+'!');
    for n:=0 to 8 do pos[n]:=EMPTY;
  end;

procedure TForm1.ANewGameExecute(Sender: TObject);
begin
  //
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
//  ShowPos(StringGrid1);
end;

procedure TForm1.StringGrid1DrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);

        {определ€ем картинку по номеру клетки}
      function Pg(n:integer):TGraphic;
      begin
        if Pos[n]= CROSS then result:=Image1.Picture.Graphic
          else if Pos[n]=NULL then result :=Image2.Picture.Graphic
          else result :=Image3.Picture.Graphic;
      end;

begin
// if GameOver then
//   begin
//    ShowPos(StringGrid1);
//    ShowGameOver(1);
//    ShowPos(StringGrid1);
//   end;
    StringGrid1.Canvas.StretchDraw(Rect,Pg(MatrixToLine(ACol,ARow)));
end;

procedure TForm1.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
var chtmp :integer;
    tmp   : integer;

begin
  chtmp:=MatrixToLine(ACol,ARow);
  if (pos[chtmp]=EMPTY) then
  begin
    pos[chtmp] := CROSS;
    ShowPos(StringGrid1);
    if not GameOver then
    begin
      tmp:=Search(NULL,-2,2,0);
      pos:=retPos;
    end else
        begin
          ShowGameOver('ничь€');
        end;
  end;
  if GameOver then ShowGameOver('¬ы проиграли');
  ShowPos(StringGrid1);
end;

end.
