{
 Global declarations for the Lazarus Mazes program

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
unit LazesGlobals;

{$mode objfpc}{$H+}

interface

uses
  Windows;

const
  // Update message when something in the maze config has changed and needs regeneration
  C_MAZE_UPDATE_MESSAGE = WM_USER + 67122;

  // Maximum width/height of the maze
  C_MIN_MAZE_SIZE =  4;
  C_MAX_MAZE_SIZE = 80;

type
  // Record structure to send messages around with maze metrics
  TMazeUpdateInfo = record
    MazeWidth : integer;
    MazeHeight: integer;
    DrawWidth : integer;
    DrawHeight: integer;
  end;
  PMazeUpdateInfo = ^TMazeUpdateInfo;

implementation

end.

