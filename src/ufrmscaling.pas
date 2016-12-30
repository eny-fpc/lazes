{
 Maze scaling form of the Lazarus Mazes program

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
unit ufrmScaling;

{$mode objfpc}{$H+}

interface

uses
  LazesGlobals,
  Windows,
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls;

type

  { TfrmScaling }

  TfrmScaling = class(TForm)
    cbLocked: TCheckBox;
    cbLockedDrawing: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    tbHeightDrawing: TTrackBar;
    tbWidth: TTrackBar;
    tbHeight: TTrackBar;
    tbWidthDrawing: TTrackBar;
    procedure cbLockedChange(Sender: TObject);
    procedure cbLockedDrawingChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure tbHeightChange(Sender: TObject);
    procedure tbHeightDrawingChange(Sender: TObject);
    procedure tbWidthChange(Sender: TObject);
    procedure tbWidthDrawingChange(Sender: TObject);

  private
    { private declarations }
    MazeMetrics: TMazeUpdateInfo;

    procedure CheckLock(pCB: TCheckBox; pMaster, pSlave: TTrackBar);
    procedure UpdateMaze;

  public
    { public declarations }
  end;

var
  frmScaling: TfrmScaling;

implementation

{$R *.lfm}

{ TfrmScaling }

procedure TfrmScaling.FormCreate(Sender: TObject);
begin
  // Get some global settings
  tbWidth.Min  := C_MIN_MAZE_SIZE;
  tbWidth.Max  := C_MAX_MAZE_SIZE;
  tbHeight.Min := C_MIN_MAZE_SIZE;
  tbHeight.Max := C_MAX_MAZE_SIZE;

  // Because of an omission on the OI the checkbox font
  // needs to be set separately
  cbLocked.Font.Style := [];
  cbLocked.Font.Color := Label1.Font.Color;
  cbLockedDrawing.Font.Style := [];
  cbLockedDrawing.Font.Color := Label1.Font.Color;
end;

procedure TfrmScaling.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction := caHide;
end;

procedure TfrmScaling.CheckLock(pCB: TCheckBox; pMaster, pSlave: TTrackBar);
begin
  if pCB.Checked then
    if pMaster.Position <> pSlave.Position then
      pSlave.Position := pMaster.Position;
  UpdateMaze;
end;

procedure TfrmScaling.UpdateMaze;
begin
  with MazeMetrics do
  begin
    MazeWidth  := tbWidth.Position;
    MazeHeight := tbHeight.Position;
    DrawWidth  := tbWidthDrawing.Position;
    DrawHeight := tbHeightDrawing.Position;
  end;
  SendMessage(Application.MainFormHandle, C_MAZE_UPDATE_MESSAGE, LongInt(@MazeMetrics), 0);
end;

procedure TfrmScaling.cbLockedChange(Sender: TObject);
begin
  CheckLock(cbLocked, tbWidth, tbHeight);
end;

procedure TfrmScaling.cbLockedDrawingChange(Sender: TObject);
begin
  CheckLock(cbLockedDrawing, tbWidthDrawing, tbHeightDrawing)
end;

procedure TfrmScaling.tbHeightChange(Sender: TObject);
begin
  CheckLock(cbLocked, tbHeight, tbWidth)
end;

procedure TfrmScaling.tbHeightDrawingChange(Sender: TObject);
begin
  CheckLock(cbLockedDrawing, tbHeightDrawing, tbWidthDrawing)
end;

procedure TfrmScaling.tbWidthChange(Sender: TObject);
begin
  CheckLock(cbLocked, tbWidth, tbHeight)
end;

procedure TfrmScaling.tbWidthDrawingChange(Sender: TObject);
begin
  CheckLock(cbLockedDrawing, tbWidthDrawing, tbHeightDrawing)
end;

end.

