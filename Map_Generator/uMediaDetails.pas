unit uMediaDetails;

{$MODE Delphi}

interface

uses
  LCLIntf, LCLType, LMessages, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, FileUtil;

type
  // MediaDetails
  TMediaDetails = Record
     FileName                : String;
     dsStatus                : String; // ERROR or empty if OK
     dsMediaOtherMajorType   : String;
     dsMediaOtherSubType     : String;
     dsMediaVideoMajorType   : String;
     dsMediaVideoSubType     : String;
     dsMediaDuration         : String;
     dsMediaVideoFourCC      : String;
     dsBitRate               : String;
     dsBitErrorRate          : String;
     dsAvgTimePerFrame       : String;
     dsMediaVideoWidth       : String;
     dsMediaVideoHeight      : String;
     dsMediaVideoBitPlanes   : String;
     dsMediaVideoComp        : String;
     dsMediaAudioMajorType   : String;
     dsMediaAudioSubType     : String;
     dsMediaAudioFormatTag   : String;
     dsMediaAudioFormat      : String;
     dsMediaAudioHertz       : String;
     dsMediaAudioBitrate     : String;
     dsMediaAudioChannels    : String;
     dsMediaMpeg1Width       : String;
     dsMediaMpeg1Height      : String;
     dsMediaMpeg1Bits        : String;
     dsMediaMpeg1Comp        : String;
     dsMediaMpeg2Width       : String;
     dsMediaMpeg2Height      : String;
     dsMediaMpeg2Bits        : String;
     dsMediaMpeg2Comp        : String;
     dsMediaMpegAudioTag     : String;
     dsMediaLength           : Double;
     dsMediaWidth            : Integer;
     dsMediaHeight           : Integer;
     dsMediaBitRate          : Integer;
     dsMediaBitPlanes        : Integer;
  end;

type
  TfrmMediaDetails = class(TForm)
    Memo: TMemo;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
    // read details from file
    function GetMediaDetails(Filename: String): TMediaDetails;
    // Show details dialog
    procedure ShowToMemo(md : TMediaDetails);
  end;

var
  frmMediaDetails: TfrmMediaDetails;

implementation

{$R *.lfm}

uses
   ActiveX, MMSystem, DXSUtil, DirectShow9;

procedure TfrmMediaDetails.ShowToMemo(md : TMediaDetails);
begin
   Memo.Lines.append('File=' + md.FileName);
   Memo.Lines.append('Status=' + md.dsStatus);
   Memo.Lines.append('MediaVideoMajorType=' + md.dsMediaVideoMajorType);
   Memo.Lines.append('MediaOtherMajorType=' + md.dsMediaOtherMajorType);
   Memo.Lines.append('MediaVideoSubType=' + md.dsMediaVideoSubType);
   Memo.Lines.append('MediaOtherSubType=' + md.dsMediaOtherSubType);
   Memo.Lines.append('MediaDuration=' + md.dsMediaDuration);
   Memo.Lines.append('MediaVideoFourCC=' + md.dsMediaVideoFourCC);

   Memo.Lines.append('MediaVideoBitRate=' + md.dsBitRate);
   Memo.Lines.append('MediaVideoErrorRate=' + md.dsBitErrorRate);
   Memo.Lines.append('MediaVideoAvgTimePerFrame=' + md.dsAvgTimePerFrame);
   Memo.Lines.append('MediaVideoWidth='+ md.dsMediaVideoWidth);
   Memo.Lines.append('MediaVideoHeight=' + md.dsMediaVideoHeight);
   Memo.Lines.append('MediaVideoBitPlanes=' + md.dsMediaVideoBitPlanes);
   Memo.Lines.append('MediaVideoComp=' + md.dsMediaVideoComp);

   Memo.Lines.append('MediaAudioMajorType=' + md.dsMediaAudioMajorType);
   Memo.Lines.append('MediaAudioSubType=' + md.dsMediaAudioSubType);
   Memo.Lines.append('MediaAudioFormatTag=' + md.dsMediaAudioFormatTag);
   Memo.Lines.append('MediaAudioFormat=' + md.dsMediaAudioFormat);
   Memo.Lines.append('MediaAudioHertz=' + md.dsMediaAudioHertz);
   Memo.Lines.append('MediaAudioBitrate=' + md.dsMediaAudioBitrate);
   Memo.Lines.append('MediaAudioChannels=' + md.dsMediaAudioChannels);

   Memo.Lines.append('MediaMpeg1Width=' + md.dsMediaMpeg1Width);
   Memo.Lines.append('MediaMpeg1Height=' + md.dsMediaMpeg1Height);
   Memo.Lines.append('MediaMpeg1Bits=' + md.dsMediaMpeg1Bits);
   Memo.Lines.append('MediaMpeg1Comp=' + md.dsMediaMpeg1Comp);

   Memo.Lines.append('MediaMpeg2Width=' + md.dsMediaMpeg2Width);
   Memo.Lines.append('MediaMpeg2Height=' + md.dsMediaMpeg2Height);
   Memo.Lines.append('MediaMpeg2Bits=' + md.dsMediaMpeg2Bits);
   Memo.Lines.append('MediaMpeg2Comp=' + md.dsMediaMpeg2Comp);

   Memo.Lines.append('MediaMpegAudioTag=' + md.dsMediaMpegAudioTag);
   Show;
end;

procedure TfrmMediaDetails.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
   Action := caFree; // destroy instance on close
end;

//----------------------------------------

function EvalFourCC(SrcFourCC : String) : String;
var
   helpstr : String;
