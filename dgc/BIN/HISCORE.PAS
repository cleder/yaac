{The Delpi Games Creator - Beta 3
 --------------------------------
 Copyright 1996 John Pullen, Paul Bearne
 
 This unit is part of the freeware Delphi Games Creator. This unit is
 completely free to use for personal or commercial use. The code is
 supplied with no guarantees on performance or stabilibty and must be 
 used at your own risk.
} 
unit hiscore;

interface

uses
  Windows, Messages, SysUtils, Classes,
  Graphics, Controls, Forms, Dialogs,DGC,Inifiles;

type
  letterrec = record
          X,Y,X1,Y1:integer;
          letter:char;
  end;

  TDGCHiScore = class(TComponent)
  private
    { Private declarations }
    FScreen:TDGCScreen;
    FMainCaption:String;
    FOptionsCaption:String;
    FShowlevel:Boolean;

  protected
    { Protected declarations }
    FScores:array[1..10] of String;
    FIniFile:Tinifile;
    letterdata:array[1..33] of letterrec;
    Currentletterpos:integer;
    Namestring:string;
    numofchar:integer;
    completed:boolean;
    userscore:longint;
    userlevel:integer;
    Function PadString(data:String):String;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
    Function GetScore(Index:Integer):string;
    Procedure ReadData;
    Procedure WriteData;
    procedure ModifyHiScore;
    Procedure GetUserName;
    procedure doKey;
  public
    Constructor Create(anOwner:Tcomponent);override;
    Procedure Execute(Score:longint;level:integer);
    Procedure Showscores;
    function CheckHiScore(score:longint;level:integer):Boolean;
  published
    { Published declarations }
    Property Showlevel:Boolean Read FShowLevel Write FShowlevel;
    Property MainCaption:String read FmainCaption write FMainCaption ;
    Property SubCaption:string read FOptionsCaption write FOptionsCaption ;
    Property DGCScreen: TDGCScreen read FScreen write FScreen;

  end;

implementation

Constructor TDGCHiScore.Create(anowner:tcomponent);
var
   i:integer;
   PathName:string;
begin
    inherited Create(anowner);
    pathname:=Extractfilepath(Application.ExeName);
    FiniFile:=TIniFile.Create(pathname+'\Hiscore.Dat');
    FScreen:=Nil;
    FShowLevel := True;
    FMainCaption:='Top Ten Scores';
    FOptionsCaption:='Press Esc to Exit';
    for i:= 1 to 10 do
         FScores[i]:=('Noname                   00 00000000');

end;

Function TDGCHiScore.CheckHiScore(Score:longint;level:integer):boolean;
var
   tempscore:real;
   templevel:integer;
   code:integer;
   tempstring:string;
begin
     readdata;
     result:=false;
     tempstring:=copy(FScores[10],length(FScores[10])-8,8);
     val(tempstring,tempscore,code);
     if score > tempscore then
        result:=true;
     if score = tempscore then
     begin
          val(copy(FScores[10],26,2),templevel,code);
          if level > templevel then
              result:=true;
     end;
end;

procedure TDGCHiScore.ModifyHiScore;
var
   tempscore:longint;
   templevel:integer;
   code:integer;
   tempstring:string;
   found:boolean;
   count:integer;
   i:integer;

begin
     found:=false;
     count:=0;
     i:=0;
     // need to modify to except higher levels and scores
     if userlevel > 99 then
        userlevel:=99;
     if userscore> 99999999 then
        userscore := 99999999;
     while (not found) and (i <= 10)do
     begin
          inc(i);
          tempstring:=copy(FScores[i],length(FScores[i])-8,9);
          val(tempstring,tempscore,code);
          if Userscore > tempscore then
          begin
             found:=true;
             count:=i;
          end;
          if Userscore = tempscore then
          begin
               val(copy(FScores[i],26,2),templevel,code);
               if userlevel > templevel then
               begin
                  found:=true;
                  count:=i;
               end;
         end;
     end;
     if found then
     begin
          for i:=9 downto count do
              FScores[i+1]:=FScores[i];
          FScores[count]:=Format('%s %0.2d %0.8d',[Padstring(namestring),userlevel,userScore]);
     end;
end;

procedure TDGCHiScore.execute(score:longint;level:integer);
var
   key:word;
   i:integer;
   j:longint;
begin
     NumOfChar:=0;
     Currentletterpos:=1;
     userscore:=score;
     userlevel:=level;
     GetUserName;
     completed:=false;
     Readdata;
     while not completed do
     begin
          dokey;
          // tacky delay
          for j:= 1 to 2000000 do;
     end;
