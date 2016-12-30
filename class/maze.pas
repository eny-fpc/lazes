{
 Base maze implementation classes for the Lazarus Mazes program

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
unit Maze;

{$mode objfpc}{$H+}

interface

uses
  ContNrs, Classes, SysUtils;

type
  // Replacement for TPoint so we can work with rows and columns
  TCellPoint = record
    Row: integer;
    Col: integer;
  end;

  // The 4 directions one can go to from withint a cell.
  // Do not change the order North, South, East, West; ever!
  TDirection = (dirNorth, dirSouth, dirEast, dirWest);
  TDirectionSet = set of TDirection;

  // For solving and displaying, keep the state of a cell
  TCellState = (csEmpty, csStart, csVisited, csExit);

  { TMazeCell }
  TMazeCell = class
  private
    FWalls : TDirectionSet;
    FNeighbours: array[TDirection] of TMazeCell;
    FTag   : integer;    // For external use (like TComponent.Tag); default = 0
    FState : TCellState; // E.g. for coloring; default = csEmpty

    function  OppositeDirection(const pDirection: TDirection): TDirection;
    function  GetCanGoDirection(const pDirection: TDirection): boolean;
    function  GetNeighbour(const pDirection: TDirection): TMazeCell;
    procedure SetCanGoDirection(const pDirection: TDirection; pCanGo: boolean);
    procedure SetNeighbour(const pDirection: TDirection; pNeighbour: TMazeCell);

  public
    constructor Create;

    property Tag: integer read FTag write FTag;
    property State: TCellState read FState write FState;
    property CanGo[const pDirection: TDirection]: boolean read GetCanGoDirection write SetCanGoDirection;
    property Neighbour[const pDirection: TDirection]: TMazeCell read GetNeighbour write SetNeighbour;
  end;

  TMazeRect = array of array of TMazeCell;

  { TMaze }

  TMaze = class
  private
    FAllCells: TFPObjectList;
    FMaze    : TMazeRect;
    FWidth   : integer;
    FHeight  : integer;
    FStart   : TCellPoint;

    function GetCell(const pRow, pCol: integer): TMazeCell;

  public
    class function CellPoint(const pRow, pCol: integer): TCellPoint;
    constructor Create(const pWidth, pHeight: integer);
    destructor Destroy; override;

    procedure ResetTags(const pValue: integer = 0);
    function  GetCell(const pPosition: TCellPoint): TMazeCell;
    function  StartCell: TMazeCell;
    procedure SetStartCell(const pRow, pCol: integer);
    function  GetStartPosition: TCellPoint;

    property Width : integer read FWidth;
    property Height: integer read FHeight;

    property Cell[const pRow, pCol: integer]: TMazeCell read GetCell; default;

  end;

implementation

{ TMazeCell }

function TMazeCell.OppositeDirection(const pDirection: TDirection): TDirection;
begin
  case pDirection of
    dirNorth: result := dirSouth;
    dirSouth: result := dirNorth;
    dirEast : result := dirWest;
    dirWest : result := dirEast
  end;
end;

function TMazeCell.GetCanGoDirection(const pDirection: TDirection): boolean;
begin
  result := not (pDirection in FWalls)
end;

function TMazeCell.GetNeighbour(const pDirection: TDirection): TMazeCell;
begin
  result := FNeighbours[pDirection];
end;

procedure TMazeCell.SetCanGoDirection(const pDirection: TDirection; pCanGo: boolean);
begin
  if pCanGo then
    begin
      // Remove wall
      FWalls := FWalls - [ pDirection ];
      // Fix neighbour also; must use local F-var to prevent loop!
      if assigned(Neighbour[pDirection]) then
        with Neighbour[pDirection] do
          FWalls := FWalls - [ OppositeDirection(pDirection) ];
    end
  else
    begin
      // Set wall
      FWalls := FWalls + [ pDirection ];
      // Fix neighbour also; must use local F-var to prevent loop!
      if assigned(Neighbour[pDirection]) then
        with Neighbour[pDirection] do
          FWalls := FWalls + [ OppositeDirection(pDirection) ];
    end;
end;

procedure TMazeCell.SetNeighbour(const pDirection: TDirection; pNeighbour: TMazeCell);
begin
  // Register the neighbour
  FNeighbours[pDirection] := pNeighbour;
  // And give self to neighbour; must use local F-var to prevent loop!
  pNeighbour.FNeighbours[OppositeDirection(pDirection)] := self
end;

constructor TMazeCell.Create;
begin
  FWalls := [ dirNorth, dirSouth, dirEast, dirWest]; // Default: all directions blocked
end;

{ TMaze }
function TMaze.GetCell(const pRow, pCol: integer): TMazeCell;
begin
  result := FMaze[pRow][pCol]
end;

class function TMaze.CellPoint(const pRow, pCol: integer): TCellPoint;
begin
  result.Row := pRow;
  result.Col := pCol
end;

constructor TMaze.Create(const pWidth, pHeight: integer);
var row, col: integer;
    MC: TMazeCell;
begin
  // Register size of the maze
  FWidth  := pWidth;
  FHeight := pHeight;
  FStart.col := PWidth div 2;
  FStart.row := pHeight div 2;

  // Create the garbage bin for all cells
  FAllCells := TFPObjectList.Create;

  // Initialize maze with number of rows
  SetLength(FMaze, Height);

  // Initialize all rows with the number of columns
  for row := 0 to Height-1 do
  begin
    // Allocate the columns in the row
    SetLength(FMaze[row], Width);
    // And add all cells
    for col := 0 to FWidth-1 do
    begin
      // Create new cell and store it.
      MC := TMazeCell.Create;
      FMaze[row][col] := MC;
      FAllCells.Add(MC);

      // Set up the neighbouts.
      // Only West and North are required, because the maze cell
      // will register itself with the neighbour as East or South
      if col > 0 then  MC.Neighbour[dirWest]  := FMaze[row][col-1];
      if row > 0 then  MC.Neighbour[dirNorth] := FMaze[row-1][col];
    end;
  end;
end;

destructor TMaze.Destroy;
begin
  FreeAndNil(FAllCells); // Clean up all cells
  inherited Destroy;
end;

procedure TMaze.ResetTags(const pValue: integer);
var row,col: integer;
begin
  for row := 0 to Height-1 do
    for col := 0 to Width-1 do
      FMaze[row][col].Tag := pValue
end;

function TMaze.GetCell(const pPosition: TCellPoint): TMazeCell;
begin
  result := FMaze[pPosition.row][pPosition.col]
end;

function TMaze.StartCell: TMazeCell;
begin
  result := FMaze[FStart.row, FStart.col]
end;

procedure TMaze.SetStartCell(const pRow, pCol: integer);
begin
  FStart.Row := pRow;
  FStart.Col := pCol;
  Cell[pRow,pCol].State := csStart;
end;

function TMaze.GetStartPosition: TCellPoint;
begin
  result := FStart;
end;

end.