begin
  HelpStr := lowercase(srcFourCC);
  if helpStr = '3iv1' then Result := 'Video Codec Used - 3IVX'
  else if helpstr = '3iv2' then Result := 'Video Codec Used - 3IVX'
  else if helpstr = 'aasc' then Result := 'Video Codec Used - Autodesk Animator'
  else if helpstr = 'adv1' then Result := 'Video Codec Used - Wave Codec'
  else if helpstr = 'advj' then Result := 'Video Codec Used - Avid M-JPEG'
  else if helpstr = 'aem1' then Result := 'Video Codec Used - Array VideoONE'
  else if helpstr = 'afl1' then Result := 'Video Codec Used - Autodesk Animator'
  else if helpstr = 'aflc' then Result := 'Video Codec Used - Autodesk Animator'
  else if helpstr = 'ampg' then Result := 'Video Codec Used - Array VideoONE'
  else if helpstr = 'anim' then Result := 'Video Codec Used - Intel RDX'
  else if helpstr = 'ap41' then Result := 'Video Codec Used - Angel Potion'
  else if helpstr = 'asv1' then Result := 'Video Codec Used - ASUS Video'
  else if helpstr = 'asv2' then Result := 'ASUS Video 2'
  else if helpstr = 'asvx' then Result := 'ASUS Video 2.0'
  else if helpstr = 'aur2' then Result := 'Aura 2 - YUV 422'
  else if helpstr = 'aura' then Result := 'Aura 1 - YUV 411'
  else if helpstr = 'avrn' then Result := 'Avid M-JPEG'
  else if helpstr = 'bink' then Result := 'Bink Video'
  else if helpstr = 'bt20' then Result := 'Prosumer Video'
  else if helpstr = 'btcv' then Result := 'Composite Video'
  else if helpstr = 'bw10' then Result := 'Broadway MPEG'
  else if helpstr = 'cc12' then Result := 'Intel YUV12'
  else if helpstr = 'cdvc' then Result := 'Canopus DV'
  else if helpstr = 'cfcc' then Result := 'DPS Perception'
  else if helpstr = 'cgdi' then Result := 'Office 97 Camcorder'
  else if helpstr = 'cham' then Result := 'Caviara Champagne'
  else if helpstr = 'cmyk' then Result := 'Uncompressed CMYK'
  else if helpstr = 'cjpg' then Result := 'Creative Labs WebCam'
  else if helpstr = 'cpla' then Result := 'Weitek YUV 4:2:0'
  else if helpstr = 'cram' then Result := 'MS Video 1'
  else if helpstr = 'cvid' then Result := 'Cinepak'
  else if helpstr = 'cwlt' then Result := 'MS Colour WLT DIB'
  else if helpstr = 'cyuv' then Result := 'Creative YUV'
  else if helpstr = 'cyuy' then Result := 'ATI YUV'
  else if helpstr = 'd261' then Result := 'Intel H.261'
  else if helpstr = 'd263' then Result := 'Intel H.263'
  else if helpstr = 'div3' then Result := 'DivX 3'
  else if helpstr = 'div4' then Result := 'DivX 4'
  else if helpstr = 'div5' then Result := 'DivX 5'
  else if helpstr = 'divx' then Result := 'DivX'
  else if helpstr = 'dmb1' then Result := 'Matrox RR Hardware'
  else if helpstr = 'dmb2' then Result := 'Paradigm M-JPEG'
  else if helpstr = 'dsvd' then Result := 'VFW Based DV'
  else if helpstr = 'duck' then Result := 'Truemotion S'
  else if helpstr = 'dv25' then Result := 'DVCPRO - 25Mb/s'
  else if helpstr = 'dv50' then Result := 'DVCPRO - 50Mb/s'
  else if helpstr = 'dvsd' then Result := 'microVideo DV300SW Firewire'
  else if helpstr = 'dve2' then Result := 'DVE-2'
  else if helpstr = 'dvx1' then Result := 'DVX1000SP'
  else if helpstr = 'dvx2' then Result := 'DVX2000S'
  else if helpstr = 'dvx3' then Result := 'DVX3000S'
  else if helpstr = 'dx50' then Result := 'DivX 5'
  else if helpstr = 'dxtn' then Result := 'DirectX Texture'
  else if helpstr = 'elk0' then Result := 'Elsa'
  else if helpstr = 'ekq0' then Result := 'Elsa Quick'
  else if helpstr = 'escp' then Result := 'Escape'
  else if helpstr = 'etv1' then Result := 'eTreppid Video'
  else if helpstr = 'etv2' then Result := 'eTreppid Video'
  else if helpstr = 'etvc' then Result := 'eTreppid Video'
  else if helpstr = 'fljp' then Result := 'Field Encoded M-JPEG'
  else if helpstr = 'frwa' then Result := 'Forward Motion /w Alpha'
  else if helpstr = 'frwd' then Result := 'Forward Motion'
  else if helpstr = 'fvf1' then Result := 'Fractal Video Frame'
  else if helpstr = 'glzw' then Result := 'Motion LZW'
  else if helpstr = 'gpeg' then Result := 'Motion JPEG'
  else if helpstr = 'gwlt' then Result := 'MS Greyscale WLT DIB'
  else if helpstr = 'h260' then Result := 'Intel Conferencing'
  else if helpstr = 'h261' then Result := 'Intel Conferencing'
  else if helpstr = 'h262' then Result := 'Intel Conferencing'
  else if helpstr = 'h263' then Result := 'Intel Conferencing'
  else if helpstr = 'h264' then Result := 'Intel Conferencing'
  else if helpstr = 'h265' then Result := 'Intel Conferencing'
  else if helpstr = 'h266' then Result := 'Intel Conferencing'
  else if helpstr = 'h267' then Result := 'Intel Conferencing'
  else if helpstr = 'h268' then Result := 'Intel Conferencing'
  else if helpstr = 'h269' then Result := 'Intel Conferencing'
  else if helpstr = 'hfyu' then Result := 'Huffman YUV/RGB Lossless'
  else if helpstr = 'hmcr' then Result := 'Rendition'
  else if helpstr = 'hmrr' then Result := 'Rendition'
  else if helpstr = 'i263' then Result := 'Intel H.263'
  else if helpstr = 'iclb' then Result := 'CellB'
  else if helpstr = 'igor' then Result := 'Power DVD'
  else if helpstr = 'ijpg' then Result := 'Intergraph JPEG'
  else if helpstr = 'ilvc' then Result := 'Intel Layered Video'
  else if helpstr = 'ir21' then Result := 'Intel Indeo 2.1'
  else if helpstr = 'iraw' then Result := 'Intel Uncompressed UYUV'
  else if helpstr = 'iv30' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv31' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv32' then Result := 'Intel Indeo 3.2'
  else if helpstr = 'iv33' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv34' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv35' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv36' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv37' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv38' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv39' then Result := 'Intel Indeo 3'
  else if helpstr = 'iv40' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv41' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv42' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv43' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv44' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv45' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv46' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv47' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv48' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv49' then Result := 'Intel Indeo 4.1 Interactive'
  else if helpstr = 'iv50' then Result := 'Intel Indeo 5.0 Interactive'
  else if helpstr = 'jbyr' then Result := 'Kensington Codec'
  else if helpstr = 'jpeg' then Result := 'MS Jpeg Still'
  else if helpstr = 'jpgl' then Result := 'JPEG Light'
  else if helpstr = 'kmvc' then Result := 'Karl Morton''s Codec'
  else if helpstr = 'l261' then Result := 'Lead H.261'
  else if helpstr = 'l263' then Result := 'Lead H.263'
  else if helpstr = 'lcmw' then Result := 'Motion CMW'
  else if helpstr = 'lead' then Result := 'Lead Video Codec'
  else if helpstr = 'lgry' then Result := 'Lead Greyscale Image'
  else if helpstr = 'ljpg' then Result := 'Lead M-JPEG'
  else if helpstr = 'm261' then Result := 'MS H.261'
  else if helpstr = 'm263' then Result := 'MS H.263'
  else if helpstr = 'm4s2' then Result := 'MS ISO MPEG4 V2'
  else if helpstr = 'mc12' then Result := 'ATI Motion Compensation'
  else if helpstr = 'mcam' then Result := 'ATI Motion Compensation'
  else if helpstr = 'mj2c' then Result := 'Morgan Motion JPEG 2000'
  else if helpstr = 'mjpg' then Result := 'Motion JPEG'
  else if helpstr = 'mmes' then Result := 'Matrox MPEG-2 ES'
  else if helpstr = 'mp2a' then Result := 'Media Excel MPEG2 Audio'
  else if helpstr = 'mp2t' then Result := 'Media Excel MPEG2 Transport'
  else if helpstr = 'mp2v' then Result := 'Media Excel MPEG2 Video'
  else if helpstr = 'mp42' then Result := 'MS MPEG-4'
  else if helpstr = 'mp43' then Result := 'MS MPEG-4'
  else if helpstr = 'mp4a' then Result := 'Media Excel MPEG4 Audio'
  else if helpstr = 'mp4t' then Result := 'Media Excel MPEG4 Transport'
  else if helpstr = 'mp4v' then Result := 'Media Excel MPEG4 Video'
  else if helpstr = 'mp4s' then Result := 'MS MPEG-4'
  else if helpstr = 'mpeg' then Result := 'MPEG'
  else if helpstr = 'mpg4' then Result := 'MS MPEG-4'
  else if helpstr = 'mpgi' then Result := 'Sigma Designs Editable MPEG'
  else if helpstr = 'mrca' then Result := 'Fast Multimedia'
  else if helpstr = 'mrle' then Result := 'MS Run Length Encoded'
  else if helpstr = 'msvc' then Result := 'MS Video 1 - Original VFW!'
  else if helpstr = 'mszh' then Result := 'AVImszh'
  else if helpstr = 'mtx1' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx2' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx3' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx4' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx5' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx6' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx7' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx8' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mtx9' then Result := 'Matrox MJPEG Variant'
  else if helpstr = 'mwv1' then Result := 'Aware Motion Wavelets'
  else if helpstr = 'ntn1' then Result := 'Nogatech Video Compression 1'
  else if helpstr = 'nvds' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvhs' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvvu' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvs0' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvs1' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvs2' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvs3' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvs4' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvs5' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvt0' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvt1' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvt2' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvt3' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvt4' then Result := 'Nvidia Texture Format'
  else if helpstr = 'nvt5' then Result := 'Nvidia Texture Format'
  else if helpstr = 'pdvc' then Result := 'IO Data Device''s DVC'
  else if helpstr = 'pgvv' then Result := 'Radius Video Vision'
  else if helpstr = 'phmo' then Result := 'Photomotion'
  else if helpstr = 'pim1' then Result := 'Pegasus Imaging Codec'
  else if helpstr = 'pim2' then Result := 'Pegasus Imaging Codec'
  else if helpstr = 'pimj' then Result := 'Pegasus Imaging Codec'
  else if helpstr = 'pixl' then Result := 'Pinnacle Video XL'
  else if helpstr = 'pvez' then Result := 'Horizons Tech. PowerEZ'
  else if helpstr = 'pvmm' then Result := 'PacketVideo Corp MPEG-4'
  else if helpstr = 'pvw2' then Result := 'Pegasus Wavelet Compression'
  else if helpstr = 'qpeg' then Result := 'Q-Team 8bit Seamless'
  else if helpstr = 'rgbt' then Result := 'Conexant 32Bit'
  else if helpstr = 'rle ' then Result := 'Run Length Encoded'
  else if helpstr = 'rle4' then Result := 'Run Length Encoded 4bpp'
  else if helpstr = 'rle8' then Result := 'Run Length Encoded 8bpp'
  else if helpstr = 'rmp4' then Result := 'Sigma MPEG-4 AS'
  else if helpstr = 'rt21' then Result := 'Intel RealTime 2.1'
  else if helpstr = 'rv20' then Result := 'Real Video G2'
  else if helpstr = 'rv30' then Result := 'Real Video 8'
  else if helpstr = 'rvx ' then Result := 'Intel RDX'
  else if helpstr = 's422' then Result := 'VideoCap C210 YUV'
  else if helpstr = 'san3' then Result := 'Direct DivX 3.11a Copy'
  else if helpstr = 'sdcc' then Result := 'Sun Digital Camera'
  else if helpstr = 'sfmc' then Result := 'CrystalNet Surface Fitting'
  else if helpstr = 'smsc' then Result := 'Radius Proprietary'
  else if helpstr = 'smsd' then Result := 'Radius Proprietary'
  else if helpstr = 'smsv' then Result := 'WorldConnect Wavelet'
  else if helpstr = 'sp54' then Result := 'SunPlus'
  else if helpstr = 'spig' then Result := 'Radius Spigot'
  else if helpstr = 'sqz2' then Result := 'MS VXtreme V2'
  else if helpstr = 'sv10' then Result := 'Sorenson Media Video R1'
  else if helpstr = 'stva' then Result := 'ST CMOS Imager Data'
  else if helpstr = 'stvb' then Result := 'ST CMOS Imager Data'
  else if helpstr = 'stvc' then Result := 'ST CMOS Imager Data'
  else if helpstr = 'stvx' then Result := 'ST CMOS Imager Data'
  else if helpstr = 'stvy' then Result := 'ST CMOS Imager Data'
  else if helpstr = 'svq1' then Result := 'Sorenson Video'
  else if helpstr = 'tlms' then Result := 'Motion Intraframe'
  else if helpstr = 'tlst' then Result := 'Motion Intraframe'
  else if helpstr = 'tm20' then Result := 'TrueMotion 2.0'
  else if helpstr = 'tm2x' then Result := 'TrueMotion 2.X'
  else if helpstr = 'tmic' then Result := 'Motion Intraframe'
  else if helpstr = 'tmot' then Result := 'TrueMotion S'
  else if helpstr = 'tr20' then Result := 'TrueMotion RT 2.0'
  else if helpstr = 'tscc' then Result := 'TechSmith Screen Cap'
  else if helpstr = 'tv10' then Result := 'Tecomac Low Bitrate'
  else if helpstr = 'tvjp' then Result := 'Pinnacle/Truevision'
  else if helpstr = 'tvmj' then Result := 'Pinnacle/Truevision'
  else if helpstr = 'ty2c' then Result := 'Trident'
  else if helpstr = 'ty2n' then Result := 'Trident'
  else if helpstr = 'ty0n' then Result := 'Trident'
  else if helpstr = 'ucod' then Result := 'ClearVideo'
  else if helpstr = 'ulti' then Result := 'Ultimotion'
  else if helpstr = 'v261' then Result := 'Lucent VX2000S'
  else if helpstr = 'v655' then Result := 'Vitec YUV 4:2:2'
  else if helpstr = 'vcr1' then Result := 'ATI Video 1'
  else if helpstr = 'vcr2' then Result := 'ATI Video 2'
  else if helpstr = 'vdct' then Result := 'VideoMaker Pro DIB'
  else if helpstr = 'vdom' then Result := 'VDOWave'
  else if helpstr = 'vdow' then Result := 'VDOLive'
  else if helpstr = 'vdtz' then Result := 'VideoTizer YUV'
  else if helpstr = 'vgpx' then Result := 'VideoGramPix'
  else if helpstr = 'vifp' then Result := 'VFAPI'
  else if helpstr = 'vids' then Result := 'YUV 4:2:2 CCIR 601'
  else if helpstr = 'vivo' then Result := 'Vivo H.263'
  else if helpstr = 'vixl' then Result := 'Miro Video XL'
  else if helpstr = 'vlv1' then Result := 'VideoLogic'
  else if helpstr = 'vp30' then Result := 'On2 VP3'
  else if helpstr = 'vp31' then Result := 'On2 VP3'
  else if helpstr = 'vssv' then Result := 'Vanguard VSS Video'
  else if helpstr = 'vx1k' then Result := 'Lucent VX1000S'
  else if helpstr = 'vx2k' then Result := 'Lucent VX2000S'
  else if helpstr = 'vxsp' then Result := 'Lucent VX1000SP'
  else if helpstr = 'vyu9' then Result := 'ATI Planar YUV'
  else if helpstr = 'vyuy' then Result := 'ATI Packed YUV'
  else if helpstr = 'wbvc' then Result := 'Winbond W9960'
  else if helpstr = 'wham' then Result := 'MS Video 1'
  else if helpstr = 'winx' then Result := 'Winnov Software'
  else if helpstr = 'wjpg' then Result := 'Winbond JPEG'
  else if helpstr = 'wnv1' then Result := 'Winnov Hardware'
  else if helpstr = 'x263' then Result := 'Xirlink H.263'
  else if helpstr = 'xvid' then Result := 'XVID MPEG-4'
  else if helpstr = 'xlv0' then Result := 'NetXL XL Video Decoder'
  else if helpstr = 'xmpg' then Result := 'XING I-Frame MPEG'
  else if helpstr = 'xwv0' then Result := 'XiWave Video'
  else if helpstr = 'xwv1' then Result := 'XiWave Video'
  else if helpstr = 'xwv2' then Result := 'XiWave Video'
  else if helpstr = 'xwv3' then Result := 'XiWave Video'
  else if helpstr = 'xwv4' then Result := 'XiWave Video'
  else if helpstr = 'xwv5' then Result := 'XiWave Video'
  else if helpstr = 'xwv6' then Result := 'XiWave Video'
  else if helpstr = 'xwv7' then Result := 'XiWave Video'
  else if helpstr = 'xwv8' then Result := 'XiWave Video'
  else if helpstr = 'xwv9' then Result := 'XiWave Video'
  else if helpstr = 'y411' then Result := 'YUV 4:1:1'
  else if helpstr = 'y41p' then Result := 'Conexant Brooktree 4:1:1'
  else if helpstr = 'yc12' then Result := 'YUV 12'
  else if helpstr = 'yuv8' then Result := 'Caviar YUV8'
  else if helpstr = 'yuy2' then Result := 'RAW YUV 4:2:2'
  else if helpstr = 'yuyv' then Result := 'Canopus'
  else if helpstr = 'zpeg' then Result := 'Metheus Video Zipper'
  else if helpstr = 'zygo' then Result := 'ZyGoVideo'
  else Result := 'Unknown FourCC Codec';
