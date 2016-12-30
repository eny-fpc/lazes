 {
  Main source of the Lazarus Mazes program.

  A maze implementation based on a depth-first backtracking algorithm.
  For more detais, see wikipedia:
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
program Lazes;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, ufrmmain1, Maze, MazePainter, MazeBuilderDepthFirst, ufrmScaling, LazesGlobals
  { you can add units after this };

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain1, frmMain1);
  Application.CreateForm(TfrmScaling, frmScaling);
  Application.Run;
end.

