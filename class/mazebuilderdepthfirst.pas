{
 Maze builder class of the Lazarus Mazes program.

 For more detais on the implementation, see wikipedia:
   http://en.wikipedia.org/wiki/Maze_generation_algorithm#Recursive_backtracker

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
unit MazeBuilderDepthFirst;

{$mode objfpc}{$H+}

interface

uses
  Maze,
  Classes, SysUtils;

type

  { TMazeBuilderDepthFirst }

  TMazeBuilderDepthFirst = class
  private
    Queue: TFPList;

    procedure ProcessCell(pCell: TMazeCell);
    function  ExtractFromQueue(const pIndex: integer): TMazeCell;

  public
    function BuildMaze(const pWidth, pHeight: integer;
                       const pStartRow: integer = 0; const pStartCol: integer = 0): TMaze;
  end;

implementation

{ TMazeBuilderDepthFirst }

// Retrieve the requested element from the backtrack queue and delete it
// from the queue so it doesn't get processed anymore.
function TMazeBuilderDepthFirst.ExtractFromQueue(const pIndex: integer): TMazeCell;
begin
  result := TMazeCell(Queue[pIndex]);
  Queue.Delete(pIndex);
end;


// Scant the given cell for all neighbours and generate a new path
// for those neighbours in a random way.
procedure TMazeBuilderDepthFirst.ProcessCell(pCell: TMazeCell);

  // Check if the cell is valid and available for the next step
  procedure CheckForAvailability(const pCell: TMazeCell);
  begin
    if assigned(pCell) then
      if pCell.Tag = 0 then
        Queue.Add(pCell)
  end;

var EOQ : integer;    // End Of Queue
    cell: TMazeCell;  // Next cell to visit
    dir : TDirection; // Loop control var
begin
  // Set the cell as visited
  pCell.Tag := 1;

  // Remember where we are in the queue
  EOQ := Queue.Count;

  // Find all neighbours that have not been visited yet
  for dir in TDirection do
    CheckForAvailability(pCell.Neighbour[dir]);

  // Process all neighbours that were found (and added to the queue)
  while Queue.Count <> EOQ do
  begin
    // If only 1 then use that one else select one randomly.
    if EOQ = Queue.Count-1 then
      Cell := ExtractFromQueue(Queue.Count-1)
    else
      Cell := ExtractFromQueue(EOQ + random(Queue.Count - EOQ));

    // Determine the direction and enable that direction, but do check if
    // this cell has not been processed in the mean time via another route!
    if Cell.Tag = 0 then
    begin
      for dir in TDirection do
        if Cell.Neighbour[dir] = pCell then
        begin
          Cell.CanGo[dir] := true;
          break
        end;

      // Process neighbours of this one
      ProcessCell(Cell);
    end;
  end;
end;

function TMazeBuilderDepthFirst.BuildMaze(const pWidth, pHeight: integer; const pStartRow: integer;
  const pStartCol: integer): TMaze;
begin
  // Init the queue that will hold cells for backtracking
  Queue := TFPList.Create;

  // Create a new maze object and populate it
  result := TMaze.Create(pWidth, pHeight);
  result.SetStartCell(pStartRow, pStartCol);
  ProcessCell(result.StartCell);

  // Clean up
  Queue.Free;
end;

end.

