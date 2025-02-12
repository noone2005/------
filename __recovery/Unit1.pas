unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.Menus, System.JSON, System.IOUtils, System.UITypes,
  System.Generics.Collections;

type
  TNodeData = class
    Title: string;
    Content: string;
    Level: Integer;
  end;

  TForm1 = class(TForm)
    pnlLeft: TPanel;
    pnlRight: TPanel;
    Splitter1: TSplitter;
    TreeView1: TTreeView;
    Memo1: TMemo;
    MainMenu1: TMainMenu;
    PopupMenu1: TPopupMenu;
    mnuFile: TMenuItem;
    mnuSave: TMenuItem;
    mnuLoad: TMenuItem;
    mnuAddLevel1: TMenuItem;
    mnuAddLevel2: TMenuItem;
    mnuAddLevel3: TMenuItem;
    mnuDelete: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Timer1: TTimer;
    StatusBar1: TStatusBar;

    procedure FormCreate(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure Memo1Change(Sender: TObject);
    procedure mnuAddLevel1Click(Sender: TObject);
    procedure mnuAddLevel2Click(Sender: TObject);
    procedure mnuAddLevel3Click(Sender: TObject);
    procedure mnuDeleteClick(Sender: TObject);
    procedure mnuSaveClick(Sender: TObject);
    procedure mnuLoadClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure TreeView1Editing(Sender: TObject; Node: TTreeNode;
      var AllowEdit: Boolean);
    procedure TreeView1Edited(Sender: TObject; Node: TTreeNode;
      var S: string);
  private
    FCurrentNode: TTreeNode;
    FAutoSaveFile: string;
    FNeedSave: Boolean;
    procedure AddNode(Level: Integer);
    procedure SaveTreeToJson(const FileName: string);
    procedure LoadTreeFromJson(const FileName: string);
    procedure ClearNodeData;
    procedure AutoSave;
    procedure SaveIfNeeded;
    procedure LoadLastSession;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  DefaultNoteFile: string;
begin
  Caption := '大飞的笔记本';
  
  // 设置窗体属性
  Width := 1200;
  Height := 600;
  Position := poScreenCenter;
  
  // 设置面板属性
  pnlLeft.Align := alLeft;  // 确保左面板靠左对齐
  pnlRight.Align := alClient;  // 确保右面板填充剩余空间
  
  // 设置分隔条属性
  Splitter1.Align := alLeft;  // 分隔条必须和被分隔的面板使用相同的对齐方式
  Splitter1.Parent := Self;  // 确保分隔条的父容器是窗体
  Splitter1.Left := pnlLeft.Left + pnlLeft.Width;  // 设置分隔条的初始位置
  
  // 确保正确的控件顺序
  pnlLeft.BringToFront;
  Splitter1.BringToFront;
  pnlRight.SendToBack;
  
  // 设置TreeView属性
  TreeView1.Align := alClient;
  TreeView1.HideSelection := False;
  
  // 设置Memo属性
  Memo1.Align := alClient;
  Memo1.ScrollBars := ssBoth;
  Memo1.Enabled := False;  // 初始时禁用Memo
  Memo1.Font.Name := '微软雅黑';
  Memo1.Font.Size := 11;
  
  // 设置菜单项标题
  mnuFile.Caption := '文件(&F)';
  mnuSave.Caption := '保存(&S)';
  mnuLoad.Caption := '打开(&O)';
  mnuAddLevel1.Caption := '添加一级目录';
  mnuAddLevel2.Caption := '添加二级目录';
  mnuAddLevel3.Caption := '添加三级目录';
  mnuDelete.Caption := '删除';
  
  // 设置对话框属性
  SaveDialog1.Filter := '记事本文件(*.note)|*.note';
  OpenDialog1.Filter := '记事本文件(*.note)|*.note';
  
  // 设置默认笔记文件路径
  DefaultNoteFile := ExtractFilePath(Application.ExeName) + '我的笔记.note';
  
  // 添加调试信息
  StatusBar1.SimpleText := '正在检查文件: ' + DefaultNoteFile;
  
  // 修改自动保存文件路径
  FAutoSaveFile := DefaultNoteFile;  // 使用同一个文件
  FNeedSave := False;
  Timer1.Interval := 3000;  // 3秒检查一次是否需要保存
  Timer1.Enabled := True;
  
  // 设置保存对话框初始目录和文件名
  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  SaveDialog1.FileName := '我的笔记.note';
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  
  // 使用 LoadLastSession 方法加载数据
  LoadLastSession;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  SaveIfNeeded;
end;

procedure TForm1.SaveIfNeeded;
begin
  if FNeedSave then
  begin
    AutoSave;
    FNeedSave := False;
  end;
end;

procedure TForm1.AutoSave;
var
  BackupFile: string;
begin
  if TreeView1.Items.Count = 0 then
    Exit; // 如果没有数据，不进行保存
    
  try
    // 创建备份文件
    BackupFile := ChangeFileExt(FAutoSaveFile, '.bak');
    if FileExists(FAutoSaveFile) then
    begin
      if FileExists(BackupFile) then
        DeleteFile(BackupFile);
      RenameFile(FAutoSaveFile, BackupFile);
    end;
    
    // 保存新文件
    SaveTreeToJson(FAutoSaveFile);
    StatusBar1.SimpleText := '自动保存成功: ' + FormatDateTime('hh:nn:ss', Now);
  except
    on E: Exception do
    begin
      StatusBar1.SimpleText := '自动保存失败: ' + E.Message;
      
      // 尝试恢复备份
      if FileExists(BackupFile) then
      begin
        try
          if FileExists(FAutoSaveFile) then
            DeleteFile(FAutoSaveFile);
          RenameFile(BackupFile, FAutoSaveFile);
          StatusBar1.SimpleText := StatusBar1.SimpleText + ' (已恢复备份)';
        except
          StatusBar1.SimpleText := StatusBar1.SimpleText + ' (备份恢复失败)';
        end;
      end;
      
      Timer1.Enabled := False;
    end;
  end;
end;

procedure TForm1.AddNode(Level: Integer);
var
  Node: TTreeNode;
  Data: TNodeData;
  Title: string;
begin
  Title := InputBox('新建目录', '请输入目录名称:', '');
  if Title = '' then Exit;
  
  Data := TNodeData.Create;
  Data.Title := Title;
  Data.Content := '';
  Data.Level := Level;
  
  Node := nil;  // 初始化 Node 变量
  
  try
    case Level of
      1: Node := TreeView1.Items.AddChild(nil, Title);
      2: begin
           if (TreeView1.Selected = nil) or (TNodeData(TreeView1.Selected.Data).Level <> 1) then
           begin
             ShowMessage('请先选择一级目录！');
             Exit;
           end;
           Node := TreeView1.Items.AddChild(TreeView1.Selected, Title);
         end;
      3: begin
           if (TreeView1.Selected = nil) or (TNodeData(TreeView1.Selected.Data).Level <> 2) then
           begin
             ShowMessage('请先选择二级目录！');
             Exit;
           end;
           Node := TreeView1.Items.AddChild(TreeView1.Selected, Title);
         end;
    end;
    
    if Assigned(Node) then
    begin
      Node.Data := Data;
      Node.Selected := True;
      FNeedSave := True;  // 添加节点后标记需要保存
    end
    else
      Data.Free;  // 如果没有创建节点，释放数据对象
      
  except
    on E: Exception do
    begin
      Data.Free;  // 发生异常时释放数据对象
      raise;  // 重新抛出异常
    end;
  end;
end;

procedure TForm1.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  if Node = nil then
  begin
    Memo1.Clear;
    Memo1.Enabled := False;
    Exit;
  end;
  
  FCurrentNode := Node;
  Memo1.Enabled := True;
  
  try
    if Assigned(Node.Data) then
    begin
      Memo1.Text := TNodeData(Node.Data).Content;
      StatusBar1.SimpleText := '当前编辑: ' + TNodeData(Node.Data).Title;
    end
    else
    begin
      Memo1.Clear;
      StatusBar1.SimpleText := '警告: 节点数据丢失';
    end;
  except
    on E: Exception do
    begin
      Memo1.Clear;
      StatusBar1.SimpleText := '加载节点内容失败: ' + E.Message;
    end;
  end;
end;

procedure TForm1.Memo1Change(Sender: TObject);
begin
  if FCurrentNode = nil then Exit;
  
  try
    if Assigned(FCurrentNode.Data) then
    begin
      TNodeData(FCurrentNode.Data).Content := Memo1.Text;
      FNeedSave := True;  // 内容改变后标记需要保存
      
      // 如果内容非空，在节点文本前添加标记
      if Trim(Memo1.Text) <> '' then
      begin
        if Copy(FCurrentNode.Text, 1, 2) <> '* ' then
          FCurrentNode.Text := '* ' + TNodeData(FCurrentNode.Data).Title;
      end
      else
      begin
        if Copy(FCurrentNode.Text, 1, 2) = '* ' then
          FCurrentNode.Text := TNodeData(FCurrentNode.Data).Title;
      end;
    end;
  except
    on E: Exception do
      StatusBar1.SimpleText := '保存内容失败: ' + E.Message;
  end;
end;

procedure TForm1.mnuAddLevel1Click(Sender: TObject);
begin
  AddNode(1);
end;

procedure TForm1.mnuAddLevel2Click(Sender: TObject);
begin
  AddNode(2);
end;

procedure TForm1.mnuAddLevel3Click(Sender: TObject);
begin
  AddNode(3);
end;

procedure TForm1.mnuDeleteClick(Sender: TObject);
begin
  if TreeView1.Selected = nil then Exit;
  
  if MessageDlg('确定要删除选中的目录吗？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    if Assigned(TreeView1.Selected.Data) then
      TNodeData(TreeView1.Selected.Data).Free;
    TreeView1.Selected.Delete;
    Memo1.Clear;
    FNeedSave := True;  // 删除节点后标记需要保存
  end;
end;

procedure TForm1.SaveTreeToJson(const FileName: string);
var
  Root: TJSONObject;
  NodesArray: TJSONArray;
  JsonStr: string;
  
  // 添加 JSON 格式化函数
  function FormatJson(const JsonString: string): string;
  var
    IndentLevel: Integer;
    I: Integer;
    C: Char;
    InQuotes: Boolean;
    PrevChar: Char;
    
    procedure AddIndent;
    var
      J: Integer;
    begin
      Result := Result + #13#10;
      for J := 1 to IndentLevel * 2 do
        Result := Result + ' ';
    end;
    
  begin
    Result := '';
    IndentLevel := 0;
    InQuotes := False;
    PrevChar := #0;
    
    for I := 1 to Length(JsonString) do
    begin
      C := JsonString[I];
      
      case C of
        '"': 
          if PrevChar <> '\' then
            InQuotes := not InQuotes;
            
        '{', '[':
          if not InQuotes then
          begin
            Inc(IndentLevel);
            Result := Result + C;
            AddIndent;
          end
          else
            Result := Result + C;
            
        '}', ']':
          if not InQuotes then
          begin
            Dec(IndentLevel);
            AddIndent;
            Result := Result + C;
          end
          else
            Result := Result + C;
            
        ',':
          if not InQuotes then
          begin
            Result := Result + C;
            AddIndent;
          end
          else
            Result := Result + C;
            
        else
          Result := Result + C;
      end;
      
      PrevChar := C;
    end;
  end;
  
  procedure AddNodeToJson(Node: TTreeNode; ParentArray: TJSONArray);
  var
    NodeObj: TJSONObject;
    ChildArray: TJSONArray;
    Child: TTreeNode;
  begin
    if not Assigned(Node) then Exit;
    
    NodeObj := TJSONObject.Create;
    NodeObj.AddPair('title', TNodeData(Node.Data).Title);
    NodeObj.AddPair('content', TNodeData(Node.Data).Content);
    NodeObj.AddPair('level', TJSONNumber.Create(TNodeData(Node.Data).Level));
    NodeObj.AddPair('expanded', TJSONBool.Create(Node.Expanded));
    
    if Node.HasChildren then
    begin
      ChildArray := TJSONArray.Create;
      Child := Node.getFirstChild;
      while Assigned(Child) do
      begin
        AddNodeToJson(Child, ChildArray);
        Child := Child.getNextSibling;
      end;
      NodeObj.AddPair('children', ChildArray);
    end;
    
    ParentArray.AddElement(NodeObj);
  end;
  
begin
  Root := TJSONObject.Create;
  NodesArray := TJSONArray.Create;
  
  try
    Root.AddPair('version', '1.1');
    Root.AddPair('saveTime', DateTimeToStr(Now));
    
    var Node := TreeView1.Items.GetFirstNode;
    while Assigned(Node) do
    begin
      if Node.Level = 0 then
        AddNodeToJson(Node, NodesArray);
      Node := Node.getNextSibling;
    end;
    
    Root.AddPair('nodes', NodesArray);
    
    // 格式化 JSON 字符串
    JsonStr := FormatJson(Root.ToString);
    
    // 保存格式化后的 JSON 字符串
    TFile.WriteAllText(FileName, JsonStr, TEncoding.UTF8);
  finally
    Root.Free;
  end;
end;

procedure TForm1.LoadTreeFromJson(const FileName: string);
var
  JsonText: string;
  Root: TJSONObject;
  SaveTime: string;
  Version: string;

  procedure LoadNodeFromJson(ParentNode: TTreeNode; NodeObj: TJSONObject);
  var
    NewNode: TTreeNode;
    Data: TNodeData;
    ChildArray: TJSONArray;
    I: Integer;
    IsExpanded: Boolean;
  begin
    Data := TNodeData.Create;
    Data.Title := NodeObj.GetValue<string>('title');
    Data.Content := NodeObj.GetValue<string>('content');
    Data.Level := NodeObj.GetValue<Integer>('level');
    
    NewNode := TreeView1.Items.AddChild(ParentNode, Data.Title);
    NewNode.Data := Data;
    
    // 恢复节点的展开状态
    if NodeObj.TryGetValue<Boolean>('expanded', IsExpanded) then
      NewNode.Expanded := IsExpanded;
    
    if NodeObj.TryGetValue<TJSONArray>('children', ChildArray) then
    begin
      for I := 0 to ChildArray.Count - 1 do
        LoadNodeFromJson(NewNode, ChildArray.Items[I] as TJSONObject);
    end;
  end;

begin
  if not FileExists(FileName) then
    Exit;
    
  JsonText := TFile.ReadAllText(FileName, TEncoding.UTF8);
  Root := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
  
  try
    // 检查文件版本 - 修改版本检查逻辑
    if Root.TryGetValue<string>('version', Version) then
    begin
      if not (Version = '1.0') and not (Version = '1.1') then
        raise Exception.Create('不支持的文件版本');
    end;
      
    // 获取保存时间
    if Root.TryGetValue<string>('saveTime', SaveTime) then
      StatusBar1.SimpleText := '最后保存时间: ' + SaveTime;
    
    ClearNodeData;
    TreeView1.Items.Clear;
    
    var NodesArray := Root.GetValue<TJSONArray>('nodes');
    if Assigned(NodesArray) then
    begin
      for var I := 0 to NodesArray.Count - 1 do
        LoadNodeFromJson(nil, NodesArray.Items[I] as TJSONObject);
    end;
  finally
    Root.Free;
  end;
end;

procedure TForm1.mnuSaveClick(Sender: TObject);
begin
  SaveDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  SaveDialog1.FileName := '我的笔记.note';
  
  if SaveDialog1.Execute then
  begin
    try
      SaveTreeToJson(SaveDialog1.FileName);
      // 如果保存的是默认文件，更新自动保存路径
      if LowerCase(SaveDialog1.FileName) = LowerCase(FAutoSaveFile) then
        StatusBar1.SimpleText := '笔记已保存'
      else
        StatusBar1.SimpleText := '文件已保存为: ' + ExtractFileName(SaveDialog1.FileName);
    except
      on E: Exception do
        ShowMessage('保存失败: ' + E.Message);
    end;
  end;
end;

procedure TForm1.mnuLoadClick(Sender: TObject);
begin
  OpenDialog1.InitialDir := ExtractFilePath(Application.ExeName);
  
  if OpenDialog1.Execute then
  begin
    try
      LoadTreeFromJson(OpenDialog1.FileName);
      // 如果打开的是默认文件，更新自动保存路径
      if LowerCase(OpenDialog1.FileName) = LowerCase(FAutoSaveFile) then
      begin
        StatusBar1.SimpleText := '已加载: 我的笔记.note';
      end
      else
      begin
        StatusBar1.SimpleText := '已打开文件: ' + ExtractFileName(OpenDialog1.FileName);
        // 询问是否设为默认笔记
        if MessageDlg('是否将此文件设为默认笔记？', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          FAutoSaveFile := OpenDialog1.FileName;
          StatusBar1.SimpleText := '已设为默认笔记: ' + ExtractFileName(OpenDialog1.FileName);
        end;
      end;
    except
      on E: Exception do
        ShowMessage('加载失败: ' + E.Message);
    end;
  end;
end;

procedure TForm1.ClearNodeData;
var
  I: Integer;
begin
  for I := 0 to TreeView1.Items.Count - 1 do
    if Assigned(TreeView1.Items[I].Data) then
      TNodeData(TreeView1.Items[I].Data).Free;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled := False;
  
  // 保存最后的状态
  if FNeedSave then
  begin
    try
      if TreeView1.Items.Count > 0 then
        SaveTreeToJson(FAutoSaveFile);
    except
      // 关闭时的保存错误可以忽略
    end;
  end;
  
  ClearNodeData;
end;

procedure TForm1.TreeView1Editing(Sender: TObject; Node: TTreeNode;
  var AllowEdit: Boolean);
begin
  AllowEdit := True;  // 允许编辑节点文本
end;

procedure TForm1.TreeView1Edited(Sender: TObject; Node: TTreeNode;
  var S: string);
begin
  if Assigned(Node.Data) then
  begin
    TNodeData(Node.Data).Title := S;
    FNeedSave := True;  // 节点标题改变后标记需要保存
  end;
end;

procedure TForm1.LoadLastSession;
begin
  // 实现 LoadLastSession 方法的逻辑
end;

end.