end;

Procedure TDGCHiScore.WriteData;
var
   i:integer;
begin
     if Assigned(FIniFile) then
     begin
          for i:= 1 to 10 do
              with FiniFile do
                    WriteString('HighScores',format('%d',[i]),FScores[i]);
     end;
end;



function TDGCHiScore.padstring(data:string):string;
begin
     while length(data) < 24 do
           data:=data+' ';
     result:=data;
end;

Procedure TDGCHiScore.ShowScores;
var
   Vidwidth:integer;
   msgstring:string;
   row,i:integer;
begin
     ReadData;
     FScreen.Back.EraseRect(FScreen.Back.clientrect, 0);
     with FScreen.Back.Canvas do
     begin
          Vidwidth:=FScreen.Back.Width div 2;
          Font.Size := 20;
          row:=110;
          Font.Color := clmaroon;
          msgstring:=FmainCaption;
          TextOut(Vidwidth - (Textwidth(msgstring) div 2),10,msgstring);
          Font.Color := clred;
          TextOut(Vidwidth - (Textwidth(msgstring) div 2)+1,11,msgstring);
          font.size:=8;
          Font.color:=claqua;
          textout(150,80,'Name');
          if FShowlevel then
          textout(340,80,'Level');
          textout(480,80,'Score');
          for i:= 1 to 10 do
          begin
               msgstring:=copy(Fscores[i],1,24);
               Font.color:=clolive;
               TextOut(100,row,msgstring);
               Font.Color := clyellow;
               TextOut(101,row+1,msgstring);
               msgstring:=copy(Fscores[i],26,2);
               font.color:=clolive;
               if FShowlevel then
                  TextOut(350,row,msgstring);
               Font.Color := clyellow;
               if Fshowlevel then
                 TextOut(351,row+1,msgstring);
               msgstring:=copy(Fscores[i],29,8);
               Font.Color:=Clolive;
               TextOut(470,row,msgstring);
               Font.Color := clyellow;
               TextOut(471,row+1,msgstring);
               inc(row,30);

          end;
          Font.Size:=10;
          Font.Color:=clwhite;
          msgstring:=FOptionsCaption;
          TextOut(Vidwidth - (Textwidth(msgstring) div 2),FScreen.Back.Height-30,msgstring);
          Release;
     end;
     FScreen.Flip;
end;

procedure TDGCHiScore.GetUserName;
var
   Vidwidth:integer;
   msgstring:string;
   col,row,i:integer;