end;

function SecondsToString(Seconds: integer): string;
var
   i1, i2: integer;
begin
   i1:=(Seconds DIV 60);
   i2:=(Seconds - (i1*60));
   If i1 DIV 60 > 0 then
      Result:=FormatFloat('00',i1 DIV 60)+':'+FormatFloat('00',i1 MOD 60)+':'+FormatFloat('00',i2)
   else
      Result:=FormatFloat('00',i1)+':'+FormatFloat('00',i2);
end;

function TfrmMediaDetails.GetMediaDetails(Filename: String): TMediaDetails;
var
   dsMediaType    : TAMMediaType;
   dsMediaStreams : Integer;
   dsMediaDet     : IMediaDet;
   tmpRec         : TMediaDetails;
   I              : Integer;
begin
   tmpRec.filename := FileName;

 try
   If Not(FileExistsUTF8(FileName) { *Converted from FileExists* }) then begin
      tmpRec.dsStatus := 'ERROR: FILE NOT FOUND';
      Exit;
   end;

   If CoCreateInstance(CLSID_MediaDet,nil,CLSCTX_INPROC,IID_IMediaDet,dsMediaDet) <> S_OK then begin
      tmpRec.dsStatus := 'ERROR: CLSID_MediaDet failed';
      Exit;
   end;

   If dsMediaDet.put_FileName(FileName) <> S_OK then begin
      tmpRec.dsStatus := 'ERROR: dsMediaDet.put_FileName failed';
      Exit;
   end;

   If dsMediaDet.get_OutputStreams(dsMediaStreams) <> S_OK then begin
      tmpRec.dsStatus := 'ERROR: dsMediaDet.get_OutputStreams failed';
      Exit;
   end;

   If (dsMediaStreams < 1) then begin
      tmpRec.dsStatus := 'ERROR: dsMediaStream < 1';
      Exit;
   end;

             For I := 0 to dsMediaStreams -1 do begin
                If dsMediaDet.put_CurrentStream(I) = S_OK then begin
                   If dsMediaDet.get_StreamLength(tmpRec.dsMediaLength) = S_OK then
                      tmpRec.dsMediaDuration := SecondsToString(trunc(tmpRec.dsMediaLength));

                   If dsMediaDet.get_StreamMediaType(dsMediaType) = S_OK then begin
                      // Major Type
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_AnalogAudio)   then tmpRec.dsMediaAudioMajorType := 'AnalogAudio'   else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_AnalogVideo)   then tmpRec.dsMediaAudioMajorType := 'Analogvideo'   else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Audio)         then tmpRec.dsMediaAudioMajorType := 'Audio'         else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_AUXLine21Data) then tmpRec.dsMediaAudioMajorType := 'AUXLine21Data' else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_File)          then tmpRec.dsMediaOtherMajorType := 'File'          else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Interleaved)   then tmpRec.dsMediaOtherMajorType := 'Interleaved'   else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_LMRT)          then tmpRec.dsMediaOtherMajorType := 'LMRT'          else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Midi)          then tmpRec.dsMediaOtherMajorType := 'Midi'          else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_MPEG2_PES)     then tmpRec.dsMediaOtherMajorType := 'MPEG2_PES'     else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_ScriptCommand) then tmpRec.dsMediaOtherMajorType := 'ScriptCommand' else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Stream)        then tmpRec.dsMediaOtherMajorType := 'Stream'        else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Text)          then tmpRec.dsMediaOtherMajorType := 'Text'          else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Timecode)      then tmpRec.dsMediaOtherMajorType := 'Timecode'      else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_URL_STREAM)    then tmpRec.dsMediaOtherMajorType := 'URL_STREAM'    else
                      if IsEqualGUID(dsMediaType.majortype,MEDIATYPE_Video)         then tmpRec.dsMediaVideoMajorType := 'Video'         else
                         tmpRec.dsMediaOtherMajorType := 'Unknown';

                      // Sub Type
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_CLPL) then tmprec.dsMediaVideoSubType := 'CLPL' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_YUYV) then tmprec.dsMediaVideoSubType := 'YUYV' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_IYUV) then tmprec.dsMediaVideoSubType := 'IYUV' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_YVU9) then tmprec.dsMediaVideoSubType := 'YVU9' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Y411) then tmprec.dsMediaVideoSubType := 'Y411' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Y41P) then tmprec.dsMediaVideoSubType := 'Y41P' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_YUY2) then tmprec.dsMediaVideoSubType := 'YUY2' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_YVYU) then tmprec.dsMediaVideoSubType := 'YVYU' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_UYVY) then tmprec.dsMediaVideoSubType := 'UYVY' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Y211) then tmprec.dsMediaVideoSubType := 'Y211' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_YV12) then tmprec.dsMediaVideoSubType := 'YV12' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_CLJR) then tmprec.dsMediaVideoSubType := 'CLJR' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_IF09) then tmprec.dsMediaVideoSubType := 'IF09' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_CPLA) then tmprec.dsMediaVideoSubType := 'CPLA' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MJPG) then tmprec.dsMediaVideoSubType := 'MJPG' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_TVMJ) then tmprec.dsMediaVideoSubType := 'TVMJ' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_WAKE) then tmprec.dsMediaVideoSubType := 'WAKE' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_CFCC) then tmprec.dsMediaVideoSubType := 'CFCC' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_IJPG) then tmprec.dsMediaVideoSubType := 'IJPG' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Plum) then tmprec.dsMediaVideoSubType := 'Plum' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVCS) then tmprec.dsMediaVideoSubType := 'DVCS' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVSD) then tmprec.dsMediaVideoSubType := 'DVSD' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MDVF) then tmprec.dsMediaVideoSubType := 'MDVF' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB1) then tmprec.dsMediaVideoSubType := 'RGB1' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB4) then tmprec.dsMediaVideoSubType := 'RGB4' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB8) then tmprec.dsMediaVideoSubType := 'RGB8' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB565) then tmprec.dsMediaVideoSubType := 'RGB565' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB555) then tmprec.dsMediaVideoSubType := 'RGB555' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB24) then tmprec.dsMediaVideoSubType := 'RGB24' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RGB32) then tmprec.dsMediaVideoSubType := 'RGB32' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_ARGB32) then tmprec.dsMediaVideoSubType := 'ARGB32' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Overlay) then tmprec.dsMediaVideoSubType := 'Overlay' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1Packet) then tmprec.dsMediaVideoSubType := 'MPEG1Packet' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1Payload) then tmprec.dsMediaVideoSubType := 'MPEG1Payload' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1AudioPayload) then tmprec.dsMediaAudioSubType := 'MPEG1AudioPayload' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1System) then tmprec.dsMediaVideoSubType := 'MPEG1System' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1VideoCD) then tmprec.dsMediaVideoSubType := 'MPEG1VideoCD' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1Video) then tmprec.dsMediaVideoSubType := 'MPEG1Video' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG1Audio) then tmprec.dsMediaAudioSubType := 'MPEG1Audio' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Avi) then tmprec.dsMediaVideoSubType := 'Avi' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Asf) then tmprec.dsMediaVideoSubType := 'Asf' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_QTMovie) then tmprec.dsMediaVideoSubType := 'QTMovie' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_QTRpza) then tmprec.dsMediaVideoSubType := 'QTRpza' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_QTSmc) then tmprec.dsMediaVideoSubType := 'QTSmc' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_QTRle) then tmprec.dsMediaVideoSubType := 'QTRle' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_QTJpeg) then tmprec.dsMediaVideoSubType := 'QTJpeg' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_PCMAudio_Obsolete) then tmprec.dsMediaAudioSubType := 'PCMAudio_Obsolete' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_PCM) then tmprec.dsMediaAudioSubType := 'PCM' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_WAVE) then tmprec.dsMediaAudioSubType := 'WAVE' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AU) then tmprec.dsMediaAudioSubType := 'AU' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AIFF) then tmprec.dsMediaAudioSubType := 'AIFF' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_dvsd_) then tmprec.dsMediaVideoSubType := 'dvsd_' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_dvhd) then tmprec.dsMediaVideoSubType := 'dvhd' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_dvsl) then tmprec.dsMediaVideoSubType := 'dvsl' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Line21_BytePair) then tmprec.dsMediaOtherSubType := 'Line21_BytePair' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Line21_GOPPacket) then tmprec.dsMediaOtherSubType := 'Line21_GOPPacket' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_Line21_VBIRawData) then tmprec.dsMediaOtherSubType := 'Line21_VBIRawData' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DRM_Audio) then tmprec.dsMediaAudioSubType := 'DRM_Audio' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_IEEE_FLOAT) then tmprec.dsMediaOtherSubType := 'IEEE_FLOAT' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DOLBY_AC3_SPDIF) then tmprec.dsMediaAudioSubType := 'DOLBY_AC3_SPDIF' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_RAW_SPORT) then tmprec.dsMediaAudioSubType := 'RAW_SPORT' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_SPDIF_TAG_241h) then tmprec.dsMediaAudioSubType := 'SPDIF_TAG_241h' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DssVideo) then tmprec.dsMediaVideoSubType := 'DssVideo' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DssAudio) then tmprec.dsMediaAudioSubType := 'DssAudio' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_VPVideo) then tmprec.dsMediaVideoSubType := 'VPVideo' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_VPVBI) then tmprec.dsMediaVideoSubType := 'VPVBI' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_NTSC_M) then tmprec.dsMediaVideoSubType := 'AnalogVideo_NTSC_M' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_B) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_B' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_D) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_D' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_G) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_G' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_H) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_H' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_I) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_I' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_M) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_M' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_N) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_N' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_PAL_N_COMBO) then tmprec.dsMediaVideoSubType := 'AnalogVideo_PAL_N_COMBO' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_B) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_B' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_D) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_D' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_G) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_G' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_H) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_H' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_K) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_K' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_K1) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_K1' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_AnalogVideo_SECAM_L) then tmprec.dsMediaVideoSubType := 'AnalogVideo_SECAM_L' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG2_VIDEO) then tmprec.dsMediaVideoSubType := 'MPEG2_VIDEO' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG2_PROGRAM) then tmprec.dsMediaVideoSubType := 'MPEG2_PROGRAM' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG2_TRANSPORT) then tmprec.dsMediaVideoSubType := 'MPEG2_TRANSPORT' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MPEG2_AUDIO) then tmprec.dsMediaAudioSubType := 'MPEG2_AUDIO' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DOLBY_AC3) then tmprec.dsMediaAudioSubType := 'DOLBY_AC3' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVD_SUBPICTURE) then tmprec.dsMediaVideoSubType := 'DVD_SUBPICTURE' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVD_LPCM_AUDIO) then tmprec.dsMediaAudioSubType := 'DVD_LPCM_AUDIO' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DTS) then tmprec.dsMediaAudioSubType := 'DTS' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_SDDS) then tmprec.dsMediaAudioSubType := 'SDDS' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVD_NAVIGATION_PCI) then tmprec.dsMediaOtherSubType := 'PCI' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVD_NAVIGATION_DSI) then tmprec.dsMediaOtherSubType := 'DSI' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DVD_NAVIGATION_PROVIDER) then tmprec.dsMediaOtherSubType := 'PROVIDER' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_MP42) then tmprec.dsMediaVideoSubType := 'MS-MPEG4' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_DIVX) then tmprec.dsMediaVideoSubType := 'DIVX' else
                      if IsEqualGUID(dsMediaType.subtype,MEDIASUBTYPE_VOXWARE) then tmprec.dsMediaAudioSubType := 'VOXWARE_MetaSound' else
                      tmpRec.dsMediaOtherSubType := 'Unknown ';

                      if IsEqualGUID(dsMediaType.formattype,FORMAT_VideoInfo) then begin
                         tmpRec.dsBitRate := IntToStr(PVideoInfoHeader(dsMediaType.pbFormat)^.dwBitRate);
                         tmpRec.dsMediaBitRate := PVideoInfoHeader(dsMediaType.pbFormat)^.dwBitRate;
                         tmpRec.dsBitErrorRate := IntToStr(PVideoInfoHeader(dsMediaType.pbFormat)^.dwBitErrorRate);
                         tmpRec.dsAvgTimePerFrame := IntToStr(PVideoInfoHeader(dsMediaType.pbFormat)^.AvgTimePerFrame);
                         if ( (dsMediaType.cbFormat > 0) and
                              assigned(dsMediaType.pbFormat) ) then begin
                            with PVideoInfoHeader(dsMediaType.pbFormat)^.bmiHeader do begin
                               tmpRec.dsMediaVideoWidth := IntToStr(biWidth);
                               tmpRec.dsMediaWidth := biWidth;
                               tmpRec.dsMediaVideoHeight := IntToStr(biHeight);
                               tmpRec.dsMediaHeight := biHeight;
                               tmpRec.dsMediaVideoBitPlanes := IntToStr(biBitCount);
                               tmpRec.dsMediaBitPlanes := biBitCount;
                               tmpRec.dsMediaVideoFourCC := GetFourCC(biCompression);
                               tmpRec.dsMediaVideoComp := EvalFOurCC(GetFourCC(biCompression));
                            end;
                         end;
                      end else begin
                         if IsEqualGUID(dsMediaType.formattype,FORMAT_VideoInfo2) then begin
                            tmpRec.dsBitRate := IntToStr(PVideoInfoHeader2(dsMediaType.pbFormat)^.dwBitRate);
                            tmpRec.dsMediaBitRate := PVideoInfoHeader2(dsMediaType.pbFormat)^.dwBitRate;
                            tmpRec.dsBitErrorRate := IntToStr(PVideoInfoHeader2(dsMediaType.pbFormat)^.dwBitErrorRate);
                            tmpRec.dsAvgTimePerFrame := IntToStr(PVideoInfoHeader2(dsMediaType.pbFormat)^.AvgTimePerFrame);
                            if ( (dsMediaType.cbFormat > 0) and
                                 assigned(dsMediaType.pbFormat) ) then begin
                               with PVideoInfoHeader2(dsMediaType.pbFormat)^.bmiHeader do begin
                                 tmpRec.dsMediaVideoWidth := IntToStr(biWidth);
                                 tmpRec.dsMediaWidth := biWidth;
                                 tmpRec.dsMediaVideoHeight := IntToStr(biHeight);
                                 tmpRec.dsMediaHeight := biHeight;
                                 tmpRec.dsMediaVideoBitPlanes := IntToStr(biBitCount);
                                 tmpRec.dsMediaBitPlanes := biBitCount;
                                 tmpRec.dsMediaVideoFourCC := GetFourCC(biCompression);
                                 tmpRec.dsMediaVideoComp := EvalFOurCC(GetFourCC(biCompression));
                               end;
                            end;
                         end else
                         if IsEqualGUID(dsMediaType.formattype,FORMAT_WaveFormatEx) then begin
                            if ((dsMediaType.cbFormat > 0) and assigned(dsMediaType.pbFormat)) then begin
                               case PWaveFormatEx(dsMediaType.pbFormat)^.wFormatTag of
                                   $0001: tmpRec.dsMediaAudioFormatTag := 'PCM';  // common
                                   $0002: tmpRec.dsMediaAudioFormatTag := 'ADPCM';
                                   $0003: tmpRec.dsMediaAudioFormatTag := 'IEEE_FLOAT';
                                   $0005: tmpRec.dsMediaAudioFormatTag := 'IBM_CVSD';
                                   $0006: tmpRec.dsMediaAudioFormatTag := 'ALAW';
                                   $0007: tmpRec.dsMediaAudioFormatTag := 'MULAW';
                                   $0010: tmpRec.dsMediaAudioFormatTag := 'OKI_ADPCM';
                                   $0011: tmpRec.dsMediaAudioFormatTag := 'DVI_ADPCM';
                                   $0012: tmpRec.dsMediaAudioFormatTag := 'MEDIASPACE_ADPCM';
                                   $0013: tmpRec.dsMediaAudioFormatTag := 'SIERRA_ADPCM';
                                   $0014: tmpRec.dsMediaAudioFormatTag := 'G723_ADPCM';
                                   $0015: tmpRec.dsMediaAudioFormatTag := 'DIGISTD';
                                   $0016: tmpRec.dsMediaAudioFormatTag := 'DIGIFIX';
                                   $0017: tmpRec.dsMediaAudioFormatTag := 'DIALOGIC_OKI_ADPCM';
                                   $0018: tmpRec.dsMediaAudioFormatTag := 'MEDIAVISION_ADPCM';
                                   $0020: tmpRec.dsMediaAudioFormatTag := 'YAMAHA_ADPCM';
                                   $0021: tmpRec.dsMediaAudioFormatTag := 'SONARC';
                                   $0022: tmpRec.dsMediaAudioFormatTag := 'DSPGROUP_TRUESPEECH';
                                   $0023: tmpRec.dsMediaAudioFormatTag := 'ECHOSC1';
                                   $0024: tmpRec.dsMediaAudioFormatTag := 'AUDIOFILE_AF36';
                                   $0025: tmpRec.dsMediaAudioFormatTag := 'APTX';
                                   $0026: tmpRec.dsMediaAudioFormatTag := 'AUDIOFILE_AF10';
                                   $0030: tmpRec.dsMediaAudioFormatTag := 'DOLBY_AC2';
                                   $0031: tmpRec.dsMediaAudioFormatTag := 'GSM610';
                                   $0032: tmpRec.dsMediaAudioFormatTag := 'MSNAUDIO';
                                   $0033: tmpRec.dsMediaAudioFormatTag := 'ANTEX_ADPCME';
                                   $0034: tmpRec.dsMediaAudioFormatTag := 'CONTROL_RES_VQLPC';
                                   $0035: tmpRec.dsMediaAudioFormatTag := 'DIGIREAL';
                                   $0036: tmpRec.dsMediaAudioFormatTag := 'DIGIADPCM';
                                   $0037: tmpRec.dsMediaAudioFormatTag := 'CONTROL_RES_CR10';
                                   $0038: tmpRec.dsMediaAudioFormatTag := 'NMS_VBXADPCM';
                                   $0039: tmpRec.dsMediaAudioFormatTag := 'CS_IMAADPCM';
                                   $003A: tmpRec.dsMediaAudioFormatTag := 'ECHOSC3';
                                   $003B: tmpRec.dsMediaAudioFormatTag := 'ROCKWELL_ADPCM';
                                   $003C: tmpRec.dsMediaAudioFormatTag := 'ROCKWELL_DIGITALK';
                                   $003D: tmpRec.dsMediaAudioFormatTag := 'XEBEC';
                                   $0040: tmpRec.dsMediaAudioFormatTag := 'G721_ADPCM';
                                   $0041: tmpRec.dsMediaAudioFormatTag := 'G728_CELP';
                                   $0050: tmpRec.dsMediaAudioFormatTag := 'MPEG';
                                   $0055: tmpRec.dsMediaAudioFormatTag := 'MPEGLAYER3';
                                   $0060: tmpRec.dsMediaAudioFormatTag := 'CIRRUS';
                                   $0061: tmpRec.dsMediaAudioFormatTag := 'ESPCM';
                                   $0062: tmpRec.dsMediaAudioFormatTag := 'VOXWARE';
                                   $0063: tmpRec.dsMediaAudioFormatTag := 'CANOPUS_ATRAC';
                                   $0064: tmpRec.dsMediaAudioFormatTag := 'G726_ADPCM';
                                   $0065: tmpRec.dsMediaAudioFormatTag := 'G722_ADPCM';
                                   $0066: tmpRec.dsMediaAudioFormatTag := 'DSAT';
                                   $0067: tmpRec.dsMediaAudioFormatTag := 'DSAT_DISPLAY';
                                   $0075: tmpRec.dsMediaAudioFormatTag := 'VOXWARE'; // aditionnal  ???
                                   $0080: tmpRec.dsMediaAudioFormatTag := 'SOFTSOUND';
                                   $0100: tmpRec.dsMediaAudioFormatTag := 'RHETOREX_ADPCM';
                                   $0200: tmpRec.dsMediaAudioFormatTag := 'CREATIVE_ADPCM';
                                   $0202: tmpRec.dsMediaAudioFormatTag := 'CREATIVE_FASTSPEECH8';
                                   $0203: tmpRec.dsMediaAudioFormatTag := 'CREATIVE_FASTSPEECH10';
                                   $0220: tmpRec.dsMediaAudioFormatTag := 'QUARTERDECK';
                                   $0300: tmpRec.dsMediaAudioFormatTag := 'FM_TOWNS_SND';
                                   $0400: tmpRec.dsMediaAudioFormatTag := 'BTV_DIGITAL';
                                   $1000: tmpRec.dsMediaAudioFormatTag := 'OLIGSM';
                                   $1001: tmpRec.dsMediaAudioFormatTag := 'OLIADPCM';
                                   $1002: tmpRec.dsMediaAudioFormatTag := 'OLICELP';
                                   $1003: tmpRec.dsMediaAudioFormatTag := 'OLISBC';
                                   $1004: tmpRec.dsMediaAudioFormatTag := 'OLIOPR';
                                   $1100: tmpRec.dsMediaAudioFormatTag := 'LH_CODEC';
                                   $1400: tmpRec.dsMediaAudioFormatTag := 'NORRIS';
                               else
                                   tmpRec.dsMediaAudioFormatTag := 'Unknown';
                               end;
                            end;

                            with PWaveFormatEx(dsMediaType.pbFormat)^ do begin
                              tmpRec.dsMediaAudioHertz := IntToStr(nSamplesPerSec);
                              tmpRec.dsMediaAudioBitrate  := IntToStr(wBitsPerSample * nSamplesPerSec);
                              tmpRec.dsMediaAudioChannels  := IntToStr(nChannels);
                            end;
                            
                         end else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_MPEGVideo) then begin
                              if ((dsMediaType.cbFormat > 0) and assigned(dsMediaType.pbFormat)) then
                              with PMPEG1VIDEOINFO(dsMediaType.pbFormat)^.hdr.bmiHeader do begin
                                 tmpRec.dsMediaMpeg1Width := IntToStr(biWidth);
                                 tmpRec.dsMediaMpeg1Height := IntToStr(biHeight);
                                 tmpRec.dsMediaMpeg1Bits := IntToStr(biBitCount);
                                 tmpRec.dsMediaMpeg1Comp := GetFourCC(biCompression);
                              end;
                           end else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_MPEG2Video) then begin
                              if ((dsMediaType.cbFormat > 0) and assigned(dsMediaType.pbFormat)) then
                              with PMPEG2VIDEOINFO(dsMediaType.pbFormat)^.hdr.bmiHeader do begin
                                 tmpRec.dsMediaMpeg2Width := IntToStr(biWidth);
                                 tmpRec.dsMediaMpeg2Height := IntToStr(biHeight);
                                 tmpRec.dsMediaMpeg2Bits := IntToStr(biBitCount);
                                 tmpRec.dsMediaMpeg2Comp := GetFourCC(biCompression);
                              end;
                           end else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_DvInfo)        then tmpRec.dsMediaMpegAudioTag := 'DvInfo' else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_MPEGStreams)   then tmpRec.dsMediaMpegAudioTag := 'MPEGStreams' else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_DolbyAC3)      then tmpRec.dsMediaMpegAudioTag := 'DolbyAC3' else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_MPEG2Audio)    then tmpRec.dsMediaMpegAudioTag := 'MPEG2Audio' else
                           if IsEqualGUID(dsMediaType.formattype,FORMAT_DVD_LPCMAudio) then tmpRec.dsMediaMpegAudioTag := 'DVD_LPCMAudio' else
                              tmpRec.dsMediaMpegAudioTag := 'Unknown';
                      end;
                   end;
                end;
             end;

 finally
   Result := tmpRec;
   dsMediaDet := nil;
 end;
end;

end.
