{
 Maze painter class of the Lazarus Mazes program

 Copyright (C) 2012 G.A. Nijland (eny @ lazarus forum http://www.lazarus.freepascal.org/)

 This source is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
 License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later
 version.

 This code is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 details.

 A copy of the GNU General Public License is available on the World Wide Web at
 <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing to the Free Software Foundation, Inc., 59
 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}
unit MazePainter;

{$mode objfpc}{$H+}

interface

uses
  Maze,
  Graphics, Classes, SysUtils;

type

  { TMazePainter }
  TMazePainter = class
  private
    FCellDrawWidth: integer;
    FCellDrawHeight: integer;
    FisDirty: boolean;
    Maze: TMaze;
    FCanvas: TCanvas;
    bmp: TBitMap;

    FWallColor: TColor;
    FWallShadowColor: TColor;
    FCellColors: array[TCellState] of TColor;

    function GetCellColor(const pState: TCellState): TColor;
    procedure SetCellColor(const pState: TCellState; pColor: TColor);
    procedure Grow(var pRect: TRect; const pdx, pdy: integer);

  public
    constructor Create(const pMaze: TMaze; pCanvas: TCanvas);
    destructor Destroy; override;

    procedure Paint(const pOffsetX: integer = 0; const pOffsetY: integer = 0);

    function Width : integer;
    function Height: integer;

    property CellDrawWidth: integer read FCellDrawWidth write FCellDrawWidth;
    property CellDrawHeight: integer read FCellDrawHeight write FCellDrawHeight;

    property CellColor[const pState: TCellState]: TColor read GetCellColor write SetCellColor;
    property WallColor: TColor read FWallColor write FWallColor;
    property WallShadowColor: TColor read FWallShadowColor write FWallShadowColor;
    property IsDirty: boolean read FisDirty write FisDirty;
  end;

implementation

{ TMazePainter }

constructor TMazePainter.Create(const pMaze: TMaze; pCanvas: TCanvas);
begin
  // Init the default drawing width and height
  FCellDrawWidth := 15;
  FCellDrawHeight := 15;

  // Set default colors
  WallColor            := clBlue;
  CellColor[csEmpty]   := clSkyBlue;
  CellColor[csStart]   := clYellow;
  CellColor[csVisited] := clMaroon;
  CellColor[csExit]    := clGreen;

  // Store maze and canvas for future reference
  Maze := pMaze;
  FCanvas := pCanvas;

  // Refresh on the next draw
  isDirty := true;
end;

destructor TMazePainter.Destroy;
begin
  bmp.Free;
  inherited Destroy;
end;

function TMazePainter.GetCellColor(const pState: TCellState): TColor;
begin
  result := FCellColors[pState];
end;

procedure TMazePainter.SetCellColor(const pState: TCellState; pColor: TColor);
begin
  FCellColors[pState] := pColor
end;

procedure TMazePainter.Grow(var pRect: TRect; const pdx, pdy: integer);
begin
  dec(pRect.Left,   pdx);
  dec(pRect.Top,    pdy);
  inc(pRect.Right,  pdx);
  inc(pRect.Bottom, pdy);
end;

procedure TMazePainter.Paint(const pOffsetX: integer; const pOffsetY: integer);
const C_LINE_THICK  = 1;
var row,col: integer;
    square : TRect;
    Canvas : TCanvas;
    dx,dy  : integer;
begin
  if isDirty then
  begin
    FreeAndNil(bmp);
    bmp := TBitMap.Create;
    bmp.Width := Width+1;
    bmp.Height := Height+1;
    Canvas := bmp.Canvas;

    for row := 0 to Maze.Height-1 do
      for col := 0 to Maze.Width-1 do
      begin
        // Draw the empty cell frame
        Canvas.Brush.Color := CellColor[csEmpty];
        Canvas.Pen.Color := Canvas.Brush.Color;

        square.Top    := row * CellDrawHeight;
        square.Left   := col * CellDrawWidth;
        square.Right  := square.Left + CellDrawWidth;
        square.Bottom := square.Top + CellDrawHeight;
        Canvas.Rectangle(square);

        // draw walls
        Canvas.Pen.color := FWallColor;
        Canvas.Pen.Width := C_LINE_THICK;
        Canvas.Pen.JoinStyle := pjsBevel;
        with Maze[row,col] do
        begin
          if not CanGo[dirNorth] then
            begin
              Canvas.Line(square.Left,  Square.Top,    square.right,  square.Top);
              Canvas.Pen.color := clMoneyGreen;
              Canvas.Line(square.Left+1,  Square.Top+1,    square.right-1,  square.Top+1);
              Canvas.Pen.color := clBlue;
            end;
          if not CanGo[dirSouth] then Canvas.Line(square.Left,  Square.Bottom, square.right,  square.Bottom);
          if not CanGo[dirWest]  then
          begin
            Canvas.Line(square.Left,   Square.Top,    square.Left,   square.Bottom);
            Canvas.Pen.color := clMoneyGreen;
            Canvas.Line(square.Left+1, Square.Top+1,  square.Left+1,   square.Bottom-1);
            Canvas.Pen.color := clBlue;
          end;
          if not CanGo[dirEast]  then Canvas.Line(square.Right, Square.Top,    square.Right,  square.Bottom);
        end;

        // Draw inside when the cell is not empty
        if Maze[row,col].State <> csEmpty then
        begin
          // Determine a visibly pleasing margin with the walls
          if FCellDrawWidth  < 13 then dx := -1 else dx := -3;
          if FCellDrawHeight < 13 then dy := -1 else dy := -3;
          // Shring by this margin and draw the cell's inside
          Grow(square, dx, dy);
          Canvas.Brush.Color := CellColor[Maze[row,col].State];
          Canvas.Pen.Color   := CellColor[Maze[row,col].State];
          Canvas.Rectangle(square);
        end;
      end;

    // Fully refreshed
    isDirty := false;
  end;

  // Draw bitmap
  FCanvas.CopyRect(Rect(pOffsetX,pOffsetY,pOffsetX+Width+1,pOffsetY+Height+1), bmp.Canvas, Rect(0,0,Width+1,Height+1));
end;

function TMazePainter.Width: integer;
begin
  result := Maze.Width * CellDrawWidth;
end;

function TMazePainter.Height: integer;
begin
  result := Maze.Height * CellDrawHeight;
end;

end.