begin
     //Erase the area that the sprite will bounce in
     FScreen.Back.EraseRect(FScreen.Back.clientrect, 0);
     with FScreen.Back.Canvas do
     begin
          Brush.Style := bsClear;
          Vidwidth:=FScreen.Back.Width div 2;
          Font.Size := 24;
          Font.color:=clolive;
          Textout(Vidwidth - (Textwidth('New High Score Enter Your Name') div 2),30,
                  'New High Score Enter Your Name');
          Font.color:=clYellow;
          Textout(Vidwidth - (Textwidth('New High Score Enter Your Name') div 2)+1,30+1,
                  'New High Score Enter Your Name');
          col:=1;
          row:=100;
          for i:= ord('A') to ord('Z') do
          begin
               msgstring:=chr(i);
               inc(col,Textwidth('W')+20);
               if col+(textwidth('W')*2) > FScreen.Back.Width  then
               begin
                    Col:=textwidth('W')+20;
                    inc(row,TextHeight('A')+10);
               end;
               with Letterdata[(i-Ord('A'))+1] do
               begin
                    X:=Col - 10;
                    Y:=Row - 5;
                    X1:=Col +TextWidth('W')+10;
                    Y1:=Row+ TextHeight('A')+5;
                    Letter:=chr(i);
               end;
               Font.Color := clgreen;
               TextOut(col,row,msgstring);
               Font.Color := cllime;
               TextOut(col+1,row+1,msgstring);
          end;
          inc(col,Textwidth('W')+20);
          Font.Color := clgreen;
          msgstring:='*';
          with LetterData[27] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:='*';
          end;
          TextOut(col,row,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+1,msgstring);
          inc(col,Textwidth('W')+20);
          Font.Color := clgreen;
          msgstring:='-';
          with LetterData[28] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:='-';
          end;
          TextOut(col,row,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+1,msgstring);
          inc(col,textwidth('W')+20);
          msgstring:='.';
          with LetterData[29] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:='.';
          end;
          TextOut(col,row,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+1,msgstring);
          inc(col,textwidth('W')+20);
          msgstring:=':';
          with LetterData[30] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:=':';
          end;
          TextOut(col,row,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+1,msgstring);
          inc(col,textwidth('W')+20);
          Font.Color := clgreen;
          msgstring:='Space';
          with LetterData[31] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:=' ';
          end;
          font.size:=8;
          TextOut(col,row+10,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+11,msgstring);
          Font.Size:=24;
          inc(col,Textwidth('W')+20);

          Font.Color := clgreen;
          msgstring:='BackUp';
          with LetterData[32] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:=#7;
          end;
          Font.size:=8;
          TextOut(col,row+10,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+11,msgstring);
          font.size:=24;
          inc(col,Textwidth('W')+20);
          Font.Color := clgreen;
          msgstring:='Done';
          with LetterData[33] do
          begin
               X:=Col - 10;
               Y:=Row - 5;
               X1:=Col +TextWidth('W')+10;
               Y1:=Row+ TextHeight('A')+5;
               Letter:=#27;
          end;
          Font.size:=8;
          TextOut(col,row+10,msgstring);
          Font.Color := cllime;
          TextOut(col+1,row+11,msgstring);
          Pen.Color:=Clwhite;
          With Letterdata[currentletterpos] do
             rectangle(X,Y,X1,Y1);
          Font.Size:=14;
          Textout(VidWidth - (textwidth(Namestring) div 2),Row+100,namestring);
          Font.Size:=14;
          Font.Color:=clyellow;
          msgstring:='Use Cursor Keys to Highlight Character';
          Textout(VidWidth - (textwidth(msgstring) div 2),Row+150,msgstring);
          msgstring:='Enter Key to Select';
          Textout(VidWidth - (textwidth(msgstring) div 2),Row+180,msgstring);
          msgstring:='Select Done When Finished';
          Textout(VidWidth - (textwidth(msgstring) div 2),Row+210,msgstring);
          msgstring:='Esc to Cancel';
          Textout(VidWidth - (textwidth(msgstring) div 2),Row+240,msgstring);
          Release;
     end;
     FScreen.Flip;
end;

// for debug puposes only unit should be totaly self contained
Function TDGCHiScore.GetScore(Index:Integer):string;
begin
     if (Index < 1 ) or (Index > 10) then
        exit
     else
         result:=FScores[Index];
end;

procedure TDGCHiScore.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
  begin
       if FScreen = AComponent then
          FScreen := nil;
  end;
end;

procedure TDGCHiScore.doKey;
var
   F:TextFile;
begin
        if FScreen.keydown(vk_left) then
        begin
           dec(currentletterpos);
           if currentletterpos < 1 then currentletterpos:=33;
           getusername;
        end;
        if FScreen.keydown(vk_up) then
        begin
             dec(currentletterpos,11);
             // put it back to where it was
             if currentletterpos < 1 then
                inc(currentletterpos,11);
             getusername;
        end;
        if FScreen.keydown(vk_right) then
        begin
           inc(Currentletterpos);
           if currentletterpos > 33 then currentletterpos:=1;
           getusername;
        end;
        if FScreen.keydown(vk_down) then
        begin
             inc(currentletterpos,11);
             // put it back to where it was
             if currentletterpos > 33 then
                dec(currentletterpos,11);
             getusername;
        end;
        if Fscreen.keydown(vk_return) then
        begin
             case currentletterpos of
                    1..31:begin
                               if numofchar < 24 then
                               begin
                                    namestring:=namestring+letterdata[currentletterpos].letter;
                                    inc(numofchar);
                               end;
                           end;
                       32:begin
                               delete(namestring,length(namestring),1);
                               dec(numofchar);
                               if numofchar < 0 then numofchar:=0;
                          end;
                       33:begin
                               // code to write high score to table
                               modifyhiscore;
                               WriteData;
                               completed:=true;
                               exit;
                          end;
              end;
              getusername;
        end;
        if Fscreen.keydown(vk_escape) then
          Completed:=true;

end;

procedure TDGCHiScore.Readdata;
var
   i:integer;
begin
     if assigned(FiniFile) then
     begin
          for i:= 1 to 10 do
          begin
               with FiniFile do
                    FScores[i]:=ReadString('HighScores',format('%d',[i]),'Noname                   00 00000000');
          end;
     end;
end;

end.
