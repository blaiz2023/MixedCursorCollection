unit main;

interface
{$ifdef gui4} {$define gui3} {$define gamecore}{$endif}
{$ifdef gui3} {$define gui2} {$define net} {$define ipsec} {$endif}
{$ifdef gui2} {$define gui}  {$define jpeg} {$endif}
{$ifdef gui} {$define snd} {$endif}
{$ifdef con3} {$define con2} {$define net} {$define ipsec} {$endif}
{$ifdef con2} {$define jpeg} {$endif}
{$ifdef WIN64}{$define 64bit}{$endif}
{$ifdef fpc} {$mode delphi}{$define laz} {$define d3laz} {$undef d3} {$else} {$define d3} {$define d`3laz} {$undef laz} {$endif}
uses gossfold, gossmake, gossroot, {$ifdef gui}gossgui, gosstext,{$endif} {$ifdef snd}gosssnd,{$endif} gosswin, gosswin2, gossio, gossimg, gossnet, gossfast, gossteps{$ifdef gamecore}, gossgame ,gamefiles{$endif};
{$B-} {generate short-circuit boolean evaluation code -> stop evaluating logic as soon as value is known}
//## ==========================================================================================================================================================================================================================
//##
//## MIT License
//##
//## Copyright 2026 Blaiz Enterprises ( http://www.blaizenterprises.com )
//##
//## Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
//## files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
//## modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
//## is furnished to do so, subject to the following conditions:
//##
//## The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//##
//## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//## OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//## LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//## CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//##
//## ==========================================================================================================================================================================================================================
//## Library.................. app code (main.pas)
//## Version.................. 2.00.7535 (+62)
//## Items.................... 2
//## Last Updated ............ 30jul2026, 25jun2026, 18jun2026, 16jun2026, 14jun2026, 05jun2026, 02jun2026, 30may2026, 29may2026, 28may2026, 27may2026, 25may2026, 23may2026, 22may2026, 15may2026, 09may2026, 08may2026, 06may2026, 05may2026, 04may2026, 03may2026
//## Lines of Code............ 2,900
//## Origin .................. Human generated and maintained
//##
//## main.pas ................ App specific code
//## gossdat.pas ............. App specific icons and help documents
//## gossfast.pas ............ FastDraw - rapid render graphic procs
//## gossgame.pas ............ GameCore - 2D game engine with integrated menu handler, xbox controller + mouse + keyboard support and window integration
//## gamefiles.pas ........... Built-in file(s) for GameCore (optional)
//## gossgui.pas ............. GUI management and controls
//## gossimg.pas ............. Multi-format graphic procs for 8, 24 and 32 bit images with IO support
//## gossio.pas .............. File IO and low level file/folder/disk/data format procs
//## gossjpg.pas ............. JPEG IO (read/write jpeg image data via third party libraries)
//## gossnet.pas ............. Networking - ip filtering, socket management etc
//## gossroot.pas ............ App startup and control (GUI, console and service)
//## gosssnd.pas ............. Sound, audio, midi and midi based chimes
//## gossteps.pas ............ System, Folder and App images
//## gosstext.pas ............ TextCore - non-GUI and GUI text engine for text boxes
//## gosswin.pas ............. Win32 api calls for 32 and 64 bit (static / api references disabled by default)
//## gosswin2.pas ............ Win32 api calls for 32 and 64 bit (dynamic - load as required with fallback failure handling and default value(s) support)
//## gosszip.pas ............. ZIP IO (read/write zip data via third party libraries)
//##
//## ==========================================================================================================================================================================================================================
//## | Name                   | Hierarchy         | Version   | Date        | Update history / brief description of function
//## |------------------------|-------------------|-----------|-------------|--------------------------------------------------------
//## | tapp                   | tbasicapp         | 1.00.030  | 30jul2026   | App as host - 06jun2026, 09may2026
//## | tarchive               | tbasicscroll      | 1.00.475  | 30jul2026   | Interactive archive - 16jun2026, 14jun2026, 06jun2026, 29may2026, 25may2026, 23may2026, 22may2026, 14may2026, 11may2026, 09may2026, 06may2026, 05may2026, 04may2026, 03may2026
//## ==========================================================================================================================================================================================================================
//## Performance Note:
//##
//## The runtime compiler options "Range Checking" and "Overflow Checking", when enabled under Delphi 3
//## (Project > Options > Complier > Runtime Errors) slow down graphics calculations by about 50%,
//## causing ~2x more CPU to be consumed.  For optimal performance, these options should be disabled
//## when compiling.
//## ==========================================================================================================================================================================================================================


var
   itimerbusy           :boolean=false;
   iapp                 :tobject=nil;

const



   //archive -------------------------------------------------------------------

   //replace mode
   rm_cancel            =0;
   rm_skipall           =1;
   rm_no                =1;
   rm_replaceall        =2;
   rm_yes               =2;
   rm_max               =2;


type


{tarchive}
   tarchive=class(tbasicscroll)
   private

    istarted                 :boolean;
    istartfile               :string;
    ifirstfileload           :boolean;
    ishowmore                :boolean;
    isettingsREF             :string;

    ifolderhub               :tfolderhub;
    ifilehub                 :tfilehub;
    ifilehubREF              :longint32;

    itimerfast               :longint64;
    itimer500                :longint64;

    iautoscroll              :boolean;
    iautoscrollCOUNT         :longint32;

    ilastsaveone_folder      :string;
    ilastsaveall_folder      :string;
    ilastcursorSchemeName    :string;

    ilastdatatype            :tdatatype;

    ilastpointersizeREF      :longint64;
    ilastpointersize         :longint32;

    itopbar                  :tbasictoolbar;
    itopbarSep               :tbasicbreak;
    imorebar                 :tmanagedata;
    imorebarSep              :tbasicbreak;
    iccbar                   :tmanagecustomcursorcolors;
    iccbarSep                :tbasicbreak;

    isep1                    :longint32;
    isep2                    :longint32;
    ibotbar                  :tbasictoolbar;

    iroller255               :longint;
    irollerUP                :boolean;

    istatusbar               :tbasicstatus;

    i_overview               :longint32;
    i_type                   :longint32;
    i_filesize               :longint32;
    i_colors                 :longint32;
    i_cells                  :longint32;
    i_dimensions             :longint32;
    i_bits                   :longint32;
    i_fps                    :longint32;
    i_misc                   :longint32;
    i_words                  :longint32;
    i_chars                  :longint32;
    i_tracks                 :longint32;
    i_cursorSize             :longint32;
    i_cursorSchemeInfo       :longint32;
    i_cursorSchemeInfo2      :longint32;
    i_max                    :longint32;

    procedure __onsync(sender:tobject);
    procedure __onclick(sender:tobject);
    procedure xcmd(const xcode2:string);
    procedure xupdatebuttons;
    procedure xhidecellsfrom(const xfrom:longint);
    function cursor__formatSupported(const xext:string)                           :boolean;
    function cursor__formatSupportedForStatus(const xext:string)                  :boolean;
    procedure cursor__install(sender:tobject;xpromptForCustomName:boolean);
    procedure dialog__suppressAllFormatOptions(x:boolean);
    function xmousePointerSize                                                    :longint32;

    //temp folder
    function xtempfolder(const xautocreate:boolean):string;
    procedure xcleantempfolder(const optionalSubFolder:string);

    //install folder
    function xinstallfolder(const xautocreate:boolean)                            :string;
    procedure xcleaninstallfolder;

    function xpromptReplaceAll(const xmsg:string)                                 :longint32;
    function xpromptContinueWriting(const xmsg:string)                            :boolean;
    function xhelpval(const x:string)                                             :string;
    function xhelpval2(const x:string;const xfull:boolean)                        :string;
    procedure setcelltext(xindex:longint;xtext:string);

    function xfilesize                                                            :string;

    //support
    property  celltext[xindex:longint]                                            :string             write setcelltext;

   public

    //create
    constructor create(xparent:tobject;const xstartfile:string);                                      virtual;
    constructor create2(xparent:tobject;xstartfile:string;xscroll,xstart:boolean);                    virtual;
    destructor  destroy;                                                                              override;
    procedure   _ontimer(sender:tobject);                                                             override;

    //settings
    function  settings                                                            :string;            virtual;
    procedure setsettings(const x:string);                                                            virtual;
    function  settingsFilename                                                    :string;
    procedure loadsettings;
    procedure savesettings;
    procedure autosavesettings;

    //io
    function  cansaveone                                                          :boolean;
    procedure saveone__tofile;

    function  cansaveall                                                          :boolean;
    procedure saveall__tofolder(const xuseTempFolder:boolean);

   end;


{tapp}
   tapp=class(tbasicapp)
   private

    iloaded                     :boolean;
    ibuildingcontrol            :boolean;
    itimer500                   :longint64;
    iarchive                    :tarchive;

    procedure xloadsettings;
    procedure xsavesettings;
    procedure xautosavesettings;
    procedure xupdatebuttons;
    procedure __onclick(sender:tobject);
    procedure xcmd(const xcode2:string);
    function xpromptCloseAndCleanUp                                               :longint32;

   public

    //create
    constructor create;                                                           virtual;
    destructor  destroy;                                                          override;
    procedure __ontimer(sender:tobject);                                          override;

   end;




//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024


//app procs --------------------------------------------------------------------
//.create / destroy
procedure app__remove;//does not fire "app__create" or "app__destroy"
procedure app__create;
procedure app__destroy;

//.event handlers
function app__onmessage(m,w,l:longint):longint;
procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
procedure app__onpaint(sw,sh:longint);
procedure app__ontimer;

//.support procs
function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
procedure app__customTEP(const xindex:longint);
function app__syncandsavesettings:boolean;


//support procs ----------------------------------------------------------------

function fastvars2__new:tfastvars2;


//archive support procs --------------------------------------------------------

procedure archive__initFolders(const xfolderhub:tfolderhub);
procedure archive__initFiles(const xfilehub:tfilehub);


implementation

{$ifdef gui}
uses
    gossdat;
{$endif}


//info procs -------------------------------------------------------------------
function app__info(xname:string):string;
begin
result:=info__rootfind(xname);
end;

function info__app(xname:string):string;//information specific to this unit of code - 20jul2024: program defaults added, 23jun2024
begin
//defaults
result:='';

try
//init
xname:=strlow(xname);

//get
if      (xname='slogan')              then result:=info__app('name')+' by Blaiz Enterprises'
else if (xname='width')               then result:='1500'
else if (xname='height')              then result:='1000'

else if (xname='language')            then result:='english-australia'//for Clyde - 14sep2025
else if (xname='codepage')            then result:='1252'
else if (xname='msix.tags')           then result:='-'//for Clyde - 31jan2026
else if (xname='msstore.name')        then result:='BlaizMixedCursorCollection'//optional - overrides default name for Clyde - 15apr2026

else if (xname='ver')                 then result:='2.00.7535'
else if (xname='date')                then result:='30jul2026'
else if (xname='name')                then result:='MixedCursorCollection'
else if (xname='web.name')            then result:='mixedcursorcollection'//used for website name
else if (xname='des')                 then result:='Collection of mixed color animated and static cursor schemes'
else if (xname='infoline')            then result:=info__app('name')+#32+info__app('des')+' v'+app__info('ver')+' (c) 1997-'+low__yearstr(2024)+' Blaiz Enterprises'
else if (xname='size')                then result:=low__b(io__filesize64(io__exename),true)
else if (xname='diskname')            then result:=io__extractfilename(io__exename)
else if (xname='service.name')        then result:=info__app('name')
else if (xname='service.displayname') then result:=info__app('service.name')
else if (xname='service.description') then result:=info__app('des')

//.links and values
else if (xname='linkname')            then result:=info__app('name')+' by Blaiz Enterprises.lnk'
else if (xname='linkname.vintage')    then result:=info__app('name')+' (Vintage) by Blaiz Enterprises.lnk'

//.author
else if (xname='author.shortname')    then result:='Blaiz'
else if (xname='author.name')         then result:='Blaiz Enterprises'
else if (xname='portal.name')         then result:='Blaiz Enterprises - Portal'
else if (xname='portal.tep')          then result:=intstr32(tepBE20)

//.software
else if (xname='url.software')        then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.html'
else if (xname='url.software.zip')    then result:='https://www.blaizenterprises.com/'+info__app('web.name')+'.zip'

//.urls
else if (xname='url.portal')          then result:='https://www.blaizenterprises.com'
else if (xname='url.contact')         then result:='https://www.blaizenterprises.com/contact.html'
else if (xname='url.facebook')        then result:='https://web.facebook.com/blaizenterprises'
else if (xname='url.mastodon')        then result:='https://mastodon.social/@BlaizEnterprises'
else if (xname='url.twitter')         then result:='https://twitter.com/blaizenterprise'
else if (xname='url.x')               then result:=info__app('url.twitter')
else if (xname='url.instagram')       then result:='https://www.instagram.com/blaizenterprises'
else if (xname='url.sourceforge')     then result:='https://sourceforge.net/u/blaiz2023/profile/'
else if (xname='url.github')          then result:='https://github.com/blaiz2023'

//.program/splash
else if (xname='license')             then result:='MIT License'
else if (xname='copyright')           then result:='© 1997-'+low__yearstr(2025)+' Blaiz Enterprises'
else if (xname='splash.web')          then result:='Web Portal: '+app__info('url.portal')


//------------------------------------------------------------------------------
//.special options - 04may2026 -------------------------------------------------

else if (xname='back.name')           then result:='Gradient Purple (Scrolling)'//default background name
else if (xname='splash.show')         then result:='0'//hide the splash screen

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

else
   begin
   //nil
   end;

except;end;
end;


//app procs --------------------------------------------------------------------
procedure app__create;
begin
{$ifdef gui}
iapp:=tapp.create;
{$else}

//.starting...
app__writeln('');
//app__writeln('Starting server...');

//.visible - true=live stats, false=standard console output
scn__setvisible(false);


{$endif}
end;

procedure app__remove;
begin
try

except;end;
end;

procedure app__destroy;
begin
try
//save
//.save app settings
app__syncandsavesettings;

//free the app
freeobj(@iapp);
except;end;
end;

function app__syncandsavesettings:boolean;
begin
//defaults
result:=false;
try
//.settings
{
app__ivalset('powerlevel',ipowerlevel);
app__ivalset('ramlimit',iramlimit);
{}


//.save
app__savesettings;

//successful
result:=true;
except;end;
end;

function app__netmore:tnetmore;//optional - return a custom "tnetmore" object for a custom helper object for each network record -> once assigned to a network record, the object remains active and ".clear()" proc is used to reduce memory/clear state info when record is reset/reused
begin
result:=tnetbasic.create;
end;

procedure app__customTEP(const xindex:longint);

   procedure mc(const sm ,sc:array of byte);//mono + color
   begin

   tep__20( xindex ,sm ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure m32(const sm:array of byte);//mono only
   begin

   tep__32( xindex ,sm ,[0] ,it_rle8 ,it_img32 );

   end;

   procedure c(const sc:array of byte);//color only
   begin

   tep__20( xindex ,[0] ,sc ,it_rle8 ,it_img32 );

   end;

   procedure m6(const sm:array of byte);//mono only
   begin

   tep__20( xindex ,sm ,[0] ,it_rle6 ,it_img32 );

   end;

begin

{
case xindex of
tepScrollDown20       :m( mtep_ScrollDown20    );
end;//case
{}

end;

function app__onmessage(m,w,l:longint):longint;
begin
//defaults
result:=0;
end;

procedure app__onpaintOFF;//called when screen was live and visible but is now not live, and output is back to line by line
begin
//nil
end;

procedure app__onpaint(sw,sh:longint);
begin
//console app only
end;

procedure app__ontimer;
begin
try
//check
if itimerbusy then exit else itimerbusy:=true;//prevent sync errors

//last timer - once only
if app__lasttimer then
   begin

   end;

//check
if not app__running then exit;


//first timer - once only
if app__firsttimer then
   begin

   end;



except;end;
try
itimerbusy:=false;
except;end;
end;


//support procs ----------------------------------------------------------------

function fastvars2__new:tfastvars2;
begin

result:=tfastvars2.create2( 60000 );//60K items

end;


//## tarchive ##################################################################


procedure archive__initFolders(const xfolderhub:tfolderhub);
begin


//option 1 - basic single folder archive configuration -------------------------
{
with xfolderhub do
begin

narchive('test');

nfinish;

end;
{}


//option 2 - multi-folder archive configuration with Home folder as root -------

with xfolderhub do
begin


//narchive('test');//debug support

{
nhome;
ncursorsRed         ([ ccl_default , ccl_modern ]);
}


nhome;


//narchive('test');//????????????????


ncursorsMixed       ([ ccl_default , ccl_modern ]);
ncursorsRainbow     ([ ccl_default , ccl_modern ]);
ncursorsCustomColor ([ ccl_default , ccl_modern ]);


nfinish;

end;

end;

procedure archive__initFiles(const xfilehub:tfilehub);
begin

//create in prority importance
with xfilehub do
begin

nmidi('');
ncursorScheme('');//13jun2026
nsprite('');
nimage('');
ntext('');

end;

end;


constructor tarchive.create(xparent:tobject;const xstartfile:string);
begin

create2(xparent,xstartfile,false,true);

end;

constructor tarchive.create2(xparent:tobject;xstartfile:string;xscroll,xstart:boolean);
const
   vLeftWidth         =33;
   vRightWidth        =100-vLeftWidth;
   vTopHeight         =50;
   vBotHeight         =100-vTopHeight;

var
   p                  :longint32;

begin

//self
if classnameis('tarchive') then track__inc(satOther,1);
inherited create2(xparent,false,false);

//require gamecore support
need_gamecore;

//vars
//was: bordersize                   :=0;
istarted                     :=false;
oautoheight                  :=true;
ominheight                   :=1;
itimerfast                   :=slowms64;
itimer500                    :=slowms64;
ifilehubREF                  :=-1;

istartfile                   :=xstartfile;
ifirstfileload               :=true;
ishowmore                    :=true;
isettingsREF                 :='';

ilastpointersizeREF          :=0;
ilastpointersize             :=1;

iroller255                   :=255;
irollerUP                    :=false;

ilastsaveone_folder          :='';
ilastsaveall_folder          :='';
ilastcursorSchemeName        :='';

iautoscroll                  :=false;
iautoscrollCOUNT             :=0;

ilastdatatype                :=dt_none;

//controls

//left area --------------------------------------------------------------------
xcols.style           :=bcLeftToRight;

with xcols.makecol(0,vLeftWidth,false) do
begin

oclsarea                     :=false;

ifolderHub                   :=tfolderhub.create( client );

archive__initFolders( ifolderHub );

ifolderHub.start( false );

end;


//right area--------------------------------------------------------------------

with xcols.makecol(1,vRightWidth,false) do
begin

oclsarea              :=false;

//topbar -----------------------------------------------------------------------

itopbar               :=xhigh.ntoolbar('');
itopbarSep            :=xhigh.nbreak(10);

with itopbar do
begin

normal                :=false;

add('More Options',tepDownward20,0,'more','Show More|Show additional options');

add('Copy',tepCopy20,0,'copy','');
add('Cells',tepCopy20,0,'copyall','');//16jun2026

isep1                 :=addsep;

add('PNG',tepCopy20,0,'copy.b64.png',xhelpval('copy.b64.png'));
add('JPG',tepCopy20,0,'copy.b64.jpg',xhelpval('copy.b64.jpg'));
add('ICO',tepCopy20,0,'copy.b64.ico',xhelpval('copy.b64.ico'));
add('GIF',tepCopy20,0,'copy.b64.gif',xhelpval('copy.b64.gif'));

isep2                 :=addsep;

add('PNG',tepCopy20,0,'copy.array.png',xhelpval('copy.array.png'));
add('JPG',tepCopy20,0,'copy.array.jpg',xhelpval('copy.array.jpg'));
add('ICO',tepCopy20,0,'copy.array.ico',xhelpval('copy.array.ico'));
add('GIF',tepCopy20,0,'copy.array.gif',xhelpval('copy.array.gif'));

end;


//morebar ----------------------------------------------------------------------

imorebar              :=tmanagedata.create( xhigh.client );//top
imorebarSep           :=xhigh.nbreak(2);

iccbar                :=tmanagecustomcursorcolors.create( xhigh.client );//bottom
iccbarSep             :=xhigh.nbreak(10);



//filehub ----------------------------------------------------------------------

ifilehub                     :=tfilehub.create( client );

archive__initFiles( ifileHub );

ifilehub.start( ifolderHub );

with xhigh2 do
begin

nbreak(10);
ibotbar               :=ntoolbar('');
nbreak(10);


with ibotbar do
begin
//xgrad;

normal                :=false;
maketitle3('Archive Extraction Options',true,false);
halign                :=1;

help:=
 'Archive Extraction Options'+
 '|For security reasons the files in this interactive archive have been embedded directly into the app. '+
 'To access the files on your computer, choose one of the options below:'+
 '|*'+
 '| 1. View in temp folder (Recommended)'+
 '| 2. Save files to a folder...'+
 '| 3. Save a file to disk...'+
 '|*|Note:|'+
 'If options 1. or 2. are not enabled, then navigate to a folder (left column) to view it''s contents, which will enable these options.'+
 '';


newline;

lsadd('View in temp folder',tepOpen20,0,'savefiles.totemp',

 'View In Temp Folder (Recommended)'+
 '|Extract files from the current folder (left column) to a dedicated temporary folder in order to view and/or access the files directly on your computer.'+
 '|*|There is no need to confirm during the extraction process as the files will be stored in an isolated temporary folder.'+
 '|*|Clean Up:|All files in the temporary folder will be automatically removed upon closing this app.'+
 ''

,-30);//realtime help set via xupdatebuttons


lsadd('Save files to a folder...',tepSave20,0,'saveall.tofolder',

 'Save Files To A Folder'+
 '|Extract files from the current folder (left column) to a folder of your choice.'+
 '|*|If one or more files with the same name already exists in the destination folder you will be prompted for overwrite confirmation before any file is extracted.'+
 ''

,-30);//realtime help set via xupdatebuttons


lsadd('Save a file to disk...',tepSave20,0,'saveone.tofile',
 'Save A File To Disk'+
 '|Save the currently selected file to disk with a name of your choice.'+
 '',-30);

with oinputcolorise do
begin

use         :=true;
minlen      :=0;
backTRUE    :=int__splice24( 0.75 ,0 ,cllime );
backFALSE   :=clred;
code        :=icTrue;

end;

end;

end;//xhigh2

end;


//bottom statusbar
i_overview                      :=0;
i_type                          :=1;
i_filesize                      :=2;

//.image
i_dimensions                    :=i_filesize + 1;
i_colors                        :=i_filesize + 2;
i_bits                          :=i_filesize + 3;
i_cells                         :=i_filesize + 4;
i_fps                           :=i_filesize + 5;
i_cursorSize                    :=i_filesize + 6;

//.text
i_words                         :=i_filesize + 1;
i_chars                         :=i_filesize + 2;

//.midi
i_tracks                        :=i_filesize + 1;

//.cursor scheme
i_cursorSchemeInfo              :=i_filesize + 1;
i_cursorSchemeInfo2             :=i_filesize + 2;

//.other
i_misc                          :=8;
i_max                           :=8;

istatusbar                      :=gui.rootwin.xstatus2;//use main GUI's bottom toolbar - 23jul2026
istatusbar.cellwidth[ i_max+1 ] :=1;

with istatusbar do
begin

cellhelp[ i_overview ]          :='Folder Information|Information about the currently open folder';
cellhelp[ i_type     ]          :='Category|Descriptive summary of the currently selected file';
cellhelp[ i_filesize ]          :='File Size|The uncompressed size of the currently selected file';

end;


//connect hubs together
ifolderhub .setfilehub   ( ifilehub   );
ifilehub   .setfolderhub ( ifolderhub );

//events
itopbar.onclick                 :=__onclick;
ibotbar.onclick                 :=__onclick;
ifilehub.onsync                 :=__onsync;
imorebar.on__cursorInstall      :=cursor__install;

//defaults
istarted                        :=true;

loadsettings;

//start
if xstart then start;

end;

destructor tarchive.destroy;
begin
try

//savesettings
autosavesettings;

//clean temp folders
xcleantempfolder('');
xcleaninstallfolder;

//turn off temp cursor - 06may2026
cursor__untemp;

//self
inherited destroy;
if classnameis('tarchive') then track__inc(satOther,-1);

except;end;
end;

procedure tarchive.cursor__install(sender:tobject;xpromptForCustomName:boolean);
label
   skipend;

var
   b                  :tfolderbase;
   dfolder            :string;
   df                 :string;//inf -> installer script
   n                  :string;
   p                  :longint32;
   dfullindex         :longint32;
   xresult            :boolean;
   v32                :longint32;
   xexitcode          :longint32;

begin

//defaults
xresult               :=false;
v32                   :=0;
b                     :=nil;

try

//init
b                     :=ifolderhub.folderCurrent;

if (b=nil) then exit;


//prompt for custom scheme name
if xpromptForCustomName then
   begin

   ilastcursorSchemeName        :=strdefb( ilastcursorSchemeName ,'My Scheme' );

   if not gui.popedit( ilastcursorSchemeName ,'Type a name for your Cursor Scheme','' ) then
      begin

      exit;

      end;

   //filter
   ilastcursorSchemeName        :=io__safename( ilastcursorSchemeName );

   //override cursor's internal filename with supplied user's name
   b.ouserfilename              :=ilastcursorSchemeName + '.inf';

   end;


//clean folder
xcleaninstallfolder;


//auto-create
dfolder     :=xinstallfolder( true );


//save cursor scheme to install folder
for p:=0 to max32 do
begin

if b.findindex( b.itemindex ,p ,dfullindex ) then//file specific testing
   begin

   //get
   n                  :=dfolder + io__extractfilename( b.full__filename( dfullindex ,0 ) );

   //.inf installer fileanme
   if (p=0) then
      begin

      df              :=n;

      end;

   //set
   if not b.full__savefile( dfullindex ,n ,v32 ) then goto skipend;

   end

else break;//stop

end;//p


//install the cursor scheme
if (not io__runwait2('rundll32.exe','advpack.dll,LaunchINFSection "'+df+'",DefaultInstall,,3',60000,true,xexitcode)) then
   begin

   goto skipend;

   end;

//successful
xresult               :=true;

skipend:

except;end;

//clean up
xcleaninstallfolder;

//turn-off
if (b<>nil) then
   begin

   b.ouserfilename    :='';

   end;

//finalise
if xresult then
   begin

   gui.popStatus( 'Cursor scheme installed' ,2 );

   //display dialog for user to select the cursor scheme
   imorebar.mousePropertiesDialog;

   end

else begin

   gui.popStatus( 'Cursor scheme installation failed' ,2 );

   end;

end;

procedure tarchive._ontimer(sender:tobject);
const
   vroller_max        =255;
   vroller_min        =60;
   vroller_step       =5;
   vroller_power      =1.0;
   vroller_idleUP     =false;
   vidle_period       =10000;//10s

begin
try

//.itimerfast
if (ms64>=itimerfast) then
   begin

   //iroller255 ----------------------------------------------------------------

   //.up
   if irollerUP then
      begin

      inc(iroller255,vroller_step);

      if (iroller255>vroller_max) then
         begin

         iroller255   :=vroller_max;

         if (not vroller_idleUP) or (low__inputidle>=vidle_period) then
            begin

            irollerUP :=false;

            end;

         end;
      end

   //.down
   else begin

      dec(iroller255,vroller_step);

      if (iroller255<vroller_min) then
         begin

         iroller255   :=vroller_min;

         if vroller_idleUP or (low__inputidle>=vidle_period) then
            begin

            irollerUP :=true;

            end;

         end;

      end;

   //.repaint to reflect subtle change in background tint
   if low__setint( ibotbar.oinputcolorise.backTRUE ,int__splice24( (1-vroller_power) + ((iroller255/255)*vroller_power) ,0 ,vinormal.highlight ) ) then
      begin

      ibotbar.paintnow;
      app__turbo;

      end;

   //reset
   itimerfast:=add64( ms64 ,30 );

   end;

//.itimer500
if (slowms64>=itimer500) or low__setint(ifilehubREF,ifilehub.fileindex) then
   begin

   //update buttons etc
   xupdatebuttons;

   //autosavesettings
   autosavesettings;

   //reset
   itimer500:=add64( slowms64 ,500 );

   end;

except;end;
end;

function tarchive.xmousePointerSize:longint32;
begin

if (ms64>=ilastpointersizeREF) then
   begin

   ilastpointersize   :=frcmin32( (strint32(reg__readval(0,'Control Panel\Cursors\CursorBaseSize',true)) div 16) - 1 ,1 );
   ilastpointersizeREF:=add64( ms64 ,1500 );

   end;

result                :=ilastpointersize;

end;

function tarchive.settingsFilename:string;
begin

result      :=app__folderSettings(true) + 'archive-settings.ini';

end;

procedure tarchive.loadsettings;
begin

if istarted then
   begin

   setsettings( io__fromfilestr2( settingsFilename ) );

   isettingsREF       :=settings;

   end;

end;

procedure tarchive.savesettings;
begin

if istarted then
   begin

   isettingsREF       :=settings;

   io__tofilestr2( settingsFilename ,isettingsREF );

   end;

end;

procedure tarchive.autosavesettings;
begin

if istarted and low__setstr( isettingsREF ,settings ) then
   begin

   savesettings;

   end;

end;

function tarchive.settings:string;

   procedure i32(const n:string;const v:longint32);
   begin

   result:=result+n+': '+intstr32(v)+#10;

   end;

   procedure b(const n:string;const v:boolean);
   begin

   result:=result+n+': '+bolstr(v)+#10;

   end;

   procedure s(const n,v:string);
   begin

   result:=result+n+': '+v+#10;

   end;

begin

//defaults
result      :='';

//check
if not istarted then exit;

//add values
b  ( 'showmore'    ,ishowmore       );
b  ( 'usepng'      ,cursor_usepng   );
i32( 'wantsize'    ,cursor_wantsize );
end;

procedure tarchive.setsettings(const x:string);
var
   a:tvars8;

begin

//check
if not istarted then exit;

//defaults
a                     :=nil;

try

//init
a                     :=tvars8.create;
a.text                :=x;

//get
ishowmore             :=a.bdef( 'showmore' ,true  );
cursor_usepng         :=a.bdef( 'usepng'   ,false );
cursor_wantsize       :=a.idef( 'wantsize' ,128     ); 

except;end;

//free
freeobj(@a);

end;

function tarchive.xhelpval(const x:string):string;
begin

result:=xhelpval2(x,true);

end;

function tarchive.xhelpval2(const x:string;const xfull:boolean):string;
begin

if      (x='copy.array.tea')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in 32 bit TEA format. Image data can be directly included into any Gossamer app source code.'
else if (x='copy.array.png')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in PNG format.'
else if (x='copy.array.jpg')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in JPEG format.'
else if (x='copy.array.gif')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in GIF format.'+xhelpval('gif.restriction')
else if (x='copy.array.ico')  then result:='Copy Image|Copy image to Clipboard as a Pascal array in ICO format.'
else if (x='copy.b64.png')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format PNG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
else if (x='copy.b64.jpg')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format JPEG. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
else if (x='copy.b64.ico')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format ICO. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'
else if (x='copy.b64.gif')    then result:='Copy Image|Copy image to Clipboard as base64 encoded text in mime/type format GIF. Image data can be inserted into HTML code, or viewed by pasting it into your browser''s address bar.'+xhelpval('gif.restriction')

else if (x='gif.restriction') then result:='|*|'+'Format Restriction|The GIF image format can only store 2 mask values (on and off) and 256 colors. An image with subtle mask values, or 2 or more, or more than 256 colors may appear incorrectly.'

else
   begin

   result:='';

   end;

end;

procedure tarchive.__onsync(sender:tobject);
begin

xcmd( 'sync' );

end;

procedure tarchive.__onclick(sender:tobject);
begin

if (sender is tbasictoolbar)    then xcmd( (sender as tbasictoolbar).ocode2 );

end;

procedure tarchive.xcmd(const xcode2:string);
var
   xresult            :boolean;
   v                  :string;
   e                  :string;
   v32                :longint32;
   x                  :tbasicimgview;//pointer only
   y                  :tbasicbwp;//pointer only
   z                  :tbasicimage;//pointer only

   function mv(const x:string):boolean;
   begin

   result   :=strm(xcode2,x,v,v32);

   end;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin


//defaults
xresult               :=true;
e                     :=gecTaskfailed;
v                     :='';
v32                   :=0;


//get
if m('more') then
   begin

   ishowmore:=not ishowmore;

   end


//-- top toolbar ---------------------------------------------------------------

else if m('copy')           then ifilehub.copyformat( fc_copy    )
else if m('copyall')        then ifilehub.copyformat( fc_copyAll )

else if m('copy.array.png') then ifilehub.copyformat( fc_pngPascal )
else if m('copy.array.jpg') then ifilehub.copyformat( fc_jpgPascal )
else if m('copy.array.ico') then ifilehub.copyformat( fc_icoPascal )
else if m('copy.array.gif') then ifilehub.copyformat( fc_gifPascal )

else if mv('copy.b64.png')  then ifilehub.copyformat( fc_pngB64 )
else if mv('copy.b64.jpg')  then ifilehub.copyformat( fc_jpgB64 )
else if mv('copy.b64.ico')  then ifilehub.copyformat( fc_icoB64 )
else if mv('copy.b64.gif')  then ifilehub.copyformat( fc_gifB64 )


//--archive extraction options -------------------------------------------------

else if m('saveone.tofile') then
   begin

   saveone__tofile;

   end

else if m('saveall.tofolder') then
   begin

   saveall__tofolder( false );

   end

else if m('savefiles.totemp') then
   begin

   saveall__tofolder( true );

   end

else if m('sync') then
   begin

   //nil

   end

else begin

   //nil

   end;


//finish
xupdatebuttons;

//sbow error
if not xresult then gui.poperror('',e);

end;

procedure tarchive.dialog__suppressAllFormatOptions(x:boolean);
begin

case x of
true:ia__useroptions_suppress(true,'*');
else ia__useroptions_suppress_clear;
end;//case

end;

function tarchive.cansaveone:boolean;
begin

result:=(ifolderhub.folderCurrent<>nil) and ifolderhub.isfile(0);

end;

procedure tarchive.saveone__tofile;
label
   redo;

var
   daction            :string;
   df                 :string;
   dfolder            :string;
   dext               :string;
   e                  :string;
   a                  :tstr8;
   b                  :tfolderbase;
   xsubfile           :longint32;

begin

//defaults
a           :=nil;

//check
if not cansaveone then exit;

try

//init
b           :=ifolderhub.folderCurrent;
dfolder     :='';
dialog__suppressAllFormatOptions( true );

//prompt
dext        :=io__readfileext_low(ifolderhub.filename(0));//force proper format extension

df          :=io__asfolderNIL( ilastsaveone_folder ) + io__extractfilename(ifolderhub.filename(0));

redo:

if gui.popsave3( df ,dext ,'' ,'' ,daction ,true ,true ) then//last "true" permits the dialog to use unknown file type(s) - 05may2026
   begin

   //init
   ilastsaveone_folder       :=io__extractfilepath( df );
   dfolder                   :=ilastsaveone_folder;
   a                         :=rescache__newStr8;


   //user has specified a different name -> switch to user file naming scheme mode
   if not strmatch( io__extractnameonly(df) ,io__extractnameonly(ifolderhub.filename(0)) ) then
      begin

      b.ouserfilename        :=df;//override normal filenames with new naming scheme

      end;

   //save main file and all subfiles
   for xsubfile:=0 to max32 do
   begin

   //.stop
   if not ifolderhub.cansubfile( xsubfile ) then//file specific testing
      begin

      break;

      end;

   //.save
   if (not ifolderhub.fromfile( xsubfile ,a )) or (not io__tofile64( dfolder + io__extractfilename( ifolderhub.filename(xsubfile) ) ,@a ,e )) then
      begin

      gui.popError('Save Failed',e);

      break;

      end;

   end;//xsubfile

   end;

//finish
dialog__suppressAllFormatOptions( false );

except;end;

//turn off user filename override
if (b<>nil) then
   begin

   b.ouserfilename           :='';

   end;

//free
rescache__delStr8( @a );

end;

function tarchive.cansaveall:boolean;
begin

result:=(ifolderhub.subcount>=1) and (ifolderhub.folderCurrent<>nil) and (not ifolderhub.atHome);

end;

procedure tarchive.saveall__tofolder(const xuseTempFolder:boolean);
label
   redo,skipone,skipCheck,skipend;

var
   flist              :tdynamicstring;
   flistREF           :tdynamiccomp;
   df                 :string;
   sfolder            :tfolderbase;
   sfolderSubPath     :string;
   dfolder            :string;
   dnameOnly          :string;
   dfolderLabel       :string;
   e                  :string;
   xreplaceMode       :longint32;
   fscanCount         :longint32;
   fsaveCount         :longint32;
   fskipCount         :longint32;
   ferrorCount        :longint32;
   psubFileID         :longint32;
   i                  :longint32;
   fbytes             :longint64;
   xstatusref         :longint64;
   xfastFileExistsOK  :boolean;
   xcheckOnly         :boolean;

   dfileExistsCount   :longint32;
   dpos               :longint32;
   xbytesWritten      :longint32;
   dfullindex         :longint32;

   dlist              :tdynamicbyte;//track repeat files

   procedure dstatus;
   begin

   sysstatus_settext(1,'File' + #9 + dnameOnly );
   sysstatus_settext(2,'Item'+#9+k64(dpos+1)+' / '+k64(sfolder.subcount));
   sysstatus_settext(3,'Files'+#9+k64(fscanCount));
   sysstatus_settext(4,'Errors'+#9+k64(ferrorCount));
   sysstatus_settext(5,'Skipped'+#9+k64(fskipCount));
   sysstatus_settext(6,'Size'+#9+low__mbAUTO2(fbytes,1,true)+' / '+low__mbAUTO2(largest64(fbytes,sfolder.subbytes),1,true));
   sysstatus_setpert(low__percentage64(dpos+1,sfolder.subcount));
   msset(xstatusref,100);

   end;

   procedure dstart;
   begin

   gui.xstatusstart(2.0,7);
   gui.xstatustab(tbDefault);
   sysstatus_settext(0,'Folder'+#9+dfolderLabel );
   sysstatus_settext(1,'File'+#9+'');
   sysstatus_settext(2,'Item'+#9+'');
   sysstatus_settext(3,'Files'+#9+k64(fscanCount));
   sysstatus_settext(4,'Errors'+#9+'');
   sysstatus_settext(5,'Skipped'+#9+'');
   sysstatus_settext(6,'Size'+#9+'');

   case xcheckOnly of
   true:gui.xstatus(0,'Checking files in folder...');
   else gui.xstatus(0,'Writing files to folder...');
   end;//case

   msset(xstatusref,100);

   end;

   procedure xfastfileexists__init;
   var
      p:longint32;

   begin

   //scan folder for files
   if not xuseTempFolder then
      begin

      //get file list from target folder -> for fast file checking, on error falls back to slow checker
      try

      case (flist=nil) of
      true:flist             :=tdynamicstring.create;
      else flist.clear;
      end;//case

      case (flistREF=nil) of
      true:flistREF          :=tdynamiccomp.create;
      else flistREF.clear;
      end;//case

      xfastFileExistsOK      :=io__filelist( flist ,false ,dfolder ,'*' ,'' );

      if xfastFileExistsOK then
         begin

         flistREF.setparams( flist.count ,flist.count ,0 );

         for p:=0 to pred(flist.count) do
         begin

         flistREF.items[p]  :=low__ref256U( flist.value[p] );

         end;//p

         end;

      except;end;

      //sync check
      if xfastFileExistsOK then
         begin

         xfastFileExistsOK:=(flist.count=flistREF.count);

         end;

      end;

   end;

   function xio__fileexists(const xnameOnly:string):boolean;
   var
      p:longint32;
      a:pdlBiLongint;
      xref:longint64;
      b:pbilongint;

   begin

   //defaults
   result   :=false;

   //ultra-fast check
   if xfastFileExistsOK then
      begin

      if (flist.count<=0) then exit;

      end

   //fast check has failed -> fallback to slow check
   else begin

      result:=io__fileexists( xnameonly );

      exit;

      end;

   //init
   xref     :=low__ref256U( xnameOnly );
   b        :=@xref;
   a        :=flistREF.core;

   //get
   for p:=0 to pred(flist.count) do
   begin

   if (a[p][0]=b[0]) and (a[p][1]=b[1]) and strmatch( xnameOnly ,flist.value[p] ) then
      begin

      result:=true;

      break;

      end;

   end;//p

   end;

   procedure xpause;
   begin

   ifolderhub.autoscrollpause;
   ifolderhub.renderPause;

   end;

   procedure xunpause;
   begin

   ifolderhub.autoscrollUnpause;
   ifolderhub.renderUnpause;

   end;

begin

//pause / stop scrolling
xpause;

//defaults
flist                 :=nil;
flistREF              :=nil;
dfileExistsCount      :=0;
xreplaceMode          :=rm_replaceall;//default mode
xstatusref            :=0;
xfastFileExistsOK     :=false;
dlist                 :=nil;

//check
if not cansaveall then
   begin

   xunpause;

   exit;

   end;

try

//init
sfolder               :=ifolderhub.folderCurrent;

if (sfolder=nil) then
   begin

   exit;

   end;

sfolderSubPath        :=sfolder.subfolder;
dlist                 :=tdynamicbyte.create;
dlist.setparams( sfolder.fullcount ,sfolder.fullcount ,0 );

//prompt
redo:

case xuseTempFolder of

true:xcleantempfolder( sfolderSubPath );//clean only this subFolder if already exists - 28jun2026

else begin

   if not gui.popfolder2(ilastsaveall_folder,'*','',true,true) then
      begin

      xunpause;

      exit;

      end;

   //ensure selected folder exists
   if not io__folderexists( ilastsaveall_folder ) then
      begin

      gui.poperror('','Folder not found');

      goto redo;

      end;

   end;

end;//case

if xuseTempFolder then
   begin

   dfolder            :=io__asfolderNIL( xtempfolder( true ) + sfolderSubPath);
   dfolderLabel       :=io__lastSubFolder( xtempfolder( false ) ) + '\' + sfolderSubPath;

   end
else begin

   dfolder            :=io__asfolderNIL( ilastsaveall_folder  + sfolderSubPath);
   dfolderLabel       :=io__lastSubFolder( ilastsaveall_folder ) + '\' + sfolderSubPath;

   end;

//start ------------------------------------------------------------------------

//init
fscanCount            :=0;
fsaveCount            :=0;
ferrorCount           :=0;
fskipCount            :=0;
fbytes                :=0;

xfastfileexists__init;

//get
for i:=0 to 1 do
begin

xcheckOnly            :=(i=0);
fscanCount            :=0;
dstart;//start status + clear "dlist"

//.clear done list
for dpos:=0 to pred(dlist.count) do
begin

dlist.items[dpos]     :=0;

end;//p

if xcheckOnly and xuseTempFolder then
   begin

   //temp folder does not need to perform file name overwrite checking
   goto skipCheck;

   end;

//.prompt to replace existing files
if (not xcheckOnly) and (not xuseTempFolder) and (dfileExistsCount<>0) then
   begin

   //hide
   gui.xstatusstop;

   //prompt
   if (dfileExistsCount>=1) then
      begin

      xreplaceMode       :=xpromptReplaceAll(

      rcode+
      'There are '+k64( dfileExistsCount )+' file'+insstr('s',dfileExistsCount<>1)+' in the destination folder '+
      'with the same name.  Do you wish to replace all the existing files with those from the archive?  '+

      '');

      end
   else if (dfileExistsCount=-1) then
      begin

      xreplaceMode       :=xpromptReplaceAll(

      rcode+
      'There maybe one or more files in the destination folder '+
      'with the same name, but the check task was cancelled.  Do you wish to continue and replace all the existing files with those from the archive?  '+

      '');

      end
   else if (dfileExistsCount<=-2) then
      begin

      xreplaceMode       :=xpromptReplaceAll(

      rcode+
      'There are at least '+k64( -dfileExistsCount )+' files in the destination folder '+
      'with the same name, maybe more, but the check task was cancelled.  Do you wish to replace all the existing files with those from the archive?  '+

      '');

      end;

   //cancelled
   if (xreplaceMode=rm_cancel) then goto skipend;

   //re-show
   dstart;

   end;


//file list --------------------------------------------------------------------

for dpos:=0 to pred(sfolder.subcount) do
begin


//subfileIDs (if supported) ----------------------------------------------------

for psubFileID:=0 to pred(max32) do
begin

//.time based status
if msok(xstatusref) or ( (dpos<=0) and (psubFileID<=0) ) then
   begin

   dstatus;

   end;

//.subfileID
if not sfolder.findindex( dpos ,psubFileID ,dfullindex ) then
   begin

   break;

   end;

if not sfolder.full__isfile( dfullindex ,0 ) then
   begin

   goto skipone;

   end;

//.check if user cancelled task
if gui.xstatustopped then
   begin

   //check task was cancelled -> prompt later
   if xcheckOnly then
      begin

      case (dfileExistsCount=0) of
      true:dfileExistsCount :=-1;//-1=signal to dialog the task was cancelled
      else dfileExistsCount :=-dfileExistsCount;//-n=signal task was cancelled with N files
      end;//case

      //.escape double loop
      goto skipCheck;

      end

   //write task was cancelled -> stop
   else begin

      //hide
      gui.xstatusstop;

      //prompt to continue writing
      if not xpromptContinueWriting(rcode+'Writing task was interrupted.  Do you wish to continue writing files to the target folder?') then
         begin

         goto skipend;

         end;

      //restart status - flush "stoppped" mode
      dstart;

      end;

   end;

//.write file to disk
if (dlist.value[ dfullindex ]<=0) then
   begin

   //init ----------------------------------------------------------------------

   inc32( fscanCount ,1 );

   dnameOnly          :=sfolder.full__filename( dfullindex ,0 );//require full access to get round mask restriction for subfiles
   df                 :=dfolder + dnameOnly;


   //.mark as done
   dlist.value[ dfullindex ]    :=1;


   //check if file(s) already exists -------------------------------------------

   if xcheckOnly then
      begin

      if xio__fileexists( dnameOnly ) then
         begin

         inc( dfileExistsCount );

         end;

      end

   //write files ---------------------------------------------------------------

   else
      begin

      if (xreplaceMode=rm_replaceAll) or (not io__fileexists( df )) then
         begin

         if sfolder.full__savefile( dfullindex ,df ,xbytesWritten ) then
            begin

            inc( fsaveCount );
            inc64( fbytes ,xbytesWritten );

            end

         else begin

            inc( ferrorCount );

            end;

         end

      else inc( fskipCount );

      end;

   end;


skipone:

end;//psubFileID ---------------------------------------------------------------


end;//p ------------------------------------------------------------------------


skipCheck:

end;//i

skipend:
except;end;

try

//status stop
gui.xstatusstop;

//popstatus
if (fsaveCount>=1) or (fskipcount>=1) or (ferrorCount>=1) then
   begin

   gui.popStatus(

    k64(fsaveCount)+' file'+insstr('s',fsaveCount<>1)+' written'+

    insstr(' with',(ferrorCount>=1) or (fskipCount>=1))+

    insstr( #32+k64(ferrorCount)+' error'+insstr('s',ferrorCount<>1) ,(ferrorCount>=1) )+

    insstr( ' and',(ferrorCount>=1) and (fskipCount>=1) )+

    insstr( #32+k64(fskipCount)+' skipped' ,(fskipCount>=1) )+

    '' ,2 );

   end;

//auto-show folder
if ((fsaveCount>=1) or (fskipCount>=1)) and io__folderexists( dfolder ) then
   begin

   runlow( dfolder ,'' );

   end;

except;end;

//free
freeobj(@flist);
freeobj(@flistREF);
freeobj(@dlist);

//unpause
xunpause;

end;

function tarchive.xinstallfolder(const xautocreate:boolean):string;
begin

result      :=app__folder2('install',xautocreate);

end;

procedure tarchive.xcleaninstallfolder;
var
   dfolder:string;
   flist:tdynamicstring;
   p:longint;

begin

//defaults
flist       :=nil;

try

//init
dfolder     :=xinstallfolder( false );
flist       :=tdynamicstring.create;


//delete files -----------------------------------------------------------------
io__filelist1( flist ,false ,true ,dfolder ,'*' ,'' );

for p:=0 to pred(flist.count) do io__remfile( dfolder + flist.value[ p ] );

//finalise -> remove install folder itself
io__deletefolder( dfolder );

except;end;

//free
freeobj(@flist);

end;

function tarchive.xtempfolder(const xautocreate:boolean):string;
begin

result      :=app__folder2('contents',xautocreate);

end;

procedure tarchive.xcleantempfolder(const optionalSubFolder:string);
var
   dfolder:string;
   flist:tdynamicstring;
   p:longint;

begin

//defaults
flist       :=nil;

try

//init
dfolder     :=io__asfolderNIL( xtempfolder( false ) + optionalSubFolder );
flist       :=tdynamicstring.create;


//delete files -----------------------------------------------------------------
io__filelist1( flist ,false ,true ,dfolder ,'*' ,'' );

for p:=0 to pred(flist.count) do io__remfile( dfolder + flist.value[ p ] );


//delete empty folders ---------------------------------------------------------
io__folderlist2( flist ,false ,true ,dfolder ,'*' ,'' );

for p:=0 to pred(flist.count) do io__deletefolder( dfolder + flist.value[ p ] );


//finalise -> remove temp folder itself
io__deletefolder( dfolder );


except;end;

//free
freeobj(@flist);

end;

function tarchive.cursor__formatSupported(const xext:string):boolean;
begin

result:=strmatch(xext,'cur') or strmatch(xext,'ani');

end;

function tarchive.cursor__formatSupportedForStatus(const xext:string):boolean;
begin

result:=strmatch(xext,'cur') or strmatch(xext,'ani') or strmatch(xext,'inf');

end;

function tarchive.xfilesize:string;
var
   xsubfile           :longint32;
   s                  :longint32;
   bol1               :boolean;
   xisApproximate     :boolean;

begin

//defaults
xisApproximate        :=false;

//get

//.folder size
if ifolderhub.isfolder(0) then
   begin

   result   :='-';

   end

//.file size
else begin

   //init
   s                  :=0;

   //get
   for xsubfile:=0 to max32 do
   begin

   if ifolderhub.cansubfileid( xsubfile ) then
      begin

      inc32( s ,ifolderhub.filesize2( xsubfile ,bol1 ) );

      if bol1 then
         begin

         xisApproximate      :=true;

         end;

      end

   else break;

   end;//xsubfile

   //set
   result             :=insstr('~ ',xisApproximate) + low__mbAUTO2( s ,1 ,true );

   end;

end;

procedure tarchive.setcelltext(xindex:longint;xtext:string);
var
   dw:longint;

begin

//get
if      (xindex=i_overview)  then dw:=320
else if (xindex=i_bits)      then dw:=80
else if (xindex=i_misc)      then dw:=120
else                              dw:=130;

//.text override
if (ilastdatatype=dt_text) then
   begin

   if (xindex=i_words) or (xindex=i_chars) then dw:=180;

   end
//.cursor scheme override
else if (ilastdatatype=dt_cursorScheme) then
   begin

   if      (xindex=i_cursorSchemeInfo)  then dw:=240
   else if (xindex=i_cursorSchemeInfo2) then dw:=180;

   end;
   
//set
istatusbar.celltext  [ xindex ]       :=xtext;
istatusbar.cellwidth [ xindex ]       :=insint(dw,xtext<>'');

end;

procedure tarchive.xhidecellsfrom(const xfrom:longint);
var
   p                  :longint32;
   fc                 :longint64;
   fb                 :longint64;
   fcap               :string;

begin

//hide unused status cells
for p:=xfrom to i_max do celltext[ p ]:='';

//size for archive -> e.g. for the Home folder
if (ifolderhub.folderCurrent=nil) then
   begin

   fc       :=ifolderhub.fullcount;
   fb       :=ifolderhub.fullbytes;
   fcap     :='in archive';

   end

//size of this folder
else if ifolderhub.athome then
   begin

   fc    :=ifolderhub.fullcount;
   fb    :=ifolderhub.fullbytes;
   fcap  :='in archive';

   end

else begin

   fc    :=ifolderhub.folderCurrent.subcount;
   fb    :=ifolderhub.folderCurrent.subbytes;
   fcap  :='listed';

   end;


//status
celltext[ i_overview ] :=
 low__mbAUTO2( fb ,1 ,true ) +
 ' and '+
 k64( fc )+' file'+insstr('s',fc<>1)+
 #32+fcap;


end;

procedure tarchive.xupdatebuttons;
var
   dt                 :tdatatype;
   ximage             :tbasicimgview;//pointer only
   xtext              :tbasicbwp;//pointer only
   xmustrealign       :boolean;
   xtopbar            :boolean;
   xmorebar           :boolean;
   xccbar             :boolean;
   bol1               :boolean;
   vs                 :string;
   v                  :longint32;
   v64                :longint64;

   function xcopyAll:string;
   begin

   if (dt=dt_text) then result:='Copy All'
   else                 result:='Cells';

   end;
   
begin


//init -------------------------------------------------------------------------

ilastdatatype         :=ifilehub.datatype(0);
dt                    :=ilastdatatype;

xtopbar               :=ifilehub.supcopyformat( fc_copy )      or
                        ifilehub.supcopyformat( fc_copyall )   or
                        ifilehub.supcopyformat( fc_pngPascal ) or
                        ifilehub.supcopyformat( fc_pngB64 );



ifilehub.fetchImageView ( ximage );//fast
ifilehub.fetchTextBox   ( xtext );//fast

imorebar.setdata( ifilehub );

imorebar.xupdatebuttons;

xmorebar              :=imorebar.canmanage and ishowmore;
xccbar                :=(ishowmore and (ilastdatatype=dt_cursorScheme)) or cursor_customcolors.canEdit;


//topbar.visible
if (itopbar.visible<>xtopbar) then
   begin

   itopbar.visible           :=xtopbar;
   itopbarSep.visible        :=xtopbar;
   xmustrealign              :=true;

   end;

//morebar.visible
if (imorebar.visible<>xmorebar) then
   begin

   imorebar.visible          :=xmorebar;
   imorebarSep.visible       :=xmorebar;
   xmustrealign              :=true;

   end;

//ccbar.visible
if (iccbar.visible<>xccbar) then
   begin

   iccbar.visible            :=xccbar;
   iccbarSep.visible         :=xccbar;
   xmustrealign              :=true;

   end;


//topbar -----------------------------------------------------------------------

with itopbar do
begin

//.more
bvisible2['more']                                :=imorebar.canmanage;
bmarked2['more']                                 :=ishowmore;
btep2['more']                                    :=low__aorb(tepDownward20,tepUpward20,ishowmore);

//.copy
bvisible2['copy']                                :=ifilehub.supcopyformat( fc_copy );
benabled2['copy']                                :=ifilehub.cancopyformat( fc_copy );

case dt of

dt_cursorScheme,
dt_cursor,
dt_image,
dt_sprite                       :bhelp2['copy']  :='Copy|Copy image to Clipboard';

dt_text                         :bhelp2['copy']  :='Copy|Copy selected text to Clipboard';

end;//case

//.copy all
bcap2['copyall']                                 :=xcopyAll;
bvisible2['copyall']                             :=ifilehub.supcopyformat( fc_copyall );
benabled2['copyall']                             :=ifilehub.cancopyformat( fc_copyall );

case dt of

dt_cursorscheme,
dt_cursor,
dt_image                        :bhelp2['copyall']:='Copy All|Copy all image cells to Clipboard';

dt_text                         :bhelp2['copyall']:='Copy All|Copy all text to Clipboard';

end;//case

//.other
bvisible[ isep1 ]               :=ifilehub.supcopyformat( fc_pngPascal ) or
                                  ifilehub.supcopyformat( fc_jpgPascal ) or
                                  ifilehub.supcopyformat( fc_icoPascal ) or
                                  ifilehub.supcopyformat( fc_gifPascal );

bvisible2['copy.array.png']     :=ifilehub.supcopyformat( fc_pngPascal );
bvisible2['copy.array.jpg']     :=ifilehub.supcopyformat( fc_jpgPascal );
bvisible2['copy.array.ico']     :=ifilehub.supcopyformat( fc_icoPascal );
bvisible2['copy.array.gif']     :=ifilehub.supcopyformat( fc_gifPascal );

benabled2['copy.array.png']     :=ifilehub.cancopyformat( fc_pngPascal );
benabled2['copy.array.jpg']     :=ifilehub.cancopyformat( fc_jpgPascal );
benabled2['copy.array.ico']     :=ifilehub.cancopyformat( fc_icoPascal );
benabled2['copy.array.gif']     :=ifilehub.cancopyformat( fc_gifPascal );


bvisible[ isep2 ]               :=ifilehub.supcopyformat( fc_pngB64 ) or
                                  ifilehub.supcopyformat( fc_jpgB64 ) or
                                  ifilehub.supcopyformat( fc_icoB64 ) or
                                  ifilehub.supcopyformat( fc_gifB64 );

bvisible2['copy.b64.png']       :=ifilehub.supcopyformat( fc_pngB64 );
bvisible2['copy.b64.jpg']       :=ifilehub.supcopyformat( fc_jpgB64 );
bvisible2['copy.b64.ico']       :=ifilehub.supcopyformat( fc_icoB64 );
bvisible2['copy.b64.gif']       :=ifilehub.supcopyformat( fc_gifB64 );

benabled2['copy.b64.png']       :=ifilehub.cancopyformat( fc_pngB64 );
benabled2['copy.b64.jpg']       :=ifilehub.cancopyformat( fc_jpgB64 );
benabled2['copy.b64.ico']       :=ifilehub.cancopyformat( fc_icoB64 );
benabled2['copy.b64.gif']       :=ifilehub.cancopyformat( fc_gifB64 );

end;


//botbar -----------------------------------------------------------------------

with ibotbar do
begin

benabled2['savefiles.totemp']     :=cansaveall;
benabled2['saveall.tofolder']     :=cansaveall;
benabled2['saveone.tofile'  ]     :=cansaveone;

end;


//statusbar --------------------------------------------------------------------

celltext[ i_filesize   ]          :=xfilesize;
celltext[ i_type   ]              :=dt__label( dt );

if ((dt=dt_cursor) or (dt=dt_image)) and ifilehub.fetchImageView( ximage ) then
   begin

   celltext[ i_dimensions ]       :=k64(ximage.width)+'w x '+k64(ximage.height)+'h';
   celltext[ i_colors     ]       :=k64(ximage.colors)+' color'+insstr('s',ximage.colors<>1);

   celltext[ i_cells ]            :=k64(ximage.cells)+' cell'+insstr('s',ximage.cells<>1);

   celltext[ i_bits ]             :=k64(ximage.bpp)+' bit';

   case (ximage.cells<=1) or (ximage.delay<1) of
   true:celltext[ i_fps ]         :='static';
   else celltext[ i_fps ]         :=curdec(1000/frcmin32(ximage.delay,1),2,false)+' fps';
   end;

   if cursor__formatSupported( ifilehub.fileext(0) ) then
      begin

      vs                        :=k64(xmousePointerSize);

      ximage.help               :='Cursor Preview|Your mouse pointer is set to show this cursor at size '+vs;

      celltext[i_cursorSize]    :='pointer size '+vs;

      xhidecellsfrom( i_cursorSize + 1);

      end

   else xhidecellsfrom( i_fps + 1);

   end

else if (dt=dt_text) and ifilehub.fetchTextBox( xtext ) then
   begin

   v                              :=xtext.wordcount;
   celltext[ i_words ]            :=k64( v )+' word'+insstr('s',v<>1);

   v                              :=frcmin32(xtext.core.data.len32-1,0);
   celltext[ i_chars ]            :=k64( v )+' char'+insstr('s',v<>1);

   xhidecellsfrom( i_chars + 1);

   end

else if (dt=dt_midi) then
   begin

   case (ifilehub.filecurrent is tfilemidi) of
   true:v   :=(ifilehub.filecurrent as tfilemidi).tracks;
   else v   :=0;
   end;//case

   celltext[ i_tracks ]      :=low__aorbstr('-',k64(v)+' track'+insstr('s',v<>1),v>=1);

   xhidecellsfrom( i_tracks + 1);

   end

else if (dt=dt_cursorScheme) then
   begin

   celltext[ i_cursorSchemeInfo  ]  :='17 cursors and 1 installer';

   celltext[ i_cursorSchemeInfo2 ]  :='pointer size ' + k64(xmousePointerSize);


   xhidecellsfrom( i_cursorSchemeInfo2 + 1);

   end

else if (dt=dt_folder) then
   begin

   xhidecellsfrom( i_type + 1 );

   end

else begin

   xhidecellsfrom( i_filesize + 1);

   end;

//xmustrealign
if xmustrealign then
   begin

   gui.fullalignpaint;

   end;

end;

function tarchive.xpromptReplaceAll(const xmsg:string):longint;
var
   a:tbasicscroll;
   da:twinrect;
   dw,dh,xpreviousfocus:longint;
   xpreviouscontrol:tbasiccontrol;
begin
//defaults
result                :=rm_cancel;
a                     :=nil;

try
//init
xpreviousfocus        :=gui.winfocus;
xpreviouscontrol      :=gui.focuscontrol;
//init
//was:dw:=400;dh:=200;low__winzoom2(dw,dh,50,50);//17mar2021
gui__scale4(1.1 ,500 ,200 ,50 ,50 ,dw ,dh );//11dec2025

da.left               :=(gui.width-dw) div 2;
da.top                :=(gui.height-dh) div 2;
da.right              :=da.left+dw-1;
da.bottom             :=da.top+dh-1;

//get
a                     :=gui.ndlg(da,false);
a.oborderstyle        :=bsSystem50;
a.static              :=true;
a.xhead.caption       :='Replace All';
a.xhead.tep           :=tepQuery24;
a.xhelp;
a.xgrad;//09dec2024
a.nbwp('',str__newaf8b(xmsg)).makeviewonly;

with a.xtoolbar2 do
begin

cadd(ntranslate('Yes - Replace all files'),tepYes20,rm_replaceall,scdlg,rthtranslate('Replace all files'),0);
cadd(ntranslate('No - Skip all existing files'),tepClose20,rm_skipall,scdlg,rthtranslate('Skip existing files'),0);
cadd(ntranslate('Cancel - Do nothing'),tepStop20,rm_cancel,scdlg,rthtranslate('Cancel'),120);

end;//with

//set
if gui.xshowwait(a,xpreviouscontrol,xpreviousfocus) then result:=a.ocode;

except;end;

//free
freeobj(@a);

end;

function tarchive.xpromptContinueWriting(const xmsg:string):boolean;
var
   a:tbasicscroll;
   da:twinrect;
   dw,dh,xpreviousfocus:longint;
   xpreviouscontrol:tbasiccontrol;
begin

//defaults
result                :=false;
a                     :=nil;

try
//init
xpreviousfocus        :=gui.winfocus;
xpreviouscontrol      :=gui.focuscontrol;
//init
//was:dw:=400;dh:=200;low__winzoom2(dw,dh,50,50);//17mar2021
gui__scale4(1.1 ,500 ,200 ,50 ,50 ,dw ,dh );//11dec2025

da.left               :=(gui.width-dw) div 2;
da.top                :=(gui.height-dh) div 2;
da.right              :=da.left+dw-1;
da.bottom             :=da.top+dh-1;

//get
a                     :=gui.ndlg(da,false);
a.oborderstyle        :=bsSystem50;
a.static              :=true;
a.xhead.caption       :='Continue Writing';
a.xhead.tep           :=tepQuery24;
a.xhelp;
a.xgrad;//09dec2024
a.nbwp('',str__newaf8b(xmsg)).makeviewonly;

with a.xtoolbar2 do
begin

cadd(ntranslate('No - Stop writing files and cancel task'),tepClose20,rm_skipall,scdlg,rthtranslate('Stop writing files'),0);
cadd(ntranslate('Yes - Continue writing files'),tepYes20,rm_replaceall,scdlg,rthtranslate('Continue writing files'),120);

end;//with

//set
result:=gui.xshowwait(a,xpreviouscontrol,xpreviousfocus) and (a.ocode=rm_replaceall);

except;end;

//free
freeobj(@a);

end;


//## tapp ######################################################################

constructor tapp.create;
begin

//cc__makeNameList;

if system_debug then dbstatus(38,'Debug 010 - 21may2021_528am');//yyyy


//win__make_gosswin2_pas;app__halt;


//self
inherited create(strint32(app__info('width')),strint32(app__info('height')));
ibuildingcontrol:=true;


//vars
iloaded           :=false;
itimer500         :=ms64;



//controls
with rootwin do
begin
scroll:=false;
static:=true;
xhead.tag:=-1;
xhead.caption2:='  -  Interactive Archive by '+app__info('author.name');

with xhead do
begin

add('' ,tepNone,0,'background.toggle' ,'' );//set via xupdatebuttons

addsep;

xaddoptions;
xaddhelp;

addsep;

//for standard Desktop Apps - MSIX is installed, so don't need to prompt
if not system_msix then
   begin

   add('Close and Clean Up' ,tepClose20,0,'closeandclean' ,'Close and Clean Up|Close the app and optionally choose to remove all the app settings and support files, and leave no trace / digital footprint behind' );

   end;

end;

iarchive    :=tarchive.create( client ,'' );

end;

//events
rootwin.xhead.onclick :=__onclick;

//defaults
ibuildingcontrol:=false;
xloadsettings;
xupdatebuttons;

//finish
createfinish;

end;

destructor tapp.destroy;
begin
try

//save settings
xsavesettings;

//controls

//self
inherited destroy;
except;end;
end;

procedure tapp.xloadsettings;
begin

iloaded:=true;

end;

procedure tapp.xsavesettings;
begin

//nil

end;

procedure tapp.xautosavesettings;
begin

//nil

end;

function tapp.xpromptCloseAndCleanUp:longint32;
var
   a                  :tbasicscroll;
   da                 :twinrect;
   dw                 :longint32;
   dh                 :longint32;
   xpreviousfocus     :longint32;
   xpreviouscontrol   :tbasiccontrol;

begin

//defaults
result                :=rm_cancel;
a                     :=nil;

try
//init
xpreviousfocus        :=gui.winfocus;
xpreviouscontrol      :=gui.focuscontrol;
//init
gui__scale4(1.1 ,500 ,200 ,50 ,50 ,dw ,dh );

da.left               :=(gui.width-dw) div 2;
da.top                :=(gui.height-dh) div 2;
da.right              :=da.left+dw-1;
da.bottom             :=da.top+dh-1;

//get
a                     :=gui.ndlg(da,false);
a.oborderstyle        :=bsSystem50;
a.static              :=true;
a.xhead.caption       :='Clean Up';
a.xhead.tep           :=tepQuery24;
a.xhelp;
a.xgrad;//09dec2024
a.nbwp('',str__newaf8b('Keep app settings for next time?')).makeviewonly;

with a.xtoolbar2 do
begin

cadd(ntranslate('Cancel'),tepClose20,rm_cancel,scdlg,rthtranslate('Cancel|Do nothing'),0);

cadd(ntranslate('No - Discard settings now'),tepClose20,rm_no,scdlg,rthtranslate('No|Delete settings'),0);

cadd(ntranslate('Yes - Keep settings'),tepYes20,rm_yes,scdlg,rthtranslate('Yes|Retain settings for next time'),120);

end;//with

//set
gui.xshowwait(a,xpreviouscontrol,xpreviousfocus);

//.return user choice
result:=a.ocode;

except;end;

//free
freeobj(@a);

end;

procedure tapp.__onclick(sender:tobject);
begin

if (sender is tbasictoolbar) then xcmd( (sender as tbasictoolbar).ocode2 );

end;

procedure tapp.xcmd(const xcode2:string);
var
   v                  :string;

   function m(const x:string):boolean;
   begin

   result   :=strmatch(x,xcode2);

   end;

begin
try

if m('closeandclean') then
   begin

   //prompt App Clean Up (not when an MSIX app) -> removes app's storage folder and its contents
   case xpromptCloseAndCleanUp of

   rm_cancel :exit;
   rm_no     :app__cleanuponclose:=true;

   end;

   //close app
   siCloseprompt(gui);

   end

else if m('background.toggle') then
   begin

   case (vibackname='none') of
   true:syssettings.s['backname']:='default';
   else syssettings.s['backname']:='none';
   end;//case

   viSyncandsave;

   end;

except;end;
end;

procedure tapp.__ontimer(sender:tobject);//._ontimer
begin
try

//timer500
if (ms64>=itimer500) then
   begin

   //savesettings
   xautosavesettings;

   //updatebuttons
   xupdatebuttons;
   
   //reset
   itimer500:=ms64+500;

   end;

except;end;
end;

procedure tapp.xupdatebuttons;
var
   xmustupdate        :boolean;

   procedure sb(const xtep:longint32;const xcaption,xhelp:string);
   begin

   //main app toolbar
   with rootwin.xhead do
   begin

   if ( btep2['background.toggle']<>xtep ) then
      begin

      btep2['background.toggle']   :=xtep;
      bcap2['background.toggle']   :=xcaption;
      bhelp2['background.toggle']  :=xhelp;

      xmustupdate                  :=true;

      end;

   end;//with

   end;

begin

//defaults
xmustupdate           :=false;

//background mode
case strmatch(vibackname,'none') of
true:sb( tepPlay20, 'Play Background Scheme' ,'Turn On Background Scheme|Turn on the app''s default animated background scheme');
else sb( tepStop20, 'Stop Background Scheme' ,'Turn Off Background Scheme|Turn off the app''s animated background scheme');
end;//case

//update
if xmustupdate then
   begin

   rootwin.xhead.paintnow;

   end;

end;

end.
