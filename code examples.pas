// ����� ������� ������� ����� ������������ � ������ �� ���������� ������ �������.
function TTMUserShiftsGridFrame.GetShiftIndexByCell: Integer;
var
  TmpDate: TDateTime;
  I, UserID: Integer;
begin
  if (UserShiftsStringGrid.Selection.Left > 0) and
     (UserShiftsStringGrid.Selection.Top > 0) then
  begin
    I := UserShiftsStringGrid.Selection.Top - 1;
    UserID := FUsers[I].Id;

    I := UserShiftsStringGrid.Selection.Left - 1;
    TmpDate := StartOfTheWeekByOSSettings(DateTimePicker.Date) + I;

    Result := GetShiftIndex(UserID, TmpDate);
  end
  else
    Result := -1;
end;


// ������ ������� � �������� ������ ��������� �����.
procedure TTaskManager.ServiceStart(Sender: TService; var Started: Boolean);
begin
  LoadSettings();

  if not DirectoryExists(ExtractFilePath(paramstr(0)) + 'Log') then
    CreateDir(ExtractFilePath(paramstr(0)) + 'Log');

  TaskManagerThread := TTaskManagerThread.Create;
  with TaskManagerThread do
  begin
    Priority := tpNormal;
    FreeOnTerminate := False;
    Resume;
  end;
end;


// ����� ������ �� ��������� � ������� ���������� ������� ������.
procedure GetAllFiles(APath: String; AListBox: TListBox; AExt:String);
var
  SRec: TSearchRec;
  IsFound: Boolean;
  MS: TMemoryStream;
  Tmp: String;
begin
  MS:=TMemoryStream.Create;
  AListBox.Items.Clear;

  try
    IsFound := (FindFirst(APath + '\*.*', faAnyFile, SRec) = 0);
    while IsFound do
    begin
      if (SRec.Name <> '.') and (SRec.Name <> '..') then
      begin
        if (SRec.Attr and faDirectory) = faDirectory then
          GetAllFiles(APath + '\' + SRec.Name, AListBox, AExt);

        if (Pos(AExt, AnsiLowerCase(SRec.Name)) > 0) and
           (Pos(AExt + '_', AnsiLowerCase(SRec.Name)) = 0) then
        begin
          Tmp := APath + '\' + SRec.Name;
          AListBox.Items.Add(Tmp);
          MS.Clear;
          MS.LoadFromFile(Tmp);
          UploadDataSize := UploadDataSize + MS.Size;
        end;
      end;
      Application.ProcessMessages;
      IsFound := (FindNext(SRec) = 0);
    end;
    FindClose(SRec);
  finally
    MS.Free;
  end;
end;


// ������ ������������� ��������� �� ����� ��� �������� ����.
procedure TMap.DrawMarquee(X, Y:integer);
begin
  // ���� ��������� � ��������� ���������.
  if bMarquee = True then
  begin
    // ������� ���������� ������������� ���������.
    Canvas.Pen.Mode := pmNotXor;
    Canvas.Rectangle(MouseDownX, MouseDownY, PosX, PosY);

    // ���� ���������� �������, �������� �����������.
    if Assigned(FOnSelfDraw) then
    begin
      Canvas.CopyMode := cmSrcCopy;
      Canvas.CopyRect(Rect(0, 0, Width, Height), FSelfDrawPicture.Canvas,
        Rect(0, 0, Width, Height));
    end;

    // ������ ����� ������������� ���������.
    Canvas.Pen.Mode := pmNotXor;
    Canvas.Rectangle(MouseDownX, MouseDownY, X, Y);
    Canvas.Pen.Mode := pmCopy;
    PosX := X;
    PosY := Y;
  end;
end;
