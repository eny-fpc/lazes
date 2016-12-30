{
 Main form of the Lazarus Mazes program

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
unit ufrmMain1;

interface

uses
  ufrmScaling,
  LazesGlobals, MazeBuilderDepthFirst, MazePainter, Maze,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, ActnList, StdActns, types, Windows;

type

  { TfrmMain1 }

  TfrmMain1 = class(TForm)
    acSolve: TAction;
    acNewMaze: TAction;
    actMetricsPopUp: TAction;
    ActionList1: TActionList;
    FileExit1: TFileExit;
    imgBackground: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    pbMaze: TPaintBox;

    procedure acNewMazeExecute(Sender: TObject);
    procedure acSolveExecute(Sender: TObject);
    procedure actMetricsPopUpExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure pbMazePaint(Sender: TObject);

  private
    Maze: TMaze;
    MazePainter: TMazePainter;
    MazeMetrics: TMazeUpdateInfo;
    MazeIsSolved: boolean;

    procedure OnMazeChangeMessage(var Msg: TMessage); message C_MAZE_UPDATE_MESSAGE;
    procedure GenerateNewMaze;
    procedure ResizeMaze(const pdx, pdy: integer);

  public
  end;

var
  frmMain1: TfrmMain1;

implementation

{$R *.lfm}

{ TfrmMain1 }

procedure TfrmMain1.FormCreate(Sender: TObject);
begin
  // Reduce flocker
  self.DoubleBuffered := true;

  // Set alignment images
  imgBackground.Align := alClient;
  pbMaze.Align := alClient;

  // Start with base maze set up
  with MazeMetrics do
  begin
    MazeWidth  := 20;
    MazeHeight := 15;
    DrawWidth  := 15;
    DrawHeight := 15;
  end;

  // Initialize the random generator, so mazes dont repeat (any time soon)
  Randomize;

  // And generate a demo maze
  GenerateNewMaze;
end;

procedure TfrmMain1.FormDestroy(Sender: TObject);
begin
  FreeAndNil(MazePainter);
  FreeAndNil(Maze);
end;

procedure TfrmMain1.FormMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  ResizeMaze(-1,-1);
end;

procedure TfrmMain1.FormMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  ResizeMaze(1,1);
end;

procedure TfrmMain1.acSolveExecute(Sender: TObject);

var Solved: boolean;

  procedure TravelMaze(CurPos: TCellPoint);

    procedure TryMove(const pFrom: TCellPoint; const pDirection: TDirection);
    const DirMoves: array[TDirection] of TPoint = ((x: 0; y:-1),  // North
                                                   (x: 0; y:+1),  // South
                                                   (x:+1; y:0 ),  // East
                                                   (x:-1; y:0 )); // West
    var NewPos: TCellPoint;
    begin
      // Direction at all possible?
      with Maze.GetCell(pFrom) do
        if not CanGo[pDirection] then EXIT;

      // Movement is possible!
      NewPos.Row := pFrom.Row + DirMoves[pDirection].y;
      NewPos.Col := pFrom.Col + DirMoves[pDirection].x;

      // Check if the next cell is not visited before.
      with Maze.GetCell(NewPos) do
        if State = csExit then
          begin
            Solved := true;
            Exit
          end
        else if State = csVisited then
          Exit
      else
        begin
          State := csVisited;     // Been here
          // Tag := 1;               // Visited
              // State := csStart;
              MazePainter.IsDirty := true; // Force repaint with new cell populated
              pbMaze.Repaint;
              Application.ProcessMessages;
              if Maze.Width < 20 then sleep(10);

              // Start travelling from here
              if not Solved then
                TravelMaze(NewPos);

              // If still not solved, backtrack
              if not Solved then
              begin
                State := csEmpty;
                // Tag := 0;
                MazePainter.IsDirty := true; // Force repaint with new cell populated
                pbMaze.Repaint;
                Application.ProcessMessages;
                if Maze.Width < 20 then sleep(10);
              end;
        end;
    end;

  begin
    // Check all 4 directions for possible moves
    if not Solved then TryMove(CurPos, dirEast);
    if not Solved then TryMove(CurPos, dirSouth);
    if not Solved then TryMove(CurPos, dirWest);
    if not Solved then TryMove(CurPos, dirNorth);
  end;

begin
  // If the maze was already solved, dont do it again
  if MazeIsSolved then
  begin
    MessageDlg('As you can see this maze was already solved!', mtInformation, [mbOK], 0);
    EXIT
  end;

  // Reset the tags, they will be used for backtracking
  Maze.ResetTags;

  // Not done yet...
  Solved := false;

  // Travel all cells until the end is found
  TravelMaze(Maze.GetStartPosition);
  MazeIsSolved := true;

  // Found, so give a victorious message!
  MessageDlg('Hurrah! Found the exit!!!!', mtInformation, [mbOK], 0);
end;

procedure TfrmMain1.acNewMazeExecute(Sender: TObject);
begin
  GenerateNewMaze;
end;

procedure TfrmMain1.actMetricsPopUpExecute(Sender: TObject);
begin
  frmScaling.Show;
end;

procedure TfrmMain1.pbMazePaint(Sender: TObject);
begin
  // Paint the maze centered within the paint window
  if assigned(MazePainter) then
    MazePainter.Paint((pbMaze.ClientWidth - MazePainter.Width) div 2,
                      (pbMaze.ClientHeight - MazePainter.Height) div 2);
end;

procedure TfrmMain1.GenerateNewMaze;
var bld: TMazeBuilderDepthFirst;
begin
  // Clean up old maze and painter
  FreeAndNil(MazePainter);
  FreeAndNil(Maze);

  // Build a new one, based on the given metrics
  bld := TMazeBuilderDepthFirst.Create;
  Maze := bld.BuildMaze(MazeMetrics.MazeWidth, MazeMetrics.MazeHeight);
  bld.Free;

  // This one is not solved yet
  MazeIsSolved := false;

  // Set lower right hand corner as exit (top left is start by default)
  Maze.Cell[ Maze.Height-1, Maze.Width-1 ].State := csExit;

  // Paint the maze
  MazePainter := TMazePainter.Create(Maze, pbMaze.Canvas);
  MazePainter.CellDrawWidth  := MazeMetrics.DrawWidth;
  MazePainter.CellDrawHeight := MazeMetrics.DrawHeight;
  pbMaze.Repaint;
end;

procedure TfrmMain1.ResizeMaze(const pdx, pdy: integer);
begin
  if  ((MazeMetrics.MazeWidth  + pdx) >= C_MIN_MAZE_SIZE)
  and ((MazeMetrics.MazeWidth  + pdx) <= C_MAX_MAZE_SIZE)
  and ((MazeMetrics.MazeHeight + pdy) >= C_MIN_MAZE_SIZE)
  and ((MazeMetrics.MazeHeight + pdy) <= C_MAX_MAZE_SIZE) then
  begin
    inc(MazeMetrics.MazeWidth,  pdx);
    inc(MazeMetrics.MazeHeight, pdy);
    GenerateNewMaze;
  end
end;

procedure TfrmMain1.OnMazeChangeMessage(var Msg: TMessage);
var NewMetrics: TMazeUpdateInfo;
begin
  // Any updates?
  NewMetrics := PMazeUpdateInfo(Msg.wParam)^;
  if (NewMetrics.DrawHeight <> MazeMetrics.DrawHeight)
  or (NewMetrics.DrawWidth  <> MazeMetrics.DrawWidth)
  or (NewMetrics.MazeHeight <> MazeMetrics.MazeHeight)
  or (NewMetrics.MazeWidth  <> MazeMetrics.MazeWidth) then
  begin
    MazeMetrics := NewMetrics;
    GenerateNewMaze;
  end;
end;

end.

