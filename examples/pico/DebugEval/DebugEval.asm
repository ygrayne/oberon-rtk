   256   0100H  02002FC34H
   260   0104H  010005695H
   264   0108H  1
   268   010CH  1
   272   0110H  1
   276   0114H  1
   280   0118H  1
   284   011CH  1
   288   0120H  1
   292   0124H  1
   296   0128H  1
   300   012CH  1
   304   0130H  1
   308   0134H  1
   312   0138H  1
   316   013CH  1
   320   0140H  1
   324   0144H  1
   328   0148H  1
   332   014CH  1
   336   0150H  1
   340   0154H  1
   344   0158H  1
   348   015CH  1
   352   0160H  1
   356   0164H  1
   360   0168H  1
   364   016CH  1
   368   0170H  1
   372   0174H  1
   376   0178H  1
   380   017CH  1
   384   0180H  1
   388   0184H  1
   392   0188H  1
   396   018CH  1
   400   0190H  1
   404   0194H  1
   408   0198H  1
   412   019CH  1
   416   01A0H  1
   420   01A4H  1
   424   01A8H  1
   428   01ACH  1
   432   01B0H  1
   436   01B4H  1
   440   01B8H  1
   444   01BCH  1
   448   01C0H  1
   452   01C4H  1
   456   01C8H  1
   460   01CCH  1
   464   01D0H  1
   468   01D4H  1
   472   01D8H  1
   476   01DCH  1
   480   01E0H  1
   484   01E4H  1
   488   01E8H  1
   492   01ECH  1
   496   01F0H  1
   500   01F4H  1
   504   01F8H  1
   508   01FCH  1
   512   0200H  0
   516   0204H  0
   520   0208H  0
   524   020CH  0
   528   0210H  0
   532   0214H  0
   536   0218H  0
   540   021CH  0
   544   0220H  0
   548   0224H  0
   552   0228H  0
   556   022CH  0
   560   0230H  0
   564   0234H  0
   568   0238H  0
   572   023CH  0
   576   0240H  0
   580   0244H  0
   584   0248H  0
   588   024CH  0
   592   0250H  0
   596   0254H  0
   600   0258H  0
   604   025CH  0
   608   0260H  0
   612   0264H  0
   616   0268H  0
   620   026CH  0
   624   0270H  0
   628   0274H  0
   632   0278H  0
   636   027CH  0
   640   0280H  0
   644   0284H  0
   648   0288H  0
   652   028CH  0
   656   0290H  0
   660   0294H  0
   664   0298H  0
   668   029CH  0
   672   02A0H  0
   676   02A4H  0
   680   02A8H  0
   684   02ACH  0
   688   02B0H  0
   692   02B4H  0
   696   02B8H  0
   700   02BCH  0
   704   02C0H  0
   708   02C4H  0
   712   02C8H  0
   716   02CCH  0
   720   02D0H  0
   724   02D4H  0
   728   02D8H  0
   732   02DCH  0
   736   02E0H  0
   740   02E4H  0
   744   02E8H  0
   748   02ECH  0
   752   02F0H  0
   756   02F4H  0
   760   02F8H  0
   764   02FCH  0
   768   0300H  0
   772   0304H  0
   776   0308H  020000200H
   780   030CH  0
   784   0310H  010005710H
   788   0314H  010005694H
   792   0318H  020000000H
   796   031CH  020030000H
   800   0320H  010000100H
   804   0324H  010200000H
   808   0328H  0
   812   032CH  0
   816   0330H  0
   820   0334H  0
   824   0338H  0
   828   033CH  0

MODULE LinkOptions:
   832   0340H  0

PROCEDURE LinkOptions.CodeStartAddress:
   836   0344H  0B500H      push     { lr }
   838   0346H  0BD00H      pop      { pc }

PROCEDURE LinkOptions.Init:
   840   0348H  0B500H      push     { lr }
   842   034AH  046C0H      nop
   844   034CH  04821H      ldr      r0,[pc,#132] -> 980
   846   034EH  04478H      add      r0,pc
   848   0350H  02191H      movs     r1,#145
   850   0352H  00089H      lsls     r1,r1,#2
   852   0354H  01A40H      subs     r0,r0,r1
   854   0356H  04920H      ldr      r1,[pc,#128] -> 984
   856   0358H  06008H      str      r0,[r1]
   858   035AH  0481FH      ldr      r0,[pc,#124] -> 984
   860   035CH  06800H      ldr      r0,[r0]
   862   035EH  02101H      movs     r1,#1
   864   0360H  00249H      lsls     r1,r1,#9
   866   0362H  01840H      adds     r0,r0,r1
   868   0364H  0491DH      ldr      r1,[pc,#116] -> 988
   870   0366H  06008H      str      r0,[r1]
   872   0368H  0481CH      ldr      r0,[pc,#112] -> 988
   874   036AH  06800H      ldr      r0,[r0]
   876   036CH  03004H      adds     r0,#4
   878   036EH  06801H      ldr      r1,[r0]
   880   0370H  04A1BH      ldr      r2,[pc,#108] -> 992
   882   0372H  06011H      str      r1,[r2]
   884   0374H  04819H      ldr      r0,[pc,#100] -> 988
   886   0376H  06800H      ldr      r0,[r0]
   888   0378H  03008H      adds     r0,#8
   890   037AH  06801H      ldr      r1,[r0]
   892   037CH  04A19H      ldr      r2,[pc,#100] -> 996
   894   037EH  06011H      str      r1,[r2]
   896   0380H  04816H      ldr      r0,[pc,#88] -> 988
   898   0382H  06800H      ldr      r0,[r0]
   900   0384H  0300CH      adds     r0,#12
   902   0386H  06801H      ldr      r1,[r0]
   904   0388H  04A17H      ldr      r2,[pc,#92] -> 1000
   906   038AH  06011H      str      r1,[r2]
   908   038CH  04813H      ldr      r0,[pc,#76] -> 988
   910   038EH  06800H      ldr      r0,[r0]
   912   0390H  03010H      adds     r0,#16
   914   0392H  06801H      ldr      r1,[r0]
   916   0394H  04A15H      ldr      r2,[pc,#84] -> 1004
   918   0396H  06011H      str      r1,[r2]
   920   0398H  04810H      ldr      r0,[pc,#64] -> 988
   922   039AH  06800H      ldr      r0,[r0]
   924   039CH  03018H      adds     r0,#24
   926   039EH  06801H      ldr      r1,[r0]
   928   03A0H  04A13H      ldr      r2,[pc,#76] -> 1008
   930   03A2H  06011H      str      r1,[r2]
   932   03A4H  0480DH      ldr      r0,[pc,#52] -> 988
   934   03A6H  06800H      ldr      r0,[r0]
   936   03A8H  0301CH      adds     r0,#28
   938   03AAH  06801H      ldr      r1,[r0]
   940   03ACH  04A11H      ldr      r2,[pc,#68] -> 1012
   942   03AEH  06011H      str      r1,[r2]
   944   03B0H  0480AH      ldr      r0,[pc,#40] -> 988
   946   03B2H  06800H      ldr      r0,[r0]
   948   03B4H  03020H      adds     r0,#32
   950   03B6H  06801H      ldr      r1,[r0]
   952   03B8H  04A0FH      ldr      r2,[pc,#60] -> 1016
   954   03BAH  06011H      str      r1,[r2]
   956   03BCH  04807H      ldr      r0,[pc,#28] -> 988
   958   03BEH  06800H      ldr      r0,[r0]
   960   03C0H  03024H      adds     r0,#36
   962   03C2H  06801H      ldr      r1,[r0]
   964   03C4H  04A0DH      ldr      r2,[pc,#52] -> 1020
   966   03C6H  06011H      str      r1,[r2]
   968   03C8H  0480BH      ldr      r0,[pc,#44] -> 1016
   970   03CAH  06800H      ldr      r0,[r0]
   972   03CCH  06801H      ldr      r1,[r0]
   974   03CEH  04A0CH      ldr      r2,[pc,#48] -> 1024
   976   03D0H  06011H      str      r1,[r2]
   978   03D2H  0BD00H      pop      { pc }
   980   03D4H  -14
   984   03D8H  02002FFDCH
   988   03DCH  02002FFFCH
   992   03E0H  02002FFF8H
   996   03E4H  02002FFF4H
  1000   03E8H  02002FFF0H
  1004   03ECH  02002FFE8H
  1008   03F0H  02002FFE4H
  1012   03F4H  02002FFE0H
  1016   03F8H  02002FFD8H
  1020   03FCH  02002FFD4H
  1024   0400H  02002FFECH

PROCEDURE LinkOptions..init:
  1028   0404H  0B500H      push     { lr }
  1030   0406H  0F7FFFF9FH  bl.w     LinkOptions.Init
  1034   040AH  0E000H      b        0 -> 1038
  1036   040CH  00031H      <LineNo: 49>
  1038   040EH  0BD00H      pop      { pc }

MODULE MCU2:
  1040   0410H  0

PROCEDURE MCU2..init:
  1044   0414H  0B500H      push     { lr }
  1046   0416H  0BD00H      pop      { pc }

MODULE Config:
  1048   0418H  0

PROCEDURE Config.init:
  1052   041CH  0B500H      push     { lr }
  1054   041EH  0480CH      ldr      r0,[pc,#48] -> 1104
  1056   0420H  06800H      ldr      r0,[r0]
  1058   0422H  04911H      ldr      r1,[pc,#68] -> 1128
  1060   0424H  06008H      str      r0,[r1]
  1062   0426H  0480BH      ldr      r0,[pc,#44] -> 1108
  1064   0428H  06800H      ldr      r0,[r0]
  1066   042AH  04910H      ldr      r1,[pc,#64] -> 1132
  1068   042CH  06008H      str      r0,[r1]
  1070   042EH  0480AH      ldr      r0,[pc,#40] -> 1112
  1072   0430H  06800H      ldr      r0,[r0]
  1074   0432H  0490FH      ldr      r1,[pc,#60] -> 1136
  1076   0434H  06008H      str      r0,[r1]
  1078   0436H  04809H      ldr      r0,[pc,#36] -> 1116
  1080   0438H  06800H      ldr      r0,[r0]
  1082   043AH  0490EH      ldr      r1,[pc,#56] -> 1140
  1084   043CH  06008H      str      r0,[r1]
  1086   043EH  04808H      ldr      r0,[pc,#32] -> 1120
  1088   0440H  06800H      ldr      r0,[r0]
  1090   0442H  0490DH      ldr      r1,[pc,#52] -> 1144
  1092   0444H  06008H      str      r0,[r1]
  1094   0446H  04807H      ldr      r0,[pc,#28] -> 1124
  1096   0448H  06800H      ldr      r0,[r0]
  1098   044AH  0490CH      ldr      r1,[pc,#48] -> 1148
  1100   044CH  06008H      str      r0,[r1]
  1102   044EH  0BD00H      pop      { pc }
  1104   0450H  02002FFE4H
  1108   0454H  02002FFECH
  1112   0458H  02002FFF4H
  1116   045CH  02002FFF0H
  1120   0460H  02002FFD8H
  1124   0464H  02002FFD4H
  1128   0468H  02002FFD0H
  1132   046CH  02002FFCCH
  1136   0470H  02002FFC8H
  1140   0474H  02002FFC4H
  1144   0478H  02002FFC0H
  1148   047CH  02002FFBCH

PROCEDURE Config..init:
  1152   0480H  0B500H      push     { lr }
  1154   0482H  0F7FFFFCBH  bl.w     Config.init
  1158   0486H  0E000H      b        0 -> 1162
  1160   0488H  00067H      <LineNo: 103>
  1162   048AH  0BD00H      pop      { pc }

MODULE StartUp:
  1164   048CH  0

PROCEDURE StartUp.AwaitPowerOnResetDone:
  1168   0490H  0B501H      push     { r0, lr }
  1170   0492H  0B081H      sub      sp,#4
  1172   0494H  04805H      ldr      r0,[pc,#20] -> 1196
  1174   0496H  06801H      ldr      r1,[r0]
  1176   0498H  09100H      str      r1,[sp]
  1178   049AH  09800H      ldr      r0,[sp]
  1180   049CH  09901H      ldr      r1,[sp,#4]
  1182   049EH  02201H      movs     r2,#1
  1184   04A0H  0408AH      lsls     r2,r1
  1186   04A2H  04210H      tst      r0,r2
  1188   04A4H  0D0F6H      beq.n    -20 -> 1172
  1190   04A6H  0B002H      add      sp,#8
  1192   04A8H  0BD00H      pop      { pc }
  1194   04AAH  046C0H      nop
  1196   04ACH  04001000CH

PROCEDURE StartUp.ReleaseReset:
  1200   04B0H  0B501H      push     { r0, lr }
  1202   04B2H  0B081H      sub      sp,#4
  1204   04B4H  04809H      ldr      r0,[pc,#36] -> 1244
  1206   04B6H  06801H      ldr      r1,[r0]
  1208   04B8H  09100H      str      r1,[sp]
  1210   04BAH  09800H      ldr      r0,[sp]
  1212   04BCH  09901H      ldr      r1,[sp,#4]
  1214   04BEH  02201H      movs     r2,#1
  1216   04C0H  0408AH      lsls     r2,r1
  1218   04C2H  04210H      tst      r0,r2
  1220   04C4H  0D001H      beq.n    2 -> 1226
  1222   04C6H  0E006H      b        12 -> 1238
  1224   04C8H  046C0H      nop
  1226   04CAH  09801H      ldr      r0,[sp,#4]
  1228   04CCH  02101H      movs     r1,#1
  1230   04CEH  04081H      lsls     r1,r0
  1232   04D0H  04608H      mov      r0,r1
  1234   04D2H  04903H      ldr      r1,[pc,#12] -> 1248
  1236   04D4H  06008H      str      r0,[r1]
  1238   04D6H  0B002H      add      sp,#8
  1240   04D8H  0BD00H      pop      { pc }
  1242   04DAH  046C0H      nop
  1244   04DCH  04000C008H
  1248   04E0H  04000F000H

PROCEDURE StartUp.AwaitReleaseDone:
  1252   04E4H  0B501H      push     { r0, lr }
  1254   04E6H  0B081H      sub      sp,#4
  1256   04E8H  04805H      ldr      r0,[pc,#20] -> 1280
  1258   04EAH  06801H      ldr      r1,[r0]
  1260   04ECH  09100H      str      r1,[sp]
  1262   04EEH  09800H      ldr      r0,[sp]
  1264   04F0H  09901H      ldr      r1,[sp,#4]
  1266   04F2H  02201H      movs     r2,#1
  1268   04F4H  0408AH      lsls     r2,r1
  1270   04F6H  04210H      tst      r0,r2
  1272   04F8H  0D0F6H      beq.n    -20 -> 1256
  1274   04FAH  0B002H      add      sp,#8
  1276   04FCH  0BD00H      pop      { pc }
  1278   04FEH  046C0H      nop
  1280   0500H  04000C008H

PROCEDURE StartUp..init:
  1284   0504H  0B500H      push     { lr }
  1286   0506H  0BD00H      pop      { pc }

MODULE Error:
  1288   0508H  0

PROCEDURE Error.StdMsg:
  1292   050CH  0B503H      push     { r0, r1, lr }
  1294   050EH  09800H      ldr      r0,[sp]
  1296   0510H  02801H      cmp      r0,#1
  1298   0512H  0DA01H      bge.n    2 -> 1304
  1300   0514H  0E00EH      b        28 -> 1332
  1302   0516H  046C0H      nop
  1304   0518H  09800H      ldr      r0,[sp]
  1306   051AH  02819H      cmp      r0,#25
  1308   051CH  0DD01H      ble.n    2 -> 1314
  1310   051EH  0E009H      b        18 -> 1332
  1312   0520H  046C0H      nop
  1314   0522H  0207FH      movs     r0,#127
  1316   0524H  00340H      lsls     r0,r0,#13
  1318   0526H  09900H      ldr      r1,[sp]
  1320   0528H  02201H      movs     r2,#1
  1322   052AH  0408AH      lsls     r2,r1
  1324   052CH  04210H      tst      r0,r2
  1326   052EH  0D101H      bne.n    2 -> 1332
  1328   0530H  0E005H      b        10 -> 1342
  1330   0532H  046C0H      nop
  1332   0534H  02000H      movs     r0,#0
  1334   0536H  09901H      ldr      r1,[sp,#4]
  1336   0538H  06008H      str      r0,[r1]
  1338   053AH  0E19DH      b        826 -> 2168
  1340   053CH  046C0H      nop
  1342   053EH  09800H      ldr      r0,[sp]
  1344   0540H  04601H      mov      r1,r0
  1346   0542H  03901H      subs     r1,#1
  1348   0544H  02919H      cmp      r1,#25
  1350   0546H  0DD01H      ble.n    2 -> 1356
  1352   0548H  0DF04H      svc      4
  1354   054AH  0003FH      <LineNo: 63>
  1356   054CH  00049H      lsls     r1,r1,#1
  1358   054EH  046C0H      nop
  1360   0550H  04A01H      ldr      r2,[pc,#4] -> 1368
  1362   0552H  01852H      adds     r2,r2,r1
  1364   0554H  0447AH      add      r2,pc
  1366   0556H  04710H      bx       r2
  1368   0558H  751
  1372   055CH  09801H      ldr      r0,[sp,#4]
  1374   055EH  046C0H      nop
  1376   0560H  0A100H      adr      r1,pc,#0 -> 1380
  1378   0562H  0E009H      b        18 -> 1400
  1380   0564H  065707974H  "type"
  1384   0568H  073657420H  " tes"
  1388   056CH  061662074H  "t fa"
  1392   0570H  072756C69H  "ilur"
  1396   0574H  000000065H  "e"
  1400   0578H  04B71H      ldr      r3,[pc,#452] -> 1856
  1402   057AH  0680AH      ldr      r2,[r1]
  1404   057CH  03104H      adds     r1,#4
  1406   057EH  06002H      str      r2,[r0]
  1408   0580H  03004H      adds     r0,#4
  1410   0582H  0401AH      ands     r2,r3
  1412   0584H  0D1F9H      bne.n    -14 -> 1402
  1414   0586H  0E177H      b        750 -> 2168
  1416   0588H  046C0H      nop
  1418   058AH  09801H      ldr      r0,[sp,#4]
  1420   058CH  0A100H      adr      r1,pc,#0 -> 1424
  1422   058EH  0E00FH      b        30 -> 1456
  1424   0590H  061727261H  "arra"
  1428   0594H  061207379H  "ys a"
  1432   0598H  06E206572H  "re n"
  1436   059CH  07420746FH  "ot t"
  1440   05A0H  073206568H  "he s"
  1444   05A4H  020656D61H  "ame "
  1448   05A8H  0676E656CH  "leng"
  1452   05ACH  000006874H  "th"
  1456   05B0H  04B63H      ldr      r3,[pc,#396] -> 1856
  1458   05B2H  0680AH      ldr      r2,[r1]
  1460   05B4H  03104H      adds     r1,#4
  1462   05B6H  06002H      str      r2,[r0]
  1464   05B8H  03004H      adds     r0,#4
  1466   05BAH  0401AH      ands     r2,r3
  1468   05BCH  0D1F9H      bne.n    -14 -> 1458
  1470   05BEH  0E15BH      b        694 -> 2168
  1472   05C0H  046C0H      nop
  1474   05C2H  09801H      ldr      r0,[sp,#4]
  1476   05C4H  0A100H      adr      r1,pc,#0 -> 1480
  1478   05C6H  0E00FH      b        30 -> 1512
  1480   05C8H  069727473H  "stri"
  1484   05CCH  02073676EH  "ngs "
  1488   05D0H  020657261H  "are "
  1492   05D4H  020746F6EH  "not "
  1496   05D8H  020656874H  "the "
  1500   05DCH  0656D6173H  "same"
  1504   05E0H  06E656C20H  " len"
  1508   05E4H  000687467H  "gth"
  1512   05E8H  04B55H      ldr      r3,[pc,#340] -> 1856
  1514   05EAH  0680AH      ldr      r2,[r1]
  1516   05ECH  03104H      adds     r1,#4
  1518   05EEH  06002H      str      r2,[r0]
  1520   05F0H  03004H      adds     r0,#4
  1522   05F2H  0401AH      ands     r2,r3
  1524   05F4H  0D1F9H      bne.n    -14 -> 1514
  1526   05F6H  0E13FH      b        638 -> 2168
  1528   05F8H  046C0H      nop
  1530   05FAH  09801H      ldr      r0,[sp,#4]
  1532   05FCH  0A100H      adr      r1,pc,#0 -> 1536
  1534   05FEH  0E015H      b        42 -> 1580
  1536   0600H  065746E69H  "inte"
  1540   0604H  020726567H  "ger "
  1544   0608H  069766964H  "divi"
  1548   060CH  020646564H  "ded "
  1552   0610H  07A207962H  "by z"
  1556   0614H  0206F7265H  "ero "
  1560   0618H  06E20726FH  "or n"
  1564   061CH  074616765H  "egat"
  1568   0620H  020657669H  "ive "
  1572   0624H  069766964H  "divi"
  1576   0628H  000726F73H  "sor"
  1580   062CH  04B44H      ldr      r3,[pc,#272] -> 1856
  1582   062EH  0680AH      ldr      r2,[r1]
  1584   0630H  03104H      adds     r1,#4
  1586   0632H  06002H      str      r2,[r0]
  1588   0634H  03004H      adds     r0,#4
  1590   0636H  0401AH      ands     r2,r3
  1592   0638H  0D1F9H      bne.n    -14 -> 1582
  1594   063AH  0E11DH      b        570 -> 2168
  1596   063CH  046C0H      nop
  1598   063EH  09801H      ldr      r0,[sp,#4]
  1600   0640H  0A100H      adr      r1,pc,#0 -> 1604
  1602   0642H  0E005H      b        10 -> 1616
  1604   0644H  020555046H  "FPU "
  1608   0648H  06F727265H  "erro"
  1612   064CH  000000072H  "r"
  1616   0650H  04B3BH      ldr      r3,[pc,#236] -> 1856
  1618   0652H  0680AH      ldr      r2,[r1]
  1620   0654H  03104H      adds     r1,#4
  1622   0656H  06002H      str      r2,[r0]
  1624   0658H  03004H      adds     r0,#4
  1626   065AH  0401AH      ands     r2,r3
  1628   065CH  0D1F9H      bne.n    -14 -> 1618
  1630   065EH  0E10BH      b        534 -> 2168
  1632   0660H  046C0H      nop
  1634   0662H  09801H      ldr      r0,[sp,#4]
  1636   0664H  0A100H      adr      r1,pc,#0 -> 1640
  1638   0666H  0E007H      b        14 -> 1656
  1640   0668H  070616568H  "heap"
  1644   066CH  065766F20H  " ove"
  1648   0670H  06F6C6672H  "rflo"
  1652   0674H  000000077H  "w"
  1656   0678H  04B31H      ldr      r3,[pc,#196] -> 1856
  1658   067AH  0680AH      ldr      r2,[r1]
  1660   067CH  03104H      adds     r1,#4
  1662   067EH  06002H      str      r2,[r0]
  1664   0680H  03004H      adds     r0,#4
  1666   0682H  0401AH      ands     r2,r3
  1668   0684H  0D1F9H      bne.n    -14 -> 1658
  1670   0686H  0E0F7H      b        494 -> 2168
  1672   0688H  046C0H      nop
  1674   068AH  09801H      ldr      r0,[sp,#4]
  1676   068CH  0A100H      adr      r1,pc,#0 -> 1680
  1678   068EH  0E011H      b        34 -> 1716
  1680   0690H  065747461H  "atte"
  1684   0694H  02074706DH  "mpt "
  1688   0698H  064206F74H  "to d"
  1692   069CH  06F707369H  "ispo"
  1696   06A0H  061206573H  "se a"
  1700   06A4H  04C494E20H  " NIL"
  1704   06A8H  0696F7020H  " poi"
  1708   06ACH  07265746EH  "nter"
  1712   06B0H  000000000H
  1716   06B4H  04B22H      ldr      r3,[pc,#136] -> 1856
  1718   06B6H  0680AH      ldr      r2,[r1]
  1720   06B8H  03104H      adds     r1,#4
  1722   06BAH  06002H      str      r2,[r0]
  1724   06BCH  03004H      adds     r0,#4
  1726   06BEH  0401AH      ands     r2,r3
  1728   06C0H  0D1F9H      bne.n    -14 -> 1718
  1730   06C2H  0E0D9H      b        434 -> 2168
  1732   06C4H  046C0H      nop
  1734   06C6H  09801H      ldr      r0,[sp,#4]
  1736   06C8H  0A100H      adr      r1,pc,#0 -> 1740
  1738   06CAH  0E00FH      b        30 -> 1772
  1740   06CCH  061766E69H  "inva"
  1744   06D0H  02064696CH  "lid "
  1748   06D4H  0756C6176H  "valu"
  1752   06D8H  06E692065H  "e in"
  1756   06DCH  073616320H  " cas"
  1760   06E0H  074732065H  "e st"
  1764   06E4H  06D657461H  "atem"
  1768   06E8H  000746E65H  "ent"
  1772   06ECH  04B14H      ldr      r3,[pc,#80] -> 1856
  1774   06EEH  0680AH      ldr      r2,[r1]
  1776   06F0H  03104H      adds     r1,#4
  1778   06F2H  06002H      str      r2,[r0]
  1780   06F4H  03004H      adds     r0,#4
  1782   06F6H  0401AH      ands     r2,r3
  1784   06F8H  0D1F9H      bne.n    -14 -> 1774
  1786   06FAH  0E0BDH      b        378 -> 2168
  1788   06FCH  046C0H      nop
  1790   06FEH  09801H      ldr      r0,[sp,#4]
  1792   0700H  0A100H      adr      r1,pc,#0 -> 1796
  1794   0702H  0E013H      b        38 -> 1836
  1796   0704H  075706E69H  "inpu"
  1800   0708H  061702074H  "t pa"
  1804   070CH  0656D6172H  "rame"
  1808   0710H  020726574H  "ter "
  1812   0714H  020736168H  "has "
  1816   0718H  075206E61H  "an u"
  1820   071CH  07078656EH  "nexp"
  1824   0720H  065746365H  "ecte"
  1828   0724H  061762064H  "d va"
  1832   0728H  00065756CH  "lue"
  1836   072CH  04B04H      ldr      r3,[pc,#16] -> 1856
  1838   072EH  0680AH      ldr      r2,[r1]
  1840   0730H  03104H      adds     r1,#4
  1842   0732H  06002H      str      r2,[r0]
  1844   0734H  03004H      adds     r0,#4
  1846   0736H  0401AH      ands     r2,r3
  1848   0738H  0D1F9H      bne.n    -14 -> 1838
  1850   073AH  046C0H      nop
  1852   073CH  0F000F802H  bl.w     Error.StdMsg + 568
  1856   0740H  0FF000000H
  1860   0744H  0E098H      b        304 -> 2168
  1862   0746H  046C0H      nop
  1864   0748H  09801H      ldr      r0,[sp,#4]
  1866   074AH  046C0H      nop
  1868   074CH  0A100H      adr      r1,pc,#0 -> 1872
  1870   074EH  0E00FH      b        30 -> 1904
  1872   0750H  061746164H  "data"
  1876   0754H  073616820H  " has"
  1880   0758H  0206E6120H  " an "
  1884   075CH  078656E75H  "unex"
  1888   0760H  074636570H  "pect"
  1892   0764H  076206465H  "ed v"
  1896   0768H  065756C61H  "alue"
  1900   076CH  000000000H
  1904   0770H  04B42H      ldr      r3,[pc,#264] -> 2172
  1906   0772H  0680AH      ldr      r2,[r1]
  1908   0774H  03104H      adds     r1,#4
  1910   0776H  06002H      str      r2,[r0]
  1912   0778H  03004H      adds     r0,#4
  1914   077AH  0401AH      ands     r2,r3
  1916   077CH  0D1F9H      bne.n    -14 -> 1906
  1918   077EH  0E07BH      b        246 -> 2168
  1920   0780H  046C0H      nop
  1922   0782H  09801H      ldr      r0,[sp,#4]
  1924   0784H  0A100H      adr      r1,pc,#0 -> 1928
  1926   0786H  0E009H      b        18 -> 1948
  1928   0788H  065646E69H  "inde"
  1932   078CH  0756F2078H  "x ou"
  1936   0790H  0666F2074H  "t of"
  1940   0794H  0756F6220H  " bou"
  1944   0798H  00073646EH  "nds"
  1948   079CH  04B37H      ldr      r3,[pc,#220] -> 2172
  1950   079EH  0680AH      ldr      r2,[r1]
  1952   07A0H  03104H      adds     r1,#4
  1954   07A2H  06002H      str      r2,[r0]
  1956   07A4H  03004H      adds     r0,#4
  1958   07A6H  0401AH      ands     r2,r3
  1960   07A8H  0D1F9H      bne.n    -14 -> 1950
  1962   07AAH  0E065H      b        202 -> 2168
  1964   07ACH  046C0H      nop
  1966   07AEH  09801H      ldr      r0,[sp,#4]
  1968   07B0H  0A100H      adr      r1,pc,#0 -> 1972
  1970   07B2H  0E00BH      b        22 -> 1996
  1972   07B4H  073726576H  "vers"
  1976   07B8H  0206E6F69H  "ion "
  1980   07BCH  063656863H  "chec"
  1984   07C0H  06166206BH  "k fa"
  1988   07C4H  064656C69H  "iled"
  1992   07C8H  000000000H
  1996   07CCH  04B2BH      ldr      r3,[pc,#172] -> 2172
  1998   07CEH  0680AH      ldr      r2,[r1]
  2000   07D0H  03104H      adds     r1,#4
  2002   07D2H  06002H      str      r2,[r0]
  2004   07D4H  03004H      adds     r0,#4
  2006   07D6H  0401AH      ands     r2,r3
  2008   07D8H  0D1F9H      bne.n    -14 -> 1998
  2010   07DAH  0E04DH      b        154 -> 2168
  2012   07DCH  046C0H      nop
  2014   07DEH  09801H      ldr      r0,[sp,#4]
  2016   07E0H  0A100H      adr      r1,pc,#0 -> 2020
  2018   07E2H  0E00BH      b        22 -> 2044
  2020   07E4H  0656D6974H  "time"
  2024   07E8H  02074756FH  "out "
  2028   07ECH  0756C6176H  "valu"
  2032   07F0H  078652065H  "e ex"
  2036   07F4H  064656563H  "ceed"
  2040   07F8H  000006465H  "ed"
  2044   07FCH  04B1FH      ldr      r3,[pc,#124] -> 2172
  2046   07FEH  0680AH      ldr      r2,[r1]
  2048   0800H  03104H      adds     r1,#4
  2050   0802H  06002H      str      r2,[r0]
  2052   0804H  03004H      adds     r0,#4
  2054   0806H  0401AH      ands     r2,r3
  2056   0808H  0D1F9H      bne.n    -14 -> 2046
  2058   080AH  0E035H      b        106 -> 2168
  2060   080CH  046C0H      nop
  2062   080EH  09801H      ldr      r0,[sp,#4]
  2064   0810H  0A100H      adr      r1,pc,#0 -> 2068
  2066   0812H  0E00FH      b        30 -> 2100
  2068   0814H  065646E75H  "unde"
  2072   0818H  0656E6966H  "fine"
  2076   081CH  072702064H  "d pr"
  2080   0820H  06465636FH  "oced"
  2084   0824H  020657275H  "ure "
  2088   0828H  069726176H  "vari"
  2092   082CH  0656C6261H  "able"
  2096   0830H  000000000H
  2100   0834H  04B11H      ldr      r3,[pc,#68] -> 2172
  2102   0836H  0680AH      ldr      r2,[r1]
  2104   0838H  03104H      adds     r1,#4
  2106   083AH  06002H      str      r2,[r0]
  2108   083CH  03004H      adds     r0,#4
  2110   083EH  0401AH      ands     r2,r3
  2112   0840H  0D1F9H      bne.n    -14 -> 2102
  2114   0842H  0E019H      b        50 -> 2168
  2116   0844H  046C0H      nop
  2118   0846H  0E79CH      b        -200 -> 1922
  2120   0848H  0E688H      b        -752 -> 1372
  2122   084AH  0E69EH      b        -708 -> 1418
  2124   084CH  0E73BH      b        -394 -> 1734
  2126   084EH  0E7DEH      b        -68 -> 2062
  2128   0850H  0E6B7H      b        -658 -> 1474
  2130   0852H  0E6D2H      b        -604 -> 1530
  2132   0854H  0E6F3H      b        -538 -> 1598
  2134   0856H  0E6F2H      b        -540 -> 1598
  2136   0858H  0E6F1H      b        -542 -> 1598
  2138   085AH  0E702H      b        -508 -> 1634
  2140   085CH  0E715H      b        -470 -> 1674
  2142   085EH  0E672H      b        -796 -> 1350
  2144   0860H  0E671H      b        -798 -> 1350
  2146   0862H  0E670H      b        -800 -> 1350
  2148   0864H  0E66FH      b        -802 -> 1350
  2150   0866H  0E66EH      b        -804 -> 1350
  2152   0868H  0E66DH      b        -806 -> 1350
  2154   086AH  0E66CH      b        -808 -> 1350
  2156   086CH  0E747H      b        -370 -> 1790
  2158   086EH  0E76BH      b        -298 -> 1864
  2160   0870H  0E787H      b        -242 -> 1922
  2162   0872H  0E79CH      b        -200 -> 1966
  2164   0874H  0E7B3H      b        -154 -> 2014
  2166   0876H  0E7CAH      b        -108 -> 2062
  2168   0878H  0B002H      add      sp,#8
  2170   087AH  0BD00H      pop      { pc }
  2172   087CH  0FF000000H

PROCEDURE Error..init:
  2176   0880H  0B500H      push     { lr }
  2178   0882H  046C0H      nop
  2180   0884H  04802H      ldr      r0,[pc,#8] -> 2192
  2182   0886H  04478H      add      r0,pc
  2184   0888H  04902H      ldr      r1,[pc,#8] -> 2196
  2186   088AH  06008H      str      r0,[r1]
  2188   088CH  0BD00H      pop      { pc }
  2190   088EH  046C0H      nop
  2192   0890H  -894
  2196   0894H  02002FFB8H

MODULE Errors:
  2200   0898H  0

PROCEDURE Errors.faultMessage:
  2204   089CH  0B503H      push     { r0, r1, lr }
  2206   089EH  09800H      ldr      r0,[sp]
  2208   08A0H  02102H      movs     r1,#2
  2210   08A2H  042C8H      cmn      r0,r1
  2212   08A4H  0D001H      beq.n    2 -> 2218
  2214   08A6H  0E009H      b        18 -> 2236
  2216   08A8H  046C0H      nop
  2218   08AAH  09801H      ldr      r0,[sp,#4]
  2220   08ACH  0A100H      adr      r1,pc,#0 -> 2224
  2222   08AEH  0E001H      b        2 -> 2228
  2224   08B0H  000494D4EH  "NMI"
  2228   08B4H  0680AH      ldr      r2,[r1]
  2230   08B6H  06002H      str      r2,[r0]
  2232   08B8H  0E07FH      b        254 -> 2490
  2234   08BAH  046C0H      nop
  2236   08BCH  09800H      ldr      r0,[sp]
  2238   08BEH  02103H      movs     r1,#3
  2240   08C0H  042C8H      cmn      r0,r1
  2242   08C2H  0D001H      beq.n    2 -> 2248
  2244   08C4H  0E013H      b        38 -> 2286
  2246   08C6H  046C0H      nop
  2248   08C8H  09801H      ldr      r0,[sp,#4]
  2250   08CAH  046C0H      nop
  2252   08CCH  0A100H      adr      r1,pc,#0 -> 2256
  2254   08CEH  0E005H      b        10 -> 2268
  2256   08D0H  064726168H  "hard"
  2260   08D4H  075616620H  " fau"
  2264   08D8H  00000746CH  "lt"
  2268   08DCH  04B38H      ldr      r3,[pc,#224] -> 2496
  2270   08DEH  0680AH      ldr      r2,[r1]
  2272   08E0H  03104H      adds     r1,#4
  2274   08E2H  06002H      str      r2,[r0]
  2276   08E4H  03004H      adds     r0,#4
  2278   08E6H  0401AH      ands     r2,r3
  2280   08E8H  0D1F9H      bne.n    -14 -> 2270
  2282   08EAH  0E066H      b        204 -> 2490
  2284   08ECH  046C0H      nop
  2286   08EEH  09800H      ldr      r0,[sp]
  2288   08F0H  02104H      movs     r1,#4
  2290   08F2H  042C8H      cmn      r0,r1
  2292   08F4H  0D001H      beq.n    2 -> 2298
  2294   08F6H  0E018H      b        48 -> 2346
  2296   08F8H  046C0H      nop
  2298   08FAH  09801H      ldr      r0,[sp,#4]
  2300   08FCH  0A100H      adr      r1,pc,#0 -> 2304
  2302   08FEH  0E00BH      b        22 -> 2328
  2304   0900H  06F6D656DH  "memo"
  2308   0904H  06D207972H  "ry m"
  2312   0908H  067616E61H  "anag"
  2316   090CH  06E656D65H  "emen"
  2320   0910H  061662074H  "t fa"
  2324   0914H  000746C75H  "ult"
  2328   0918H  04B29H      ldr      r3,[pc,#164] -> 2496
  2330   091AH  0680AH      ldr      r2,[r1]
  2332   091CH  03104H      adds     r1,#4
  2334   091EH  06002H      str      r2,[r0]
  2336   0920H  03004H      adds     r0,#4
  2338   0922H  0401AH      ands     r2,r3
  2340   0924H  0D1F9H      bne.n    -14 -> 2330
  2342   0926H  0E048H      b        144 -> 2490
  2344   0928H  046C0H      nop
  2346   092AH  09800H      ldr      r0,[sp]
  2348   092CH  02105H      movs     r1,#5
  2350   092EH  042C8H      cmn      r0,r1
  2352   0930H  0D001H      beq.n    2 -> 2358
  2354   0932H  0E012H      b        36 -> 2394
  2356   0934H  046C0H      nop
  2358   0936H  09801H      ldr      r0,[sp,#4]
  2360   0938H  0A100H      adr      r1,pc,#0 -> 2364
  2362   093AH  0E005H      b        10 -> 2376
  2364   093CH  020737562H  "bus "
  2368   0940H  06C756166H  "faul"
  2372   0944H  000000074H  "t"
  2376   0948H  04B1DH      ldr      r3,[pc,#116] -> 2496
  2378   094AH  0680AH      ldr      r2,[r1]
  2380   094CH  03104H      adds     r1,#4
  2382   094EH  06002H      str      r2,[r0]
  2384   0950H  03004H      adds     r0,#4
  2386   0952H  0401AH      ands     r2,r3
  2388   0954H  0D1F9H      bne.n    -14 -> 2378
  2390   0956H  0E030H      b        96 -> 2490
  2392   0958H  046C0H      nop
  2394   095AH  09800H      ldr      r0,[sp]
  2396   095CH  02106H      movs     r1,#6
  2398   095EH  042C8H      cmn      r0,r1
  2400   0960H  0D001H      beq.n    2 -> 2406
  2402   0962H  0E012H      b        36 -> 2442
  2404   0964H  046C0H      nop
  2406   0966H  09801H      ldr      r0,[sp,#4]
  2408   0968H  0A100H      adr      r1,pc,#0 -> 2412
  2410   096AH  0E005H      b        10 -> 2424
  2412   096CH  067617375H  "usag"
  2416   0970H  061662065H  "e fa"
  2420   0974H  000746C75H  "ult"
  2424   0978H  04B11H      ldr      r3,[pc,#68] -> 2496
  2426   097AH  0680AH      ldr      r2,[r1]
  2428   097CH  03104H      adds     r1,#4
  2430   097EH  06002H      str      r2,[r0]
  2432   0980H  03004H      adds     r0,#4
  2434   0982H  0401AH      ands     r2,r3
  2436   0984H  0D1F9H      bne.n    -14 -> 2426
  2438   0986H  0E018H      b        48 -> 2490
  2440   0988H  046C0H      nop
  2442   098AH  09801H      ldr      r0,[sp,#4]
  2444   098CH  0A100H      adr      r1,pc,#0 -> 2448
  2446   098EH  0E00DH      b        26 -> 2476
  2448   0990H  07373696DH  "miss"
  2452   0994H  020676E69H  "ing "
  2456   0998H  065637865H  "exce"
  2460   099CH  06F697470H  "ptio"
  2464   09A0H  06168206EH  "n ha"
  2468   09A4H  0656C646EH  "ndle"
  2472   09A8H  000000072H  "r"
  2476   09ACH  04B04H      ldr      r3,[pc,#16] -> 2496
  2478   09AEH  0680AH      ldr      r2,[r1]
  2480   09B0H  03104H      adds     r1,#4
  2482   09B2H  06002H      str      r2,[r0]
  2484   09B4H  03004H      adds     r0,#4
  2486   09B6H  0401AH      ands     r2,r3
  2488   09B8H  0D1F9H      bne.n    -14 -> 2478
  2490   09BAH  0B002H      add      sp,#8
  2492   09BCH  0BD00H      pop      { pc }
  2494   09BEH  046C0H      nop
  2496   09C0H  0FF000000H

PROCEDURE Errors.errorMessage:
  2500   09C4H  0B503H      push     { r0, r1, lr }
  2502   09C6H  09800H      ldr      r0,[sp]
  2504   09C8H  02864H      cmp      r0,#100
  2506   09CAH  0DA01H      bge.n    2 -> 2512
  2508   09CCH  0E1ACH      b        856 -> 3368
  2510   09CEH  046C0H      nop
  2512   09D0H  09800H      ldr      r0,[sp]
  2514   09D2H  02875H      cmp      r0,#117
  2516   09D4H  0DD01H      ble.n    2 -> 2522
  2518   09D6H  0E1A7H      b        846 -> 3368
  2520   09D8H  046C0H      nop
  2522   09DAH  09800H      ldr      r0,[sp]
  2524   09DCH  04601H      mov      r1,r0
  2526   09DEH  03964H      subs     r1,#100
  2528   09E0H  02912H      cmp      r1,#18
  2530   09E2H  0DD01H      ble.n    2 -> 2536
  2532   09E4H  0DF04H      svc      4
  2534   09E6H  00050H      <LineNo: 80>
  2536   09E8H  00049H      lsls     r1,r1,#1
  2538   09EAH  046C0H      nop
  2540   09ECH  04A01H      ldr      r2,[pc,#4] -> 2548
  2542   09EEH  01852H      adds     r2,r2,r1
  2544   09F0H  0447AH      add      r2,pc
  2546   09F2H  04710H      bx       r2
  2548   09F4H  779
  2552   09F8H  09801H      ldr      r0,[sp,#4]
  2554   09FAH  046C0H      nop
  2556   09FCH  0A100H      adr      r1,pc,#0 -> 2560
  2558   09FEH  0E005H      b        10 -> 2572
  2560   0A00H  063617473H  "stac"
  2564   0A04H  07274206BH  "k tr"
  2568   0A08H  000656361H  "ace"
  2572   0A0CH  04B72H      ldr      r3,[pc,#456] -> 3032
  2574   0A0EH  0680AH      ldr      r2,[r1]
  2576   0A10H  03104H      adds     r1,#4
  2578   0A12H  06002H      str      r2,[r0]
  2580   0A14H  03004H      adds     r0,#4
  2582   0A16H  0401AH      ands     r2,r3
  2584   0A18H  0D1F9H      bne.n    -14 -> 2574
  2586   0A1AH  0E183H      b        774 -> 3364
  2588   0A1CH  046C0H      nop
  2590   0A1EH  09801H      ldr      r0,[sp,#4]
  2592   0A20H  0A100H      adr      r1,pc,#0 -> 2596
  2594   0A22H  0E00BH      b        22 -> 2620
  2596   0A24H  063657270H  "prec"
  2600   0A28H  069646E6FH  "ondi"
  2604   0A2CH  06E6F6974H  "tion"
  2608   0A30H  06F697620H  " vio"
  2612   0A34H  06974616CH  "lati"
  2616   0A38H  000006E6FH  "on"
  2620   0A3CH  04B66H      ldr      r3,[pc,#408] -> 3032
  2622   0A3EH  0680AH      ldr      r2,[r1]
  2624   0A40H  03104H      adds     r1,#4
  2626   0A42H  06002H      str      r2,[r0]
  2628   0A44H  03004H      adds     r0,#4
  2630   0A46H  0401AH      ands     r2,r3
  2632   0A48H  0D1F9H      bne.n    -14 -> 2622
  2634   0A4AH  0E16BH      b        726 -> 3364
  2636   0A4CH  046C0H      nop
  2638   0A4EH  09801H      ldr      r0,[sp,#4]
  2640   0A50H  0A100H      adr      r1,pc,#0 -> 2644
  2642   0A52H  0E00BH      b        22 -> 2668
  2644   0A54H  074736F70H  "post"
  2648   0A58H  0646E6F63H  "cond"
  2652   0A5CH  06F697469H  "itio"
  2656   0A60H  06976206EH  "n vi"
  2660   0A64H  074616C6FH  "olat"
  2664   0A68H  0006E6F69H  "ion"
  2668   0A6CH  04B5AH      ldr      r3,[pc,#360] -> 3032
  2670   0A6EH  0680AH      ldr      r2,[r1]
  2672   0A70H  03104H      adds     r1,#4
  2674   0A72H  06002H      str      r2,[r0]
  2676   0A74H  03004H      adds     r0,#4
  2678   0A76H  0401AH      ands     r2,r3
  2680   0A78H  0D1F9H      bne.n    -14 -> 2670
  2682   0A7AH  0E153H      b        678 -> 3364
  2684   0A7CH  046C0H      nop
  2686   0A7EH  09801H      ldr      r0,[sp,#4]
  2688   0A80H  0A100H      adr      r1,pc,#0 -> 2692
  2690   0A82H  0E00DH      b        26 -> 2720
  2692   0A84H  0736E6F63H  "cons"
  2696   0A88H  065747369H  "iste"
  2700   0A8CH  02079636EH  "ncy "
  2704   0A90H  063656863H  "chec"
  2708   0A94H  06976206BH  "k vi"
  2712   0A98H  074616C6FH  "olat"
  2716   0A9CH  0006E6F69H  "ion"
  2720   0AA0H  04B4DH      ldr      r3,[pc,#308] -> 3032
  2722   0AA2H  0680AH      ldr      r2,[r1]
  2724   0AA4H  03104H      adds     r1,#4
  2726   0AA6H  06002H      str      r2,[r0]
  2728   0AA8H  03004H      adds     r0,#4
  2730   0AAAH  0401AH      ands     r2,r3
  2732   0AACH  0D1F9H      bne.n    -14 -> 2722
  2734   0AAEH  0E139H      b        626 -> 3364
  2736   0AB0H  046C0H      nop
  2738   0AB2H  09801H      ldr      r0,[sp,#4]
  2740   0AB4H  0A100H      adr      r1,pc,#0 -> 2744
  2742   0AB6H  0E00BH      b        22 -> 2768
  2744   0AB8H  0676F7270H  "prog"
  2748   0ABCH  0206D6172H  "ram "
  2752   0AC0H  069736564H  "desi"
  2756   0AC4H  065206E67H  "gn e"
  2760   0AC8H  0726F7272H  "rror"
  2764   0ACCH  000000000H
  2768   0AD0H  04B41H      ldr      r3,[pc,#260] -> 3032
  2770   0AD2H  0680AH      ldr      r2,[r1]
  2772   0AD4H  03104H      adds     r1,#4
  2774   0AD6H  06002H      str      r2,[r0]
  2776   0AD8H  03004H      adds     r0,#4
  2778   0ADAH  0401AH      ands     r2,r3
  2780   0ADCH  0D1F9H      bne.n    -14 -> 2770
  2782   0ADEH  0E121H      b        578 -> 3364
  2784   0AE0H  046C0H      nop
  2786   0AE2H  09801H      ldr      r0,[sp,#4]
  2788   0AE4H  0A100H      adr      r1,pc,#0 -> 2792
  2790   0AE6H  0E007H      b        14 -> 2808
  2792   0AE8H  066667562H  "buff"
  2796   0AECH  06F207265H  "er o"
  2800   0AF0H  066726576H  "verf"
  2804   0AF4H  000776F6CH  "low"
  2808   0AF8H  04B37H      ldr      r3,[pc,#220] -> 3032
  2810   0AFAH  0680AH      ldr      r2,[r1]
  2812   0AFCH  03104H      adds     r1,#4
  2814   0AFEH  06002H      str      r2,[r0]
  2816   0B00H  03004H      adds     r0,#4
  2818   0B02H  0401AH      ands     r2,r3
  2820   0B04H  0D1F9H      bne.n    -14 -> 2810
  2822   0B06H  0E10DH      b        538 -> 3364
  2824   0B08H  046C0H      nop
  2826   0B0AH  09801H      ldr      r0,[sp,#4]
  2828   0B0CH  0A100H      adr      r1,pc,#0 -> 2832
  2830   0B0EH  0E007H      b        14 -> 2848
  2832   0B10H  066667562H  "buff"
  2836   0B14H  065207265H  "er e"
  2840   0B18H  07974706DH  "mpty"
  2844   0B1CH  000000000H
  2848   0B20H  04B2DH      ldr      r3,[pc,#180] -> 3032
  2850   0B22H  0680AH      ldr      r2,[r1]
  2852   0B24H  03104H      adds     r1,#4
  2854   0B26H  06002H      str      r2,[r0]
  2856   0B28H  03004H      adds     r0,#4
  2858   0B2AH  0401AH      ands     r2,r3
  2860   0B2CH  0D1F9H      bne.n    -14 -> 2850
  2862   0B2EH  0E0F9H      b        498 -> 3364
  2864   0B30H  046C0H      nop
  2866   0B32H  09801H      ldr      r0,[sp,#4]
  2868   0B34H  0A100H      adr      r1,pc,#0 -> 2872
  2870   0B36H  0E007H      b        14 -> 2888
  2872   0B38H  0696D6974H  "timi"
  2876   0B3CH  06520676EH  "ng e"
  2880   0B40H  0726F7272H  "rror"
  2884   0B44H  000000000H
  2888   0B48H  04B23H      ldr      r3,[pc,#140] -> 3032
  2890   0B4AH  0680AH      ldr      r2,[r1]
  2892   0B4CH  03104H      adds     r1,#4
  2894   0B4EH  06002H      str      r2,[r0]
  2896   0B50H  03004H      adds     r0,#4
  2898   0B52H  0401AH      ands     r2,r3
  2900   0B54H  0D1F9H      bne.n    -14 -> 2890
  2902   0B56H  0E0E5H      b        458 -> 3364
  2904   0B58H  046C0H      nop
  2906   0B5AH  09801H      ldr      r0,[sp,#4]
  2908   0B5CH  0A100H      adr      r1,pc,#0 -> 2912
  2910   0B5EH  0E007H      b        14 -> 2928
  2912   0B60H  070616568H  "heap"
  2916   0B64H  065766F20H  " ove"
  2920   0B68H  06F6C6672H  "rflo"
  2924   0B6CH  000000077H  "w"
  2928   0B70H  04B19H      ldr      r3,[pc,#100] -> 3032
  2930   0B72H  0680AH      ldr      r2,[r1]
  2932   0B74H  03104H      adds     r1,#4
  2934   0B76H  06002H      str      r2,[r0]
  2936   0B78H  03004H      adds     r0,#4
  2938   0B7AH  0401AH      ands     r2,r3
  2940   0B7CH  0D1F9H      bne.n    -14 -> 2930
  2942   0B7EH  0E0D1H      b        418 -> 3364
  2944   0B80H  046C0H      nop
  2946   0B82H  09801H      ldr      r0,[sp,#4]
  2948   0B84H  0A100H      adr      r1,pc,#0 -> 2952
  2950   0B86H  0E007H      b        14 -> 2968
  2952   0B88H  063617473H  "stac"
  2956   0B8CH  0766F206BH  "k ov"
  2960   0B90H  06C667265H  "erfl"
  2964   0B94H  00000776FH  "ow"
  2968   0B98H  04B0FH      ldr      r3,[pc,#60] -> 3032
  2970   0B9AH  0680AH      ldr      r2,[r1]
  2972   0B9CH  03104H      adds     r1,#4
  2974   0B9EH  06002H      str      r2,[r0]
  2976   0BA0H  03004H      adds     r0,#4
  2978   0BA2H  0401AH      ands     r2,r3
  2980   0BA4H  0D1F9H      bne.n    -14 -> 2970
  2982   0BA6H  0E0BDH      b        378 -> 3364
  2984   0BA8H  046C0H      nop
  2986   0BAAH  09801H      ldr      r0,[sp,#4]
  2988   0BACH  0A100H      adr      r1,pc,#0 -> 2992
  2990   0BAEH  0E009H      b        18 -> 3012
  2992   0BB0H  0726F7473H  "stor"
  2996   0BB4H  020656761H  "age "
  3000   0BB8H  07265766FH  "over"
  3004   0BBCH  0776F6C66H  "flow"
  3008   0BC0H  000000000H
  3012   0BC4H  04B04H      ldr      r3,[pc,#16] -> 3032
  3014   0BC6H  0680AH      ldr      r2,[r1]
  3016   0BC8H  03104H      adds     r1,#4
  3018   0BCAH  06002H      str      r2,[r0]
  3020   0BCCH  03004H      adds     r0,#4
  3022   0BCEH  0401AH      ands     r2,r3
  3024   0BD0H  0D1F9H      bne.n    -14 -> 3014
  3026   0BD2H  046C0H      nop
  3028   0BD4H  0F000F802H  bl.w     Errors.errorMessage + 536
  3032   0BD8H  0FF000000H
  3036   0BDCH  0E0A2H      b        324 -> 3364
  3038   0BDEH  046C0H      nop
  3040   0BE0H  09801H      ldr      r0,[sp,#4]
  3042   0BE2H  046C0H      nop
  3044   0BE4H  0A100H      adr      r1,pc,#0 -> 3048
  3046   0BE6H  0E007H      b        14 -> 3064
  3048   0BE8H  0726F7473H  "stor"
  3052   0BECH  020656761H  "age "
  3056   0BF0H  06F727265H  "erro"
  3060   0BF4H  000000072H  "r"
  3064   0BF8H  04B66H      ldr      r3,[pc,#408] -> 3476
  3066   0BFAH  0680AH      ldr      r2,[r1]
  3068   0BFCH  03104H      adds     r1,#4
  3070   0BFEH  06002H      str      r2,[r0]
  3072   0C00H  03004H      adds     r0,#4
  3074   0C02H  0401AH      ands     r2,r3
  3076   0C04H  0D1F9H      bne.n    -14 -> 3066
  3078   0C06H  0E08DH      b        282 -> 3364
  3080   0C08H  046C0H      nop
  3082   0C0AH  09801H      ldr      r0,[sp,#4]
  3084   0C0CH  0A100H      adr      r1,pc,#0 -> 3088
  3086   0C0EH  0E005H      b        10 -> 3100
  3088   0C10H  067617375H  "usag"
  3092   0C14H  072652065H  "e er"
  3096   0C18H  000726F72H  "ror"
  3100   0C1CH  04B5DH      ldr      r3,[pc,#372] -> 3476
  3102   0C1EH  0680AH      ldr      r2,[r1]
  3104   0C20H  03104H      adds     r1,#4
  3106   0C22H  06002H      str      r2,[r0]
  3108   0C24H  03004H      adds     r0,#4
  3110   0C26H  0401AH      ands     r2,r3
  3112   0C28H  0D1F9H      bne.n    -14 -> 3102
  3114   0C2AH  0E07BH      b        246 -> 3364
  3116   0C2CH  046C0H      nop
  3118   0C2EH  09801H      ldr      r0,[sp,#4]
  3120   0C30H  0A100H      adr      r1,pc,#0 -> 3124
  3122   0C32H  0E00DH      b        26 -> 3152
  3124   0C34H  06F736572H  "reso"
  3128   0C38H  065637275H  "urce"
  3132   0C3CH  073696D20H  " mis"
  3136   0C40H  0676E6973H  "sing"
  3140   0C44H  020726F20H  " or "
  3144   0C48H  06C756166H  "faul"
  3148   0C4CH  000007974H  "ty"
  3152   0C50H  04B50H      ldr      r3,[pc,#320] -> 3476
  3154   0C52H  0680AH      ldr      r2,[r1]
  3156   0C54H  03104H      adds     r1,#4
  3158   0C56H  06002H      str      r2,[r0]
  3160   0C58H  03004H      adds     r0,#4
  3162   0C5AH  0401AH      ands     r2,r3
  3164   0C5CH  0D1F9H      bne.n    -14 -> 3154
  3166   0C5EH  0E061H      b        194 -> 3364
  3168   0C60H  046C0H      nop
  3170   0C62H  09801H      ldr      r0,[sp,#4]
  3172   0C64H  0A100H      adr      r1,pc,#0 -> 3176
  3174   0C66H  0E00DH      b        26 -> 3204
  3176   0C68H  0636E7566H  "func"
  3180   0C6CH  06E6F6974H  "tion"
  3184   0C70H  074696C61H  "alit"
  3188   0C74H  06F6E2079H  "y no"
  3192   0C78H  075732074H  "t su"
  3196   0C7CH  0726F7070H  "ppor"
  3200   0C80H  000646574H  "ted"
  3204   0C84H  04B43H      ldr      r3,[pc,#268] -> 3476
  3206   0C86H  0680AH      ldr      r2,[r1]
  3208   0C88H  03104H      adds     r1,#4
  3210   0C8AH  06002H      str      r2,[r0]
  3212   0C8CH  03004H      adds     r0,#4
  3214   0C8EH  0401AH      ands     r2,r3
  3216   0C90H  0D1F9H      bne.n    -14 -> 3206
  3218   0C92H  0E047H      b        142 -> 3364
  3220   0C94H  046C0H      nop
  3222   0C96H  09801H      ldr      r0,[sp,#4]
  3224   0C98H  0A100H      adr      r1,pc,#0 -> 3228
  3226   0C9AH  0E011H      b        34 -> 3264
  3228   0C9CH  0636E7566H  "func"
  3232   0CA0H  06E6F6974H  "tion"
  3236   0CA4H  074696C61H  "alit"
  3240   0CA8H  06F6E2079H  "y no"
  3244   0CACH  079282074H  "t (y"
  3248   0CB0H  020297465H  "et) "
  3252   0CB4H  06C706D69H  "impl"
  3256   0CB8H  06E656D65H  "emen"
  3260   0CBCH  000646574H  "ted"
  3264   0CC0H  04B34H      ldr      r3,[pc,#208] -> 3476
  3266   0CC2H  0680AH      ldr      r2,[r1]
  3268   0CC4H  03104H      adds     r1,#4
  3270   0CC6H  06002H      str      r2,[r0]
  3272   0CC8H  03004H      adds     r0,#4
  3274   0CCAH  0401AH      ands     r2,r3
  3276   0CCCH  0D1F9H      bne.n    -14 -> 3266
  3278   0CCEH  0E029H      b        82 -> 3364
  3280   0CD0H  046C0H      nop
  3282   0CD2H  09801H      ldr      r0,[sp,#4]
  3284   0CD4H  0A100H      adr      r1,pc,#0 -> 3288
  3286   0CD6H  0E009H      b        18 -> 3308
  3288   0CD8H  0206F6F74H  "too "
  3292   0CDCH  0796E616DH  "many"
  3296   0CE0H  072687420H  " thr"
  3300   0CE4H  073646165H  "eads"
  3304   0CE8H  000000000H
  3308   0CECH  04B29H      ldr      r3,[pc,#164] -> 3476
  3310   0CEEH  0680AH      ldr      r2,[r1]
  3312   0CF0H  03104H      adds     r1,#4
  3314   0CF2H  06002H      str      r2,[r0]
  3316   0CF4H  03004H      adds     r0,#4
  3318   0CF6H  0401AH      ands     r2,r3
  3320   0CF8H  0D1F9H      bne.n    -14 -> 3310
  3322   0CFAH  0E013H      b        38 -> 3364
  3324   0CFCH  046C0H      nop
  3326   0CFEH  0E67BH      b        -778 -> 2552
  3328   0D00H  0E68DH      b        -742 -> 2590
  3330   0D02H  0E6A4H      b        -696 -> 2638
  3332   0D04H  0E6BBH      b        -650 -> 2686
  3334   0D06H  0E6D4H      b        -600 -> 2738
  3336   0D08H  0E6EBH      b        -554 -> 2786
  3338   0D0AH  0E6FEH      b        -516 -> 2826
  3340   0D0CH  0E711H      b        -478 -> 2866
  3342   0D0EH  0E724H      b        -440 -> 2906
  3344   0D10H  0E737H      b        -402 -> 2946
  3346   0D12H  0E74AH      b        -364 -> 2986
  3348   0D14H  0E764H      b        -312 -> 3040
  3350   0D16H  0E778H      b        -272 -> 3082
  3352   0D18H  0E663H      b        -826 -> 2530
  3354   0D1AH  0E788H      b        -240 -> 3118
  3356   0D1CH  0E7A1H      b        -190 -> 3170
  3358   0D1EH  0E7BAH      b        -140 -> 3222
  3360   0D20H  0E7D7H      b        -82 -> 3282
  3362   0D22H  046C0H      nop
  3364   0D24H  0E033H      b        102 -> 3470
  3366   0D26H  046C0H      nop
  3368   0D28H  09800H      ldr      r0,[sp]
  3370   0D2AH  02801H      cmp      r0,#1
  3372   0D2CH  0DA01H      bge.n    2 -> 3378
  3374   0D2EH  0E01CH      b        56 -> 3434
  3376   0D30H  046C0H      nop
  3378   0D32H  09800H      ldr      r0,[sp]
  3380   0D34H  02819H      cmp      r0,#25
  3382   0D36H  0DD01H      ble.n    2 -> 3388
  3384   0D38H  0E017H      b        46 -> 3434
  3386   0D3AH  046C0H      nop
  3388   0D3CH  0207FH      movs     r0,#127
  3390   0D3EH  00340H      lsls     r0,r0,#13
  3392   0D40H  09900H      ldr      r1,[sp]
  3394   0D42H  02201H      movs     r2,#1
  3396   0D44H  0408AH      lsls     r2,r1
  3398   0D46H  04210H      tst      r0,r2
  3400   0D48H  0D001H      beq.n    2 -> 3406
  3402   0D4AH  0E00EH      b        28 -> 3434
  3404   0D4CH  046C0H      nop
  3406   0D4EH  09800H      ldr      r0,[sp]
  3408   0D50H  09901H      ldr      r1,[sp,#4]
  3410   0D52H  04A11H      ldr      r2,[pc,#68] -> 3480
  3412   0D54H  06812H      ldr      r2,[r2]
  3414   0D56H  02A00H      cmp      r2,#0
  3416   0D58H  0D101H      bne.n    2 -> 3422
  3418   0D5AH  0DF05H      svc      5
  3420   0D5CH  00075H      <LineNo: 117>
  3422   0D5EH  03201H      adds     r2,#1
  3424   0D60H  04790H      blx      r2
  3426   0D62H  0E000H      b        0 -> 3430
  3428   0D64H  00075H      <LineNo: 117>
  3430   0D66H  0E012H      b        36 -> 3470
  3432   0D68H  046C0H      nop
  3434   0D6AH  09801H      ldr      r0,[sp,#4]
  3436   0D6CH  0A100H      adr      r1,pc,#0 -> 3440
  3438   0D6EH  0E007H      b        14 -> 3456
  3440   0D70H  06E6B6E75H  "unkn"
  3444   0D74H  0206E776FH  "own "
  3448   0D78H  06F727265H  "erro"
  3452   0D7CH  000000072H  "r"
  3456   0D80H  04B04H      ldr      r3,[pc,#16] -> 3476
  3458   0D82H  0680AH      ldr      r2,[r1]
  3460   0D84H  03104H      adds     r1,#4
  3462   0D86H  06002H      str      r2,[r0]
  3464   0D88H  03004H      adds     r0,#4
  3466   0D8AH  0401AH      ands     r2,r3
  3468   0D8CH  0D1F9H      bne.n    -14 -> 3458
  3470   0D8EH  0B002H      add      sp,#8
  3472   0D90H  0BD00H      pop      { pc }
  3474   0D92H  046C0H      nop
  3476   0D94H  0FF000000H
  3480   0D98H  02002FFB8H

PROCEDURE Errors.Msg:
  3484   0D9CH  0B503H      push     { r0, r1, lr }
  3486   0D9EH  09800H      ldr      r0,[sp]
  3488   0DA0H  02800H      cmp      r0,#0
  3490   0DA2H  0DB01H      blt.n    2 -> 3496
  3492   0DA4H  0E008H      b        16 -> 3512
  3494   0DA6H  046C0H      nop
  3496   0DA8H  09800H      ldr      r0,[sp]
  3498   0DAAH  09901H      ldr      r1,[sp,#4]
  3500   0DACH  0F7FFFD76H  bl.w     Errors.faultMessage
  3504   0DB0H  0E000H      b        0 -> 3508
  3506   0DB2H  0007FH      <LineNo: 127>
  3508   0DB4H  0E006H      b        12 -> 3524
  3510   0DB6H  046C0H      nop
  3512   0DB8H  09800H      ldr      r0,[sp]
  3514   0DBAH  09901H      ldr      r1,[sp,#4]
  3516   0DBCH  0F7FFFE02H  bl.w     Errors.errorMessage
  3520   0DC0H  0E000H      b        0 -> 3524
  3522   0DC2H  00081H      <LineNo: 129>
  3524   0DC4H  0B002H      add      sp,#8
  3526   0DC6H  0BD00H      pop      { pc }

PROCEDURE Errors.GetExceptionType:
  3528   0DC8H  0B503H      push     { r0, r1, lr }
  3530   0DCAH  09800H      ldr      r0,[sp]
  3532   0DCCH  02800H      cmp      r0,#0
  3534   0DCEH  0DB01H      blt.n    2 -> 3540
  3536   0DD0H  0E013H      b        38 -> 3578
  3538   0DD2H  046C0H      nop
  3540   0DD4H  09801H      ldr      r0,[sp,#4]
  3542   0DD6H  046C0H      nop
  3544   0DD8H  0A100H      adr      r1,pc,#0 -> 3548
  3546   0DDAH  0E005H      b        10 -> 3560
  3548   0DDCH  02075636DH  "mcu "
  3552   0DE0H  06C756166H  "faul"
  3556   0DE4H  000000074H  "t"
  3560   0DE8H  04B0EH      ldr      r3,[pc,#56] -> 3620
  3562   0DEAH  0680AH      ldr      r2,[r1]
  3564   0DECH  03104H      adds     r1,#4
  3566   0DEEH  06002H      str      r2,[r0]
  3568   0DF0H  03004H      adds     r0,#4
  3570   0DF2H  0401AH      ands     r2,r3
  3572   0DF4H  0D1F9H      bne.n    -14 -> 3562
  3574   0DF6H  0E012H      b        36 -> 3614
  3576   0DF8H  046C0H      nop
  3578   0DFAH  09801H      ldr      r0,[sp,#4]
  3580   0DFCH  0A100H      adr      r1,pc,#0 -> 3584
  3582   0DFEH  0E007H      b        14 -> 3600
  3584   0E00H  02D6E7572H  "run-"
  3588   0E04H  0656D6974H  "time"
  3592   0E08H  072726520H  " err"
  3596   0E0CH  00000726FH  "or"
  3600   0E10H  04B04H      ldr      r3,[pc,#16] -> 3620
  3602   0E12H  0680AH      ldr      r2,[r1]
  3604   0E14H  03104H      adds     r1,#4
  3606   0E16H  06002H      str      r2,[r0]
  3608   0E18H  03004H      adds     r0,#4
  3610   0E1AH  0401AH      ands     r2,r3
  3612   0E1CH  0D1F9H      bne.n    -14 -> 3602
  3614   0E1EH  0B002H      add      sp,#8
  3616   0E20H  0BD00H      pop      { pc }
  3618   0E22H  046C0H      nop
  3620   0E24H  0FF000000H

PROCEDURE Errors..init:
  3624   0E28H  0B500H      push     { lr }
  3626   0E2AH  0BD00H      pop      { pc }

MODULE GPIO:
  3628   0E2CH  0
  3632   0E30H  28
  3636   0E34H  0
  3640   0E38H  0
  3644   0E3CH  0
  3648   0E40H  0

PROCEDURE GPIO.SetFunction:
  3652   0E44H  0B503H      push     { r0, r1, lr }
  3654   0E46H  0B082H      sub      sp,#8
  3656   0E48H  0480DH      ldr      r0,[pc,#52] -> 3712
  3658   0E4AH  09903H      ldr      r1,[sp,#12]
  3660   0E4CH  02201H      movs     r2,#1
  3662   0E4EH  0408AH      lsls     r2,r1
  3664   0E50H  04210H      tst      r0,r2
  3666   0E52H  0D101H      bne.n    2 -> 3672
  3668   0E54H  0DF65H      svc      101
  3670   0E56H  00056H      <LineNo: 86>
  3672   0E58H  09802H      ldr      r0,[sp,#8]
  3674   0E5AH  000C0H      lsls     r0,r0,#3
  3676   0E5CH  04909H      ldr      r1,[pc,#36] -> 3716
  3678   0E5EH  01840H      adds     r0,r0,r1
  3680   0E60H  09000H      str      r0,[sp]
  3682   0E62H  09800H      ldr      r0,[sp]
  3684   0E64H  06801H      ldr      r1,[r0]
  3686   0E66H  09101H      str      r1,[sp,#4]
  3688   0E68H  09803H      ldr      r0,[sp,#12]
  3690   0E6AH  04669H      mov      r1,sp
  3692   0E6CH  0684AH      ldr      r2,[r1,#4]
  3694   0E6EH  04B06H      ldr      r3,[pc,#24] -> 3720
  3696   0E70H  0401AH      ands     r2,r3
  3698   0E72H  04302H      orrs     r2,r0
  3700   0E74H  09201H      str      r2,[sp,#4]
  3702   0E76H  09800H      ldr      r0,[sp]
  3704   0E78H  09901H      ldr      r1,[sp,#4]
  3706   0E7AH  06001H      str      r1,[r0]
  3708   0E7CH  0B004H      add      sp,#16
  3710   0E7EH  0BD00H      pop      { pc }
  3712   0E80H  1022
  3716   0E84H  040014004H
  3720   0E88H  -32

PROCEDURE GPIO.SetInverters:
  3724   0E8CH  0B503H      push     { r0, r1, lr }
  3726   0E8EH  0B082H      sub      sp,#8
  3728   0E90H  09802H      ldr      r0,[sp,#8]
  3730   0E92H  000C0H      lsls     r0,r0,#3
  3732   0E94H  04909H      ldr      r1,[pc,#36] -> 3772
  3734   0E96H  01840H      adds     r0,r0,r1
  3736   0E98H  09000H      str      r0,[sp]
  3738   0E9AH  09800H      ldr      r0,[sp]
  3740   0E9CH  06801H      ldr      r1,[r0]
  3742   0E9EH  09101H      str      r1,[sp,#4]
  3744   0EA0H  09803H      ldr      r0,[sp,#12]
  3746   0EA2H  04669H      mov      r1,sp
  3748   0EA4H  0684AH      ldr      r2,[r1,#4]
  3750   0EA6H  0231FH      movs     r3,#31
  3752   0EA8H  0401AH      ands     r2,r3
  3754   0EAAH  00140H      lsls     r0,r0,#5
  3756   0EACH  04302H      orrs     r2,r0
  3758   0EAEH  09201H      str      r2,[sp,#4]
  3760   0EB0H  09800H      ldr      r0,[sp]
  3762   0EB2H  09901H      ldr      r1,[sp,#4]
  3764   0EB4H  06001H      str      r1,[r0]
  3766   0EB6H  0B004H      add      sp,#16
  3768   0EB8H  0BD00H      pop      { pc }
  3770   0EBAH  046C0H      nop
  3772   0EBCH  040014004H

PROCEDURE GPIO.ConfigurePad:
  3776   0EC0H  0B507H      push     { r0, r1, r2, lr }
  3778   0EC2H  0B082H      sub      sp,#8
  3780   0EC4H  02003H      movs     r0,#3
  3782   0EC6H  09903H      ldr      r1,[sp,#12]
  3784   0EC8H  06809H      ldr      r1,[r1]
  3786   0ECAH  02201H      movs     r2,#1
  3788   0ECCH  0408AH      lsls     r2,r1
  3790   0ECEH  04210H      tst      r0,r2
  3792   0ED0H  0D101H      bne.n    2 -> 3798
  3794   0ED2H  0DF65H      svc      101
  3796   0ED4H  0006EH      <LineNo: 110>
  3798   0ED6H  02003H      movs     r0,#3
  3800   0ED8H  09903H      ldr      r1,[sp,#12]
  3802   0EDAH  06849H      ldr      r1,[r1,#4]
  3804   0EDCH  02201H      movs     r2,#1
  3806   0EDEH  0408AH      lsls     r2,r1
  3808   0EE0H  04210H      tst      r0,r2
  3810   0EE2H  0D101H      bne.n    2 -> 3816
  3812   0EE4H  0DF65H      svc      101
  3814   0EE6H  0006FH      <LineNo: 111>
  3816   0EE8H  0200FH      movs     r0,#15
  3818   0EEAH  09903H      ldr      r1,[sp,#12]
  3820   0EECH  06889H      ldr      r1,[r1,#8]
  3822   0EEEH  02201H      movs     r2,#1
  3824   0EF0H  0408AH      lsls     r2,r1
  3826   0EF2H  04210H      tst      r0,r2
  3828   0EF4H  0D101H      bne.n    2 -> 3834
  3830   0EF6H  0DF65H      svc      101
  3832   0EF8H  00070H      <LineNo: 112>
  3834   0EFAH  02003H      movs     r0,#3
  3836   0EFCH  09903H      ldr      r1,[sp,#12]
  3838   0EFEH  068C9H      ldr      r1,[r1,#12]
  3840   0F00H  02201H      movs     r2,#1
  3842   0F02H  0408AH      lsls     r2,r1
  3844   0F04H  04210H      tst      r0,r2
  3846   0F06H  0D101H      bne.n    2 -> 3852
  3848   0F08H  0DF65H      svc      101
  3850   0F0AH  00071H      <LineNo: 113>
  3852   0F0CH  02003H      movs     r0,#3
  3854   0F0EH  09903H      ldr      r1,[sp,#12]
  3856   0F10H  06909H      ldr      r1,[r1,#16]
  3858   0F12H  02201H      movs     r2,#1
  3860   0F14H  0408AH      lsls     r2,r1
  3862   0F16H  04210H      tst      r0,r2
  3864   0F18H  0D101H      bne.n    2 -> 3870
  3866   0F1AH  0DF65H      svc      101
  3868   0F1CH  00072H      <LineNo: 114>
  3870   0F1EH  02003H      movs     r0,#3
  3872   0F20H  09903H      ldr      r1,[sp,#12]
  3874   0F22H  06949H      ldr      r1,[r1,#20]
  3876   0F24H  02201H      movs     r2,#1
  3878   0F26H  0408AH      lsls     r2,r1
  3880   0F28H  04210H      tst      r0,r2
  3882   0F2AH  0D101H      bne.n    2 -> 3888
  3884   0F2CH  0DF65H      svc      101
  3886   0F2EH  00073H      <LineNo: 115>
  3888   0F30H  02003H      movs     r0,#3
  3890   0F32H  09903H      ldr      r1,[sp,#12]
  3892   0F34H  06989H      ldr      r1,[r1,#24]
  3894   0F36H  02201H      movs     r2,#1
  3896   0F38H  0408AH      lsls     r2,r1
  3898   0F3AH  04210H      tst      r0,r2
  3900   0F3CH  0D101H      bne.n    2 -> 3906
  3902   0F3EH  0DF65H      svc      101
  3904   0F40H  00074H      <LineNo: 116>
  3906   0F42H  09802H      ldr      r0,[sp,#8]
  3908   0F44H  00080H      lsls     r0,r0,#2
  3910   0F46H  04917H      ldr      r1,[pc,#92] -> 4004
  3912   0F48H  01840H      adds     r0,r0,r1
  3914   0F4AH  09000H      str      r0,[sp]
  3916   0F4CH  09803H      ldr      r0,[sp,#12]
  3918   0F4EH  06980H      ldr      r0,[r0,#24]
  3920   0F50H  09001H      str      r0,[sp,#4]
  3922   0F52H  09803H      ldr      r0,[sp,#12]
  3924   0F54H  06940H      ldr      r0,[r0,#20]
  3926   0F56H  00040H      lsls     r0,r0,#1
  3928   0F58H  09901H      ldr      r1,[sp,#4]
  3930   0F5AH  01808H      adds     r0,r1,r0
  3932   0F5CH  09001H      str      r0,[sp,#4]
  3934   0F5EH  09803H      ldr      r0,[sp,#12]
  3936   0F60H  06900H      ldr      r0,[r0,#16]
  3938   0F62H  00080H      lsls     r0,r0,#2
  3940   0F64H  09901H      ldr      r1,[sp,#4]
  3942   0F66H  01808H      adds     r0,r1,r0
  3944   0F68H  09001H      str      r0,[sp,#4]
  3946   0F6AH  09803H      ldr      r0,[sp,#12]
  3948   0F6CH  068C0H      ldr      r0,[r0,#12]
  3950   0F6EH  000C0H      lsls     r0,r0,#3
  3952   0F70H  09901H      ldr      r1,[sp,#4]
  3954   0F72H  01808H      adds     r0,r1,r0
  3956   0F74H  09001H      str      r0,[sp,#4]
  3958   0F76H  09803H      ldr      r0,[sp,#12]
  3960   0F78H  06880H      ldr      r0,[r0,#8]
  3962   0F7AH  00100H      lsls     r0,r0,#4
  3964   0F7CH  09901H      ldr      r1,[sp,#4]
  3966   0F7EH  01808H      adds     r0,r1,r0
  3968   0F80H  09001H      str      r0,[sp,#4]
  3970   0F82H  09803H      ldr      r0,[sp,#12]
  3972   0F84H  06840H      ldr      r0,[r0,#4]
  3974   0F86H  00180H      lsls     r0,r0,#6
  3976   0F88H  09901H      ldr      r1,[sp,#4]
  3978   0F8AH  01808H      adds     r0,r1,r0
  3980   0F8CH  09001H      str      r0,[sp,#4]
  3982   0F8EH  09803H      ldr      r0,[sp,#12]
  3984   0F90H  06800H      ldr      r0,[r0]
  3986   0F92H  001C0H      lsls     r0,r0,#7
  3988   0F94H  09901H      ldr      r1,[sp,#4]
  3990   0F96H  01808H      adds     r0,r1,r0
  3992   0F98H  09001H      str      r0,[sp,#4]
  3994   0F9AH  09800H      ldr      r0,[sp]
  3996   0F9CH  09901H      ldr      r1,[sp,#4]
  3998   0F9EH  06001H      str      r1,[r0]
  4000   0FA0H  0B005H      add      sp,#20
  4002   0FA2H  0BD00H      pop      { pc }
  4004   0FA4H  04001C004H

PROCEDURE GPIO.GetPadBaseCfg:
  4008   0FA8H  0B503H      push     { r0, r1, lr }
  4010   0FAAH  09800H      ldr      r0,[sp]
  4012   0FACH  02100H      movs     r1,#0
  4014   0FAEH  02207H      movs     r2,#7
  4016   0FB0H  06001H      str      r1,[r0]
  4018   0FB2H  03004H      adds     r0,#4
  4020   0FB4H  03A01H      subs     r2,#1
  4022   0FB6H  0DCFBH      bgt.n    -10 -> 4016
  4024   0FB8H  02001H      movs     r0,#1
  4026   0FBAH  09900H      ldr      r1,[sp]
  4028   0FBCH  06048H      str      r0,[r1,#4]
  4030   0FBEH  02001H      movs     r0,#1
  4032   0FC0H  09900H      ldr      r1,[sp]
  4034   0FC2H  06088H      str      r0,[r1,#8]
  4036   0FC4H  02001H      movs     r0,#1
  4038   0FC6H  09900H      ldr      r1,[sp]
  4040   0FC8H  06108H      str      r0,[r1,#16]
  4042   0FCAH  02001H      movs     r0,#1
  4044   0FCCH  09900H      ldr      r1,[sp]
  4046   0FCEH  06148H      str      r0,[r1,#20]
  4048   0FD0H  0B002H      add      sp,#8
  4050   0FD2H  0BD00H      pop      { pc }

PROCEDURE GPIO.DisableOutput:
  4052   0FD4H  0B501H      push     { r0, lr }
  4054   0FD6H  0B081H      sub      sp,#4
  4056   0FD8H  09801H      ldr      r0,[sp,#4]
  4058   0FDAH  00080H      lsls     r0,r0,#2
  4060   0FDCH  04903H      ldr      r1,[pc,#12] -> 4076
  4062   0FDEH  01840H      adds     r0,r0,r1
  4064   0FE0H  09000H      str      r0,[sp]
  4066   0FE2H  09800H      ldr      r0,[sp]
  4068   0FE4H  02180H      movs     r1,#128
  4070   0FE6H  06001H      str      r1,[r0]
  4072   0FE8H  0B002H      add      sp,#8
  4074   0FEAH  0BD00H      pop      { pc }
  4076   0FECH  04001E004H

PROCEDURE GPIO.DisableInput:
  4080   0FF0H  0B501H      push     { r0, lr }
  4082   0FF2H  0B081H      sub      sp,#4
  4084   0FF4H  09801H      ldr      r0,[sp,#4]
  4086   0FF6H  00080H      lsls     r0,r0,#2
  4088   0FF8H  04903H      ldr      r1,[pc,#12] -> 4104
  4090   0FFAH  01840H      adds     r0,r0,r1
  4092   0FFCH  09000H      str      r0,[sp]
  4094   0FFEH  09800H      ldr      r0,[sp]
  4096  01000H  02140H      movs     r1,#64
  4098  01002H  06001H      str      r1,[r0]
  4100  01004H  0B002H      add      sp,#8
  4102  01006H  0BD00H      pop      { pc }
  4104  01008H  04001F004H

PROCEDURE GPIO.Set:
  4108  0100CH  0B501H      push     { r0, lr }
  4110  0100EH  04802H      ldr      r0,[pc,#8] -> 4120
  4112  01010H  09900H      ldr      r1,[sp]
  4114  01012H  06001H      str      r1,[r0]
  4116  01014H  0B001H      add      sp,#4
  4118  01016H  0BD00H      pop      { pc }
  4120  01018H  0D0000014H

PROCEDURE GPIO.Clear:
  4124  0101CH  0B501H      push     { r0, lr }
  4126  0101EH  04802H      ldr      r0,[pc,#8] -> 4136
  4128  01020H  09900H      ldr      r1,[sp]
  4130  01022H  06001H      str      r1,[r0]
  4132  01024H  0B001H      add      sp,#4
  4134  01026H  0BD00H      pop      { pc }
  4136  01028H  0D0000018H

PROCEDURE GPIO.Toggle:
  4140  0102CH  0B501H      push     { r0, lr }
  4142  0102EH  04802H      ldr      r0,[pc,#8] -> 4152
  4144  01030H  09900H      ldr      r1,[sp]
  4146  01032H  06001H      str      r1,[r0]
  4148  01034H  0B001H      add      sp,#4
  4150  01036H  0BD00H      pop      { pc }
  4152  01038H  0D000001CH

PROCEDURE GPIO.Get:
  4156  0103CH  0B501H      push     { r0, lr }
  4158  0103EH  04803H      ldr      r0,[pc,#12] -> 4172
  4160  01040H  06801H      ldr      r1,[r0]
  4162  01042H  09A00H      ldr      r2,[sp]
  4164  01044H  06011H      str      r1,[r2]
  4166  01046H  0B001H      add      sp,#4
  4168  01048H  0BD00H      pop      { pc }
  4170  0104AH  046C0H      nop
  4172  0104CH  0D0000004H

PROCEDURE GPIO.Put:
  4176  01050H  0B501H      push     { r0, lr }
  4178  01052H  04802H      ldr      r0,[pc,#8] -> 4188
  4180  01054H  09900H      ldr      r1,[sp]
  4182  01056H  06001H      str      r1,[r0]
  4184  01058H  0B001H      add      sp,#4
  4186  0105AH  0BD00H      pop      { pc }
  4188  0105CH  0D0000010H

PROCEDURE GPIO.GetBack:
  4192  01060H  0B501H      push     { r0, lr }
  4194  01062H  04803H      ldr      r0,[pc,#12] -> 4208
  4196  01064H  06801H      ldr      r1,[r0]
  4198  01066H  09A00H      ldr      r2,[sp]
  4200  01068H  06011H      str      r1,[r2]
  4202  0106AH  0B001H      add      sp,#4
  4204  0106CH  0BD00H      pop      { pc }
  4206  0106EH  046C0H      nop
  4208  01070H  0D0000010H

PROCEDURE GPIO.Check:
  4212  01074H  0B501H      push     { r0, lr }
  4214  01076H  0B081H      sub      sp,#4
  4216  01078H  04806H      ldr      r0,[pc,#24] -> 4244
  4218  0107AH  06801H      ldr      r1,[r0]
  4220  0107CH  09100H      str      r1,[sp]
  4222  0107EH  09800H      ldr      r0,[sp]
  4224  01080H  09901H      ldr      r1,[sp,#4]
  4226  01082H  04008H      ands     r0,r1
  4228  01084H  02100H      movs     r1,#0
  4230  01086H  04288H      cmp      r0,r1
  4232  01088H  0D101H      bne.n    2 -> 4238
  4234  0108AH  02000H      movs     r0,#0
  4236  0108CH  0E000H      b        0 -> 4240
  4238  0108EH  02001H      movs     r0,#1
  4240  01090H  0B002H      add      sp,#8
  4242  01092H  0BD00H      pop      { pc }
  4244  01094H  0D0000004H

PROCEDURE GPIO.OutputEnable:
  4248  01098H  0B501H      push     { r0, lr }
  4250  0109AH  04802H      ldr      r0,[pc,#8] -> 4260
  4252  0109CH  09900H      ldr      r1,[sp]
  4254  0109EH  06001H      str      r1,[r0]
  4256  010A0H  0B001H      add      sp,#4
  4258  010A2H  0BD00H      pop      { pc }
  4260  010A4H  0D0000024H

PROCEDURE GPIO.OutputDisable:
  4264  010A8H  0B501H      push     { r0, lr }
  4266  010AAH  04802H      ldr      r0,[pc,#8] -> 4276
  4268  010ACH  09900H      ldr      r1,[sp]
  4270  010AEH  06001H      str      r1,[r0]
  4272  010B0H  0B001H      add      sp,#4
  4274  010B2H  0BD00H      pop      { pc }
  4276  010B4H  0D0000028H

PROCEDURE GPIO.OutputEnToggle:
  4280  010B8H  0B501H      push     { r0, lr }
  4282  010BAH  04802H      ldr      r0,[pc,#8] -> 4292
  4284  010BCH  09900H      ldr      r1,[sp]
  4286  010BEH  06001H      str      r1,[r0]
  4288  010C0H  0B001H      add      sp,#4
  4290  010C2H  0BD00H      pop      { pc }
  4292  010C4H  0D000002CH

PROCEDURE GPIO.GetOutputEnable:
  4296  010C8H  0B501H      push     { r0, lr }
  4298  010CAH  04803H      ldr      r0,[pc,#12] -> 4312
  4300  010CCH  06801H      ldr      r1,[r0]
  4302  010CEH  09A00H      ldr      r2,[sp]
  4304  010D0H  06011H      str      r1,[r2]
  4306  010D2H  0B001H      add      sp,#4
  4308  010D4H  0BD00H      pop      { pc }
  4310  010D6H  046C0H      nop
  4312  010D8H  0D0000020H

PROCEDURE GPIO.init:
  4316  010DCH  0B500H      push     { lr }
  4318  010DEH  02005H      movs     r0,#5
  4320  010E0H  0F7FFF9E6H  bl.w     StartUp.ReleaseReset
  4324  010E4H  0E000H      b        0 -> 4328
  4326  010E6H  000EDH      <LineNo: 237>
  4328  010E8H  02005H      movs     r0,#5
  4330  010EAH  0F7FFF9FBH  bl.w     StartUp.AwaitReleaseDone
  4334  010EEH  0E000H      b        0 -> 4338
  4336  010F0H  000EEH      <LineNo: 238>
  4338  010F2H  02008H      movs     r0,#8
  4340  010F4H  0F7FFF9DCH  bl.w     StartUp.ReleaseReset
  4344  010F8H  0E000H      b        0 -> 4348
  4346  010FAH  000EFH      <LineNo: 239>
  4348  010FCH  02008H      movs     r0,#8
  4350  010FEH  0F7FFF9F1H  bl.w     StartUp.AwaitReleaseDone
  4354  01102H  0E000H      b        0 -> 4358
  4356  01104H  000F0H      <LineNo: 240>
  4358  01106H  0BD00H      pop      { pc }

PROCEDURE GPIO..init:
  4360  01108H  0B500H      push     { lr }
  4362  0110AH  0F7FFFFE7H  bl.w     GPIO.init
  4366  0110EH  0E000H      b        0 -> 4370
  4368  01110H  000F4H      <LineNo: 244>
  4370  01112H  0BD00H      pop      { pc }

MODULE Clocks:
  4372  01114H  0

PROCEDURE Clocks.Monitor:
  4376  01118H  0B501H      push     { r0, lr }
  4378  0111AH  0B081H      sub      sp,#4
  4380  0111CH  02000H      movs     r0,#0
  4382  0111EH  09000H      str      r0,[sp]
  4384  01120H  09801H      ldr      r0,[sp,#4]
  4386  01122H  04669H      mov      r1,sp
  4388  01124H  0680AH      ldr      r2,[r1]
  4390  01126H  04B0AH      ldr      r3,[pc,#40] -> 4432
  4392  01128H  0401AH      ands     r2,r3
  4394  0112AH  00140H      lsls     r0,r0,#5
  4396  0112CH  04302H      orrs     r2,r0
  4398  0112EH  09200H      str      r2,[sp]
  4400  01130H  04808H      ldr      r0,[pc,#32] -> 4436
  4402  01132H  09900H      ldr      r1,[sp]
  4404  01134H  06001H      str      r1,[r0]
  4406  01136H  04808H      ldr      r0,[pc,#32] -> 4440
  4408  01138H  02101H      movs     r1,#1
  4410  0113AH  002C9H      lsls     r1,r1,#11
  4412  0113CH  06001H      str      r1,[r0]
  4414  0113EH  02015H      movs     r0,#21
  4416  01140H  02108H      movs     r1,#8
  4418  01142H  0F7FFFE7FH  bl.w     GPIO.SetFunction
  4422  01146H  0E000H      b        0 -> 4426
  4424  01148H  0004BH      <LineNo: 75>
  4426  0114AH  0B002H      add      sp,#8
  4428  0114CH  0BD00H      pop      { pc }
  4430  0114EH  046C0H      nop
  4432  01150H  -481
  4436  01154H  040008000H
  4440  01158H  04000A000H

PROCEDURE Clocks.EnableClockWake:
  4444  0115CH  0B503H      push     { r0, r1, lr }
  4446  0115EH  04804H      ldr      r0,[pc,#16] -> 4464
  4448  01160H  09900H      ldr      r1,[sp]
  4450  01162H  06001H      str      r1,[r0]
  4452  01164H  04803H      ldr      r0,[pc,#12] -> 4468
  4454  01166H  09901H      ldr      r1,[sp,#4]
  4456  01168H  06001H      str      r1,[r0]
  4458  0116AH  0B002H      add      sp,#8
  4460  0116CH  0BD00H      pop      { pc }
  4462  0116EH  046C0H      nop
  4464  01170H  04000A0A0H
  4468  01174H  04000A0A4H

PROCEDURE Clocks.DisableClockWake:
  4472  01178H  0B503H      push     { r0, r1, lr }
  4474  0117AH  04804H      ldr      r0,[pc,#16] -> 4492
  4476  0117CH  09900H      ldr      r1,[sp]
  4478  0117EH  06001H      str      r1,[r0]
  4480  01180H  04803H      ldr      r0,[pc,#12] -> 4496
  4482  01182H  09901H      ldr      r1,[sp,#4]
  4484  01184H  06001H      str      r1,[r0]
  4486  01186H  0B002H      add      sp,#8
  4488  01188H  0BD00H      pop      { pc }
  4490  0118AH  046C0H      nop
  4492  0118CH  04000B0A0H
  4496  01190H  04000B0A4H

PROCEDURE Clocks.EnableClockSleep:
  4500  01194H  0B503H      push     { r0, r1, lr }
  4502  01196H  04804H      ldr      r0,[pc,#16] -> 4520
  4504  01198H  09900H      ldr      r1,[sp]
  4506  0119AH  06001H      str      r1,[r0]
  4508  0119CH  04803H      ldr      r0,[pc,#12] -> 4524
  4510  0119EH  09901H      ldr      r1,[sp,#4]
  4512  011A0H  06001H      str      r1,[r0]
  4514  011A2H  0B002H      add      sp,#8
  4516  011A4H  0BD00H      pop      { pc }
  4518  011A6H  046C0H      nop
  4520  011A8H  04000A0A8H
  4524  011ACH  04000A0ACH

PROCEDURE Clocks.DisableClockSleep:
  4528  011B0H  0B503H      push     { r0, r1, lr }
  4530  011B2H  04804H      ldr      r0,[pc,#16] -> 4548
  4532  011B4H  09900H      ldr      r1,[sp]
  4534  011B6H  06001H      str      r1,[r0]
  4536  011B8H  04803H      ldr      r0,[pc,#12] -> 4552
  4538  011BAH  09901H      ldr      r1,[sp,#4]
  4540  011BCH  06001H      str      r1,[r0]
  4542  011BEH  0B002H      add      sp,#8
  4544  011C0H  0BD00H      pop      { pc }
  4546  011C2H  046C0H      nop
  4548  011C4H  04000B0A8H
  4552  011C8H  04000B0ACH

PROCEDURE Clocks.GetEnabled:
  4556  011CCH  0B503H      push     { r0, r1, lr }
  4558  011CEH  04805H      ldr      r0,[pc,#20] -> 4580
  4560  011D0H  06801H      ldr      r1,[r0]
  4562  011D2H  09A00H      ldr      r2,[sp]
  4564  011D4H  06011H      str      r1,[r2]
  4566  011D6H  04804H      ldr      r0,[pc,#16] -> 4584
  4568  011D8H  06801H      ldr      r1,[r0]
  4570  011DAH  09A01H      ldr      r2,[sp,#4]
  4572  011DCH  06011H      str      r1,[r2]
  4574  011DEH  0B002H      add      sp,#8
  4576  011E0H  0BD00H      pop      { pc }
  4578  011E2H  046C0H      nop
  4580  011E4H  0400080B0H
  4584  011E8H  0400080B4H

PROCEDURE Clocks.startXOSC:
  4588  011ECH  0B500H      push     { lr }
  4590  011EEH  0B081H      sub      sp,#4
  4592  011F0H  02001H      movs     r0,#1
  4594  011F2H  0F7FFF94DH  bl.w     StartUp.AwaitPowerOnResetDone
  4598  011F6H  0E000H      b        0 -> 4602
  4600  011F8H  00076H      <LineNo: 118>
  4602  011FAH  0480BH      ldr      r0,[pc,#44] -> 4648
  4604  011FCH  0215EH      movs     r1,#94
  4606  011FEH  06001H      str      r1,[r0]
  4608  01200H  0480AH      ldr      r0,[pc,#40] -> 4652
  4610  01202H  06801H      ldr      r1,[r0]
  4612  01204H  09100H      str      r1,[sp]
  4614  01206H  0480AH      ldr      r0,[pc,#40] -> 4656
  4616  01208H  04669H      mov      r1,sp
  4618  0120AH  0680AH      ldr      r2,[r1]
  4620  0120CH  04B09H      ldr      r3,[pc,#36] -> 4660
  4622  0120EH  0401AH      ands     r2,r3
  4624  01210H  00300H      lsls     r0,r0,#12
  4626  01212H  04302H      orrs     r2,r0
  4628  01214H  09200H      str      r2,[sp]
  4630  01216H  04805H      ldr      r0,[pc,#20] -> 4652
  4632  01218H  09900H      ldr      r1,[sp]
  4634  0121AH  06001H      str      r1,[r0]
  4636  0121CH  04806H      ldr      r0,[pc,#24] -> 4664
  4638  0121EH  06801H      ldr      r1,[r0]
  4640  01220H  00009H      movs     r1,r1
  4642  01222H  0D5FBH      bpl.n    -10 -> 4636
  4644  01224H  0B001H      add      sp,#4
  4646  01226H  0BD00H      pop      { pc }
  4648  01228H  04002400CH
  4652  0122CH  040024000H
  4656  01230H  4011
  4660  01234H  0FF000FFFH
  4664  01238H  040024004H

PROCEDURE Clocks.startSysPLL:
  4668  0123CH  0B500H      push     { lr }
  4670  0123EH  0B081H      sub      sp,#4
  4672  01240H  0200CH      movs     r0,#12
  4674  01242H  0F7FFF935H  bl.w     StartUp.ReleaseReset
  4678  01246H  0E000H      b        0 -> 4682
  4680  01248H  00086H      <LineNo: 134>
  4682  0124AH  0200CH      movs     r0,#12
  4684  0124CH  0F7FFF94AH  bl.w     StartUp.AwaitReleaseDone
  4688  01250H  0E000H      b        0 -> 4692
  4690  01252H  00087H      <LineNo: 135>
  4692  01254H  04811H      ldr      r0,[pc,#68] -> 4764
  4694  01256H  0217DH      movs     r1,#125
  4696  01258H  06001H      str      r1,[r0]
  4698  0125AH  04811H      ldr      r0,[pc,#68] -> 4768
  4700  0125CH  02121H      movs     r1,#33
  4702  0125EH  06001H      str      r1,[r0]
  4704  01260H  04810H      ldr      r0,[pc,#64] -> 4772
  4706  01262H  06801H      ldr      r1,[r0]
  4708  01264H  00009H      movs     r1,r1
  4710  01266H  0D5FBH      bpl.n    -10 -> 4704
  4712  01268H  02000H      movs     r0,#0
  4714  0126AH  09000H      str      r0,[sp]
  4716  0126CH  02006H      movs     r0,#6
  4718  0126EH  04669H      mov      r1,sp
  4720  01270H  0680AH      ldr      r2,[r1]
  4722  01272H  04B0DH      ldr      r3,[pc,#52] -> 4776
  4724  01274H  0401AH      ands     r2,r3
  4726  01276H  00400H      lsls     r0,r0,#16
  4728  01278H  04302H      orrs     r2,r0
  4730  0127AH  09200H      str      r2,[sp]
  4732  0127CH  02002H      movs     r0,#2
  4734  0127EH  04669H      mov      r1,sp
  4736  01280H  0680AH      ldr      r2,[r1]
  4738  01282H  04B0AH      ldr      r3,[pc,#40] -> 4780
  4740  01284H  0401AH      ands     r2,r3
  4742  01286H  00300H      lsls     r0,r0,#12
  4744  01288H  04302H      orrs     r2,r0
  4746  0128AH  09200H      str      r2,[sp]
  4748  0128CH  04808H      ldr      r0,[pc,#32] -> 4784
  4750  0128EH  09900H      ldr      r1,[sp]
  4752  01290H  06001H      str      r1,[r0]
  4754  01292H  04803H      ldr      r0,[pc,#12] -> 4768
  4756  01294H  02108H      movs     r1,#8
  4758  01296H  06001H      str      r1,[r0]
  4760  01298H  0B001H      add      sp,#4
  4762  0129AH  0BD00H      pop      { pc }
  4764  0129CH  040028008H
  4768  012A0H  04002B004H
  4772  012A4H  040028000H
  4776  012A8H  0FFF8FFFFH
  4780  012ACH  -28673
  4784  012B0H  04002800CH

PROCEDURE Clocks.startUsbPLL:
  4788  012B4H  0B500H      push     { lr }
  4790  012B6H  0B081H      sub      sp,#4
  4792  012B8H  0200DH      movs     r0,#13
  4794  012BAH  0F7FFF8F9H  bl.w     StartUp.ReleaseReset
  4798  012BEH  0E000H      b        0 -> 4802
  4800  012C0H  0009FH      <LineNo: 159>
  4802  012C2H  0200DH      movs     r0,#13
  4804  012C4H  0F7FFF90EH  bl.w     StartUp.AwaitReleaseDone
  4808  012C8H  0E000H      b        0 -> 4812
  4810  012CAH  000A0H      <LineNo: 160>
  4812  012CCH  04811H      ldr      r0,[pc,#68] -> 4884
  4814  012CEH  02140H      movs     r1,#64
  4816  012D0H  06001H      str      r1,[r0]
  4818  012D2H  04811H      ldr      r0,[pc,#68] -> 4888
  4820  012D4H  02121H      movs     r1,#33
  4822  012D6H  06001H      str      r1,[r0]
  4824  012D8H  04810H      ldr      r0,[pc,#64] -> 4892
  4826  012DAH  06801H      ldr      r1,[r0]
  4828  012DCH  00009H      movs     r1,r1
  4830  012DEH  0D5FBH      bpl.n    -10 -> 4824
  4832  012E0H  02000H      movs     r0,#0
  4834  012E2H  09000H      str      r0,[sp]
  4836  012E4H  02004H      movs     r0,#4
  4838  012E6H  04669H      mov      r1,sp
  4840  012E8H  0680AH      ldr      r2,[r1]
  4842  012EAH  04B0DH      ldr      r3,[pc,#52] -> 4896
  4844  012ECH  0401AH      ands     r2,r3
  4846  012EEH  00400H      lsls     r0,r0,#16
  4848  012F0H  04302H      orrs     r2,r0
  4850  012F2H  09200H      str      r2,[sp]
  4852  012F4H  02004H      movs     r0,#4
  4854  012F6H  04669H      mov      r1,sp
  4856  012F8H  0680AH      ldr      r2,[r1]
  4858  012FAH  04B0AH      ldr      r3,[pc,#40] -> 4900
  4860  012FCH  0401AH      ands     r2,r3
  4862  012FEH  00300H      lsls     r0,r0,#12
  4864  01300H  04302H      orrs     r2,r0
  4866  01302H  09200H      str      r2,[sp]
  4868  01304H  04808H      ldr      r0,[pc,#32] -> 4904
  4870  01306H  09900H      ldr      r1,[sp]
  4872  01308H  06001H      str      r1,[r0]
  4874  0130AH  04803H      ldr      r0,[pc,#12] -> 4888
  4876  0130CH  02108H      movs     r1,#8
  4878  0130EH  06001H      str      r1,[r0]
  4880  01310H  0B001H      add      sp,#4
  4882  01312H  0BD00H      pop      { pc }
  4884  01314H  04002C008H
  4888  01318H  04002F004H
  4892  0131CH  04002C000H
  4896  01320H  0FFF8FFFFH
  4900  01324H  -28673
  4904  01328H  04002C00CH

PROCEDURE Clocks.connectClocks:
  4908  0132CH  0B500H      push     { lr }
  4910  0132EH  0B081H      sub      sp,#4
  4912  01330H  04810H      ldr      r0,[pc,#64] -> 4980
  4914  01332H  02101H      movs     r1,#1
  4916  01334H  06001H      str      r1,[r0]
  4918  01336H  04810H      ldr      r0,[pc,#64] -> 4984
  4920  01338H  06801H      ldr      r1,[r0]
  4922  0133AH  00789H      lsls     r1,r1,#30
  4924  0133CH  0D5FBH      bpl.n    -10 -> 4918
  4926  0133EH  0480FH      ldr      r0,[pc,#60] -> 4988
  4928  01340H  02101H      movs     r1,#1
  4930  01342H  06001H      str      r1,[r0]
  4932  01344H  0480EH      ldr      r0,[pc,#56] -> 4992
  4934  01346H  06801H      ldr      r1,[r0]
  4936  01348H  00789H      lsls     r1,r1,#30
  4938  0134AH  0D5FBH      bpl.n    -10 -> 4932
  4940  0134CH  02000H      movs     r0,#0
  4942  0134EH  09000H      str      r0,[sp]
  4944  01350H  02002H      movs     r0,#2
  4946  01352H  04669H      mov      r1,sp
  4948  01354H  0680AH      ldr      r2,[r1]
  4950  01356H  04B0BH      ldr      r3,[pc,#44] -> 4996
  4952  01358H  0401AH      ands     r2,r3
  4954  0135AH  00140H      lsls     r0,r0,#5
  4956  0135CH  04302H      orrs     r2,r0
  4958  0135EH  09200H      str      r2,[sp]
  4960  01360H  04809H      ldr      r0,[pc,#36] -> 5000
  4962  01362H  09900H      ldr      r1,[sp]
  4964  01364H  06001H      str      r1,[r0]
  4966  01366H  04809H      ldr      r0,[pc,#36] -> 5004
  4968  01368H  02101H      movs     r1,#1
  4970  0136AH  002C9H      lsls     r1,r1,#11
  4972  0136CH  06001H      str      r1,[r0]
  4974  0136EH  0B001H      add      sp,#4
  4976  01370H  0BD00H      pop      { pc }
  4978  01372H  046C0H      nop
  4980  01374H  04000A03CH
  4984  01378H  040008044H
  4988  0137CH  04000A030H
  4992  01380H  040008038H
  4996  01384H  -225
  5000  01388H  040008048H
  5004  0138CH  04000A048H

PROCEDURE Clocks.startTickClock:
  5008  01390H  0B500H      push     { lr }
  5010  01392H  04804H      ldr      r0,[pc,#16] -> 5028
  5012  01394H  02130H      movs     r1,#48
  5014  01396H  06001H      str      r1,[r0]
  5016  01398H  04803H      ldr      r0,[pc,#12] -> 5032
  5018  0139AH  02101H      movs     r1,#1
  5020  0139CH  00249H      lsls     r1,r1,#9
  5022  0139EH  06001H      str      r1,[r0]
  5024  013A0H  0BD00H      pop      { pc }
  5026  013A2H  046C0H      nop
  5028  013A4H  04005802CH
  5032  013A8H  04005A02CH

PROCEDURE Clocks.init:
  5036  013ACH  0B500H      push     { lr }
  5038  013AEH  0F7FFFF1DH  bl.w     Clocks.startXOSC
  5042  013B2H  0E000H      b        0 -> 5046
  5044  013B4H  000D6H      <LineNo: 214>
  5046  013B6H  0F7FFFF41H  bl.w     Clocks.startSysPLL
  5050  013BAH  0E000H      b        0 -> 5054
  5052  013BCH  000D7H      <LineNo: 215>
  5054  013BEH  0F7FFFF79H  bl.w     Clocks.startUsbPLL
  5058  013C2H  0E000H      b        0 -> 5062
  5060  013C4H  000D8H      <LineNo: 216>
  5062  013C6H  0F7FFFFB1H  bl.w     Clocks.connectClocks
  5066  013CAH  0E000H      b        0 -> 5070
  5068  013CCH  000D9H      <LineNo: 217>
  5070  013CEH  0F7FFFFDFH  bl.w     Clocks.startTickClock
  5074  013D2H  0E000H      b        0 -> 5078
  5076  013D4H  000DAH      <LineNo: 218>
  5078  013D6H  0BD00H      pop      { pc }

PROCEDURE Clocks..init:
  5080  013D8H  0B500H      push     { lr }
  5082  013DAH  0F7FFFFE7H  bl.w     Clocks.init
  5086  013DEH  0E000H      b        0 -> 5090
  5088  013E0H  000DEH      <LineNo: 222>
  5090  013E2H  0BD00H      pop      { pc }

MODULE MAU:
  5092  013E4H  0

PROCEDURE MAU.New:
  5096  013E8H  0B503H      push     { r0, r1, lr }
  5098  013EAH  09800H      ldr      r0,[sp]
  5100  013ECH  09901H      ldr      r1,[sp,#4]
  5102  013EEH  04A06H      ldr      r2,[pc,#24] -> 5128
  5104  013F0H  06812H      ldr      r2,[r2]
  5106  013F2H  02A00H      cmp      r2,#0
  5108  013F4H  0D101H      bne.n    2 -> 5114
  5110  013F6H  0DF05H      svc      5
  5112  013F8H  0001FH      <LineNo: 31>
  5114  013FAH  03201H      adds     r2,#1
  5116  013FCH  04790H      blx      r2
  5118  013FEH  0E000H      b        0 -> 5122
  5120  01400H  0001FH      <LineNo: 31>
  5122  01402H  0B002H      add      sp,#8
  5124  01404H  0BD00H      pop      { pc }
  5126  01406H  046C0H      nop
  5128  01408H  02002FFB4H

PROCEDURE MAU.Dispose:
  5132  0140CH  0B503H      push     { r0, r1, lr }
  5134  0140EH  09800H      ldr      r0,[sp]
  5136  01410H  09901H      ldr      r1,[sp,#4]
  5138  01412H  04A06H      ldr      r2,[pc,#24] -> 5164
  5140  01414H  06812H      ldr      r2,[r2]
  5142  01416H  02A00H      cmp      r2,#0
  5144  01418H  0D101H      bne.n    2 -> 5150
  5146  0141AH  0DF05H      svc      5
  5148  0141CH  00025H      <LineNo: 37>
  5150  0141EH  03201H      adds     r2,#1
  5152  01420H  04790H      blx      r2
  5154  01422H  0E000H      b        0 -> 5158
  5156  01424H  00025H      <LineNo: 37>
  5158  01426H  0B002H      add      sp,#8
  5160  01428H  0BD00H      pop      { pc }
  5162  0142AH  046C0H      nop
  5164  0142CH  02002FFB0H

PROCEDURE MAU.SetNew:
  5168  01430H  0B501H      push     { r0, lr }
  5170  01432H  09800H      ldr      r0,[sp]
  5172  01434H  04901H      ldr      r1,[pc,#4] -> 5180
  5174  01436H  06008H      str      r0,[r1]
  5176  01438H  0B001H      add      sp,#4
  5178  0143AH  0BD00H      pop      { pc }
  5180  0143CH  02002FFB4H

PROCEDURE MAU.SetDispose:
  5184  01440H  0B501H      push     { r0, lr }
  5186  01442H  09800H      ldr      r0,[sp]
  5188  01444H  04901H      ldr      r1,[pc,#4] -> 5196
  5190  01446H  06008H      str      r0,[r1]
  5192  01448H  0B001H      add      sp,#4
  5194  0144AH  0BD00H      pop      { pc }
  5196  0144CH  02002FFB0H

PROCEDURE MAU.Allocate:
  5200  01450H  0B503H      push     { r0, r1, lr }
  5202  01452H  0B083H      sub      sp,#12
  5204  01454H  04817H      ldr      r0,[pc,#92] -> 5300
  5206  01456H  06800H      ldr      r0,[r0]
  5208  01458H  02800H      cmp      r0,#0
  5210  0145AH  0D001H      beq.n    2 -> 5216
  5212  0145CH  0E004H      b        8 -> 5224
  5214  0145EH  046C0H      nop
  5216  01460H  04668H      mov      r0,sp
  5218  01462H  09002H      str      r0,[sp,#8]
  5220  01464H  0E003H      b        6 -> 5230
  5222  01466H  046C0H      nop
  5224  01468H  04812H      ldr      r0,[pc,#72] -> 5300
  5226  0146AH  06800H      ldr      r0,[r0]
  5228  0146CH  09002H      str      r0,[sp,#8]
  5230  0146EH  09804H      ldr      r0,[sp,#16]
  5232  01470H  06801H      ldr      r1,[r0]
  5234  01472H  09101H      str      r1,[sp,#4]
  5236  01474H  04810H      ldr      r0,[pc,#64] -> 5304
  5238  01476H  06800H      ldr      r0,[r0]
  5240  01478H  03004H      adds     r0,#4
  5242  0147AH  09901H      ldr      r1,[sp,#4]
  5244  0147CH  01840H      adds     r0,r0,r1
  5246  0147EH  09000H      str      r0,[sp]
  5248  01480H  09800H      ldr      r0,[sp]
  5250  01482H  09902H      ldr      r1,[sp,#8]
  5252  01484H  04288H      cmp      r0,r1
  5254  01486H  0DC01H      bgt.n    2 -> 5260
  5256  01488H  0E005H      b        10 -> 5270
  5258  0148AH  046C0H      nop
  5260  0148CH  02000H      movs     r0,#0
  5262  0148EH  09903H      ldr      r1,[sp,#12]
  5264  01490H  06008H      str      r0,[r1]
  5266  01492H  0E00CH      b        24 -> 5294
  5268  01494H  046C0H      nop
  5270  01496H  04808H      ldr      r0,[pc,#32] -> 5304
  5272  01498H  06800H      ldr      r0,[r0]
  5274  0149AH  03004H      adds     r0,#4
  5276  0149CH  09903H      ldr      r1,[sp,#12]
  5278  0149EH  06008H      str      r0,[r1]
  5280  014A0H  04805H      ldr      r0,[pc,#20] -> 5304
  5282  014A2H  06800H      ldr      r0,[r0]
  5284  014A4H  09904H      ldr      r1,[sp,#16]
  5286  014A6H  06001H      str      r1,[r0]
  5288  014A8H  09800H      ldr      r0,[sp]
  5290  014AAH  04903H      ldr      r1,[pc,#12] -> 5304
  5292  014ACH  06008H      str      r0,[r1]
  5294  014AEH  0B005H      add      sp,#20
  5296  014B0H  0BD00H      pop      { pc }
  5298  014B2H  046C0H      nop
  5300  014B4H  02002FFA8H
  5304  014B8H  02002FFACH

PROCEDURE MAU.Deallocate:
  5308  014BCH  0B503H      push     { r0, r1, lr }
  5310  014BEH  0B082H      sub      sp,#8
  5312  014C0H  09802H      ldr      r0,[sp,#8]
  5314  014C2H  06800H      ldr      r0,[r0]
  5316  014C4H  02800H      cmp      r0,#0
  5318  014C6H  0D101H      bne.n    2 -> 5324
  5320  014C8H  0DF0CH      svc      12
  5322  014CAH  00055H      <LineNo: 85>
  5324  014CCH  09803H      ldr      r0,[sp,#12]
  5326  014CEH  06801H      ldr      r1,[r0]
  5328  014D0H  09101H      str      r1,[sp,#4]
  5330  014D2H  0480AH      ldr      r0,[pc,#40] -> 5372
  5332  014D4H  06800H      ldr      r0,[r0]
  5334  014D6H  09901H      ldr      r1,[sp,#4]
  5336  014D8H  01A40H      subs     r0,r0,r1
  5338  014DAH  09000H      str      r0,[sp]
  5340  014DCH  09800H      ldr      r0,[sp]
  5342  014DEH  09902H      ldr      r1,[sp,#8]
  5344  014E0H  06809H      ldr      r1,[r1]
  5346  014E2H  04288H      cmp      r0,r1
  5348  014E4H  0D001H      beq.n    2 -> 5354
  5350  014E6H  0E004H      b        8 -> 5362
  5352  014E8H  046C0H      nop
  5354  014EAH  09800H      ldr      r0,[sp]
  5356  014ECH  03804H      subs     r0,#4
  5358  014EEH  04903H      ldr      r1,[pc,#12] -> 5372
  5360  014F0H  06008H      str      r0,[r1]
  5362  014F2H  02000H      movs     r0,#0
  5364  014F4H  09902H      ldr      r1,[sp,#8]
  5366  014F6H  06008H      str      r0,[r1]
  5368  014F8H  0B004H      add      sp,#16
  5370  014FAH  0BD00H      pop      { pc }
  5372  014FCH  02002FFACH

PROCEDURE MAU..init:
  5376  01500H  0B500H      push     { lr }
  5378  01502H  046C0H      nop
  5380  01504H  0480AH      ldr      r0,[pc,#40] -> 5424
  5382  01506H  04478H      add      r0,pc
  5384  01508H  0F7FFFF92H  bl.w     MAU.SetNew
  5388  0150CH  0E000H      b        0 -> 5392
  5390  0150EH  0005FH      <LineNo: 95>
  5392  01510H  04808H      ldr      r0,[pc,#32] -> 5428
  5394  01512H  04478H      add      r0,pc
  5396  01514H  0F7FFFF94H  bl.w     MAU.SetDispose
  5400  01518H  0E000H      b        0 -> 5404
  5402  0151AH  00060H      <LineNo: 96>
  5404  0151CH  04806H      ldr      r0,[pc,#24] -> 5432
  5406  0151EH  06800H      ldr      r0,[r0]
  5408  01520H  04907H      ldr      r1,[pc,#28] -> 5440
  5410  01522H  06008H      str      r0,[r1]
  5412  01524H  04805H      ldr      r0,[pc,#20] -> 5436
  5414  01526H  06800H      ldr      r0,[r0]
  5416  01528H  04906H      ldr      r1,[pc,#24] -> 5444
  5418  0152AH  06008H      str      r0,[r1]
  5420  0152CH  0BD00H      pop      { pc }
  5422  0152EH  046C0H      nop
  5424  01530H  -186
  5428  01534H  -90
  5432  01538H  02002FFF4H
  5436  0153CH  02002FFF0H
  5440  01540H  02002FFACH
  5444  01544H  02002FFA8H

MODULE Memory:
  5448  01548H  0
  5452  0154CH  8
  5456  01550H  0
  5460  01554H  0
  5464  01558H  0
  5468  0155CH  0
  5472  01560H  8
  5476  01564H  0
  5480  01568H  0
  5484  0156CH  0
  5488  01570H  0
  5492  01574H  148
  5496  01578H  0
  5500  0157CH  0
  5504  01580H  0
  5508  01584H  0
  5512  01588H  8
  5516  0158CH  0
  5520  01590H  0
  5524  01594H  0
  5528  01598H  0

PROCEDURE Memory.Allocate:
  5532  0159CH  0B503H      push     { r0, r1, lr }
  5534  0159EH  0B084H      sub      sp,#16
  5536  015A0H  04821H      ldr      r0,[pc,#132] -> 5672
  5538  015A2H  06801H      ldr      r1,[r0]
  5540  015A4H  09100H      str      r1,[sp]
  5542  015A6H  09800H      ldr      r0,[sp]
  5544  015A8H  04920H      ldr      r1,[pc,#128] -> 5676
  5546  015AAH  000C0H      lsls     r0,r0,#3
  5548  015ACH  01808H      adds     r0,r1,r0
  5550  015AEH  06800H      ldr      r0,[r0]
  5552  015B0H  09003H      str      r0,[sp,#12]
  5554  015B2H  09803H      ldr      r0,[sp,#12]
  5556  015B4H  02800H      cmp      r0,#0
  5558  015B6H  0D001H      beq.n    2 -> 5564
  5560  015B8H  0E008H      b        16 -> 5580
  5562  015BAH  046C0H      nop
  5564  015BCH  09800H      ldr      r0,[sp]
  5566  015BEH  0491CH      ldr      r1,[pc,#112] -> 5680
  5568  015C0H  02294H      movs     r2,#148
  5570  015C2H  04350H      muls     r0,r2
  5572  015C4H  01808H      adds     r0,r1,r0
  5574  015C6H  02188H      movs     r1,#136
  5576  015C8H  05840H      ldr      r0,[r0,r1]
  5578  015CAH  09003H      str      r0,[sp,#12]
  5580  015CCH  09805H      ldr      r0,[sp,#20]
  5582  015CEH  06801H      ldr      r1,[r0]
  5584  015D0H  09102H      str      r1,[sp,#8]
  5586  015D2H  09800H      ldr      r0,[sp]
  5588  015D4H  04915H      ldr      r1,[pc,#84] -> 5676
  5590  015D6H  000C0H      lsls     r0,r0,#3
  5592  015D8H  01808H      adds     r0,r1,r0
  5594  015DAH  06840H      ldr      r0,[r0,#4]
  5596  015DCH  03004H      adds     r0,#4
  5598  015DEH  09902H      ldr      r1,[sp,#8]
  5600  015E0H  01840H      adds     r0,r0,r1
  5602  015E2H  09001H      str      r0,[sp,#4]
  5604  015E4H  09801H      ldr      r0,[sp,#4]
  5606  015E6H  09903H      ldr      r1,[sp,#12]
  5608  015E8H  04288H      cmp      r0,r1
  5610  015EAH  0DC01H      bgt.n    2 -> 5616
  5612  015ECH  0E005H      b        10 -> 5626
  5614  015EEH  046C0H      nop
  5616  015F0H  02000H      movs     r0,#0
  5618  015F2H  09904H      ldr      r1,[sp,#16]
  5620  015F4H  06008H      str      r0,[r1]
  5622  015F6H  0E015H      b        42 -> 5668
  5624  015F8H  046C0H      nop
  5626  015FAH  09800H      ldr      r0,[sp]
  5628  015FCH  0490BH      ldr      r1,[pc,#44] -> 5676
  5630  015FEH  000C0H      lsls     r0,r0,#3
  5632  01600H  01808H      adds     r0,r1,r0
  5634  01602H  06840H      ldr      r0,[r0,#4]
  5636  01604H  03004H      adds     r0,#4
  5638  01606H  09904H      ldr      r1,[sp,#16]
  5640  01608H  06008H      str      r0,[r1]
  5642  0160AH  09800H      ldr      r0,[sp]
  5644  0160CH  04907H      ldr      r1,[pc,#28] -> 5676
  5646  0160EH  000C0H      lsls     r0,r0,#3
  5648  01610H  01808H      adds     r0,r1,r0
  5650  01612H  06840H      ldr      r0,[r0,#4]
  5652  01614H  09905H      ldr      r1,[sp,#20]
  5654  01616H  06001H      str      r1,[r0]
  5656  01618H  09800H      ldr      r0,[sp]
  5658  0161AH  04904H      ldr      r1,[pc,#16] -> 5676
  5660  0161CH  000C0H      lsls     r0,r0,#3
  5662  0161EH  01808H      adds     r0,r1,r0
  5664  01620H  09901H      ldr      r1,[sp,#4]
  5666  01622H  06041H      str      r1,[r0,#4]
  5668  01624H  0B006H      add      sp,#24
  5670  01626H  0BD00H      pop      { pc }
  5672  01628H  0D0000000H
  5676  0162CH  02002FF88H
  5680  01630H  02002FE60H

PROCEDURE Memory.Deallocate:
  5684  01634H  0B503H      push     { r0, r1, lr }
  5686  01636H  0B083H      sub      sp,#12
  5688  01638H  09803H      ldr      r0,[sp,#12]
  5690  0163AH  06800H      ldr      r0,[r0]
  5692  0163CH  02800H      cmp      r0,#0
  5694  0163EH  0D101H      bne.n    2 -> 5700
  5696  01640H  0DF0CH      svc      12
  5698  01642H  00055H      <LineNo: 85>
  5700  01644H  04814H      ldr      r0,[pc,#80] -> 5784
  5702  01646H  06801H      ldr      r1,[r0]
  5704  01648H  09100H      str      r1,[sp]
  5706  0164AH  09804H      ldr      r0,[sp,#16]
  5708  0164CH  06801H      ldr      r1,[r0]
  5710  0164EH  09102H      str      r1,[sp,#8]
  5712  01650H  09800H      ldr      r0,[sp]
  5714  01652H  02802H      cmp      r0,#2
  5716  01654H  0D301H      bcc.n    2 -> 5722
  5718  01656H  0DF01H      svc      1
  5720  01658H  00059H      <LineNo: 89>
  5722  0165AH  04910H      ldr      r1,[pc,#64] -> 5788
  5724  0165CH  000C0H      lsls     r0,r0,#3
  5726  0165EH  01808H      adds     r0,r1,r0
  5728  01660H  06840H      ldr      r0,[r0,#4]
  5730  01662H  09902H      ldr      r1,[sp,#8]
  5732  01664H  01A40H      subs     r0,r0,r1
  5734  01666H  09001H      str      r0,[sp,#4]
  5736  01668H  09801H      ldr      r0,[sp,#4]
  5738  0166AH  09903H      ldr      r1,[sp,#12]
  5740  0166CH  06809H      ldr      r1,[r1]
  5742  0166EH  04288H      cmp      r0,r1
  5744  01670H  0D001H      beq.n    2 -> 5750
  5746  01672H  0E00BH      b        22 -> 5772
  5748  01674H  046C0H      nop
  5750  01676H  09800H      ldr      r0,[sp]
  5752  01678H  02802H      cmp      r0,#2
  5754  0167AH  0D301H      bcc.n    2 -> 5760
  5756  0167CH  0DF01H      svc      1
  5758  0167EH  0005AH      <LineNo: 90>
  5760  01680H  04906H      ldr      r1,[pc,#24] -> 5788
  5762  01682H  000C0H      lsls     r0,r0,#3
  5764  01684H  01808H      adds     r0,r1,r0
  5766  01686H  09901H      ldr      r1,[sp,#4]
  5768  01688H  03904H      subs     r1,#4
  5770  0168AH  06041H      str      r1,[r0,#4]
  5772  0168CH  02000H      movs     r0,#0
  5774  0168EH  09903H      ldr      r1,[sp,#12]
  5776  01690H  06008H      str      r0,[r1]
  5778  01692H  0B005H      add      sp,#20
  5780  01694H  0BD00H      pop      { pc }
  5782  01696H  046C0H      nop
  5784  01698H  0D0000000H
  5788  0169CH  02002FF88H

PROCEDURE Memory.LockHeaps:
  5792  016A0H  0B500H      push     { lr }
  5794  016A2H  04804H      ldr      r0,[pc,#16] -> 5812
  5796  016A4H  04903H      ldr      r1,[pc,#12] -> 5812
  5798  016A6H  06849H      ldr      r1,[r1,#4]
  5800  016A8H  06001H      str      r1,[r0]
  5802  016AAH  04802H      ldr      r0,[pc,#8] -> 5812
  5804  016ACH  04901H      ldr      r1,[pc,#4] -> 5812
  5806  016AEH  068C9H      ldr      r1,[r1,#12]
  5808  016B0H  06081H      str      r1,[r0,#8]
  5810  016B2H  0BD00H      pop      { pc }
  5812  016B4H  02002FF88H

PROCEDURE Memory.initStackCheck:
  5816  016B8H  0B503H      push     { r0, r1, lr }
  5818  016BAH  09800H      ldr      r0,[sp]
  5820  016BCH  09901H      ldr      r1,[sp,#4]
  5822  016BEH  04288H      cmp      r0,r1
  5824  016C0H  0DB01H      blt.n    2 -> 5830
  5826  016C2H  0E008H      b        16 -> 5846
  5828  016C4H  046C0H      nop
  5830  016C6H  09800H      ldr      r0,[sp]
  5832  016C8H  03003H      adds     r0,#3
  5834  016CAH  09900H      ldr      r1,[sp]
  5836  016CCH  06008H      str      r0,[r1]
  5838  016CEH  09800H      ldr      r0,[sp]
  5840  016D0H  03004H      adds     r0,#4
  5842  016D2H  09000H      str      r0,[sp]
  5844  016D4H  0E7F1H      b        -30 -> 5818
  5846  016D6H  0B002H      add      sp,#8
  5848  016D8H  0BD00H      pop      { pc }
  5850  016DAH  046C0H      nop

PROCEDURE Memory.checkStackUsage:
  5852  016DCH  0B507H      push     { r0, r1, r2, lr }
  5854  016DEH  0B081H      sub      sp,#4
  5856  016E0H  09801H      ldr      r0,[sp,#4]
  5858  016E2H  06801H      ldr      r1,[r0]
  5860  016E4H  09100H      str      r1,[sp]
  5862  016E6H  02000H      movs     r0,#0
  5864  016E8H  09903H      ldr      r1,[sp,#12]
  5866  016EAH  06008H      str      r0,[r1]
  5868  016ECH  09801H      ldr      r0,[sp,#4]
  5870  016EEH  03003H      adds     r0,#3
  5872  016F0H  09900H      ldr      r1,[sp]
  5874  016F2H  04281H      cmp      r1,r0
  5876  016F4H  0D001H      beq.n    2 -> 5882
  5878  016F6H  0E011H      b        34 -> 5916
  5880  016F8H  046C0H      nop
  5882  016FAH  09801H      ldr      r0,[sp,#4]
  5884  016FCH  09902H      ldr      r1,[sp,#8]
  5886  016FEH  04288H      cmp      r0,r1
  5888  01700H  0DB01H      blt.n    2 -> 5894
  5890  01702H  0E00BH      b        22 -> 5916
  5892  01704H  046C0H      nop
  5894  01706H  09801H      ldr      r0,[sp,#4]
  5896  01708H  03004H      adds     r0,#4
  5898  0170AH  09001H      str      r0,[sp,#4]
  5900  0170CH  09803H      ldr      r0,[sp,#12]
  5902  0170EH  06801H      ldr      r1,[r0]
  5904  01710H  03104H      adds     r1,#4
  5906  01712H  06001H      str      r1,[r0]
  5908  01714H  09801H      ldr      r0,[sp,#4]
  5910  01716H  06801H      ldr      r1,[r0]
  5912  01718H  09100H      str      r1,[sp]
  5914  0171AH  0E7E7H      b        -50 -> 5868
  5916  0171CH  0B004H      add      sp,#16
  5918  0171EH  0BD00H      pop      { pc }

PROCEDURE Memory.CheckLoopStackUsage:
  5920  01720H  0B503H      push     { r0, r1, lr }
  5922  01722H  0B084H      sub      sp,#16
  5924  01724H  04817H      ldr      r0,[pc,#92] -> 6020
  5926  01726H  06801H      ldr      r1,[r0]
  5928  01728H  09100H      str      r1,[sp]
  5930  0172AH  09800H      ldr      r0,[sp]
  5932  0172CH  02802H      cmp      r0,#2
  5934  0172EH  0D301H      bcc.n    2 -> 5940
  5936  01730H  0DF01H      svc      1
  5938  01732H  00081H      <LineNo: 129>
  5940  01734H  04914H      ldr      r1,[pc,#80] -> 6024
  5942  01736H  02294H      movs     r2,#148
  5944  01738H  04350H      muls     r0,r2
  5946  0173AH  01808H      adds     r0,r1,r0
  5948  0173CH  02180H      movs     r1,#128
  5950  0173EH  05840H      ldr      r0,[r0,r1]
  5952  01740H  09001H      str      r0,[sp,#4]
  5954  01742H  09800H      ldr      r0,[sp]
  5956  01744H  02802H      cmp      r0,#2
  5958  01746H  0D301H      bcc.n    2 -> 5964
  5960  01748H  0DF01H      svc      1
  5962  0174AH  00082H      <LineNo: 130>
  5964  0174CH  0490EH      ldr      r1,[pc,#56] -> 6024
  5966  0174EH  02294H      movs     r2,#148
  5968  01750H  04350H      muls     r0,r2
  5970  01752H  01808H      adds     r0,r1,r0
  5972  01754H  02184H      movs     r1,#132
  5974  01756H  05840H      ldr      r0,[r0,r1]
  5976  01758H  09904H      ldr      r1,[sp,#16]
  5978  0175AH  06008H      str      r0,[r1]
  5980  0175CH  09801H      ldr      r0,[sp,#4]
  5982  0175EH  09904H      ldr      r1,[sp,#16]
  5984  01760H  06809H      ldr      r1,[r1]
  5986  01762H  01840H      adds     r0,r0,r1
  5988  01764H  09002H      str      r0,[sp,#8]
  5990  01766H  09801H      ldr      r0,[sp,#4]
  5992  01768H  09902H      ldr      r1,[sp,#8]
  5994  0176AH  0AA03H      add      r2,sp,#12
  5996  0176CH  0F7FFFFB6H  bl.w     Memory.checkStackUsage
  6000  01770H  0E000H      b        0 -> 6004
  6002  01772H  00084H      <LineNo: 132>
  6004  01774H  09804H      ldr      r0,[sp,#16]
  6006  01776H  06800H      ldr      r0,[r0]
  6008  01778H  09903H      ldr      r1,[sp,#12]
  6010  0177AH  01A40H      subs     r0,r0,r1
  6012  0177CH  09905H      ldr      r1,[sp,#20]
  6014  0177EH  06008H      str      r0,[r1]
  6016  01780H  0B006H      add      sp,#24
  6018  01782H  0BD00H      pop      { pc }
  6020  01784H  0D0000000H
  6024  01788H  02002FE60H

PROCEDURE Memory.CheckThreadStackUsage:
  6028  0178CH  0B507H      push     { r0, r1, r2, lr }
  6030  0178EH  0B084H      sub      sp,#16
  6032  01790H  0481DH      ldr      r0,[pc,#116] -> 6152
  6034  01792H  06801H      ldr      r1,[r0]
  6036  01794H  09100H      str      r1,[sp]
  6038  01796H  09800H      ldr      r0,[sp]
  6040  01798H  02802H      cmp      r0,#2
  6042  0179AH  0D301H      bcc.n    2 -> 6048
  6044  0179CH  0DF01H      svc      1
  6046  0179EH  0008DH      <LineNo: 141>
  6048  017A0H  0491AH      ldr      r1,[pc,#104] -> 6156
  6050  017A2H  02294H      movs     r2,#148
  6052  017A4H  04350H      muls     r0,r2
  6054  017A6H  01808H      adds     r0,r1,r0
  6056  017A8H  09904H      ldr      r1,[sp,#16]
  6058  017AAH  02910H      cmp      r1,#16
  6060  017ACH  0D301H      bcc.n    2 -> 6066
  6062  017AEH  0DF01H      svc      1
  6064  017B0H  0008DH      <LineNo: 141>
  6066  017B2H  000C9H      lsls     r1,r1,#3
  6068  017B4H  01840H      adds     r0,r0,r1
  6070  017B6H  06800H      ldr      r0,[r0]
  6072  017B8H  09001H      str      r0,[sp,#4]
  6074  017BAH  09800H      ldr      r0,[sp]
  6076  017BCH  02802H      cmp      r0,#2
  6078  017BEH  0D301H      bcc.n    2 -> 6084
  6080  017C0H  0DF01H      svc      1
  6082  017C2H  0008EH      <LineNo: 142>
  6084  017C4H  04911H      ldr      r1,[pc,#68] -> 6156
  6086  017C6H  02294H      movs     r2,#148
  6088  017C8H  04350H      muls     r0,r2
  6090  017CAH  01808H      adds     r0,r1,r0
  6092  017CCH  09904H      ldr      r1,[sp,#16]
  6094  017CEH  02910H      cmp      r1,#16
  6096  017D0H  0D301H      bcc.n    2 -> 6102
  6098  017D2H  0DF01H      svc      1
  6100  017D4H  0008EH      <LineNo: 142>
  6102  017D6H  000C9H      lsls     r1,r1,#3
  6104  017D8H  01840H      adds     r0,r0,r1
  6106  017DAH  06840H      ldr      r0,[r0,#4]
  6108  017DCH  09905H      ldr      r1,[sp,#20]
  6110  017DEH  06008H      str      r0,[r1]
  6112  017E0H  09801H      ldr      r0,[sp,#4]
  6114  017E2H  09905H      ldr      r1,[sp,#20]
  6116  017E4H  06809H      ldr      r1,[r1]
  6118  017E6H  01840H      adds     r0,r0,r1
  6120  017E8H  09002H      str      r0,[sp,#8]
  6122  017EAH  09801H      ldr      r0,[sp,#4]
  6124  017ECH  09902H      ldr      r1,[sp,#8]
  6126  017EEH  0AA03H      add      r2,sp,#12
  6128  017F0H  0F7FFFF74H  bl.w     Memory.checkStackUsage
  6132  017F4H  0E000H      b        0 -> 6136
  6134  017F6H  00090H      <LineNo: 144>
  6136  017F8H  09805H      ldr      r0,[sp,#20]
  6138  017FAH  06800H      ldr      r0,[r0]
  6140  017FCH  09903H      ldr      r1,[sp,#12]
  6142  017FEH  01A40H      subs     r0,r0,r1
  6144  01800H  09906H      ldr      r1,[sp,#24]
  6146  01802H  06008H      str      r0,[r1]
  6148  01804H  0B007H      add      sp,#28
  6150  01806H  0BD00H      pop      { pc }
  6152  01808H  0D0000000H
  6156  0180CH  02002FE60H

PROCEDURE Memory.allocStack:
  6160  01810H  0B507H      push     { r0, r1, r2, lr }
  6162  01812H  0B081H      sub      sp,#4
  6164  01814H  09802H      ldr      r0,[sp,#8]
  6166  01816H  02802H      cmp      r0,#2
  6168  01818H  0D301H      bcc.n    2 -> 6174
  6170  0181AH  0DF01H      svc      1
  6172  0181CH  00098H      <LineNo: 152>
  6174  0181EH  04924H      ldr      r1,[pc,#144] -> 6320
  6176  01820H  000C0H      lsls     r0,r0,#3
  6178  01822H  01808H      adds     r0,r1,r0
  6180  01824H  06800H      ldr      r0,[r0]
  6182  01826H  09000H      str      r0,[sp]
  6184  01828H  09800H      ldr      r0,[sp]
  6186  0182AH  02800H      cmp      r0,#0
  6188  0182CH  0D001H      beq.n    2 -> 6194
  6190  0182EH  0E00AH      b        20 -> 6214
  6192  01830H  046C0H      nop
  6194  01832H  09802H      ldr      r0,[sp,#8]
  6196  01834H  02802H      cmp      r0,#2
  6198  01836H  0D301H      bcc.n    2 -> 6204
  6200  01838H  0DF01H      svc      1
  6202  0183AH  0009AH      <LineNo: 154>
  6204  0183CH  0491CH      ldr      r1,[pc,#112] -> 6320
  6206  0183EH  000C0H      lsls     r0,r0,#3
  6208  01840H  01808H      adds     r0,r1,r0
  6210  01842H  06840H      ldr      r0,[r0,#4]
  6212  01844H  09000H      str      r0,[sp]
  6214  01846H  09802H      ldr      r0,[sp,#8]
  6216  01848H  02802H      cmp      r0,#2
  6218  0184AH  0D301H      bcc.n    2 -> 6224
  6220  0184CH  0DF01H      svc      1
  6222  0184EH  0009CH      <LineNo: 156>
  6224  01850H  04918H      ldr      r1,[pc,#96] -> 6324
  6226  01852H  02294H      movs     r2,#148
  6228  01854H  04350H      muls     r0,r2
  6230  01856H  01808H      adds     r0,r1,r0
  6232  01858H  02188H      movs     r1,#136
  6234  0185AH  05840H      ldr      r0,[r0,r1]
  6236  0185CH  09903H      ldr      r1,[sp,#12]
  6238  0185EH  01A40H      subs     r0,r0,r1
  6240  01860H  09900H      ldr      r1,[sp]
  6242  01862H  04288H      cmp      r0,r1
  6244  01864H  0DC01H      bgt.n    2 -> 6250
  6246  01866H  0E01DH      b        58 -> 6308
  6248  01868H  046C0H      nop
  6250  0186AH  09802H      ldr      r0,[sp,#8]
  6252  0186CH  02802H      cmp      r0,#2
  6254  0186EH  0D301H      bcc.n    2 -> 6260
  6256  01870H  0DF01H      svc      1
  6258  01872H  0009DH      <LineNo: 157>
  6260  01874H  0490FH      ldr      r1,[pc,#60] -> 6324
  6262  01876H  02294H      movs     r2,#148
  6264  01878H  04350H      muls     r0,r2
  6266  0187AH  01808H      adds     r0,r1,r0
  6268  0187CH  09903H      ldr      r1,[sp,#12]
  6270  0187EH  03088H      adds     r0,#136
  6272  01880H  06802H      ldr      r2,[r0]
  6274  01882H  01A52H      subs     r2,r2,r1
  6276  01884H  06002H      str      r2,[r0]
  6278  01886H  09802H      ldr      r0,[sp,#8]
  6280  01888H  02802H      cmp      r0,#2
  6282  0188AH  0D301H      bcc.n    2 -> 6288
  6284  0188CH  0DF01H      svc      1
  6286  0188EH  0009EH      <LineNo: 158>
  6288  01890H  04908H      ldr      r1,[pc,#32] -> 6324
  6290  01892H  02294H      movs     r2,#148
  6292  01894H  04350H      muls     r0,r2
  6294  01896H  01808H      adds     r0,r1,r0
  6296  01898H  02188H      movs     r1,#136
  6298  0189AH  05840H      ldr      r0,[r0,r1]
  6300  0189CH  09901H      ldr      r1,[sp,#4]
  6302  0189EH  06008H      str      r0,[r1]
  6304  018A0H  0E003H      b        6 -> 6314
  6306  018A2H  046C0H      nop
  6308  018A4H  02000H      movs     r0,#0
  6310  018A6H  09901H      ldr      r1,[sp,#4]
  6312  018A8H  06008H      str      r0,[r1]
  6314  018AAH  0B004H      add      sp,#16
  6316  018ACH  0BD00H      pop      { pc }
  6318  018AEH  046C0H      nop
  6320  018B0H  02002FF88H
  6324  018B4H  02002FE60H

PROCEDURE Memory.AllocThreadStack:
  6328  018B8H  0B507H      push     { r0, r1, r2, lr }
  6330  018BAH  0B081H      sub      sp,#4
  6332  018BCH  04828H      ldr      r0,[pc,#160] -> 6496
  6334  018BEH  06801H      ldr      r1,[r0]
  6336  018C0H  09100H      str      r1,[sp]
  6338  018C2H  09801H      ldr      r0,[sp,#4]
  6340  018C4H  09900H      ldr      r1,[sp]
  6342  018C6H  09A03H      ldr      r2,[sp,#12]
  6344  018C8H  0F7FFFFA2H  bl.w     Memory.allocStack
  6348  018CCH  0E000H      b        0 -> 6352
  6350  018CEH  000A9H      <LineNo: 169>
  6352  018D0H  09801H      ldr      r0,[sp,#4]
  6354  018D2H  06800H      ldr      r0,[r0]
  6356  018D4H  02800H      cmp      r0,#0
  6358  018D6H  0D101H      bne.n    2 -> 6364
  6360  018D8H  0E03FH      b        126 -> 6490
  6362  018DAH  046C0H      nop
  6364  018DCH  09800H      ldr      r0,[sp]
  6366  018DEH  02802H      cmp      r0,#2
  6368  018E0H  0D301H      bcc.n    2 -> 6374
  6370  018E2H  0DF01H      svc      1
  6372  018E4H  000ABH      <LineNo: 171>
  6374  018E6H  0491FH      ldr      r1,[pc,#124] -> 6500
  6376  018E8H  02294H      movs     r2,#148
  6378  018EAH  04350H      muls     r0,r2
  6380  018ECH  01808H      adds     r0,r1,r0
  6382  018EEH  09902H      ldr      r1,[sp,#8]
  6384  018F0H  02910H      cmp      r1,#16
  6386  018F2H  0D301H      bcc.n    2 -> 6392
  6388  018F4H  0DF01H      svc      1
  6390  018F6H  000ABH      <LineNo: 171>
  6392  018F8H  000C9H      lsls     r1,r1,#3
  6394  018FAH  01840H      adds     r0,r0,r1
  6396  018FCH  09901H      ldr      r1,[sp,#4]
  6398  018FEH  06809H      ldr      r1,[r1]
  6400  01900H  06001H      str      r1,[r0]
  6402  01902H  09800H      ldr      r0,[sp]
  6404  01904H  02802H      cmp      r0,#2
  6406  01906H  0D301H      bcc.n    2 -> 6412
  6408  01908H  0DF01H      svc      1
  6410  0190AH  000ACH      <LineNo: 172>
  6412  0190CH  04915H      ldr      r1,[pc,#84] -> 6500
  6414  0190EH  02294H      movs     r2,#148
  6416  01910H  04350H      muls     r0,r2
  6418  01912H  01808H      adds     r0,r1,r0
  6420  01914H  09902H      ldr      r1,[sp,#8]
  6422  01916H  02910H      cmp      r1,#16
  6424  01918H  0D301H      bcc.n    2 -> 6430
  6426  0191AH  0DF01H      svc      1
  6428  0191CH  000ACH      <LineNo: 172>
  6430  0191EH  000C9H      lsls     r1,r1,#3
  6432  01920H  01840H      adds     r0,r0,r1
  6434  01922H  09903H      ldr      r1,[sp,#12]
  6436  01924H  06041H      str      r1,[r0,#4]
  6438  01926H  09800H      ldr      r0,[sp]
  6440  01928H  02802H      cmp      r0,#2
  6442  0192AH  0D301H      bcc.n    2 -> 6448
  6444  0192CH  0DF01H      svc      1
  6446  0192EH  000ADH      <LineNo: 173>
  6448  01930H  0490CH      ldr      r1,[pc,#48] -> 6500
  6450  01932H  02294H      movs     r2,#148
  6452  01934H  04350H      muls     r0,r2
  6454  01936H  01808H      adds     r0,r1,r0
  6456  01938H  02190H      movs     r1,#144
  6458  0193AH  05C40H      ldrb     r0,[r0,r1]
  6460  0193CH  02101H      movs     r1,#1
  6462  0193EH  04208H      tst      r0,r1
  6464  01940H  0D101H      bne.n    2 -> 6470
  6466  01942H  0E00AH      b        20 -> 6490
  6468  01944H  046C0H      nop
  6470  01946H  09801H      ldr      r0,[sp,#4]
  6472  01948H  06800H      ldr      r0,[r0]
  6474  0194AH  09901H      ldr      r1,[sp,#4]
  6476  0194CH  06809H      ldr      r1,[r1]
  6478  0194EH  09A03H      ldr      r2,[sp,#12]
  6480  01950H  01889H      adds     r1,r1,r2
  6482  01952H  0F7FFFEB1H  bl.w     Memory.initStackCheck
  6486  01956H  0E000H      b        0 -> 6490
  6488  01958H  000AEH      <LineNo: 174>
  6490  0195AH  0B004H      add      sp,#16
  6492  0195CH  0BD00H      pop      { pc }
  6494  0195EH  046C0H      nop
  6496  01960H  0D0000000H
  6500  01964H  02002FE60H

PROCEDURE Memory.AllocLoopStack:
  6504  01968H  0B503H      push     { r0, r1, lr }
  6506  0196AH  0B081H      sub      sp,#4
  6508  0196CH  04822H      ldr      r0,[pc,#136] -> 6648
  6510  0196EH  06801H      ldr      r1,[r0]
  6512  01970H  09100H      str      r1,[sp]
  6514  01972H  09801H      ldr      r0,[sp,#4]
  6516  01974H  09900H      ldr      r1,[sp]
  6518  01976H  09A02H      ldr      r2,[sp,#8]
  6520  01978H  0F7FFFF4AH  bl.w     Memory.allocStack
  6524  0197CH  0E000H      b        0 -> 6528
  6526  0197EH  000B8H      <LineNo: 184>
  6528  01980H  09801H      ldr      r0,[sp,#4]
  6530  01982H  06800H      ldr      r0,[r0]
  6532  01984H  02800H      cmp      r0,#0
  6534  01986H  0D101H      bne.n    2 -> 6540
  6536  01988H  0E033H      b        102 -> 6642
  6538  0198AH  046C0H      nop
  6540  0198CH  09800H      ldr      r0,[sp]
  6542  0198EH  02802H      cmp      r0,#2
  6544  01990H  0D301H      bcc.n    2 -> 6550
  6546  01992H  0DF01H      svc      1
  6548  01994H  000BAH      <LineNo: 186>
  6550  01996H  04919H      ldr      r1,[pc,#100] -> 6652
  6552  01998H  02294H      movs     r2,#148
  6554  0199AH  04350H      muls     r0,r2
  6556  0199CH  01808H      adds     r0,r1,r0
  6558  0199EH  09901H      ldr      r1,[sp,#4]
  6560  019A0H  06809H      ldr      r1,[r1]
  6562  019A2H  02280H      movs     r2,#128
  6564  019A4H  05081H      str      r1,[r0,r2]
  6566  019A6H  09800H      ldr      r0,[sp]
  6568  019A8H  02802H      cmp      r0,#2
  6570  019AAH  0D301H      bcc.n    2 -> 6576
  6572  019ACH  0DF01H      svc      1
  6574  019AEH  000BBH      <LineNo: 187>
  6576  019B0H  04912H      ldr      r1,[pc,#72] -> 6652
  6578  019B2H  02294H      movs     r2,#148
  6580  019B4H  04350H      muls     r0,r2
  6582  019B6H  01808H      adds     r0,r1,r0
  6584  019B8H  09902H      ldr      r1,[sp,#8]
  6586  019BAH  02284H      movs     r2,#132
  6588  019BCH  05081H      str      r1,[r0,r2]
  6590  019BEH  09800H      ldr      r0,[sp]
  6592  019C0H  02802H      cmp      r0,#2
  6594  019C2H  0D301H      bcc.n    2 -> 6600
  6596  019C4H  0DF01H      svc      1
  6598  019C6H  000BCH      <LineNo: 188>
  6600  019C8H  0490CH      ldr      r1,[pc,#48] -> 6652
  6602  019CAH  02294H      movs     r2,#148
  6604  019CCH  04350H      muls     r0,r2
  6606  019CEH  01808H      adds     r0,r1,r0
  6608  019D0H  02190H      movs     r1,#144
  6610  019D2H  05C40H      ldrb     r0,[r0,r1]
  6612  019D4H  02101H      movs     r1,#1
  6614  019D6H  04208H      tst      r0,r1
  6616  019D8H  0D101H      bne.n    2 -> 6622
  6618  019DAH  0E00AH      b        20 -> 6642
  6620  019DCH  046C0H      nop
  6622  019DEH  09801H      ldr      r0,[sp,#4]
  6624  019E0H  06800H      ldr      r0,[r0]
  6626  019E2H  09901H      ldr      r1,[sp,#4]
  6628  019E4H  06809H      ldr      r1,[r1]
  6630  019E6H  09A02H      ldr      r2,[sp,#8]
  6632  019E8H  01889H      adds     r1,r1,r2
  6634  019EAH  0F7FFFE65H  bl.w     Memory.initStackCheck
  6638  019EEH  0E000H      b        0 -> 6642
  6640  019F0H  000BDH      <LineNo: 189>
  6642  019F2H  0B003H      add      sp,#12
  6644  019F4H  0BD00H      pop      { pc }
  6646  019F6H  046C0H      nop
  6648  019F8H  0D0000000H
  6652  019FCH  02002FE60H

PROCEDURE Memory.EnableStackCheck:
  6656  01A00H  0B501H      push     { r0, lr }
  6658  01A02H  0B081H      sub      sp,#4
  6660  01A04H  04808H      ldr      r0,[pc,#32] -> 6696
  6662  01A06H  06801H      ldr      r1,[r0]
  6664  01A08H  09100H      str      r1,[sp]
  6666  01A0AH  09800H      ldr      r0,[sp]
  6668  01A0CH  02802H      cmp      r0,#2
  6670  01A0EH  0D301H      bcc.n    2 -> 6676
  6672  01A10H  0DF01H      svc      1
  6674  01A12H  000C7H      <LineNo: 199>
  6676  01A14H  04905H      ldr      r1,[pc,#20] -> 6700
  6678  01A16H  02294H      movs     r2,#148
  6680  01A18H  04350H      muls     r0,r2
  6682  01A1AH  01808H      adds     r0,r1,r0
  6684  01A1CH  0A901H      add      r1,sp,#4
  6686  01A1EH  07809H      ldrb     r1,[r1]
  6688  01A20H  02290H      movs     r2,#144
  6690  01A22H  05481H      strb     r1,[r0,r2]
  6692  01A24H  0B002H      add      sp,#8
  6694  01A26H  0BD00H      pop      { pc }
  6696  01A28H  0D0000000H
  6700  01A2CH  02002FE60H

PROCEDURE Memory.ResetMainStack:
  6704  01A30H  0B503H      push     { r0, r1, lr }
  6706  01A32H  0B082H      sub      sp,#8
  6708  01A34H  09802H      ldr      r0,[sp,#8]
  6710  01A36H  02802H      cmp      r0,#2
  6712  01A38H  0D301H      bcc.n    2 -> 6718
  6714  01A3AH  0DF01H      svc      1
  6716  01A3CH  000D0H      <LineNo: 208>
  6718  01A3EH  0490DH      ldr      r1,[pc,#52] -> 6772
  6720  01A40H  000C0H      lsls     r0,r0,#3
  6722  01A42H  01808H      adds     r0,r1,r0
  6724  01A44H  06800H      ldr      r0,[r0]
  6726  01A46H  03804H      subs     r0,#4
  6728  01A48H  09001H      str      r0,[sp,#4]
  6730  01A4AH  02000H      movs     r0,#0
  6732  01A4CH  09000H      str      r0,[sp]
  6734  01A4EH  09800H      ldr      r0,[sp]
  6736  01A50H  09903H      ldr      r1,[sp,#12]
  6738  01A52H  04288H      cmp      r0,r1
  6740  01A54H  0DB01H      blt.n    2 -> 6746
  6742  01A56H  0E00AH      b        20 -> 6766
  6744  01A58H  046C0H      nop
  6746  01A5AH  09801H      ldr      r0,[sp,#4]
  6748  01A5CH  02100H      movs     r1,#0
  6750  01A5EH  06001H      str      r1,[r0]
  6752  01A60H  09800H      ldr      r0,[sp]
  6754  01A62H  03001H      adds     r0,#1
  6756  01A64H  09000H      str      r0,[sp]
  6758  01A66H  09801H      ldr      r0,[sp,#4]
  6760  01A68H  03804H      subs     r0,#4
  6762  01A6AH  09001H      str      r0,[sp,#4]
  6764  01A6CH  0E7EFH      b        -34 -> 6734
  6766  01A6EH  0B004H      add      sp,#16
  6768  01A70H  0BD00H      pop      { pc }
  6770  01A72H  046C0H      nop
  6772  01A74H  02002FF98H

PROCEDURE Memory.init:
  6776  01A78H  0B500H      push     { lr }
  6778  01A7AH  046C0H      nop
  6780  01A7CH  04829H      ldr      r0,[pc,#164] -> 6948
  6782  01A7EH  04478H      add      r0,pc
  6784  01A80H  0F7FFFCD6H  bl.w     MAU.SetNew
  6788  01A84H  0E000H      b        0 -> 6792
  6790  01A86H  000DDH      <LineNo: 221>
  6792  01A88H  04827H      ldr      r0,[pc,#156] -> 6952
  6794  01A8AH  04478H      add      r0,pc
  6796  01A8CH  0F7FFFCD8H  bl.w     MAU.SetDispose
  6800  01A90H  0E000H      b        0 -> 6804
  6802  01A92H  000DDH      <LineNo: 221>
  6804  01A94H  0482DH      ldr      r0,[pc,#180] -> 6988
  6806  01A96H  04929H      ldr      r1,[pc,#164] -> 6972
  6808  01A98H  06809H      ldr      r1,[r1]
  6810  01A9AH  06001H      str      r1,[r0]
  6812  01A9CH  0482BH      ldr      r0,[pc,#172] -> 6988
  6814  01A9EH  04928H      ldr      r1,[pc,#160] -> 6976
  6816  01AA0H  06809H      ldr      r1,[r1]
  6818  01AA2H  06041H      str      r1,[r0,#4]
  6820  01AA4H  04829H      ldr      r0,[pc,#164] -> 6988
  6822  01AA6H  04921H      ldr      r1,[pc,#132] -> 6956
  6824  01AA8H  06081H      str      r1,[r0,#8]
  6826  01AAAH  04828H      ldr      r0,[pc,#160] -> 6988
  6828  01AACH  04920H      ldr      r1,[pc,#128] -> 6960
  6830  01AAEH  060C1H      str      r1,[r0,#12]
  6832  01AB0H  04827H      ldr      r0,[pc,#156] -> 6992
  6834  01AB2H  04924H      ldr      r1,[pc,#144] -> 6980
  6836  01AB4H  06809H      ldr      r1,[r1]
  6838  01AB6H  06041H      str      r1,[r0,#4]
  6840  01AB8H  04825H      ldr      r0,[pc,#148] -> 6992
  6842  01ABAH  04923H      ldr      r1,[pc,#140] -> 6984
  6844  01ABCH  06809H      ldr      r1,[r1]
  6846  01ABEH  06001H      str      r1,[r0]
  6848  01AC0H  04823H      ldr      r0,[pc,#140] -> 6992
  6850  01AC2H  0491CH      ldr      r1,[pc,#112] -> 6964
  6852  01AC4H  060C1H      str      r1,[r0,#12]
  6854  01AC6H  04822H      ldr      r0,[pc,#136] -> 6992
  6856  01AC8H  02100H      movs     r1,#0
  6858  01ACAH  06081H      str      r1,[r0,#8]
  6860  01ACCH  04821H      ldr      r0,[pc,#132] -> 6996
  6862  01ACEH  0491BH      ldr      r1,[pc,#108] -> 6972
  6864  01AD0H  06809H      ldr      r1,[r1]
  6866  01AD2H  02201H      movs     r2,#1
  6868  01AD4H  00292H      lsls     r2,r2,#10
  6870  01AD6H  01A89H      subs     r1,r1,r2
  6872  01AD8H  02288H      movs     r2,#136
  6874  01ADAH  05081H      str      r1,[r0,r2]
  6876  01ADCH  0481DH      ldr      r0,[pc,#116] -> 6996
  6878  01ADEH  04917H      ldr      r1,[pc,#92] -> 6972
  6880  01AE0H  06809H      ldr      r1,[r1]
  6882  01AE2H  0228CH      movs     r2,#140
  6884  01AE4H  05081H      str      r1,[r0,r2]
  6886  01AE6H  0481BH      ldr      r0,[pc,#108] -> 6996
  6888  01AE8H  02100H      movs     r1,#0
  6890  01AEAH  02290H      movs     r2,#144
  6892  01AECH  05481H      strb     r1,[r0,r2]
  6894  01AEEH  04819H      ldr      r0,[pc,#100] -> 6996
  6896  01AF0H  04911H      ldr      r1,[pc,#68] -> 6968
  6898  01AF2H  02247H      movs     r2,#71
  6900  01AF4H  00092H      lsls     r2,r2,#2
  6902  01AF6H  05081H      str      r1,[r0,r2]
  6904  01AF8H  04816H      ldr      r0,[pc,#88] -> 6996
  6906  01AFAH  0490CH      ldr      r1,[pc,#48] -> 6956
  6908  01AFCH  02209H      movs     r2,#9
  6910  01AFEH  00152H      lsls     r2,r2,#5
  6912  01B00H  05081H      str      r1,[r0,r2]
  6914  01B02H  04814H      ldr      r0,[pc,#80] -> 6996
  6916  01B04H  02100H      movs     r1,#0
  6918  01B06H  02249H      movs     r2,#73
  6920  01B08H  00092H      lsls     r2,r2,#2
  6922  01B0AH  05481H      strb     r1,[r0,r2]
  6924  01B0CH  0480FH      ldr      r0,[pc,#60] -> 6988
  6926  01B0EH  0490FH      ldr      r1,[pc,#60] -> 6988
  6928  01B10H  06800H      ldr      r0,[r0]
  6930  01B12H  06809H      ldr      r1,[r1]
  6932  01B14H  06001H      str      r1,[r0]
  6934  01B16H  0480DH      ldr      r0,[pc,#52] -> 6988
  6936  01B18H  0490CH      ldr      r1,[pc,#48] -> 6988
  6938  01B1AH  06880H      ldr      r0,[r0,#8]
  6940  01B1CH  06889H      ldr      r1,[r1,#8]
  6942  01B1EH  06001H      str      r1,[r0]
  6944  01B20H  0BD00H      pop      { pc }
  6946  01B22H  046C0H      nop
  6948  01B24H  -1254
  6952  01B28H  -1114
  6956  01B2CH  02003FFFCH
  6960  01B30H  020030000H
  6964  01B34H  020030200H
  6968  01B38H  02003FBFCH
  6972  01B3CH  02002FFCCH
  6976  01B40H  02002FFD0H
  6980  01B44H  02002FFC8H
  6984  01B48H  02002FFC4H
  6988  01B4CH  02002FF98H
  6992  01B50H  02002FF88H
  6996  01B54H  02002FE60H

PROCEDURE Memory..init:
  7000  01B58H  0B500H      push     { lr }
  7002  01B5AH  0F7FFFF8DH  bl.w     Memory.init
  7006  01B5EH  0E000H      b        0 -> 7010
  7008  01B60H  000F9H      <LineNo: 249>
  7010  01B62H  0BD00H      pop      { pc }

MODULE LED:
  7012  01B64H  0

PROCEDURE LED.init:
  7016  01B68H  0B500H      push     { lr }
  7018  01B6AH  02019H      movs     r0,#25
  7020  01B6CH  02105H      movs     r1,#5
  7022  01B6EH  0F7FFF969H  bl.w     GPIO.SetFunction
  7026  01B72H  0E000H      b        0 -> 7030
  7028  01B74H  00023H      <LineNo: 35>
  7030  01B76H  02001H      movs     r0,#1
  7032  01B78H  00640H      lsls     r0,r0,#25
  7034  01B7AH  0F7FFFA8DH  bl.w     GPIO.OutputEnable
  7038  01B7EH  0E000H      b        0 -> 7042
  7040  01B80H  00024H      <LineNo: 36>
  7042  01B82H  0BD00H      pop      { pc }

PROCEDURE LED..init:
  7044  01B84H  0B500H      push     { lr }
  7046  01B86H  0F7FFFFEFH  bl.w     LED.init
  7050  01B8AH  0E000H      b        0 -> 7054
  7052  01B8CH  00028H      <LineNo: 40>
  7054  01B8EH  0BD00H      pop      { pc }

MODULE RuntimeErrors:
  7056  01B90H  0
  7060  01B94H  8
  7064  01B98H  0
  7068  01B9CH  0
  7072  01BA0H  0
  7076  01BA4H  0
  7080  01BA8H  68
  7084  01BACH  0
  7088  01BB0H  0
  7092  01BB4H  0
  7096  01BB8H  0
  7100  01BBCH  36
  7104  01BC0H  0
  7108  01BC4H  0
  7112  01BC8H  0
  7116  01BCCH  0
  7120  01BD0H  16
  7124  01BD4H  0
  7128  01BD8H  0
  7132  01BDCH  0
  7136  01BE0H  0
  7140  01BE4H  8
  7144  01BE8H  0
  7148  01BECH  0
  7152  01BF0H  0
  7156  01BF4H  0
  7160  01BF8H  64
  7164  01BFCH  010001BF8H
  7168  01C00H  0
  7172  01C04H  0
  7176  01C08H  0
  7180  01C0CH  128
  7184  01C10H  010001C0CH
  7188  01C14H  0
  7192  01C18H  0
  7196  01C1CH  0
  7200  01C20H  200
  7204  01C24H  0
  7208  01C28H  0
  7212  01C2CH  0
  7216  01C30H  0

PROCEDURE RuntimeErrors.HALT:
  7220  01C34H  0B501H      push     { r0, lr }
  7222  01C36H  09800H      ldr      r0,[sp]
  7224  01C38H  04907H      ldr      r1,[pc,#28] -> 7256
  7226  01C3AH  022C8H      movs     r2,#200
  7228  01C3CH  04350H      muls     r0,r2
  7230  01C3EH  01808H      adds     r0,r1,r0
  7232  01C40H  021C4H      movs     r1,#196
  7234  01C42H  05C40H      ldrb     r0,[r0,r1]
  7236  01C44H  02101H      movs     r1,#1
  7238  01C46H  04208H      tst      r0,r1
  7240  01C48H  0D101H      bne.n    2 -> 7246
  7242  01C4AH  0E002H      b        4 -> 7250
  7244  01C4CH  046C0H      nop
  7246  01C4EH  04280H      cmp      r0,r0
  7248  01C50H  0D0FDH      beq.n    -6 -> 7246
  7250  01C52H  0B001H      add      sp,#4
  7252  01C54H  0BD00H      pop      { pc }
  7254  01C56H  046C0H      nop
  7256  01C58H  02002FCD0H

PROCEDURE RuntimeErrors.getHalfWord:
  7260  01C5CH  0B503H      push     { r0, r1, lr }
  7262  01C5EH  0B081H      sub      sp,#4
  7264  01C60H  09801H      ldr      r0,[sp,#4]
  7266  01C62H  03001H      adds     r0,#1
  7268  01C64H  07801H      ldrb     r1,[r0]
  7270  01C66H  0AA00H      add      r2,sp,#0
  7272  01C68H  07011H      strb     r1,[r2]
  7274  01C6AH  09801H      ldr      r0,[sp,#4]
  7276  01C6CH  07801H      ldrb     r1,[r0]
  7278  01C6EH  0AA00H      add      r2,sp,#0
  7280  01C70H  07051H      strb     r1,[r2,#1]
  7282  01C72H  0A800H      add      r0,sp,#0
  7284  01C74H  07800H      ldrb     r0,[r0]
  7286  01C76H  00200H      lsls     r0,r0,#8
  7288  01C78H  0A900H      add      r1,sp,#0
  7290  01C7AH  07849H      ldrb     r1,[r1,#1]
  7292  01C7CH  01840H      adds     r0,r0,r1
  7294  01C7EH  09902H      ldr      r1,[sp,#8]
  7296  01C80H  06008H      str      r0,[r1]
  7298  01C82H  0B003H      add      sp,#12
  7300  01C84H  0BD00H      pop      { pc }
  7302  01C86H  046C0H      nop

PROCEDURE RuntimeErrors.isBL:
  7304  01C88H  0B501H      push     { r0, lr }
  7306  01C8AH  0B081H      sub      sp,#4
  7308  01C8CH  09801H      ldr      r0,[sp,#4]
  7310  01C8EH  04669H      mov      r1,sp
  7312  01C90H  0F7FFFFE4H  bl.w     RuntimeErrors.getHalfWord
  7316  01C94H  0E000H      b        0 -> 7320
  7318  01C96H  00094H      <LineNo: 148>
  7320  01C98H  09800H      ldr      r0,[sp]
  7322  01C9AH  00400H      lsls     r0,r0,#16
  7324  01C9CH  00EC0H      lsrs     r0,r0,#27
  7326  01C9EH  0281EH      cmp      r0,#30
  7328  01CA0H  0D001H      beq.n    2 -> 7334
  7330  01CA2H  02000H      movs     r0,#0
  7332  01CA4H  0E000H      b        0 -> 7336
  7334  01CA6H  02001H      movs     r0,#1
  7336  01CA8H  0B002H      add      sp,#8
  7338  01CAAH  0BD00H      pop      { pc }

PROCEDURE RuntimeErrors.isBLX:
  7340  01CACH  0B501H      push     { r0, lr }
  7342  01CAEH  0B081H      sub      sp,#4
  7344  01CB0H  09801H      ldr      r0,[sp,#4]
  7346  01CB2H  04669H      mov      r1,sp
  7348  01CB4H  0F7FFFFD2H  bl.w     RuntimeErrors.getHalfWord
  7352  01CB8H  0E000H      b        0 -> 7356
  7354  01CBAH  0009DH      <LineNo: 157>
  7356  01CBCH  09800H      ldr      r0,[sp]
  7358  01CBEH  00400H      lsls     r0,r0,#16
  7360  01CC0H  00DC0H      lsrs     r0,r0,#23
  7362  01CC2H  0288FH      cmp      r0,#143
  7364  01CC4H  0D001H      beq.n    2 -> 7370
  7366  01CC6H  0E005H      b        10 -> 7380
  7368  01CC8H  046C0H      nop
  7370  01CCAH  09800H      ldr      r0,[sp]
  7372  01CCCH  00740H      lsls     r0,r0,#29
  7374  01CCEH  00F40H      lsrs     r0,r0,#29
  7376  01CD0H  02800H      cmp      r0,#0
  7378  01CD2H  0D001H      beq.n    2 -> 7384
  7380  01CD4H  02000H      movs     r0,#0
  7382  01CD6H  0E000H      b        0 -> 7386
  7384  01CD8H  02001H      movs     r0,#1
  7386  01CDAH  0B002H      add      sp,#8
  7388  01CDCH  0BD00H      pop      { pc }
  7390  01CDEH  046C0H      nop

PROCEDURE RuntimeErrors.getNextLR:
  7392  01CE0H  0B507H      push     { r0, r1, r2, lr }
  7394  01CE2H  0B081H      sub      sp,#4
  7396  01CE4H  02000H      movs     r0,#0
  7398  01CE6H  09903H      ldr      r1,[sp,#12]
  7400  01CE8H  06008H      str      r0,[r1]
  7402  01CEAH  09801H      ldr      r0,[sp,#4]
  7404  01CECH  06801H      ldr      r1,[r0]
  7406  01CEEH  09A02H      ldr      r2,[sp,#8]
  7408  01CF0H  06011H      str      r1,[r2]
  7410  01CF2H  09802H      ldr      r0,[sp,#8]
  7412  01CF4H  06800H      ldr      r0,[r0]
  7414  01CF6H  02101H      movs     r1,#1
  7416  01CF8H  04208H      tst      r0,r1
  7418  01CFAH  0D101H      bne.n    2 -> 7424
  7420  01CFCH  0E042H      b        132 -> 7556
  7422  01CFEH  046C0H      nop
  7424  01D00H  09802H      ldr      r0,[sp,#8]
  7426  01D02H  06801H      ldr      r1,[r0]
  7428  01D04H  03901H      subs     r1,#1
  7430  01D06H  06001H      str      r1,[r0]
  7432  01D08H  09802H      ldr      r0,[sp,#8]
  7434  01D0AH  06800H      ldr      r0,[r0]
  7436  01D0CH  0491EH      ldr      r1,[pc,#120] -> 7560
  7438  01D0EH  06809H      ldr      r1,[r1]
  7440  01D10H  04288H      cmp      r0,r1
  7442  01D12H  0DA01H      bge.n    2 -> 7448
  7444  01D14H  0E036H      b        108 -> 7556
  7446  01D16H  046C0H      nop
  7448  01D18H  09802H      ldr      r0,[sp,#8]
  7450  01D1AH  06800H      ldr      r0,[r0]
  7452  01D1CH  0491BH      ldr      r1,[pc,#108] -> 7564
  7454  01D1EH  06809H      ldr      r1,[r1]
  7456  01D20H  04288H      cmp      r0,r1
  7458  01D22H  0DB01H      blt.n    2 -> 7464
  7460  01D24H  0E02EH      b        92 -> 7556
  7462  01D26H  046C0H      nop
  7464  01D28H  09802H      ldr      r0,[sp,#8]
  7466  01D2AH  06800H      ldr      r0,[r0]
  7468  01D2CH  03804H      subs     r0,#4
  7470  01D2EH  0F7FFFFABH  bl.w     RuntimeErrors.isBL
  7474  01D32H  0E000H      b        0 -> 7478
  7476  01D34H  000AEH      <LineNo: 174>
  7478  01D36H  02101H      movs     r1,#1
  7480  01D38H  04208H      tst      r0,r1
  7482  01D3AH  0D001H      beq.n    2 -> 7488
  7484  01D3CH  0E00CH      b        24 -> 7512
  7486  01D3EH  046C0H      nop
  7488  01D40H  09802H      ldr      r0,[sp,#8]
  7490  01D42H  06800H      ldr      r0,[r0]
  7492  01D44H  03802H      subs     r0,#2
  7494  01D46H  0F7FFFFB1H  bl.w     RuntimeErrors.isBLX
  7498  01D4AH  0E000H      b        0 -> 7502
  7500  01D4CH  000AEH      <LineNo: 174>
  7502  01D4EH  02101H      movs     r1,#1
  7504  01D50H  04208H      tst      r0,r1
  7506  01D52H  0D101H      bne.n    2 -> 7512
  7508  01D54H  0E016H      b        44 -> 7556
  7510  01D56H  046C0H      nop
  7512  01D58H  09802H      ldr      r0,[sp,#8]
  7514  01D5AH  06800H      ldr      r0,[r0]
  7516  01D5CH  04669H      mov      r1,sp
  7518  01D5EH  0F7FFFF7DH  bl.w     RuntimeErrors.getHalfWord
  7522  01D62H  0E000H      b        0 -> 7526
  7524  01D64H  000AFH      <LineNo: 175>
  7526  01D66H  09800H      ldr      r0,[sp]
  7528  01D68H  02107H      movs     r1,#7
  7530  01D6AH  00349H      lsls     r1,r1,#13
  7532  01D6CH  04288H      cmp      r0,r1
  7534  01D6EH  0D001H      beq.n    2 -> 7540
  7536  01D70H  0E005H      b        10 -> 7550
  7538  01D72H  046C0H      nop
  7540  01D74H  02001H      movs     r0,#1
  7542  01D76H  09903H      ldr      r1,[sp,#12]
  7544  01D78H  06008H      str      r0,[r1]
  7546  01D7AH  0E003H      b        6 -> 7556
  7548  01D7CH  046C0H      nop
  7550  01D7EH  02002H      movs     r0,#2
  7552  01D80H  09903H      ldr      r1,[sp,#12]
  7554  01D82H  06008H      str      r0,[r1]
  7556  01D84H  0B004H      add      sp,#16
  7558  01D86H  0BD00H      pop      { pc }
  7560  01D88H  02002FFC0H
  7564  01D8CH  02002FFBCH

PROCEDURE RuntimeErrors.Stacktrace:
  7568  01D90H  0B507H      push     { r0, r1, r2, lr }
  7570  01D92H  0B085H      sub      sp,#20
  7572  01D94H  09805H      ldr      r0,[sp,#20]
  7574  01D96H  06801H      ldr      r1,[r0]
  7576  01D98H  09101H      str      r1,[sp,#4]
  7578  01D9AH  09805H      ldr      r0,[sp,#20]
  7580  01D9CH  09901H      ldr      r1,[sp,#4]
  7582  01D9EH  04288H      cmp      r0,r1
  7584  01DA0H  0D101H      bne.n    2 -> 7590
  7586  01DA2H  0E041H      b        130 -> 7720
  7588  01DA4H  046C0H      nop
  7590  01DA6H  09806H      ldr      r0,[sp,#24]
  7592  01DA8H  06C00H      ldr      r0,[r0,#64]
  7594  01DAAH  02807H      cmp      r0,#7
  7596  01DACH  0DB01H      blt.n    2 -> 7602
  7598  01DAEH  0E03BH      b        118 -> 7720
  7600  01DB0H  046C0H      nop
  7602  01DB2H  09805H      ldr      r0,[sp,#20]
  7604  01DB4H  04669H      mov      r1,sp
  7606  01DB6H  0AA02H      add      r2,sp,#8
  7608  01DB8H  0F7FFFF92H  bl.w     RuntimeErrors.getNextLR
  7612  01DBCH  0E000H      b        0 -> 7616
  7614  01DBEH  000C6H      <LineNo: 198>
  7616  01DC0H  09802H      ldr      r0,[sp,#8]
  7618  01DC2H  02800H      cmp      r0,#0
  7620  01DC4H  0DC01H      bgt.n    2 -> 7626
  7622  01DC6H  0E028H      b        80 -> 7706
  7624  01DC8H  046C0H      nop
  7626  01DCAH  09800H      ldr      r0,[sp]
  7628  01DCCH  03804H      subs     r0,#4
  7630  01DCEH  09003H      str      r0,[sp,#12]
  7632  01DD0H  09802H      ldr      r0,[sp,#8]
  7634  01DD2H  02801H      cmp      r0,#1
  7636  01DD4H  0D001H      beq.n    2 -> 7642
  7638  01DD6H  0E009H      b        18 -> 7660
  7640  01DD8H  046C0H      nop
  7642  01DDAH  09800H      ldr      r0,[sp]
  7644  01DDCH  03002H      adds     r0,#2
  7646  01DDEH  0A904H      add      r1,sp,#16
  7648  01DE0H  0F7FFFF3CH  bl.w     RuntimeErrors.getHalfWord
  7652  01DE4H  0E000H      b        0 -> 7656
  7654  01DE6H  000CAH      <LineNo: 202>
  7656  01DE8H  0E002H      b        4 -> 7664
  7658  01DEAH  046C0H      nop
  7660  01DECH  02000H      movs     r0,#0
  7662  01DEEH  09004H      str      r0,[sp,#16]
  7664  01DF0H  09806H      ldr      r0,[sp,#24]
  7666  01DF2H  06C00H      ldr      r0,[r0,#64]
  7668  01DF4H  02808H      cmp      r0,#8
  7670  01DF6H  0D301H      bcc.n    2 -> 7676
  7672  01DF8H  0DF01H      svc      1
  7674  01DFAH  000CEH      <LineNo: 206>
  7676  01DFCH  09906H      ldr      r1,[sp,#24]
  7678  01DFEH  000C0H      lsls     r0,r0,#3
  7680  01E00H  01808H      adds     r0,r1,r0
  7682  01E02H  02102H      movs     r1,#2
  7684  01E04H  0AA03H      add      r2,sp,#12
  7686  01E06H  06813H      ldr      r3,[r2]
  7688  01E08H  03204H      adds     r2,#4
  7690  01E0AH  06003H      str      r3,[r0]
  7692  01E0CH  03004H      adds     r0,#4
  7694  01E0EH  03901H      subs     r1,#1
  7696  01E10H  0D1F9H      bne.n    -14 -> 7686
  7698  01E12H  09806H      ldr      r0,[sp,#24]
  7700  01E14H  06C01H      ldr      r1,[r0,#64]
  7702  01E16H  03101H      adds     r1,#1
  7704  01E18H  06401H      str      r1,[r0,#64]
  7706  01E1AH  09805H      ldr      r0,[sp,#20]
  7708  01E1CH  03004H      adds     r0,#4
  7710  01E1EH  09005H      str      r0,[sp,#20]
  7712  01E20H  09805H      ldr      r0,[sp,#20]
  7714  01E22H  06801H      ldr      r1,[r0]
  7716  01E24H  09101H      str      r1,[sp,#4]
  7718  01E26H  0E7B8H      b        -144 -> 7578
  7720  01E28H  09806H      ldr      r0,[sp,#24]
  7722  01E2AH  06C00H      ldr      r0,[r0,#64]
  7724  01E2CH  02807H      cmp      r0,#7
  7726  01E2EH  0D001H      beq.n    2 -> 7732
  7728  01E30H  0E003H      b        6 -> 7738
  7730  01E32H  046C0H      nop
  7732  01E34H  04802H      ldr      r0,[pc,#8] -> 7744
  7734  01E36H  09906H      ldr      r1,[sp,#24]
  7736  01E38H  06388H      str      r0,[r1,#56]
  7738  01E3AH  0B008H      add      sp,#32
  7740  01E3CH  0BD00H      pop      { pc }
  7742  01E3EH  046C0H      nop
  7744  01E40H  -1

PROCEDURE RuntimeErrors.extractError:
  7748  01E44H  0B507H      push     { r0, r1, r2, lr }
  7750  01E46H  0B083H      sub      sp,#12
  7752  01E48H  09803H      ldr      r0,[sp,#12]
  7754  01E4AH  03018H      adds     r0,#24
  7756  01E4CH  06801H      ldr      r1,[r0]
  7758  01E4EH  09102H      str      r1,[sp,#8]
  7760  01E50H  09802H      ldr      r0,[sp,#8]
  7762  01E52H  0A901H      add      r1,sp,#4
  7764  01E54H  0F7FFFF02H  bl.w     RuntimeErrors.getHalfWord
  7768  01E58H  0E000H      b        0 -> 7772
  7770  01E5AH  000DFH      <LineNo: 223>
  7772  01E5CH  09802H      ldr      r0,[sp,#8]
  7774  01E5EH  03802H      subs     r0,#2
  7776  01E60H  09002H      str      r0,[sp,#8]
  7778  01E62H  09802H      ldr      r0,[sp,#8]
  7780  01E64H  09000H      str      r0,[sp]
  7782  01E66H  09802H      ldr      r0,[sp,#8]
  7784  01E68H  09904H      ldr      r1,[sp,#16]
  7786  01E6AH  0F7FFFEF7H  bl.w     RuntimeErrors.getHalfWord
  7790  01E6EH  0E000H      b        0 -> 7794
  7792  01E70H  000E2H      <LineNo: 226>
  7794  01E72H  09804H      ldr      r0,[sp,#16]
  7796  01E74H  06800H      ldr      r0,[r0]
  7798  01E76H  0B2C0H      uxtb     r0,r0
  7800  01E78H  09904H      ldr      r1,[sp,#16]
  7802  01E7AH  06008H      str      r0,[r1]
  7804  01E7CH  02002H      movs     r0,#2
  7806  01E7EH  09904H      ldr      r1,[sp,#16]
  7808  01E80H  03108H      adds     r1,#8
  7810  01E82H  0466AH      mov      r2,sp
  7812  01E84H  06813H      ldr      r3,[r2]
  7814  01E86H  03204H      adds     r2,#4
  7816  01E88H  0600BH      str      r3,[r1]
  7818  01E8AH  03104H      adds     r1,#4
  7820  01E8CH  03801H      subs     r0,#1
  7822  01E8EH  0D1F9H      bne.n    -14 -> 7812
  7824  01E90H  02001H      movs     r0,#1
  7826  01E92H  09904H      ldr      r1,[sp,#16]
  7828  01E94H  06488H      str      r0,[r1,#72]
  7830  01E96H  0B006H      add      sp,#24
  7832  01E98H  0BD00H      pop      { pc }
  7834  01E9AH  046C0H      nop

PROCEDURE RuntimeErrors.extractFault:
  7836  01E9CH  0B507H      push     { r0, r1, r2, lr }
  7838  01E9EH  09800H      ldr      r0,[sp]
  7840  01EA0H  03018H      adds     r0,#24
  7842  01EA2H  06801H      ldr      r1,[r0]
  7844  01EA4H  09A01H      ldr      r2,[sp,#4]
  7846  01EA6H  06091H      str      r1,[r2,#8]
  7848  01EA8H  0F3EF8B05H  .word 0x8B05F3EF /* EMIT */
  7852  01EACH  04658H      mov      r0,r11
  7854  01EAEH  09901H      ldr      r1,[sp,#4]
  7856  01EB0H  06008H      str      r0,[r1]
  7858  01EB2H  0B003H      add      sp,#12
  7860  01EB4H  0BD00H      pop      { pc }
  7862  01EB6H  046C0H      nop

PROCEDURE RuntimeErrors.readRegs:
  7864  01EB8H  0B507H      push     { r0, r1, r2, lr }
  7866  01EBAH  09800H      ldr      r0,[sp]
  7868  01EBCH  06801H      ldr      r1,[r0]
  7870  01EBEH  09A01H      ldr      r2,[sp,#4]
  7872  01EC0H  06011H      str      r1,[r2]
  7874  01EC2H  09800H      ldr      r0,[sp]
  7876  01EC4H  03004H      adds     r0,#4
  7878  01EC6H  06801H      ldr      r1,[r0]
  7880  01EC8H  09A01H      ldr      r2,[sp,#4]
  7882  01ECAH  06051H      str      r1,[r2,#4]
  7884  01ECCH  09800H      ldr      r0,[sp]
  7886  01ECEH  03008H      adds     r0,#8
  7888  01ED0H  06801H      ldr      r1,[r0]
  7890  01ED2H  09A01H      ldr      r2,[sp,#4]
  7892  01ED4H  06091H      str      r1,[r2,#8]
  7894  01ED6H  09800H      ldr      r0,[sp]
  7896  01ED8H  0300CH      adds     r0,#12
  7898  01EDAH  06801H      ldr      r1,[r0]
  7900  01EDCH  09A01H      ldr      r2,[sp,#4]
  7902  01EDEH  060D1H      str      r1,[r2,#12]
  7904  01EE0H  09800H      ldr      r0,[sp]
  7906  01EE2H  03010H      adds     r0,#16
  7908  01EE4H  06801H      ldr      r1,[r0]
  7910  01EE6H  09A01H      ldr      r2,[sp,#4]
  7912  01EE8H  06111H      str      r1,[r2,#16]
  7914  01EEAH  09800H      ldr      r0,[sp]
  7916  01EECH  03014H      adds     r0,#20
  7918  01EEEH  06801H      ldr      r1,[r0]
  7920  01EF0H  09A01H      ldr      r2,[sp,#4]
  7922  01EF2H  06151H      str      r1,[r2,#20]
  7924  01EF4H  09800H      ldr      r0,[sp]
  7926  01EF6H  03018H      adds     r0,#24
  7928  01EF8H  06801H      ldr      r1,[r0]
  7930  01EFAH  09A01H      ldr      r2,[sp,#4]
  7932  01EFCH  06191H      str      r1,[r2,#24]
  7934  01EFEH  09800H      ldr      r0,[sp]
  7936  01F00H  0301CH      adds     r0,#28
  7938  01F02H  06801H      ldr      r1,[r0]
  7940  01F04H  09A01H      ldr      r2,[sp,#4]
  7942  01F06H  061D1H      str      r1,[r2,#28]
  7944  01F08H  09800H      ldr      r0,[sp]
  7946  01F0AH  09901H      ldr      r1,[sp,#4]
  7948  01F0CH  06208H      str      r0,[r1,#32]
  7950  01F0EH  0B003H      add      sp,#12
  7952  01F10H  0BD00H      pop      { pc }
  7954  01F12H  046C0H      nop

PROCEDURE RuntimeErrors.traceStart:
  7956  01F14H  0B501H      push     { r0, lr }
  7958  01F16H  0B081H      sub      sp,#4
  7960  01F18H  09801H      ldr      r0,[sp,#4]
  7962  01F1AH  03020H      adds     r0,#32
  7964  01F1CH  09000H      str      r0,[sp]
  7966  01F1EH  09801H      ldr      r0,[sp,#4]
  7968  01F20H  0301CH      adds     r0,#28
  7970  01F22H  06801H      ldr      r1,[r0]
  7972  01F24H  00589H      lsls     r1,r1,#22
  7974  01F26H  0D401H      bmi.n    2 -> 7980
  7976  01F28H  0E003H      b        6 -> 7986
  7978  01F2AH  046C0H      nop
  7980  01F2CH  09800H      ldr      r0,[sp]
  7982  01F2EH  03004H      adds     r0,#4
  7984  01F30H  09000H      str      r0,[sp]
  7986  01F32H  09800H      ldr      r0,[sp]
  7988  01F34H  0B002H      add      sp,#8
  7990  01F36H  0BD00H      pop      { pc }

PROCEDURE RuntimeErrors.stackFrameBase:
  7992  01F38H  0B503H      push     { r0, r1, lr }
  7994  01F3AH  0B081H      sub      sp,#4
  7996  01F3CH  09802H      ldr      r0,[sp,#8]
  7998  01F3EH  02104H      movs     r1,#4
  8000  01F40H  04208H      tst      r0,r1
  8002  01F42H  0D101H      bne.n    2 -> 8008
  8004  01F44H  0E006H      b        12 -> 8020
  8006  01F46H  046C0H      nop
  8008  01F48H  0F3EF8B09H  .word 0x8B09F3EF /* EMIT */
  8012  01F4CH  04658H      mov      r0,r11
  8014  01F4EH  09000H      str      r0,[sp]
  8016  01F50H  0E002H      b        4 -> 8024
  8018  01F52H  046C0H      nop
  8020  01F54H  09801H      ldr      r0,[sp,#4]
  8022  01F56H  09000H      str      r0,[sp]
  8024  01F58H  09800H      ldr      r0,[sp]
  8026  01F5AH  0B003H      add      sp,#12
  8028  01F5CH  0BD00H      pop      { pc }
  8030  01F5EH  046C0H      nop

PROCEDURE RuntimeErrors.errorHandler:
  8032  01F60H  0B500H      push     { lr }
  8034  01F62H  0B082H      sub      sp,#8
  8036  01F64H  0486DH      ldr      r0,[pc,#436] -> 8476
  8038  01F66H  06801H      ldr      r1,[r0]
  8040  01F68H  09101H      str      r1,[sp,#4]
  8042  01F6AH  09801H      ldr      r0,[sp,#4]
  8044  01F6CH  02802H      cmp      r0,#2
  8046  01F6EH  0D301H      bcc.n    2 -> 8052
  8048  01F70H  0DF01H      svc      1
  8050  01F72H  0011EH      <LineNo: 286>
  8052  01F74H  0496EH      ldr      r1,[pc,#440] -> 8496
  8054  01F76H  022C8H      movs     r2,#200
  8056  01F78H  04350H      muls     r0,r2
  8058  01F7AH  01808H      adds     r0,r1,r0
  8060  01F7CH  021C7H      movs     r1,#199
  8062  01F7EH  05C40H      ldrb     r0,[r0,r1]
  8064  01F80H  02101H      movs     r1,#1
  8066  01F82H  04208H      tst      r0,r1
  8068  01F84H  0D101H      bne.n    2 -> 8074
  8070  01F86H  0E032H      b        100 -> 8174
  8072  01F88H  046C0H      nop
  8074  01F8AH  09801H      ldr      r0,[sp,#4]
  8076  01F8CH  02802H      cmp      r0,#2
  8078  01F8EH  0D301H      bcc.n    2 -> 8084
  8080  01F90H  0DF01H      svc      1
  8082  01F92H  0011FH      <LineNo: 287>
  8084  01F94H  04966H      ldr      r1,[pc,#408] -> 8496
  8086  01F96H  022C8H      movs     r2,#200
  8088  01F98H  04350H      muls     r0,r2
  8090  01F9AH  01808H      adds     r0,r1,r0
  8092  01F9CH  04679H      mov      r1,pc
  8094  01F9EH  022B8H      movs     r2,#184
  8096  01FA0H  05081H      str      r1,[r0,r2]
  8098  01FA2H  09801H      ldr      r0,[sp,#4]
  8100  01FA4H  02802H      cmp      r0,#2
  8102  01FA6H  0D301H      bcc.n    2 -> 8108
  8104  01FA8H  0DF01H      svc      1
  8106  01FAAH  00120H      <LineNo: 288>
  8108  01FACH  04960H      ldr      r1,[pc,#384] -> 8496
  8110  01FAEH  022C8H      movs     r2,#200
  8112  01FB0H  04350H      muls     r0,r2
  8114  01FB2H  01808H      adds     r0,r1,r0
  8116  01FB4H  04669H      mov      r1,sp
  8118  01FB6H  022B0H      movs     r2,#176
  8120  01FB8H  05081H      str      r1,[r0,r2]
  8122  01FBAH  09801H      ldr      r0,[sp,#4]
  8124  01FBCH  02802H      cmp      r0,#2
  8126  01FBEH  0D301H      bcc.n    2 -> 8132
  8128  01FC0H  0DF01H      svc      1
  8130  01FC2H  00121H      <LineNo: 289>
  8132  01FC4H  0495AH      ldr      r1,[pc,#360] -> 8496
  8134  01FC6H  022C8H      movs     r2,#200
  8136  01FC8H  04350H      muls     r0,r2
  8138  01FCAH  01808H      adds     r0,r1,r0
  8140  01FCCH  04671H      mov      r1,lr
  8142  01FCEH  022B4H      movs     r2,#180
  8144  01FD0H  05081H      str      r1,[r0,r2]
  8146  01FD2H  0F3EF8B03H  .word 0x8B03F3EF /* EMIT */
  8150  01FD6H  09801H      ldr      r0,[sp,#4]
  8152  01FD8H  02802H      cmp      r0,#2
  8154  01FDAH  0D301H      bcc.n    2 -> 8160
  8156  01FDCH  0DF01H      svc      1
  8158  01FDEH  00123H      <LineNo: 291>
  8160  01FE0H  04953H      ldr      r1,[pc,#332] -> 8496
  8162  01FE2H  022C8H      movs     r2,#200
  8164  01FE4H  04350H      muls     r0,r2
  8166  01FE6H  01808H      adds     r0,r1,r0
  8168  01FE8H  04659H      mov      r1,r11
  8170  01FEAH  022BCH      movs     r2,#188
  8172  01FECH  05081H      str      r1,[r0,r2]
  8174  01FEEH  09801H      ldr      r0,[sp,#4]
  8176  01FF0H  02802H      cmp      r0,#2
  8178  01FF2H  0D301H      bcc.n    2 -> 8184
  8180  01FF4H  0DF01H      svc      1
  8182  01FF6H  00125H      <LineNo: 293>
  8184  01FF8H  0494DH      ldr      r1,[pc,#308] -> 8496
  8186  01FFAH  022C8H      movs     r2,#200
  8188  01FFCH  04350H      muls     r0,r2
  8190  01FFEH  01808H      adds     r0,r1,r0
  8192  02000H  09901H      ldr      r1,[sp,#4]
  8194  02002H  06441H      str      r1,[r0,#68]
  8196  02004H  04668H      mov      r0,sp
  8198  02006H  0300CH      adds     r0,#12
  8200  02008H  04671H      mov      r1,lr
  8202  0200AH  0F7FFFF95H  bl.w     RuntimeErrors.stackFrameBase
  8206  0200EH  0E000H      b        0 -> 8210
  8208  02010H  00126H      <LineNo: 294>
  8210  02012H  09000H      str      r0,[sp]
  8212  02014H  09801H      ldr      r0,[sp,#4]
  8214  02016H  02802H      cmp      r0,#2
  8216  02018H  0D301H      bcc.n    2 -> 8222
  8218  0201AH  0DF01H      svc      1
  8220  0201CH  00127H      <LineNo: 295>
  8222  0201EH  04944H      ldr      r1,[pc,#272] -> 8496
  8224  02020H  022C8H      movs     r2,#200
  8226  02022H  04350H      muls     r0,r2
  8228  02024H  01808H      adds     r0,r1,r0
  8230  02026H  021C6H      movs     r1,#198
  8232  02028H  05C40H      ldrb     r0,[r0,r1]
  8234  0202AH  02101H      movs     r1,#1
  8236  0202CH  04208H      tst      r0,r1
  8238  0202EH  0D101H      bne.n    2 -> 8244
  8240  02030H  0E012H      b        36 -> 8280
  8242  02032H  046C0H      nop
  8244  02034H  09800H      ldr      r0,[sp]
  8246  02036H  09901H      ldr      r1,[sp,#4]
  8248  02038H  02902H      cmp      r1,#2
  8250  0203AH  0D301H      bcc.n    2 -> 8256
  8252  0203CH  0DF01H      svc      1
  8254  0203EH  00128H      <LineNo: 296>
  8256  02040H  04A3BH      ldr      r2,[pc,#236] -> 8496
  8258  02042H  023C8H      movs     r3,#200
  8260  02044H  04359H      muls     r1,r3
  8262  02046H  01851H      adds     r1,r2,r1
  8264  02048H  0318CH      adds     r1,#140
  8266  0204AH  04A35H      ldr      r2,[pc,#212] -> 8480
  8268  0204CH  0467BH      mov      r3,pc
  8270  0204EH  018D2H      adds     r2,r2,r3
  8272  02050H  0F7FFFF32H  bl.w     RuntimeErrors.readRegs
  8276  02054H  0E000H      b        0 -> 8280
  8278  02056H  00128H      <LineNo: 296>
  8280  02058H  09800H      ldr      r0,[sp]
  8282  0205AH  09901H      ldr      r1,[sp,#4]
  8284  0205CH  02902H      cmp      r1,#2
  8286  0205EH  0D301H      bcc.n    2 -> 8292
  8288  02060H  0DF01H      svc      1
  8290  02062H  0012AH      <LineNo: 298>
  8292  02064H  04A32H      ldr      r2,[pc,#200] -> 8496
  8294  02066H  023C8H      movs     r3,#200
  8296  02068H  04359H      muls     r1,r3
  8298  0206AH  01851H      adds     r1,r2,r1
  8300  0206CH  03140H      adds     r1,#64
  8302  0206EH  04A2DH      ldr      r2,[pc,#180] -> 8484
  8304  02070H  0467BH      mov      r3,pc
  8306  02072H  018D2H      adds     r2,r2,r3
  8308  02074H  0F7FFFEE6H  bl.w     RuntimeErrors.extractError
  8312  02078H  0E000H      b        0 -> 8316
  8314  0207AH  0012AH      <LineNo: 298>
  8316  0207CH  09801H      ldr      r0,[sp,#4]
  8318  0207EH  02802H      cmp      r0,#2
  8320  02080H  0D301H      bcc.n    2 -> 8326
  8322  02082H  0DF01H      svc      1
  8324  02084H  0012BH      <LineNo: 299>
  8326  02086H  0492AH      ldr      r1,[pc,#168] -> 8496
  8328  02088H  022C8H      movs     r2,#200
  8330  0208AH  04350H      muls     r0,r2
  8332  0208CH  01808H      adds     r0,r1,r0
  8334  0208EH  021C5H      movs     r1,#197
  8336  02090H  05C40H      ldrb     r0,[r0,r1]
  8338  02092H  02101H      movs     r1,#1
  8340  02094H  04208H      tst      r0,r1
  8342  02096H  0D101H      bne.n    2 -> 8348
  8344  02098H  0E016H      b        44 -> 8392
  8346  0209AH  046C0H      nop
  8348  0209CH  09800H      ldr      r0,[sp]
  8350  0209EH  0F7FFFF39H  bl.w     RuntimeErrors.traceStart
  8354  020A2H  0E000H      b        0 -> 8358
  8356  020A4H  0012CH      <LineNo: 300>
  8358  020A6H  09901H      ldr      r1,[sp,#4]
  8360  020A8H  02902H      cmp      r1,#2
  8362  020AAH  0D301H      bcc.n    2 -> 8368
  8364  020ACH  0DF01H      svc      1
  8366  020AEH  0012CH      <LineNo: 300>
  8368  020B0H  04A1FH      ldr      r2,[pc,#124] -> 8496
  8370  020B2H  023C8H      movs     r3,#200
  8372  020B4H  04359H      muls     r1,r3
  8374  020B6H  01851H      adds     r1,r2,r1
  8376  020B8H  03148H      adds     r1,#72
  8378  020BAH  04A1BH      ldr      r2,[pc,#108] -> 8488
  8380  020BCH  0467BH      mov      r3,pc
  8382  020BEH  018D2H      adds     r2,r2,r3
  8384  020C0H  0F7FFFE66H  bl.w     RuntimeErrors.Stacktrace
  8388  020C4H  0E000H      b        0 -> 8392
  8390  020C6H  0012CH      <LineNo: 300>
  8392  020C8H  09801H      ldr      r0,[sp,#4]
  8394  020CAH  02802H      cmp      r0,#2
  8396  020CCH  0D301H      bcc.n    2 -> 8402
  8398  020CEH  0DF01H      svc      1
  8400  020D0H  0012EH      <LineNo: 302>
  8402  020D2H  04917H      ldr      r1,[pc,#92] -> 8496
  8404  020D4H  022C8H      movs     r2,#200
  8406  020D6H  04350H      muls     r0,r2
  8408  020D8H  01808H      adds     r0,r1,r0
  8410  020DAH  021C0H      movs     r1,#192
  8412  020DCH  05840H      ldr      r0,[r0,r1]
  8414  020DEH  0B401H      push     { r0 }
  8416  020E0H  09802H      ldr      r0,[sp,#8]
  8418  020E2H  09902H      ldr      r1,[sp,#8]
  8420  020E4H  02902H      cmp      r1,#2
  8422  020E6H  0D301H      bcc.n    2 -> 8428
  8424  020E8H  0DF01H      svc      1
  8426  020EAH  0012EH      <LineNo: 302>
  8428  020ECH  04A10H      ldr      r2,[pc,#64] -> 8496
  8430  020EEH  023C8H      movs     r3,#200
  8432  020F0H  04359H      muls     r1,r3
  8434  020F2H  01851H      adds     r1,r2,r1
  8436  020F4H  03140H      adds     r1,#64
  8438  020F6H  04A0DH      ldr      r2,[pc,#52] -> 8492
  8440  020F8H  0467BH      mov      r3,pc
  8442  020FAH  018D2H      adds     r2,r2,r3
  8444  020FCH  0BC08H      pop      { r3 }
  8446  020FEH  02B00H      cmp      r3,#0
  8448  02100H  0D101H      bne.n    2 -> 8454
  8450  02102H  0DF05H      svc      5
  8452  02104H  0012EH      <LineNo: 302>
  8454  02106H  03301H      adds     r3,#1
  8456  02108H  04798H      blx      r3
  8458  0210AH  0E000H      b        0 -> 8462
  8460  0210CH  0012DH      <LineNo: 301>
  8462  0210EH  09801H      ldr      r0,[sp,#4]
  8464  02110H  0F7FFFD90H  bl.w     RuntimeErrors.HALT
  8468  02114H  0E000H      b        0 -> 8472
  8470  02116H  00130H      <LineNo: 304>
  8472  02118H  0B002H      add      sp,#8
  8474  0211AH  0BD00H      pop      { pc }
  8476  0211CH  0D0000000H
  8480  02120H  -1172
  8484  02124H  -1128
  8488  02128H  -1304
  8492  0212CH  -1264
  8496  02130H  02002FCD0H

PROCEDURE RuntimeErrors.faultHandler:
  8500  02134H  0B500H      push     { lr }
  8502  02136H  0B082H      sub      sp,#8
  8504  02138H  04857H      ldr      r0,[pc,#348] -> 8856
  8506  0213AH  06801H      ldr      r1,[r0]
  8508  0213CH  09101H      str      r1,[sp,#4]
  8510  0213EH  09801H      ldr      r0,[sp,#4]
  8512  02140H  02802H      cmp      r0,#2
  8514  02142H  0D301H      bcc.n    2 -> 8520
  8516  02144H  0DF01H      svc      1
  8518  02146H  0013AH      <LineNo: 314>
  8520  02148H  04957H      ldr      r1,[pc,#348] -> 8872
  8522  0214AH  022C8H      movs     r2,#200
  8524  0214CH  04350H      muls     r0,r2
  8526  0214EH  01808H      adds     r0,r1,r0
  8528  02150H  021C7H      movs     r1,#199
  8530  02152H  05C40H      ldrb     r0,[r0,r1]
  8532  02154H  02101H      movs     r1,#1
  8534  02156H  04208H      tst      r0,r1
  8536  02158H  0D101H      bne.n    2 -> 8542
  8538  0215AH  0E02EH      b        92 -> 8634
  8540  0215CH  046C0H      nop
  8542  0215EH  09801H      ldr      r0,[sp,#4]
  8544  02160H  02802H      cmp      r0,#2
  8546  02162H  0D301H      bcc.n    2 -> 8552
  8548  02164H  0DF01H      svc      1
  8550  02166H  0013BH      <LineNo: 315>
  8552  02168H  0494FH      ldr      r1,[pc,#316] -> 8872
  8554  0216AH  022C8H      movs     r2,#200
  8556  0216CH  04350H      muls     r0,r2
  8558  0216EH  01808H      adds     r0,r1,r0
  8560  02170H  04679H      mov      r1,pc
  8562  02172H  06381H      str      r1,[r0,#56]
  8564  02174H  09801H      ldr      r0,[sp,#4]
  8566  02176H  02802H      cmp      r0,#2
  8568  02178H  0D301H      bcc.n    2 -> 8574
  8570  0217AH  0DF01H      svc      1
  8572  0217CH  0013CH      <LineNo: 316>
  8574  0217EH  0494AH      ldr      r1,[pc,#296] -> 8872
  8576  02180H  022C8H      movs     r2,#200
  8578  02182H  04350H      muls     r0,r2
  8580  02184H  01808H      adds     r0,r1,r0
  8582  02186H  04669H      mov      r1,sp
  8584  02188H  06301H      str      r1,[r0,#48]
  8586  0218AH  09801H      ldr      r0,[sp,#4]
  8588  0218CH  02802H      cmp      r0,#2
  8590  0218EH  0D301H      bcc.n    2 -> 8596
  8592  02190H  0DF01H      svc      1
  8594  02192H  0013DH      <LineNo: 317>
  8596  02194H  04944H      ldr      r1,[pc,#272] -> 8872
  8598  02196H  022C8H      movs     r2,#200
  8600  02198H  04350H      muls     r0,r2
  8602  0219AH  01808H      adds     r0,r1,r0
  8604  0219CH  04671H      mov      r1,lr
  8606  0219EH  06341H      str      r1,[r0,#52]
  8608  021A0H  0F3EF8B03H  .word 0x8B03F3EF /* EMIT */
  8612  021A4H  09801H      ldr      r0,[sp,#4]
  8614  021A6H  02802H      cmp      r0,#2
  8616  021A8H  0D301H      bcc.n    2 -> 8622
  8618  021AAH  0DF01H      svc      1
  8620  021ACH  0013FH      <LineNo: 319>
  8622  021AEH  0493EH      ldr      r1,[pc,#248] -> 8872
  8624  021B0H  022C8H      movs     r2,#200
  8626  021B2H  04350H      muls     r0,r2
  8628  021B4H  01808H      adds     r0,r1,r0
  8630  021B6H  04659H      mov      r1,r11
  8632  021B8H  063C1H      str      r1,[r0,#60]
  8634  021BAH  09801H      ldr      r0,[sp,#4]
  8636  021BCH  02802H      cmp      r0,#2
  8638  021BEH  0D301H      bcc.n    2 -> 8644
  8640  021C0H  0DF01H      svc      1
  8642  021C2H  00141H      <LineNo: 321>
  8644  021C4H  04938H      ldr      r1,[pc,#224] -> 8872
  8646  021C6H  022C8H      movs     r2,#200
  8648  021C8H  04350H      muls     r0,r2
  8650  021CAH  01808H      adds     r0,r1,r0
  8652  021CCH  09901H      ldr      r1,[sp,#4]
  8654  021CEH  06041H      str      r1,[r0,#4]
  8656  021D0H  04668H      mov      r0,sp
  8658  021D2H  0300CH      adds     r0,#12
  8660  021D4H  04671H      mov      r1,lr
  8662  021D6H  0F7FFFEAFH  bl.w     RuntimeErrors.stackFrameBase
  8666  021DAH  0E000H      b        0 -> 8670
  8668  021DCH  00142H      <LineNo: 322>
  8670  021DEH  09000H      str      r0,[sp]
  8672  021E0H  09801H      ldr      r0,[sp,#4]
  8674  021E2H  02802H      cmp      r0,#2
  8676  021E4H  0D301H      bcc.n    2 -> 8682
  8678  021E6H  0DF01H      svc      1
  8680  021E8H  00143H      <LineNo: 323>
  8682  021EAH  0492FH      ldr      r1,[pc,#188] -> 8872
  8684  021ECH  022C8H      movs     r2,#200
  8686  021EEH  04350H      muls     r0,r2
  8688  021F0H  01808H      adds     r0,r1,r0
  8690  021F2H  021C6H      movs     r1,#198
  8692  021F4H  05C40H      ldrb     r0,[r0,r1]
  8694  021F6H  02101H      movs     r1,#1
  8696  021F8H  04208H      tst      r0,r1
  8698  021FAH  0D101H      bne.n    2 -> 8704
  8700  021FCH  0E012H      b        36 -> 8740
  8702  021FEH  046C0H      nop
  8704  02200H  09800H      ldr      r0,[sp]
  8706  02202H  09901H      ldr      r1,[sp,#4]
  8708  02204H  02902H      cmp      r1,#2
  8710  02206H  0D301H      bcc.n    2 -> 8716
  8712  02208H  0DF01H      svc      1
  8714  0220AH  00144H      <LineNo: 324>
  8716  0220CH  04A26H      ldr      r2,[pc,#152] -> 8872
  8718  0220EH  023C8H      movs     r3,#200
  8720  02210H  04359H      muls     r1,r3
  8722  02212H  01851H      adds     r1,r2,r1
  8724  02214H  0310CH      adds     r1,#12
  8726  02216H  04A21H      ldr      r2,[pc,#132] -> 8860
  8728  02218H  0467BH      mov      r3,pc
  8730  0221AH  018D2H      adds     r2,r2,r3
  8732  0221CH  0F7FFFE4CH  bl.w     RuntimeErrors.readRegs
  8736  02220H  0E000H      b        0 -> 8740
  8738  02222H  00144H      <LineNo: 324>
  8740  02224H  09800H      ldr      r0,[sp]
  8742  02226H  09901H      ldr      r1,[sp,#4]
  8744  02228H  02902H      cmp      r1,#2
  8746  0222AH  0D301H      bcc.n    2 -> 8752
  8748  0222CH  0DF01H      svc      1
  8750  0222EH  00146H      <LineNo: 326>
  8752  02230H  04A1DH      ldr      r2,[pc,#116] -> 8872
  8754  02232H  023C8H      movs     r3,#200
  8756  02234H  04359H      muls     r1,r3
  8758  02236H  01851H      adds     r1,r2,r1
  8760  02238H  04A19H      ldr      r2,[pc,#100] -> 8864
  8762  0223AH  0467BH      mov      r3,pc
  8764  0223CH  018D2H      adds     r2,r2,r3
  8766  0223EH  0F7FFFE2DH  bl.w     RuntimeErrors.extractFault
  8770  02242H  0E000H      b        0 -> 8774
  8772  02244H  00146H      <LineNo: 326>
  8774  02246H  09801H      ldr      r0,[sp,#4]
  8776  02248H  02802H      cmp      r0,#2
  8778  0224AH  0D301H      bcc.n    2 -> 8784
  8780  0224CH  0DF01H      svc      1
  8782  0224EH  00147H      <LineNo: 327>
  8784  02250H  04915H      ldr      r1,[pc,#84] -> 8872
  8786  02252H  022C8H      movs     r2,#200
  8788  02254H  04350H      muls     r0,r2
  8790  02256H  01808H      adds     r0,r1,r0
  8792  02258H  021C0H      movs     r1,#192
  8794  0225AH  05840H      ldr      r0,[r0,r1]
  8796  0225CH  0B401H      push     { r0 }
  8798  0225EH  09802H      ldr      r0,[sp,#8]
  8800  02260H  09902H      ldr      r1,[sp,#8]
  8802  02262H  02902H      cmp      r1,#2
  8804  02264H  0D301H      bcc.n    2 -> 8810
  8806  02266H  0DF01H      svc      1
  8808  02268H  00147H      <LineNo: 327>
  8810  0226AH  04A0FH      ldr      r2,[pc,#60] -> 8872
  8812  0226CH  023C8H      movs     r3,#200
  8814  0226EH  04359H      muls     r1,r3
  8816  02270H  01851H      adds     r1,r2,r1
  8818  02272H  04A0CH      ldr      r2,[pc,#48] -> 8868
  8820  02274H  0467BH      mov      r3,pc
  8822  02276H  018D2H      adds     r2,r2,r3
  8824  02278H  0BC08H      pop      { r3 }
  8826  0227AH  02B00H      cmp      r3,#0
  8828  0227CH  0D101H      bne.n    2 -> 8834
  8830  0227EH  0DF05H      svc      5
  8832  02280H  00147H      <LineNo: 327>
  8834  02282H  03301H      adds     r3,#1
  8836  02284H  04798H      blx      r3
  8838  02286H  0E000H      b        0 -> 8842
  8840  02288H  00146H      <LineNo: 326>
  8842  0228AH  09801H      ldr      r0,[sp,#4]
  8844  0228CH  0F7FFFCD2H  bl.w     RuntimeErrors.HALT
  8848  02290H  0E000H      b        0 -> 8852
  8850  02292H  00148H      <LineNo: 328>
  8852  02294H  0B002H      add      sp,#8
  8854  02296H  0BD00H      pop      { pc }
  8856  02298H  0D0000000H
  8860  0229CH  -1632
  8864  022A0H  -1606
  8868  022A4H  -1664
  8872  022A8H  02002FCD0H

PROCEDURE RuntimeErrors.SetHandler:
  8876  022ACH  0B503H      push     { r0, r1, lr }
  8878  022AEH  09800H      ldr      r0,[sp]
  8880  022B0H  04904H      ldr      r1,[pc,#16] -> 8900
  8882  022B2H  022C8H      movs     r2,#200
  8884  022B4H  04350H      muls     r0,r2
  8886  022B6H  01808H      adds     r0,r1,r0
  8888  022B8H  09901H      ldr      r1,[sp,#4]
  8890  022BAH  022C0H      movs     r2,#192
  8892  022BCH  05081H      str      r1,[r0,r2]
  8894  022BEH  0B002H      add      sp,#8
  8896  022C0H  0BD00H      pop      { pc }
  8898  022C2H  046C0H      nop
  8900  022C4H  02002FCD0H

PROCEDURE RuntimeErrors.SetHalt:
  8904  022C8H  0B503H      push     { r0, r1, lr }
  8906  022CAH  09800H      ldr      r0,[sp]
  8908  022CCH  04904H      ldr      r1,[pc,#16] -> 8928
  8910  022CEH  022C8H      movs     r2,#200
  8912  022D0H  04350H      muls     r0,r2
  8914  022D2H  01808H      adds     r0,r1,r0
  8916  022D4H  0A901H      add      r1,sp,#4
  8918  022D6H  07809H      ldrb     r1,[r1]
  8920  022D8H  022C4H      movs     r2,#196
  8922  022DAH  05481H      strb     r1,[r0,r2]
  8924  022DCH  0B002H      add      sp,#8
  8926  022DEH  0BD00H      pop      { pc }
  8928  022E0H  02002FCD0H

PROCEDURE RuntimeErrors.SetStacktraceOn:
  8932  022E4H  0B503H      push     { r0, r1, lr }
  8934  022E6H  09800H      ldr      r0,[sp]
  8936  022E8H  02802H      cmp      r0,#2
  8938  022EAH  0D301H      bcc.n    2 -> 8944
  8940  022ECH  0DF01H      svc      1
  8942  022EEH  00158H      <LineNo: 344>
  8944  022F0H  04904H      ldr      r1,[pc,#16] -> 8964
  8946  022F2H  022C8H      movs     r2,#200
  8948  022F4H  04350H      muls     r0,r2
  8950  022F6H  01808H      adds     r0,r1,r0
  8952  022F8H  0A901H      add      r1,sp,#4
  8954  022FAH  07809H      ldrb     r1,[r1]
  8956  022FCH  022C5H      movs     r2,#197
  8958  022FEH  05481H      strb     r1,[r0,r2]
  8960  02300H  0B002H      add      sp,#8
  8962  02302H  0BD00H      pop      { pc }
  8964  02304H  02002FCD0H

PROCEDURE RuntimeErrors.SetStackedRegsOn:
  8968  02308H  0B503H      push     { r0, r1, lr }
  8970  0230AH  09800H      ldr      r0,[sp]
  8972  0230CH  02802H      cmp      r0,#2
  8974  0230EH  0D301H      bcc.n    2 -> 8980
  8976  02310H  0DF01H      svc      1
  8978  02312H  0015DH      <LineNo: 349>
  8980  02314H  04904H      ldr      r1,[pc,#16] -> 9000
  8982  02316H  022C8H      movs     r2,#200
  8984  02318H  04350H      muls     r0,r2
  8986  0231AH  01808H      adds     r0,r1,r0
  8988  0231CH  0A901H      add      r1,sp,#4
  8990  0231EH  07809H      ldrb     r1,[r1]
  8992  02320H  022C6H      movs     r2,#198
  8994  02322H  05481H      strb     r1,[r0,r2]
  8996  02324H  0B002H      add      sp,#8
  8998  02326H  0BD00H      pop      { pc }
  9000  02328H  02002FCD0H

PROCEDURE RuntimeErrors.SetCurrentRegsOn:
  9004  0232CH  0B503H      push     { r0, r1, lr }
  9006  0232EH  09800H      ldr      r0,[sp]
  9008  02330H  02802H      cmp      r0,#2
  9010  02332H  0D301H      bcc.n    2 -> 9016
  9012  02334H  0DF01H      svc      1
  9014  02336H  00162H      <LineNo: 354>
  9016  02338H  04904H      ldr      r1,[pc,#16] -> 9036
  9018  0233AH  022C8H      movs     r2,#200
  9020  0233CH  04350H      muls     r0,r2
  9022  0233EH  01808H      adds     r0,r1,r0
  9024  02340H  0A901H      add      r1,sp,#4
  9026  02342H  07809H      ldrb     r1,[r1]
  9028  02344H  022C7H      movs     r2,#199
  9030  02346H  05481H      strb     r1,[r0,r2]
  9032  02348H  0B002H      add      sp,#8
  9034  0234AH  0BD00H      pop      { pc }
  9036  0234CH  02002FCD0H

PROCEDURE RuntimeErrors.install:
  9040  02350H  0B503H      push     { r0, r1, lr }
  9042  02352H  09801H      ldr      r0,[sp,#4]
  9044  02354H  02101H      movs     r1,#1
  9046  02356H  04308H      orrs     r0,r1
  9048  02358H  09001H      str      r0,[sp,#4]
  9050  0235AH  09800H      ldr      r0,[sp]
  9052  0235CH  09901H      ldr      r1,[sp,#4]
  9054  0235EH  06001H      str      r1,[r0]
  9056  02360H  0B002H      add      sp,#8
  9058  02362H  0BD00H      pop      { pc }

PROCEDURE RuntimeErrors.ledOnAndHalt:
  9060  02364H  0B507H      push     { r0, r1, r2, lr }
  9062  02366H  04803H      ldr      r0,[pc,#12] -> 9076
  9064  02368H  02119H      movs     r1,#25
  9066  0236AH  06001H      str      r1,[r0]
  9068  0236CH  04280H      cmp      r0,r0
  9070  0236EH  0D0FDH      beq.n    -6 -> 9068
  9072  02370H  0B003H      add      sp,#12
  9074  02372H  0BD00H      pop      { pc }
  9076  02374H  0D0000014H

PROCEDURE RuntimeErrors.init:
  9080  02378H  0B500H      push     { lr }
  9082  0237AH  0B084H      sub      sp,#16
  9084  0237CH  02000H      movs     r0,#0
  9086  0237EH  09000H      str      r0,[sp]
  9088  02380H  09800H      ldr      r0,[sp]
  9090  02382H  02802H      cmp      r0,#2
  9092  02384H  0DB01H      blt.n    2 -> 9098
  9094  02386H  0E059H      b        178 -> 9276
  9096  02388H  046C0H      nop
  9098  0238AH  09800H      ldr      r0,[sp]
  9100  0238CH  02802H      cmp      r0,#2
  9102  0238EH  0D301H      bcc.n    2 -> 9108
  9104  02390H  0DF01H      svc      1
  9106  02392H  0017BH      <LineNo: 379>
  9108  02394H  04954H      ldr      r1,[pc,#336] -> 9448
  9110  02396H  000C0H      lsls     r0,r0,#3
  9112  02398H  01808H      adds     r0,r1,r0
  9114  0239AH  09900H      ldr      r1,[sp]
  9116  0239CH  02902H      cmp      r1,#2
  9118  0239EH  0D301H      bcc.n    2 -> 9124
  9120  023A0H  0DF01H      svc      1
  9122  023A2H  0017BH      <LineNo: 379>
  9124  023A4H  04A50H      ldr      r2,[pc,#320] -> 9448
  9126  023A6H  000C9H      lsls     r1,r1,#3
  9128  023A8H  01851H      adds     r1,r2,r1
  9130  023AAH  06800H      ldr      r0,[r0]
  9132  023ACH  06809H      ldr      r1,[r1]
  9134  023AEH  06001H      str      r1,[r0]
  9136  023B0H  09800H      ldr      r0,[sp]
  9138  023B2H  02800H      cmp      r0,#0
  9140  023B4H  0D001H      beq.n    2 -> 9146
  9142  023B6H  0E004H      b        8 -> 9154
  9144  023B8H  046C0H      nop
  9146  023BAH  0484BH      ldr      r0,[pc,#300] -> 9448
  9148  023BCH  04944H      ldr      r1,[pc,#272] -> 9424
  9150  023BEH  06840H      ldr      r0,[r0,#4]
  9152  023C0H  06008H      str      r0,[r1]
  9154  023C2H  09800H      ldr      r0,[sp]
  9156  023C4H  02802H      cmp      r0,#2
  9158  023C6H  0D301H      bcc.n    2 -> 9164
  9160  023C8H  0DF01H      svc      1
  9162  023CAH  00184H      <LineNo: 388>
  9164  023CCH  04946H      ldr      r1,[pc,#280] -> 9448
  9166  023CEH  000C0H      lsls     r0,r0,#3
  9168  023D0H  01808H      adds     r0,r1,r0
  9170  023D2H  06840H      ldr      r0,[r0,#4]
  9172  023D4H  09002H      str      r0,[sp,#8]
  9174  023D6H  09802H      ldr      r0,[sp,#8]
  9176  023D8H  030C0H      adds     r0,#192
  9178  023DAH  09003H      str      r0,[sp,#12]
  9180  023DCH  09802H      ldr      r0,[sp,#8]
  9182  023DEH  03008H      adds     r0,#8
  9184  023E0H  0493CH      ldr      r1,[pc,#240] -> 9428
  9186  023E2H  04479H      add      r1,pc
  9188  023E4H  0F7FFFFB4H  bl.w     RuntimeErrors.install
  9192  023E8H  0E000H      b        0 -> 9196
  9194  023EAH  00186H      <LineNo: 390>
  9196  023ECH  09802H      ldr      r0,[sp,#8]
  9198  023EEH  0300CH      adds     r0,#12
  9200  023F0H  04939H      ldr      r1,[pc,#228] -> 9432
  9202  023F2H  04479H      add      r1,pc
  9204  023F4H  0F7FFFFACH  bl.w     RuntimeErrors.install
  9208  023F8H  0E000H      b        0 -> 9212
  9210  023FAH  00187H      <LineNo: 391>
  9212  023FCH  09802H      ldr      r0,[sp,#8]
  9214  023FEH  0302CH      adds     r0,#44
  9216  02400H  04936H      ldr      r1,[pc,#216] -> 9436
  9218  02402H  04479H      add      r1,pc
  9220  02404H  0F7FFFFA4H  bl.w     RuntimeErrors.install
  9224  02408H  0E000H      b        0 -> 9228
  9226  0240AH  00188H      <LineNo: 392>
  9228  0240CH  09802H      ldr      r0,[sp,#8]
  9230  0240EH  03038H      adds     r0,#56
  9232  02410H  09001H      str      r0,[sp,#4]
  9234  02412H  09801H      ldr      r0,[sp,#4]
  9236  02414H  09903H      ldr      r1,[sp,#12]
  9238  02416H  04288H      cmp      r0,r1
  9240  02418H  0DB01H      blt.n    2 -> 9246
  9242  0241AH  0E00BH      b        22 -> 9268
  9244  0241CH  046C0H      nop
  9246  0241EH  09801H      ldr      r0,[sp,#4]
  9248  02420H  0492FH      ldr      r1,[pc,#188] -> 9440
  9250  02422H  04479H      add      r1,pc
  9252  02424H  0F7FFFF94H  bl.w     RuntimeErrors.install
  9256  02428H  0E000H      b        0 -> 9260
  9258  0242AH  0018BH      <LineNo: 395>
  9260  0242CH  09801H      ldr      r0,[sp,#4]
  9262  0242EH  03004H      adds     r0,#4
  9264  02430H  09001H      str      r0,[sp,#4]
  9266  02432H  0E7EEH      b        -36 -> 9234
  9268  02434H  09800H      ldr      r0,[sp]
  9270  02436H  03001H      adds     r0,#1
  9272  02438H  09000H      str      r0,[sp]
  9274  0243AH  0E7A1H      b        -190 -> 9088
  9276  0243CH  02000H      movs     r0,#0
  9278  0243EH  09000H      str      r0,[sp]
  9280  02440H  09800H      ldr      r0,[sp]
  9282  02442H  02802H      cmp      r0,#2
  9284  02444H  0DB01H      blt.n    2 -> 9290
  9286  02446H  0E041H      b        130 -> 9420
  9288  02448H  046C0H      nop
  9290  0244AH  09800H      ldr      r0,[sp]
  9292  0244CH  02802H      cmp      r0,#2
  9294  0244EH  0D301H      bcc.n    2 -> 9300
  9296  02450H  0DF01H      svc      1
  9298  02452H  00193H      <LineNo: 403>
  9300  02454H  04925H      ldr      r1,[pc,#148] -> 9452
  9302  02456H  022C8H      movs     r2,#200
  9304  02458H  04350H      muls     r0,r2
  9306  0245AH  01808H      adds     r0,r1,r0
  9308  0245CH  04921H      ldr      r1,[pc,#132] -> 9444
  9310  0245EH  04479H      add      r1,pc
  9312  02460H  022C0H      movs     r2,#192
  9314  02462H  05081H      str      r1,[r0,r2]
  9316  02464H  09800H      ldr      r0,[sp]
  9318  02466H  02802H      cmp      r0,#2
  9320  02468H  0D301H      bcc.n    2 -> 9326
  9322  0246AH  0DF01H      svc      1
  9324  0246CH  00194H      <LineNo: 404>
  9326  0246EH  0491FH      ldr      r1,[pc,#124] -> 9452
  9328  02470H  022C8H      movs     r2,#200
  9330  02472H  04350H      muls     r0,r2
  9332  02474H  01808H      adds     r0,r1,r0
  9334  02476H  02101H      movs     r1,#1
  9336  02478H  022C4H      movs     r2,#196
  9338  0247AH  05481H      strb     r1,[r0,r2]
  9340  0247CH  09800H      ldr      r0,[sp]
  9342  0247EH  02802H      cmp      r0,#2
  9344  02480H  0D301H      bcc.n    2 -> 9350
  9346  02482H  0DF01H      svc      1
  9348  02484H  00195H      <LineNo: 405>
  9350  02486H  04919H      ldr      r1,[pc,#100] -> 9452
  9352  02488H  022C8H      movs     r2,#200
  9354  0248AH  04350H      muls     r0,r2
  9356  0248CH  01808H      adds     r0,r1,r0
  9358  0248EH  02101H      movs     r1,#1
  9360  02490H  022C6H      movs     r2,#198
  9362  02492H  05481H      strb     r1,[r0,r2]
  9364  02494H  09800H      ldr      r0,[sp]
  9366  02496H  02802H      cmp      r0,#2
  9368  02498H  0D301H      bcc.n    2 -> 9374
  9370  0249AH  0DF01H      svc      1
  9372  0249CH  00196H      <LineNo: 406>
  9374  0249EH  04913H      ldr      r1,[pc,#76] -> 9452
  9376  024A0H  022C8H      movs     r2,#200
  9378  024A2H  04350H      muls     r0,r2
  9380  024A4H  01808H      adds     r0,r1,r0
  9382  024A6H  02101H      movs     r1,#1
  9384  024A8H  022C7H      movs     r2,#199
  9386  024AAH  05481H      strb     r1,[r0,r2]
  9388  024ACH  09800H      ldr      r0,[sp]
  9390  024AEH  02802H      cmp      r0,#2
  9392  024B0H  0D301H      bcc.n    2 -> 9398
  9394  024B2H  0DF01H      svc      1
  9396  024B4H  00197H      <LineNo: 407>
  9398  024B6H  0490DH      ldr      r1,[pc,#52] -> 9452
  9400  024B8H  022C8H      movs     r2,#200
  9402  024BAH  04350H      muls     r0,r2
  9404  024BCH  01808H      adds     r0,r1,r0
  9406  024BEH  02101H      movs     r1,#1
  9408  024C0H  022C5H      movs     r2,#197
  9410  024C2H  05481H      strb     r1,[r0,r2]
  9412  024C4H  09800H      ldr      r0,[sp]
  9414  024C6H  03001H      adds     r0,#1
  9416  024C8H  09000H      str      r0,[sp]
  9418  024CAH  0E7B9H      b        -142 -> 9280
  9420  024CCH  0B004H      add      sp,#16
  9422  024CEH  0BD00H      pop      { pc }
  9424  024D0H  0E000ED08H
  9428  024D4H  -690
  9432  024D8H  -706
  9436  024DCH  -1190
  9440  024E0H  -754
  9444  024E4H  -254
  9448  024E8H  02002FF98H
  9452  024ECH  02002FCD0H

PROCEDURE RuntimeErrors..init:
  9456  024F0H  0B500H      push     { lr }
  9458  024F2H  0F7FFFF41H  bl.w     RuntimeErrors.init
  9462  024F6H  0E000H      b        0 -> 9466
  9464  024F8H  0019DH      <LineNo: 413>
  9466  024FAH  0BD00H      pop      { pc }

MODULE TextIO:
  9468  024FCH  0
  9472  02500H  0
  9476  02504H  0
  9480  02508H  0
  9484  0250CH  0
  9488  02510H  0
  9492  02514H  12
  9496  02518H  0
  9500  0251CH  0
  9504  02520H  0
  9508  02524H  0
  9512  02528H  8
  9516  0252CH  0
  9520  02530H  0
  9524  02534H  0
  9528  02538H  0

PROCEDURE TextIO.OpenWriter:
  9532  0253CH  0B507H      push     { r0, r1, r2, lr }
  9534  0253EH  09800H      ldr      r0,[sp]
  9536  02540H  02800H      cmp      r0,#0
  9538  02542H  0D101H      bne.n    2 -> 9544
  9540  02544H  0DF65H      svc      101
  9542  02546H  00032H      <LineNo: 50>
  9544  02548H  09801H      ldr      r0,[sp,#4]
  9546  0254AH  09900H      ldr      r1,[sp]
  9548  0254CH  06008H      str      r0,[r1]
  9550  0254EH  09802H      ldr      r0,[sp,#8]
  9552  02550H  09900H      ldr      r1,[sp]
  9554  02552H  06048H      str      r0,[r1,#4]
  9556  02554H  02000H      movs     r0,#0
  9558  02556H  09900H      ldr      r1,[sp]
  9560  02558H  06088H      str      r0,[r1,#8]
  9562  0255AH  0B003H      add      sp,#12
  9564  0255CH  0BD00H      pop      { pc }
  9566  0255EH  046C0H      nop

PROCEDURE TextIO.InstallFlushOutProc:
  9568  02560H  0B503H      push     { r0, r1, lr }
  9570  02562H  09800H      ldr      r0,[sp]
  9572  02564H  02800H      cmp      r0,#0
  9574  02566H  0D101H      bne.n    2 -> 9580
  9576  02568H  0DF65H      svc      101
  9578  0256AH  0003BH      <LineNo: 59>
  9580  0256CH  09801H      ldr      r0,[sp,#4]
  9582  0256EH  09900H      ldr      r1,[sp]
  9584  02570H  06088H      str      r0,[r1,#8]
  9586  02572H  0B002H      add      sp,#8
  9588  02574H  0BD00H      pop      { pc }
  9590  02576H  046C0H      nop

PROCEDURE TextIO.OpenReader:
  9592  02578H  0B507H      push     { r0, r1, r2, lr }
  9594  0257AH  09800H      ldr      r0,[sp]
  9596  0257CH  02800H      cmp      r0,#0
  9598  0257EH  0D101H      bne.n    2 -> 9604
  9600  02580H  0DF65H      svc      101
  9602  02582H  00042H      <LineNo: 66>
  9604  02584H  09801H      ldr      r0,[sp,#4]
  9606  02586H  09900H      ldr      r1,[sp]
  9608  02588H  06008H      str      r0,[r1]
  9610  0258AH  09802H      ldr      r0,[sp,#8]
  9612  0258CH  09900H      ldr      r1,[sp]
  9614  0258EH  06048H      str      r0,[r1,#4]
  9616  02590H  0B003H      add      sp,#12
  9618  02592H  0BD00H      pop      { pc }

PROCEDURE TextIO..init:
  9620  02594H  0B500H      push     { lr }
  9622  02596H  0BD00H      pop      { pc }

MODULE Texts:
  9624  02598H  0
  9628  0259CH  020202020H  "    "
  9632  025A0H  020202020H  "    "
  9636  025A4H  020202020H  "    "
  9640  025A8H  020202020H  "    "
  9644  025ACH  020202020H  "    "
  9648  025B0H  020202020H  "    "
  9652  025B4H  020202020H  "    "
  9656  025B8H  020202020H  "    "
  9660  025BCH  000000000H

PROCEDURE Texts.IntToString:
  9664  025C0H  0B50FH      push     { r0, r1, r2, r3, lr }
  9666  025C2H  0B085H      sub      sp,#20
  9668  025C4H  09807H      ldr      r0,[sp,#28]
  9670  025C6H  0280CH      cmp      r0,#12
  9672  025C8H  0DA01H      bge.n    2 -> 9678
  9674  025CAH  0DF65H      svc      101
  9676  025CCH  0002DH      <LineNo: 45>
  9678  025CEH  09805H      ldr      r0,[sp,#20]
  9680  025D0H  0494FH      ldr      r1,[pc,#316] -> 10000
  9682  025D2H  042C8H      cmn      r0,r1
  9684  025D4H  0D001H      beq.n    2 -> 9690
  9686  025D6H  0E025H      b        74 -> 9764
  9688  025D8H  046C0H      nop
  9690  025DAH  0200CH      movs     r0,#12
  9692  025DCH  09907H      ldr      r1,[sp,#28]
  9694  025DEH  04281H      cmp      r1,r0
  9696  025E0H  0DA01H      bge.n    2 -> 9702
  9698  025E2H  0DF06H      svc      6
  9700  025E4H  0002FH      <LineNo: 47>
  9702  025E6H  09806H      ldr      r0,[sp,#24]
  9704  025E8H  0A100H      adr      r1,pc,#0 -> 9708
  9706  025EAH  0E005H      b        10 -> 9720
  9708  025ECH  03431322DH  "-214"
  9712  025F0H  033383437H  "7483"
  9716  025F4H  000383436H  "648"
  9720  025F8H  04B46H      ldr      r3,[pc,#280] -> 10004
  9722  025FAH  0680AH      ldr      r2,[r1]
  9724  025FCH  03104H      adds     r1,#4
  9726  025FEH  06002H      str      r2,[r0]
  9728  02600H  03004H      adds     r0,#4
  9730  02602H  0401AH      ands     r2,r3
  9732  02604H  0D1F9H      bne.n    -14 -> 9722
  9734  02606H  0200BH      movs     r0,#11
  9736  02608H  09907H      ldr      r1,[sp,#28]
  9738  0260AH  04288H      cmp      r0,r1
  9740  0260CH  0D301H      bcc.n    2 -> 9746
  9742  0260EH  0DF01H      svc      1
  9744  02610H  00030H      <LineNo: 48>
  9746  02612H  09906H      ldr      r1,[sp,#24]
  9748  02614H  01808H      adds     r0,r1,r0
  9750  02616H  02100H      movs     r1,#0
  9752  02618H  07001H      strb     r1,[r0]
  9754  0261AH  0200BH      movs     r0,#11
  9756  0261CH  09908H      ldr      r1,[sp,#32]
  9758  0261EH  06008H      str      r0,[r1]
  9760  02620H  0E074H      b        232 -> 9996
  9762  02622H  046C0H      nop
  9764  02624H  02000H      movs     r0,#0
  9766  02626H  09000H      str      r0,[sp]
  9768  02628H  09805H      ldr      r0,[sp,#20]
  9770  0262AH  02800H      cmp      r0,#0
  9772  0262CH  0DB01H      blt.n    2 -> 9778
  9774  0262EH  0E010H      b        32 -> 9810
  9776  02630H  046C0H      nop
  9778  02632H  09805H      ldr      r0,[sp,#20]
  9780  02634H  04240H      rsbs     r0,r0,#0
  9782  02636H  09005H      str      r0,[sp,#20]
  9784  02638H  09800H      ldr      r0,[sp]
  9786  0263AH  09907H      ldr      r1,[sp,#28]
  9788  0263CH  04288H      cmp      r0,r1
  9790  0263EH  0D301H      bcc.n    2 -> 9796
  9792  02640H  0DF01H      svc      1
  9794  02642H  00036H      <LineNo: 54>
  9796  02644H  09906H      ldr      r1,[sp,#24]
  9798  02646H  01808H      adds     r0,r1,r0
  9800  02648H  0212DH      movs     r1,#45
  9802  0264AH  07001H      strb     r1,[r0]
  9804  0264CH  09800H      ldr      r0,[sp]
  9806  0264EH  03001H      adds     r0,#1
  9808  02650H  09000H      str      r0,[sp]
  9810  02652H  02000H      movs     r0,#0
  9812  02654H  09001H      str      r0,[sp,#4]
  9814  02656H  09801H      ldr      r0,[sp,#4]
  9816  02658H  0280AH      cmp      r0,#10
  9818  0265AH  0D301H      bcc.n    2 -> 9824
  9820  0265CH  0DF01H      svc      1
  9822  0265EH  0003BH      <LineNo: 59>
  9824  02660H  04669H      mov      r1,sp
  9826  02662H  01808H      adds     r0,r1,r0
  9828  02664H  09905H      ldr      r1,[sp,#20]
  9830  02666H  0220AH      movs     r2,#10
  9832  02668H  02501H      movs     r5,#1
  9834  0266AH  007EDH      lsls     r5,r5,#31
  9836  0266CH  02300H      movs     r3,#0
  9838  0266EH  02400H      movs     r4,#0
  9840  02670H  00049H      lsls     r1,r1,#1
  9842  02672H  04164H      adcs     r4,r4
  9844  02674H  04294H      cmp      r4,r2
  9846  02676H  0D301H      bcc.n    2 -> 9852
  9848  02678H  0195BH      adds     r3,r3,r5
  9850  0267AH  01AA4H      subs     r4,r4,r2
  9852  0267CH  0086DH      lsrs     r5,r5,#1
  9854  0267EH  0D1F7H      bne.n    -18 -> 9840
  9856  02680H  04621H      mov      r1,r4
  9858  02682H  03130H      adds     r1,#48
  9860  02684H  07201H      strb     r1,[r0,#8]
  9862  02686H  09805H      ldr      r0,[sp,#20]
  9864  02688H  0210AH      movs     r1,#10
  9866  0268AH  02401H      movs     r4,#1
  9868  0268CH  007E4H      lsls     r4,r4,#31
  9870  0268EH  02200H      movs     r2,#0
  9872  02690H  02300H      movs     r3,#0
  9874  02692H  00040H      lsls     r0,r0,#1
  9876  02694H  0415BH      adcs     r3,r3
  9878  02696H  0428BH      cmp      r3,r1
  9880  02698H  0D301H      bcc.n    2 -> 9886
  9882  0269AH  01912H      adds     r2,r2,r4
  9884  0269CH  01A5BH      subs     r3,r3,r1
  9886  0269EH  00864H      lsrs     r4,r4,#1
  9888  026A0H  0D1F7H      bne.n    -18 -> 9874
  9890  026A2H  04610H      mov      r0,r2
  9892  026A4H  09005H      str      r0,[sp,#20]
  9894  026A6H  09801H      ldr      r0,[sp,#4]
  9896  026A8H  03001H      adds     r0,#1
  9898  026AAH  09001H      str      r0,[sp,#4]
  9900  026ACH  09805H      ldr      r0,[sp,#20]
  9902  026AEH  02800H      cmp      r0,#0
  9904  026B0H  0D1D1H      bne.n    -94 -> 9814
  9906  026B2H  09801H      ldr      r0,[sp,#4]
  9908  026B4H  03801H      subs     r0,#1
  9910  026B6H  09001H      str      r0,[sp,#4]
  9912  026B8H  09801H      ldr      r0,[sp,#4]
  9914  026BAH  02800H      cmp      r0,#0
  9916  026BCH  0DA01H      bge.n    2 -> 9922
  9918  026BEH  0E018H      b        48 -> 9970
  9920  026C0H  046C0H      nop
  9922  026C2H  09800H      ldr      r0,[sp]
  9924  026C4H  09907H      ldr      r1,[sp,#28]
  9926  026C6H  04288H      cmp      r0,r1
  9928  026C8H  0D301H      bcc.n    2 -> 9934
  9930  026CAH  0DF01H      svc      1
  9932  026CCH  00041H      <LineNo: 65>
  9934  026CEH  09906H      ldr      r1,[sp,#24]
  9936  026D0H  01808H      adds     r0,r1,r0
  9938  026D2H  09901H      ldr      r1,[sp,#4]
  9940  026D4H  0290AH      cmp      r1,#10
  9942  026D6H  0D301H      bcc.n    2 -> 9948
  9944  026D8H  0DF01H      svc      1
  9946  026DAH  00041H      <LineNo: 65>
  9948  026DCH  0466AH      mov      r2,sp
  9950  026DEH  01851H      adds     r1,r2,r1
  9952  026E0H  07A09H      ldrb     r1,[r1,#8]
  9954  026E2H  07001H      strb     r1,[r0]
  9956  026E4H  09801H      ldr      r0,[sp,#4]
  9958  026E6H  03801H      subs     r0,#1
  9960  026E8H  09001H      str      r0,[sp,#4]
  9962  026EAH  09800H      ldr      r0,[sp]
  9964  026ECH  03001H      adds     r0,#1
  9966  026EEH  09000H      str      r0,[sp]
  9968  026F0H  0E7E2H      b        -60 -> 9912
  9970  026F2H  09800H      ldr      r0,[sp]
  9972  026F4H  09907H      ldr      r1,[sp,#28]
  9974  026F6H  04288H      cmp      r0,r1
  9976  026F8H  0D301H      bcc.n    2 -> 9982
  9978  026FAH  0DF01H      svc      1
  9980  026FCH  00044H      <LineNo: 68>
  9982  026FEH  09906H      ldr      r1,[sp,#24]
  9984  02700H  01808H      adds     r0,r1,r0
  9986  02702H  02100H      movs     r1,#0
  9988  02704H  07001H      strb     r1,[r0]
  9990  02706H  09800H      ldr      r0,[sp]
  9992  02708H  09908H      ldr      r1,[sp,#32]
  9994  0270AH  06008H      str      r0,[r1]
  9996  0270CH  0B009H      add      sp,#36
  9998  0270EH  0BD00H      pop      { pc }
 10000  02710H  080000000H
 10004  02714H  0FF000000H

PROCEDURE Texts.IntToHexString:
 10008  02718H  0B50FH      push     { r0, r1, r2, r3, lr }
 10010  0271AH  0B086H      sub      sp,#24
 10012  0271CH  09808H      ldr      r0,[sp,#32]
 10014  0271EH  0280AH      cmp      r0,#10
 10016  02720H  0DA01H      bge.n    2 -> 10022
 10018  02722H  0DF65H      svc      101
 10020  02724H  0004DH      <LineNo: 77>
 10022  02726H  02000H      movs     r0,#0
 10024  02728H  09000H      str      r0,[sp]
 10026  0272AH  09806H      ldr      r0,[sp,#24]
 10028  0272CH  00700H      lsls     r0,r0,#28
 10030  0272EH  00F00H      lsrs     r0,r0,#28
 10032  02730H  09002H      str      r0,[sp,#8]
 10034  02732H  09802H      ldr      r0,[sp,#8]
 10036  02734H  0280AH      cmp      r0,#10
 10038  02736H  0DB01H      blt.n    2 -> 10044
 10040  02738H  0E00CH      b        24 -> 10068
 10042  0273AH  046C0H      nop
 10044  0273CH  09800H      ldr      r0,[sp]
 10046  0273EH  0280AH      cmp      r0,#10
 10048  02740H  0D301H      bcc.n    2 -> 10054
 10050  02742H  0DF01H      svc      1
 10052  02744H  00052H      <LineNo: 82>
 10054  02746H  04669H      mov      r1,sp
 10056  02748H  01808H      adds     r0,r1,r0
 10058  0274AH  09902H      ldr      r1,[sp,#8]
 10060  0274CH  03130H      adds     r1,#48
 10062  0274EH  07301H      strb     r1,[r0,#12]
 10064  02750H  0E00BH      b        22 -> 10090
 10066  02752H  046C0H      nop
 10068  02754H  09800H      ldr      r0,[sp]
 10070  02756H  0280AH      cmp      r0,#10
 10072  02758H  0D301H      bcc.n    2 -> 10078
 10074  0275AH  0DF01H      svc      1
 10076  0275CH  00054H      <LineNo: 84>
 10078  0275EH  04669H      mov      r1,sp
 10080  02760H  01808H      adds     r0,r1,r0
 10082  02762H  09902H      ldr      r1,[sp,#8]
 10084  02764H  0390AH      subs     r1,#10
 10086  02766H  03141H      adds     r1,#65
 10088  02768H  07301H      strb     r1,[r0,#12]
 10090  0276AH  09806H      ldr      r0,[sp,#24]
 10092  0276CH  01100H      asrs     r0,r0,#4
 10094  0276EH  09006H      str      r0,[sp,#24]
 10096  02770H  09800H      ldr      r0,[sp]
 10098  02772H  03001H      adds     r0,#1
 10100  02774H  09000H      str      r0,[sp]
 10102  02776H  09800H      ldr      r0,[sp]
 10104  02778H  02808H      cmp      r0,#8
 10106  0277AH  0D1D6H      bne.n    -84 -> 10026
 10108  0277CH  09800H      ldr      r0,[sp]
 10110  0277EH  03801H      subs     r0,#1
 10112  02780H  09000H      str      r0,[sp]
 10114  02782H  02000H      movs     r0,#0
 10116  02784H  09001H      str      r0,[sp,#4]
 10118  02786H  09800H      ldr      r0,[sp]
 10120  02788H  02800H      cmp      r0,#0
 10122  0278AH  0DA01H      bge.n    2 -> 10128
 10124  0278CH  0E018H      b        48 -> 10176
 10126  0278EH  046C0H      nop
 10128  02790H  09801H      ldr      r0,[sp,#4]
 10130  02792H  09908H      ldr      r1,[sp,#32]
 10132  02794H  04288H      cmp      r0,r1
 10134  02796H  0D301H      bcc.n    2 -> 10140
 10136  02798H  0DF01H      svc      1
 10138  0279AH  0005BH      <LineNo: 91>
 10140  0279CH  09907H      ldr      r1,[sp,#28]
 10142  0279EH  01808H      adds     r0,r1,r0
 10144  027A0H  09900H      ldr      r1,[sp]
 10146  027A2H  0290AH      cmp      r1,#10
 10148  027A4H  0D301H      bcc.n    2 -> 10154
 10150  027A6H  0DF01H      svc      1
 10152  027A8H  0005BH      <LineNo: 91>
 10154  027AAH  0466AH      mov      r2,sp
 10156  027ACH  01851H      adds     r1,r2,r1
 10158  027AEH  07B09H      ldrb     r1,[r1,#12]
 10160  027B0H  07001H      strb     r1,[r0]
 10162  027B2H  09800H      ldr      r0,[sp]
 10164  027B4H  03801H      subs     r0,#1
 10166  027B6H  09000H      str      r0,[sp]
 10168  027B8H  09801H      ldr      r0,[sp,#4]
 10170  027BAH  03001H      adds     r0,#1
 10172  027BCH  09001H      str      r0,[sp,#4]
 10174  027BEH  0E7E2H      b        -60 -> 10118
 10176  027C0H  02008H      movs     r0,#8
 10178  027C2H  09908H      ldr      r1,[sp,#32]
 10180  027C4H  04288H      cmp      r0,r1
 10182  027C6H  0D301H      bcc.n    2 -> 10188
 10184  027C8H  0DF01H      svc      1
 10186  027CAH  0005EH      <LineNo: 94>
 10188  027CCH  09907H      ldr      r1,[sp,#28]
 10190  027CEH  01808H      adds     r0,r1,r0
 10192  027D0H  02148H      movs     r1,#72
 10194  027D2H  07001H      strb     r1,[r0]
 10196  027D4H  02009H      movs     r0,#9
 10198  027D6H  09908H      ldr      r1,[sp,#32]
 10200  027D8H  04288H      cmp      r0,r1
 10202  027DAH  0D301H      bcc.n    2 -> 10208
 10204  027DCH  0DF01H      svc      1
 10206  027DEH  0005FH      <LineNo: 95>
 10208  027E0H  09907H      ldr      r1,[sp,#28]
 10210  027E2H  01808H      adds     r0,r1,r0
 10212  027E4H  02100H      movs     r1,#0
 10214  027E6H  07001H      strb     r1,[r0]
 10216  027E8H  02009H      movs     r0,#9
 10218  027EAH  09909H      ldr      r1,[sp,#36]
 10220  027ECH  06008H      str      r0,[r1]
 10222  027EEH  0B00AH      add      sp,#40
 10224  027F0H  0BD00H      pop      { pc }
 10226  027F2H  046C0H      nop

PROCEDURE Texts.IntToBinString:
 10228  027F4H  0B50FH      push     { r0, r1, r2, r3, lr }
 10230  027F6H  0B084H      sub      sp,#16
 10232  027F8H  09806H      ldr      r0,[sp,#24]
 10234  027FAH  02824H      cmp      r0,#36
 10236  027FCH  0DA01H      bge.n    2 -> 10242
 10238  027FEH  0DF65H      svc      101
 10240  02800H  00069H      <LineNo: 105>
 10242  02802H  02000H      movs     r0,#0
 10244  02804H  09002H      str      r0,[sp,#8]
 10246  02806H  02000H      movs     r0,#0
 10248  02808H  09000H      str      r0,[sp]
 10250  0280AH  09800H      ldr      r0,[sp]
 10252  0280CH  02803H      cmp      r0,#3
 10254  0280EH  0DD01H      ble.n    2 -> 10260
 10256  02810H  0E043H      b        134 -> 10394
 10258  02812H  046C0H      nop
 10260  02814H  09804H      ldr      r0,[sp,#16]
 10262  02816H  00E00H      lsrs     r0,r0,#24
 10264  02818H  09003H      str      r0,[sp,#12]
 10266  0281AH  09804H      ldr      r0,[sp,#16]
 10268  0281CH  00200H      lsls     r0,r0,#8
 10270  0281EH  09004H      str      r0,[sp,#16]
 10272  02820H  02007H      movs     r0,#7
 10274  02822H  09001H      str      r0,[sp,#4]
 10276  02824H  09801H      ldr      r0,[sp,#4]
 10278  02826H  02800H      cmp      r0,#0
 10280  02828H  0DA01H      bge.n    2 -> 10286
 10282  0282AH  0E025H      b        74 -> 10360
 10284  0282CH  046C0H      nop
 10286  0282EH  09803H      ldr      r0,[sp,#12]
 10288  02830H  09901H      ldr      r1,[sp,#4]
 10290  02832H  02201H      movs     r2,#1
 10292  02834H  0408AH      lsls     r2,r1
 10294  02836H  04210H      tst      r0,r2
 10296  02838H  0D101H      bne.n    2 -> 10302
 10298  0283AH  0E00CH      b        24 -> 10326
 10300  0283CH  046C0H      nop
 10302  0283EH  09802H      ldr      r0,[sp,#8]
 10304  02840H  09906H      ldr      r1,[sp,#24]
 10306  02842H  04288H      cmp      r0,r1
 10308  02844H  0D301H      bcc.n    2 -> 10314
 10310  02846H  0DF01H      svc      1
 10312  02848H  0006FH      <LineNo: 111>
 10314  0284AH  09905H      ldr      r1,[sp,#20]
 10316  0284CH  01808H      adds     r0,r1,r0
 10318  0284EH  02131H      movs     r1,#49
 10320  02850H  07001H      strb     r1,[r0]
 10322  02852H  0E00AH      b        20 -> 10346
 10324  02854H  046C0H      nop
 10326  02856H  09802H      ldr      r0,[sp,#8]
 10328  02858H  09906H      ldr      r1,[sp,#24]
 10330  0285AH  04288H      cmp      r0,r1
 10332  0285CH  0D301H      bcc.n    2 -> 10338
 10334  0285EH  0DF01H      svc      1
 10336  02860H  0006FH      <LineNo: 111>
 10338  02862H  09905H      ldr      r1,[sp,#20]
 10340  02864H  01808H      adds     r0,r1,r0
 10342  02866H  02130H      movs     r1,#48
 10344  02868H  07001H      strb     r1,[r0]
 10346  0286AH  09802H      ldr      r0,[sp,#8]
 10348  0286CH  03001H      adds     r0,#1
 10350  0286EH  09002H      str      r0,[sp,#8]
 10352  02870H  09801H      ldr      r0,[sp,#4]
 10354  02872H  03801H      subs     r0,#1
 10356  02874H  09001H      str      r0,[sp,#4]
 10358  02876H  0E7D5H      b        -86 -> 10276
 10360  02878H  09802H      ldr      r0,[sp,#8]
 10362  0287AH  09906H      ldr      r1,[sp,#24]
 10364  0287CH  04288H      cmp      r0,r1
 10366  0287EH  0D301H      bcc.n    2 -> 10372
 10368  02880H  0DF01H      svc      1
 10370  02882H  00072H      <LineNo: 114>
 10372  02884H  09905H      ldr      r1,[sp,#20]
 10374  02886H  01808H      adds     r0,r1,r0
 10376  02888H  02120H      movs     r1,#32
 10378  0288AH  07001H      strb     r1,[r0]
 10380  0288CH  09802H      ldr      r0,[sp,#8]
 10382  0288EH  03001H      adds     r0,#1
 10384  02890H  09002H      str      r0,[sp,#8]
 10386  02892H  09800H      ldr      r0,[sp]
 10388  02894H  03001H      adds     r0,#1
 10390  02896H  09000H      str      r0,[sp]
 10392  02898H  0E7B7H      b        -146 -> 10250
 10394  0289AH  02023H      movs     r0,#35
 10396  0289CH  09906H      ldr      r1,[sp,#24]
 10398  0289EH  04288H      cmp      r0,r1
 10400  028A0H  0D301H      bcc.n    2 -> 10406
 10402  028A2H  0DF01H      svc      1
 10404  028A4H  00075H      <LineNo: 117>
 10406  028A6H  09905H      ldr      r1,[sp,#20]
 10408  028A8H  01808H      adds     r0,r1,r0
 10410  028AAH  02100H      movs     r1,#0
 10412  028ACH  07001H      strb     r1,[r0]
 10414  028AEH  02023H      movs     r0,#35
 10416  028B0H  09907H      ldr      r1,[sp,#28]
 10418  028B2H  06008H      str      r0,[r1]
 10420  028B4H  0B008H      add      sp,#32
 10422  028B6H  0BD00H      pop      { pc }

PROCEDURE Texts.Write:
 10424  028B8H  0B503H      push     { r0, r1, lr }
 10426  028BAH  0B081H      sub      sp,#4
 10428  028BCH  0A802H      add      r0,sp,#8
 10430  028BEH  07800H      ldrb     r0,[r0]
 10432  028C0H  0A900H      add      r1,sp,#0
 10434  028C2H  07008H      strb     r0,[r1]
 10436  028C4H  09801H      ldr      r0,[sp,#4]
 10438  028C6H  06800H      ldr      r0,[r0]
 10440  028C8H  04669H      mov      r1,sp
 10442  028CAH  02201H      movs     r2,#1
 10444  028CCH  02301H      movs     r3,#1
 10446  028CEH  09C01H      ldr      r4,[sp,#4]
 10448  028D0H  06864H      ldr      r4,[r4,#4]
 10450  028D2H  02C00H      cmp      r4,#0
 10452  028D4H  0D101H      bne.n    2 -> 10458
 10454  028D6H  0DF05H      svc      5
 10456  028D8H  0007FH      <LineNo: 127>
 10458  028DAH  03401H      adds     r4,#1
 10460  028DCH  047A0H      blx      r4
 10462  028DEH  0E000H      b        0 -> 10466
 10464  028E0H  0007FH      <LineNo: 127>
 10466  028E2H  0B003H      add      sp,#12
 10468  028E4H  0BD00H      pop      { pc }
 10470  028E6H  046C0H      nop

PROCEDURE Texts.WriteString:
 10472  028E8H  0B507H      push     { r0, r1, r2, lr }
 10474  028EAH  0B081H      sub      sp,#4
 10476  028ECH  02000H      movs     r0,#0
 10478  028EEH  09000H      str      r0,[sp]
 10480  028F0H  09800H      ldr      r0,[sp]
 10482  028F2H  09903H      ldr      r1,[sp,#12]
 10484  028F4H  04288H      cmp      r0,r1
 10486  028F6H  0DB01H      blt.n    2 -> 10492
 10488  028F8H  0E011H      b        34 -> 10526
 10490  028FAH  046C0H      nop
 10492  028FCH  09800H      ldr      r0,[sp]
 10494  028FEH  09903H      ldr      r1,[sp,#12]
 10496  02900H  04288H      cmp      r0,r1
 10498  02902H  0D301H      bcc.n    2 -> 10504
 10500  02904H  0DF01H      svc      1
 10502  02906H  00087H      <LineNo: 135>
 10504  02908H  09902H      ldr      r1,[sp,#8]
 10506  0290AH  01808H      adds     r0,r1,r0
 10508  0290CH  07800H      ldrb     r0,[r0]
 10510  0290EH  02800H      cmp      r0,#0
 10512  02910H  0D101H      bne.n    2 -> 10518
 10514  02912H  0E004H      b        8 -> 10526
 10516  02914H  046C0H      nop
 10518  02916H  09800H      ldr      r0,[sp]
 10520  02918H  03001H      adds     r0,#1
 10522  0291AH  09000H      str      r0,[sp]
 10524  0291CH  0E7E8H      b        -48 -> 10480
 10526  0291EH  09801H      ldr      r0,[sp,#4]
 10528  02920H  06800H      ldr      r0,[r0]
 10530  02922H  09902H      ldr      r1,[sp,#8]
 10532  02924H  09A03H      ldr      r2,[sp,#12]
 10534  02926H  09B00H      ldr      r3,[sp]
 10536  02928H  09C01H      ldr      r4,[sp,#4]
 10538  0292AH  06864H      ldr      r4,[r4,#4]
 10540  0292CH  02C00H      cmp      r4,#0
 10542  0292EH  0D101H      bne.n    2 -> 10548
 10544  02930H  0DF05H      svc      5
 10546  02932H  00088H      <LineNo: 136>
 10548  02934H  03401H      adds     r4,#1
 10550  02936H  047A0H      blx      r4
 10552  02938H  0E000H      b        0 -> 10556
 10554  0293AH  00088H      <LineNo: 136>
 10556  0293CH  0B004H      add      sp,#16
 10558  0293EH  0BD00H      pop      { pc }

PROCEDURE Texts.WriteLn:
 10560  02940H  0B501H      push     { r0, lr }
 10562  02942H  09800H      ldr      r0,[sp]
 10564  02944H  06800H      ldr      r0,[r0]
 10566  02946H  04907H      ldr      r1,[pc,#28] -> 10596
 10568  02948H  02202H      movs     r2,#2
 10570  0294AH  02302H      movs     r3,#2
 10572  0294CH  09C00H      ldr      r4,[sp]
 10574  0294EH  06864H      ldr      r4,[r4,#4]
 10576  02950H  02C00H      cmp      r4,#0
 10578  02952H  0D101H      bne.n    2 -> 10584
 10580  02954H  0DF05H      svc      5
 10582  02956H  0008EH      <LineNo: 142>
 10584  02958H  03401H      adds     r4,#1
 10586  0295AH  047A0H      blx      r4
 10588  0295CH  0E000H      b        0 -> 10592
 10590  0295EH  0008EH      <LineNo: 142>
 10592  02960H  0B001H      add      sp,#4
 10594  02962H  0BD00H      pop      { pc }
 10596  02964H  02002FCCCH

PROCEDURE Texts.writeNumString:
 10600  02968H  0B51FH      push     { r0, r1, r2, r3, r4, lr }
 10602  0296AH  09804H      ldr      r0,[sp,#16]
 10604  0296CH  02820H      cmp      r0,#32
 10606  0296EH  0DC01H      bgt.n    2 -> 10612
 10608  02970H  0E002H      b        4 -> 10616
 10610  02972H  046C0H      nop
 10612  02974H  02020H      movs     r0,#32
 10614  02976H  09004H      str      r0,[sp,#16]
 10616  02978H  09804H      ldr      r0,[sp,#16]
 10618  0297AH  02800H      cmp      r0,#0
 10620  0297CH  0DC01H      bgt.n    2 -> 10626
 10622  0297EH  0E012H      b        36 -> 10662
 10624  02980H  046C0H      nop
 10626  02982H  09800H      ldr      r0,[sp]
 10628  02984H  06800H      ldr      r0,[r0]
 10630  02986H  046C0H      nop
 10632  02988H  0490FH      ldr      r1,[pc,#60] -> 10696
 10634  0298AH  0467AH      mov      r2,pc
 10636  0298CH  01889H      adds     r1,r1,r2
 10638  0298EH  02221H      movs     r2,#33
 10640  02990H  09B04H      ldr      r3,[sp,#16]
 10642  02992H  09C00H      ldr      r4,[sp]
 10644  02994H  06864H      ldr      r4,[r4,#4]
 10646  02996H  02C00H      cmp      r4,#0
 10648  02998H  0D101H      bne.n    2 -> 10654
 10650  0299AH  0DF05H      svc      5
 10652  0299CH  00096H      <LineNo: 150>
 10654  0299EH  03401H      adds     r4,#1
 10656  029A0H  047A0H      blx      r4
 10658  029A2H  0E000H      b        0 -> 10662
 10660  029A4H  00096H      <LineNo: 150>
 10662  029A6H  09800H      ldr      r0,[sp]
 10664  029A8H  06800H      ldr      r0,[r0]
 10666  029AAH  09901H      ldr      r1,[sp,#4]
 10668  029ACH  09A02H      ldr      r2,[sp,#8]
 10670  029AEH  09B03H      ldr      r3,[sp,#12]
 10672  029B0H  09C00H      ldr      r4,[sp]
 10674  029B2H  06864H      ldr      r4,[r4,#4]
 10676  029B4H  02C00H      cmp      r4,#0
 10678  029B6H  0D101H      bne.n    2 -> 10684
 10680  029B8H  0DF05H      svc      5
 10682  029BAH  00098H      <LineNo: 152>
 10684  029BCH  03401H      adds     r4,#1
 10686  029BEH  047A0H      blx      r4
 10688  029C0H  0E000H      b        0 -> 10692
 10690  029C2H  00098H      <LineNo: 152>
 10692  029C4H  0B005H      add      sp,#20
 10694  029C6H  0BD00H      pop      { pc }
 10696  029C8H  -1010

PROCEDURE Texts.WriteInt:
 10700  029CCH  0B507H      push     { r0, r1, r2, lr }
 10702  029CEH  0B084H      sub      sp,#16
 10704  029D0H  09805H      ldr      r0,[sp,#20]
 10706  029D2H  04669H      mov      r1,sp
 10708  029D4H  0220CH      movs     r2,#12
 10710  029D6H  0AB03H      add      r3,sp,#12
 10712  029D8H  0F7FFFDF2H  bl.w     Texts.IntToString
 10716  029DCH  0E000H      b        0 -> 10720
 10718  029DEH  000A2H      <LineNo: 162>
 10720  029E0H  09804H      ldr      r0,[sp,#16]
 10722  029E2H  04669H      mov      r1,sp
 10724  029E4H  0220CH      movs     r2,#12
 10726  029E6H  09B03H      ldr      r3,[sp,#12]
 10728  029E8H  09C06H      ldr      r4,[sp,#24]
 10730  029EAH  09D03H      ldr      r5,[sp,#12]
 10732  029ECH  01B64H      subs     r4,r4,r5
 10734  029EEH  0F7FFFFBBH  bl.w     Texts.writeNumString
 10738  029F2H  0E000H      b        0 -> 10742
 10740  029F4H  000A3H      <LineNo: 163>
 10742  029F6H  0B007H      add      sp,#28
 10744  029F8H  0BD00H      pop      { pc }
 10746  029FAH  046C0H      nop

PROCEDURE Texts.WriteHex:
 10748  029FCH  0B507H      push     { r0, r1, r2, lr }
 10750  029FEH  0B084H      sub      sp,#16
 10752  02A00H  09805H      ldr      r0,[sp,#20]
 10754  02A02H  04669H      mov      r1,sp
 10756  02A04H  0220CH      movs     r2,#12
 10758  02A06H  0AB03H      add      r3,sp,#12
 10760  02A08H  0F7FFFE86H  bl.w     Texts.IntToHexString
 10764  02A0CH  0E000H      b        0 -> 10768
 10766  02A0EH  000AAH      <LineNo: 170>
 10768  02A10H  09804H      ldr      r0,[sp,#16]
 10770  02A12H  04669H      mov      r1,sp
 10772  02A14H  0220CH      movs     r2,#12
 10774  02A16H  09B03H      ldr      r3,[sp,#12]
 10776  02A18H  09C06H      ldr      r4,[sp,#24]
 10778  02A1AH  09D03H      ldr      r5,[sp,#12]
 10780  02A1CH  01B64H      subs     r4,r4,r5
 10782  02A1EH  0F7FFFFA3H  bl.w     Texts.writeNumString
 10786  02A22H  0E000H      b        0 -> 10790
 10788  02A24H  000ABH      <LineNo: 171>
 10790  02A26H  0B007H      add      sp,#28
 10792  02A28H  0BD00H      pop      { pc }
 10794  02A2AH  046C0H      nop

PROCEDURE Texts.WriteBin:
 10796  02A2CH  0B507H      push     { r0, r1, r2, lr }
 10798  02A2EH  0B08AH      sub      sp,#40
 10800  02A30H  0980BH      ldr      r0,[sp,#44]
 10802  02A32H  04669H      mov      r1,sp
 10804  02A34H  02224H      movs     r2,#36
 10806  02A36H  0AB09H      add      r3,sp,#36
 10808  02A38H  0F7FFFEDCH  bl.w     Texts.IntToBinString
 10812  02A3CH  0E000H      b        0 -> 10816
 10814  02A3EH  000B2H      <LineNo: 178>
 10816  02A40H  0980AH      ldr      r0,[sp,#40]
 10818  02A42H  04669H      mov      r1,sp
 10820  02A44H  02224H      movs     r2,#36
 10822  02A46H  09B09H      ldr      r3,[sp,#36]
 10824  02A48H  09C0CH      ldr      r4,[sp,#48]
 10826  02A4AH  09D09H      ldr      r5,[sp,#36]
 10828  02A4CH  01B64H      subs     r4,r4,r5
 10830  02A4EH  0F7FFFF8BH  bl.w     Texts.writeNumString
 10834  02A52H  0E000H      b        0 -> 10838
 10836  02A54H  000B3H      <LineNo: 179>
 10838  02A56H  0B00DH      add      sp,#52
 10840  02A58H  0BD00H      pop      { pc }
 10842  02A5AH  046C0H      nop

PROCEDURE Texts.cleanLeft:
 10844  02A5CH  0B50FH      push     { r0, r1, r2, r3, lr }
 10846  02A5EH  0B081H      sub      sp,#4
 10848  02A60H  02000H      movs     r0,#0
 10850  02A62H  09903H      ldr      r1,[sp,#12]
 10852  02A64H  06008H      str      r0,[r1]
 10854  02A66H  09803H      ldr      r0,[sp,#12]
 10856  02A68H  06800H      ldr      r0,[r0]
 10858  02A6AH  09902H      ldr      r1,[sp,#8]
 10860  02A6CH  04288H      cmp      r0,r1
 10862  02A6EH  0D301H      bcc.n    2 -> 10868
 10864  02A70H  0DF01H      svc      1
 10866  02A72H  000BCH      <LineNo: 188>
 10868  02A74H  09901H      ldr      r1,[sp,#4]
 10870  02A76H  01808H      adds     r0,r1,r0
 10872  02A78H  07800H      ldrb     r0,[r0]
 10874  02A7AH  02820H      cmp      r0,#32
 10876  02A7CH  0D001H      beq.n    2 -> 10882
 10878  02A7EH  0E005H      b        10 -> 10892
 10880  02A80H  046C0H      nop
 10882  02A82H  09803H      ldr      r0,[sp,#12]
 10884  02A84H  06801H      ldr      r1,[r0]
 10886  02A86H  03101H      adds     r1,#1
 10888  02A88H  06001H      str      r1,[r0]
 10890  02A8AH  0E7ECH      b        -40 -> 10854
 10892  02A8CH  09803H      ldr      r0,[sp,#12]
 10894  02A8EH  06800H      ldr      r0,[r0]
 10896  02A90H  09902H      ldr      r1,[sp,#8]
 10898  02A92H  04288H      cmp      r0,r1
 10900  02A94H  0D301H      bcc.n    2 -> 10906
 10902  02A96H  0DF01H      svc      1
 10904  02A98H  000BDH      <LineNo: 189>
 10906  02A9AH  09901H      ldr      r1,[sp,#4]
 10908  02A9CH  01808H      adds     r0,r1,r0
 10910  02A9EH  07800H      ldrb     r0,[r0]
 10912  02AA0H  0A900H      add      r1,sp,#0
 10914  02AA2H  07008H      strb     r0,[r1]
 10916  02AA4H  0A800H      add      r0,sp,#0
 10918  02AA6H  07800H      ldrb     r0,[r0]
 10920  02AA8H  0282DH      cmp      r0,#45
 10922  02AAAH  0D001H      beq.n    2 -> 10928
 10924  02AACH  02000H      movs     r0,#0
 10926  02AAEH  0E000H      b        0 -> 10930
 10928  02AB0H  02001H      movs     r0,#1
 10930  02AB2H  09904H      ldr      r1,[sp,#16]
 10932  02AB4H  07008H      strb     r0,[r1]
 10934  02AB6H  0A800H      add      r0,sp,#0
 10936  02AB8H  07800H      ldrb     r0,[r0]
 10938  02ABAH  0282DH      cmp      r0,#45
 10940  02ABCH  0D101H      bne.n    2 -> 10946
 10942  02ABEH  0E006H      b        12 -> 10958
 10944  02AC0H  046C0H      nop
 10946  02AC2H  0A800H      add      r0,sp,#0
 10948  02AC4H  07800H      ldrb     r0,[r0]
 10950  02AC6H  0282BH      cmp      r0,#43
 10952  02AC8H  0D001H      beq.n    2 -> 10958
 10954  02ACAH  0E004H      b        8 -> 10966
 10956  02ACCH  046C0H      nop
 10958  02ACEH  09803H      ldr      r0,[sp,#12]
 10960  02AD0H  06801H      ldr      r1,[r0]
 10962  02AD2H  03101H      adds     r1,#1
 10964  02AD4H  06001H      str      r1,[r0]
 10966  02AD6H  09803H      ldr      r0,[sp,#12]
 10968  02AD8H  06800H      ldr      r0,[r0]
 10970  02ADAH  09902H      ldr      r1,[sp,#8]
 10972  02ADCH  04288H      cmp      r0,r1
 10974  02ADEH  0D301H      bcc.n    2 -> 10980
 10976  02AE0H  0DF01H      svc      1
 10978  02AE2H  000C0H      <LineNo: 192>
 10980  02AE4H  09901H      ldr      r1,[sp,#4]
 10982  02AE6H  01808H      adds     r0,r1,r0
 10984  02AE8H  07800H      ldrb     r0,[r0]
 10986  02AEAH  02820H      cmp      r0,#32
 10988  02AECH  0D001H      beq.n    2 -> 10994
 10990  02AEEH  0E005H      b        10 -> 11004
 10992  02AF0H  046C0H      nop
 10994  02AF2H  09803H      ldr      r0,[sp,#12]
 10996  02AF4H  06801H      ldr      r1,[r0]
 10998  02AF6H  03101H      adds     r1,#1
 11000  02AF8H  06001H      str      r1,[r0]
 11002  02AFAH  0E7ECH      b        -40 -> 10966
 11004  02AFCH  09803H      ldr      r0,[sp,#12]
 11006  02AFEH  06800H      ldr      r0,[r0]
 11008  02B00H  09902H      ldr      r1,[sp,#8]
 11010  02B02H  04288H      cmp      r0,r1
 11012  02B04H  0D301H      bcc.n    2 -> 11018
 11014  02B06H  0DF01H      svc      1
 11016  02B08H  000C1H      <LineNo: 193>
 11018  02B0AH  09901H      ldr      r1,[sp,#4]
 11020  02B0CH  01808H      adds     r0,r1,r0
 11022  02B0EH  07800H      ldrb     r0,[r0]
 11024  02B10H  02830H      cmp      r0,#48
 11026  02B12H  0D001H      beq.n    2 -> 11032
 11028  02B14H  0E005H      b        10 -> 11042
 11030  02B16H  046C0H      nop
 11032  02B18H  09803H      ldr      r0,[sp,#12]
 11034  02B1AH  06801H      ldr      r1,[r0]
 11036  02B1CH  03101H      adds     r1,#1
 11038  02B1EH  06001H      str      r1,[r0]
 11040  02B20H  0E7ECH      b        -40 -> 11004
 11042  02B22H  0B005H      add      sp,#20
 11044  02B24H  0BD00H      pop      { pc }
 11046  02B26H  046C0H      nop

PROCEDURE Texts.cleanRight:
 11048  02B28H  0B50FH      push     { r0, r1, r2, r3, lr }
 11050  02B2AH  09802H      ldr      r0,[sp,#8]
 11052  02B2CH  03801H      subs     r0,#1
 11054  02B2EH  09903H      ldr      r1,[sp,#12]
 11056  02B30H  06008H      str      r0,[r1]
 11058  02B32H  09803H      ldr      r0,[sp,#12]
 11060  02B34H  06800H      ldr      r0,[r0]
 11062  02B36H  09901H      ldr      r1,[sp,#4]
 11064  02B38H  04288H      cmp      r0,r1
 11066  02B3AH  0D301H      bcc.n    2 -> 11072
 11068  02B3CH  0DF01H      svc      1
 11070  02B3EH  000C7H      <LineNo: 199>
 11072  02B40H  09900H      ldr      r1,[sp]
 11074  02B42H  01808H      adds     r0,r1,r0
 11076  02B44H  07800H      ldrb     r0,[r0]
 11078  02B46H  02820H      cmp      r0,#32
 11080  02B48H  0D001H      beq.n    2 -> 11086
 11082  02B4AH  0E005H      b        10 -> 11096
 11084  02B4CH  046C0H      nop
 11086  02B4EH  09803H      ldr      r0,[sp,#12]
 11088  02B50H  06801H      ldr      r1,[r0]
 11090  02B52H  03901H      subs     r1,#1
 11092  02B54H  06001H      str      r1,[r0]
 11094  02B56H  0E7ECH      b        -40 -> 11058
 11096  02B58H  0B004H      add      sp,#16
 11098  02B5AH  0BD00H      pop      { pc }

PROCEDURE Texts.StrToInt:
 11100  02B5CH  0B51FH      push     { r0, r1, r2, r3, r4, lr }
 11102  02B5EH  0B084H      sub      sp,#16
 11104  02B60H  02000H      movs     r0,#0
 11106  02B62H  09908H      ldr      r1,[sp,#32]
 11108  02B64H  06008H      str      r0,[r1]
 11110  02B66H  09804H      ldr      r0,[sp,#16]
 11112  02B68H  09905H      ldr      r1,[sp,#20]
 11114  02B6AH  0466AH      mov      r2,sp
 11116  02B6CH  0AB03H      add      r3,sp,#12
 11118  02B6EH  0F7FFFF75H  bl.w     Texts.cleanLeft
 11122  02B72H  0E000H      b        0 -> 11126
 11124  02B74H  000D2H      <LineNo: 210>
 11126  02B76H  09806H      ldr      r0,[sp,#24]
 11128  02B78H  09900H      ldr      r1,[sp]
 11130  02B7AH  01A40H      subs     r0,r0,r1
 11132  02B7CH  0280AH      cmp      r0,#10
 11134  02B7EH  0DC01H      bgt.n    2 -> 11140
 11136  02B80H  0E003H      b        6 -> 11146
 11138  02B82H  046C0H      nop
 11140  02B84H  02003H      movs     r0,#3
 11142  02B86H  09908H      ldr      r1,[sp,#32]
 11144  02B88H  06008H      str      r0,[r1]
 11146  02B8AH  09808H      ldr      r0,[sp,#32]
 11148  02B8CH  06800H      ldr      r0,[r0]
 11150  02B8EH  02800H      cmp      r0,#0
 11152  02B90H  0D001H      beq.n    2 -> 11158
 11154  02B92H  0E061H      b        194 -> 11352
 11156  02B94H  046C0H      nop
 11158  02B96H  09804H      ldr      r0,[sp,#16]
 11160  02B98H  09905H      ldr      r1,[sp,#20]
 11162  02B9AH  09A06H      ldr      r2,[sp,#24]
 11164  02B9CH  0AB01H      add      r3,sp,#4
 11166  02B9EH  0F7FFFFC3H  bl.w     Texts.cleanRight
 11170  02BA2H  0E000H      b        0 -> 11174
 11172  02BA4H  000D7H      <LineNo: 215>
 11174  02BA6H  02000H      movs     r0,#0
 11176  02BA8H  09907H      ldr      r1,[sp,#28]
 11178  02BAAH  06008H      str      r0,[r1]
 11180  02BACH  09800H      ldr      r0,[sp]
 11182  02BAEH  09901H      ldr      r1,[sp,#4]
 11184  02BB0H  04288H      cmp      r0,r1
 11186  02BB2H  0DD01H      ble.n    2 -> 11192
 11188  02BB4H  0E050H      b        160 -> 11352
 11190  02BB6H  046C0H      nop
 11192  02BB8H  09808H      ldr      r0,[sp,#32]
 11194  02BBAH  06800H      ldr      r0,[r0]
 11196  02BBCH  02800H      cmp      r0,#0
 11198  02BBEH  0D001H      beq.n    2 -> 11204
 11200  02BC0H  0E04AH      b        148 -> 11352
 11202  02BC2H  046C0H      nop
 11204  02BC4H  09800H      ldr      r0,[sp]
 11206  02BC6H  09905H      ldr      r1,[sp,#20]
 11208  02BC8H  04288H      cmp      r0,r1
 11210  02BCAH  0D301H      bcc.n    2 -> 11216
 11212  02BCCH  0DF01H      svc      1
 11214  02BCEH  000DAH      <LineNo: 218>
 11216  02BD0H  09904H      ldr      r1,[sp,#16]
 11218  02BD2H  01808H      adds     r0,r1,r0
 11220  02BD4H  07800H      ldrb     r0,[r0]
 11222  02BD6H  0A903H      add      r1,sp,#12
 11224  02BD8H  07048H      strb     r0,[r1,#1]
 11226  02BDAH  0A803H      add      r0,sp,#12
 11228  02BDCH  07840H      ldrb     r0,[r0,#1]
 11230  02BDEH  02830H      cmp      r0,#48
 11232  02BE0H  0DA01H      bge.n    2 -> 11238
 11234  02BE2H  0E006H      b        12 -> 11250
 11236  02BE4H  046C0H      nop
 11238  02BE6H  0A803H      add      r0,sp,#12
 11240  02BE8H  07840H      ldrb     r0,[r0,#1]
 11242  02BEAH  02839H      cmp      r0,#57
 11244  02BECH  0DC01H      bgt.n    2 -> 11250
 11246  02BEEH  0E005H      b        10 -> 11260
 11248  02BF0H  046C0H      nop
 11250  02BF2H  02002H      movs     r0,#2
 11252  02BF4H  09908H      ldr      r1,[sp,#32]
 11254  02BF6H  06008H      str      r0,[r1]
 11256  02BF8H  0E02DH      b        90 -> 11350
 11258  02BFAH  046C0H      nop
 11260  02BFCH  0A803H      add      r0,sp,#12
 11262  02BFEH  07840H      ldrb     r0,[r0,#1]
 11264  02C00H  03830H      subs     r0,#48
 11266  02C02H  09002H      str      r0,[sp,#8]
 11268  02C04H  09807H      ldr      r0,[sp,#28]
 11270  02C06H  06800H      ldr      r0,[r0]
 11272  02C08H  0210AH      movs     r1,#10
 11274  02C0AH  04348H      muls     r0,r1
 11276  02C0CH  09902H      ldr      r1,[sp,#8]
 11278  02C0EH  01840H      adds     r0,r0,r1
 11280  02C10H  09907H      ldr      r1,[sp,#28]
 11282  02C12H  06008H      str      r0,[r1]
 11284  02C14H  09807H      ldr      r0,[sp,#28]
 11286  02C16H  06800H      ldr      r0,[r0]
 11288  02C18H  04919H      ldr      r1,[pc,#100] -> 11392
 11290  02C1AH  01A08H      subs     r0,r1,r0
 11292  02C1CH  02800H      cmp      r0,#0
 11294  02C1EH  0DB01H      blt.n    2 -> 11300
 11296  02C20H  0E016H      b        44 -> 11344
 11298  02C22H  046C0H      nop
 11300  02C24H  0A803H      add      r0,sp,#12
 11302  02C26H  07800H      ldrb     r0,[r0]
 11304  02C28H  02101H      movs     r1,#1
 11306  02C2AH  04208H      tst      r0,r1
 11308  02C2CH  0D101H      bne.n    2 -> 11314
 11310  02C2EH  0E00CH      b        24 -> 11338
 11312  02C30H  046C0H      nop
 11314  02C32H  09807H      ldr      r0,[sp,#28]
 11316  02C34H  06800H      ldr      r0,[r0]
 11318  02C36H  04913H      ldr      r1,[pc,#76] -> 11396
 11320  02C38H  042C8H      cmn      r0,r1
 11322  02C3AH  0D001H      beq.n    2 -> 11328
 11324  02C3CH  0E005H      b        10 -> 11338
 11326  02C3EH  046C0H      nop
 11328  02C40H  02000H      movs     r0,#0
 11330  02C42H  0A903H      add      r1,sp,#12
 11332  02C44H  07008H      strb     r0,[r1]
 11334  02C46H  0E003H      b        6 -> 11344
 11336  02C48H  046C0H      nop
 11338  02C4AH  02003H      movs     r0,#3
 11340  02C4CH  09908H      ldr      r1,[sp,#32]
 11342  02C4EH  06008H      str      r0,[r1]
 11344  02C50H  09800H      ldr      r0,[sp]
 11346  02C52H  03001H      adds     r0,#1
 11348  02C54H  09000H      str      r0,[sp]
 11350  02C56H  0E7A9H      b        -174 -> 11180
 11352  02C58H  09808H      ldr      r0,[sp,#32]
 11354  02C5AH  06800H      ldr      r0,[r0]
 11356  02C5CH  02800H      cmp      r0,#0
 11358  02C5EH  0D001H      beq.n    2 -> 11364
 11360  02C60H  0E00CH      b        24 -> 11388
 11362  02C62H  046C0H      nop
 11364  02C64H  0A803H      add      r0,sp,#12
 11366  02C66H  07800H      ldrb     r0,[r0]
 11368  02C68H  02101H      movs     r1,#1
 11370  02C6AH  04208H      tst      r0,r1
 11372  02C6CH  0D101H      bne.n    2 -> 11378
 11374  02C6EH  0E005H      b        10 -> 11388
 11376  02C70H  046C0H      nop
 11378  02C72H  09807H      ldr      r0,[sp,#28]
 11380  02C74H  06800H      ldr      r0,[r0]
 11382  02C76H  04240H      rsbs     r0,r0,#0
 11384  02C78H  09907H      ldr      r1,[sp,#28]
 11386  02C7AH  06008H      str      r0,[r1]
 11388  02C7CH  0B009H      add      sp,#36
 11390  02C7EH  0BD00H      pop      { pc }
 11392  02C80H  07FFFFFFFH
 11396  02C84H  080000000H

PROCEDURE Texts.ReadString:
 11400  02C88H  0B50FH      push     { r0, r1, r2, r3, lr }
 11402  02C8AH  0B081H      sub      sp,#4
 11404  02C8CH  09801H      ldr      r0,[sp,#4]
 11406  02C8EH  06800H      ldr      r0,[r0]
 11408  02C90H  09902H      ldr      r1,[sp,#8]
 11410  02C92H  09A03H      ldr      r2,[sp,#12]
 11412  02C94H  0466BH      mov      r3,sp
 11414  02C96H  09C04H      ldr      r4,[sp,#16]
 11416  02C98H  09D01H      ldr      r5,[sp,#4]
 11418  02C9AH  0686DH      ldr      r5,[r5,#4]
 11420  02C9CH  02D00H      cmp      r5,#0
 11422  02C9EH  0D101H      bne.n    2 -> 11428
 11424  02CA0H  0DF05H      svc      5
 11426  02CA2H  000FAH      <LineNo: 250>
 11428  02CA4H  03501H      adds     r5,#1
 11430  02CA6H  047A8H      blx      r5
 11432  02CA8H  0E000H      b        0 -> 11436
 11434  02CAAH  000F9H      <LineNo: 249>
 11436  02CACH  09804H      ldr      r0,[sp,#16]
 11438  02CAEH  06800H      ldr      r0,[r0]
 11440  02CB0H  02800H      cmp      r0,#0
 11442  02CB2H  0D001H      beq.n    2 -> 11448
 11444  02CB4H  0E008H      b        16 -> 11464
 11446  02CB6H  046C0H      nop
 11448  02CB8H  09800H      ldr      r0,[sp]
 11450  02CBAH  02800H      cmp      r0,#0
 11452  02CBCH  0D001H      beq.n    2 -> 11458
 11454  02CBEH  0E003H      b        6 -> 11464
 11456  02CC0H  046C0H      nop
 11458  02CC2H  02004H      movs     r0,#4
 11460  02CC4H  09904H      ldr      r1,[sp,#16]
 11462  02CC6H  06008H      str      r0,[r1]
 11464  02CC8H  0B005H      add      sp,#20
 11466  02CCAH  0BD00H      pop      { pc }

PROCEDURE Texts.ReadInt:
 11468  02CCCH  0B507H      push     { r0, r1, r2, lr }
 11470  02CCEH  0B089H      sub      sp,#36
 11472  02CD0H  09809H      ldr      r0,[sp,#36]
 11474  02CD2H  06800H      ldr      r0,[r0]
 11476  02CD4H  0A901H      add      r1,sp,#4
 11478  02CD6H  02220H      movs     r2,#32
 11480  02CD8H  0466BH      mov      r3,sp
 11482  02CDAH  09C0BH      ldr      r4,[sp,#44]
 11484  02CDCH  09D09H      ldr      r5,[sp,#36]
 11486  02CDEH  0686DH      ldr      r5,[r5,#4]
 11488  02CE0H  02D00H      cmp      r5,#0
 11490  02CE2H  0D101H      bne.n    2 -> 11496
 11492  02CE4H  0DF05H      svc      5
 11494  02CE6H  0010DH      <LineNo: 269>
 11496  02CE8H  03501H      adds     r5,#1
 11498  02CEAH  047A8H      blx      r5
 11500  02CECH  0E000H      b        0 -> 11504
 11502  02CEEH  0010CH      <LineNo: 268>
 11504  02CF0H  0980BH      ldr      r0,[sp,#44]
 11506  02CF2H  06800H      ldr      r0,[r0]
 11508  02CF4H  02800H      cmp      r0,#0
 11510  02CF6H  0D001H      beq.n    2 -> 11516
 11512  02CF8H  0E013H      b        38 -> 11554
 11514  02CFAH  046C0H      nop
 11516  02CFCH  09800H      ldr      r0,[sp]
 11518  02CFEH  02800H      cmp      r0,#0
 11520  02D00H  0DC01H      bgt.n    2 -> 11526
 11522  02D02H  0E00BH      b        22 -> 11548
 11524  02D04H  046C0H      nop
 11526  02D06H  0A801H      add      r0,sp,#4
 11528  02D08H  02120H      movs     r1,#32
 11530  02D0AH  09A00H      ldr      r2,[sp]
 11532  02D0CH  09B0AH      ldr      r3,[sp,#40]
 11534  02D0EH  09C0BH      ldr      r4,[sp,#44]
 11536  02D10H  0F7FFFF24H  bl.w     Texts.StrToInt
 11540  02D14H  0E000H      b        0 -> 11544
 11542  02D16H  00110H      <LineNo: 272>
 11544  02D18H  0E003H      b        6 -> 11554
 11546  02D1AH  046C0H      nop
 11548  02D1CH  02004H      movs     r0,#4
 11550  02D1EH  0990BH      ldr      r1,[sp,#44]
 11552  02D20H  06008H      str      r0,[r1]
 11554  02D22H  0B00CH      add      sp,#48
 11556  02D24H  0BD00H      pop      { pc }
 11558  02D26H  046C0H      nop

PROCEDURE Texts.FlushOut:
 11560  02D28H  0B501H      push     { r0, lr }
 11562  02D2AH  09800H      ldr      r0,[sp]
 11564  02D2CH  06880H      ldr      r0,[r0,#8]
 11566  02D2EH  02800H      cmp      r0,#0
 11568  02D30H  0D101H      bne.n    2 -> 11574
 11570  02D32H  0E00CH      b        24 -> 11598
 11572  02D34H  046C0H      nop
 11574  02D36H  09800H      ldr      r0,[sp]
 11576  02D38H  06800H      ldr      r0,[r0]
 11578  02D3AH  09900H      ldr      r1,[sp]
 11580  02D3CH  06889H      ldr      r1,[r1,#8]
 11582  02D3EH  02900H      cmp      r1,#0
 11584  02D40H  0D101H      bne.n    2 -> 11590
 11586  02D42H  0DF05H      svc      5
 11588  02D44H  0011FH      <LineNo: 287>
 11590  02D46H  03101H      adds     r1,#1
 11592  02D48H  04788H      blx      r1
 11594  02D4AH  0E000H      b        0 -> 11598
 11596  02D4CH  0011FH      <LineNo: 287>
 11598  02D4EH  0B001H      add      sp,#4
 11600  02D50H  0BD00H      pop      { pc }
 11602  02D52H  046C0H      nop

PROCEDURE Texts..init:
 11604  02D54H  0B500H      push     { lr }
 11606  02D56H  04803H      ldr      r0,[pc,#12] -> 11620
 11608  02D58H  0210DH      movs     r1,#13
 11610  02D5AH  07001H      strb     r1,[r0]
 11612  02D5CH  04801H      ldr      r0,[pc,#4] -> 11620
 11614  02D5EH  0210AH      movs     r1,#10
 11616  02D60H  07041H      strb     r1,[r0,#1]
 11618  02D62H  0BD00H      pop      { pc }
 11620  02D64H  02002FCCCH

MODULE ResData:
 11624  02D68H  0
 11628  02D6CH  12
 11632  02D70H  0
 11636  02D74H  0
 11640  02D78H  0
 11644  02D7CH  0
 11648  02D80H  16
 11652  02D84H  0
 11656  02D88H  0
 11660  02D8CH  0
 11664  02D90H  0

PROCEDURE ResData.Size:
 11668  02D94H  0B503H      push     { r0, r1, lr }
 11670  02D96H  09800H      ldr      r0,[sp]
 11672  02D98H  06840H      ldr      r0,[r0,#4]
 11674  02D9AH  0B002H      add      sp,#8
 11676  02D9CH  0BD00H      pop      { pc }
 11678  02D9EH  046C0H      nop

PROCEDURE ResData.GetInt:
 11680  02DA0H  0B50FH      push     { r0, r1, r2, r3, lr }
 11682  02DA2H  09802H      ldr      r0,[sp,#8]
 11684  02DA4H  09900H      ldr      r1,[sp]
 11686  02DA6H  06889H      ldr      r1,[r1,#8]
 11688  02DA8H  04288H      cmp      r0,r1
 11690  02DAAH  0DD01H      ble.n    2 -> 11696
 11692  02DACH  0DF16H      svc      22
 11694  02DAEH  0002CH      <LineNo: 44>
 11696  02DB0H  09802H      ldr      r0,[sp,#8]
 11698  02DB2H  00080H      lsls     r0,r0,#2
 11700  02DB4H  09900H      ldr      r1,[sp]
 11702  02DB6H  06809H      ldr      r1,[r1]
 11704  02DB8H  01808H      adds     r0,r1,r0
 11706  02DBAH  06801H      ldr      r1,[r0]
 11708  02DBCH  09A03H      ldr      r2,[sp,#12]
 11710  02DBEH  06011H      str      r1,[r2]
 11712  02DC0H  0B004H      add      sp,#16
 11714  02DC2H  0BD00H      pop      { pc }

PROCEDURE ResData.GetByte:
 11716  02DC4H  0B50FH      push     { r0, r1, r2, r3, lr }
 11718  02DC6H  09802H      ldr      r0,[sp,#8]
 11720  02DC8H  09900H      ldr      r1,[sp]
 11722  02DCAH  06849H      ldr      r1,[r1,#4]
 11724  02DCCH  04288H      cmp      r0,r1
 11726  02DCEH  0DD01H      ble.n    2 -> 11732
 11728  02DD0H  0DF16H      svc      22
 11730  02DD2H  00033H      <LineNo: 51>
 11732  02DD4H  09800H      ldr      r0,[sp]
 11734  02DD6H  06800H      ldr      r0,[r0]
 11736  02DD8H  09902H      ldr      r1,[sp,#8]
 11738  02DDAH  01840H      adds     r0,r0,r1
 11740  02DDCH  07801H      ldrb     r1,[r0]
 11742  02DDEH  09A03H      ldr      r2,[sp,#12]
 11744  02DE0H  07011H      strb     r1,[r2]
 11746  02DE2H  0B004H      add      sp,#16
 11748  02DE4H  0BD00H      pop      { pc }
 11750  02DE6H  046C0H      nop

PROCEDURE ResData.GetChar:
 11752  02DE8H  0B50FH      push     { r0, r1, r2, r3, lr }
 11754  02DEAH  09802H      ldr      r0,[sp,#8]
 11756  02DECH  09900H      ldr      r1,[sp]
 11758  02DEEH  06849H      ldr      r1,[r1,#4]
 11760  02DF0H  04288H      cmp      r0,r1
 11762  02DF2H  0DD01H      ble.n    2 -> 11768
 11764  02DF4H  0DF16H      svc      22
 11766  02DF6H  0003AH      <LineNo: 58>
 11768  02DF8H  09800H      ldr      r0,[sp]
 11770  02DFAH  06800H      ldr      r0,[r0]
 11772  02DFCH  09902H      ldr      r1,[sp,#8]
 11774  02DFEH  01840H      adds     r0,r0,r1
 11776  02E00H  07801H      ldrb     r1,[r0]
 11778  02E02H  09A03H      ldr      r2,[sp,#12]
 11780  02E04H  07011H      strb     r1,[r2]
 11782  02E06H  0B004H      add      sp,#16
 11784  02E08H  0BD00H      pop      { pc }
 11786  02E0AH  046C0H      nop

PROCEDURE ResData.GetIntArray:
 11788  02E0CH  0B53FH      push     { r0, r1, r2, r3, r4, r5, lr }
 11790  02E0EH  0B082H      sub      sp,#8
 11792  02E10H  09804H      ldr      r0,[sp,#16]
 11794  02E12H  09902H      ldr      r1,[sp,#8]
 11796  02E14H  06889H      ldr      r1,[r1,#8]
 11798  02E16H  04288H      cmp      r0,r1
 11800  02E18H  0DD01H      ble.n    2 -> 11806
 11802  02E1AH  0DF16H      svc      22
 11804  02E1CH  00043H      <LineNo: 67>
 11806  02E1EH  09804H      ldr      r0,[sp,#16]
 11808  02E20H  09905H      ldr      r1,[sp,#20]
 11810  02E22H  01840H      adds     r0,r0,r1
 11812  02E24H  09902H      ldr      r1,[sp,#8]
 11814  02E26H  06889H      ldr      r1,[r1,#8]
 11816  02E28H  04288H      cmp      r0,r1
 11818  02E2AH  0DC01H      bgt.n    2 -> 11824
 11820  02E2CH  0E006H      b        12 -> 11836
 11822  02E2EH  046C0H      nop
 11824  02E30H  09802H      ldr      r0,[sp,#8]
 11826  02E32H  06880H      ldr      r0,[r0,#8]
 11828  02E34H  09904H      ldr      r1,[sp,#16]
 11830  02E36H  01A40H      subs     r0,r0,r1
 11832  02E38H  03001H      adds     r0,#1
 11834  02E3AH  09005H      str      r0,[sp,#20]
 11836  02E3CH  09805H      ldr      r0,[sp,#20]
 11838  02E3EH  09907H      ldr      r1,[sp,#28]
 11840  02E40H  04288H      cmp      r0,r1
 11842  02E42H  0DD01H      ble.n    2 -> 11848
 11844  02E44H  0DF16H      svc      22
 11846  02E46H  00045H      <LineNo: 69>
 11848  02E48H  09804H      ldr      r0,[sp,#16]
 11850  02E4AH  00080H      lsls     r0,r0,#2
 11852  02E4CH  09902H      ldr      r1,[sp,#8]
 11854  02E4EH  06809H      ldr      r1,[r1]
 11856  02E50H  01808H      adds     r0,r1,r0
 11858  02E52H  09001H      str      r0,[sp,#4]
 11860  02E54H  02000H      movs     r0,#0
 11862  02E56H  09000H      str      r0,[sp]
 11864  02E58H  09805H      ldr      r0,[sp,#20]
 11866  02E5AH  03801H      subs     r0,#1
 11868  02E5CH  09900H      ldr      r1,[sp]
 11870  02E5EH  04281H      cmp      r1,r0
 11872  02E60H  0DD01H      ble.n    2 -> 11878
 11874  02E62H  0E00EH      b        28 -> 11906
 11876  02E64H  046C0H      nop
 11878  02E66H  09800H      ldr      r0,[sp]
 11880  02E68H  09906H      ldr      r1,[sp,#24]
 11882  02E6AH  00080H      lsls     r0,r0,#2
 11884  02E6CH  01808H      adds     r0,r1,r0
 11886  02E6EH  09901H      ldr      r1,[sp,#4]
 11888  02E70H  0680AH      ldr      r2,[r1]
 11890  02E72H  06002H      str      r2,[r0]
 11892  02E74H  09801H      ldr      r0,[sp,#4]
 11894  02E76H  03004H      adds     r0,#4
 11896  02E78H  09001H      str      r0,[sp,#4]
 11898  02E7AH  09800H      ldr      r0,[sp]
 11900  02E7CH  03001H      adds     r0,#1
 11902  02E7EH  09000H      str      r0,[sp]
 11904  02E80H  0E7EAH      b        -44 -> 11864
 11906  02E82H  09805H      ldr      r0,[sp,#20]
 11908  02E84H  0B008H      add      sp,#32
 11910  02E86H  0BD00H      pop      { pc }

PROCEDURE ResData.GetReal:
 11912  02E88H  0B50FH      push     { r0, r1, r2, r3, lr }
 11914  02E8AH  09802H      ldr      r0,[sp,#8]
 11916  02E8CH  09900H      ldr      r1,[sp]
 11918  02E8EH  06889H      ldr      r1,[r1,#8]
 11920  02E90H  04288H      cmp      r0,r1
 11922  02E92H  0DB01H      blt.n    2 -> 11928
 11924  02E94H  0DF16H      svc      22
 11926  02E96H  00051H      <LineNo: 81>
 11928  02E98H  09802H      ldr      r0,[sp,#8]
 11930  02E9AH  00080H      lsls     r0,r0,#2
 11932  02E9CH  09900H      ldr      r1,[sp]
 11934  02E9EH  06809H      ldr      r1,[r1]
 11936  02EA0H  01808H      adds     r0,r1,r0
 11938  02EA2H  06801H      ldr      r1,[r0]
 11940  02EA4H  09A03H      ldr      r2,[sp,#12]
 11942  02EA6H  06011H      str      r1,[r2]
 11944  02EA8H  0B004H      add      sp,#16
 11946  02EAAH  0BD00H      pop      { pc }

PROCEDURE ResData.GetRealArray:
 11948  02EACH  0B53FH      push     { r0, r1, r2, r3, r4, r5, lr }
 11950  02EAEH  0B082H      sub      sp,#8
 11952  02EB0H  09804H      ldr      r0,[sp,#16]
 11954  02EB2H  09902H      ldr      r1,[sp,#8]
 11956  02EB4H  06889H      ldr      r1,[r1,#8]
 11958  02EB6H  04288H      cmp      r0,r1
 11960  02EB8H  0DD01H      ble.n    2 -> 11966
 11962  02EBAH  0DF16H      svc      22
 11964  02EBCH  0005AH      <LineNo: 90>
 11966  02EBEH  09804H      ldr      r0,[sp,#16]
 11968  02EC0H  09905H      ldr      r1,[sp,#20]
 11970  02EC2H  01840H      adds     r0,r0,r1
 11972  02EC4H  09902H      ldr      r1,[sp,#8]
 11974  02EC6H  06889H      ldr      r1,[r1,#8]
 11976  02EC8H  04288H      cmp      r0,r1
 11978  02ECAH  0DC01H      bgt.n    2 -> 11984
 11980  02ECCH  0E006H      b        12 -> 11996
 11982  02ECEH  046C0H      nop
 11984  02ED0H  09802H      ldr      r0,[sp,#8]
 11986  02ED2H  06880H      ldr      r0,[r0,#8]
 11988  02ED4H  09904H      ldr      r1,[sp,#16]
 11990  02ED6H  01A40H      subs     r0,r0,r1
 11992  02ED8H  03001H      adds     r0,#1
 11994  02EDAH  09005H      str      r0,[sp,#20]
 11996  02EDCH  09805H      ldr      r0,[sp,#20]
 11998  02EDEH  09907H      ldr      r1,[sp,#28]
 12000  02EE0H  04288H      cmp      r0,r1
 12002  02EE2H  0DD01H      ble.n    2 -> 12008
 12004  02EE4H  0DF16H      svc      22
 12006  02EE6H  0005CH      <LineNo: 92>
 12008  02EE8H  09804H      ldr      r0,[sp,#16]
 12010  02EEAH  00080H      lsls     r0,r0,#2
 12012  02EECH  09902H      ldr      r1,[sp,#8]
 12014  02EEEH  06809H      ldr      r1,[r1]
 12016  02EF0H  01808H      adds     r0,r1,r0
 12018  02EF2H  09001H      str      r0,[sp,#4]
 12020  02EF4H  02000H      movs     r0,#0
 12022  02EF6H  09000H      str      r0,[sp]
 12024  02EF8H  09805H      ldr      r0,[sp,#20]
 12026  02EFAH  03801H      subs     r0,#1
 12028  02EFCH  09900H      ldr      r1,[sp]
 12030  02EFEH  04281H      cmp      r1,r0
 12032  02F00H  0DD01H      ble.n    2 -> 12038
 12034  02F02H  0E00EH      b        28 -> 12066
 12036  02F04H  046C0H      nop
 12038  02F06H  09800H      ldr      r0,[sp]
 12040  02F08H  09906H      ldr      r1,[sp,#24]
 12042  02F0AH  00080H      lsls     r0,r0,#2
 12044  02F0CH  01808H      adds     r0,r1,r0
 12046  02F0EH  09901H      ldr      r1,[sp,#4]
 12048  02F10H  0680AH      ldr      r2,[r1]
 12050  02F12H  06002H      str      r2,[r0]
 12052  02F14H  09801H      ldr      r0,[sp,#4]
 12054  02F16H  03004H      adds     r0,#4
 12056  02F18H  09001H      str      r0,[sp,#4]
 12058  02F1AH  09800H      ldr      r0,[sp]
 12060  02F1CH  03001H      adds     r0,#1
 12062  02F1EH  09000H      str      r0,[sp]
 12064  02F20H  0E7EAH      b        -44 -> 12024
 12066  02F22H  09805H      ldr      r0,[sp,#20]
 12068  02F24H  0B008H      add      sp,#32
 12070  02F26H  0BD00H      pop      { pc }

PROCEDURE ResData.GetName:
 12072  02F28H  0B503H      push     { r0, r1, lr }
 12074  02F2AH  0B082H      sub      sp,#8
 12076  02F2CH  09802H      ldr      r0,[sp,#8]
 12078  02F2EH  06801H      ldr      r1,[r0]
 12080  02F30H  09101H      str      r1,[sp,#4]
 12082  02F32H  02000H      movs     r0,#0
 12084  02F34H  09000H      str      r0,[sp]
 12086  02F36H  09800H      ldr      r0,[sp]
 12088  02F38H  02803H      cmp      r0,#3
 12090  02F3AH  0DD01H      ble.n    2 -> 12096
 12092  02F3CH  0E00CH      b        24 -> 12120
 12094  02F3EH  046C0H      nop
 12096  02F40H  09800H      ldr      r0,[sp]
 12098  02F42H  09903H      ldr      r1,[sp,#12]
 12100  02F44H  01808H      adds     r0,r1,r0
 12102  02F46H  09900H      ldr      r1,[sp]
 12104  02F48H  0466AH      mov      r2,sp
 12106  02F4AH  01851H      adds     r1,r2,r1
 12108  02F4CH  07909H      ldrb     r1,[r1,#4]
 12110  02F4EH  07001H      strb     r1,[r0]
 12112  02F50H  09800H      ldr      r0,[sp]
 12114  02F52H  03001H      adds     r0,#1
 12116  02F54H  09000H      str      r0,[sp]
 12118  02F56H  0E7EEH      b        -36 -> 12086
 12120  02F58H  09802H      ldr      r0,[sp,#8]
 12122  02F5AH  03004H      adds     r0,#4
 12124  02F5CH  06801H      ldr      r1,[r0]
 12126  02F5EH  09101H      str      r1,[sp,#4]
 12128  02F60H  02000H      movs     r0,#0
 12130  02F62H  09000H      str      r0,[sp]
 12132  02F64H  09800H      ldr      r0,[sp]
 12134  02F66H  02803H      cmp      r0,#3
 12136  02F68H  0DD01H      ble.n    2 -> 12142
 12138  02F6AH  0E00DH      b        26 -> 12168
 12140  02F6CH  046C0H      nop
 12142  02F6EH  09800H      ldr      r0,[sp]
 12144  02F70H  03004H      adds     r0,#4
 12146  02F72H  09903H      ldr      r1,[sp,#12]
 12148  02F74H  01808H      adds     r0,r1,r0
 12150  02F76H  09900H      ldr      r1,[sp]
 12152  02F78H  0466AH      mov      r2,sp
 12154  02F7AH  01851H      adds     r1,r2,r1
 12156  02F7CH  07909H      ldrb     r1,[r1,#4]
 12158  02F7EH  07001H      strb     r1,[r0]
 12160  02F80H  09800H      ldr      r0,[sp]
 12162  02F82H  03001H      adds     r0,#1
 12164  02F84H  09000H      str      r0,[sp]
 12166  02F86H  0E7EDH      b        -38 -> 12132
 12168  02F88H  02000H      movs     r0,#0
 12170  02F8AH  09903H      ldr      r1,[sp,#12]
 12172  02F8CH  07208H      strb     r0,[r1,#8]
 12174  02F8EH  0B004H      add      sp,#16
 12176  02F90H  0BD00H      pop      { pc }
 12178  02F92H  046C0H      nop

PROCEDURE ResData.Count:
 12180  02F94H  0B500H      push     { lr }
 12182  02F96H  0B084H      sub      sp,#16
 12184  02F98H  04811H      ldr      r0,[pc,#68] -> 12256
 12186  02F9AH  06800H      ldr      r0,[r0]
 12188  02F9CH  09002H      str      r0,[sp,#8]
 12190  02F9EH  09802H      ldr      r0,[sp,#8]
 12192  02FA0H  06801H      ldr      r1,[r0]
 12194  02FA2H  09103H      str      r1,[sp,#12]
 12196  02FA4H  02000H      movs     r0,#0
 12198  02FA6H  09000H      str      r0,[sp]
 12200  02FA8H  09803H      ldr      r0,[sp,#12]
 12202  02FAAH  0490CH      ldr      r1,[pc,#48] -> 12252
 12204  02FACH  04288H      cmp      r0,r1
 12206  02FAEH  0D001H      beq.n    2 -> 12212
 12208  02FB0H  0E010H      b        32 -> 12244
 12210  02FB2H  046C0H      nop
 12212  02FB4H  09802H      ldr      r0,[sp,#8]
 12214  02FB6H  03014H      adds     r0,#20
 12216  02FB8H  06801H      ldr      r1,[r0]
 12218  02FBAH  09101H      str      r1,[sp,#4]
 12220  02FBCH  09802H      ldr      r0,[sp,#8]
 12222  02FBEH  03018H      adds     r0,#24
 12224  02FC0H  09901H      ldr      r1,[sp,#4]
 12226  02FC2H  01840H      adds     r0,r0,r1
 12228  02FC4H  09002H      str      r0,[sp,#8]
 12230  02FC6H  09802H      ldr      r0,[sp,#8]
 12232  02FC8H  06801H      ldr      r1,[r0]
 12234  02FCAH  09103H      str      r1,[sp,#12]
 12236  02FCCH  09800H      ldr      r0,[sp]
 12238  02FCEH  03001H      adds     r0,#1
 12240  02FD0H  09000H      str      r0,[sp]
 12242  02FD2H  0E7E9H      b        -46 -> 12200
 12244  02FD4H  09800H      ldr      r0,[sp]
 12246  02FD6H  0B004H      add      sp,#16
 12248  02FD8H  0BD00H      pop      { pc }
 12250  02FDAH  046C0H      nop
 12252  02FDCH  05237424FH  "OB7R"
 12256  02FE0H  02002FFE8H

PROCEDURE ResData.GetDirectory:
 12260  02FE4H  0B503H      push     { r0, r1, lr }
 12262  02FE6H  0B084H      sub      sp,#16
 12264  02FE8H  04820H      ldr      r0,[pc,#128] -> 12396
 12266  02FEAH  06800H      ldr      r0,[r0]
 12268  02FECH  09001H      str      r0,[sp,#4]
 12270  02FEEH  09801H      ldr      r0,[sp,#4]
 12272  02FF0H  06801H      ldr      r1,[r0]
 12274  02FF2H  09103H      str      r1,[sp,#12]
 12276  02FF4H  02000H      movs     r0,#0
 12278  02FF6H  09000H      str      r0,[sp]
 12280  02FF8H  09803H      ldr      r0,[sp,#12]
 12282  02FFAH  0491BH      ldr      r1,[pc,#108] -> 12392
 12284  02FFCH  04288H      cmp      r0,r1
 12286  02FFEH  0D001H      beq.n    2 -> 12292
 12288  03000H  0E030H      b        96 -> 12388
 12290  03002H  046C0H      nop
 12292  03004H  09800H      ldr      r0,[sp]
 12294  03006H  09905H      ldr      r1,[sp,#20]
 12296  03008H  04288H      cmp      r0,r1
 12298  0300AH  0DB01H      blt.n    2 -> 12304
 12300  0300CH  0E02AH      b        84 -> 12388
 12302  0300EH  046C0H      nop
 12304  03010H  09801H      ldr      r0,[sp,#4]
 12306  03012H  03008H      adds     r0,#8
 12308  03014H  09900H      ldr      r1,[sp]
 12310  03016H  09A05H      ldr      r2,[sp,#20]
 12312  03018H  04291H      cmp      r1,r2
 12314  0301AH  0D301H      bcc.n    2 -> 12320
 12316  0301CH  0DF01H      svc      1
 12318  0301EH  0008EH      <LineNo: 142>
 12320  03020H  09A04H      ldr      r2,[sp,#16]
 12322  03022H  00109H      lsls     r1,r1,#4
 12324  03024H  01851H      adds     r1,r2,r1
 12326  03026H  0F7FFFF7FH  bl.w     ResData.GetName
 12330  0302AH  0E000H      b        0 -> 12334
 12332  0302CH  0008EH      <LineNo: 142>
 12334  0302EH  09801H      ldr      r0,[sp,#4]
 12336  03030H  03014H      adds     r0,#20
 12338  03032H  06801H      ldr      r1,[r0]
 12340  03034H  09102H      str      r1,[sp,#8]
 12342  03036H  09800H      ldr      r0,[sp]
 12344  03038H  09905H      ldr      r1,[sp,#20]
 12346  0303AH  04288H      cmp      r0,r1
 12348  0303CH  0D301H      bcc.n    2 -> 12354
 12350  0303EH  0DF01H      svc      1
 12352  03040H  00090H      <LineNo: 144>
 12354  03042H  09904H      ldr      r1,[sp,#16]
 12356  03044H  00100H      lsls     r0,r0,#4
 12358  03046H  01808H      adds     r0,r1,r0
 12360  03048H  09902H      ldr      r1,[sp,#8]
 12362  0304AH  060C1H      str      r1,[r0,#12]
 12364  0304CH  09801H      ldr      r0,[sp,#4]
 12366  0304EH  03018H      adds     r0,#24
 12368  03050H  09902H      ldr      r1,[sp,#8]
 12370  03052H  01840H      adds     r0,r0,r1
 12372  03054H  09001H      str      r0,[sp,#4]
 12374  03056H  09801H      ldr      r0,[sp,#4]
 12376  03058H  06801H      ldr      r1,[r0]
 12378  0305AH  09103H      str      r1,[sp,#12]
 12380  0305CH  09800H      ldr      r0,[sp]
 12382  0305EH  03001H      adds     r0,#1
 12384  03060H  09000H      str      r0,[sp]
 12386  03062H  0E7C9H      b        -110 -> 12280
 12388  03064H  0B006H      add      sp,#24
 12390  03066H  0BD00H      pop      { pc }
 12392  03068H  05237424FH  "OB7R"
 12396  0306CH  02002FFE8H

PROCEDURE ResData.Open:
 12400  03070H  0B50FH      push     { r0, r1, r2, r3, lr }
 12402  03072H  0B088H      sub      sp,#32
 12404  03074H  02000H      movs     r0,#0
 12406  03076H  09908H      ldr      r1,[sp,#32]
 12408  03078H  06048H      str      r0,[r1,#4]
 12410  0307AH  02000H      movs     r0,#0
 12412  0307CH  09908H      ldr      r1,[sp,#32]
 12414  0307EH  06008H      str      r0,[r1]
 12416  03080H  02000H      movs     r0,#0
 12418  03082H  09908H      ldr      r1,[sp,#32]
 12420  03084H  06088H      str      r0,[r1,#8]
 12422  03086H  04828H      ldr      r0,[pc,#160] -> 12584
 12424  03088H  06800H      ldr      r0,[r0]
 12426  0308AH  09002H      str      r0,[sp,#8]
 12428  0308CH  09802H      ldr      r0,[sp,#8]
 12430  0308EH  06801H      ldr      r1,[r0]
 12432  03090H  09104H      str      r1,[sp,#16]
 12434  03092H  09804H      ldr      r0,[sp,#16]
 12436  03094H  04923H      ldr      r1,[pc,#140] -> 12580
 12438  03096H  04288H      cmp      r0,r1
 12440  03098H  0D001H      beq.n    2 -> 12446
 12442  0309AH  0DF15H      svc      21
 12444  0309CH  000A3H      <LineNo: 163>
 12446  0309EH  09804H      ldr      r0,[sp,#16]
 12448  030A0H  04920H      ldr      r1,[pc,#128] -> 12580
 12450  030A2H  04288H      cmp      r0,r1
 12452  030A4H  0D001H      beq.n    2 -> 12458
 12454  030A6H  0E03AH      b        116 -> 12574
 12456  030A8H  046C0H      nop
 12458  030AAH  09802H      ldr      r0,[sp,#8]
 12460  030ACH  03008H      adds     r0,#8
 12462  030AEH  0A905H      add      r1,sp,#20
 12464  030B0H  0F7FFFF3AH  bl.w     ResData.GetName
 12468  030B4H  0E000H      b        0 -> 12472
 12470  030B6H  000A5H      <LineNo: 165>
 12472  030B8H  09802H      ldr      r0,[sp,#8]
 12474  030BAH  03004H      adds     r0,#4
 12476  030BCH  06801H      ldr      r1,[r0]
 12478  030BEH  09100H      str      r1,[sp]
 12480  030C0H  09800H      ldr      r0,[sp]
 12482  030C2H  02801H      cmp      r0,#1
 12484  030C4H  0D001H      beq.n    2 -> 12490
 12486  030C6H  0DF17H      svc      23
 12488  030C8H  000A7H      <LineNo: 167>
 12490  030CAH  09802H      ldr      r0,[sp,#8]
 12492  030CCH  03014H      adds     r0,#20
 12494  030CEH  06801H      ldr      r1,[r0]
 12496  030D0H  09103H      str      r1,[sp,#12]
 12498  030D2H  02000H      movs     r0,#0
 12500  030D4H  0990AH      ldr      r1,[sp,#40]
 12502  030D6H  0AA05H      add      r2,sp,#20
 12504  030D8H  05C0BH      ldrb     r3,[r1,r0]
 12506  030DAH  05C14H      ldrb     r4,[r2,r0]
 12508  030DCH  03001H      adds     r0,#1
 12510  030DEH  042A3H      cmp      r3,r4
 12512  030E0H  0D101H      bne.n    2 -> 12518
 12514  030E2H  02B00H      cmp      r3,#0
 12516  030E4H  0D1F8H      bne.n    -16 -> 12504
 12518  030E6H  0D001H      beq.n    2 -> 12524
 12520  030E8H  0E010H      b        32 -> 12556
 12522  030EAH  046C0H      nop
 12524  030ECH  09803H      ldr      r0,[sp,#12]
 12526  030EEH  09908H      ldr      r1,[sp,#32]
 12528  030F0H  06048H      str      r0,[r1,#4]
 12530  030F2H  09802H      ldr      r0,[sp,#8]
 12532  030F4H  03010H      adds     r0,#16
 12534  030F6H  06801H      ldr      r1,[r0]
 12536  030F8H  09101H      str      r1,[sp,#4]
 12538  030FAH  09802H      ldr      r0,[sp,#8]
 12540  030FCH  03018H      adds     r0,#24
 12542  030FEH  09908H      ldr      r1,[sp,#32]
 12544  03100H  06008H      str      r0,[r1]
 12546  03102H  09808H      ldr      r0,[sp,#32]
 12548  03104H  06840H      ldr      r0,[r0,#4]
 12550  03106H  01080H      asrs     r0,r0,#2
 12552  03108H  09908H      ldr      r1,[sp,#32]
 12554  0310AH  06088H      str      r0,[r1,#8]
 12556  0310CH  09802H      ldr      r0,[sp,#8]
 12558  0310EH  03018H      adds     r0,#24
 12560  03110H  09903H      ldr      r1,[sp,#12]
 12562  03112H  01840H      adds     r0,r0,r1
 12564  03114H  09002H      str      r0,[sp,#8]
 12566  03116H  09802H      ldr      r0,[sp,#8]
 12568  03118H  06801H      ldr      r1,[r0]
 12570  0311AH  09104H      str      r1,[sp,#16]
 12572  0311CH  0E7BFH      b        -130 -> 12446
 12574  0311EH  0B00CH      add      sp,#48
 12576  03120H  0BD00H      pop      { pc }
 12578  03122H  046C0H      nop
 12580  03124H  05237424FH  "OB7R"
 12584  03128H  02002FFE8H

PROCEDURE ResData..init:
 12588  0312CH  0B500H      push     { lr }
 12590  0312EH  0BD00H      pop      { pc }

MODULE RuntimeErrorsOu:
 12592  03130H  0

PROCEDURE RuntimeErrorsOu.intArrayToChars:
 12596  03134H  0B50FH      push     { r0, r1, r2, r3, lr }
 12598  03136H  0B081H      sub      sp,#4
 12600  03138H  02000H      movs     r0,#0
 12602  0313AH  09000H      str      r0,[sp]
 12604  0313CH  09802H      ldr      r0,[sp,#8]
 12606  0313EH  03801H      subs     r0,#1
 12608  03140H  09900H      ldr      r1,[sp]
 12610  03142H  04281H      cmp      r1,r0
 12612  03144H  0DD01H      ble.n    2 -> 12618
 12614  03146H  0E00CH      b        24 -> 12642
 12616  03148H  046C0H      nop
 12618  0314AH  09800H      ldr      r0,[sp]
 12620  0314CH  09903H      ldr      r1,[sp,#12]
 12622  0314EH  01808H      adds     r0,r1,r0
 12624  03150H  09900H      ldr      r1,[sp]
 12626  03152H  09A01H      ldr      r2,[sp,#4]
 12628  03154H  01851H      adds     r1,r2,r1
 12630  03156H  07809H      ldrb     r1,[r1]
 12632  03158H  07001H      strb     r1,[r0]
 12634  0315AH  09800H      ldr      r0,[sp]
 12636  0315CH  03001H      adds     r0,#1
 12638  0315EH  09000H      str      r0,[sp]
 12640  03160H  0E7ECH      b        -40 -> 12604
 12642  03162H  0B005H      add      sp,#20
 12644  03164H  0BD00H      pop      { pc }
 12646  03166H  046C0H      nop

PROCEDURE RuntimeErrorsOu.GetName:
 12648  03168H  0B507H      push     { r0, r1, r2, lr }
 12650  0316AH  0B090H      sub      sp,#64
 12652  0316CH  04668H      mov      r0,sp
 12654  0316EH  04947H      ldr      r1,[pc,#284] -> 12940
 12656  03170H  0A200H      adr      r2,pc,#0 -> 12660
 12658  03172H  0E003H      b        6 -> 12668
 12660  03174H  06665722EH  ".ref"
 12664  03178H  000000000H
 12668  0317CH  02305H      movs     r3,#5
 12670  0317EH  0F7FFFF77H  bl.w     ResData.Open
 12674  03182H  0E000H      b        0 -> 12678
 12676  03184H  0002EH      <LineNo: 46>
 12678  03186H  04668H      mov      r0,sp
 12680  03188H  04940H      ldr      r1,[pc,#256] -> 12940
 12682  0318AH  0F7FFFE03H  bl.w     ResData.Size
 12686  0318EH  0E000H      b        0 -> 12690
 12688  03190H  0002FH      <LineNo: 47>
 12690  03192H  09007H      str      r0,[sp,#28]
 12692  03194H  09807H      ldr      r0,[sp,#28]
 12694  03196H  02118H      movs     r1,#24
 12696  03198H  02401H      movs     r4,#1
 12698  0319AH  007E4H      lsls     r4,r4,#31
 12700  0319CH  02200H      movs     r2,#0
 12702  0319EH  02300H      movs     r3,#0
 12704  031A0H  00040H      lsls     r0,r0,#1
 12706  031A2H  0415BH      adcs     r3,r3
 12708  031A4H  0428BH      cmp      r3,r1
 12710  031A6H  0D301H      bcc.n    2 -> 12716
 12712  031A8H  01912H      adds     r2,r2,r4
 12714  031AAH  01A5BH      subs     r3,r3,r1
 12716  031ACH  00864H      lsrs     r4,r4,#1
 12718  031AEH  0D1F7H      bne.n    -18 -> 12704
 12720  031B0H  04610H      mov      r0,r2
 12722  031B2H  09008H      str      r0,[sp,#32]
 12724  031B4H  02000H      movs     r0,#0
 12726  031B6H  09003H      str      r0,[sp,#12]
 12728  031B8H  02000H      movs     r0,#0
 12730  031BAH  09006H      str      r0,[sp,#24]
 12732  031BCH  02000H      movs     r0,#0
 12734  031BEH  09004H      str      r0,[sp,#16]
 12736  031C0H  09808H      ldr      r0,[sp,#32]
 12738  031C2H  03801H      subs     r0,#1
 12740  031C4H  0900EH      str      r0,[sp,#56]
 12742  031C6H  09808H      ldr      r0,[sp,#32]
 12744  031C8H  03801H      subs     r0,#1
 12746  031CAH  0900FH      str      r0,[sp,#60]
 12748  031CCH  09803H      ldr      r0,[sp,#12]
 12750  031CEH  09908H      ldr      r1,[sp,#32]
 12752  031D0H  04288H      cmp      r0,r1
 12754  031D2H  0DB01H      blt.n    2 -> 12760
 12756  031D4H  0E02CH      b        88 -> 12848
 12758  031D6H  046C0H      nop
 12760  031D8H  04668H      mov      r0,sp
 12762  031DAH  0492CH      ldr      r1,[pc,#176] -> 12940
 12764  031DCH  09A04H      ldr      r2,[sp,#16]
 12766  031DEH  0AB09H      add      r3,sp,#36
 12768  031E0H  0F7FFFDDEH  bl.w     ResData.GetInt
 12772  031E4H  0E000H      b        0 -> 12776
 12774  031E6H  00037H      <LineNo: 55>
 12776  031E8H  04668H      mov      r0,sp
 12778  031EAH  04928H      ldr      r1,[pc,#160] -> 12940
 12780  031ECH  09A04H      ldr      r2,[sp,#16]
 12782  031EEH  03205H      adds     r2,#5
 12784  031F0H  0AB06H      add      r3,sp,#24
 12786  031F2H  0F7FFFDD5H  bl.w     ResData.GetInt
 12790  031F6H  0E000H      b        0 -> 12794
 12792  031F8H  00038H      <LineNo: 56>
 12794  031FAH  09806H      ldr      r0,[sp,#24]
 12796  031FCH  09910H      ldr      r1,[sp,#64]
 12798  031FEH  04288H      cmp      r0,r1
 12800  03200H  0DC01H      bgt.n    2 -> 12806
 12802  03202H  0E007H      b        14 -> 12820
 12804  03204H  046C0H      nop
 12806  03206H  09803H      ldr      r0,[sp,#12]
 12808  03208H  03801H      subs     r0,#1
 12810  0320AH  0900FH      str      r0,[sp,#60]
 12812  0320CH  09808H      ldr      r0,[sp,#32]
 12814  0320EH  09003H      str      r0,[sp,#12]
 12816  03210H  0E007H      b        14 -> 12834
 12818  03212H  046C0H      nop
 12820  03214H  09809H      ldr      r0,[sp,#36]
 12822  03216H  02800H      cmp      r0,#0
 12824  03218H  0D001H      beq.n    2 -> 12830
 12826  0321AH  0E002H      b        4 -> 12834
 12828  0321CH  046C0H      nop
 12830  0321EH  09803H      ldr      r0,[sp,#12]
 12832  03220H  0900EH      str      r0,[sp,#56]
 12834  03222H  09804H      ldr      r0,[sp,#16]
 12836  03224H  03006H      adds     r0,#6
 12838  03226H  09004H      str      r0,[sp,#16]
 12840  03228H  09803H      ldr      r0,[sp,#12]
 12842  0322AH  03001H      adds     r0,#1
 12844  0322CH  09003H      str      r0,[sp,#12]
 12846  0322EH  0E7CDH      b        -102 -> 12748
 12848  03230H  04668H      mov      r0,sp
 12850  03232H  04916H      ldr      r1,[pc,#88] -> 12940
 12852  03234H  09A0EH      ldr      r2,[sp,#56]
 12854  03236H  02306H      movs     r3,#6
 12856  03238H  0435AH      muls     r2,r3
 12858  0323AH  03201H      adds     r2,#1
 12860  0323CH  02304H      movs     r3,#4
 12862  0323EH  0AC0AH      add      r4,sp,#40
 12864  03240H  02504H      movs     r5,#4
 12866  03242H  0F7FFFDE3H  bl.w     ResData.GetIntArray
 12870  03246H  0E000H      b        0 -> 12874
 12872  03248H  00042H      <LineNo: 66>
 12874  0324AH  09005H      str      r0,[sp,#20]
 12876  0324CH  0A80AH      add      r0,sp,#40
 12878  0324EH  02110H      movs     r1,#16
 12880  03250H  09A11H      ldr      r2,[sp,#68]
 12882  03252H  02310H      movs     r3,#16
 12884  03254H  0F7FFFF6EH  bl.w     RuntimeErrorsOu.intArrayToChars
 12888  03258H  0E000H      b        0 -> 12892
 12890  0325AH  00043H      <LineNo: 67>
 12892  0325CH  04668H      mov      r0,sp
 12894  0325EH  0490BH      ldr      r1,[pc,#44] -> 12940
 12896  03260H  09A0FH      ldr      r2,[sp,#60]
 12898  03262H  02306H      movs     r3,#6
 12900  03264H  0435AH      muls     r2,r3
 12902  03266H  03201H      adds     r2,#1
 12904  03268H  02304H      movs     r3,#4
 12906  0326AH  0AC0AH      add      r4,sp,#40
 12908  0326CH  02504H      movs     r5,#4
 12910  0326EH  0F7FFFDCDH  bl.w     ResData.GetIntArray
 12914  03272H  0E000H      b        0 -> 12918
 12916  03274H  00044H      <LineNo: 68>
 12918  03276H  09005H      str      r0,[sp,#20]
 12920  03278H  0A80AH      add      r0,sp,#40
 12922  0327AH  02110H      movs     r1,#16
 12924  0327CH  09A12H      ldr      r2,[sp,#72]
 12926  0327EH  02310H      movs     r3,#16
 12928  03280H  0F7FFFF58H  bl.w     RuntimeErrorsOu.intArrayToChars
 12932  03284H  0E000H      b        0 -> 12936
 12934  03286H  00045H      <LineNo: 69>
 12936  03288H  0B013H      add      sp,#76
 12938  0328AH  0BD00H      pop      { pc }
 12940  0328CH  010002D6CH

PROCEDURE RuntimeErrorsOu.printStackTrace:
 12944  03290H  0B507H      push     { r0, r1, r2, lr }
 12946  03292H  0B089H      sub      sp,#36
 12948  03294H  0980AH      ldr      r0,[sp,#40]
 12950  03296H  06C00H      ldr      r0,[r0,#64]
 12952  03298H  02801H      cmp      r0,#1
 12954  0329AH  0DC01H      bgt.n    2 -> 12960
 12956  0329CH  0E0FCH      b        504 -> 13464
 12958  0329EH  046C0H      nop
 12960  032A0H  09809H      ldr      r0,[sp,#36]
 12962  032A2H  046C0H      nop
 12964  032A4H  0A100H      adr      r1,pc,#0 -> 12968
 12966  032A6H  0E003H      b        6 -> 12976
 12968  032A8H  063617274H  "trac"
 12972  032ACH  000003A65H  "e:"
 12976  032B0H  02207H      movs     r2,#7
 12978  032B2H  0F7FFFB19H  bl.w     Texts.WriteString
 12982  032B6H  0E000H      b        0 -> 12986
 12984  032B8H  00050H      <LineNo: 80>
 12986  032BAH  09809H      ldr      r0,[sp,#36]
 12988  032BCH  0F7FFFB40H  bl.w     Texts.WriteLn
 12992  032C0H  0E000H      b        0 -> 12996
 12994  032C2H  00050H      <LineNo: 80>
 12996  032C4H  02000H      movs     r0,#0
 12998  032C6H  09000H      str      r0,[sp]
 13000  032C8H  09800H      ldr      r0,[sp]
 13002  032CAH  02808H      cmp      r0,#8
 13004  032CCH  0D301H      bcc.n    2 -> 13010
 13006  032CEH  0DF01H      svc      1
 13008  032D0H  00052H      <LineNo: 82>
 13010  032D2H  0990AH      ldr      r1,[sp,#40]
 13012  032D4H  000C0H      lsls     r0,r0,#3
 13014  032D6H  01808H      adds     r0,r1,r0
 13016  032D8H  06800H      ldr      r0,[r0]
 13018  032DAH  0A901H      add      r1,sp,#4
 13020  032DCH  0AA05H      add      r2,sp,#20
 13022  032DEH  0F7FFFF43H  bl.w     RuntimeErrorsOu.GetName
 13026  032E2H  0E000H      b        0 -> 13030
 13028  032E4H  00052H      <LineNo: 82>
 13030  032E6H  09800H      ldr      r0,[sp]
 13032  032E8H  0990AH      ldr      r1,[sp,#40]
 13034  032EAH  06C09H      ldr      r1,[r1,#64]
 13036  032ECH  04288H      cmp      r0,r1
 13038  032EEH  0DB01H      blt.n    2 -> 13044
 13040  032F0H  0E0A6H      b        332 -> 13376
 13042  032F2H  046C0H      nop
 13044  032F4H  09809H      ldr      r0,[sp,#36]
 13046  032F6H  046C0H      nop
 13048  032F8H  0A100H      adr      r1,pc,#0 -> 13052
 13050  032FAH  0E001H      b        2 -> 13056
 13052  032FCH  8224
 13056  03300H  02203H      movs     r2,#3
 13058  03302H  0F7FFFAF1H  bl.w     Texts.WriteString
 13062  03306H  0E000H      b        0 -> 13066
 13064  03308H  00054H      <LineNo: 84>
 13066  0330AH  09809H      ldr      r0,[sp,#36]
 13068  0330CH  0A901H      add      r1,sp,#4
 13070  0330EH  02210H      movs     r2,#16
 13072  03310H  0F7FFFAEAH  bl.w     Texts.WriteString
 13076  03314H  0E000H      b        0 -> 13080
 13078  03316H  00054H      <LineNo: 84>
 13080  03318H  09809H      ldr      r0,[sp,#36]
 13082  0331AH  046C0H      nop
 13084  0331CH  0A100H      adr      r1,pc,#0 -> 13088
 13086  0331EH  0E001H      b        2 -> 13092
 13088  03320H  46
 13092  03324H  02202H      movs     r2,#2
 13094  03326H  0F7FFFADFH  bl.w     Texts.WriteString
 13098  0332AH  0E000H      b        0 -> 13102
 13100  0332CH  00054H      <LineNo: 84>
 13102  0332EH  09809H      ldr      r0,[sp,#36]
 13104  03330H  0A905H      add      r1,sp,#20
 13106  03332H  02210H      movs     r2,#16
 13108  03334H  0F7FFFAD8H  bl.w     Texts.WriteString
 13112  03338H  0E000H      b        0 -> 13116
 13114  0333AH  00054H      <LineNo: 84>
 13116  0333CH  09809H      ldr      r0,[sp,#36]
 13118  0333EH  046C0H      nop
 13120  03340H  0A100H      adr      r1,pc,#0 -> 13124
 13122  03342H  0E001H      b        2 -> 13128
 13124  03344H  8224
 13128  03348H  02203H      movs     r2,#3
 13130  0334AH  0F7FFFACDH  bl.w     Texts.WriteString
 13134  0334EH  0E000H      b        0 -> 13138
 13136  03350H  00055H      <LineNo: 85>
 13138  03352H  09809H      ldr      r0,[sp,#36]
 13140  03354H  09900H      ldr      r1,[sp]
 13142  03356H  02908H      cmp      r1,#8
 13144  03358H  0D301H      bcc.n    2 -> 13150
 13146  0335AH  0DF01H      svc      1
 13148  0335CH  00055H      <LineNo: 85>
 13150  0335EH  09A0AH      ldr      r2,[sp,#40]
 13152  03360H  000C9H      lsls     r1,r1,#3
 13154  03362H  01851H      adds     r1,r2,r1
 13156  03364H  06809H      ldr      r1,[r1]
 13158  03366H  02200H      movs     r2,#0
 13160  03368H  0F7FFFB48H  bl.w     Texts.WriteHex
 13164  0336CH  0E000H      b        0 -> 13168
 13166  0336EH  00055H      <LineNo: 85>
 13168  03370H  09800H      ldr      r0,[sp]
 13170  03372H  02808H      cmp      r0,#8
 13172  03374H  0D301H      bcc.n    2 -> 13178
 13174  03376H  0DF01H      svc      1
 13176  03378H  00056H      <LineNo: 86>
 13178  0337AH  0990AH      ldr      r1,[sp,#40]
 13180  0337CH  000C0H      lsls     r0,r0,#3
 13182  0337EH  01808H      adds     r0,r1,r0
 13184  03380H  06840H      ldr      r0,[r0,#4]
 13186  03382H  02800H      cmp      r0,#0
 13188  03384H  0DC01H      bgt.n    2 -> 13194
 13190  03386H  0E019H      b        50 -> 13244
 13192  03388H  046C0H      nop
 13194  0338AH  09809H      ldr      r0,[sp,#36]
 13196  0338CH  0A100H      adr      r1,pc,#0 -> 13200
 13198  0338EH  0E001H      b        2 -> 13204
 13200  03390H  8224
 13204  03394H  02203H      movs     r2,#3
 13206  03396H  0F7FFFAA7H  bl.w     Texts.WriteString
 13210  0339AH  0E000H      b        0 -> 13214
 13212  0339CH  00057H      <LineNo: 87>
 13214  0339EH  09809H      ldr      r0,[sp,#36]
 13216  033A0H  09900H      ldr      r1,[sp]
 13218  033A2H  02908H      cmp      r1,#8
 13220  033A4H  0D301H      bcc.n    2 -> 13226
 13222  033A6H  0DF01H      svc      1
 13224  033A8H  00057H      <LineNo: 87>
 13226  033AAH  09A0AH      ldr      r2,[sp,#40]
 13228  033ACH  000C9H      lsls     r1,r1,#3
 13230  033AEH  01851H      adds     r1,r2,r1
 13232  033B0H  06849H      ldr      r1,[r1,#4]
 13234  033B2H  02204H      movs     r2,#4
 13236  033B4H  0F7FFFB0AH  bl.w     Texts.WriteInt
 13240  033B8H  0E000H      b        0 -> 13244
 13242  033BAH  00057H      <LineNo: 87>
 13244  033BCH  09809H      ldr      r0,[sp,#36]
 13246  033BEH  0F7FFFABFH  bl.w     Texts.WriteLn
 13250  033C2H  0E000H      b        0 -> 13254
 13252  033C4H  00059H      <LineNo: 89>
 13254  033C6H  09800H      ldr      r0,[sp]
 13256  033C8H  03001H      adds     r0,#1
 13258  033CAH  09000H      str      r0,[sp]
 13260  033CCH  02000H      movs     r0,#0
 13262  033CEH  0A905H      add      r1,sp,#20
 13264  033D0H  0A200H      adr      r2,pc,#0 -> 13268
 13266  033D2H  0E003H      b        6 -> 13276
 13268  033D4H  0696E692EH  ".ini"
 13272  033D8H  000000074H  "t"
 13276  033DCH  05C0BH      ldrb     r3,[r1,r0]
 13278  033DEH  05C14H      ldrb     r4,[r2,r0]
 13280  033E0H  03001H      adds     r0,#1
 13282  033E2H  042A3H      cmp      r3,r4
 13284  033E4H  0D101H      bne.n    2 -> 13290
 13286  033E6H  02B00H      cmp      r3,#0
 13288  033E8H  0D1F8H      bne.n    -16 -> 13276
 13290  033EAH  0D001H      beq.n    2 -> 13296
 13292  033ECH  0E018H      b        48 -> 13344
 13294  033EEH  046C0H      nop
 13296  033F0H  0A801H      add      r0,sp,#4
 13298  033F2H  046C0H      nop
 13300  033F4H  0A100H      adr      r1,pc,#0 -> 13304
 13302  033F6H  0E003H      b        6 -> 13312
 13304  033F8H  072617473H  "star"
 13308  033FCH  000000074H  "t"
 13312  03400H  0680AH      ldr      r2,[r1]
 13314  03402H  03104H      adds     r1,#4
 13316  03404H  06002H      str      r2,[r0]
 13318  03406H  03004H      adds     r0,#4
 13320  03408H  0680AH      ldr      r2,[r1]
 13322  0340AH  06002H      str      r2,[r0]
 13324  0340CH  0A805H      add      r0,sp,#20
 13326  0340EH  046C0H      nop
 13328  03410H  0A100H      adr      r1,pc,#0 -> 13332
 13330  03412H  0E001H      b        2 -> 13336
 13332  03414H  28789
 13336  03418H  0680AH      ldr      r2,[r1]
 13338  0341AH  06002H      str      r2,[r0]
 13340  0341CH  0E00FH      b        30 -> 13374
 13342  0341EH  046C0H      nop
 13344  03420H  09800H      ldr      r0,[sp]
 13346  03422H  02808H      cmp      r0,#8
 13348  03424H  0D301H      bcc.n    2 -> 13354
 13350  03426H  0DF01H      svc      1
 13352  03428H  0005EH      <LineNo: 94>
 13354  0342AH  0990AH      ldr      r1,[sp,#40]
 13356  0342CH  000C0H      lsls     r0,r0,#3
 13358  0342EH  01808H      adds     r0,r1,r0
 13360  03430H  06800H      ldr      r0,[r0]
 13362  03432H  0A901H      add      r1,sp,#4
 13364  03434H  0AA05H      add      r2,sp,#20
 13366  03436H  0F7FFFE97H  bl.w     RuntimeErrorsOu.GetName
 13370  0343AH  0E000H      b        0 -> 13374
 13372  0343CH  0005EH      <LineNo: 94>
 13374  0343EH  0E752H      b        -348 -> 13030
 13376  03440H  09800H      ldr      r0,[sp]
 13378  03442H  02808H      cmp      r0,#8
 13380  03444H  0D301H      bcc.n    2 -> 13386
 13382  03446H  0DF01H      svc      1
 13384  03448H  00061H      <LineNo: 97>
 13386  0344AH  0990AH      ldr      r1,[sp,#40]
 13388  0344CH  000C0H      lsls     r0,r0,#3
 13390  0344EH  01808H      adds     r0,r1,r0
 13392  03450H  06800H      ldr      r0,[r0]
 13394  03452H  02101H      movs     r1,#1
 13396  03454H  042C8H      cmn      r0,r1
 13398  03456H  0D001H      beq.n    2 -> 13404
 13400  03458H  0E01CH      b        56 -> 13460
 13402  0345AH  046C0H      nop
 13404  0345CH  09809H      ldr      r0,[sp,#36]
 13406  0345EH  02120H      movs     r1,#32
 13408  03460H  0F7FFFA2AH  bl.w     Texts.Write
 13412  03464H  0E000H      b        0 -> 13416
 13414  03466H  00062H      <LineNo: 98>
 13416  03468H  09809H      ldr      r0,[sp,#36]
 13418  0346AH  046C0H      nop
 13420  0346CH  0A100H      adr      r1,pc,#0 -> 13424
 13422  0346EH  0E007H      b        14 -> 13440
 13424  03470H  0202D2D2DH  "--- "
 13428  03474H  065726F6DH  "more"
 13432  03478H  02D2D2D20H  " ---"
 13436  0347CH  000000000H
 13440  03480H  0220DH      movs     r2,#13
 13442  03482H  0F7FFFA31H  bl.w     Texts.WriteString
 13446  03486H  0E000H      b        0 -> 13450
 13448  03488H  00062H      <LineNo: 98>
 13450  0348AH  09809H      ldr      r0,[sp,#36]
 13452  0348CH  0F7FFFA58H  bl.w     Texts.WriteLn
 13456  03490H  0E000H      b        0 -> 13460
 13458  03492H  00062H      <LineNo: 98>
 13460  03494H  0E014H      b        40 -> 13504
 13462  03496H  046C0H      nop
 13464  03498H  09809H      ldr      r0,[sp,#36]
 13466  0349AH  046C0H      nop
 13468  0349CH  0A100H      adr      r1,pc,#0 -> 13472
 13470  0349EH  0E005H      b        10 -> 13484
 13472  034A0H  074206F6EH  "no t"
 13476  034A4H  065636172H  "race"
 13480  034A8H  000000000H
 13484  034ACH  02209H      movs     r2,#9
 13486  034AEH  0F7FFFA1BH  bl.w     Texts.WriteString
 13490  034B2H  0E000H      b        0 -> 13494
 13492  034B4H  00065H      <LineNo: 101>
 13494  034B6H  09809H      ldr      r0,[sp,#36]
 13496  034B8H  0F7FFFA42H  bl.w     Texts.WriteLn
 13500  034BCH  0E000H      b        0 -> 13504
 13502  034BEH  00065H      <LineNo: 101>
 13504  034C0H  0B00CH      add      sp,#48
 13506  034C2H  0BD00H      pop      { pc }

PROCEDURE RuntimeErrorsOu.regOut:
 13508  034C4H  0B50FH      push     { r0, r1, r2, r3, lr }
 13510  034C6H  09800H      ldr      r0,[sp]
 13512  034C8H  02120H      movs     r1,#32
 13514  034CAH  0F7FFF9F5H  bl.w     Texts.Write
 13518  034CEH  0E000H      b        0 -> 13522
 13520  034D0H  0006CH      <LineNo: 108>
 13522  034D2H  09800H      ldr      r0,[sp]
 13524  034D4H  09901H      ldr      r1,[sp,#4]
 13526  034D6H  09A02H      ldr      r2,[sp,#8]
 13528  034D8H  0F7FFFA06H  bl.w     Texts.WriteString
 13532  034DCH  0E000H      b        0 -> 13536
 13534  034DEH  0006CH      <LineNo: 108>
 13536  034E0H  09800H      ldr      r0,[sp]
 13538  034E2H  09903H      ldr      r1,[sp,#12]
 13540  034E4H  0220AH      movs     r2,#10
 13542  034E6H  0F7FFFA89H  bl.w     Texts.WriteHex
 13546  034EAH  0E000H      b        0 -> 13550
 13548  034ECH  0006DH      <LineNo: 109>
 13550  034EEH  09800H      ldr      r0,[sp]
 13552  034F0H  0F7FFFA26H  bl.w     Texts.WriteLn
 13556  034F4H  0E000H      b        0 -> 13560
 13558  034F6H  0006EH      <LineNo: 110>
 13560  034F8H  0B004H      add      sp,#16
 13562  034FAH  0BD00H      pop      { pc }

PROCEDURE RuntimeErrorsOu.printStackedRegs:
 13564  034FCH  0B507H      push     { r0, r1, r2, lr }
 13566  034FEH  09800H      ldr      r0,[sp]
 13568  03500H  0A100H      adr      r1,pc,#0 -> 13572
 13570  03502H  0E009H      b        18 -> 13592
 13572  03504H  063617473H  "stac"
 13576  03508H  02064656BH  "ked "
 13580  0350CH  069676572H  "regi"
 13584  03510H  072657473H  "ster"
 13588  03514H  000003A73H  "s:"
 13592  03518H  02213H      movs     r2,#19
 13594  0351AH  0F7FFF9E5H  bl.w     Texts.WriteString
 13598  0351EH  0E000H      b        0 -> 13602
 13600  03520H  00074H      <LineNo: 116>
 13602  03522H  09800H      ldr      r0,[sp]
 13604  03524H  0F7FFFA0CH  bl.w     Texts.WriteLn
 13608  03528H  0E000H      b        0 -> 13612
 13610  0352AH  00074H      <LineNo: 116>
 13612  0352CH  09800H      ldr      r0,[sp]
 13614  0352EH  046C0H      nop
 13616  03530H  0A100H      adr      r1,pc,#0 -> 13620
 13618  03532H  0E003H      b        6 -> 13628
 13620  03534H  030722020H  "  r0"
 13624  03538H  00000003AH  ":"
 13628  0353CH  02206H      movs     r2,#6
 13630  0353EH  09B01H      ldr      r3,[sp,#4]
 13632  03540H  0681BH      ldr      r3,[r3]
 13634  03542H  0F7FFFFBFH  bl.w     RuntimeErrorsOu.regOut
 13638  03546H  0E000H      b        0 -> 13642
 13640  03548H  00075H      <LineNo: 117>
 13642  0354AH  09800H      ldr      r0,[sp]
 13644  0354CH  0A100H      adr      r1,pc,#0 -> 13648
 13646  0354EH  0E003H      b        6 -> 13656
 13648  03550H  031722020H  "  r1"
 13652  03554H  00000003AH  ":"
 13656  03558H  02206H      movs     r2,#6
 13658  0355AH  09B01H      ldr      r3,[sp,#4]
 13660  0355CH  0685BH      ldr      r3,[r3,#4]
 13662  0355EH  0F7FFFFB1H  bl.w     RuntimeErrorsOu.regOut
 13666  03562H  0E000H      b        0 -> 13670
 13668  03564H  00076H      <LineNo: 118>
 13670  03566H  09800H      ldr      r0,[sp]
 13672  03568H  0A100H      adr      r1,pc,#0 -> 13676
 13674  0356AH  0E003H      b        6 -> 13684
 13676  0356CH  032722020H  "  r2"
 13680  03570H  00000003AH  ":"
 13684  03574H  02206H      movs     r2,#6
 13686  03576H  09B01H      ldr      r3,[sp,#4]
 13688  03578H  0689BH      ldr      r3,[r3,#8]
 13690  0357AH  0F7FFFFA3H  bl.w     RuntimeErrorsOu.regOut
 13694  0357EH  0E000H      b        0 -> 13698
 13696  03580H  00077H      <LineNo: 119>
 13698  03582H  09800H      ldr      r0,[sp]
 13700  03584H  0A100H      adr      r1,pc,#0 -> 13704
 13702  03586H  0E003H      b        6 -> 13712
 13704  03588H  033722020H  "  r3"
 13708  0358CH  00000003AH  ":"
 13712  03590H  02206H      movs     r2,#6
 13714  03592H  09B01H      ldr      r3,[sp,#4]
 13716  03594H  068DBH      ldr      r3,[r3,#12]
 13718  03596H  0F7FFFF95H  bl.w     RuntimeErrorsOu.regOut
 13722  0359AH  0E000H      b        0 -> 13726
 13724  0359CH  00078H      <LineNo: 120>
 13726  0359EH  09800H      ldr      r0,[sp]
 13728  035A0H  0A100H      adr      r1,pc,#0 -> 13732
 13730  035A2H  0E003H      b        6 -> 13740
 13732  035A4H  032317220H  " r12"
 13736  035A8H  00000003AH  ":"
 13740  035ACH  02206H      movs     r2,#6
 13742  035AEH  09B01H      ldr      r3,[sp,#4]
 13744  035B0H  0691BH      ldr      r3,[r3,#16]
 13746  035B2H  0F7FFFF87H  bl.w     RuntimeErrorsOu.regOut
 13750  035B6H  0E000H      b        0 -> 13754
 13752  035B8H  00079H      <LineNo: 121>
 13754  035BAH  09800H      ldr      r0,[sp]
 13756  035BCH  0A100H      adr      r1,pc,#0 -> 13760
 13758  035BEH  0E003H      b        6 -> 13768
 13760  035C0H  0726C2020H  "  lr"
 13764  035C4H  00000003AH  ":"
 13768  035C8H  02206H      movs     r2,#6
 13770  035CAH  09B01H      ldr      r3,[sp,#4]
 13772  035CCH  0695BH      ldr      r3,[r3,#20]
 13774  035CEH  0F7FFFF79H  bl.w     RuntimeErrorsOu.regOut
 13778  035D2H  0E000H      b        0 -> 13782
 13780  035D4H  0007AH      <LineNo: 122>
 13782  035D6H  09800H      ldr      r0,[sp]
 13784  035D8H  0A100H      adr      r1,pc,#0 -> 13788
 13786  035DAH  0E003H      b        6 -> 13796
 13788  035DCH  063702020H  "  pc"
 13792  035E0H  00000003AH  ":"
 13796  035E4H  02206H      movs     r2,#6
 13798  035E6H  09B01H      ldr      r3,[sp,#4]
 13800  035E8H  0699BH      ldr      r3,[r3,#24]
 13802  035EAH  0F7FFFF6BH  bl.w     RuntimeErrorsOu.regOut
 13806  035EEH  0E000H      b        0 -> 13810
 13808  035F0H  0007BH      <LineNo: 123>
 13810  035F2H  09800H      ldr      r0,[sp]
 13812  035F4H  0A100H      adr      r1,pc,#0 -> 13816
 13814  035F6H  0E003H      b        6 -> 13824
 13816  035F8H  072737078H  "xpsr"
 13820  035FCH  00000003AH  ":"
 13824  03600H  02206H      movs     r2,#6
 13826  03602H  09B01H      ldr      r3,[sp,#4]
 13828  03604H  069DBH      ldr      r3,[r3,#28]
 13830  03606H  0F7FFFF5DH  bl.w     RuntimeErrorsOu.regOut
 13834  0360AH  0E000H      b        0 -> 13838
 13836  0360CH  0007CH      <LineNo: 124>
 13838  0360EH  09800H      ldr      r0,[sp]
 13840  03610H  0A100H      adr      r1,pc,#0 -> 13844
 13842  03612H  0E003H      b        6 -> 13852
 13844  03614H  070732020H  "  sp"
 13848  03618H  00000003AH  ":"
 13852  0361CH  02206H      movs     r2,#6
 13854  0361EH  09B01H      ldr      r3,[sp,#4]
 13856  03620H  06A1BH      ldr      r3,[r3,#32]
 13858  03622H  0F7FFFF4FH  bl.w     RuntimeErrorsOu.regOut
 13862  03626H  0E000H      b        0 -> 13866
 13864  03628H  0007DH      <LineNo: 125>
 13866  0362AH  0B003H      add      sp,#12
 13868  0362CH  0BD00H      pop      { pc }
 13870  0362EH  046C0H      nop

PROCEDURE RuntimeErrorsOu.printCurrentRegs:
 13872  03630H  0B507H      push     { r0, r1, r2, lr }
 13874  03632H  09800H      ldr      r0,[sp]
 13876  03634H  0A100H      adr      r1,pc,#0 -> 13880
 13878  03636H  0E009H      b        18 -> 13900
 13880  03638H  072727563H  "curr"
 13884  0363CH  020746E65H  "ent "
 13888  03640H  069676572H  "regi"
 13892  03644H  072657473H  "ster"
 13896  03648H  000003A73H  "s:"
 13900  0364CH  02213H      movs     r2,#19
 13902  0364EH  0F7FFF94BH  bl.w     Texts.WriteString
 13906  03652H  0E000H      b        0 -> 13910
 13908  03654H  00083H      <LineNo: 131>
 13910  03656H  09800H      ldr      r0,[sp]
 13912  03658H  0F7FFF972H  bl.w     Texts.WriteLn
 13916  0365CH  0E000H      b        0 -> 13920
 13918  0365EH  00083H      <LineNo: 131>
 13920  03660H  09800H      ldr      r0,[sp]
 13922  03662H  046C0H      nop
 13924  03664H  0A100H      adr      r1,pc,#0 -> 13928
 13926  03666H  0E003H      b        6 -> 13936
 13928  03668H  070732020H  "  sp"
 13932  0366CH  00000003AH  ":"
 13936  03670H  02206H      movs     r2,#6
 13938  03672H  09B01H      ldr      r3,[sp,#4]
 13940  03674H  0681BH      ldr      r3,[r3]
 13942  03676H  0F7FFFF25H  bl.w     RuntimeErrorsOu.regOut
 13946  0367AH  0E000H      b        0 -> 13950
 13948  0367CH  00084H      <LineNo: 132>
 13950  0367EH  09800H      ldr      r0,[sp]
 13952  03680H  0A100H      adr      r1,pc,#0 -> 13956
 13954  03682H  0E003H      b        6 -> 13964
 13956  03684H  0726C2020H  "  lr"
 13960  03688H  00000003AH  ":"
 13964  0368CH  02206H      movs     r2,#6
 13966  0368EH  09B01H      ldr      r3,[sp,#4]
 13968  03690H  0685BH      ldr      r3,[r3,#4]
 13970  03692H  0F7FFFF17H  bl.w     RuntimeErrorsOu.regOut
 13974  03696H  0E000H      b        0 -> 13978
 13976  03698H  00085H      <LineNo: 133>
 13978  0369AH  09800H      ldr      r0,[sp]
 13980  0369CH  0A100H      adr      r1,pc,#0 -> 13984
 13982  0369EH  0E003H      b        6 -> 13992
 13984  036A0H  063702020H  "  pc"
 13988  036A4H  00000003AH  ":"
 13992  036A8H  02206H      movs     r2,#6
 13994  036AAH  09B01H      ldr      r3,[sp,#4]
 13996  036ACH  0689BH      ldr      r3,[r3,#8]
 13998  036AEH  0F7FFFF09H  bl.w     RuntimeErrorsOu.regOut
 14002  036B2H  0E000H      b        0 -> 14006
 14004  036B4H  00086H      <LineNo: 134>
 14006  036B6H  09800H      ldr      r0,[sp]
 14008  036B8H  0A100H      adr      r1,pc,#0 -> 14012
 14010  036BAH  0E003H      b        6 -> 14020
 14012  036BCH  072737078H  "xpsr"
 14016  036C0H  00000003AH  ":"
 14020  036C4H  02206H      movs     r2,#6
 14022  036C6H  09B01H      ldr      r3,[sp,#4]
 14024  036C8H  068DBH      ldr      r3,[r3,#12]
 14026  036CAH  0F7FFFEFBH  bl.w     RuntimeErrorsOu.regOut
 14030  036CEH  0E000H      b        0 -> 14034
 14032  036D0H  00087H      <LineNo: 135>
 14034  036D2H  0B003H      add      sp,#12
 14036  036D4H  0BD00H      pop      { pc }
 14038  036D6H  046C0H      nop

PROCEDURE RuntimeErrorsOu.PrintException:
 14040  036D8H  0B507H      push     { r0, r1, r2, lr }
 14042  036DAH  0B09CH      sub      sp,#112
 14044  036DCH  0A81DH      add      r0,sp,#116
 14046  036DEH  06840H      ldr      r0,[r0,#4]
 14048  036E0H  04971H      ldr      r1,[pc,#452] -> 14504
 14050  036E2H  04288H      cmp      r0,r1
 14052  036E4H  0D001H      beq.n    2 -> 14058
 14054  036E6H  0E00EH      b        28 -> 14086
 14056  036E8H  046C0H      nop
 14058  036EAH  0981DH      ldr      r0,[sp,#116]
 14060  036ECH  06800H      ldr      r0,[r0]
 14062  036EEH  04240H      rsbs     r0,r0,#0
 14064  036F0H  09000H      str      r0,[sp]
 14066  036F2H  0981DH      ldr      r0,[sp,#116]
 14068  036F4H  06840H      ldr      r0,[r0,#4]
 14070  036F6H  09001H      str      r0,[sp,#4]
 14072  036F8H  0981DH      ldr      r0,[sp,#116]
 14074  036FAH  06880H      ldr      r0,[r0,#8]
 14076  036FCH  09002H      str      r0,[sp,#8]
 14078  036FEH  04869H      ldr      r0,[pc,#420] -> 14500
 14080  03700H  09003H      str      r0,[sp,#12]
 14082  03702H  0E013H      b        38 -> 14124
 14084  03704H  046C0H      nop
 14086  03706H  0A81DH      add      r0,sp,#116
 14088  03708H  06840H      ldr      r0,[r0,#4]
 14090  0370AH  04968H      ldr      r1,[pc,#416] -> 14508
 14092  0370CH  04288H      cmp      r0,r1
 14094  0370EH  0D001H      beq.n    2 -> 14100
 14096  03710H  0E00CH      b        24 -> 14124
 14098  03712H  046C0H      nop
 14100  03714H  0981DH      ldr      r0,[sp,#116]
 14102  03716H  06800H      ldr      r0,[r0]
 14104  03718H  09000H      str      r0,[sp]
 14106  0371AH  0981DH      ldr      r0,[sp,#116]
 14108  0371CH  06840H      ldr      r0,[r0,#4]
 14110  0371EH  09001H      str      r0,[sp,#4]
 14112  03720H  0981DH      ldr      r0,[sp,#116]
 14114  03722H  06880H      ldr      r0,[r0,#8]
 14116  03724H  09002H      str      r0,[sp,#8]
 14118  03726H  0981DH      ldr      r0,[sp,#116]
 14120  03728H  068C0H      ldr      r0,[r0,#12]
 14122  0372AH  09003H      str      r0,[sp,#12]
 14124  0372CH  09800H      ldr      r0,[sp]
 14126  0372EH  0A90CH      add      r1,sp,#48
 14128  03730H  0F7FDFB4AH  bl.w     Errors.GetExceptionType
 14132  03734H  0E000H      b        0 -> 14136
 14134  03736H  0009DH      <LineNo: 157>
 14136  03738H  0981CH      ldr      r0,[sp,#112]
 14138  0373AH  046C0H      nop
 14140  0373CH  0A100H      adr      r1,pc,#0 -> 14144
 14142  0373EH  0E005H      b        10 -> 14156
 14144  03740H  065637865H  "exce"
 14148  03744H  06F697470H  "ptio"
 14152  03748H  000203A6EH  "n: "
 14156  0374CH  0220CH      movs     r2,#12
 14158  0374EH  0F7FFF8CBH  bl.w     Texts.WriteString
 14162  03752H  0E000H      b        0 -> 14166
 14164  03754H  0009EH      <LineNo: 158>
 14166  03756H  0981CH      ldr      r0,[sp,#112]
 14168  03758H  0A90CH      add      r1,sp,#48
 14170  0375AH  02240H      movs     r2,#64
 14172  0375CH  0F7FFF8C4H  bl.w     Texts.WriteString
 14176  03760H  0E000H      b        0 -> 14180
 14178  03762H  0009EH      <LineNo: 158>
 14180  03764H  09800H      ldr      r0,[sp]
 14182  03766H  0A90CH      add      r1,sp,#48
 14184  03768H  0F7FDFB18H  bl.w     Errors.Msg
 14188  0376CH  0E000H      b        0 -> 14192
 14190  0376EH  0009FH      <LineNo: 159>
 14192  03770H  0981CH      ldr      r0,[sp,#112]
 14194  03772H  02120H      movs     r1,#32
 14196  03774H  0F7FFF8A0H  bl.w     Texts.Write
 14200  03778H  0E000H      b        0 -> 14204
 14202  0377AH  000A0H      <LineNo: 160>
 14204  0377CH  0981CH      ldr      r0,[sp,#112]
 14206  0377EH  09900H      ldr      r1,[sp]
 14208  03780H  02200H      movs     r2,#0
 14210  03782H  0F7FFF923H  bl.w     Texts.WriteInt
 14214  03786H  0E000H      b        0 -> 14218
 14216  03788H  000A0H      <LineNo: 160>
 14218  0378AH  0981CH      ldr      r0,[sp,#112]
 14220  0378CH  0A100H      adr      r1,pc,#0 -> 14224
 14222  0378EH  0E003H      b        6 -> 14232
 14224  03790H  0726F6320H  " cor"
 14228  03794H  000203A65H  "e: "
 14232  03798H  02208H      movs     r2,#8
 14234  0379AH  0F7FFF8A5H  bl.w     Texts.WriteString
 14238  0379EH  0E000H      b        0 -> 14242
 14240  037A0H  000A0H      <LineNo: 160>
 14242  037A2H  0981CH      ldr      r0,[sp,#112]
 14244  037A4H  09901H      ldr      r1,[sp,#4]
 14246  037A6H  02200H      movs     r2,#0
 14248  037A8H  0F7FFF910H  bl.w     Texts.WriteInt
 14252  037ACH  0E000H      b        0 -> 14256
 14254  037AEH  000A1H      <LineNo: 161>
 14256  037B0H  0981CH      ldr      r0,[sp,#112]
 14258  037B2H  0F7FFF8C5H  bl.w     Texts.WriteLn
 14262  037B6H  0E000H      b        0 -> 14266
 14264  037B8H  000A1H      <LineNo: 161>
 14266  037BAH  0981CH      ldr      r0,[sp,#112]
 14268  037BCH  0A90CH      add      r1,sp,#48
 14270  037BEH  02240H      movs     r2,#64
 14272  037C0H  0F7FFF892H  bl.w     Texts.WriteString
 14276  037C4H  0E000H      b        0 -> 14280
 14278  037C6H  000A2H      <LineNo: 162>
 14280  037C8H  0981CH      ldr      r0,[sp,#112]
 14282  037CAH  0F7FFF8B9H  bl.w     Texts.WriteLn
 14286  037CEH  0E000H      b        0 -> 14290
 14288  037D0H  000A2H      <LineNo: 162>
 14290  037D2H  09802H      ldr      r0,[sp,#8]
 14292  037D4H  0A904H      add      r1,sp,#16
 14294  037D6H  0AA08H      add      r2,sp,#32
 14296  037D8H  0F7FFFCC6H  bl.w     RuntimeErrorsOu.GetName
 14300  037DCH  0E000H      b        0 -> 14304
 14302  037DEH  000A3H      <LineNo: 163>
 14304  037E0H  0981CH      ldr      r0,[sp,#112]
 14306  037E2H  0A904H      add      r1,sp,#16
 14308  037E4H  02210H      movs     r2,#16
 14310  037E6H  0F7FFF87FH  bl.w     Texts.WriteString
 14314  037EAH  0E000H      b        0 -> 14318
 14316  037ECH  000A4H      <LineNo: 164>
 14318  037EEH  0981CH      ldr      r0,[sp,#112]
 14320  037F0H  0212EH      movs     r1,#46
 14322  037F2H  0F7FFF861H  bl.w     Texts.Write
 14326  037F6H  0E000H      b        0 -> 14330
 14328  037F8H  000A4H      <LineNo: 164>
 14330  037FAH  0981CH      ldr      r0,[sp,#112]
 14332  037FCH  0A908H      add      r1,sp,#32
 14334  037FEH  02210H      movs     r2,#16
 14336  03800H  0F7FFF872H  bl.w     Texts.WriteString
 14340  03804H  0E000H      b        0 -> 14344
 14342  03806H  000A4H      <LineNo: 164>
 14344  03808H  0981CH      ldr      r0,[sp,#112]
 14346  0380AH  046C0H      nop
 14348  0380CH  0A100H      adr      r1,pc,#0 -> 14352
 14350  0380EH  0E003H      b        6 -> 14360
 14352  03810H  03A612020H  "  a:"
 14356  03814H  000000020H  " "
 14360  03818H  02206H      movs     r2,#6
 14362  0381AH  0F7FFF865H  bl.w     Texts.WriteString
 14366  0381EH  0E000H      b        0 -> 14370
 14368  03820H  000A5H      <LineNo: 165>
 14370  03822H  0981CH      ldr      r0,[sp,#112]
 14372  03824H  09902H      ldr      r1,[sp,#8]
 14374  03826H  02200H      movs     r2,#0
 14376  03828H  0F7FFF8E8H  bl.w     Texts.WriteHex
 14380  0382CH  0E000H      b        0 -> 14384
 14382  0382EH  000A5H      <LineNo: 165>
 14384  03830H  09803H      ldr      r0,[sp,#12]
 14386  03832H  02101H      movs     r1,#1
 14388  03834H  042C8H      cmn      r0,r1
 14390  03836H  0D101H      bne.n    2 -> 14396
 14392  03838H  0E014H      b        40 -> 14436
 14394  0383AH  046C0H      nop
 14396  0383CH  0981CH      ldr      r0,[sp,#112]
 14398  0383EH  046C0H      nop
 14400  03840H  0A100H      adr      r1,pc,#0 -> 14404
 14402  03842H  0E003H      b        6 -> 14412
 14404  03844H  06E6C2020H  "  ln"
 14408  03848H  00000203AH  ": "
 14412  0384CH  02207H      movs     r2,#7
 14414  0384EH  0F7FFF84BH  bl.w     Texts.WriteString
 14418  03852H  0E000H      b        0 -> 14422
 14420  03854H  000A7H      <LineNo: 167>
 14422  03856H  0981CH      ldr      r0,[sp,#112]
 14424  03858H  09903H      ldr      r1,[sp,#12]
 14426  0385AH  02200H      movs     r2,#0
 14428  0385CH  0F7FFF8B6H  bl.w     Texts.WriteInt
 14432  03860H  0E000H      b        0 -> 14436
 14434  03862H  000A7H      <LineNo: 167>
 14436  03864H  0981CH      ldr      r0,[sp,#112]
 14438  03866H  0F7FFF86BH  bl.w     Texts.WriteLn
 14442  0386AH  0E000H      b        0 -> 14446
 14444  0386CH  000A9H      <LineNo: 169>
 14446  0386EH  0A81DH      add      r0,sp,#116
 14448  03870H  06840H      ldr      r0,[r0,#4]
 14450  03872H  0490EH      ldr      r1,[pc,#56] -> 14508
 14452  03874H  04288H      cmp      r0,r1
 14454  03876H  0D001H      beq.n    2 -> 14460
 14456  03878H  0E025H      b        74 -> 14534
 14458  0387AH  046C0H      nop
 14460  0387CH  0981CH      ldr      r0,[sp,#112]
 14462  0387EH  0991DH      ldr      r1,[sp,#116]
 14464  03880H  03108H      adds     r1,#8
 14466  03882H  0AA1EH      add      r2,sp,#120
 14468  03884H  06812H      ldr      r2,[r2]
 14470  03886H  0F7FFFD03H  bl.w     RuntimeErrorsOu.printStackTrace
 14474  0388AH  0E000H      b        0 -> 14478
 14476  0388CH  000ACH      <LineNo: 172>
 14478  0388EH  0981CH      ldr      r0,[sp,#112]
 14480  03890H  0991DH      ldr      r1,[sp,#116]
 14482  03892H  0314CH      adds     r1,#76
 14484  03894H  0AA1EH      add      r2,sp,#120
 14486  03896H  06812H      ldr      r2,[r2]
 14488  03898H  0F7FFFE30H  bl.w     RuntimeErrorsOu.printStackedRegs
 14492  0389CH  0E000H      b        0 -> 14496
 14494  0389EH  000ADH      <LineNo: 173>
 14496  038A0H  0F000F806H  bl.w     RuntimeErrorsOu.PrintException + 472
 14500  038A4H  -1
 14504  038A8H  010001BF8H
 14508  038ACH  010001C0CH
 14512  038B0H  0981CH      ldr      r0,[sp,#112]
 14514  038B2H  0991DH      ldr      r1,[sp,#116]
 14516  038B4H  03170H      adds     r1,#112
 14518  038B6H  0AA1EH      add      r2,sp,#120
 14520  038B8H  06812H      ldr      r2,[r2]
 14522  038BAH  0F7FFFEB9H  bl.w     RuntimeErrorsOu.printCurrentRegs
 14526  038BEH  0E000H      b        0 -> 14530
 14528  038C0H  000AEH      <LineNo: 174>
 14530  038C2H  0E019H      b        50 -> 14584
 14532  038C4H  046C0H      nop
 14534  038C6H  0A81DH      add      r0,sp,#116
 14536  038C8H  06840H      ldr      r0,[r0,#4]
 14538  038CAH  0490CH      ldr      r1,[pc,#48] -> 14588
 14540  038CCH  04288H      cmp      r0,r1
 14542  038CEH  0D001H      beq.n    2 -> 14548
 14544  038D0H  0E012H      b        36 -> 14584
 14546  038D2H  046C0H      nop
 14548  038D4H  0981CH      ldr      r0,[sp,#112]
 14550  038D6H  0991DH      ldr      r1,[sp,#116]
 14552  038D8H  0310CH      adds     r1,#12
 14554  038DAH  0AA1EH      add      r2,sp,#120
 14556  038DCH  06812H      ldr      r2,[r2]
 14558  038DEH  0F7FFFE0DH  bl.w     RuntimeErrorsOu.printStackedRegs
 14562  038E2H  0E000H      b        0 -> 14566
 14564  038E4H  000B0H      <LineNo: 176>
 14566  038E6H  0981CH      ldr      r0,[sp,#112]
 14568  038E8H  0991DH      ldr      r1,[sp,#116]
 14570  038EAH  03130H      adds     r1,#48
 14572  038ECH  0AA1EH      add      r2,sp,#120
 14574  038EEH  06812H      ldr      r2,[r2]
 14576  038F0H  0F7FFFE9EH  bl.w     RuntimeErrorsOu.printCurrentRegs
 14580  038F4H  0E000H      b        0 -> 14584
 14582  038F6H  000B1H      <LineNo: 177>
 14584  038F8H  0B01FH      add      sp,#124
 14586  038FAH  0BD00H      pop      { pc }
 14588  038FCH  010001BF8H

PROCEDURE RuntimeErrorsOu.HandleException:
 14592  03900H  0B507H      push     { r0, r1, r2, lr }
 14594  03902H  09800H      ldr      r0,[sp]
 14596  03904H  02802H      cmp      r0,#2
 14598  03906H  0DB01H      blt.n    2 -> 14604
 14600  03908H  0DF65H      svc      101
 14602  0390AH  000BAH      <LineNo: 186>
 14604  0390CH  09800H      ldr      r0,[sp]
 14606  0390EH  02802H      cmp      r0,#2
 14608  03910H  0D301H      bcc.n    2 -> 14614
 14610  03912H  0DF01H      svc      1
 14612  03914H  000BBH      <LineNo: 187>
 14614  03916H  04906H      ldr      r1,[pc,#24] -> 14640
 14616  03918H  00080H      lsls     r0,r0,#2
 14618  0391AH  01808H      adds     r0,r1,r0
 14620  0391CH  06800H      ldr      r0,[r0]
 14622  0391EH  09901H      ldr      r1,[sp,#4]
 14624  03920H  0AA02H      add      r2,sp,#8
 14626  03922H  06812H      ldr      r2,[r2]
 14628  03924H  0F7FFFED8H  bl.w     RuntimeErrorsOu.PrintException
 14632  03928H  0E000H      b        0 -> 14636
 14634  0392AH  000BBH      <LineNo: 187>
 14636  0392CH  0B003H      add      sp,#12
 14638  0392EH  0BD00H      pop      { pc }
 14640  03930H  02002FCC4H

PROCEDURE RuntimeErrorsOu.SetWriter:
 14644  03934H  0B503H      push     { r0, r1, lr }
 14646  03936H  09800H      ldr      r0,[sp]
 14648  03938H  02802H      cmp      r0,#2
 14650  0393AH  0DB01H      blt.n    2 -> 14656
 14652  0393CH  0DF65H      svc      101
 14654  0393EH  000C2H      <LineNo: 194>
 14656  03940H  09800H      ldr      r0,[sp]
 14658  03942H  02802H      cmp      r0,#2
 14660  03944H  0D301H      bcc.n    2 -> 14666
 14662  03946H  0DF01H      svc      1
 14664  03948H  000C3H      <LineNo: 195>
 14666  0394AH  04903H      ldr      r1,[pc,#12] -> 14680
 14668  0394CH  00080H      lsls     r0,r0,#2
 14670  0394EH  01808H      adds     r0,r1,r0
 14672  03950H  09901H      ldr      r1,[sp,#4]
 14674  03952H  06001H      str      r1,[r0]
 14676  03954H  0B002H      add      sp,#8
 14678  03956H  0BD00H      pop      { pc }
 14680  03958H  02002FCC4H

PROCEDURE RuntimeErrorsOu..init:
 14684  0395CH  0B500H      push     { lr }
 14686  0395EH  0BD00H      pop      { pc }

MODULE UARTdev:
 14688  03960H  0
 14692  03964H  64
 14696  03968H  010003964H
 14700  0396CH  0
 14704  03970H  0
 14708  03974H  0
 14712  03978H  28
 14716  0397CH  0
 14720  03980H  0
 14724  03984H  0
 14728  03988H  0

PROCEDURE UARTdev.Init:
 14732  0398CH  0B503H      push     { r0, r1, lr }
 14734  0398EH  0B081H      sub      sp,#4
 14736  03990H  09801H      ldr      r0,[sp,#4]
 14738  03992H  02800H      cmp      r0,#0
 14740  03994H  0D101H      bne.n    2 -> 14746
 14742  03996H  0DF65H      svc      101
 14744  03998H  00079H      <LineNo: 121>
 14746  0399AH  02003H      movs     r0,#3
 14748  0399CH  09902H      ldr      r1,[sp,#8]
 14750  0399EH  02201H      movs     r2,#1
 14752  039A0H  0408AH      lsls     r2,r1
 14754  039A2H  04210H      tst      r0,r2
 14756  039A4H  0D101H      bne.n    2 -> 14762
 14758  039A6H  0DF00H      svc      0
 14760  039A8H  0007AH      <LineNo: 122>
 14762  039AAH  09802H      ldr      r0,[sp,#8]
 14764  039ACH  09901H      ldr      r1,[sp,#4]
 14766  039AEH  06008H      str      r0,[r1]
 14768  039B0H  09802H      ldr      r0,[sp,#8]
 14770  039B2H  04601H      mov      r1,r0
 14772  039B4H  046C0H      nop
 14774  039B6H  02901H      cmp      r1,#1
 14776  039B8H  0DD01H      ble.n    2 -> 14782
 14778  039BAH  0DF04H      svc      4
 14780  039BCH  0007CH      <LineNo: 124>
 14782  039BEH  00049H      lsls     r1,r1,#1
 14784  039C0H  04A01H      ldr      r2,[pc,#4] -> 14792
 14786  039C2H  01852H      adds     r2,r2,r1
 14788  039C4H  0447AH      add      r2,pc
 14790  039C6H  04710H      bx       r2
 14792  039C8H  45
 14796  039CCH  04825H      ldr      r0,[pc,#148] -> 14948
 14798  039CEH  09000H      str      r0,[sp]
 14800  039D0H  02016H      movs     r0,#22
 14802  039D2H  09901H      ldr      r1,[sp,#4]
 14804  039D4H  06048H      str      r0,[r1,#4]
 14806  039D6H  02014H      movs     r0,#20
 14808  039D8H  09901H      ldr      r1,[sp,#4]
 14810  039DAH  06088H      str      r0,[r1,#8]
 14812  039DCH  0E00CH      b        24 -> 14840
 14814  039DEH  046C0H      nop
 14816  039E0H  04821H      ldr      r0,[pc,#132] -> 14952
 14818  039E2H  09000H      str      r0,[sp]
 14820  039E4H  02017H      movs     r0,#23
 14822  039E6H  09901H      ldr      r1,[sp,#4]
 14824  039E8H  06048H      str      r0,[r1,#4]
 14826  039EAH  02015H      movs     r0,#21
 14828  039ECH  09901H      ldr      r1,[sp,#4]
 14830  039EEH  06088H      str      r0,[r1,#8]
 14832  039F0H  0E002H      b        4 -> 14840
 14834  039F2H  046C0H      nop
 14836  039F4H  0E7EAH      b        -44 -> 14796
 14838  039F6H  0E7F3H      b        -26 -> 14816
 14840  039F8H  09800H      ldr      r0,[sp]
 14842  039FAH  03030H      adds     r0,#48
 14844  039FCH  09901H      ldr      r1,[sp,#4]
 14846  039FEH  060C8H      str      r0,[r1,#12]
 14848  03A00H  09800H      ldr      r0,[sp]
 14850  03A02H  03024H      adds     r0,#36
 14852  03A04H  09901H      ldr      r1,[sp,#4]
 14854  03A06H  06108H      str      r0,[r1,#16]
 14856  03A08H  09800H      ldr      r0,[sp]
 14858  03A0AH  03028H      adds     r0,#40
 14860  03A0CH  09901H      ldr      r1,[sp,#4]
 14862  03A0EH  06148H      str      r0,[r1,#20]
 14864  03A10H  09800H      ldr      r0,[sp]
 14866  03A12H  0302CH      adds     r0,#44
 14868  03A14H  09901H      ldr      r1,[sp,#4]
 14870  03A16H  06188H      str      r0,[r1,#24]
 14872  03A18H  09800H      ldr      r0,[sp]
 14874  03A1AH  03000H      adds     r0,#0
 14876  03A1CH  09901H      ldr      r1,[sp,#4]
 14878  03A1EH  061C8H      str      r0,[r1,#28]
 14880  03A20H  09800H      ldr      r0,[sp]
 14882  03A22H  03000H      adds     r0,#0
 14884  03A24H  09901H      ldr      r1,[sp,#4]
 14886  03A26H  06208H      str      r0,[r1,#32]
 14888  03A28H  09800H      ldr      r0,[sp]
 14890  03A2AH  03018H      adds     r0,#24
 14892  03A2CH  09901H      ldr      r1,[sp,#4]
 14894  03A2EH  06248H      str      r0,[r1,#36]
 14896  03A30H  09800H      ldr      r0,[sp]
 14898  03A32H  03004H      adds     r0,#4
 14900  03A34H  09901H      ldr      r1,[sp,#4]
 14902  03A36H  06288H      str      r0,[r1,#40]
 14904  03A38H  09800H      ldr      r0,[sp]
 14906  03A3AH  03048H      adds     r0,#72
 14908  03A3CH  09901H      ldr      r1,[sp,#4]
 14910  03A3EH  062C8H      str      r0,[r1,#44]
 14912  03A40H  09800H      ldr      r0,[sp]
 14914  03A42H  03034H      adds     r0,#52
 14916  03A44H  09901H      ldr      r1,[sp,#4]
 14918  03A46H  06308H      str      r0,[r1,#48]
 14920  03A48H  09800H      ldr      r0,[sp]
 14922  03A4AH  03038H      adds     r0,#56
 14924  03A4CH  09901H      ldr      r1,[sp,#4]
 14926  03A4EH  06348H      str      r0,[r1,#52]
 14928  03A50H  09800H      ldr      r0,[sp]
 14930  03A52H  03040H      adds     r0,#64
 14932  03A54H  09901H      ldr      r1,[sp,#4]
 14934  03A56H  06388H      str      r0,[r1,#56]
 14936  03A58H  09800H      ldr      r0,[sp]
 14938  03A5AH  03044H      adds     r0,#68
 14940  03A5CH  09901H      ldr      r1,[sp,#4]
 14942  03A5EH  063C8H      str      r0,[r1,#60]
 14944  03A60H  0B003H      add      sp,#12
 14946  03A62H  0BD00H      pop      { pc }
 14948  03A64H  040034000H
 14952  03A68H  040038000H

PROCEDURE UARTdev.Configure:
 14956  03A6CH  0B50FH      push     { r0, r1, r2, r3, lr }
 14958  03A6EH  0B083H      sub      sp,#12
 14960  03A70H  09803H      ldr      r0,[sp,#12]
 14962  03A72H  02800H      cmp      r0,#0
 14964  03A74H  0D101H      bne.n    2 -> 14970
 14966  03A76H  0DF65H      svc      101
 14968  03A78H  00096H      <LineNo: 150>
 14970  03A7AH  02003H      movs     r0,#3
 14972  03A7CH  09904H      ldr      r1,[sp,#16]
 14974  03A7EH  06809H      ldr      r1,[r1]
 14976  03A80H  02201H      movs     r2,#1
 14978  03A82H  0408AH      lsls     r2,r1
 14980  03A84H  04210H      tst      r0,r2
 14982  03A86H  0D101H      bne.n    2 -> 14988
 14984  03A88H  0DF65H      svc      101
 14986  03A8AH  00097H      <LineNo: 151>
 14988  03A8CH  0200FH      movs     r0,#15
 14990  03A8EH  09904H      ldr      r1,[sp,#16]
 14992  03A90H  06849H      ldr      r1,[r1,#4]
 14994  03A92H  02201H      movs     r2,#1
 14996  03A94H  0408AH      lsls     r2,r1
 14998  03A96H  04210H      tst      r0,r2
 15000  03A98H  0D101H      bne.n    2 -> 15006
 15002  03A9AH  0DF65H      svc      101
 15004  03A9CH  00098H      <LineNo: 152>
 15006  03A9EH  02003H      movs     r0,#3
 15008  03AA0H  09904H      ldr      r1,[sp,#16]
 15010  03AA2H  06889H      ldr      r1,[r1,#8]
 15012  03AA4H  02201H      movs     r2,#1
 15014  03AA6H  0408AH      lsls     r2,r1
 15016  03AA8H  04210H      tst      r0,r2
 15018  03AAAH  0D101H      bne.n    2 -> 15024
 15020  03AACH  0DF65H      svc      101
 15022  03AAEH  00099H      <LineNo: 153>
 15024  03AB0H  02003H      movs     r0,#3
 15026  03AB2H  09904H      ldr      r1,[sp,#16]
 15028  03AB4H  068C9H      ldr      r1,[r1,#12]
 15030  03AB6H  02201H      movs     r2,#1
 15032  03AB8H  0408AH      lsls     r2,r1
 15034  03ABAH  04210H      tst      r0,r2
 15036  03ABCH  0D101H      bne.n    2 -> 15042
 15038  03ABEH  0DF65H      svc      101
 15040  03AC0H  0009AH      <LineNo: 154>
 15042  03AC2H  02003H      movs     r0,#3
 15044  03AC4H  09904H      ldr      r1,[sp,#16]
 15046  03AC6H  06909H      ldr      r1,[r1,#16]
 15048  03AC8H  02201H      movs     r2,#1
 15050  03ACAH  0408AH      lsls     r2,r1
 15052  03ACCH  04210H      tst      r0,r2
 15054  03ACEH  0D101H      bne.n    2 -> 15060
 15056  03AD0H  0DF65H      svc      101
 15058  03AD2H  0009BH      <LineNo: 155>
 15060  03AD4H  02003H      movs     r0,#3
 15062  03AD6H  09904H      ldr      r1,[sp,#16]
 15064  03AD8H  06949H      ldr      r1,[r1,#20]
 15066  03ADAH  02201H      movs     r2,#1
 15068  03ADCH  0408AH      lsls     r2,r1
 15070  03ADEH  04210H      tst      r0,r2
 15072  03AE0H  0D101H      bne.n    2 -> 15078
 15074  03AE2H  0DF65H      svc      101
 15076  03AE4H  0009CH      <LineNo: 156>
 15078  03AE6H  02003H      movs     r0,#3
 15080  03AE8H  09904H      ldr      r1,[sp,#16]
 15082  03AEAH  06989H      ldr      r1,[r1,#24]
 15084  03AECH  02201H      movs     r2,#1
 15086  03AEEH  0408AH      lsls     r2,r1
 15088  03AF0H  04210H      tst      r0,r2
 15090  03AF2H  0D101H      bne.n    2 -> 15096
 15092  03AF4H  0DF65H      svc      101
 15094  03AF6H  0009DH      <LineNo: 157>
 15096  03AF8H  09803H      ldr      r0,[sp,#12]
 15098  03AFAH  06840H      ldr      r0,[r0,#4]
 15100  03AFCH  0F7FCFCD8H  bl.w     StartUp.ReleaseReset
 15104  03B00H  0E000H      b        0 -> 15108
 15106  03B02H  000A0H      <LineNo: 160>
 15108  03B04H  09803H      ldr      r0,[sp,#12]
 15110  03B06H  06840H      ldr      r0,[r0,#4]
 15112  03B08H  0F7FCFCECH  bl.w     StartUp.AwaitReleaseDone
 15116  03B0CH  0E000H      b        0 -> 15120
 15118  03B0EH  000A1H      <LineNo: 161>
 15120  03B10H  09803H      ldr      r0,[sp,#12]
 15122  03B12H  068C0H      ldr      r0,[r0,#12]
 15124  03B14H  02100H      movs     r1,#0
 15126  03B16H  06001H      str      r1,[r0]
 15128  03B18H  04840H      ldr      r0,[pc,#256] -> 15388
 15130  03B1AH  09906H      ldr      r1,[sp,#24]
 15132  03B1CH  02900H      cmp      r1,#0
 15134  03B1EH  0DC01H      bgt.n    2 -> 15140
 15136  03B20H  0DF07H      svc      7
 15138  03B22H  000A7H      <LineNo: 167>
 15140  03B24H  02401H      movs     r4,#1
 15142  03B26H  007E4H      lsls     r4,r4,#31
 15144  03B28H  02200H      movs     r2,#0
 15146  03B2AH  02300H      movs     r3,#0
 15148  03B2CH  00040H      lsls     r0,r0,#1
 15150  03B2EH  0415BH      adcs     r3,r3
 15152  03B30H  0428BH      cmp      r3,r1
 15154  03B32H  0D301H      bcc.n    2 -> 15160
 15156  03B34H  01912H      adds     r2,r2,r4
 15158  03B36H  01A5BH      subs     r3,r3,r1
 15160  03B38H  00864H      lsrs     r4,r4,#1
 15162  03B3AH  0D1F7H      bne.n    -18 -> 15148
 15164  03B3CH  04610H      mov      r0,r2
 15166  03B3EH  09000H      str      r0,[sp]
 15168  03B40H  09800H      ldr      r0,[sp]
 15170  03B42H  009C0H      lsrs     r0,r0,#7
 15172  03B44H  09001H      str      r0,[sp,#4]
 15174  03B46H  09801H      ldr      r0,[sp,#4]
 15176  03B48H  02800H      cmp      r0,#0
 15178  03B4AH  0D001H      beq.n    2 -> 15184
 15180  03B4CH  0E006H      b        12 -> 15196
 15182  03B4EH  046C0H      nop
 15184  03B50H  02001H      movs     r0,#1
 15186  03B52H  09001H      str      r0,[sp,#4]
 15188  03B54H  02000H      movs     r0,#0
 15190  03B56H  09002H      str      r0,[sp,#8]
 15192  03B58H  0E012H      b        36 -> 15232
 15194  03B5AH  046C0H      nop
 15196  03B5CH  09801H      ldr      r0,[sp,#4]
 15198  03B5EH  04930H      ldr      r1,[pc,#192] -> 15392
 15200  03B60H  04288H      cmp      r0,r1
 15202  03B62H  0DA01H      bge.n    2 -> 15208
 15204  03B64H  0E006H      b        12 -> 15220
 15206  03B66H  046C0H      nop
 15208  03B68H  0482DH      ldr      r0,[pc,#180] -> 15392
 15210  03B6AH  09001H      str      r0,[sp,#4]
 15212  03B6CH  02000H      movs     r0,#0
 15214  03B6EH  09002H      str      r0,[sp,#8]
 15216  03B70H  0E006H      b        12 -> 15232
 15218  03B72H  046C0H      nop
 15220  03B74H  09801H      ldr      r0,[sp,#4]
 15222  03B76H  00600H      lsls     r0,r0,#24
 15224  03B78H  00E00H      lsrs     r0,r0,#24
 15226  03B7AH  03001H      adds     r0,#1
 15228  03B7CH  01040H      asrs     r0,r0,#1
 15230  03B7EH  09002H      str      r0,[sp,#8]
 15232  03B80H  09803H      ldr      r0,[sp,#12]
 15234  03B82H  06900H      ldr      r0,[r0,#16]
 15236  03B84H  09901H      ldr      r1,[sp,#4]
 15238  03B86H  06001H      str      r1,[r0]
 15240  03B88H  09803H      ldr      r0,[sp,#12]
 15242  03B8AH  06940H      ldr      r0,[r0,#20]
 15244  03B8CH  09902H      ldr      r1,[sp,#8]
 15246  03B8EH  06001H      str      r1,[r0]
 15248  03B90H  02000H      movs     r0,#0
 15250  03B92H  09000H      str      r0,[sp]
 15252  03B94H  09804H      ldr      r0,[sp,#16]
 15254  03B96H  06800H      ldr      r0,[r0]
 15256  03B98H  04669H      mov      r1,sp
 15258  03B9AH  0680AH      ldr      r2,[r1]
 15260  03B9CH  04B21H      ldr      r3,[pc,#132] -> 15396
 15262  03B9EH  0401AH      ands     r2,r3
 15264  03BA0H  001C0H      lsls     r0,r0,#7
 15266  03BA2H  04302H      orrs     r2,r0
 15268  03BA4H  09200H      str      r2,[sp]
 15270  03BA6H  09804H      ldr      r0,[sp,#16]
 15272  03BA8H  06840H      ldr      r0,[r0,#4]
 15274  03BAAH  04669H      mov      r1,sp
 15276  03BACH  0680AH      ldr      r2,[r1]
 15278  03BAEH  04B1EH      ldr      r3,[pc,#120] -> 15400
 15280  03BB0H  0401AH      ands     r2,r3
 15282  03BB2H  00140H      lsls     r0,r0,#5
 15284  03BB4H  04302H      orrs     r2,r0
 15286  03BB6H  09200H      str      r2,[sp]
 15288  03BB8H  09804H      ldr      r0,[sp,#16]
 15290  03BBAH  06880H      ldr      r0,[r0,#8]
 15292  03BBCH  04669H      mov      r1,sp
 15294  03BBEH  0680AH      ldr      r2,[r1]
 15296  03BC0H  04B1AH      ldr      r3,[pc,#104] -> 15404
 15298  03BC2H  0401AH      ands     r2,r3
 15300  03BC4H  00100H      lsls     r0,r0,#4
 15302  03BC6H  04302H      orrs     r2,r0
 15304  03BC8H  09200H      str      r2,[sp]
 15306  03BCAH  09804H      ldr      r0,[sp,#16]
 15308  03BCCH  068C0H      ldr      r0,[r0,#12]
 15310  03BCEH  04669H      mov      r1,sp
 15312  03BD0H  0680AH      ldr      r2,[r1]
 15314  03BD2H  04B17H      ldr      r3,[pc,#92] -> 15408
 15316  03BD4H  0401AH      ands     r2,r3
 15318  03BD6H  000C0H      lsls     r0,r0,#3
 15320  03BD8H  04302H      orrs     r2,r0
 15322  03BDAH  09200H      str      r2,[sp]
 15324  03BDCH  09804H      ldr      r0,[sp,#16]
 15326  03BDEH  06900H      ldr      r0,[r0,#16]
 15328  03BE0H  04669H      mov      r1,sp
 15330  03BE2H  0680AH      ldr      r2,[r1]
 15332  03BE4H  04B13H      ldr      r3,[pc,#76] -> 15412
 15334  03BE6H  0401AH      ands     r2,r3
 15336  03BE8H  00080H      lsls     r0,r0,#2
 15338  03BEAH  04302H      orrs     r2,r0
 15340  03BECH  09200H      str      r2,[sp]
 15342  03BEEH  09804H      ldr      r0,[sp,#16]
 15344  03BF0H  06940H      ldr      r0,[r0,#20]
 15346  03BF2H  04669H      mov      r1,sp
 15348  03BF4H  0680AH      ldr      r2,[r1]
 15350  03BF6H  04B10H      ldr      r3,[pc,#64] -> 15416
 15352  03BF8H  0401AH      ands     r2,r3
 15354  03BFAH  00040H      lsls     r0,r0,#1
 15356  03BFCH  04302H      orrs     r2,r0
 15358  03BFEH  09200H      str      r2,[sp]
 15360  03C00H  09804H      ldr      r0,[sp,#16]
 15362  03C02H  06980H      ldr      r0,[r0,#24]
 15364  03C04H  04669H      mov      r1,sp
 15366  03C06H  0680AH      ldr      r2,[r1]
 15368  03C08H  04B0CH      ldr      r3,[pc,#48] -> 15420
 15370  03C0AH  0401AH      ands     r2,r3
 15372  03C0CH  04302H      orrs     r2,r0
 15374  03C0EH  09200H      str      r2,[sp]
 15376  03C10H  09803H      ldr      r0,[sp,#12]
 15378  03C12H  06980H      ldr      r0,[r0,#24]
 15380  03C14H  09900H      ldr      r1,[sp]
 15382  03C16H  06001H      str      r1,[r0]
 15384  03C18H  0B007H      add      sp,#28
 15386  03C1AH  0BD00H      pop      { pc }
 15388  03C1CH  016E36000H
 15392  03C20H  00000FFFFH
 15396  03C24H  -129
 15400  03C28H  -97
 15404  03C2CH  -17
 15408  03C30H  -9
 15412  03C34H  -5
 15416  03C38H  -3
 15420  03C3CH  -2

PROCEDURE UARTdev.Enable:
 15424  03C40H  0B501H      push     { r0, lr }
 15426  03C42H  09800H      ldr      r0,[sp]
 15428  03C44H  02800H      cmp      r0,#0
 15430  03C46H  0D101H      bne.n    2 -> 15436
 15432  03C48H  0DF65H      svc      101
 15434  03C4AH  000C2H      <LineNo: 194>
 15436  03C4CH  09800H      ldr      r0,[sp]
 15438  03C4EH  068C0H      ldr      r0,[r0,#12]
 15440  03C50H  02101H      movs     r1,#1
 15442  03C52H  00349H      lsls     r1,r1,#13
 15444  03C54H  01840H      adds     r0,r0,r1
 15446  03C56H  04902H      ldr      r1,[pc,#8] -> 15456
 15448  03C58H  06001H      str      r1,[r0]
 15450  03C5AH  0B001H      add      sp,#4
 15452  03C5CH  0BD00H      pop      { pc }
 15454  03C5EH  046C0H      nop
 15456  03C60H  769

PROCEDURE UARTdev.Disable:
 15460  03C64H  0B501H      push     { r0, lr }
 15462  03C66H  09800H      ldr      r0,[sp]
 15464  03C68H  02800H      cmp      r0,#0
 15466  03C6AH  0D101H      bne.n    2 -> 15472
 15468  03C6CH  0DF65H      svc      101
 15470  03C6EH  000C9H      <LineNo: 201>
 15472  03C70H  09800H      ldr      r0,[sp]
 15474  03C72H  068C0H      ldr      r0,[r0,#12]
 15476  03C74H  02103H      movs     r1,#3
 15478  03C76H  00309H      lsls     r1,r1,#12
 15480  03C78H  01840H      adds     r0,r0,r1
 15482  03C7AH  04902H      ldr      r1,[pc,#8] -> 15492
 15484  03C7CH  06001H      str      r1,[r0]
 15486  03C7EH  0B001H      add      sp,#4
 15488  03C80H  0BD00H      pop      { pc }
 15490  03C82H  046C0H      nop
 15492  03C84H  769

PROCEDURE UARTdev.Flags:
 15496  03C88H  0B501H      push     { r0, lr }
 15498  03C8AH  0B081H      sub      sp,#4
 15500  03C8CH  09801H      ldr      r0,[sp,#4]
 15502  03C8EH  06A40H      ldr      r0,[r0,#36]
 15504  03C90H  06801H      ldr      r1,[r0]
 15506  03C92H  09100H      str      r1,[sp]
 15508  03C94H  09800H      ldr      r0,[sp]
 15510  03C96H  0B002H      add      sp,#8
 15512  03C98H  0BD00H      pop      { pc }
 15514  03C9AH  046C0H      nop

PROCEDURE UARTdev.GetBaseCfg:
 15516  03C9CH  0B503H      push     { r0, r1, lr }
 15518  03C9EH  09800H      ldr      r0,[sp]
 15520  03CA0H  02100H      movs     r1,#0
 15522  03CA2H  02207H      movs     r2,#7
 15524  03CA4H  06001H      str      r1,[r0]
 15526  03CA6H  03004H      adds     r0,#4
 15528  03CA8H  03A01H      subs     r2,#1
 15530  03CAAH  0DCFBH      bgt.n    -10 -> 15524
 15532  03CACH  02003H      movs     r0,#3
 15534  03CAEH  09900H      ldr      r1,[sp]
 15536  03CB0H  06048H      str      r0,[r1,#4]
 15538  03CB2H  0B002H      add      sp,#8
 15540  03CB4H  0BD00H      pop      { pc }
 15542  03CB6H  046C0H      nop

PROCEDURE UARTdev.GetCurrentCfg:
 15544  03CB8H  0B507H      push     { r0, r1, r2, lr }
 15546  03CBAH  0B081H      sub      sp,#4
 15548  03CBCH  09801H      ldr      r0,[sp,#4]
 15550  03CBEH  06980H      ldr      r0,[r0,#24]
 15552  03CC0H  06801H      ldr      r1,[r0]
 15554  03CC2H  09100H      str      r1,[sp]
 15556  03CC4H  09800H      ldr      r0,[sp]
 15558  03CC6H  00600H      lsls     r0,r0,#24
 15560  03CC8H  00FC0H      lsrs     r0,r0,#31
 15562  03CCAH  09902H      ldr      r1,[sp,#8]
 15564  03CCCH  06008H      str      r0,[r1]
 15566  03CCEH  09800H      ldr      r0,[sp]
 15568  03CD0H  00640H      lsls     r0,r0,#25
 15570  03CD2H  00F80H      lsrs     r0,r0,#30
 15572  03CD4H  09902H      ldr      r1,[sp,#8]
 15574  03CD6H  06048H      str      r0,[r1,#4]
 15576  03CD8H  09800H      ldr      r0,[sp]
 15578  03CDAH  006C0H      lsls     r0,r0,#27
 15580  03CDCH  00FC0H      lsrs     r0,r0,#31
 15582  03CDEH  09902H      ldr      r1,[sp,#8]
 15584  03CE0H  06088H      str      r0,[r1,#8]
 15586  03CE2H  09800H      ldr      r0,[sp]
 15588  03CE4H  00700H      lsls     r0,r0,#28
 15590  03CE6H  00FC0H      lsrs     r0,r0,#31
 15592  03CE8H  09902H      ldr      r1,[sp,#8]
 15594  03CEAH  060C8H      str      r0,[r1,#12]
 15596  03CECH  09800H      ldr      r0,[sp]
 15598  03CEEH  00740H      lsls     r0,r0,#29
 15600  03CF0H  00FC0H      lsrs     r0,r0,#31
 15602  03CF2H  09902H      ldr      r1,[sp,#8]
 15604  03CF4H  06108H      str      r0,[r1,#16]
 15606  03CF6H  09800H      ldr      r0,[sp]
 15608  03CF8H  00780H      lsls     r0,r0,#30
 15610  03CFAH  00FC0H      lsrs     r0,r0,#31
 15612  03CFCH  09902H      ldr      r1,[sp,#8]
 15614  03CFEH  06148H      str      r0,[r1,#20]
 15616  03D00H  09800H      ldr      r0,[sp]
 15618  03D02H  007C0H      lsls     r0,r0,#31
 15620  03D04H  00FC0H      lsrs     r0,r0,#31
 15622  03D06H  09902H      ldr      r1,[sp,#8]
 15624  03D08H  06188H      str      r0,[r1,#24]
 15626  03D0AH  0B004H      add      sp,#16
 15628  03D0CH  0BD00H      pop      { pc }
 15630  03D0EH  046C0H      nop

PROCEDURE UARTdev.SetFifoLvl:
 15632  03D10H  0B507H      push     { r0, r1, r2, lr }
 15634  03D12H  0B081H      sub      sp,#4
 15636  03D14H  0201FH      movs     r0,#31
 15638  03D16H  09902H      ldr      r1,[sp,#8]
 15640  03D18H  02201H      movs     r2,#1
 15642  03D1AH  0408AH      lsls     r2,r1
 15644  03D1CH  04210H      tst      r0,r2
 15646  03D1EH  0D101H      bne.n    2 -> 15652
 15648  03D20H  0DF00H      svc      0
 15650  03D22H  000FBH      <LineNo: 251>
 15652  03D24H  0201FH      movs     r0,#31
 15654  03D26H  09903H      ldr      r1,[sp,#12]
 15656  03D28H  02201H      movs     r2,#1
 15658  03D2AH  0408AH      lsls     r2,r1
 15660  03D2CH  04210H      tst      r0,r2
 15662  03D2EH  0D101H      bne.n    2 -> 15668
 15664  03D30H  0DF00H      svc      0
 15666  03D32H  000FCH      <LineNo: 252>
 15668  03D34H  09802H      ldr      r0,[sp,#8]
 15670  03D36H  09000H      str      r0,[sp]
 15672  03D38H  09803H      ldr      r0,[sp,#12]
 15674  03D3AH  000C0H      lsls     r0,r0,#3
 15676  03D3CH  09900H      ldr      r1,[sp]
 15678  03D3EH  01808H      adds     r0,r1,r0
 15680  03D40H  09000H      str      r0,[sp]
 15682  03D42H  09801H      ldr      r0,[sp,#4]
 15684  03D44H  06B00H      ldr      r0,[r0,#48]
 15686  03D46H  09900H      ldr      r1,[sp]
 15688  03D48H  06001H      str      r1,[r0]
 15690  03D4AH  0B004H      add      sp,#16
 15692  03D4CH  0BD00H      pop      { pc }
 15694  03D4EH  046C0H      nop

PROCEDURE UARTdev.EnableInt:
 15696  03D50H  0B503H      push     { r0, r1, lr }
 15698  03D52H  09800H      ldr      r0,[sp]
 15700  03D54H  06B40H      ldr      r0,[r0,#52]
 15702  03D56H  02101H      movs     r1,#1
 15704  03D58H  00349H      lsls     r1,r1,#13
 15706  03D5AH  01840H      adds     r0,r0,r1
 15708  03D5CH  09901H      ldr      r1,[sp,#4]
 15710  03D5EH  06001H      str      r1,[r0]
 15712  03D60H  0B002H      add      sp,#8
 15714  03D62H  0BD00H      pop      { pc }

PROCEDURE UARTdev.DisableInt:
 15716  03D64H  0B503H      push     { r0, r1, lr }
 15718  03D66H  09800H      ldr      r0,[sp]
 15720  03D68H  06B40H      ldr      r0,[r0,#52]
 15722  03D6AH  02103H      movs     r1,#3
 15724  03D6CH  00309H      lsls     r1,r1,#12
 15726  03D6EH  01840H      adds     r0,r0,r1
 15728  03D70H  09901H      ldr      r1,[sp,#4]
 15730  03D72H  06001H      str      r1,[r0]
 15732  03D74H  0B002H      add      sp,#8
 15734  03D76H  0BD00H      pop      { pc }

PROCEDURE UARTdev.GetEnabledInt:
 15736  03D78H  0B503H      push     { r0, r1, lr }
 15738  03D7AH  09800H      ldr      r0,[sp]
 15740  03D7CH  06B40H      ldr      r0,[r0,#52]
 15742  03D7EH  06801H      ldr      r1,[r0]
 15744  03D80H  09A01H      ldr      r2,[sp,#4]
 15746  03D82H  06011H      str      r1,[r2]
 15748  03D84H  0B002H      add      sp,#8
 15750  03D86H  0BD00H      pop      { pc }

PROCEDURE UARTdev.GetIntStatus:
 15752  03D88H  0B503H      push     { r0, r1, lr }
 15754  03D8AH  09800H      ldr      r0,[sp]
 15756  03D8CH  06B80H      ldr      r0,[r0,#56]
 15758  03D8EH  06801H      ldr      r1,[r0]
 15760  03D90H  09A01H      ldr      r2,[sp,#4]
 15762  03D92H  06011H      str      r1,[r2]
 15764  03D94H  0B002H      add      sp,#8
 15766  03D96H  0BD00H      pop      { pc }

PROCEDURE UARTdev.ClearInt:
 15768  03D98H  0B503H      push     { r0, r1, lr }
 15770  03D9AH  09800H      ldr      r0,[sp]
 15772  03D9CH  06BC0H      ldr      r0,[r0,#60]
 15774  03D9EH  02101H      movs     r1,#1
 15776  03DA0H  00349H      lsls     r1,r1,#13
 15778  03DA2H  01840H      adds     r0,r0,r1
 15780  03DA4H  09901H      ldr      r1,[sp,#4]
 15782  03DA6H  06001H      str      r1,[r0]
 15784  03DA8H  0B002H      add      sp,#8
 15786  03DAAH  0BD00H      pop      { pc }

PROCEDURE UARTdev..init:
 15788  03DACH  0B500H      push     { lr }
 15790  03DAEH  0BD00H      pop      { pc }

MODULE Terminals:
 15792  03DB0H  0

PROCEDURE Terminals.InitUART:
 15796  03DB4H  0B51FH      push     { r0, r1, r2, r3, r4, lr }
 15798  03DB6H  09804H      ldr      r0,[sp,#16]
 15800  03DB8H  04911H      ldr      r1,[pc,#68] -> 15872
 15802  03DBAH  0F7FDFB15H  bl.w     MAU.New
 15806  03DBEH  0E000H      b        0 -> 15810
 15808  03DC0H  00024H      <LineNo: 36>
 15810  03DC2H  09804H      ldr      r0,[sp,#16]
 15812  03DC4H  06800H      ldr      r0,[r0]
 15814  03DC6H  02800H      cmp      r0,#0
 15816  03DC8H  0D101H      bne.n    2 -> 15822
 15818  03DCAH  0DF6CH      svc      108
 15820  03DCCH  00024H      <LineNo: 36>
 15822  03DCEH  09804H      ldr      r0,[sp,#16]
 15824  03DD0H  06800H      ldr      r0,[r0]
 15826  03DD2H  09900H      ldr      r1,[sp]
 15828  03DD4H  0F7FFFDDAH  bl.w     UARTdev.Init
 15832  03DD8H  0E000H      b        0 -> 15836
 15834  03DDAH  00025H      <LineNo: 37>
 15836  03DDCH  09804H      ldr      r0,[sp,#16]
 15838  03DDEH  06800H      ldr      r0,[r0]
 15840  03DE0H  09901H      ldr      r1,[sp,#4]
 15842  03DE2H  0AA02H      add      r2,sp,#8
 15844  03DE4H  06812H      ldr      r2,[r2]
 15846  03DE6H  09B03H      ldr      r3,[sp,#12]
 15848  03DE8H  0F7FFFE40H  bl.w     UARTdev.Configure
 15852  03DECH  0E000H      b        0 -> 15856
 15854  03DEEH  00026H      <LineNo: 38>
 15856  03DF0H  09804H      ldr      r0,[sp,#16]
 15858  03DF2H  06800H      ldr      r0,[r0]
 15860  03DF4H  0F7FFFF24H  bl.w     UARTdev.Enable
 15864  03DF8H  0E000H      b        0 -> 15868
 15866  03DFAH  00027H      <LineNo: 39>
 15868  03DFCH  0B005H      add      sp,#20
 15870  03DFEH  0BD00H      pop      { pc }
 15872  03E00H  010003964H

PROCEDURE Terminals.Open:
 15876  03E04H  0B50FH      push     { r0, r1, r2, r3, lr }
 15878  03E06H  02003H      movs     r0,#3
 15880  03E08H  09900H      ldr      r1,[sp]
 15882  03E0AH  02201H      movs     r2,#1
 15884  03E0CH  0408AH      lsls     r2,r1
 15886  03E0EH  04210H      tst      r0,r2
 15888  03E10H  0D101H      bne.n    2 -> 15894
 15890  03E12H  0DF65H      svc      101
 15892  03E14H  0002DH      <LineNo: 45>
 15894  03E16H  09801H      ldr      r0,[sp,#4]
 15896  03E18H  02800H      cmp      r0,#0
 15898  03E1AH  0D101H      bne.n    2 -> 15904
 15900  03E1CH  0DF65H      svc      101
 15902  03E1EH  0002EH      <LineNo: 46>
 15904  03E20H  09800H      ldr      r0,[sp]
 15906  03E22H  02802H      cmp      r0,#2
 15908  03E24H  0D301H      bcc.n    2 -> 15914
 15910  03E26H  0DF01H      svc      1
 15912  03E28H  0002FH      <LineNo: 47>
 15914  03E2AH  04930H      ldr      r1,[pc,#192] -> 16108
 15916  03E2CH  00080H      lsls     r0,r0,#2
 15918  03E2EH  01808H      adds     r0,r1,r0
 15920  03E30H  06800H      ldr      r0,[r0]
 15922  03E32H  02800H      cmp      r0,#0
 15924  03E34H  0D001H      beq.n    2 -> 15930
 15926  03E36H  0E052H      b        164 -> 16094
 15928  03E38H  046C0H      nop
 15930  03E3AH  09800H      ldr      r0,[sp]
 15932  03E3CH  02802H      cmp      r0,#2
 15934  03E3EH  0D301H      bcc.n    2 -> 15940
 15936  03E40H  0DF01H      svc      1
 15938  03E42H  00030H      <LineNo: 48>
 15940  03E44H  04929H      ldr      r1,[pc,#164] -> 16108
 15942  03E46H  00080H      lsls     r0,r0,#2
 15944  03E48H  01808H      adds     r0,r1,r0
 15946  03E4AH  04926H      ldr      r1,[pc,#152] -> 16100
 15948  03E4CH  0F7FDFACCH  bl.w     MAU.New
 15952  03E50H  0E000H      b        0 -> 15956
 15954  03E52H  00030H      <LineNo: 48>
 15956  03E54H  09800H      ldr      r0,[sp]
 15958  03E56H  02802H      cmp      r0,#2
 15960  03E58H  0D301H      bcc.n    2 -> 15966
 15962  03E5AH  0DF01H      svc      1
 15964  03E5CH  00030H      <LineNo: 48>
 15966  03E5EH  04923H      ldr      r1,[pc,#140] -> 16108
 15968  03E60H  00080H      lsls     r0,r0,#2
 15970  03E62H  01808H      adds     r0,r1,r0
 15972  03E64H  06800H      ldr      r0,[r0]
 15974  03E66H  02800H      cmp      r0,#0
 15976  03E68H  0D101H      bne.n    2 -> 15982
 15978  03E6AH  0DF6CH      svc      108
 15980  03E6CH  00030H      <LineNo: 48>
 15982  03E6EH  09800H      ldr      r0,[sp]
 15984  03E70H  02802H      cmp      r0,#2
 15986  03E72H  0D301H      bcc.n    2 -> 15992
 15988  03E74H  0DF01H      svc      1
 15990  03E76H  00031H      <LineNo: 49>
 15992  03E78H  0491DH      ldr      r1,[pc,#116] -> 16112
 15994  03E7AH  00080H      lsls     r0,r0,#2
 15996  03E7CH  01808H      adds     r0,r1,r0
 15998  03E7EH  0491AH      ldr      r1,[pc,#104] -> 16104
 16000  03E80H  0F7FDFAB2H  bl.w     MAU.New
 16004  03E84H  0E000H      b        0 -> 16008
 16006  03E86H  00031H      <LineNo: 49>
 16008  03E88H  09800H      ldr      r0,[sp]
 16010  03E8AH  02802H      cmp      r0,#2
 16012  03E8CH  0D301H      bcc.n    2 -> 16018
 16014  03E8EH  0DF01H      svc      1
 16016  03E90H  00031H      <LineNo: 49>
 16018  03E92H  04917H      ldr      r1,[pc,#92] -> 16112
 16020  03E94H  00080H      lsls     r0,r0,#2
 16022  03E96H  01808H      adds     r0,r1,r0
 16024  03E98H  06800H      ldr      r0,[r0]
 16026  03E9AH  02800H      cmp      r0,#0
 16028  03E9CH  0D101H      bne.n    2 -> 16034
 16030  03E9EH  0DF6CH      svc      108
 16032  03EA0H  00031H      <LineNo: 49>
 16034  03EA2H  09800H      ldr      r0,[sp]
 16036  03EA4H  02802H      cmp      r0,#2
 16038  03EA6H  0D301H      bcc.n    2 -> 16044
 16040  03EA8H  0DF01H      svc      1
 16042  03EAAH  00032H      <LineNo: 50>
 16044  03EACH  0490FH      ldr      r1,[pc,#60] -> 16108
 16046  03EAEH  00080H      lsls     r0,r0,#2
 16048  03EB0H  01808H      adds     r0,r1,r0
 16050  03EB2H  06800H      ldr      r0,[r0]
 16052  03EB4H  09901H      ldr      r1,[sp,#4]
 16054  03EB6H  09A02H      ldr      r2,[sp,#8]
 16056  03EB8H  0F7FEFB40H  bl.w     TextIO.OpenWriter
 16060  03EBCH  0E000H      b        0 -> 16064
 16062  03EBEH  00032H      <LineNo: 50>
 16064  03EC0H  09800H      ldr      r0,[sp]
 16066  03EC2H  02802H      cmp      r0,#2
 16068  03EC4H  0D301H      bcc.n    2 -> 16074
 16070  03EC6H  0DF01H      svc      1
 16072  03EC8H  00033H      <LineNo: 51>
 16074  03ECAH  04909H      ldr      r1,[pc,#36] -> 16112
 16076  03ECCH  00080H      lsls     r0,r0,#2
 16078  03ECEH  01808H      adds     r0,r1,r0
 16080  03ED0H  06800H      ldr      r0,[r0]
 16082  03ED2H  09901H      ldr      r1,[sp,#4]
 16084  03ED4H  09A03H      ldr      r2,[sp,#12]
 16086  03ED6H  0F7FEFB4FH  bl.w     TextIO.OpenReader
 16090  03EDAH  0E000H      b        0 -> 16094
 16092  03EDCH  00033H      <LineNo: 51>
 16094  03EDEH  0B004H      add      sp,#16
 16096  03EE0H  0BD00H      pop      { pc }
 16098  03EE2H  046C0H      nop
 16100  03EE4H  010002514H
 16104  03EE8H  010002528H
 16108  03EECH  02002FCBCH
 16112  03EF0H  02002FCACH

PROCEDURE Terminals.Close:
 16116  03EF4H  0B503H      push     { r0, r1, lr }
 16118  03EF6H  09800H      ldr      r0,[sp]
 16120  03EF8H  02802H      cmp      r0,#2
 16122  03EFAH  0D301H      bcc.n    2 -> 16128
 16124  03EFCH  0DF01H      svc      1
 16126  03EFEH  0003AH      <LineNo: 58>
 16128  03F00H  04909H      ldr      r1,[pc,#36] -> 16168
 16130  03F02H  00080H      lsls     r0,r0,#2
 16132  03F04H  01808H      adds     r0,r1,r0
 16134  03F06H  06800H      ldr      r0,[r0]
 16136  03F08H  06800H      ldr      r0,[r0]
 16138  03F0AH  09901H      ldr      r1,[sp,#4]
 16140  03F0CH  06008H      str      r0,[r1]
 16142  03F0EH  09800H      ldr      r0,[sp]
 16144  03F10H  02802H      cmp      r0,#2
 16146  03F12H  0D301H      bcc.n    2 -> 16152
 16148  03F14H  0DF01H      svc      1
 16150  03F16H  0003BH      <LineNo: 59>
 16152  03F18H  04903H      ldr      r1,[pc,#12] -> 16168
 16154  03F1AH  00080H      lsls     r0,r0,#2
 16156  03F1CH  01808H      adds     r0,r1,r0
 16158  03F1EH  02100H      movs     r1,#0
 16160  03F20H  06001H      str      r1,[r0]
 16162  03F22H  0B002H      add      sp,#8
 16164  03F24H  0BD00H      pop      { pc }
 16166  03F26H  046C0H      nop
 16168  03F28H  02002FCBCH

PROCEDURE Terminals.OpenErr:
 16172  03F2CH  0B503H      push     { r0, r1, lr }
 16174  03F2EH  02003H      movs     r0,#3
 16176  03F30H  09900H      ldr      r1,[sp]
 16178  03F32H  02201H      movs     r2,#1
 16180  03F34H  0408AH      lsls     r2,r1
 16182  03F36H  04210H      tst      r0,r2
 16184  03F38H  0D101H      bne.n    2 -> 16190
 16186  03F3AH  0DF65H      svc      101
 16188  03F3CH  00047H      <LineNo: 71>
 16190  03F3EH  09800H      ldr      r0,[sp]
 16192  03F40H  02802H      cmp      r0,#2
 16194  03F42H  0D301H      bcc.n    2 -> 16200
 16196  03F44H  0DF01H      svc      1
 16198  03F46H  00048H      <LineNo: 72>
 16200  03F48H  04925H      ldr      r1,[pc,#148] -> 16352
 16202  03F4AH  00080H      lsls     r0,r0,#2
 16204  03F4CH  01808H      adds     r0,r1,r0
 16206  03F4EH  06800H      ldr      r0,[r0]
 16208  03F50H  02800H      cmp      r0,#0
 16210  03F52H  0D101H      bne.n    2 -> 16216
 16212  03F54H  0DF68H      svc      104
 16214  03F56H  00048H      <LineNo: 72>
 16216  03F58H  09800H      ldr      r0,[sp]
 16218  03F5AH  02802H      cmp      r0,#2
 16220  03F5CH  0D301H      bcc.n    2 -> 16226
 16222  03F5EH  0DF01H      svc      1
 16224  03F60H  00049H      <LineNo: 73>
 16226  03F62H  04920H      ldr      r1,[pc,#128] -> 16356
 16228  03F64H  00080H      lsls     r0,r0,#2
 16230  03F66H  01808H      adds     r0,r1,r0
 16232  03F68H  06800H      ldr      r0,[r0]
 16234  03F6AH  02800H      cmp      r0,#0
 16236  03F6CH  0D001H      beq.n    2 -> 16242
 16238  03F6EH  0E032H      b        100 -> 16342
 16240  03F70H  046C0H      nop
 16242  03F72H  09800H      ldr      r0,[sp]
 16244  03F74H  02802H      cmp      r0,#2
 16246  03F76H  0D301H      bcc.n    2 -> 16252
 16248  03F78H  0DF01H      svc      1
 16250  03F7AH  0004AH      <LineNo: 74>
 16252  03F7CH  04919H      ldr      r1,[pc,#100] -> 16356
 16254  03F7EH  00080H      lsls     r0,r0,#2
 16256  03F80H  01808H      adds     r0,r1,r0
 16258  03F82H  04916H      ldr      r1,[pc,#88] -> 16348
 16260  03F84H  0F7FDFA30H  bl.w     MAU.New
 16264  03F88H  0E000H      b        0 -> 16268
 16266  03F8AH  0004AH      <LineNo: 74>
 16268  03F8CH  09800H      ldr      r0,[sp]
 16270  03F8EH  02802H      cmp      r0,#2
 16272  03F90H  0D301H      bcc.n    2 -> 16278
 16274  03F92H  0DF01H      svc      1
 16276  03F94H  0004AH      <LineNo: 74>
 16278  03F96H  04913H      ldr      r1,[pc,#76] -> 16356
 16280  03F98H  00080H      lsls     r0,r0,#2
 16282  03F9AH  01808H      adds     r0,r1,r0
 16284  03F9CH  06800H      ldr      r0,[r0]
 16286  03F9EH  02800H      cmp      r0,#0
 16288  03FA0H  0D101H      bne.n    2 -> 16294
 16290  03FA2H  0DF6CH      svc      108
 16292  03FA4H  0004AH      <LineNo: 74>
 16294  03FA6H  09800H      ldr      r0,[sp]
 16296  03FA8H  02802H      cmp      r0,#2
 16298  03FAAH  0D301H      bcc.n    2 -> 16304
 16300  03FACH  0DF01H      svc      1
 16302  03FAEH  0004BH      <LineNo: 75>
 16304  03FB0H  0490CH      ldr      r1,[pc,#48] -> 16356
 16306  03FB2H  00080H      lsls     r0,r0,#2
 16308  03FB4H  01808H      adds     r0,r1,r0
 16310  03FB6H  06800H      ldr      r0,[r0]
 16312  03FB8H  09900H      ldr      r1,[sp]
 16314  03FBAH  02902H      cmp      r1,#2
 16316  03FBCH  0D301H      bcc.n    2 -> 16322
 16318  03FBEH  0DF01H      svc      1
 16320  03FC0H  0004BH      <LineNo: 75>
 16322  03FC2H  04A07H      ldr      r2,[pc,#28] -> 16352
 16324  03FC4H  00089H      lsls     r1,r1,#2
 16326  03FC6H  01851H      adds     r1,r2,r1
 16328  03FC8H  06809H      ldr      r1,[r1]
 16330  03FCAH  06809H      ldr      r1,[r1]
 16332  03FCCH  09A01H      ldr      r2,[sp,#4]
 16334  03FCEH  0F7FEFAB5H  bl.w     TextIO.OpenWriter
 16338  03FD2H  0E000H      b        0 -> 16342
 16340  03FD4H  0004BH      <LineNo: 75>
 16342  03FD6H  0B002H      add      sp,#8
 16344  03FD8H  0BD00H      pop      { pc }
 16346  03FDAH  046C0H      nop
 16348  03FDCH  010002514H
 16352  03FE0H  02002FCBCH
 16356  03FE4H  02002FCB4H

PROCEDURE Terminals..init:
 16360  03FE8H  0B500H      push     { lr }
 16362  03FEAH  04809H      ldr      r0,[pc,#36] -> 16400
 16364  03FECH  02100H      movs     r1,#0
 16366  03FEEH  06001H      str      r1,[r0]
 16368  03FF0H  04807H      ldr      r0,[pc,#28] -> 16400
 16370  03FF2H  02100H      movs     r1,#0
 16372  03FF4H  06041H      str      r1,[r0,#4]
 16374  03FF6H  04807H      ldr      r0,[pc,#28] -> 16404
 16376  03FF8H  02100H      movs     r1,#0
 16378  03FFAH  06001H      str      r1,[r0]
 16380  03FFCH  04805H      ldr      r0,[pc,#20] -> 16404
 16382  03FFEH  02100H      movs     r1,#0
 16384  04000H  06041H      str      r1,[r0,#4]
 16386  04002H  04805H      ldr      r0,[pc,#20] -> 16408
 16388  04004H  02100H      movs     r1,#0
 16390  04006H  06001H      str      r1,[r0]
 16392  04008H  04803H      ldr      r0,[pc,#12] -> 16408
 16394  0400AH  02100H      movs     r1,#0
 16396  0400CH  06041H      str      r1,[r0,#4]
 16398  0400EH  0BD00H      pop      { pc }
 16400  04010H  02002FCBCH
 16404  04014H  02002FCACH
 16408  04018H  02002FCB4H

MODULE Out:
 16412  0401CH  0

PROCEDURE Out.Open:
 16416  04020H  0B503H      push     { r0, r1, lr }
 16418  04022H  09800H      ldr      r0,[sp]
 16420  04024H  02800H      cmp      r0,#0
 16422  04026H  0D101H      bne.n    2 -> 16428
 16424  04028H  0DF65H      svc      101
 16426  0402AH  00016H      <LineNo: 22>
 16428  0402CH  09801H      ldr      r0,[sp,#4]
 16430  0402EH  02800H      cmp      r0,#0
 16432  04030H  0D101H      bne.n    2 -> 16438
 16434  04032H  0DF65H      svc      101
 16436  04034H  00017H      <LineNo: 23>
 16438  04036H  04804H      ldr      r0,[pc,#16] -> 16456
 16440  04038H  09900H      ldr      r1,[sp]
 16442  0403AH  06001H      str      r1,[r0]
 16444  0403CH  04802H      ldr      r0,[pc,#8] -> 16456
 16446  0403EH  09901H      ldr      r1,[sp,#4]
 16448  04040H  06041H      str      r1,[r0,#4]
 16450  04042H  0B002H      add      sp,#8
 16452  04044H  0BD00H      pop      { pc }
 16454  04046H  046C0H      nop
 16456  04048H  02002FCA4H

PROCEDURE Out.Char:
 16460  0404CH  0B501H      push     { r0, lr }
 16462  0404EH  0B081H      sub      sp,#4
 16464  04050H  04809H      ldr      r0,[pc,#36] -> 16504
 16466  04052H  06801H      ldr      r1,[r0]
 16468  04054H  09100H      str      r1,[sp]
 16470  04056H  09800H      ldr      r0,[sp]
 16472  04058H  02802H      cmp      r0,#2
 16474  0405AH  0D301H      bcc.n    2 -> 16480
 16476  0405CH  0DF01H      svc      1
 16478  0405EH  00021H      <LineNo: 33>
 16480  04060H  04906H      ldr      r1,[pc,#24] -> 16508
 16482  04062H  00080H      lsls     r0,r0,#2
 16484  04064H  01808H      adds     r0,r1,r0
 16486  04066H  06800H      ldr      r0,[r0]
 16488  04068H  0A901H      add      r1,sp,#4
 16490  0406AH  07809H      ldrb     r1,[r1]
 16492  0406CH  0F7FEFC24H  bl.w     Texts.Write
 16496  04070H  0E000H      b        0 -> 16500
 16498  04072H  00021H      <LineNo: 33>
 16500  04074H  0B002H      add      sp,#8
 16502  04076H  0BD00H      pop      { pc }
 16504  04078H  0D0000000H
 16508  0407CH  02002FCA4H

PROCEDURE Out.String:
 16512  04080H  0B503H      push     { r0, r1, lr }
 16514  04082H  0B081H      sub      sp,#4
 16516  04084H  04809H      ldr      r0,[pc,#36] -> 16556
 16518  04086H  06801H      ldr      r1,[r0]
 16520  04088H  09100H      str      r1,[sp]
 16522  0408AH  09800H      ldr      r0,[sp]
 16524  0408CH  02802H      cmp      r0,#2
 16526  0408EH  0D301H      bcc.n    2 -> 16532
 16528  04090H  0DF01H      svc      1
 16530  04092H  00029H      <LineNo: 41>
 16532  04094H  04906H      ldr      r1,[pc,#24] -> 16560
 16534  04096H  00080H      lsls     r0,r0,#2
 16536  04098H  01808H      adds     r0,r1,r0
 16538  0409AH  06800H      ldr      r0,[r0]
 16540  0409CH  09901H      ldr      r1,[sp,#4]
 16542  0409EH  09A02H      ldr      r2,[sp,#8]
 16544  040A0H  0F7FEFC22H  bl.w     Texts.WriteString
 16548  040A4H  0E000H      b        0 -> 16552
 16550  040A6H  00029H      <LineNo: 41>
 16552  040A8H  0B003H      add      sp,#12
 16554  040AAH  0BD00H      pop      { pc }
 16556  040ACH  0D0000000H
 16560  040B0H  02002FCA4H

PROCEDURE Out.Ln:
 16564  040B4H  0B500H      push     { lr }
 16566  040B6H  0B081H      sub      sp,#4
 16568  040B8H  04808H      ldr      r0,[pc,#32] -> 16604
 16570  040BAH  06801H      ldr      r1,[r0]
 16572  040BCH  09100H      str      r1,[sp]
 16574  040BEH  09800H      ldr      r0,[sp]
 16576  040C0H  02802H      cmp      r0,#2
 16578  040C2H  0D301H      bcc.n    2 -> 16584
 16580  040C4H  0DF01H      svc      1
 16582  040C6H  00031H      <LineNo: 49>
 16584  040C8H  04905H      ldr      r1,[pc,#20] -> 16608
 16586  040CAH  00080H      lsls     r0,r0,#2
 16588  040CCH  01808H      adds     r0,r1,r0
 16590  040CEH  06800H      ldr      r0,[r0]
 16592  040D0H  0F7FEFC36H  bl.w     Texts.WriteLn
 16596  040D4H  0E000H      b        0 -> 16600
 16598  040D6H  00031H      <LineNo: 49>
 16600  040D8H  0B001H      add      sp,#4
 16602  040DAH  0BD00H      pop      { pc }
 16604  040DCH  0D0000000H
 16608  040E0H  02002FCA4H

PROCEDURE Out.Int:
 16612  040E4H  0B503H      push     { r0, r1, lr }
 16614  040E6H  0B081H      sub      sp,#4
 16616  040E8H  04809H      ldr      r0,[pc,#36] -> 16656
 16618  040EAH  06801H      ldr      r1,[r0]
 16620  040ECH  09100H      str      r1,[sp]
 16622  040EEH  09800H      ldr      r0,[sp]
 16624  040F0H  02802H      cmp      r0,#2
 16626  040F2H  0D301H      bcc.n    2 -> 16632
 16628  040F4H  0DF01H      svc      1
 16630  040F6H  00039H      <LineNo: 57>
 16632  040F8H  04906H      ldr      r1,[pc,#24] -> 16660
 16634  040FAH  00080H      lsls     r0,r0,#2
 16636  040FCH  01808H      adds     r0,r1,r0
 16638  040FEH  06800H      ldr      r0,[r0]
 16640  04100H  09901H      ldr      r1,[sp,#4]
 16642  04102H  09A02H      ldr      r2,[sp,#8]
 16644  04104H  0F7FEFC62H  bl.w     Texts.WriteInt
 16648  04108H  0E000H      b        0 -> 16652
 16650  0410AH  00039H      <LineNo: 57>
 16652  0410CH  0B003H      add      sp,#12
 16654  0410EH  0BD00H      pop      { pc }
 16656  04110H  0D0000000H
 16660  04114H  02002FCA4H

PROCEDURE Out.Hex:
 16664  04118H  0B503H      push     { r0, r1, lr }
 16666  0411AH  0B081H      sub      sp,#4
 16668  0411CH  04809H      ldr      r0,[pc,#36] -> 16708
 16670  0411EH  06801H      ldr      r1,[r0]
 16672  04120H  09100H      str      r1,[sp]
 16674  04122H  09800H      ldr      r0,[sp]
 16676  04124H  02802H      cmp      r0,#2
 16678  04126H  0D301H      bcc.n    2 -> 16684
 16680  04128H  0DF01H      svc      1
 16682  0412AH  00041H      <LineNo: 65>
 16684  0412CH  04906H      ldr      r1,[pc,#24] -> 16712
 16686  0412EH  00080H      lsls     r0,r0,#2
 16688  04130H  01808H      adds     r0,r1,r0
 16690  04132H  06800H      ldr      r0,[r0]
 16692  04134H  09901H      ldr      r1,[sp,#4]
 16694  04136H  09A02H      ldr      r2,[sp,#8]
 16696  04138H  0F7FEFC60H  bl.w     Texts.WriteHex
 16700  0413CH  0E000H      b        0 -> 16704
 16702  0413EH  00041H      <LineNo: 65>
 16704  04140H  0B003H      add      sp,#12
 16706  04142H  0BD00H      pop      { pc }
 16708  04144H  0D0000000H
 16712  04148H  02002FCA4H

PROCEDURE Out.Bin:
 16716  0414CH  0B503H      push     { r0, r1, lr }
 16718  0414EH  0B081H      sub      sp,#4
 16720  04150H  04809H      ldr      r0,[pc,#36] -> 16760
 16722  04152H  06801H      ldr      r1,[r0]
 16724  04154H  09100H      str      r1,[sp]
 16726  04156H  09800H      ldr      r0,[sp]
 16728  04158H  02802H      cmp      r0,#2
 16730  0415AH  0D301H      bcc.n    2 -> 16736
 16732  0415CH  0DF01H      svc      1
 16734  0415EH  00049H      <LineNo: 73>
 16736  04160H  04906H      ldr      r1,[pc,#24] -> 16764
 16738  04162H  00080H      lsls     r0,r0,#2
 16740  04164H  01808H      adds     r0,r1,r0
 16742  04166H  06800H      ldr      r0,[r0]
 16744  04168H  09901H      ldr      r1,[sp,#4]
 16746  0416AH  09A02H      ldr      r2,[sp,#8]
 16748  0416CH  0F7FEFC5EH  bl.w     Texts.WriteBin
 16752  04170H  0E000H      b        0 -> 16756
 16754  04172H  00049H      <LineNo: 73>
 16756  04174H  0B003H      add      sp,#12
 16758  04176H  0BD00H      pop      { pc }
 16760  04178H  0D0000000H
 16764  0417CH  02002FCA4H

PROCEDURE Out.Flush:
 16768  04180H  0B500H      push     { lr }
 16770  04182H  0B081H      sub      sp,#4
 16772  04184H  04808H      ldr      r0,[pc,#32] -> 16808
 16774  04186H  06801H      ldr      r1,[r0]
 16776  04188H  09100H      str      r1,[sp]
 16778  0418AH  09800H      ldr      r0,[sp]
 16780  0418CH  02802H      cmp      r0,#2
 16782  0418EH  0D301H      bcc.n    2 -> 16788
 16784  04190H  0DF01H      svc      1
 16786  04192H  00051H      <LineNo: 81>
 16788  04194H  04905H      ldr      r1,[pc,#20] -> 16812
 16790  04196H  00080H      lsls     r0,r0,#2
 16792  04198H  01808H      adds     r0,r1,r0
 16794  0419AH  06800H      ldr      r0,[r0]
 16796  0419CH  0F7FEFDC4H  bl.w     Texts.FlushOut
 16800  041A0H  0E000H      b        0 -> 16804
 16802  041A2H  00051H      <LineNo: 81>
 16804  041A4H  0B001H      add      sp,#4
 16806  041A6H  0BD00H      pop      { pc }
 16808  041A8H  0D0000000H
 16812  041ACH  02002FCA4H

PROCEDURE Out..init:
 16816  041B0H  0B500H      push     { lr }
 16818  041B2H  04803H      ldr      r0,[pc,#12] -> 16832
 16820  041B4H  02100H      movs     r1,#0
 16822  041B6H  06001H      str      r1,[r0]
 16824  041B8H  04801H      ldr      r0,[pc,#4] -> 16832
 16826  041BAH  02100H      movs     r1,#0
 16828  041BCH  06041H      str      r1,[r0,#4]
 16830  041BEH  0BD00H      pop      { pc }
 16832  041C0H  02002FCA4H

MODULE In:
 16836  041C4H  0

PROCEDURE In.Open:
 16840  041C8H  0B503H      push     { r0, r1, lr }
 16842  041CAH  09800H      ldr      r0,[sp]
 16844  041CCH  02800H      cmp      r0,#0
 16846  041CEH  0D101H      bne.n    2 -> 16852
 16848  041D0H  0DF65H      svc      101
 16850  041D2H  0001DH      <LineNo: 29>
 16852  041D4H  09801H      ldr      r0,[sp,#4]
 16854  041D6H  02800H      cmp      r0,#0
 16856  041D8H  0D101H      bne.n    2 -> 16862
 16858  041DAH  0DF65H      svc      101
 16860  041DCH  0001EH      <LineNo: 30>
 16862  041DEH  04804H      ldr      r0,[pc,#16] -> 16880
 16864  041E0H  09900H      ldr      r1,[sp]
 16866  041E2H  06001H      str      r1,[r0]
 16868  041E4H  04802H      ldr      r0,[pc,#8] -> 16880
 16870  041E6H  09901H      ldr      r1,[sp,#4]
 16872  041E8H  06041H      str      r1,[r0,#4]
 16874  041EAH  0B002H      add      sp,#8
 16876  041ECH  0BD00H      pop      { pc }
 16878  041EEH  046C0H      nop
 16880  041F0H  02002FC9CH

PROCEDURE In.String:
 16884  041F4H  0B507H      push     { r0, r1, r2, lr }
 16886  041F6H  0B081H      sub      sp,#4
 16888  041F8H  0480AH      ldr      r0,[pc,#40] -> 16932
 16890  041FAH  06801H      ldr      r1,[r0]
 16892  041FCH  09100H      str      r1,[sp]
 16894  041FEH  09800H      ldr      r0,[sp]
 16896  04200H  02802H      cmp      r0,#2
 16898  04202H  0D301H      bcc.n    2 -> 16904
 16900  04204H  0DF01H      svc      1
 16902  04206H  00028H      <LineNo: 40>
 16904  04208H  04907H      ldr      r1,[pc,#28] -> 16936
 16906  0420AH  00080H      lsls     r0,r0,#2
 16908  0420CH  01808H      adds     r0,r1,r0
 16910  0420EH  06800H      ldr      r0,[r0]
 16912  04210H  09901H      ldr      r1,[sp,#4]
 16914  04212H  09A02H      ldr      r2,[sp,#8]
 16916  04214H  09B03H      ldr      r3,[sp,#12]
 16918  04216H  0F7FEFD37H  bl.w     Texts.ReadString
 16922  0421AH  0E000H      b        0 -> 16926
 16924  0421CH  00028H      <LineNo: 40>
 16926  0421EH  0B004H      add      sp,#16
 16928  04220H  0BD00H      pop      { pc }
 16930  04222H  046C0H      nop
 16932  04224H  0D0000000H
 16936  04228H  02002FC9CH

PROCEDURE In.Int:
 16940  0422CH  0B503H      push     { r0, r1, lr }
 16942  0422EH  0B081H      sub      sp,#4
 16944  04230H  04809H      ldr      r0,[pc,#36] -> 16984
 16946  04232H  06801H      ldr      r1,[r0]
 16948  04234H  09100H      str      r1,[sp]
 16950  04236H  09800H      ldr      r0,[sp]
 16952  04238H  02802H      cmp      r0,#2
 16954  0423AH  0D301H      bcc.n    2 -> 16960
 16956  0423CH  0DF01H      svc      1
 16958  0423EH  00030H      <LineNo: 48>
 16960  04240H  04906H      ldr      r1,[pc,#24] -> 16988
 16962  04242H  00080H      lsls     r0,r0,#2
 16964  04244H  01808H      adds     r0,r1,r0
 16966  04246H  06800H      ldr      r0,[r0]
 16968  04248H  09901H      ldr      r1,[sp,#4]
 16970  0424AH  09A02H      ldr      r2,[sp,#8]
 16972  0424CH  0F7FEFD3EH  bl.w     Texts.ReadInt
 16976  04250H  0E000H      b        0 -> 16980
 16978  04252H  00030H      <LineNo: 48>
 16980  04254H  0B003H      add      sp,#12
 16982  04256H  0BD00H      pop      { pc }
 16984  04258H  0D0000000H
 16988  0425CH  02002FC9CH

PROCEDURE In..init:
 16992  04260H  0B500H      push     { lr }
 16994  04262H  04803H      ldr      r0,[pc,#12] -> 17008
 16996  04264H  02100H      movs     r1,#0
 16998  04266H  06001H      str      r1,[r0]
 17000  04268H  04801H      ldr      r0,[pc,#4] -> 17008
 17002  0426AH  02100H      movs     r1,#0
 17004  0426CH  06041H      str      r1,[r0,#4]
 17006  0426EH  0BD00H      pop      { pc }
 17008  04270H  02002FC9CH

MODULE UARTstr:
 17012  04274H  0

PROCEDURE UARTstr.PutChar:
 17016  04278H  0B503H      push     { r0, r1, lr }
 17018  0427AH  0B081H      sub      sp,#4
 17020  0427CH  09801H      ldr      r0,[sp,#4]
 17022  0427EH  04A0AH      ldr      r2,[pc,#40] -> 17064
 17024  04280H  05881H      ldr      r1,[r0,r2]
 17026  04282H  06849H      ldr      r1,[r1,#4]
 17028  04284H  04A09H      ldr      r2,[pc,#36] -> 17068
 17030  04286H  04291H      cmp      r1,r2
 17032  04288H  0D001H      beq.n    2 -> 17038
 17034  0428AH  0DF02H      svc      2
 17036  0428CH  00014H      <LineNo: 20>
 17038  0428EH  09000H      str      r0,[sp]
 17040  04290H  09800H      ldr      r0,[sp]
 17042  04292H  06A40H      ldr      r0,[r0,#36]
 17044  04294H  06801H      ldr      r1,[r0]
 17046  04296H  00689H      lsls     r1,r1,#26
 17048  04298H  0D4FAH      bmi.n    -12 -> 17040
 17050  0429AH  09800H      ldr      r0,[sp]
 17052  0429CH  069C0H      ldr      r0,[r0,#28]
 17054  0429EH  0A902H      add      r1,sp,#8
 17056  042A0H  07809H      ldrb     r1,[r1]
 17058  042A2H  07001H      strb     r1,[r0]
 17060  042A4H  0B003H      add      sp,#12
 17062  042A6H  0BD00H      pop      { pc }
 17064  042A8H  -4
 17068  042ACH  010003964H

PROCEDURE UARTstr.PutString:
 17072  042B0H  0B50FH      push     { r0, r1, r2, r3, lr }
 17074  042B2H  0B082H      sub      sp,#8
 17076  042B4H  09802H      ldr      r0,[sp,#8]
 17078  042B6H  04A19H      ldr      r2,[pc,#100] -> 17180
 17080  042B8H  05881H      ldr      r1,[r0,r2]
 17082  042BAH  06849H      ldr      r1,[r1,#4]
 17084  042BCH  04A18H      ldr      r2,[pc,#96] -> 17184
 17086  042BEH  04291H      cmp      r1,r2
 17088  042C0H  0D001H      beq.n    2 -> 17094
 17090  042C2H  0DF02H      svc      2
 17092  042C4H  0001DH      <LineNo: 29>
 17094  042C6H  09000H      str      r0,[sp]
 17096  042C8H  09805H      ldr      r0,[sp,#20]
 17098  042CAH  09904H      ldr      r1,[sp,#16]
 17100  042CCH  04288H      cmp      r0,r1
 17102  042CEH  0DC01H      bgt.n    2 -> 17108
 17104  042D0H  0E002H      b        4 -> 17112
 17106  042D2H  046C0H      nop
 17108  042D4H  09804H      ldr      r0,[sp,#16]
 17110  042D6H  09005H      str      r0,[sp,#20]
 17112  042D8H  02000H      movs     r0,#0
 17114  042DAH  09001H      str      r0,[sp,#4]
 17116  042DCH  09801H      ldr      r0,[sp,#4]
 17118  042DEH  09905H      ldr      r1,[sp,#20]
 17120  042E0H  04288H      cmp      r0,r1
 17122  042E2H  0DB01H      blt.n    2 -> 17128
 17124  042E4H  0E017H      b        46 -> 17174
 17126  042E6H  046C0H      nop
 17128  042E8H  09800H      ldr      r0,[sp]
 17130  042EAH  06A40H      ldr      r0,[r0,#36]
 17132  042ECH  06801H      ldr      r1,[r0]
 17134  042EEH  00689H      lsls     r1,r1,#26
 17136  042F0H  0D501H      bpl.n    2 -> 17142
 17138  042F2H  0E00FH      b        30 -> 17172
 17140  042F4H  046C0H      nop
 17142  042F6H  09801H      ldr      r0,[sp,#4]
 17144  042F8H  09904H      ldr      r1,[sp,#16]
 17146  042FAH  04288H      cmp      r0,r1
 17148  042FCH  0D301H      bcc.n    2 -> 17154
 17150  042FEH  0DF01H      svc      1
 17152  04300H  00022H      <LineNo: 34>
 17154  04302H  09903H      ldr      r1,[sp,#12]
 17156  04304H  01808H      adds     r0,r1,r0
 17158  04306H  09900H      ldr      r1,[sp]
 17160  04308H  069C9H      ldr      r1,[r1,#28]
 17162  0430AH  07800H      ldrb     r0,[r0]
 17164  0430CH  07008H      strb     r0,[r1]
 17166  0430EH  09801H      ldr      r0,[sp,#4]
 17168  04310H  03001H      adds     r0,#1
 17170  04312H  09001H      str      r0,[sp,#4]
 17172  04314H  0E7E2H      b        -60 -> 17116
 17174  04316H  0B006H      add      sp,#24
 17176  04318H  0BD00H      pop      { pc }
 17178  0431AH  046C0H      nop
 17180  0431CH  -4
 17184  04320H  010003964H

PROCEDURE UARTstr.GetChar:
 17188  04324H  0B503H      push     { r0, r1, lr }
 17190  04326H  0B081H      sub      sp,#4
 17192  04328H  09801H      ldr      r0,[sp,#4]
 17194  0432AH  04A0AH      ldr      r2,[pc,#40] -> 17236
 17196  0432CH  05881H      ldr      r1,[r0,r2]
 17198  0432EH  06849H      ldr      r1,[r1,#4]
 17200  04330H  04A09H      ldr      r2,[pc,#36] -> 17240
 17202  04332H  04291H      cmp      r1,r2
 17204  04334H  0D001H      beq.n    2 -> 17210
 17206  04336H  0DF02H      svc      2
 17208  04338H  0002CH      <LineNo: 44>
 17210  0433AH  09000H      str      r0,[sp]
 17212  0433CH  09800H      ldr      r0,[sp]
 17214  0433EH  06A40H      ldr      r0,[r0,#36]
 17216  04340H  06801H      ldr      r1,[r0]
 17218  04342H  006C9H      lsls     r1,r1,#27
 17220  04344H  0D4FAH      bmi.n    -12 -> 17212
 17222  04346H  09800H      ldr      r0,[sp]
 17224  04348H  06A00H      ldr      r0,[r0,#32]
 17226  0434AH  07801H      ldrb     r1,[r0]
 17228  0434CH  09A02H      ldr      r2,[sp,#8]
 17230  0434EH  07011H      strb     r1,[r2]
 17232  04350H  0B003H      add      sp,#12
 17234  04352H  0BD00H      pop      { pc }
 17236  04354H  -4
 17240  04358H  010003964H

PROCEDURE UARTstr.GetString:
 17244  0435CH  0B51FH      push     { r0, r1, r2, r3, r4, lr }
 17246  0435EH  0B083H      sub      sp,#12
 17248  04360H  09803H      ldr      r0,[sp,#12]
 17250  04362H  04A32H      ldr      r2,[pc,#200] -> 17452
 17252  04364H  05881H      ldr      r1,[r0,r2]
 17254  04366H  06849H      ldr      r1,[r1,#4]
 17256  04368H  04A31H      ldr      r2,[pc,#196] -> 17456
 17258  0436AH  04291H      cmp      r1,r2
 17260  0436CH  0D001H      beq.n    2 -> 17266
 17262  0436EH  0DF02H      svc      2
 17264  04370H  00035H      <LineNo: 53>
 17266  04372H  09000H      str      r0,[sp]
 17268  04374H  09805H      ldr      r0,[sp,#20]
 17270  04376H  03801H      subs     r0,#1
 17272  04378H  09001H      str      r0,[sp,#4]
 17274  0437AH  02000H      movs     r0,#0
 17276  0437CH  09907H      ldr      r1,[sp,#28]
 17278  0437EH  06008H      str      r0,[r1]
 17280  04380H  02000H      movs     r0,#0
 17282  04382H  09906H      ldr      r1,[sp,#24]
 17284  04384H  06008H      str      r0,[r1]
 17286  04386H  09803H      ldr      r0,[sp,#12]
 17288  04388H  0A902H      add      r1,sp,#8
 17290  0438AH  0F7FFFFCBH  bl.w     UARTstr.GetChar
 17294  0438EH  0E000H      b        0 -> 17298
 17296  04390H  00039H      <LineNo: 57>
 17298  04392H  0A802H      add      r0,sp,#8
 17300  04394H  07800H      ldrb     r0,[r0]
 17302  04396H  02820H      cmp      r0,#32
 17304  04398H  0DA01H      bge.n    2 -> 17310
 17306  0439AH  0E01EH      b        60 -> 17370
 17308  0439CH  046C0H      nop
 17310  0439EH  09806H      ldr      r0,[sp,#24]
 17312  043A0H  06800H      ldr      r0,[r0]
 17314  043A2H  09901H      ldr      r1,[sp,#4]
 17316  043A4H  04288H      cmp      r0,r1
 17318  043A6H  0DB01H      blt.n    2 -> 17324
 17320  043A8H  0E017H      b        46 -> 17370
 17322  043AAH  046C0H      nop
 17324  043ACH  09806H      ldr      r0,[sp,#24]
 17326  043AEH  06800H      ldr      r0,[r0]
 17328  043B0H  09905H      ldr      r1,[sp,#20]
 17330  043B2H  04288H      cmp      r0,r1
 17332  043B4H  0D301H      bcc.n    2 -> 17338
 17334  043B6H  0DF01H      svc      1
 17336  043B8H  0003BH      <LineNo: 59>
 17338  043BAH  09904H      ldr      r1,[sp,#16]
 17340  043BCH  01808H      adds     r0,r1,r0
 17342  043BEH  0A902H      add      r1,sp,#8
 17344  043C0H  07809H      ldrb     r1,[r1]
 17346  043C2H  07001H      strb     r1,[r0]
 17348  043C4H  09806H      ldr      r0,[sp,#24]
 17350  043C6H  06801H      ldr      r1,[r0]
 17352  043C8H  03101H      adds     r1,#1
 17354  043CAH  06001H      str      r1,[r0]
 17356  043CCH  09803H      ldr      r0,[sp,#12]
 17358  043CEH  0A902H      add      r1,sp,#8
 17360  043D0H  0F7FFFFA8H  bl.w     UARTstr.GetChar
 17364  043D4H  0E000H      b        0 -> 17368
 17366  043D6H  0003DH      <LineNo: 61>
 17368  043D8H  0E7DBH      b        -74 -> 17298
 17370  043DAH  09806H      ldr      r0,[sp,#24]
 17372  043DCH  06800H      ldr      r0,[r0]
 17374  043DEH  09905H      ldr      r1,[sp,#20]
 17376  043E0H  04288H      cmp      r0,r1
 17378  043E2H  0D301H      bcc.n    2 -> 17384
 17380  043E4H  0DF01H      svc      1
 17382  043E6H  0003FH      <LineNo: 63>
 17384  043E8H  09904H      ldr      r1,[sp,#16]
 17386  043EAH  01808H      adds     r0,r1,r0
 17388  043ECH  02100H      movs     r1,#0
 17390  043EEH  07001H      strb     r1,[r0]
 17392  043F0H  0A802H      add      r0,sp,#8
 17394  043F2H  07800H      ldrb     r0,[r0]
 17396  043F4H  02820H      cmp      r0,#32
 17398  043F6H  0DA01H      bge.n    2 -> 17404
 17400  043F8H  0E016H      b        44 -> 17448
 17402  043FAH  046C0H      nop
 17404  043FCH  02001H      movs     r0,#1
 17406  043FEH  09907H      ldr      r1,[sp,#28]
 17408  04400H  06008H      str      r0,[r1]
 17410  04402H  09803H      ldr      r0,[sp,#12]
 17412  04404H  0A902H      add      r1,sp,#8
 17414  04406H  0F7FFFF8DH  bl.w     UARTstr.GetChar
 17418  0440AH  0E000H      b        0 -> 17422
 17420  0440CH  00043H      <LineNo: 67>
 17422  0440EH  0A802H      add      r0,sp,#8
 17424  04410H  07800H      ldrb     r0,[r0]
 17426  04412H  02820H      cmp      r0,#32
 17428  04414H  0DA01H      bge.n    2 -> 17434
 17430  04416H  0E007H      b        14 -> 17448
 17432  04418H  046C0H      nop
 17434  0441AH  09803H      ldr      r0,[sp,#12]
 17436  0441CH  0A902H      add      r1,sp,#8
 17438  0441EH  0F7FFFF81H  bl.w     UARTstr.GetChar
 17442  04422H  0E000H      b        0 -> 17446
 17444  04424H  00045H      <LineNo: 69>
 17446  04426H  0E7F2H      b        -28 -> 17422
 17448  04428H  0B008H      add      sp,#32
 17450  0442AH  0BD00H      pop      { pc }
 17452  0442CH  -4
 17456  04430H  010003964H

PROCEDURE UARTstr.DeviceStatus:
 17460  04434H  0B501H      push     { r0, lr }
 17462  04436H  0B081H      sub      sp,#4
 17464  04438H  09801H      ldr      r0,[sp,#4]
 17466  0443AH  04A08H      ldr      r2,[pc,#32] -> 17500
 17468  0443CH  05881H      ldr      r1,[r0,r2]
 17470  0443EH  06849H      ldr      r1,[r1,#4]
 17472  04440H  04A07H      ldr      r2,[pc,#28] -> 17504
 17474  04442H  04291H      cmp      r1,r2
 17476  04444H  0D001H      beq.n    2 -> 17482
 17478  04446H  0DF02H      svc      2
 17480  04448H  00053H      <LineNo: 83>
 17482  0444AH  09000H      str      r0,[sp]
 17484  0444CH  09800H      ldr      r0,[sp]
 17486  0444EH  0F7FFFC1BH  bl.w     UARTdev.Flags
 17490  04452H  0E000H      b        0 -> 17494
 17492  04454H  00053H      <LineNo: 83>
 17494  04456H  0B002H      add      sp,#8
 17496  04458H  0BD00H      pop      { pc }
 17498  0445AH  046C0H      nop
 17500  0445CH  -4
 17504  04460H  010003964H

PROCEDURE UARTstr..init:
 17508  04464H  0B500H      push     { lr }
 17510  04466H  0BD00H      pop      { pc }

MODULE Main:
 17512  04468H  0

PROCEDURE Main.configPins:
 17516  0446CH  0B503H      push     { r0, r1, lr }
 17518  0446EH  09800H      ldr      r0,[sp]
 17520  04470H  02102H      movs     r1,#2
 17522  04472H  0F7FCFCE7H  bl.w     GPIO.SetFunction
 17526  04476H  0E000H      b        0 -> 17530
 17528  04478H  00025H      <LineNo: 37>
 17530  0447AH  09801H      ldr      r0,[sp,#4]
 17532  0447CH  02102H      movs     r1,#2
 17534  0447EH  0F7FCFCE1H  bl.w     GPIO.SetFunction
 17538  04482H  0E000H      b        0 -> 17542
 17540  04484H  00026H      <LineNo: 38>
 17542  04486H  0B002H      add      sp,#8
 17544  04488H  0BD00H      pop      { pc }
 17546  0448AH  046C0H      nop

PROCEDURE Main.init:
 17548  0448CH  0B500H      push     { lr }
 17550  0448EH  0B089H      sub      sp,#36
 17552  04490H  0A802H      add      r0,sp,#8
 17554  04492H  04937H      ldr      r1,[pc,#220] -> 17776
 17556  04494H  0F7FFFC02H  bl.w     UARTdev.GetBaseCfg
 17560  04498H  0E000H      b        0 -> 17564
 17562  0449AH  00030H      <LineNo: 48>
 17564  0449CH  02001H      movs     r0,#1
 17566  0449EH  09004H      str      r0,[sp,#16]
 17568  044A0H  02000H      movs     r0,#0
 17570  044A2H  02101H      movs     r1,#1
 17572  044A4H  0F7FFFFE2H  bl.w     Main.configPins
 17576  044A8H  0E000H      b        0 -> 17580
 17578  044AAH  00034H      <LineNo: 52>
 17580  044ACH  02004H      movs     r0,#4
 17582  044AEH  02105H      movs     r1,#5
 17584  044B0H  0F7FFFFDCH  bl.w     Main.configPins
 17588  044B4H  0E000H      b        0 -> 17592
 17590  044B6H  00035H      <LineNo: 53>
 17592  044B8H  02000H      movs     r0,#0
 17594  044BAH  0A902H      add      r1,sp,#8
 17596  044BCH  04A2CH      ldr      r2,[pc,#176] -> 17776
 17598  044BEH  0234BH      movs     r3,#75
 17600  044C0H  0025BH      lsls     r3,r3,#9
 17602  044C2H  0466CH      mov      r4,sp
 17604  044C4H  0F7FFFC76H  bl.w     Terminals.InitUART
 17608  044C8H  0E000H      b        0 -> 17612
 17610  044CAH  00038H      <LineNo: 56>
 17612  044CCH  02000H      movs     r0,#0
 17614  044CEH  09900H      ldr      r1,[sp]
 17616  044D0H  04A28H      ldr      r2,[pc,#160] -> 17780
 17618  044D2H  04B29H      ldr      r3,[pc,#164] -> 17784
 17620  044D4H  0F7FFFC96H  bl.w     Terminals.Open
 17624  044D8H  0E000H      b        0 -> 17628
 17626  044DAH  00039H      <LineNo: 57>
 17628  044DCH  02001H      movs     r0,#1
 17630  044DEH  0A902H      add      r1,sp,#8
 17632  044E0H  04A23H      ldr      r2,[pc,#140] -> 17776
 17634  044E2H  0234BH      movs     r3,#75
 17636  044E4H  0025BH      lsls     r3,r3,#9
 17638  044E6H  0AC01H      add      r4,sp,#4
 17640  044E8H  0F7FFFC64H  bl.w     Terminals.InitUART
 17644  044ECH  0E000H      b        0 -> 17648
 17646  044EEH  0003AH      <LineNo: 58>
 17648  044F0H  02001H      movs     r0,#1
 17650  044F2H  09901H      ldr      r1,[sp,#4]
 17652  044F4H  04A1FH      ldr      r2,[pc,#124] -> 17780
 17654  044F6H  04B20H      ldr      r3,[pc,#128] -> 17784
 17656  044F8H  0F7FFFC84H  bl.w     Terminals.Open
 17660  044FCH  0E000H      b        0 -> 17664
 17662  044FEH  0003BH      <LineNo: 59>
 17664  04500H  0481EH      ldr      r0,[pc,#120] -> 17788
 17666  04502H  06800H      ldr      r0,[r0]
 17668  04504H  0491DH      ldr      r1,[pc,#116] -> 17788
 17670  04506H  06849H      ldr      r1,[r1,#4]
 17672  04508H  0F7FFFD8AH  bl.w     Out.Open
 17676  0450CH  0E000H      b        0 -> 17680
 17678  0450EH  0003EH      <LineNo: 62>
 17680  04510H  0481BH      ldr      r0,[pc,#108] -> 17792
 17682  04512H  06800H      ldr      r0,[r0]
 17684  04514H  0491AH      ldr      r1,[pc,#104] -> 17792
 17686  04516H  06849H      ldr      r1,[r1,#4]
 17688  04518H  0F7FFFE56H  bl.w     In.Open
 17692  0451CH  0E000H      b        0 -> 17696
 17694  0451EH  0003FH      <LineNo: 63>
 17696  04520H  02000H      movs     r0,#0
 17698  04522H  04914H      ldr      r1,[pc,#80] -> 17780
 17700  04524H  0F7FFFD02H  bl.w     Terminals.OpenErr
 17704  04528H  0E000H      b        0 -> 17708
 17706  0452AH  00044H      <LineNo: 68>
 17708  0452CH  02000H      movs     r0,#0
 17710  0452EH  04915H      ldr      r1,[pc,#84] -> 17796
 17712  04530H  06809H      ldr      r1,[r1]
 17714  04532H  0F7FFF9FFH  bl.w     RuntimeErrorsOu.SetWriter
 17718  04536H  0E000H      b        0 -> 17722
 17720  04538H  00045H      <LineNo: 69>
 17722  0453AH  02000H      movs     r0,#0
 17724  0453CH  04912H      ldr      r1,[pc,#72] -> 17800
 17726  0453EH  0F7FDFEB5H  bl.w     RuntimeErrors.SetHandler
 17730  04542H  0E000H      b        0 -> 17734
 17732  04544H  00046H      <LineNo: 70>
 17734  04546H  02001H      movs     r0,#1
 17736  04548H  0490AH      ldr      r1,[pc,#40] -> 17780
 17738  0454AH  0F7FFFCEFH  bl.w     Terminals.OpenErr
 17742  0454EH  0E000H      b        0 -> 17746
 17744  04550H  0004AH      <LineNo: 74>
 17746  04552H  02001H      movs     r0,#1
 17748  04554H  0490BH      ldr      r1,[pc,#44] -> 17796
 17750  04556H  06849H      ldr      r1,[r1,#4]
 17752  04558H  0F7FFF9ECH  bl.w     RuntimeErrorsOu.SetWriter
 17756  0455CH  0E000H      b        0 -> 17760
 17758  0455EH  0004BH      <LineNo: 75>
 17760  04560H  02001H      movs     r0,#1
 17762  04562H  04909H      ldr      r1,[pc,#36] -> 17800
 17764  04564H  0F7FDFEA2H  bl.w     RuntimeErrors.SetHandler
 17768  04568H  0E000H      b        0 -> 17772
 17770  0456AH  0004CH      <LineNo: 76>
 17772  0456CH  0B009H      add      sp,#36
 17774  0456EH  0BD00H      pop      { pc }
 17776  04570H  010003978H
 17780  04574H  0100042B0H
 17784  04578H  01000435CH
 17788  0457CH  02002FCBCH
 17792  04580H  02002FCACH
 17796  04584H  02002FCB4H
 17800  04588H  010003900H

PROCEDURE Main..init:
 17804  0458CH  0B500H      push     { lr }
 17806  0458EH  0F7FFFF7DH  bl.w     Main.init
 17810  04592H  0E000H      b        0 -> 17814
 17812  04594H  00050H      <LineNo: 80>
 17814  04596H  0BD00H      pop      { pc }

MODULE Coroutines:
 17816  04598H  0
 17820  0459CH  20
 17824  045A0H  0
 17828  045A4H  0
 17832  045A8H  0
 17836  045ACH  0

PROCEDURE Coroutines.Reset:
 17840  045B0H  0B501H      push     { r0, lr }
 17842  045B2H  0B081H      sub      sp,#4
 17844  045B4H  09801H      ldr      r0,[sp,#4]
 17846  045B6H  02800H      cmp      r0,#0
 17848  045B8H  0D101H      bne.n    2 -> 17854
 17850  045BAH  0DF65H      svc      101
 17852  045BCH  0001DH      <LineNo: 29>
 17854  045BEH  09801H      ldr      r0,[sp,#4]
 17856  045C0H  06880H      ldr      r0,[r0,#8]
 17858  045C2H  09901H      ldr      r1,[sp,#4]
 17860  045C4H  068C9H      ldr      r1,[r1,#12]
 17862  045C6H  01840H      adds     r0,r0,r1
 17864  045C8H  09901H      ldr      r1,[sp,#4]
 17866  045CAH  06008H      str      r0,[r1]
 17868  045CCH  09801H      ldr      r0,[sp,#4]
 17870  045CEH  06801H      ldr      r1,[r0]
 17872  045D0H  03904H      subs     r1,#4
 17874  045D2H  06001H      str      r1,[r0]
 17876  045D4H  09801H      ldr      r0,[sp,#4]
 17878  045D6H  06800H      ldr      r0,[r0]
 17880  045D8H  09901H      ldr      r1,[sp,#4]
 17882  045DAH  06809H      ldr      r1,[r1]
 17884  045DCH  06001H      str      r1,[r0]
 17886  045DEH  09801H      ldr      r0,[sp,#4]
 17888  045E0H  06801H      ldr      r1,[r0]
 17890  045E2H  03904H      subs     r1,#4
 17892  045E4H  06001H      str      r1,[r0]
 17894  045E6H  09801H      ldr      r0,[sp,#4]
 17896  045E8H  06800H      ldr      r0,[r0]
 17898  045EAH  09901H      ldr      r1,[sp,#4]
 17900  045ECH  06849H      ldr      r1,[r1,#4]
 17902  045EEH  06001H      str      r1,[r0]
 17904  045F0H  09801H      ldr      r0,[sp,#4]
 17906  045F2H  06800H      ldr      r0,[r0]
 17908  045F4H  06801H      ldr      r1,[r0]
 17910  045F6H  09100H      str      r1,[sp]
 17912  045F8H  09800H      ldr      r0,[sp]
 17914  045FAH  02101H      movs     r1,#1
 17916  045FCH  04308H      orrs     r0,r1
 17918  045FEH  09000H      str      r0,[sp]
 17920  04600H  09801H      ldr      r0,[sp,#4]
 17922  04602H  06800H      ldr      r0,[r0]
 17924  04604H  09900H      ldr      r1,[sp]
 17926  04606H  06001H      str      r1,[r0]
 17928  04608H  09801H      ldr      r0,[sp,#4]
 17930  0460AH  06801H      ldr      r1,[r0]
 17932  0460CH  03904H      subs     r1,#4
 17934  0460EH  06001H      str      r1,[r0]
 17936  04610H  09801H      ldr      r0,[sp,#4]
 17938  04612H  06801H      ldr      r1,[r0]
 17940  04614H  03904H      subs     r1,#4
 17942  04616H  06001H      str      r1,[r0]
 17944  04618H  0B002H      add      sp,#8
 17946  0461AH  0BD00H      pop      { pc }

PROCEDURE Coroutines.Allocate:
 17948  0461CH  0B503H      push     { r0, r1, lr }
 17950  0461EH  09800H      ldr      r0,[sp]
 17952  04620H  02800H      cmp      r0,#0
 17954  04622H  0D101H      bne.n    2 -> 17960
 17956  04624H  0DF65H      svc      101
 17958  04626H  00035H      <LineNo: 53>
 17960  04628H  09801H      ldr      r0,[sp,#4]
 17962  0462AH  09900H      ldr      r1,[sp]
 17964  0462CH  06048H      str      r0,[r1,#4]
 17966  0462EH  09800H      ldr      r0,[sp]
 17968  04630H  0F7FFFFBEH  bl.w     Coroutines.Reset
 17972  04634H  0E000H      b        0 -> 17976
 17974  04636H  00037H      <LineNo: 55>
 17976  04638H  0B002H      add      sp,#8
 17978  0463AH  0BD00H      pop      { pc }

PROCEDURE Coroutines.Init:
 17980  0463CH  0B50FH      push     { r0, r1, r2, r3, lr }
 17982  0463EH  09800H      ldr      r0,[sp]
 17984  04640H  02800H      cmp      r0,#0
 17986  04642H  0D101H      bne.n    2 -> 17992
 17988  04644H  0DF65H      svc      101
 17990  04646H  0003DH      <LineNo: 61>
 17992  04648H  09801H      ldr      r0,[sp,#4]
 17994  0464AH  09900H      ldr      r1,[sp]
 17996  0464CH  06088H      str      r0,[r1,#8]
 17998  0464EH  09802H      ldr      r0,[sp,#8]
 18000  04650H  09900H      ldr      r1,[sp]
 18002  04652H  060C8H      str      r0,[r1,#12]
 18004  04654H  09803H      ldr      r0,[sp,#12]
 18006  04656H  09900H      ldr      r1,[sp]
 18008  04658H  06108H      str      r0,[r1,#16]
 18010  0465AH  0B004H      add      sp,#16
 18012  0465CH  0BD00H      pop      { pc }
 18014  0465EH  046C0H      nop

PROCEDURE Coroutines.Transfer:
 18016  04660H  0B503H      push     { r0, r1, lr }
 18018  04662H  04668H      mov      r0,sp
 18020  04664H  09900H      ldr      r1,[sp]
 18022  04666H  06008H      str      r0,[r1]
 18024  04668H  09801H      ldr      r0,[sp,#4]
 18026  0466AH  06800H      ldr      r0,[r0]
 18028  0466CH  04685H      mov      sp,r0
 18030  0466EH  0B002H      add      sp,#8
 18032  04670H  0BD00H      pop      { pc }
 18034  04672H  046C0H      nop

PROCEDURE Coroutines..init:
 18036  04674H  0B500H      push     { lr }
 18038  04676H  0BD00H      pop      { pc }

MODULE SysTick:
 18040  04678H  0

PROCEDURE SysTick.Tick:
 18044  0467CH  0B500H      push     { lr }
 18046  0467EH  04804H      ldr      r0,[pc,#16] -> 18064
 18048  04680H  06801H      ldr      r1,[r0]
 18050  04682H  003C9H      lsls     r1,r1,#15
 18052  04684H  0D401H      bmi.n    2 -> 18058
 18054  04686H  02000H      movs     r0,#0
 18056  04688H  0E000H      b        0 -> 18060
 18058  0468AH  02001H      movs     r0,#1
 18060  0468CH  0BD00H      pop      { pc }
 18062  0468EH  046C0H      nop
 18064  04690H  0E000E010H

PROCEDURE SysTick.Enable:
 18068  04694H  0B500H      push     { lr }
 18070  04696H  04802H      ldr      r0,[pc,#8] -> 18080
 18072  04698H  02101H      movs     r1,#1
 18074  0469AH  06001H      str      r1,[r0]
 18076  0469CH  0BD00H      pop      { pc }
 18078  0469EH  046C0H      nop
 18080  046A0H  0E000E010H

PROCEDURE SysTick.Init:
 18084  046A4H  0B501H      push     { r0, lr }
 18086  046A6H  0B081H      sub      sp,#4
 18088  046A8H  09801H      ldr      r0,[sp,#4]
 18090  046AAH  0217DH      movs     r1,#125
 18092  046ACH  000C9H      lsls     r1,r1,#3
 18094  046AEH  04348H      muls     r0,r1
 18096  046B0H  03801H      subs     r0,#1
 18098  046B2H  09000H      str      r0,[sp]
 18100  046B4H  04803H      ldr      r0,[pc,#12] -> 18116
 18102  046B6H  09900H      ldr      r1,[sp]
 18104  046B8H  06001H      str      r1,[r0]
 18106  046BAH  04803H      ldr      r0,[pc,#12] -> 18120
 18108  046BCH  02100H      movs     r1,#0
 18110  046BEH  06001H      str      r1,[r0]
 18112  046C0H  0B002H      add      sp,#8
 18114  046C2H  0BD00H      pop      { pc }
 18116  046C4H  0E000E014H
 18120  046C8H  0E000E018H

PROCEDURE SysTick..init:
 18124  046CCH  0B500H      push     { lr }
 18126  046CEH  0BD00H      pop      { pc }

MODULE Kernel:
 18128  046D0H  0
 18132  046D4H  48
 18136  046D8H  0
 18140  046DCH  0
 18144  046E0H  0
 18148  046E4H  0
 18152  046E8H  92
 18156  046ECH  0
 18160  046F0H  0
 18164  046F4H  0
 18168  046F8H  0

PROCEDURE Kernel.slotIn:
 18172  046FCH  0B503H      push     { r0, r1, lr }
 18174  046FEH  0B082H      sub      sp,#8
 18176  04700H  09803H      ldr      r0,[sp,#12]
 18178  04702H  06C80H      ldr      r0,[r0,#72]
 18180  04704H  09902H      ldr      r1,[sp,#8]
 18182  04706H  06849H      ldr      r1,[r1,#4]
 18184  04708H  02201H      movs     r2,#1
 18186  0470AH  0408AH      lsls     r2,r1
 18188  0470CH  04210H      tst      r0,r2
 18190  0470EH  0D001H      beq.n    2 -> 18196
 18192  04710H  0E032H      b        100 -> 18296
 18194  04712H  046C0H      nop
 18196  04714H  09803H      ldr      r0,[sp,#12]
 18198  04716H  06C40H      ldr      r0,[r0,#68]
 18200  04718H  09000H      str      r0,[sp]
 18202  0471AH  09800H      ldr      r0,[sp]
 18204  0471CH  09001H      str      r0,[sp,#4]
 18206  0471EH  09800H      ldr      r0,[sp]
 18208  04720H  02800H      cmp      r0,#0
 18210  04722H  0D101H      bne.n    2 -> 18216
 18212  04724H  0E00EH      b        28 -> 18244
 18214  04726H  046C0H      nop
 18216  04728H  09800H      ldr      r0,[sp]
 18218  0472AH  06800H      ldr      r0,[r0]
 18220  0472CH  09902H      ldr      r1,[sp,#8]
 18222  0472EH  06809H      ldr      r1,[r1]
 18224  04730H  04288H      cmp      r0,r1
 18226  04732H  0DD01H      ble.n    2 -> 18232
 18228  04734H  0E006H      b        12 -> 18244
 18230  04736H  046C0H      nop
 18232  04738H  09800H      ldr      r0,[sp]
 18234  0473AH  09001H      str      r0,[sp,#4]
 18236  0473CH  09800H      ldr      r0,[sp]
 18238  0473EH  06AC0H      ldr      r0,[r0,#44]
 18240  04740H  09000H      str      r0,[sp]
 18242  04742H  0E7ECH      b        -40 -> 18206
 18244  04744H  09801H      ldr      r0,[sp,#4]
 18246  04746H  09900H      ldr      r1,[sp]
 18248  04748H  04288H      cmp      r0,r1
 18250  0474AH  0D001H      beq.n    2 -> 18256
 18252  0474CH  0E005H      b        10 -> 18266
 18254  0474EH  046C0H      nop
 18256  04750H  09802H      ldr      r0,[sp,#8]
 18258  04752H  09903H      ldr      r1,[sp,#12]
 18260  04754H  06448H      str      r0,[r1,#68]
 18262  04756H  0E003H      b        6 -> 18272
 18264  04758H  046C0H      nop
 18266  0475AH  09802H      ldr      r0,[sp,#8]
 18268  0475CH  09901H      ldr      r1,[sp,#4]
 18270  0475EH  062C8H      str      r0,[r1,#44]
 18272  04760H  09800H      ldr      r0,[sp]
 18274  04762H  09902H      ldr      r1,[sp,#8]
 18276  04764H  062C8H      str      r0,[r1,#44]
 18278  04766H  09802H      ldr      r0,[sp,#8]
 18280  04768H  06840H      ldr      r0,[r0,#4]
 18282  0476AH  02101H      movs     r1,#1
 18284  0476CH  04081H      lsls     r1,r0
 18286  0476EH  09A03H      ldr      r2,[sp,#12]
 18288  04770H  03248H      adds     r2,#72
 18290  04772H  06813H      ldr      r3,[r2]
 18292  04774H  0430BH      orrs     r3,r1
 18294  04776H  06013H      str      r3,[r2]
 18296  04778H  0B004H      add      sp,#16
 18298  0477AH  0BD00H      pop      { pc }

PROCEDURE Kernel.Allocate:
 18300  0477CH  0B51FH      push     { r0, r1, r2, r3, r4, lr }
 18302  0477EH  0B083H      sub      sp,#12
 18304  04780H  04831H      ldr      r0,[pc,#196] -> 18504
 18306  04782H  06801H      ldr      r1,[r0]
 18308  04784H  09100H      str      r1,[sp]
 18310  04786H  09800H      ldr      r0,[sp]
 18312  04788H  02802H      cmp      r0,#2
 18314  0478AH  0D301H      bcc.n    2 -> 18320
 18316  0478CH  0DF01H      svc      1
 18318  0478EH  00069H      <LineNo: 105>
 18320  04790H  0492EH      ldr      r1,[pc,#184] -> 18508
 18322  04792H  00080H      lsls     r0,r0,#2
 18324  04794H  01808H      adds     r0,r1,r0
 18326  04796H  06800H      ldr      r0,[r0]
 18328  04798H  09002H      str      r0,[sp,#8]
 18330  0479AH  02001H      movs     r0,#1
 18332  0479CH  09907H      ldr      r1,[sp,#28]
 18334  0479EH  06008H      str      r0,[r1]
 18336  047A0H  09802H      ldr      r0,[sp,#8]
 18338  047A2H  06CC0H      ldr      r0,[r0,#76]
 18340  047A4H  02810H      cmp      r0,#16
 18342  047A6H  0DB01H      blt.n    2 -> 18348
 18344  047A8H  0E04BH      b        150 -> 18498
 18346  047AAH  046C0H      nop
 18348  047ACH  09802H      ldr      r0,[sp,#8]
 18350  047AEH  06CC0H      ldr      r0,[r0,#76]
 18352  047B0H  09906H      ldr      r1,[sp,#24]
 18354  047B2H  06008H      str      r0,[r1]
 18356  047B4H  09806H      ldr      r0,[sp,#24]
 18358  047B6H  06800H      ldr      r0,[r0]
 18360  047B8H  02810H      cmp      r0,#16
 18362  047BAH  0D301H      bcc.n    2 -> 18368
 18364  047BCH  0DF01H      svc      1
 18366  047BEH  0006DH      <LineNo: 109>
 18368  047C0H  09902H      ldr      r1,[sp,#8]
 18370  047C2H  00080H      lsls     r0,r0,#2
 18372  047C4H  01808H      adds     r0,r1,r0
 18374  047C6H  06800H      ldr      r0,[r0]
 18376  047C8H  09905H      ldr      r1,[sp,#20]
 18378  047CAH  06008H      str      r0,[r1]
 18380  047CCH  09802H      ldr      r0,[sp,#8]
 18382  047CEH  06CC1H      ldr      r1,[r0,#76]
 18384  047D0H  03101H      adds     r1,#1
 18386  047D2H  064C1H      str      r1,[r0,#76]
 18388  047D4H  09805H      ldr      r0,[sp,#20]
 18390  047D6H  06800H      ldr      r0,[r0]
 18392  047D8H  02101H      movs     r1,#1
 18394  047DAH  06081H      str      r1,[r0,#8]
 18396  047DCH  09805H      ldr      r0,[sp,#20]
 18398  047DEH  06800H      ldr      r0,[r0]
 18400  047E0H  02107H      movs     r1,#7
 18402  047E2H  06001H      str      r1,[r0]
 18404  047E4H  09805H      ldr      r0,[sp,#20]
 18406  047E6H  06800H      ldr      r0,[r0]
 18408  047E8H  02100H      movs     r1,#0
 18410  047EAH  060C1H      str      r1,[r0,#12]
 18412  047ECH  09805H      ldr      r0,[sp,#20]
 18414  047EEH  06800H      ldr      r0,[r0]
 18416  047F0H  02100H      movs     r1,#0
 18418  047F2H  06141H      str      r1,[r0,#20]
 18420  047F4H  09805H      ldr      r0,[sp,#20]
 18422  047F6H  06800H      ldr      r0,[r0]
 18424  047F8H  02100H      movs     r1,#0
 18426  047FAH  06181H      str      r1,[r0,#24]
 18428  047FCH  0A801H      add      r0,sp,#4
 18430  047FEH  09906H      ldr      r1,[sp,#24]
 18432  04800H  06809H      ldr      r1,[r1]
 18434  04802H  09A04H      ldr      r2,[sp,#16]
 18436  04804H  0F7FDF858H  bl.w     Memory.AllocThreadStack
 18440  04808H  0E000H      b        0 -> 18444
 18442  0480AH  00072H      <LineNo: 114>
 18444  0480CH  09801H      ldr      r0,[sp,#4]
 18446  0480EH  02800H      cmp      r0,#0
 18448  04810H  0D101H      bne.n    2 -> 18454
 18450  04812H  0E016H      b        44 -> 18498
 18452  04814H  046C0H      nop
 18454  04816H  09805H      ldr      r0,[sp,#20]
 18456  04818H  06800H      ldr      r0,[r0]
 18458  0481AH  06A40H      ldr      r0,[r0,#36]
 18460  0481CH  09901H      ldr      r1,[sp,#4]
 18462  0481EH  09A04H      ldr      r2,[sp,#16]
 18464  04820H  09B06H      ldr      r3,[sp,#24]
 18466  04822H  0681BH      ldr      r3,[r3]
 18468  04824H  0F7FFFF0AH  bl.w     Coroutines.Init
 18472  04828H  0E000H      b        0 -> 18476
 18474  0482AH  00074H      <LineNo: 116>
 18476  0482CH  09805H      ldr      r0,[sp,#20]
 18478  0482EH  06800H      ldr      r0,[r0]
 18480  04830H  06A40H      ldr      r0,[r0,#36]
 18482  04832H  09903H      ldr      r1,[sp,#12]
 18484  04834H  0F7FFFEF2H  bl.w     Coroutines.Allocate
 18488  04838H  0E000H      b        0 -> 18492
 18490  0483AH  00075H      <LineNo: 117>
 18492  0483CH  02000H      movs     r0,#0
 18494  0483EH  09907H      ldr      r1,[sp,#28]
 18496  04840H  06008H      str      r0,[r1]
 18498  04842H  0B008H      add      sp,#32
 18500  04844H  0BD00H      pop      { pc }
 18502  04846H  046C0H      nop
 18504  04848H  0D0000000H
 18508  0484CH  02002FC94H

PROCEDURE Kernel.Reallocate:
 18512  04850H  0B507H      push     { r0, r1, r2, lr }
 18514  04852H  02001H      movs     r0,#1
 18516  04854H  09902H      ldr      r1,[sp,#8]
 18518  04856H  06008H      str      r0,[r1]
 18520  04858H  09800H      ldr      r0,[sp]
 18522  0485AH  06880H      ldr      r0,[r0,#8]
 18524  0485CH  02801H      cmp      r0,#1
 18526  0485EH  0D001H      beq.n    2 -> 18532
 18528  04860H  0E016H      b        44 -> 18576
 18530  04862H  046C0H      nop
 18532  04864H  02001H      movs     r0,#1
 18534  04866H  09900H      ldr      r1,[sp]
 18536  04868H  06008H      str      r0,[r1]
 18538  0486AH  02000H      movs     r0,#0
 18540  0486CH  09900H      ldr      r1,[sp]
 18542  0486EH  060C8H      str      r0,[r1,#12]
 18544  04870H  02000H      movs     r0,#0
 18546  04872H  09900H      ldr      r1,[sp]
 18548  04874H  06148H      str      r0,[r1,#20]
 18550  04876H  02000H      movs     r0,#0
 18552  04878H  09900H      ldr      r1,[sp]
 18554  0487AH  06188H      str      r0,[r1,#24]
 18556  0487CH  09800H      ldr      r0,[sp]
 18558  0487EH  06A40H      ldr      r0,[r0,#36]
 18560  04880H  09901H      ldr      r1,[sp,#4]
 18562  04882H  0F7FFFECBH  bl.w     Coroutines.Allocate
 18566  04886H  0E000H      b        0 -> 18570
 18568  04888H  00083H      <LineNo: 131>
 18570  0488AH  02000H      movs     r0,#0
 18572  0488CH  09902H      ldr      r1,[sp,#8]
 18574  0488EH  06008H      str      r0,[r1]
 18576  04890H  0B003H      add      sp,#12
 18578  04892H  0BD00H      pop      { pc }

PROCEDURE Kernel.Enable:
 18580  04894H  0B501H      push     { r0, lr }
 18582  04896H  09800H      ldr      r0,[sp]
 18584  04898H  02800H      cmp      r0,#0
 18586  0489AH  0D101H      bne.n    2 -> 18592
 18588  0489CH  0DF65H      svc      101
 18590  0489EH  0008BH      <LineNo: 139>
 18592  048A0H  02000H      movs     r0,#0
 18594  048A2H  09900H      ldr      r1,[sp]
 18596  048A4H  06088H      str      r0,[r1,#8]
 18598  048A6H  0B001H      add      sp,#4
 18600  048A8H  0BD00H      pop      { pc }
 18602  048AAH  046C0H      nop

PROCEDURE Kernel.SetPrio:
 18604  048ACH  0B503H      push     { r0, r1, lr }
 18606  048AEH  09801H      ldr      r0,[sp,#4]
 18608  048B0H  09900H      ldr      r1,[sp]
 18610  048B2H  06008H      str      r0,[r1]
 18612  048B4H  0B002H      add      sp,#8
 18614  048B6H  0BD00H      pop      { pc }

PROCEDURE Kernel.SetPeriod:
 18616  048B8H  0B507H      push     { r0, r1, r2, lr }
 18618  048BAH  09801H      ldr      r0,[sp,#4]
 18620  048BCH  09900H      ldr      r1,[sp]
 18622  048BEH  060C8H      str      r0,[r1,#12]
 18624  048C0H  09802H      ldr      r0,[sp,#8]
 18626  048C2H  09900H      ldr      r1,[sp]
 18628  048C4H  06108H      str      r0,[r1,#16]
 18630  048C6H  0B003H      add      sp,#12
 18632  048C8H  0BD00H      pop      { pc }
 18634  048CAH  046C0H      nop

PROCEDURE Kernel.Next:
 18636  048CCH  0B500H      push     { lr }
 18638  048CEH  0B082H      sub      sp,#8
 18640  048D0H  0480BH      ldr      r0,[pc,#44] -> 18688
 18642  048D2H  06801H      ldr      r1,[r0]
 18644  048D4H  09100H      str      r1,[sp]
 18646  048D6H  09800H      ldr      r0,[sp]
 18648  048D8H  02802H      cmp      r0,#2
 18650  048DAH  0D301H      bcc.n    2 -> 18656
 18652  048DCH  0DF01H      svc      1
 18654  048DEH  000A3H      <LineNo: 163>
 18656  048E0H  04908H      ldr      r1,[pc,#32] -> 18692
 18658  048E2H  00080H      lsls     r0,r0,#2
 18660  048E4H  01808H      adds     r0,r1,r0
 18662  048E6H  06800H      ldr      r0,[r0]
 18664  048E8H  09001H      str      r0,[sp,#4]
 18666  048EAH  09801H      ldr      r0,[sp,#4]
 18668  048ECH  06C00H      ldr      r0,[r0,#64]
 18670  048EEH  06A40H      ldr      r0,[r0,#36]
 18672  048F0H  09901H      ldr      r1,[sp,#4]
 18674  048F2H  06D49H      ldr      r1,[r1,#84]
 18676  048F4H  0F7FFFEB4H  bl.w     Coroutines.Transfer
 18680  048F8H  0E000H      b        0 -> 18684
 18682  048FAH  000A4H      <LineNo: 164>
 18684  048FCH  0B002H      add      sp,#8
 18686  048FEH  0BD00H      pop      { pc }
 18688  04900H  0D0000000H
 18692  04904H  02002FC94H

PROCEDURE Kernel.NextQueued:
 18696  04908H  0B500H      push     { lr }
 18698  0490AH  0B081H      sub      sp,#4
 18700  0490CH  04807H      ldr      r0,[pc,#28] -> 18732
 18702  0490EH  06801H      ldr      r1,[r0]
 18704  04910H  09100H      str      r1,[sp]
 18706  04912H  09800H      ldr      r0,[sp]
 18708  04914H  02802H      cmp      r0,#2
 18710  04916H  0D301H      bcc.n    2 -> 18716
 18712  04918H  0DF01H      svc      1
 18714  0491AH  000ABH      <LineNo: 171>
 18716  0491CH  04904H      ldr      r1,[pc,#16] -> 18736
 18718  0491EH  00080H      lsls     r0,r0,#2
 18720  04920H  01808H      adds     r0,r1,r0
 18722  04922H  06800H      ldr      r0,[r0]
 18724  04924H  06C40H      ldr      r0,[r0,#68]
 18726  04926H  0B001H      add      sp,#4
 18728  04928H  0BD00H      pop      { pc }
 18730  0492AH  046C0H      nop
 18732  0492CH  0D0000000H
 18736  04930H  02002FC94H

PROCEDURE Kernel.SuspendMe:
 18740  04934H  0B500H      push     { lr }
 18742  04936H  0B082H      sub      sp,#8
 18744  04938H  0480DH      ldr      r0,[pc,#52] -> 18800
 18746  0493AH  06801H      ldr      r1,[r0]
 18748  0493CH  09100H      str      r1,[sp]
 18750  0493EH  09800H      ldr      r0,[sp]
 18752  04940H  02802H      cmp      r0,#2
 18754  04942H  0D301H      bcc.n    2 -> 18760
 18756  04944H  0DF01H      svc      1
 18758  04946H  000B4H      <LineNo: 180>
 18760  04948H  0490AH      ldr      r1,[pc,#40] -> 18804
 18762  0494AH  00080H      lsls     r0,r0,#2
 18764  0494CH  01808H      adds     r0,r1,r0
 18766  0494EH  06800H      ldr      r0,[r0]
 18768  04950H  09001H      str      r0,[sp,#4]
 18770  04952H  09801H      ldr      r0,[sp,#4]
 18772  04954H  06C00H      ldr      r0,[r0,#64]
 18774  04956H  02101H      movs     r1,#1
 18776  04958H  06081H      str      r1,[r0,#8]
 18778  0495AH  09801H      ldr      r0,[sp,#4]
 18780  0495CH  06C00H      ldr      r0,[r0,#64]
 18782  0495EH  06A40H      ldr      r0,[r0,#36]
 18784  04960H  09901H      ldr      r1,[sp,#4]
 18786  04962H  06D49H      ldr      r1,[r1,#84]
 18788  04964H  0F7FFFE7CH  bl.w     Coroutines.Transfer
 18792  04968H  0E000H      b        0 -> 18796
 18794  0496AH  000B6H      <LineNo: 182>
 18796  0496CH  0B002H      add      sp,#8
 18798  0496EH  0BD00H      pop      { pc }
 18800  04970H  0D0000000H
 18804  04974H  02002FC94H

PROCEDURE Kernel.DelayMe:
 18808  04978H  0B501H      push     { r0, lr }
 18810  0497AH  0B082H      sub      sp,#8
 18812  0497CH  0480DH      ldr      r0,[pc,#52] -> 18868
 18814  0497EH  06801H      ldr      r1,[r0]
 18816  04980H  09100H      str      r1,[sp]
 18818  04982H  09800H      ldr      r0,[sp]
 18820  04984H  02802H      cmp      r0,#2
 18822  04986H  0D301H      bcc.n    2 -> 18828
 18824  04988H  0DF01H      svc      1
 18826  0498AH  000BEH      <LineNo: 190>
 18828  0498CH  0490AH      ldr      r1,[pc,#40] -> 18872
 18830  0498EH  00080H      lsls     r0,r0,#2
 18832  04990H  01808H      adds     r0,r1,r0
 18834  04992H  06800H      ldr      r0,[r0]
 18836  04994H  09001H      str      r0,[sp,#4]
 18838  04996H  09801H      ldr      r0,[sp,#4]
 18840  04998H  06C00H      ldr      r0,[r0,#64]
 18842  0499AH  09902H      ldr      r1,[sp,#8]
 18844  0499CH  06141H      str      r1,[r0,#20]
 18846  0499EH  09801H      ldr      r0,[sp,#4]
 18848  049A0H  06C00H      ldr      r0,[r0,#64]
 18850  049A2H  06A40H      ldr      r0,[r0,#36]
 18852  049A4H  09901H      ldr      r1,[sp,#4]
 18854  049A6H  06D49H      ldr      r1,[r1,#84]
 18856  049A8H  0F7FFFE5AH  bl.w     Coroutines.Transfer
 18860  049ACH  0E000H      b        0 -> 18864
 18862  049AEH  000C0H      <LineNo: 192>
 18864  049B0H  0B003H      add      sp,#12
 18866  049B2H  0BD00H      pop      { pc }
 18868  049B4H  0D0000000H
 18872  049B8H  02002FC94H

PROCEDURE Kernel.StartTimeout:
 18876  049BCH  0B501H      push     { r0, lr }
 18878  049BEH  0B081H      sub      sp,#4
 18880  049C0H  04808H      ldr      r0,[pc,#32] -> 18916
 18882  049C2H  06801H      ldr      r1,[r0]
 18884  049C4H  09100H      str      r1,[sp]
 18886  049C6H  09800H      ldr      r0,[sp]
 18888  049C8H  02802H      cmp      r0,#2
 18890  049CAH  0D301H      bcc.n    2 -> 18896
 18892  049CCH  0DF01H      svc      1
 18894  049CEH  000C8H      <LineNo: 200>
 18896  049D0H  04905H      ldr      r1,[pc,#20] -> 18920
 18898  049D2H  00080H      lsls     r0,r0,#2
 18900  049D4H  01808H      adds     r0,r1,r0
 18902  049D6H  06800H      ldr      r0,[r0]
 18904  049D8H  06C00H      ldr      r0,[r0,#64]
 18906  049DAH  09901H      ldr      r1,[sp,#4]
 18908  049DCH  06141H      str      r1,[r0,#20]
 18910  049DEH  0B002H      add      sp,#8
 18912  049E0H  0BD00H      pop      { pc }
 18914  049E2H  046C0H      nop
 18916  049E4H  0D0000000H
 18920  049E8H  02002FC94H

PROCEDURE Kernel.CancelTimeout:
 18924  049ECH  0B500H      push     { lr }
 18926  049EEH  02000H      movs     r0,#0
 18928  049F0H  0F7FFFFE4H  bl.w     Kernel.StartTimeout
 18932  049F4H  0E000H      b        0 -> 18936
 18934  049F6H  000CEH      <LineNo: 206>
 18936  049F8H  0BD00H      pop      { pc }
 18938  049FAH  046C0H      nop

PROCEDURE Kernel.AwaitDeviceFlags:
 18940  049FCH  0B507H      push     { r0, r1, r2, lr }
 18942  049FEH  0B082H      sub      sp,#8
 18944  04A00H  04811H      ldr      r0,[pc,#68] -> 19016
 18946  04A02H  06801H      ldr      r1,[r0]
 18948  04A04H  09100H      str      r1,[sp]
 18950  04A06H  09800H      ldr      r0,[sp]
 18952  04A08H  02802H      cmp      r0,#2
 18954  04A0AH  0D301H      bcc.n    2 -> 18960
 18956  04A0CH  0DF01H      svc      1
 18958  04A0EH  000DDH      <LineNo: 221>
 18960  04A10H  0490EH      ldr      r1,[pc,#56] -> 19020
 18962  04A12H  00080H      lsls     r0,r0,#2
 18964  04A14H  01808H      adds     r0,r1,r0
 18966  04A16H  06800H      ldr      r0,[r0]
 18968  04A18H  09001H      str      r0,[sp,#4]
 18970  04A1AH  09801H      ldr      r0,[sp,#4]
 18972  04A1CH  06C00H      ldr      r0,[r0,#64]
 18974  04A1EH  09902H      ldr      r1,[sp,#8]
 18976  04A20H  06181H      str      r1,[r0,#24]
 18978  04A22H  09801H      ldr      r0,[sp,#4]
 18980  04A24H  06C00H      ldr      r0,[r0,#64]
 18982  04A26H  09903H      ldr      r1,[sp,#12]
 18984  04A28H  061C1H      str      r1,[r0,#28]
 18986  04A2AH  09801H      ldr      r0,[sp,#4]
 18988  04A2CH  06C00H      ldr      r0,[r0,#64]
 18990  04A2EH  09904H      ldr      r1,[sp,#16]
 18992  04A30H  06201H      str      r1,[r0,#32]
 18994  04A32H  09801H      ldr      r0,[sp,#4]
 18996  04A34H  06C00H      ldr      r0,[r0,#64]
 18998  04A36H  06A40H      ldr      r0,[r0,#36]
 19000  04A38H  09901H      ldr      r1,[sp,#4]
 19002  04A3AH  06D49H      ldr      r1,[r1,#84]
 19004  04A3CH  0F7FFFE10H  bl.w     Coroutines.Transfer
 19008  04A40H  0E000H      b        0 -> 19012
 19010  04A42H  000E1H      <LineNo: 225>
 19012  04A44H  0B005H      add      sp,#20
 19014  04A46H  0BD00H      pop      { pc }
 19016  04A48H  0D0000000H
 19020  04A4CH  02002FC94H

PROCEDURE Kernel.CancelAwaitDeviceFlags:
 19024  04A50H  0B500H      push     { lr }
 19026  04A52H  0B082H      sub      sp,#8
 19028  04A54H  04809H      ldr      r0,[pc,#36] -> 19068
 19030  04A56H  06801H      ldr      r1,[r0]
 19032  04A58H  09100H      str      r1,[sp]
 19034  04A5AH  09800H      ldr      r0,[sp]
 19036  04A5CH  02802H      cmp      r0,#2
 19038  04A5EH  0D301H      bcc.n    2 -> 19044
 19040  04A60H  0DF01H      svc      1
 19042  04A62H  000E9H      <LineNo: 233>
 19044  04A64H  04906H      ldr      r1,[pc,#24] -> 19072
 19046  04A66H  00080H      lsls     r0,r0,#2
 19048  04A68H  01808H      adds     r0,r1,r0
 19050  04A6AH  06800H      ldr      r0,[r0]
 19052  04A6CH  09001H      str      r0,[sp,#4]
 19054  04A6EH  09801H      ldr      r0,[sp,#4]
 19056  04A70H  06C00H      ldr      r0,[r0,#64]
 19058  04A72H  02100H      movs     r1,#0
 19060  04A74H  06181H      str      r1,[r0,#24]
 19062  04A76H  0B002H      add      sp,#8
 19064  04A78H  0BD00H      pop      { pc }
 19066  04A7AH  046C0H      nop
 19068  04A7CH  0D0000000H
 19072  04A80H  02002FC94H

PROCEDURE Kernel.Trigger:
 19076  04A84H  0B500H      push     { lr }
 19078  04A86H  0B081H      sub      sp,#4
 19080  04A88H  04807H      ldr      r0,[pc,#28] -> 19112
 19082  04A8AH  06801H      ldr      r1,[r0]
 19084  04A8CH  09100H      str      r1,[sp]
 19086  04A8EH  09800H      ldr      r0,[sp]
 19088  04A90H  02802H      cmp      r0,#2
 19090  04A92H  0D301H      bcc.n    2 -> 19096
 19092  04A94H  0DF01H      svc      1
 19094  04A96H  000F1H      <LineNo: 241>
 19096  04A98H  04904H      ldr      r1,[pc,#16] -> 19116
 19098  04A9AH  00080H      lsls     r0,r0,#2
 19100  04A9CH  01808H      adds     r0,r1,r0
 19102  04A9EH  06800H      ldr      r0,[r0]
 19104  04AA0H  06C00H      ldr      r0,[r0,#64]
 19106  04AA2H  06A80H      ldr      r0,[r0,#40]
 19108  04AA4H  0B001H      add      sp,#4
 19110  04AA6H  0BD00H      pop      { pc }
 19112  04AA8H  0D0000000H
 19116  04AACH  02002FC94H

PROCEDURE Kernel.ChangePrio:
 19120  04AB0H  0B501H      push     { r0, lr }
 19122  04AB2H  0B081H      sub      sp,#4
 19124  04AB4H  04808H      ldr      r0,[pc,#32] -> 19160
 19126  04AB6H  06801H      ldr      r1,[r0]
 19128  04AB8H  09100H      str      r1,[sp]
 19130  04ABAH  09800H      ldr      r0,[sp]
 19132  04ABCH  02802H      cmp      r0,#2
 19134  04ABEH  0D301H      bcc.n    2 -> 19140
 19136  04AC0H  0DF01H      svc      1
 19138  04AC2H  000FAH      <LineNo: 250>
 19140  04AC4H  04905H      ldr      r1,[pc,#20] -> 19164
 19142  04AC6H  00080H      lsls     r0,r0,#2
 19144  04AC8H  01808H      adds     r0,r1,r0
 19146  04ACAH  06800H      ldr      r0,[r0]
 19148  04ACCH  06C00H      ldr      r0,[r0,#64]
 19150  04ACEH  09901H      ldr      r1,[sp,#4]
 19152  04AD0H  06001H      str      r1,[r0]
 19154  04AD2H  0B002H      add      sp,#8
 19156  04AD4H  0BD00H      pop      { pc }
 19158  04AD6H  046C0H      nop
 19160  04AD8H  0D0000000H
 19164  04ADCH  02002FC94H

PROCEDURE Kernel.ChangePeriod:
 19168  04AE0H  0B503H      push     { r0, r1, lr }
 19170  04AE2H  0B082H      sub      sp,#8
 19172  04AE4H  0480BH      ldr      r0,[pc,#44] -> 19220
 19174  04AE6H  06801H      ldr      r1,[r0]
 19176  04AE8H  09100H      str      r1,[sp]
 19178  04AEAH  09800H      ldr      r0,[sp]
 19180  04AECH  02802H      cmp      r0,#2
 19182  04AEEH  0D301H      bcc.n    2 -> 19188
 19184  04AF0H  0DF01H      svc      1
 19186  04AF2H  00102H      <LineNo: 258>
 19188  04AF4H  04908H      ldr      r1,[pc,#32] -> 19224
 19190  04AF6H  00080H      lsls     r0,r0,#2
 19192  04AF8H  01808H      adds     r0,r1,r0
 19194  04AFAH  06800H      ldr      r0,[r0]
 19196  04AFCH  09001H      str      r0,[sp,#4]
 19198  04AFEH  09801H      ldr      r0,[sp,#4]
 19200  04B00H  06C00H      ldr      r0,[r0,#64]
 19202  04B02H  09902H      ldr      r1,[sp,#8]
 19204  04B04H  060C1H      str      r1,[r0,#12]
 19206  04B06H  09801H      ldr      r0,[sp,#4]
 19208  04B08H  06C00H      ldr      r0,[r0,#64]
 19210  04B0AH  09903H      ldr      r1,[sp,#12]
 19212  04B0CH  06101H      str      r1,[r0,#16]
 19214  04B0EH  0B004H      add      sp,#16
 19216  04B10H  0BD00H      pop      { pc }
 19218  04B12H  046C0H      nop
 19220  04B14H  0D0000000H
 19224  04B18H  02002FC94H

PROCEDURE Kernel.Ct:
 19228  04B1CH  0B500H      push     { lr }
 19230  04B1EH  0B081H      sub      sp,#4
 19232  04B20H  04807H      ldr      r0,[pc,#28] -> 19264
 19234  04B22H  06801H      ldr      r1,[r0]
 19236  04B24H  09100H      str      r1,[sp]
 19238  04B26H  09800H      ldr      r0,[sp]
 19240  04B28H  02802H      cmp      r0,#2
 19242  04B2AH  0D301H      bcc.n    2 -> 19248
 19244  04B2CH  0DF01H      svc      1
 19246  04B2EH  0010BH      <LineNo: 267>
 19248  04B30H  04904H      ldr      r1,[pc,#16] -> 19268
 19250  04B32H  00080H      lsls     r0,r0,#2
 19252  04B34H  01808H      adds     r0,r1,r0
 19254  04B36H  06800H      ldr      r0,[r0]
 19256  04B38H  06C00H      ldr      r0,[r0,#64]
 19258  04B3AH  0B001H      add      sp,#4
 19260  04B3CH  0BD00H      pop      { pc }
 19262  04B3EH  046C0H      nop
 19264  04B40H  0D0000000H
 19268  04B44H  02002FC94H

PROCEDURE Kernel.Tid:
 19272  04B48H  0B500H      push     { lr }
 19274  04B4AH  0B081H      sub      sp,#4
 19276  04B4CH  04807H      ldr      r0,[pc,#28] -> 19308
 19278  04B4EH  06801H      ldr      r1,[r0]
 19280  04B50H  09100H      str      r1,[sp]
 19282  04B52H  09800H      ldr      r0,[sp]
 19284  04B54H  02802H      cmp      r0,#2
 19286  04B56H  0D301H      bcc.n    2 -> 19292
 19288  04B58H  0DF01H      svc      1
 19290  04B5AH  00113H      <LineNo: 275>
 19292  04B5CH  04904H      ldr      r1,[pc,#16] -> 19312
 19294  04B5EH  00080H      lsls     r0,r0,#2
 19296  04B60H  01808H      adds     r0,r1,r0
 19298  04B62H  06800H      ldr      r0,[r0]
 19300  04B64H  06C00H      ldr      r0,[r0,#64]
 19302  04B66H  06840H      ldr      r0,[r0,#4]
 19304  04B68H  0B001H      add      sp,#4
 19306  04B6AH  0BD00H      pop      { pc }
 19308  04B6CH  0D0000000H
 19312  04B70H  02002FC94H

PROCEDURE Kernel.Prio:
 19316  04B74H  0B501H      push     { r0, lr }
 19318  04B76H  09800H      ldr      r0,[sp]
 19320  04B78H  06800H      ldr      r0,[r0]
 19322  04B7AH  0B001H      add      sp,#4
 19324  04B7CH  0BD00H      pop      { pc }
 19326  04B7EH  046C0H      nop

PROCEDURE Kernel.loopc:
 19328  04B80H  0B500H      push     { lr }
 19330  04B82H  0B086H      sub      sp,#24
 19332  04B84H  0486FH      ldr      r0,[pc,#444] -> 19780
 19334  04B86H  06801H      ldr      r1,[r0]
 19336  04B88H  09101H      str      r1,[sp,#4]
 19338  04B8AH  09801H      ldr      r0,[sp,#4]
 19340  04B8CH  02180H      movs     r1,#128
 19342  04B8EH  0F7FCFF4FH  bl.w     Memory.ResetMainStack
 19346  04B92H  0E000H      b        0 -> 19350
 19348  04B94H  00122H      <LineNo: 290>
 19350  04B96H  09801H      ldr      r0,[sp,#4]
 19352  04B98H  02802H      cmp      r0,#2
 19354  04B9AH  0D301H      bcc.n    2 -> 19360
 19356  04B9CH  0DF01H      svc      1
 19358  04B9EH  00123H      <LineNo: 291>
 19360  04BA0H  04969H      ldr      r1,[pc,#420] -> 19784
 19362  04BA2H  00080H      lsls     r0,r0,#2
 19364  04BA4H  01808H      adds     r0,r1,r0
 19366  04BA6H  06800H      ldr      r0,[r0]
 19368  04BA8H  09004H      str      r0,[sp,#16]
 19370  04BAAH  02000H      movs     r0,#0
 19372  04BACH  09904H      ldr      r1,[sp,#16]
 19374  04BAEH  06408H      str      r0,[r1,#64]
 19376  04BB0H  0F7FFFD64H  bl.w     SysTick.Tick
 19380  04BB4H  0E000H      b        0 -> 19384
 19382  04BB6H  00126H      <LineNo: 294>
 19384  04BB8H  02101H      movs     r1,#1
 19386  04BBAH  04208H      tst      r0,r1
 19388  04BBCH  0D101H      bne.n    2 -> 19394
 19390  04BBEH  0E0B1H      b        354 -> 19748
 19392  04BC0H  046C0H      nop
 19394  04BC2H  02000H      movs     r0,#0
 19396  04BC4H  09000H      str      r0,[sp]
 19398  04BC6H  09800H      ldr      r0,[sp]
 19400  04BC8H  09904H      ldr      r1,[sp,#16]
 19402  04BCAH  06CC9H      ldr      r1,[r1,#76]
 19404  04BCCH  04288H      cmp      r0,r1
 19406  04BCEH  0DB01H      blt.n    2 -> 19412
 19408  04BD0H  0E0A8H      b        336 -> 19748
 19410  04BD2H  046C0H      nop
 19412  04BD4H  09800H      ldr      r0,[sp]
 19414  04BD6H  02810H      cmp      r0,#16
 19416  04BD8H  0D301H      bcc.n    2 -> 19422
 19418  04BDAH  0DF01H      svc      1
 19420  04BDCH  00129H      <LineNo: 297>
 19422  04BDEH  09904H      ldr      r1,[sp,#16]
 19424  04BE0H  00080H      lsls     r0,r0,#2
 19426  04BE2H  01808H      adds     r0,r1,r0
 19428  04BE4H  06800H      ldr      r0,[r0]
 19430  04BE6H  09002H      str      r0,[sp,#8]
 19432  04BE8H  02000H      movs     r0,#0
 19434  04BEAH  09003H      str      r0,[sp,#12]
 19436  04BECH  09802H      ldr      r0,[sp,#8]
 19438  04BEEH  06880H      ldr      r0,[r0,#8]
 19440  04BF0H  02800H      cmp      r0,#0
 19442  04BF2H  0D001H      beq.n    2 -> 19448
 19444  04BF4H  0E087H      b        270 -> 19718
 19446  04BF6H  046C0H      nop
 19448  04BF8H  02000H      movs     r0,#0
 19450  04BFAH  09902H      ldr      r1,[sp,#8]
 19452  04BFCH  06288H      str      r0,[r1,#40]
 19454  04BFEH  09802H      ldr      r0,[sp,#8]
 19456  04C00H  06940H      ldr      r0,[r0,#20]
 19458  04C02H  02800H      cmp      r0,#0
 19460  04C04H  0DD01H      ble.n    2 -> 19466
 19462  04C06H  0E010H      b        32 -> 19498
 19464  04C08H  046C0H      nop
 19466  04C0AH  09802H      ldr      r0,[sp,#8]
 19468  04C0CH  068C0H      ldr      r0,[r0,#12]
 19470  04C0EH  02800H      cmp      r0,#0
 19472  04C10H  0D001H      beq.n    2 -> 19478
 19474  04C12H  0E00AH      b        20 -> 19498
 19476  04C14H  046C0H      nop
 19478  04C16H  09802H      ldr      r0,[sp,#8]
 19480  04C18H  06980H      ldr      r0,[r0,#24]
 19482  04C1AH  02800H      cmp      r0,#0
 19484  04C1CH  0D001H      beq.n    2 -> 19490
 19486  04C1EH  0E004H      b        8 -> 19498
 19488  04C20H  046C0H      nop
 19490  04C22H  09802H      ldr      r0,[sp,#8]
 19492  04C24H  09003H      str      r0,[sp,#12]
 19494  04C26H  0E06EH      b        220 -> 19718
 19496  04C28H  046C0H      nop
 19498  04C2AH  09802H      ldr      r0,[sp,#8]
 19500  04C2CH  068C0H      ldr      r0,[r0,#12]
 19502  04C2EH  02800H      cmp      r0,#0
 19504  04C30H  0DC01H      bgt.n    2 -> 19510
 19506  04C32H  0E017H      b        46 -> 19556
 19508  04C34H  046C0H      nop
 19510  04C36H  09804H      ldr      r0,[sp,#16]
 19512  04C38H  06D00H      ldr      r0,[r0,#80]
 19514  04C3AH  09902H      ldr      r1,[sp,#8]
 19516  04C3CH  03110H      adds     r1,#16
 19518  04C3EH  0680AH      ldr      r2,[r1]
 19520  04C40H  01A12H      subs     r2,r2,r0
 19522  04C42H  0600AH      str      r2,[r1]
 19524  04C44H  09802H      ldr      r0,[sp,#8]
 19526  04C46H  06900H      ldr      r0,[r0,#16]
 19528  04C48H  02800H      cmp      r0,#0
 19530  04C4AH  0DD01H      ble.n    2 -> 19536
 19532  04C4CH  0E00AH      b        20 -> 19556
 19534  04C4EH  046C0H      nop
 19536  04C50H  09802H      ldr      r0,[sp,#8]
 19538  04C52H  06900H      ldr      r0,[r0,#16]
 19540  04C54H  09902H      ldr      r1,[sp,#8]
 19542  04C56H  068C9H      ldr      r1,[r1,#12]
 19544  04C58H  01840H      adds     r0,r0,r1
 19546  04C5AH  09902H      ldr      r1,[sp,#8]
 19548  04C5CH  06108H      str      r0,[r1,#16]
 19550  04C5EH  02001H      movs     r0,#1
 19552  04C60H  09902H      ldr      r1,[sp,#8]
 19554  04C62H  06288H      str      r0,[r1,#40]
 19556  04C64H  09802H      ldr      r0,[sp,#8]
 19558  04C66H  06940H      ldr      r0,[r0,#20]
 19560  04C68H  02800H      cmp      r0,#0
 19562  04C6AH  0DC01H      bgt.n    2 -> 19568
 19564  04C6CH  0E012H      b        36 -> 19604
 19566  04C6EH  046C0H      nop
 19568  04C70H  09804H      ldr      r0,[sp,#16]
 19570  04C72H  06D00H      ldr      r0,[r0,#80]
 19572  04C74H  09902H      ldr      r1,[sp,#8]
 19574  04C76H  03114H      adds     r1,#20
 19576  04C78H  0680AH      ldr      r2,[r1]
 19578  04C7AH  01A12H      subs     r2,r2,r0
 19580  04C7CH  0600AH      str      r2,[r1]
 19582  04C7EH  09802H      ldr      r0,[sp,#8]
 19584  04C80H  06940H      ldr      r0,[r0,#20]
 19586  04C82H  02800H      cmp      r0,#0
 19588  04C84H  0DD01H      ble.n    2 -> 19594
 19590  04C86H  0E005H      b        10 -> 19604
 19592  04C88H  046C0H      nop
 19594  04C8AH  09802H      ldr      r0,[sp,#8]
 19596  04C8CH  09003H      str      r0,[sp,#12]
 19598  04C8EH  02002H      movs     r0,#2
 19600  04C90H  09902H      ldr      r1,[sp,#8]
 19602  04C92H  06288H      str      r0,[r1,#40]
 19604  04C94H  09802H      ldr      r0,[sp,#8]
 19606  04C96H  06980H      ldr      r0,[r0,#24]
 19608  04C98H  02800H      cmp      r0,#0
 19610  04C9AH  0D101H      bne.n    2 -> 19616
 19612  04C9CH  0E01FH      b        62 -> 19678
 19614  04C9EH  046C0H      nop
 19616  04CA0H  09802H      ldr      r0,[sp,#8]
 19618  04CA2H  06980H      ldr      r0,[r0,#24]
 19620  04CA4H  06801H      ldr      r1,[r0]
 19622  04CA6H  09105H      str      r1,[sp,#20]
 19624  04CA8H  09802H      ldr      r0,[sp,#8]
 19626  04CAAH  069C0H      ldr      r0,[r0,#28]
 19628  04CACH  09905H      ldr      r1,[sp,#20]
 19630  04CAEH  04008H      ands     r0,r1
 19632  04CB0H  02100H      movs     r1,#0
 19634  04CB2H  04288H      cmp      r0,r1
 19636  04CB4H  0D001H      beq.n    2 -> 19642
 19638  04CB6H  0E00AH      b        20 -> 19662
 19640  04CB8H  046C0H      nop
 19642  04CBAH  09805H      ldr      r0,[sp,#20]
 19644  04CBCH  09902H      ldr      r1,[sp,#8]
 19646  04CBEH  06A09H      ldr      r1,[r1,#32]
 19648  04CC0H  04008H      ands     r0,r1
 19650  04CC2H  09902H      ldr      r1,[sp,#8]
 19652  04CC4H  06A09H      ldr      r1,[r1,#32]
 19654  04CC6H  04288H      cmp      r0,r1
 19656  04CC8H  0D101H      bne.n    2 -> 19662
 19658  04CCAH  0E008H      b        16 -> 19678
 19660  04CCCH  046C0H      nop
 19662  04CCEH  09802H      ldr      r0,[sp,#8]
 19664  04CD0H  09003H      str      r0,[sp,#12]
 19666  04CD2H  02000H      movs     r0,#0
 19668  04CD4H  09902H      ldr      r1,[sp,#8]
 19670  04CD6H  06188H      str      r0,[r1,#24]
 19672  04CD8H  02003H      movs     r0,#3
 19674  04CDAH  09902H      ldr      r1,[sp,#8]
 19676  04CDCH  06288H      str      r0,[r1,#40]
 19678  04CDEH  09802H      ldr      r0,[sp,#8]
 19680  04CE0H  06A80H      ldr      r0,[r0,#40]
 19682  04CE2H  02801H      cmp      r0,#1
 19684  04CE4H  0D001H      beq.n    2 -> 19690
 19686  04CE6H  0E00EH      b        28 -> 19718
 19688  04CE8H  046C0H      nop
 19690  04CEAH  09802H      ldr      r0,[sp,#8]
 19692  04CECH  06940H      ldr      r0,[r0,#20]
 19694  04CEEH  02800H      cmp      r0,#0
 19696  04CF0H  0DD01H      ble.n    2 -> 19702
 19698  04CF2H  0E008H      b        16 -> 19718
 19700  04CF4H  046C0H      nop
 19702  04CF6H  09802H      ldr      r0,[sp,#8]
 19704  04CF8H  06980H      ldr      r0,[r0,#24]
 19706  04CFAH  02800H      cmp      r0,#0
 19708  04CFCH  0D001H      beq.n    2 -> 19714
 19710  04CFEH  0E002H      b        4 -> 19718
 19712  04D00H  046C0H      nop
 19714  04D02H  09802H      ldr      r0,[sp,#8]
 19716  04D04H  09003H      str      r0,[sp,#12]
 19718  04D06H  09803H      ldr      r0,[sp,#12]
 19720  04D08H  02800H      cmp      r0,#0
 19722  04D0AH  0D101H      bne.n    2 -> 19728
 19724  04D0CH  0E006H      b        12 -> 19740
 19726  04D0EH  046C0H      nop
 19728  04D10H  09802H      ldr      r0,[sp,#8]
 19730  04D12H  09904H      ldr      r1,[sp,#16]
 19732  04D14H  0F7FFFCF2H  bl.w     Kernel.slotIn
 19736  04D18H  0E000H      b        0 -> 19740
 19738  04D1AH  0014FH      <LineNo: 335>
 19740  04D1CH  09800H      ldr      r0,[sp]
 19742  04D1EH  03001H      adds     r0,#1
 19744  04D20H  09000H      str      r0,[sp]
 19746  04D22H  0E750H      b        -352 -> 19398
 19748  04D24H  09804H      ldr      r0,[sp,#16]
 19750  04D26H  06C40H      ldr      r0,[r0,#68]
 19752  04D28H  02800H      cmp      r0,#0
 19754  04D2AH  0D101H      bne.n    2 -> 19760
 19756  04D2CH  0E026H      b        76 -> 19836
 19758  04D2EH  046C0H      nop
 19760  04D30H  09804H      ldr      r0,[sp,#16]
 19762  04D32H  06C40H      ldr      r0,[r0,#68]
 19764  04D34H  09002H      str      r0,[sp,#8]
 19766  04D36H  09804H      ldr      r0,[sp,#16]
 19768  04D38H  06C40H      ldr      r0,[r0,#68]
 19770  04D3AH  06AC0H      ldr      r0,[r0,#44]
 19772  04D3CH  09904H      ldr      r1,[sp,#16]
 19774  04D3EH  06448H      str      r0,[r1,#68]
 19776  04D40H  0F000F804H  bl.w     Kernel.loopc + 460
 19780  04D44H  0D0000000H
 19784  04D48H  02002FC94H
 19788  04D4CH  09802H      ldr      r0,[sp,#8]
 19790  04D4EH  06840H      ldr      r0,[r0,#4]
 19792  04D50H  02101H      movs     r1,#1
 19794  04D52H  04081H      lsls     r1,r0
 19796  04D54H  09A04H      ldr      r2,[sp,#16]
 19798  04D56H  03248H      adds     r2,#72
 19800  04D58H  06813H      ldr      r3,[r2]
 19802  04D5AH  0438BH      bics     r3,r1
 19804  04D5CH  06013H      str      r3,[r2]
 19806  04D5EH  09802H      ldr      r0,[sp,#8]
 19808  04D60H  09904H      ldr      r1,[sp,#16]
 19810  04D62H  06408H      str      r0,[r1,#64]
 19812  04D64H  09804H      ldr      r0,[sp,#16]
 19814  04D66H  06D40H      ldr      r0,[r0,#84]
 19816  04D68H  09902H      ldr      r1,[sp,#8]
 19818  04D6AH  06A49H      ldr      r1,[r1,#36]
 19820  04D6CH  0F7FFFC78H  bl.w     Coroutines.Transfer
 19824  04D70H  0E000H      b        0 -> 19828
 19826  04D72H  00164H      <LineNo: 356>
 19828  04D74H  02000H      movs     r0,#0
 19830  04D76H  09904H      ldr      r1,[sp,#16]
 19832  04D78H  06408H      str      r0,[r1,#64]
 19834  04D7AH  0E7D3H      b        -90 -> 19748
 19836  04D7CH  04280H      cmp      r0,r0
 19838  04D7EH  0D100H      bne.n    0 -> 19842
 19840  04D80H  0E716H      b        -468 -> 19376
 19842  04D82H  0B006H      add      sp,#24
 19844  04D84H  0BD00H      pop      { pc }
 19846  04D86H  046C0H      nop

PROCEDURE Kernel.Run:
 19848  04D88H  0B500H      push     { lr }
 19850  04D8AH  0B081H      sub      sp,#4
 19852  04D8CH  04815H      ldr      r0,[pc,#84] -> 19940
 19854  04D8EH  06801H      ldr      r1,[r0]
 19856  04D90H  09100H      str      r1,[sp]
 19858  04D92H  04668H      mov      r0,sp
 19860  04D94H  04683H      mov      r11,r0
 19862  04D96H  0F38B8809H  .word 0x8809F38B /* EMIT */
 19866  04D9AH  02002H      movs     r0,#2
 19868  04D9CH  04683H      mov      r11,r0
 19870  04D9EH  0F38B8814H  .word 0x8814F38B /* EMIT */
 19874  04DA2H  0F3BF8F6FH  isb
 19878  04DA6H  0F7FFFC75H  bl.w     SysTick.Enable
 19882  04DAAH  0E000H      b        0 -> 19886
 19884  04DACH  0017CH      <LineNo: 380>
 19886  04DAEH  09800H      ldr      r0,[sp]
 19888  04DB0H  02802H      cmp      r0,#2
 19890  04DB2H  0D301H      bcc.n    2 -> 19896
 19892  04DB4H  0DF01H      svc      1
 19894  04DB6H  0017DH      <LineNo: 381>
 19896  04DB8H  0490BH      ldr      r1,[pc,#44] -> 19944
 19898  04DBAH  00080H      lsls     r0,r0,#2
 19900  04DBCH  01808H      adds     r0,r1,r0
 19902  04DBEH  06800H      ldr      r0,[r0]
 19904  04DC0H  06D80H      ldr      r0,[r0,#88]
 19906  04DC2H  09900H      ldr      r1,[sp]
 19908  04DC4H  02902H      cmp      r1,#2
 19910  04DC6H  0D301H      bcc.n    2 -> 19916
 19912  04DC8H  0DF01H      svc      1
 19914  04DCAH  0017DH      <LineNo: 381>
 19916  04DCCH  04A06H      ldr      r2,[pc,#24] -> 19944
 19918  04DCEH  00089H      lsls     r1,r1,#2
 19920  04DD0H  01851H      adds     r1,r2,r1
 19922  04DD2H  06809H      ldr      r1,[r1]
 19924  04DD4H  06D49H      ldr      r1,[r1,#84]
 19926  04DD6H  0F7FFFC43H  bl.w     Coroutines.Transfer
 19930  04DDAH  0E000H      b        0 -> 19934
 19932  04DDCH  0017DH      <LineNo: 381>
 19934  04DDEH  0B001H      add      sp,#4
 19936  04DE0H  0BD00H      pop      { pc }
 19938  04DE2H  046C0H      nop
 19940  04DE4H  0D0000000H
 19944  04DE8H  02002FC94H

PROCEDURE Kernel.Install:
 19948  04DECH  0B501H      push     { r0, lr }
 19950  04DEEH  0B084H      sub      sp,#16
 19952  04DF0H  04869H      ldr      r0,[pc,#420] -> 20376
 19954  04DF2H  06801H      ldr      r1,[r0]
 19956  04DF4H  09102H      str      r1,[sp,#8]
 19958  04DF6H  09802H      ldr      r0,[sp,#8]
 19960  04DF8H  02802H      cmp      r0,#2
 19962  04DFAH  0D301H      bcc.n    2 -> 19968
 19964  04DFCH  0DF01H      svc      1
 19966  04DFEH  00189H      <LineNo: 393>
 19968  04E00H  0496BH      ldr      r1,[pc,#428] -> 20400
 19970  04E02H  00080H      lsls     r0,r0,#2
 19972  04E04H  01808H      adds     r0,r1,r0
 19974  04E06H  04965H      ldr      r1,[pc,#404] -> 20380
 19976  04E08H  0467AH      mov      r2,pc
 19978  04E0AH  01889H      adds     r1,r1,r2
 19980  04E0CH  0F7FCFAECH  bl.w     MAU.New
 19984  04E10H  0E000H      b        0 -> 19988
 19986  04E12H  00189H      <LineNo: 393>
 19988  04E14H  09802H      ldr      r0,[sp,#8]
 19990  04E16H  02802H      cmp      r0,#2
 19992  04E18H  0D301H      bcc.n    2 -> 19998
 19994  04E1AH  0DF01H      svc      1
 19996  04E1CH  00189H      <LineNo: 393>
 19998  04E1EH  04964H      ldr      r1,[pc,#400] -> 20400
 20000  04E20H  00080H      lsls     r0,r0,#2
 20002  04E22H  01808H      adds     r0,r1,r0
 20004  04E24H  06800H      ldr      r0,[r0]
 20006  04E26H  02800H      cmp      r0,#0
 20008  04E28H  0D101H      bne.n    2 -> 20014
 20010  04E2AH  0DF6CH      svc      108
 20012  04E2CH  00189H      <LineNo: 393>
 20014  04E2EH  09802H      ldr      r0,[sp,#8]
 20016  04E30H  02802H      cmp      r0,#2
 20018  04E32H  0D301H      bcc.n    2 -> 20024
 20020  04E34H  0DF01H      svc      1
 20022  04E36H  0018AH      <LineNo: 394>
 20024  04E38H  0495DH      ldr      r1,[pc,#372] -> 20400
 20026  04E3AH  00080H      lsls     r0,r0,#2
 20028  04E3CH  01808H      adds     r0,r1,r0
 20030  04E3EH  06800H      ldr      r0,[r0]
 20032  04E40H  09003H      str      r0,[sp,#12]
 20034  04E42H  02000H      movs     r0,#0
 20036  04E44H  09903H      ldr      r1,[sp,#12]
 20038  04E46H  06408H      str      r0,[r1,#64]
 20040  04E48H  02000H      movs     r0,#0
 20042  04E4AH  09903H      ldr      r1,[sp,#12]
 20044  04E4CH  06448H      str      r0,[r1,#68]
 20046  04E4EH  02000H      movs     r0,#0
 20048  04E50H  09903H      ldr      r1,[sp,#12]
 20050  04E52H  06488H      str      r0,[r1,#72]
 20052  04E54H  02000H      movs     r0,#0
 20054  04E56H  09903H      ldr      r1,[sp,#12]
 20056  04E58H  064C8H      str      r0,[r1,#76]
 20058  04E5AH  09804H      ldr      r0,[sp,#16]
 20060  04E5CH  09903H      ldr      r1,[sp,#12]
 20062  04E5EH  06508H      str      r0,[r1,#80]
 20064  04E60H  09803H      ldr      r0,[sp,#12]
 20066  04E62H  03058H      adds     r0,#88
 20068  04E64H  04951H      ldr      r1,[pc,#324] -> 20396
 20070  04E66H  0F7FCFABFH  bl.w     MAU.New
 20074  04E6AH  0E000H      b        0 -> 20078
 20076  04E6CH  0018FH      <LineNo: 399>
 20078  04E6EH  09803H      ldr      r0,[sp,#12]
 20080  04E70H  06D80H      ldr      r0,[r0,#88]
 20082  04E72H  02800H      cmp      r0,#0
 20084  04E74H  0D101H      bne.n    2 -> 20090
 20086  04E76H  0DF6CH      svc      108
 20088  04E78H  0018FH      <LineNo: 399>
 20090  04E7AH  09803H      ldr      r0,[sp,#12]
 20092  04E7CH  03054H      adds     r0,#84
 20094  04E7EH  0494BH      ldr      r1,[pc,#300] -> 20396
 20096  04E80H  0F7FCFAB2H  bl.w     MAU.New
 20100  04E84H  0E000H      b        0 -> 20104
 20102  04E86H  00190H      <LineNo: 400>
 20104  04E88H  09803H      ldr      r0,[sp,#12]
 20106  04E8AH  06D40H      ldr      r0,[r0,#84]
 20108  04E8CH  02800H      cmp      r0,#0
 20110  04E8EH  0D101H      bne.n    2 -> 20116
 20112  04E90H  0DF6CH      svc      108
 20114  04E92H  00190H      <LineNo: 400>
 20116  04E94H  0A801H      add      r0,sp,#4
 20118  04E96H  02101H      movs     r1,#1
 20120  04E98H  00209H      lsls     r1,r1,#8
 20122  04E9AH  0F7FCFD65H  bl.w     Memory.AllocLoopStack
 20126  04E9EH  0E000H      b        0 -> 20130
 20128  04EA0H  00191H      <LineNo: 401>
 20130  04EA2H  09801H      ldr      r0,[sp,#4]
 20132  04EA4H  02800H      cmp      r0,#0
 20134  04EA6H  0D101H      bne.n    2 -> 20140
 20136  04EA8H  0DF6EH      svc      110
 20138  04EAAH  00191H      <LineNo: 401>
 20140  04EACH  09803H      ldr      r0,[sp,#12]
 20142  04EAEH  06D40H      ldr      r0,[r0,#84]
 20144  04EB0H  09901H      ldr      r1,[sp,#4]
 20146  04EB2H  02201H      movs     r2,#1
 20148  04EB4H  00212H      lsls     r2,r2,#8
 20150  04EB6H  04B3AH      ldr      r3,[pc,#232] -> 20384
 20152  04EB8H  0F7FFFBC0H  bl.w     Coroutines.Init
 20156  04EBCH  0E000H      b        0 -> 20160
 20158  04EBEH  00192H      <LineNo: 402>
 20160  04EC0H  09803H      ldr      r0,[sp,#12]
 20162  04EC2H  06D40H      ldr      r0,[r0,#84]
 20164  04EC4H  04937H      ldr      r1,[pc,#220] -> 20388
 20166  04EC6H  04479H      add      r1,pc
 20168  04EC8H  0F7FFFBA8H  bl.w     Coroutines.Allocate
 20172  04ECCH  0E000H      b        0 -> 20176
 20174  04ECEH  00193H      <LineNo: 403>
 20176  04ED0H  02000H      movs     r0,#0
 20178  04ED2H  09000H      str      r0,[sp]
 20180  04ED4H  09800H      ldr      r0,[sp]
 20182  04ED6H  02810H      cmp      r0,#16
 20184  04ED8H  0DB01H      blt.n    2 -> 20190
 20186  04EDAH  0E053H      b        166 -> 20356
 20188  04EDCH  046C0H      nop
 20190  04EDEH  09800H      ldr      r0,[sp]
 20192  04EE0H  02810H      cmp      r0,#16
 20194  04EE2H  0D301H      bcc.n    2 -> 20200
 20196  04EE4H  0DF01H      svc      1
 20198  04EE6H  00199H      <LineNo: 409>
 20200  04EE8H  09903H      ldr      r1,[sp,#12]
 20202  04EEAH  00080H      lsls     r0,r0,#2
 20204  04EECH  01808H      adds     r0,r1,r0
 20206  04EEEH  0492EH      ldr      r1,[pc,#184] -> 20392
 20208  04EF0H  0467AH      mov      r2,pc
 20210  04EF2H  01889H      adds     r1,r1,r2
 20212  04EF4H  0F7FCFA78H  bl.w     MAU.New
 20216  04EF8H  0E000H      b        0 -> 20220
 20218  04EFAH  00199H      <LineNo: 409>
 20220  04EFCH  09800H      ldr      r0,[sp]
 20222  04EFEH  02810H      cmp      r0,#16
 20224  04F00H  0D301H      bcc.n    2 -> 20230
 20226  04F02H  0DF01H      svc      1
 20228  04F04H  00199H      <LineNo: 409>
 20230  04F06H  09903H      ldr      r1,[sp,#12]
 20232  04F08H  00080H      lsls     r0,r0,#2
 20234  04F0AH  01808H      adds     r0,r1,r0
 20236  04F0CH  06800H      ldr      r0,[r0]
 20238  04F0EH  02800H      cmp      r0,#0
 20240  04F10H  0D101H      bne.n    2 -> 20246
 20242  04F12H  0DF6CH      svc      108
 20244  04F14H  00199H      <LineNo: 409>
 20246  04F16H  09800H      ldr      r0,[sp]
 20248  04F18H  02810H      cmp      r0,#16
 20250  04F1AH  0D301H      bcc.n    2 -> 20256
 20252  04F1CH  0DF01H      svc      1
 20254  04F1EH  0019AH      <LineNo: 410>
 20256  04F20H  09903H      ldr      r1,[sp,#12]
 20258  04F22H  00080H      lsls     r0,r0,#2
 20260  04F24H  01808H      adds     r0,r1,r0
 20262  04F26H  06800H      ldr      r0,[r0]
 20264  04F28H  02101H      movs     r1,#1
 20266  04F2AH  06081H      str      r1,[r0,#8]
 20268  04F2CH  09800H      ldr      r0,[sp]
 20270  04F2EH  02810H      cmp      r0,#16
 20272  04F30H  0D301H      bcc.n    2 -> 20278
 20274  04F32H  0DF01H      svc      1
 20276  04F34H  0019BH      <LineNo: 411>
 20278  04F36H  09903H      ldr      r1,[sp,#12]
 20280  04F38H  00080H      lsls     r0,r0,#2
 20282  04F3AH  01808H      adds     r0,r1,r0
 20284  04F3CH  06800H      ldr      r0,[r0]
 20286  04F3EH  09900H      ldr      r1,[sp]
 20288  04F40H  06041H      str      r1,[r0,#4]
 20290  04F42H  09800H      ldr      r0,[sp]
 20292  04F44H  02810H      cmp      r0,#16
 20294  04F46H  0D301H      bcc.n    2 -> 20300
 20296  04F48H  0DF01H      svc      1
 20298  04F4AH  0019CH      <LineNo: 412>
 20300  04F4CH  09903H      ldr      r1,[sp,#12]
 20302  04F4EH  00080H      lsls     r0,r0,#2
 20304  04F50H  01808H      adds     r0,r1,r0
 20306  04F52H  06800H      ldr      r0,[r0]
 20308  04F54H  03024H      adds     r0,#36
 20310  04F56H  04915H      ldr      r1,[pc,#84] -> 20396
 20312  04F58H  0F7FCFA46H  bl.w     MAU.New
 20316  04F5CH  0E000H      b        0 -> 20320
 20318  04F5EH  0019CH      <LineNo: 412>
 20320  04F60H  09800H      ldr      r0,[sp]
 20322  04F62H  02810H      cmp      r0,#16
 20324  04F64H  0D301H      bcc.n    2 -> 20330
 20326  04F66H  0DF01H      svc      1
 20328  04F68H  0019CH      <LineNo: 412>
 20330  04F6AH  09903H      ldr      r1,[sp,#12]
 20332  04F6CH  00080H      lsls     r0,r0,#2
 20334  04F6EH  01808H      adds     r0,r1,r0
 20336  04F70H  06800H      ldr      r0,[r0]
 20338  04F72H  06A40H      ldr      r0,[r0,#36]
 20340  04F74H  02800H      cmp      r0,#0
 20342  04F76H  0D101H      bne.n    2 -> 20348
 20344  04F78H  0DF6CH      svc      108
 20346  04F7AH  0019CH      <LineNo: 412>
 20348  04F7CH  09800H      ldr      r0,[sp]
 20350  04F7EH  03001H      adds     r0,#1
 20352  04F80H  09000H      str      r0,[sp]
 20354  04F82H  0E7A7H      b        -178 -> 20180
 20356  04F84H  09804H      ldr      r0,[sp,#16]
 20358  04F86H  02101H      movs     r1,#1
 20360  04F88H  04348H      muls     r0,r1
 20362  04F8AH  0F7FFFB8BH  bl.w     SysTick.Init
 20366  04F8EH  0E000H      b        0 -> 20370
 20368  04F90H  001A0H      <LineNo: 416>
 20370  04F92H  0B005H      add      sp,#20
 20372  04F94H  0BD00H      pop      { pc }
 20374  04F96H  046C0H      nop
 20376  04F98H  0D0000000H
 20380  04F9CH  -1828
 20384  04FA0H  -1
 20388  04FA4H  -842
 20392  04FA8H  -2080
 20396  04FACH  01000459CH
 20400  04FB0H  02002FC94H

PROCEDURE Kernel..init:
 20404  04FB4H  0B500H      push     { lr }
 20406  04FB6H  02010H      movs     r0,#16
 20408  04FB8H  02820H      cmp      r0,#32
 20410  04FBAH  0DD01H      ble.n    2 -> 20416
 20412  04FBCH  0DF68H      svc      104
 20414  04FBEH  001A4H      <LineNo: 420>
 20416  04FC0H  04804H      ldr      r0,[pc,#16] -> 20436
 20418  04FC2H  04478H      add      r0,pc
 20420  04FC4H  04905H      ldr      r1,[pc,#20] -> 20444
 20422  04FC6H  06008H      str      r0,[r1]
 20424  04FC8H  04803H      ldr      r0,[pc,#12] -> 20440
 20426  04FCAH  04478H      add      r0,pc
 20428  04FCCH  04904H      ldr      r1,[pc,#16] -> 20448
 20430  04FCEH  06008H      str      r0,[r1]
 20432  04FD0H  0BD00H      pop      { pc }
 20434  04FD2H  046C0H      nop
 20436  04FD4H  -1682
 20440  04FD8H  -1794
 20444  04FDCH  02002FC90H
 20448  04FE0H  02002FC8CH

MODULE LEDext:
 20452  04FE4H  0

PROCEDURE LEDext.SetLedBits:
 20456  04FE8H  0B507H      push     { r0, r1, r2, lr }
 20458  04FEAH  0B084H      sub      sp,#16
 20460  04FECH  02000H      movs     r0,#0
 20462  04FEEH  09002H      str      r0,[sp,#8]
 20464  04FF0H  02000H      movs     r0,#0
 20466  04FF2H  09003H      str      r0,[sp,#12]
 20468  04FF4H  02000H      movs     r0,#0
 20470  04FF6H  09000H      str      r0,[sp]
 20472  04FF8H  09805H      ldr      r0,[sp,#20]
 20474  04FFAH  09906H      ldr      r1,[sp,#24]
 20476  04FFCH  01A40H      subs     r0,r0,r1
 20478  04FFEH  09001H      str      r0,[sp,#4]
 20480  05000H  09800H      ldr      r0,[sp]
 20482  05002H  09901H      ldr      r1,[sp,#4]
 20484  05004H  04288H      cmp      r0,r1
 20486  05006H  0DD01H      ble.n    2 -> 20492
 20488  05008H  0E030H      b        96 -> 20588
 20490  0500AH  046C0H      nop
 20492  0500CH  09804H      ldr      r0,[sp,#16]
 20494  0500EH  09900H      ldr      r1,[sp]
 20496  05010H  02201H      movs     r2,#1
 20498  05012H  0408AH      lsls     r2,r1
 20500  05014H  04210H      tst      r0,r2
 20502  05016H  0D101H      bne.n    2 -> 20508
 20504  05018H  0E013H      b        38 -> 20546
 20506  0501AH  046C0H      nop
 20508  0501CH  09800H      ldr      r0,[sp]
 20510  0501EH  09906H      ldr      r1,[sp,#24]
 20512  05020H  01840H      adds     r0,r0,r1
 20514  05022H  02808H      cmp      r0,#8
 20516  05024H  0D301H      bcc.n    2 -> 20522
 20518  05026H  0DF01H      svc      1
 20520  05028H  00040H      <LineNo: 64>
 20522  0502AH  04916H      ldr      r1,[pc,#88] -> 20612
 20524  0502CH  00080H      lsls     r0,r0,#2
 20526  0502EH  01808H      adds     r0,r1,r0
 20528  05030H  06800H      ldr      r0,[r0]
 20530  05032H  02101H      movs     r1,#1
 20532  05034H  04081H      lsls     r1,r0
 20534  05036H  0AA02H      add      r2,sp,#8
 20536  05038H  06813H      ldr      r3,[r2]
 20538  0503AH  0430BH      orrs     r3,r1
 20540  0503CH  06013H      str      r3,[r2]
 20542  0503EH  0E011H      b        34 -> 20580
 20544  05040H  046C0H      nop
 20546  05042H  09800H      ldr      r0,[sp]
 20548  05044H  09906H      ldr      r1,[sp,#24]
 20550  05046H  01840H      adds     r0,r0,r1
 20552  05048H  02808H      cmp      r0,#8
 20554  0504AH  0D301H      bcc.n    2 -> 20560
 20556  0504CH  0DF01H      svc      1
 20558  0504EH  00042H      <LineNo: 66>
 20560  05050H  0490CH      ldr      r1,[pc,#48] -> 20612
 20562  05052H  00080H      lsls     r0,r0,#2
 20564  05054H  01808H      adds     r0,r1,r0
 20566  05056H  06800H      ldr      r0,[r0]
 20568  05058H  02101H      movs     r1,#1
 20570  0505AH  04081H      lsls     r1,r0
 20572  0505CH  0AA03H      add      r2,sp,#12
 20574  0505EH  06813H      ldr      r3,[r2]
 20576  05060H  0430BH      orrs     r3,r1
 20578  05062H  06013H      str      r3,[r2]
 20580  05064H  09800H      ldr      r0,[sp]
 20582  05066H  03001H      adds     r0,#1
 20584  05068H  09000H      str      r0,[sp]
 20586  0506AH  0E7C9H      b        -110 -> 20480
 20588  0506CH  09803H      ldr      r0,[sp,#12]
 20590  0506EH  0F7FBFFD5H  bl.w     GPIO.Clear
 20594  05072H  0E000H      b        0 -> 20598
 20596  05074H  00046H      <LineNo: 70>
 20598  05076H  09802H      ldr      r0,[sp,#8]
 20600  05078H  0F7FBFFC8H  bl.w     GPIO.Set
 20604  0507CH  0E000H      b        0 -> 20608
 20606  0507EH  00047H      <LineNo: 71>
 20608  05080H  0B007H      add      sp,#28
 20610  05082H  0BD00H      pop      { pc }
 20612  05084H  02002FC6CH

PROCEDURE LEDext.SetValue:
 20616  05088H  0B501H      push     { r0, lr }
 20618  0508AH  09800H      ldr      r0,[sp]
 20620  0508CH  02107H      movs     r1,#7
 20622  0508EH  02200H      movs     r2,#0
 20624  05090H  0F7FFFFAAH  bl.w     LEDext.SetLedBits
 20628  05094H  0E000H      b        0 -> 20632
 20630  05096H  0004DH      <LineNo: 77>
 20632  05098H  0B001H      add      sp,#4
 20634  0509AH  0BD00H      pop      { pc }

PROCEDURE LEDext.init:
 20636  0509CH  0B500H      push     { lr }
 20638  0509EH  0B082H      sub      sp,#8
 20640  050A0H  04827H      ldr      r0,[pc,#156] -> 20800
 20642  050A2H  02102H      movs     r1,#2
 20644  050A4H  06001H      str      r1,[r0]
 20646  050A6H  04826H      ldr      r0,[pc,#152] -> 20800
 20648  050A8H  02103H      movs     r1,#3
 20650  050AAH  06041H      str      r1,[r0,#4]
 20652  050ACH  04824H      ldr      r0,[pc,#144] -> 20800
 20654  050AEH  02106H      movs     r1,#6
 20656  050B0H  06081H      str      r1,[r0,#8]
 20658  050B2H  04823H      ldr      r0,[pc,#140] -> 20800
 20660  050B4H  02107H      movs     r1,#7
 20662  050B6H  060C1H      str      r1,[r0,#12]
 20664  050B8H  04821H      ldr      r0,[pc,#132] -> 20800
 20666  050BAH  02108H      movs     r1,#8
 20668  050BCH  06101H      str      r1,[r0,#16]
 20670  050BEH  04820H      ldr      r0,[pc,#128] -> 20800
 20672  050C0H  02109H      movs     r1,#9
 20674  050C2H  06141H      str      r1,[r0,#20]
 20676  050C4H  0481EH      ldr      r0,[pc,#120] -> 20800
 20678  050C6H  0210EH      movs     r1,#14
 20680  050C8H  06181H      str      r1,[r0,#24]
 20682  050CAH  0481DH      ldr      r0,[pc,#116] -> 20800
 20684  050CCH  0210FH      movs     r1,#15
 20686  050CEH  061C1H      str      r1,[r0,#28]
 20688  050D0H  02019H      movs     r0,#25
 20690  050D2H  02105H      movs     r1,#5
 20692  050D4H  0F7FBFEB6H  bl.w     GPIO.SetFunction
 20696  050D8H  0E000H      b        0 -> 20700
 20698  050DAH  0005CH      <LineNo: 92>
 20700  050DCH  02001H      movs     r0,#1
 20702  050DEH  00640H      lsls     r0,r0,#25
 20704  050E0H  0F7FBFFDAH  bl.w     GPIO.OutputEnable
 20708  050E4H  0E000H      b        0 -> 20712
 20710  050E6H  0005DH      <LineNo: 93>
 20712  050E8H  02000H      movs     r0,#0
 20714  050EAH  09000H      str      r0,[sp]
 20716  050ECH  09800H      ldr      r0,[sp]
 20718  050EEH  02808H      cmp      r0,#8
 20720  050F0H  0DB01H      blt.n    2 -> 20726
 20722  050F2H  0E022H      b        68 -> 20794
 20724  050F4H  046C0H      nop
 20726  050F6H  09800H      ldr      r0,[sp]
 20728  050F8H  02808H      cmp      r0,#8
 20730  050FAH  0D301H      bcc.n    2 -> 20736
 20732  050FCH  0DF01H      svc      1
 20734  050FEH  00060H      <LineNo: 96>
 20736  05100H  0490FH      ldr      r1,[pc,#60] -> 20800
 20738  05102H  00080H      lsls     r0,r0,#2
 20740  05104H  01808H      adds     r0,r1,r0
 20742  05106H  06800H      ldr      r0,[r0]
 20744  05108H  02105H      movs     r1,#5
 20746  0510AH  0F7FBFE9BH  bl.w     GPIO.SetFunction
 20750  0510EH  0E000H      b        0 -> 20754
 20752  05110H  00060H      <LineNo: 96>
 20754  05112H  09800H      ldr      r0,[sp]
 20756  05114H  02808H      cmp      r0,#8
 20758  05116H  0D301H      bcc.n    2 -> 20764
 20760  05118H  0DF01H      svc      1
 20762  0511AH  00061H      <LineNo: 97>
 20764  0511CH  04908H      ldr      r1,[pc,#32] -> 20800
 20766  0511EH  00080H      lsls     r0,r0,#2
 20768  05120H  01808H      adds     r0,r1,r0
 20770  05122H  06800H      ldr      r0,[r0]
 20772  05124H  02101H      movs     r1,#1
 20774  05126H  04081H      lsls     r1,r0
 20776  05128H  04608H      mov      r0,r1
 20778  0512AH  0F7FBFFB5H  bl.w     GPIO.OutputEnable
 20782  0512EH  0E000H      b        0 -> 20786
 20784  05130H  00061H      <LineNo: 97>
 20786  05132H  09800H      ldr      r0,[sp]
 20788  05134H  03001H      adds     r0,#1
 20790  05136H  09000H      str      r0,[sp]
 20792  05138H  0E7D8H      b        -80 -> 20716
 20794  0513AH  0B002H      add      sp,#8
 20796  0513CH  0BD00H      pop      { pc }
 20798  0513EH  046C0H      nop
 20800  05140H  02002FC6CH

PROCEDURE LEDext..init:
 20804  05144H  0B500H      push     { lr }
 20806  05146H  0F7FFFFA9H  bl.w     LEDext.init
 20810  0514AH  0E000H      b        0 -> 20814
 20812  0514CH  00067H      <LineNo: 103>
 20814  0514EH  0BD00H      pop      { pc }

MODULE Exceptions:
 20816  05150H  0

PROCEDURE Exceptions.EnableInt:
 20820  05154H  0B501H      push     { r0, lr }
 20822  05156H  04802H      ldr      r0,[pc,#8] -> 20832
 20824  05158H  09900H      ldr      r1,[sp]
 20826  0515AH  06001H      str      r1,[r0]
 20828  0515CH  0B001H      add      sp,#4
 20830  0515EH  0BD00H      pop      { pc }
 20832  05160H  0E000E100H

PROCEDURE Exceptions.GetEnabledInt:
 20836  05164H  0B501H      push     { r0, lr }
 20838  05166H  04803H      ldr      r0,[pc,#12] -> 20852
 20840  05168H  06801H      ldr      r1,[r0]
 20842  0516AH  09A00H      ldr      r2,[sp]
 20844  0516CH  06011H      str      r1,[r2]
 20846  0516EH  0B001H      add      sp,#4
 20848  05170H  0BD00H      pop      { pc }
 20850  05172H  046C0H      nop
 20852  05174H  0E000E100H

PROCEDURE Exceptions.DisableInt:
 20856  05178H  0B501H      push     { r0, lr }
 20858  0517AH  04802H      ldr      r0,[pc,#8] -> 20868
 20860  0517CH  09900H      ldr      r1,[sp]
 20862  0517EH  06001H      str      r1,[r0]
 20864  05180H  0B001H      add      sp,#4
 20866  05182H  0BD00H      pop      { pc }
 20868  05184H  0E000E180H

PROCEDURE Exceptions.SetPendingInt:
 20872  05188H  0B501H      push     { r0, lr }
 20874  0518AH  04802H      ldr      r0,[pc,#8] -> 20884
 20876  0518CH  09900H      ldr      r1,[sp]
 20878  0518EH  06001H      str      r1,[r0]
 20880  05190H  0B001H      add      sp,#4
 20882  05192H  0BD00H      pop      { pc }
 20884  05194H  0E000E200H

PROCEDURE Exceptions.GetPendingInt:
 20888  05198H  0B501H      push     { r0, lr }
 20890  0519AH  04803H      ldr      r0,[pc,#12] -> 20904
 20892  0519CH  06801H      ldr      r1,[r0]
 20894  0519EH  09A00H      ldr      r2,[sp]
 20896  051A0H  06011H      str      r1,[r2]
 20898  051A2H  0B001H      add      sp,#4
 20900  051A4H  0BD00H      pop      { pc }
 20902  051A6H  046C0H      nop
 20904  051A8H  0E000E200H

PROCEDURE Exceptions.ClearPendingInt:
 20908  051ACH  0B501H      push     { r0, lr }
 20910  051AEH  04802H      ldr      r0,[pc,#8] -> 20920
 20912  051B0H  09900H      ldr      r1,[sp]
 20914  051B2H  06001H      str      r1,[r0]
 20916  051B4H  0B001H      add      sp,#4
 20918  051B6H  0BD00H      pop      { pc }
 20920  051B8H  0E000E280H

PROCEDURE Exceptions.SetIntPrio:
 20924  051BCH  0B503H      push     { r0, r1, lr }
 20926  051BEH  0B082H      sub      sp,#8
 20928  051C0H  09802H      ldr      r0,[sp,#8]
 20930  051C2H  01080H      asrs     r0,r0,#2
 20932  051C4H  00080H      lsls     r0,r0,#2
 20934  051C6H  0490AH      ldr      r1,[pc,#40] -> 20976
 20936  051C8H  01840H      adds     r0,r0,r1
 20938  051CAH  09000H      str      r0,[sp]
 20940  051CCH  09800H      ldr      r0,[sp]
 20942  051CEH  06801H      ldr      r1,[r0]
 20944  051D0H  09101H      str      r1,[sp,#4]
 20946  051D2H  09803H      ldr      r0,[sp,#12]
 20948  051D4H  00180H      lsls     r0,r0,#6
 20950  051D6H  09902H      ldr      r1,[sp,#8]
 20952  051D8H  00789H      lsls     r1,r1,#30
 20954  051DAH  00F89H      lsrs     r1,r1,#30
 20956  051DCH  000C9H      lsls     r1,r1,#3
 20958  051DEH  04088H      lsls     r0,r1
 20960  051E0H  09901H      ldr      r1,[sp,#4]
 20962  051E2H  01808H      adds     r0,r1,r0
 20964  051E4H  09001H      str      r0,[sp,#4]
 20966  051E6H  09800H      ldr      r0,[sp]
 20968  051E8H  09901H      ldr      r1,[sp,#4]
 20970  051EAH  06001H      str      r1,[r0]
 20972  051ECH  0B004H      add      sp,#16
 20974  051EEH  0BD00H      pop      { pc }
 20976  051F0H  0E000E400H

PROCEDURE Exceptions.GetIntPrio:
 20980  051F4H  0B503H      push     { r0, r1, lr }
 20982  051F6H  0B081H      sub      sp,#4
 20984  051F8H  09801H      ldr      r0,[sp,#4]
 20986  051FAH  01080H      asrs     r0,r0,#2
 20988  051FCH  00080H      lsls     r0,r0,#2
 20990  051FEH  04904H      ldr      r1,[pc,#16] -> 21008
 20992  05200H  01840H      adds     r0,r0,r1
 20994  05202H  09000H      str      r0,[sp]
 20996  05204H  09800H      ldr      r0,[sp]
 20998  05206H  06801H      ldr      r1,[r0]
 21000  05208H  09A02H      ldr      r2,[sp,#8]
 21002  0520AH  06011H      str      r1,[r2]
 21004  0520CH  0B003H      add      sp,#12
 21006  0520EH  0BD00H      pop      { pc }
 21008  05210H  0E000E400H

PROCEDURE Exceptions.InstallIntHandler:
 21012  05214H  0B503H      push     { r0, r1, lr }
 21014  05216H  0B082H      sub      sp,#8
 21016  05218H  04808H      ldr      r0,[pc,#32] -> 21052
 21018  0521AH  06801H      ldr      r1,[r0]
 21020  0521CH  09101H      str      r1,[sp,#4]
 21022  0521EH  09801H      ldr      r0,[sp,#4]
 21024  05220H  03040H      adds     r0,#64
 21026  05222H  09902H      ldr      r1,[sp,#8]
 21028  05224H  00089H      lsls     r1,r1,#2
 21030  05226H  01840H      adds     r0,r0,r1
 21032  05228H  09000H      str      r0,[sp]
 21034  0522AH  09803H      ldr      r0,[sp,#12]
 21036  0522CH  02101H      movs     r1,#1
 21038  0522EH  04308H      orrs     r0,r1
 21040  05230H  09003H      str      r0,[sp,#12]
 21042  05232H  09800H      ldr      r0,[sp]
 21044  05234H  09903H      ldr      r1,[sp,#12]
 21046  05236H  06001H      str      r1,[r0]
 21048  05238H  0B004H      add      sp,#16
 21050  0523AH  0BD00H      pop      { pc }
 21052  0523CH  0E000ED08H

PROCEDURE Exceptions.SetSysExcPrio:
 21056  05240H  0B503H      push     { r0, r1, lr }
 21058  05242H  0B082H      sub      sp,#8
 21060  05244H  02019H      movs     r0,#25
 21062  05246H  002C0H      lsls     r0,r0,#11
 21064  05248H  09902H      ldr      r1,[sp,#8]
 21066  0524AH  02201H      movs     r2,#1
 21068  0524CH  0408AH      lsls     r2,r1
 21070  0524EH  04210H      tst      r0,r2
 21072  05250H  0D101H      bne.n    2 -> 21078
 21074  05252H  0DF65H      svc      101
 21076  05254H  00086H      <LineNo: 134>
 21078  05256H  09802H      ldr      r0,[sp,#8]
 21080  05258H  01080H      asrs     r0,r0,#2
 21082  0525AH  00080H      lsls     r0,r0,#2
 21084  0525CH  0490AH      ldr      r1,[pc,#40] -> 21128
 21086  0525EH  01840H      adds     r0,r0,r1
 21088  05260H  09000H      str      r0,[sp]
 21090  05262H  09800H      ldr      r0,[sp]
 21092  05264H  06801H      ldr      r1,[r0]
 21094  05266H  09101H      str      r1,[sp,#4]
 21096  05268H  09803H      ldr      r0,[sp,#12]
 21098  0526AH  00180H      lsls     r0,r0,#6
 21100  0526CH  09902H      ldr      r1,[sp,#8]
 21102  0526EH  00789H      lsls     r1,r1,#30
 21104  05270H  00F89H      lsrs     r1,r1,#30
 21106  05272H  000C9H      lsls     r1,r1,#3
 21108  05274H  04088H      lsls     r0,r1
 21110  05276H  09901H      ldr      r1,[sp,#4]
 21112  05278H  01808H      adds     r0,r1,r0
 21114  0527AH  09001H      str      r0,[sp,#4]
 21116  0527CH  09800H      ldr      r0,[sp]
 21118  0527EH  09901H      ldr      r1,[sp,#4]
 21120  05280H  06001H      str      r1,[r0]
 21122  05282H  0B004H      add      sp,#16
 21124  05284H  0BD00H      pop      { pc }
 21126  05286H  046C0H      nop
 21128  05288H  0E000ED14H

PROCEDURE Exceptions.GetSysExcPrio:
 21132  0528CH  0B503H      push     { r0, r1, lr }
 21134  0528EH  0B081H      sub      sp,#4
 21136  05290H  02019H      movs     r0,#25
 21138  05292H  002C0H      lsls     r0,r0,#11
 21140  05294H  09901H      ldr      r1,[sp,#4]
 21142  05296H  02201H      movs     r2,#1
 21144  05298H  0408AH      lsls     r2,r1
 21146  0529AH  04210H      tst      r0,r2
 21148  0529CH  0D101H      bne.n    2 -> 21154
 21150  0529EH  0DF65H      svc      101
 21152  052A0H  00091H      <LineNo: 145>
 21154  052A2H  09801H      ldr      r0,[sp,#4]
 21156  052A4H  01080H      asrs     r0,r0,#2
 21158  052A6H  00080H      lsls     r0,r0,#2
 21160  052A8H  04904H      ldr      r1,[pc,#16] -> 21180
 21162  052AAH  01840H      adds     r0,r0,r1
 21164  052ACH  09000H      str      r0,[sp]
 21166  052AEH  09800H      ldr      r0,[sp]
 21168  052B0H  06801H      ldr      r1,[r0]
 21170  052B2H  09A02H      ldr      r2,[sp,#8]
 21172  052B4H  06011H      str      r1,[r2]
 21174  052B6H  0B003H      add      sp,#12
 21176  052B8H  0BD00H      pop      { pc }
 21178  052BAH  046C0H      nop
 21180  052BCH  0E000ED14H

PROCEDURE Exceptions.InstallExcHandler:
 21184  052C0H  0B503H      push     { r0, r1, lr }
 21186  052C2H  0B082H      sub      sp,#8
 21188  052C4H  04807H      ldr      r0,[pc,#28] -> 21220
 21190  052C6H  06801H      ldr      r1,[r0]
 21192  052C8H  09100H      str      r1,[sp]
 21194  052CAH  09800H      ldr      r0,[sp]
 21196  052CCH  09902H      ldr      r1,[sp,#8]
 21198  052CEH  01840H      adds     r0,r0,r1
 21200  052D0H  09001H      str      r0,[sp,#4]
 21202  052D2H  09803H      ldr      r0,[sp,#12]
 21204  052D4H  02101H      movs     r1,#1
 21206  052D6H  04308H      orrs     r0,r1
 21208  052D8H  09003H      str      r0,[sp,#12]
 21210  052DAH  09801H      ldr      r0,[sp,#4]
 21212  052DCH  09903H      ldr      r1,[sp,#12]
 21214  052DEH  06001H      str      r1,[r0]
 21216  052E0H  0B004H      add      sp,#16
 21218  052E2H  0BD00H      pop      { pc }
 21220  052E4H  0E000ED08H

PROCEDURE Exceptions.SetNMI:
 21224  052E8H  0B503H      push     { r0, r1, lr }
 21226  052EAH  02003H      movs     r0,#3
 21228  052ECH  09900H      ldr      r1,[sp]
 21230  052EEH  02201H      movs     r2,#1
 21232  052F0H  0408AH      lsls     r2,r1
 21234  052F2H  04210H      tst      r0,r2
 21236  052F4H  0D101H      bne.n    2 -> 21242
 21238  052F6H  0DF65H      svc      101
 21240  052F8H  000A5H      <LineNo: 165>
 21242  052FAH  09800H      ldr      r0,[sp]
 21244  052FCH  04601H      mov      r1,r0
 21246  052FEH  046C0H      nop
 21248  05300H  02901H      cmp      r1,#1
 21250  05302H  0DD01H      ble.n    2 -> 21256
 21252  05304H  0DF04H      svc      4
 21254  05306H  000A6H      <LineNo: 166>
 21256  05308H  00049H      lsls     r1,r1,#1
 21258  0530AH  046C0H      nop
 21260  0530CH  04A01H      ldr      r2,[pc,#4] -> 21268
 21262  0530EH  01852H      adds     r2,r2,r1
 21264  05310H  0447AH      add      r2,pc
 21266  05312H  04710H      bx       r2
 21268  05314H  25
 21272  05318H  04806H      ldr      r0,[pc,#24] -> 21300
 21274  0531AH  09901H      ldr      r1,[sp,#4]
 21276  0531CH  06001H      str      r1,[r0]
 21278  0531EH  0E007H      b        14 -> 21296
 21280  05320H  046C0H      nop
 21282  05322H  04805H      ldr      r0,[pc,#20] -> 21304
 21284  05324H  09901H      ldr      r1,[sp,#4]
 21286  05326H  06001H      str      r1,[r0]
 21288  05328H  0E002H      b        4 -> 21296
 21290  0532AH  046C0H      nop
 21292  0532CH  0E7F4H      b        -24 -> 21272
 21294  0532EH  0E7F8H      b        -16 -> 21282
 21296  05330H  0B002H      add      sp,#8
 21298  05332H  0BD00H      pop      { pc }
 21300  05334H  040004000H
 21304  05338H  040004004H

PROCEDURE Exceptions..init:
 21308  0533CH  0B500H      push     { lr }
 21310  0533EH  0BD00H      pop      { pc }

MODULE Timers:
 21312  05340H  0

PROCEDURE Timers.GetTime:
 21316  05344H  0B503H      push     { r0, r1, lr }
 21318  05346H  0B082H      sub      sp,#8
 21320  05348H  04810H      ldr      r0,[pc,#64] -> 21388
 21322  0534AH  06801H      ldr      r1,[r0]
 21324  0534CH  09A02H      ldr      r2,[sp,#8]
 21326  0534EH  06011H      str      r1,[r2]
 21328  05350H  02000H      movs     r0,#0
 21330  05352H  0A901H      add      r1,sp,#4
 21332  05354H  07008H      strb     r0,[r1]
 21334  05356H  0480EH      ldr      r0,[pc,#56] -> 21392
 21336  05358H  06801H      ldr      r1,[r0]
 21338  0535AH  09A03H      ldr      r2,[sp,#12]
 21340  0535CH  06011H      str      r1,[r2]
 21342  0535EH  0480BH      ldr      r0,[pc,#44] -> 21388
 21344  05360H  06801H      ldr      r1,[r0]
 21346  05362H  09100H      str      r1,[sp]
 21348  05364H  09800H      ldr      r0,[sp]
 21350  05366H  09902H      ldr      r1,[sp,#8]
 21352  05368H  06809H      ldr      r1,[r1]
 21354  0536AH  04288H      cmp      r0,r1
 21356  0536CH  0D001H      beq.n    2 -> 21362
 21358  0536EH  02000H      movs     r0,#0
 21360  05370H  0E000H      b        0 -> 21364
 21362  05372H  02001H      movs     r0,#1
 21364  05374H  0A901H      add      r1,sp,#4
 21366  05376H  07008H      strb     r0,[r1]
 21368  05378H  09800H      ldr      r0,[sp]
 21370  0537AH  09902H      ldr      r1,[sp,#8]
 21372  0537CH  06008H      str      r0,[r1]
 21374  0537EH  0A801H      add      r0,sp,#4
 21376  05380H  07800H      ldrb     r0,[r0]
 21378  05382H  02101H      movs     r1,#1
 21380  05384H  04208H      tst      r0,r1
 21382  05386H  0D0E6H      beq.n    -52 -> 21334
 21384  05388H  0B004H      add      sp,#16
 21386  0538AH  0BD00H      pop      { pc }
 21388  0538CH  040054024H
 21392  05390H  040054028H

PROCEDURE Timers.GetTimeL:
 21396  05394H  0B501H      push     { r0, lr }
 21398  05396H  04803H      ldr      r0,[pc,#12] -> 21412
 21400  05398H  06801H      ldr      r1,[r0]
 21402  0539AH  09A00H      ldr      r2,[sp]
 21404  0539CH  06011H      str      r1,[r2]
 21406  0539EH  0B001H      add      sp,#4
 21408  053A0H  0BD00H      pop      { pc }
 21410  053A2H  046C0H      nop
 21412  053A4H  040054028H

PROCEDURE Timers.InstallAlarmIntHandler:
 21416  053A8H  0B503H      push     { r0, r1, lr }
 21418  053AAH  09800H      ldr      r0,[sp]
 21420  053ACH  03000H      adds     r0,#0
 21422  053AEH  09901H      ldr      r1,[sp,#4]
 21424  053B0H  0F7FFFF30H  bl.w     Exceptions.InstallIntHandler
 21428  053B4H  0E000H      b        0 -> 21432
 21430  053B6H  0002CH      <LineNo: 44>
 21432  053B8H  0B002H      add      sp,#8
 21434  053BAH  0BD00H      pop      { pc }

PROCEDURE Timers.SetAlarmIntPrio:
 21436  053BCH  0B503H      push     { r0, r1, lr }
 21438  053BEH  09800H      ldr      r0,[sp]
 21440  053C0H  03000H      adds     r0,#0
 21442  053C2H  09901H      ldr      r1,[sp,#4]
 21444  053C4H  0F7FFFEFAH  bl.w     Exceptions.SetIntPrio
 21448  053C8H  0E000H      b        0 -> 21452
 21450  053CAH  00032H      <LineNo: 50>
 21452  053CCH  0B002H      add      sp,#8
 21454  053CEH  0BD00H      pop      { pc }

PROCEDURE Timers.EnableAlarmInt:
 21456  053D0H  0B501H      push     { r0, lr }
 21458  053D2H  09800H      ldr      r0,[sp]
 21460  053D4H  02101H      movs     r1,#1
 21462  053D6H  04081H      lsls     r1,r0
 21464  053D8H  04608H      mov      r0,r1
 21466  053DAH  04902H      ldr      r1,[pc,#8] -> 21476
 21468  053DCH  06008H      str      r0,[r1]
 21470  053DEH  0B001H      add      sp,#4
 21472  053E0H  0BD00H      pop      { pc }
 21474  053E2H  046C0H      nop
 21476  053E4H  040056038H

PROCEDURE Timers.DeassertAlarmInt:
 21480  053E8H  0B501H      push     { r0, lr }
 21482  053EAH  09800H      ldr      r0,[sp]
 21484  053ECH  02101H      movs     r1,#1
 21486  053EEH  04081H      lsls     r1,r0
 21488  053F0H  04608H      mov      r0,r1
 21490  053F2H  04902H      ldr      r1,[pc,#8] -> 21500
 21492  053F4H  06008H      str      r0,[r1]
 21494  053F6H  0B001H      add      sp,#4
 21496  053F8H  0BD00H      pop      { pc }
 21498  053FAH  046C0H      nop
 21500  053FCH  040057034H

PROCEDURE Timers.SetTime:
 21504  05400H  0B503H      push     { r0, r1, lr }
 21506  05402H  04804H      ldr      r0,[pc,#16] -> 21524
 21508  05404H  09901H      ldr      r1,[sp,#4]
 21510  05406H  06001H      str      r1,[r0]
 21512  05408H  04803H      ldr      r0,[pc,#12] -> 21528
 21514  0540AH  09900H      ldr      r1,[sp]
 21516  0540CH  06001H      str      r1,[r0]
 21518  0540EH  0B002H      add      sp,#8
 21520  05410H  0BD00H      pop      { pc }
 21522  05412H  046C0H      nop
 21524  05414H  040054004H
 21528  05418H  040054000H

PROCEDURE Timers..init:
 21532  0541CH  0B500H      push     { lr }
 21534  0541EH  0BD00H      pop      { pc }

MODULE DebugEvalImp:
 21536  05420H  0
 21540  05424H  4
 21544  05428H  0
 21548  0542CH  0
 21552  05430H  0
 21556  05434H  0

PROCEDURE DebugEvalImp..init:
 21560  05438H  0B500H      push     { lr }
 21562  0543AH  0202AH      movs     r0,#42
 21564  0543CH  04901H      ldr      r1,[pc,#4] -> 21572
 21566  0543EH  06008H      str      r0,[r1]
 21568  05440H  0BD00H      pop      { pc }
 21570  05442H  046C0H      nop
 21572  05444H  02002FC68H

MODULE DebugEval:
 21576  05448H  0
 21580  0544CH  12
 21584  05450H  01000544CH
 21588  05454H  0
 21592  05458H  0
 21596  0545CH  0
 21600  05460H  20
 21604  05464H  01000544CH
 21608  05468H  010005460H
 21612  0546CH  0
 21616  05470H  0
 21620  05474H  28
 21624  05478H  01000544CH
 21628  0547CH  010005460H
 21632  05480H  010005474H
 21636  05484H  0

PROCEDURE DebugEval.writeThreadInfo:
 21640  05488H  0B503H      push     { r0, r1, lr }
 21642  0548AH  046C0H      nop
 21644  0548CH  0A000H      adr      r0,pc,#0 -> 21648
 21646  0548EH  0E001H      b        2 -> 21652
 21648  05490H  99
 21652  05494H  02102H      movs     r1,#2
 21654  05496H  0F7FEFDF3H  bl.w     Out.String
 21658  0549AH  0E000H      b        0 -> 21662
 21660  0549CH  0002FH      <LineNo: 47>
 21662  0549EH  09801H      ldr      r0,[sp,#4]
 21664  054A0H  02100H      movs     r1,#0
 21666  054A2H  0F7FEFE1FH  bl.w     Out.Int
 21670  054A6H  0E000H      b        0 -> 21674
 21672  054A8H  0002FH      <LineNo: 47>
 21674  054AAH  046C0H      nop
 21676  054ACH  0A000H      adr      r0,pc,#0 -> 21680
 21678  054AEH  0E001H      b        2 -> 21684
 21680  054B0H  29741
 21684  054B4H  02103H      movs     r1,#3
 21686  054B6H  0F7FEFDE3H  bl.w     Out.String
 21690  054BAH  0E000H      b        0 -> 21694
 21692  054BCH  00030H      <LineNo: 48>
 21694  054BEH  09800H      ldr      r0,[sp]
 21696  054C0H  02100H      movs     r1,#0
 21698  054C2H  0F7FEFE0FH  bl.w     Out.Int
 21702  054C6H  0E000H      b        0 -> 21706
 21704  054C8H  00030H      <LineNo: 48>
 21706  054CAH  0B002H      add      sp,#8
 21708  054CCH  0BD00H      pop      { pc }
 21710  054CEH  046C0H      nop

PROCEDURE DebugEval.testType:
 21712  054D0H  0B503H      push     { r0, r1, lr }
 21714  054D2H  0A800H      add      r0,sp,#0
 21716  054D4H  068C0H      ldr      r0,[r0,#12]
 21718  054D6H  04904H      ldr      r1,[pc,#16] -> 21736
 21720  054D8H  0467AH      mov      r2,pc
 21722  054DAH  01889H      adds     r1,r1,r2
 21724  054DCH  04288H      cmp      r0,r1
 21726  054DEH  0D001H      beq.n    2 -> 21732
 21728  054E0H  0E000H      b        0 -> 21732
 21730  054E2H  046C0H      nop
 21732  054E4H  0B002H      add      sp,#8
 21734  054E6H  0BD00H      pop      { pc }
 21736  054E8H  -104

PROCEDURE DebugEval.t0c:
 21740  054ECH  0B500H      push     { lr }
 21742  054EEH  0B081H      sub      sp,#4
 21744  054F0H  04816H      ldr      r0,[pc,#88] -> 21836
 21746  054F2H  02101H      movs     r1,#1
 21748  054F4H  00649H      lsls     r1,r1,#25
 21750  054F6H  06001H      str      r1,[r0]
 21752  054F8H  02000H      movs     r0,#0
 21754  054FAH  09000H      str      r0,[sp]
 21756  054FCH  04814H      ldr      r0,[pc,#80] -> 21840
 21758  054FEH  04918H      ldr      r1,[pc,#96] -> 21856
 21760  05500H  06008H      str      r0,[r1]
 21762  05502H  04817H      ldr      r0,[pc,#92] -> 21856
 21764  05504H  06800H      ldr      r0,[r0]
 21766  05506H  02107H      movs     r1,#7
 21768  05508H  00649H      lsls     r1,r1,#25
 21770  0550AH  01840H      adds     r0,r0,r1
 21772  0550CH  04914H      ldr      r1,[pc,#80] -> 21856
 21774  0550EH  06008H      str      r0,[r1]
 21776  05510H  04813H      ldr      r0,[pc,#76] -> 21856
 21778  05512H  06800H      ldr      r0,[r0]
 21780  05514H  0490FH      ldr      r1,[pc,#60] -> 21844
 21782  05516H  01840H      adds     r0,r0,r1
 21784  05518H  04911H      ldr      r1,[pc,#68] -> 21856
 21786  0551AH  06008H      str      r0,[r1]
 21788  0551CH  0480EH      ldr      r0,[pc,#56] -> 21848
 21790  0551EH  04911H      ldr      r1,[pc,#68] -> 21860
 21792  05520H  06008H      str      r0,[r1]
 21794  05522H  09800H      ldr      r0,[sp]
 21796  05524H  0F7FFFDB0H  bl.w     LEDext.SetValue
 21800  05528H  0E000H      b        0 -> 21804
 21802  0552AH  0004CH      <LineNo: 76>
 21804  0552CH  09800H      ldr      r0,[sp]
 21806  0552EH  03001H      adds     r0,#1
 21808  05530H  09000H      str      r0,[sp]
 21810  05532H  0480AH      ldr      r0,[pc,#40] -> 21852
 21812  05534H  02101H      movs     r1,#1
 21814  05536H  00649H      lsls     r1,r1,#25
 21816  05538H  06001H      str      r1,[r0]
 21818  0553AH  0F7FFF9C7H  bl.w     Kernel.Next
 21822  0553EH  0E000H      b        0 -> 21826
 21824  05540H  0004FH      <LineNo: 79>
 21826  05542H  04280H      cmp      r0,r0
 21828  05544H  0D0EDH      beq.n    -38 -> 21794
 21830  05546H  0B001H      add      sp,#4
 21832  05548H  0BD00H      pop      { pc }
 21834  0554AH  046C0H      nop
 21836  0554CH  0D0000014H
 21840  05550H  0F0000000H
 21844  05554H  000D00001H
 21848  05558H  -42
 21852  0555CH  0D000001CH
 21856  05560H  02002FC54H
 21860  05564H  02002FC4CH

PROCEDURE DebugEval.t1c:
 21864  05568H  0B500H      push     { lr }
 21866  0556AH  0B085H      sub      sp,#20
 21868  0556CH  0F7FFFAECH  bl.w     Kernel.Tid
 21872  05570H  0E000H      b        0 -> 21876
 21874  05572H  00057H      <LineNo: 87>
 21876  05574H  09000H      str      r0,[sp]
 21878  05576H  02000H      movs     r0,#0
 21880  05578H  09002H      str      r0,[sp,#8]
 21882  0557AH  0A803H      add      r0,sp,#12
 21884  0557CH  0F7FFFF0AH  bl.w     Timers.GetTimeL
 21888  05580H  0E000H      b        0 -> 21892
 21890  05582H  00059H      <LineNo: 89>
 21892  05584H  0F7FFF9A2H  bl.w     Kernel.Next
 21896  05588H  0E000H      b        0 -> 21900
 21898  0558AH  0005BH      <LineNo: 91>
 21900  0558CH  0A804H      add      r0,sp,#16
 21902  0558EH  0F7FFFF01H  bl.w     Timers.GetTimeL
 21906  05592H  0E000H      b        0 -> 21910
 21908  05594H  0005CH      <LineNo: 92>
 21910  05596H  09800H      ldr      r0,[sp]
 21912  05598H  09901H      ldr      r1,[sp,#4]
 21914  0559AH  0F7FFFF75H  bl.w     DebugEval.writeThreadInfo
 21918  0559EH  0E000H      b        0 -> 21922
 21920  055A0H  0005DH      <LineNo: 93>
 21922  055A2H  09802H      ldr      r0,[sp,#8]
 21924  055A4H  02108H      movs     r1,#8
 21926  055A6H  0F7FEFD9DH  bl.w     Out.Int
 21930  055AAH  0E000H      b        0 -> 21934
 21932  055ACH  0005EH      <LineNo: 94>
 21934  055AEH  09804H      ldr      r0,[sp,#16]
 21936  055B0H  09903H      ldr      r1,[sp,#12]
 21938  055B2H  01A40H      subs     r0,r0,r1
 21940  055B4H  02108H      movs     r1,#8
 21942  055B6H  0F7FEFD95H  bl.w     Out.Int
 21946  055BAH  0E000H      b        0 -> 21950
 21948  055BCH  0005EH      <LineNo: 94>
 21950  055BEH  0F7FEFD79H  bl.w     Out.Ln
 21954  055C2H  0E000H      b        0 -> 21958
 21956  055C4H  0005EH      <LineNo: 94>
 21958  055C6H  09804H      ldr      r0,[sp,#16]
 21960  055C8H  09003H      str      r0,[sp,#12]
 21962  055CAH  09802H      ldr      r0,[sp,#8]
 21964  055CCH  03001H      adds     r0,#1
 21966  055CEH  09002H      str      r0,[sp,#8]
 21968  055D0H  04280H      cmp      r0,r0
 21970  055D2H  0D0D7H      beq.n    -82 -> 21892
 21972  055D4H  0B005H      add      sp,#20
 21974  055D6H  0BD00H      pop      { pc }

PROCEDURE DebugEval.run:
 21976  055D8H  0B500H      push     { lr }
 21978  055DAH  0B081H      sub      sp,#4
 21980  055DCH  0200AH      movs     r0,#10
 21982  055DEH  0F7FFFC05H  bl.w     Kernel.Install
 21986  055E2H  0E000H      b        0 -> 21990
 21988  055E4H  00069H      <LineNo: 105>
 21990  055E6H  046C0H      nop
 21992  055E8H  04821H      ldr      r0,[pc,#132] -> 22128
 21994  055EAH  04478H      add      r0,pc
 21996  055ECH  02101H      movs     r1,#1
 21998  055EEH  00289H      lsls     r1,r1,#10
 22000  055F0H  04A21H      ldr      r2,[pc,#132] -> 22136
 22002  055F2H  04B22H      ldr      r3,[pc,#136] -> 22140
 22004  055F4H  0466CH      mov      r4,sp
 22006  055F6H  0F7FFF8C1H  bl.w     Kernel.Allocate
 22010  055FAH  0E000H      b        0 -> 22014
 22012  055FCH  0006AH      <LineNo: 106>
 22014  055FEH  09800H      ldr      r0,[sp]
 22016  05600H  02800H      cmp      r0,#0
 22018  05602H  0D001H      beq.n    2 -> 22024
 22020  05604H  0DF00H      svc      0
 22022  05606H  0006AH      <LineNo: 106>
 22024  05608H  0481BH      ldr      r0,[pc,#108] -> 22136
 22026  0560AH  06800H      ldr      r0,[r0]
 22028  0560CH  021FAH      movs     r1,#250
 22030  0560EH  02200H      movs     r2,#0
 22032  05610H  0F7FFF952H  bl.w     Kernel.SetPeriod
 22036  05614H  0E000H      b        0 -> 22040
 22038  05616H  0006BH      <LineNo: 107>
 22040  05618H  04817H      ldr      r0,[pc,#92] -> 22136
 22042  0561AH  06800H      ldr      r0,[r0]
 22044  0561CH  0F7FFF93AH  bl.w     Kernel.Enable
 22048  05620H  0E000H      b        0 -> 22052
 22050  05622H  0006BH      <LineNo: 107>
 22052  05624H  04813H      ldr      r0,[pc,#76] -> 22132
 22054  05626H  04478H      add      r0,pc
 22056  05628H  02101H      movs     r1,#1
 22058  0562AH  00289H      lsls     r1,r1,#10
 22060  0562CH  04A14H      ldr      r2,[pc,#80] -> 22144
 22062  0562EH  04B15H      ldr      r3,[pc,#84] -> 22148
 22064  05630H  0466CH      mov      r4,sp
 22066  05632H  0F7FFF8A3H  bl.w     Kernel.Allocate
 22070  05636H  0E000H      b        0 -> 22074
 22072  05638H  0006CH      <LineNo: 108>
 22074  0563AH  09800H      ldr      r0,[sp]
 22076  0563CH  02800H      cmp      r0,#0
 22078  0563EH  0D001H      beq.n    2 -> 22084
 22080  05640H  0DF00H      svc      0
 22082  05642H  0006CH      <LineNo: 108>
 22084  05644H  0480EH      ldr      r0,[pc,#56] -> 22144
 22086  05646H  06800H      ldr      r0,[r0]
 22088  05648H  0217DH      movs     r1,#125
 22090  0564AH  000C9H      lsls     r1,r1,#3
 22092  0564CH  02200H      movs     r2,#0
 22094  0564EH  0F7FFF933H  bl.w     Kernel.SetPeriod
 22098  05652H  0E000H      b        0 -> 22102
 22100  05654H  0006DH      <LineNo: 109>
 22102  05656H  0480AH      ldr      r0,[pc,#40] -> 22144
 22104  05658H  06800H      ldr      r0,[r0]
 22106  0565AH  0F7FFF91BH  bl.w     Kernel.Enable
 22110  0565EH  0E000H      b        0 -> 22114
 22112  05660H  0006DH      <LineNo: 109>
 22114  05662H  0F7FFFB91H  bl.w     Kernel.Run
 22118  05666H  0E000H      b        0 -> 22122
 22120  05668H  0006EH      <LineNo: 110>
 22122  0566AH  0B001H      add      sp,#4
 22124  0566CH  0BD00H      pop      { pc }
 22126  0566EH  046C0H      nop
 22128  05670H  -258
 22132  05674H  -194
 22136  05678H  02002FC64H
 22140  0567CH  02002FC5CH
 22144  05680H  02002FC60H
 22148  05684H  02002FC58H

PROCEDURE DebugEval..init:
 22152  05688H  0B500H      push     { lr }
 22154  0568AH  0F7FFFFA5H  bl.w     DebugEval.run
 22158  0568EH  0E000H      b        0 -> 22162
 22160  05690H  00073H      <LineNo: 115>
 22162  05692H  0BD00H      pop      { pc }
 22164  05694H  0F7FAFEB6H  bl.w     LinkOptions..init
 22168  05698H  0F7FAFEBCH  bl.w     MCU2..init
 22172  0569CH  0F7FAFEF0H  bl.w     Config..init
 22176  056A0H  0F7FAFF30H  bl.w     StartUp..init
 22180  056A4H  0F7FBF8ECH  bl.w     Error..init
 22184  056A8H  0F7FBFBBEH  bl.w     Errors..init
 22188  056ACH  0F7FBFD2CH  bl.w     GPIO..init
 22192  056B0H  0F7FBFE92H  bl.w     Clocks..init
 22196  056B4H  0F7FBFF24H  bl.w     MAU..init
 22200  056B8H  0F7FCFA4EH  bl.w     Memory..init
 22204  056BCH  0F7FCFA62H  bl.w     LED..init
 22208  056C0H  0F7FCFF16H  bl.w     RuntimeErrors..init
 22212  056C4H  0F7FCFF66H  bl.w     TextIO..init
 22216  056C8H  0F7FDFB44H  bl.w     Texts..init
 22220  056CCH  0F7FDFD2EH  bl.w     ResData..init
 22224  056D0H  0F7FEF944H  bl.w     RuntimeErrorsOu..init
 22228  056D4H  0F7FEFB6AH  bl.w     UARTdev..init
 22232  056D8H  0F7FEFC86H  bl.w     Terminals..init
 22236  056DCH  0F7FEFD68H  bl.w     Out..init
 22240  056E0H  0F7FEFDBEH  bl.w     In..init
 22244  056E4H  0F7FEFEBEH  bl.w     UARTstr..init
 22248  056E8H  0F7FEFF50H  bl.w     Main..init
 22252  056ECH  0F7FEFFC2H  bl.w     Coroutines..init
 22256  056F0H  0F7FEFFECH  bl.w     SysTick..init
 22260  056F4H  0F7FFFC5EH  bl.w     Kernel..init
 22264  056F8H  0F7FFFD24H  bl.w     LEDext..init
 22268  056FCH  0F7FFFE1EH  bl.w     Exceptions..init
 22272  05700H  0F7FFFE8CH  bl.w     Timers..init
 22276  05704H  0F7FFFE98H  bl.w     DebugEvalImp..init
 22280  05708H  0F7FFFFBEH  bl.w     DebugEval..init
 22284  0570CH  0F7FFFFFEH  bl.w     DebugEval..init + 132
 22288  05710H  05237424FH  "OB7R"
 22292  05714H  000000001H
 22296  05718H  06665722EH  ".ref"
 22300  0571CH  000000000H
 22304  05720H  0
 22308  05724H  6576
 22312  05728H  0
 22316  0572CH  06B6E694CH  "Link"
 22320  05730H  06974704FH  "Opti"
 22324  05734H  000736E6FH  "ons"
 22328  05738H  0
 22332  0573CH  010000340H
 22336  05740H  1
 22340  05744H  065646F43H  "Code"
 22344  05748H  072617453H  "Star"
 22348  0574CH  064644174H  "tAdd"
 22352  05750H  000736572H  "res"
 22356  05754H  010000344H
 22360  05758H  2
 22364  0575CH  074696E49H  "Init"
 22368  05760H  072617400H
 22372  05764H  064644174H  "tAdd"
 22376  05768H  000736572H  "res"
 22380  0576CH  010000348H
 22384  05770H  3
 22388  05774H  0696E692EH  ".ini"
 22392  05778H  072610074H  "t"
 22396  0577CH  064644174H  "tAdd"
 22400  05780H  000736572H  "res"
 22404  05784H  010000404H
 22408  05788H  0
 22412  0578CH  03255434DH  "MCU2"
 22416  05790H  000000000H
 22420  05794H  0
 22424  05798H  0
 22428  0579CH  010000410H
 22432  057A0H  1
 22436  057A4H  0696E692EH  ".ini"
 22440  057A8H  000000074H  "t"
 22444  057ACH  0
 22448  057B0H  0
 22452  057B4H  010000414H
 22456  057B8H  0
 22460  057BCH  0666E6F43H  "Conf"
 22464  057C0H  000006769H  "ig"
 22468  057C4H  0
 22472  057C8H  0
 22476  057CCH  010000418H
 22480  057D0H  1
 22484  057D4H  074696E69H  "init"
 22488  057D8H  069747000H
 22492  057DCH  000736E6FH  "ons"
 22496  057E0H  0
 22500  057E4H  01000041CH
 22504  057E8H  2
 22508  057ECH  0696E692EH  ".ini"
 22512  057F0H  069740074H  "t"
 22516  057F4H  000736E6FH  "ons"
 22520  057F8H  0
 22524  057FCH  010000480H
 22528  05800H  0
 22532  05804H  072617453H  "Star"
 22536  05808H  000705574H  "tUp"
 22540  0580CH  0
 22544  05810H  0
 22548  05814H  01000048CH
 22552  05818H  1
 22556  0581CH  069617741H  "Awai"
 22560  05820H  0776F5074H  "tPow"
 22564  05824H  06E4F7265H  "erOn"
 22568  05828H  000736552H  "Res"
 22572  0582CH  010000490H
 22576  05830H  2
 22580  05834H  0656C6552H  "Rele"
 22584  05838H  052657361H  "aseR"
 22588  0583CH  074657365H  "eset"
 22592  05840H  000736500H
 22596  05844H  0100004B0H
 22600  05848H  3
 22604  0584CH  069617741H  "Awai"
 22608  05850H  06C655274H  "tRel"
 22612  05854H  065736165H  "ease"
 22616  05858H  0006E6F44H  "Don"
 22620  0585CH  0100004E4H
 22624  05860H  4
 22628  05864H  0696E692EH  ".ini"
 22632  05868H  06C650074H  "t"
 22636  0586CH  065736165H  "ease"
 22640  05870H  0006E6F44H  "Don"
 22644  05874H  010000504H
 22648  05878H  0
 22652  0587CH  06F727245H  "Erro"
 22656  05880H  000000072H  "r"
 22660  05884H  0
 22664  05888H  0
 22668  0588CH  010000508H
 22672  05890H  1
 22676  05894H  04D647453H  "StdM"
 22680  05898H  000006773H  "sg"
 22684  0589CH  0
 22688  058A0H  0
 22692  058A4H  01000050CH
 22696  058A8H  2
 22700  058ACH  0696E692EH  ".ini"
 22704  058B0H  000000074H  "t"
 22708  058B4H  0
 22712  058B8H  0
 22716  058BCH  010000880H
 22720  058C0H  0
 22724  058C4H  06F727245H  "Erro"
 22728  058C8H  000007372H  "rs"
 22732  058CCH  0
 22736  058D0H  0
 22740  058D4H  010000898H
 22744  058D8H  1
 22748  058DCH  06C756166H  "faul"
 22752  058E0H  073654D74H  "tMes"
 22756  058E4H  065676173H  "sage"
 22760  058E8H  000000000H
 22764  058ECH  01000089CH
 22768  058F0H  2
 22772  058F4H  06F727265H  "erro"
 22776  058F8H  073654D72H  "rMes"
 22780  058FCH  065676173H  "sage"
 22784  05900H  000000000H
 22788  05904H  0100009C4H
 22792  05908H  3
 22796  0590CH  00067734DH  "Msg"
 22800  05910H  073654D72H  "rMes"
 22804  05914H  065676173H  "sage"
 22808  05918H  000000000H
 22812  0591CH  010000D9CH
 22816  05920H  4
 22820  05924H  045746547H  "GetE"
 22824  05928H  070656378H  "xcep"
 22828  0592CH  06E6F6974H  "tion"
 22832  05930H  000707954H  "Typ"
 22836  05934H  010000DC8H
 22840  05938H  5
 22844  0593CH  0696E692EH  ".ini"
 22848  05940H  070650074H  "t"
 22852  05944H  06E6F6974H  "tion"
 22856  05948H  000707954H  "Typ"
 22860  0594CH  010000E28H
 22864  05950H  0
 22868  05954H  04F495047H  "GPIO"
 22872  05958H  000000000H
 22876  0595CH  0
 22880  05960H  0
 22884  05964H  010000E2CH
 22888  05968H  1
 22892  0596CH  046746553H  "SetF"
 22896  05970H  074636E75H  "unct"
 22900  05974H  0006E6F69H  "ion"
 22904  05978H  0
 22908  0597CH  010000E44H
 22912  05980H  2
 22916  05984H  049746553H  "SetI"
 22920  05988H  07265766EH  "nver"
 22924  0598CH  073726574H  "ters"
 22928  05990H  000000000H
 22932  05994H  010000E8CH
 22936  05998H  3
 22940  0599CH  0666E6F43H  "Conf"
 22944  059A0H  072756769H  "igur"
 22948  059A4H  064615065H  "ePad"
 22952  059A8H  000000000H
 22956  059ACH  010000EC0H
 22960  059B0H  4
 22964  059B4H  050746547H  "GetP"
 22968  059B8H  061426461H  "adBa"
 22972  059BCH  066436573H  "seCf"
 22976  059C0H  000000067H  "g"
 22980  059C4H  010000FA8H
 22984  059C8H  5
 22988  059CCH  061736944H  "Disa"
 22992  059D0H  04F656C62H  "bleO"
 22996  059D4H  075707475H  "utpu"
 23000  059D8H  000000074H  "t"
 23004  059DCH  010000FD4H
 23008  059E0H  6
 23012  059E4H  061736944H  "Disa"
 23016  059E8H  049656C62H  "bleI"
 23020  059ECH  07475706EH  "nput"
 23024  059F0H  000000000H
 23028  059F4H  010000FF0H
 23032  059F8H  7
 23036  059FCH  000746553H  "Set"
 23040  05A00H  049656C62H  "bleI"
 23044  05A04H  07475706EH  "nput"
 23048  05A08H  000000000H
 23052  05A0CH  01000100CH
 23056  05A10H  8
 23060  05A14H  061656C43H  "Clea"
 23064  05A18H  049650072H  "r"
 23068  05A1CH  07475706EH  "nput"
 23072  05A20H  000000000H
 23076  05A24H  01000101CH
 23080  05A28H  9
 23084  05A2CH  067676F54H  "Togg"
 23088  05A30H  04900656CH  "le"
 23092  05A34H  07475706EH  "nput"
 23096  05A38H  000000000H
 23100  05A3CH  01000102CH
 23104  05A40H  10
 23108  05A44H  000746547H  "Get"
 23112  05A48H  04900656CH  "le"
 23116  05A4CH  07475706EH  "nput"
 23120  05A50H  000000000H
 23124  05A54H  01000103CH
 23128  05A58H  11
 23132  05A5CH  000747550H  "Put"
 23136  05A60H  04900656CH  "le"
 23140  05A64H  07475706EH  "nput"
 23144  05A68H  000000000H
 23148  05A6CH  010001050H
 23152  05A70H  12
 23156  05A74H  042746547H  "GetB"
 23160  05A78H  0006B6361H  "ack"
 23164  05A7CH  07475706EH  "nput"
 23168  05A80H  000000000H
 23172  05A84H  010001060H
 23176  05A88H  13
 23180  05A8CH  063656843H  "Chec"
 23184  05A90H  0006B006BH  "k"
 23188  05A94H  07475706EH  "nput"
 23192  05A98H  000000000H
 23196  05A9CH  010001074H
 23200  05AA0H  14
 23204  05AA4H  07074754FH  "Outp"
 23208  05AA8H  06E457475H  "utEn"
 23212  05AACH  0656C6261H  "able"
 23216  05AB0H  000000000H
 23220  05AB4H  010001098H
 23224  05AB8H  15
 23228  05ABCH  07074754FH  "Outp"
 23232  05AC0H  069447475H  "utDi"
 23236  05AC4H  06C626173H  "sabl"
 23240  05AC8H  000000065H  "e"
 23244  05ACCH  0100010A8H
 23248  05AD0H  16
 23252  05AD4H  07074754FH  "Outp"
 23256  05AD8H  06E457475H  "utEn"
 23260  05ADCH  067676F54H  "Togg"
 23264  05AE0H  00000656CH  "le"
 23268  05AE4H  0100010B8H
 23272  05AE8H  17
 23276  05AECH  04F746547H  "GetO"
 23280  05AF0H  075707475H  "utpu"
 23284  05AF4H  0616E4574H  "tEna"
 23288  05AF8H  000656C62H  "ble"
 23292  05AFCH  0100010C8H
 23296  05B00H  18
 23300  05B04H  074696E69H  "init"
 23304  05B08H  075707400H
 23308  05B0CH  0616E4574H  "tEna"
 23312  05B10H  000656C62H  "ble"
 23316  05B14H  0100010DCH
 23320  05B18H  19
 23324  05B1CH  0696E692EH  ".ini"
 23328  05B20H  075700074H  "t"
 23332  05B24H  0616E4574H  "tEna"
 23336  05B28H  000656C62H  "ble"
 23340  05B2CH  010001108H
 23344  05B30H  0
 23348  05B34H  0636F6C43H  "Cloc"
 23352  05B38H  00000736BH  "ks"
 23356  05B3CH  0
 23360  05B40H  0
 23364  05B44H  010001114H
 23368  05B48H  1
 23372  05B4CH  0696E6F4DH  "Moni"
 23376  05B50H  000726F74H  "tor"
 23380  05B54H  0
 23384  05B58H  0
 23388  05B5CH  010001118H
 23392  05B60H  2
 23396  05B64H  062616E45H  "Enab"
 23400  05B68H  06C43656CH  "leCl"
 23404  05B6CH  0576B636FH  "ockW"
 23408  05B70H  000656B61H  "ake"
 23412  05B74H  01000115CH
 23416  05B78H  3
 23420  05B7CH  061736944H  "Disa"
 23424  05B80H  043656C62H  "bleC"
 23428  05B84H  06B636F6CH  "lock"
 23432  05B88H  0006B6157H  "Wak"
 23436  05B8CH  010001178H
 23440  05B90H  4
 23444  05B94H  062616E45H  "Enab"
 23448  05B98H  06C43656CH  "leCl"
 23452  05B9CH  0536B636FH  "ockS"
 23456  05BA0H  00065656CH  "lee"
 23460  05BA4H  010001194H
 23464  05BA8H  5
 23468  05BACH  061736944H  "Disa"
 23472  05BB0H  043656C62H  "bleC"
 23476  05BB4H  06B636F6CH  "lock"
 23480  05BB8H  000656C53H  "Sle"
 23484  05BBCH  0100011B0H
 23488  05BC0H  6
 23492  05BC4H  045746547H  "GetE"
 23496  05BC8H  06C62616EH  "nabl"
 23500  05BCCH  06B006465H  "ed"
 23504  05BD0H  000656C53H  "Sle"
 23508  05BD4H  0100011CCH
 23512  05BD8H  7
 23516  05BDCH  072617473H  "star"
 23520  05BE0H  0534F5874H  "tXOS"
 23524  05BE4H  06B000043H  "C"
 23528  05BE8H  000656C53H  "Sle"
 23532  05BECH  0100011ECH
 23536  05BF0H  8
 23540  05BF4H  072617473H  "star"
 23544  05BF8H  073795374H  "tSys"
 23548  05BFCH  0004C4C50H  "PLL"
 23552  05C00H  000656C53H  "Sle"
 23556  05C04H  01000123CH
 23560  05C08H  9
 23564  05C0CH  072617473H  "star"
 23568  05C10H  062735574H  "tUsb"
 23572  05C14H  0004C4C50H  "PLL"
 23576  05C18H  000656C53H  "Sle"
 23580  05C1CH  0100012B4H
 23584  05C20H  10
 23588  05C24H  06E6E6F63H  "conn"
 23592  05C28H  043746365H  "ectC"
 23596  05C2CH  06B636F6CH  "lock"
 23600  05C30H  000650073H  "s"
 23604  05C34H  01000132CH
 23608  05C38H  11
 23612  05C3CH  072617473H  "star"
 23616  05C40H  063695474H  "tTic"
 23620  05C44H  06F6C436BH  "kClo"
 23624  05C48H  000006B63H  "ck"
 23628  05C4CH  010001390H
 23632  05C50H  12
 23636  05C54H  074696E69H  "init"
 23640  05C58H  063695400H
 23644  05C5CH  06F6C436BH  "kClo"
 23648  05C60H  000006B63H  "ck"
 23652  05C64H  0100013ACH
 23656  05C68H  13
 23660  05C6CH  0696E692EH  ".ini"
 23664  05C70H  063690074H  "t"
 23668  05C74H  06F6C436BH  "kClo"
 23672  05C78H  000006B63H  "ck"
 23676  05C7CH  0100013D8H
 23680  05C80H  0
 23684  05C84H  00055414DH  "MAU"
 23688  05C88H  0
 23692  05C8CH  0
 23696  05C90H  0
 23700  05C94H  0100013E4H
 23704  05C98H  1
 23708  05C9CH  00077654EH  "New"
 23712  05CA0H  06974704FH  "Opti"
 23716  05CA4H  000736E6FH  "ons"
 23720  05CA8H  0
 23724  05CACH  0100013E8H
 23728  05CB0H  2
 23732  05CB4H  070736944H  "Disp"
 23736  05CB8H  00065736FH  "ose"
 23740  05CBCH  000736E6FH  "ons"
 23744  05CC0H  0
 23748  05CC4H  01000140CH
 23752  05CC8H  3
 23756  05CCCH  04E746553H  "SetN"
 23760  05CD0H  000007765H  "ew"
 23764  05CD4H  000736E6FH  "ons"
 23768  05CD8H  0
 23772  05CDCH  010001430H
 23776  05CE0H  4
 23780  05CE4H  044746553H  "SetD"
 23784  05CE8H  06F707369H  "ispo"
 23788  05CECH  000006573H  "se"
 23792  05CF0H  0
 23796  05CF4H  010001440H
 23800  05CF8H  5
 23804  05CFCH  06F6C6C41H  "Allo"
 23808  05D00H  065746163H  "cate"
 23812  05D04H  000006500H
 23816  05D08H  0
 23820  05D0CH  010001450H
 23824  05D10H  6
 23828  05D14H  06C616544H  "Deal"
 23832  05D18H  061636F6CH  "loca"
 23836  05D1CH  000006574H  "te"
 23840  05D20H  0
 23844  05D24H  0100014BCH
 23848  05D28H  7
 23852  05D2CH  0696E692EH  ".ini"
 23856  05D30H  061630074H  "t"
 23860  05D34H  25972
 23864  05D38H  0
 23868  05D3CH  010001500H
 23872  05D40H  0
 23876  05D44H  06F6D654DH  "Memo"
 23880  05D48H  000007972H  "ry"
 23884  05D4CH  0
 23888  05D50H  0
 23892  05D54H  010001548H
 23896  05D58H  1
 23900  05D5CH  06F6C6C41H  "Allo"
 23904  05D60H  065746163H  "cate"
 23908  05D64H  000000000H
 23912  05D68H  0
 23916  05D6CH  01000159CH
 23920  05D70H  2
 23924  05D74H  06C616544H  "Deal"
 23928  05D78H  061636F6CH  "loca"
 23932  05D7CH  000006574H  "te"
 23936  05D80H  0
 23940  05D84H  010001634H
 23944  05D88H  3
 23948  05D8CH  06B636F4CH  "Lock"
 23952  05D90H  070616548H  "Heap"
 23956  05D94H  000000073H  "s"
 23960  05D98H  0
 23964  05D9CH  0100016A0H
 23968  05DA0H  4
 23972  05DA4H  074696E69H  "init"
 23976  05DA8H  063617453H  "Stac"
 23980  05DACH  06568436BH  "kChe"
 23984  05DB0H  000006B63H  "ck"
 23988  05DB4H  0100016B8H
 23992  05DB8H  5
 23996  05DBCH  063656863H  "chec"
 24000  05DC0H  06174536BH  "kSta"
 24004  05DC4H  073556B63H  "ckUs"
 24008  05DC8H  000656761H  "age"
 24012  05DCCH  0100016DCH
 24016  05DD0H  6
 24020  05DD4H  063656843H  "Chec"
 24024  05DD8H  06F6F4C6BH  "kLoo"
 24028  05DDCH  061745370H  "pSta"
 24032  05DE0H  000556B63H  "ckU"
 24036  05DE4H  010001720H
 24040  05DE8H  7
 24044  05DECH  063656843H  "Chec"
 24048  05DF0H  07268546BH  "kThr"
 24052  05DF4H  053646165H  "eadS"
 24056  05DF8H  000636174H  "tac"
 24060  05DFCH  01000178CH
 24064  05E00H  8
 24068  05E04H  06F6C6C61H  "allo"
 24072  05E08H  061745363H  "cSta"
 24076  05E0CH  053006B63H  "ck"
 24080  05E10H  000636174H  "tac"
 24084  05E14H  010001810H
 24088  05E18H  9
 24092  05E1CH  06F6C6C41H  "Allo"
 24096  05E20H  072685463H  "cThr"
 24100  05E24H  053646165H  "eadS"
 24104  05E28H  000636174H  "tac"
 24108  05E2CH  0100018B8H
 24112  05E30H  10
 24116  05E34H  06F6C6C41H  "Allo"
 24120  05E38H  06F6F4C63H  "cLoo"
 24124  05E3CH  061745370H  "pSta"
 24128  05E40H  000006B63H  "ck"
 24132  05E44H  010001968H
 24136  05E48H  11
 24140  05E4CH  062616E45H  "Enab"
 24144  05E50H  07453656CH  "leSt"
 24148  05E54H  0436B6361H  "ackC"
 24152  05E58H  000636568H  "hec"
 24156  05E5CH  010001A00H
 24160  05E60H  12
 24164  05E64H  065736552H  "Rese"
 24168  05E68H  069614D74H  "tMai"
 24172  05E6CH  06174536EH  "nSta"
 24176  05E70H  000006B63H  "ck"
 24180  05E74H  010001A30H
 24184  05E78H  13
 24188  05E7CH  074696E69H  "init"
 24192  05E80H  069614D00H
 24196  05E84H  06174536EH  "nSta"
 24200  05E88H  000006B63H  "ck"
 24204  05E8CH  010001A78H
 24208  05E90H  14
 24212  05E94H  0696E692EH  ".ini"
 24216  05E98H  069610074H  "t"
 24220  05E9CH  06174536EH  "nSta"
 24224  05EA0H  000006B63H  "ck"
 24228  05EA4H  010001B58H
 24232  05EA8H  0
 24236  05EACH  00044454CH  "LED"
 24240  05EB0H  0
 24244  05EB4H  0
 24248  05EB8H  0
 24252  05EBCH  010001B64H
 24256  05EC0H  1
 24260  05EC4H  074696E69H  "init"
 24264  05EC8H  000000000H
 24268  05ECCH  0
 24272  05ED0H  0
 24276  05ED4H  010001B68H
 24280  05ED8H  2
 24284  05EDCH  0696E692EH  ".ini"
 24288  05EE0H  000000074H  "t"
 24292  05EE4H  0
 24296  05EE8H  0
 24300  05EECH  010001B84H
 24304  05EF0H  0
 24308  05EF4H  0746E7552H  "Runt"
 24312  05EF8H  045656D69H  "imeE"
 24316  05EFCH  0726F7272H  "rror"
 24320  05F00H  000000073H  "s"
 24324  05F04H  010001B90H
 24328  05F08H  1
 24332  05F0CH  0544C4148H  "HALT"
 24336  05F10H  000007900H
 24340  05F14H  0
 24344  05F18H  0
 24348  05F1CH  010001C34H
 24352  05F20H  2
 24356  05F24H  048746567H  "getH"
 24360  05F28H  057666C61H  "alfW"
 24364  05F2CH  00064726FH  "ord"
 24368  05F30H  0
 24372  05F34H  010001C5CH
 24376  05F38H  3
 24380  05F3CH  04C427369H  "isBL"
 24384  05F40H  057666C00H
 24388  05F44H  00064726FH  "ord"
 24392  05F48H  0
 24396  05F4CH  010001C88H
 24400  05F50H  4
 24404  05F54H  04C427369H  "isBL"
 24408  05F58H  057660058H  "X"
 24412  05F5CH  00064726FH  "ord"
 24416  05F60H  0
 24420  05F64H  010001CACH
 24424  05F68H  5
 24428  05F6CH  04E746567H  "getN"
 24432  05F70H  04C747865H  "extL"
 24436  05F74H  000640052H  "R"
 24440  05F78H  0
 24444  05F7CH  010001CE0H
 24448  05F80H  6
 24452  05F84H  063617453H  "Stac"
 24456  05F88H  06172746BH  "ktra"
 24460  05F8CH  000006563H  "ce"
 24464  05F90H  0
 24468  05F94H  010001D90H
 24472  05F98H  7
 24476  05F9CH  072747865H  "extr"
 24480  05FA0H  045746361H  "actE"
 24484  05FA4H  0726F7272H  "rror"
 24488  05FA8H  000000000H
 24492  05FACH  010001E44H
 24496  05FB0H  8
 24500  05FB4H  072747865H  "extr"
 24504  05FB8H  046746361H  "actF"
 24508  05FBCH  0746C7561H  "ault"
 24512  05FC0H  000000000H
 24516  05FC4H  010001E9CH
 24520  05FC8H  9
 24524  05FCCH  064616572H  "read"
 24528  05FD0H  073676552H  "Regs"
 24532  05FD4H  0746C7500H
 24536  05FD8H  0
 24540  05FDCH  010001EB8H
 24544  05FE0H  10
 24548  05FE4H  063617274H  "trac"
 24552  05FE8H  061745365H  "eSta"
 24556  05FECH  074007472H  "rt"
 24560  05FF0H  0
 24564  05FF4H  010001F14H
 24568  05FF8H  11
 24572  05FFCH  063617473H  "stac"
 24576  06000H  06172466BH  "kFra"
 24580  06004H  06142656DH  "meBa"
 24584  06008H  000006573H  "se"
 24588  0600CH  010001F38H
 24592  06010H  12
 24596  06014H  06F727265H  "erro"
 24600  06018H  06E614872H  "rHan"
 24604  0601CH  072656C64H  "dler"
 24608  06020H  000006500H
 24612  06024H  010001F60H
 24616  06028H  13
 24620  0602CH  06C756166H  "faul"
 24624  06030H  06E614874H  "tHan"
 24628  06034H  072656C64H  "dler"
 24632  06038H  000006500H
 24636  0603CH  010002134H
 24640  06040H  14
 24644  06044H  048746553H  "SetH"
 24648  06048H  06C646E61H  "andl"
 24652  0604CH  072007265H  "er"
 24656  06050H  25856
 24660  06054H  0100022ACH
 24664  06058H  15
 24668  0605CH  048746553H  "SetH"
 24672  06060H  000746C61H  "alt"
 24676  06064H  072007265H  "er"
 24680  06068H  25856
 24684  0606CH  0100022C8H
 24688  06070H  16
 24692  06074H  053746553H  "SetS"
 24696  06078H  06B636174H  "tack"
 24700  0607CH  063617274H  "trac"
 24704  06080H  0006E4F65H  "eOn"
 24708  06084H  0100022E4H
 24712  06088H  17
 24716  0608CH  053746553H  "SetS"
 24720  06090H  06B636174H  "tack"
 24724  06094H  065526465H  "edRe"
 24728  06098H  0004F7367H  "gsO"
 24732  0609CH  010002308H
 24736  060A0H  18
 24740  060A4H  043746553H  "SetC"
 24744  060A8H  065727275H  "urre"
 24748  060ACH  06552746EH  "ntRe"
 24752  060B0H  0004F7367H  "gsO"
 24756  060B4H  01000232CH
 24760  060B8H  19
 24764  060BCH  074736E69H  "inst"
 24768  060C0H  0006C6C61H  "all"
 24772  060C4H  06552746EH  "ntRe"
 24776  060C8H  0004F7367H  "gsO"
 24780  060CCH  010002350H
 24784  060D0H  20
 24788  060D4H  04F64656CH  "ledO"
 24792  060D8H  0646E416EH  "nAnd"
 24796  060DCH  0746C6148H  "Halt"
 24800  060E0H  0004F7300H
 24804  060E4H  010002364H
 24808  060E8H  21
 24812  060ECH  074696E69H  "init"
 24816  060F0H  0646E4100H
 24820  060F4H  0746C6148H  "Halt"
 24824  060F8H  0004F7300H
 24828  060FCH  010002378H
 24832  06100H  22
 24836  06104H  0696E692EH  ".ini"
 24840  06108H  0646E0074H  "t"
 24844  0610CH  0746C6148H  "Halt"
 24848  06110H  0004F7300H
 24852  06114H  0100024F0H
 24856  06118H  0
 24860  0611CH  074786554H  "Text"
 24864  06120H  000004F49H  "IO"
 24868  06124H  0
 24872  06128H  0
 24876  0612CH  0100024FCH
 24880  06130H  1
 24884  06134H  06E65704FH  "Open"
 24888  06138H  074697257H  "Writ"
 24892  0613CH  000007265H  "er"
 24896  06140H  0
 24900  06144H  01000253CH
 24904  06148H  2
 24908  0614CH  074736E49H  "Inst"
 24912  06150H  0466C6C61H  "allF"
 24916  06154H  06873756CH  "lush"
 24920  06158H  00074754FH  "Out"
 24924  0615CH  010002560H
 24928  06160H  3
 24932  06164H  06E65704FH  "Open"
 24936  06168H  064616552H  "Read"
 24940  0616CH  068007265H  "er"
 24944  06170H  00074754FH  "Out"
 24948  06174H  010002578H
 24952  06178H  4
 24956  0617CH  0696E692EH  ".ini"
 24960  06180H  064610074H  "t"
 24964  06184H  068007265H  "er"
 24968  06188H  00074754FH  "Out"
 24972  0618CH  010002594H
 24976  06190H  0
 24980  06194H  074786554H  "Text"
 24984  06198H  000000073H  "s"
 24988  0619CH  0
 24992  061A0H  0
 24996  061A4H  010002598H
 25000  061A8H  1
 25004  061ACH  054746E49H  "IntT"
 25008  061B0H  07274536FH  "oStr"
 25012  061B4H  000676E69H  "ing"
 25016  061B8H  0
 25020  061BCH  0100025C0H
 25024  061C0H  2
 25028  061C4H  054746E49H  "IntT"
 25032  061C8H  07865486FH  "oHex"
 25036  061CCH  069727453H  "Stri"
 25040  061D0H  00000676EH  "ng"
 25044  061D4H  010002718H
 25048  061D8H  3
 25052  061DCH  054746E49H  "IntT"
 25056  061E0H  06E69426FH  "oBin"
 25060  061E4H  069727453H  "Stri"
 25064  061E8H  00000676EH  "ng"
 25068  061ECH  0100027F4H
 25072  061F0H  4
 25076  061F4H  074697257H  "Writ"
 25080  061F8H  06E690065H  "e"
 25084  061FCH  069727453H  "Stri"
 25088  06200H  00000676EH  "ng"
 25092  06204H  0100028B8H
 25096  06208H  5
 25100  0620CH  074697257H  "Writ"
 25104  06210H  072745365H  "eStr"
 25108  06214H  000676E69H  "ing"
 25112  06218H  26478
 25116  0621CH  0100028E8H
 25120  06220H  6
 25124  06224H  074697257H  "Writ"
 25128  06228H  0006E4C65H  "eLn"
 25132  0622CH  000676E69H  "ing"
 25136  06230H  26478
 25140  06234H  010002940H
 25144  06238H  7
 25148  0623CH  074697277H  "writ"
 25152  06240H  06D754E65H  "eNum"
 25156  06244H  069727453H  "Stri"
 25160  06248H  00000676EH  "ng"
 25164  0624CH  010002968H
 25168  06250H  8
 25172  06254H  074697257H  "Writ"
 25176  06258H  0746E4965H  "eInt"
 25180  0625CH  069727400H
 25184  06260H  26478
 25188  06264H  0100029CCH
 25192  06268H  9
 25196  0626CH  074697257H  "Writ"
 25200  06270H  078654865H  "eHex"
 25204  06274H  069727400H
 25208  06278H  26478
 25212  0627CH  0100029FCH
 25216  06280H  10
 25220  06284H  074697257H  "Writ"
 25224  06288H  06E694265H  "eBin"
 25228  0628CH  069727400H
 25232  06290H  26478
 25236  06294H  010002A2CH
 25240  06298H  11
 25244  0629CH  061656C63H  "clea"
 25248  062A0H  066654C6EH  "nLef"
 25252  062A4H  069720074H  "t"
 25256  062A8H  26478
 25260  062ACH  010002A5CH
 25264  062B0H  12
 25268  062B4H  061656C63H  "clea"
 25272  062B8H  06769526EH  "nRig"
 25276  062BCH  069007468H  "ht"
 25280  062C0H  26478
 25284  062C4H  010002B28H
 25288  062C8H  13
 25292  062CCH  054727453H  "StrT"
 25296  062D0H  0746E496FH  "oInt"
 25300  062D4H  069007400H
 25304  062D8H  26478
 25308  062DCH  010002B5CH
 25312  062E0H  14
 25316  062E4H  064616552H  "Read"
 25320  062E8H  069727453H  "Stri"
 25324  062ECH  06900676EH  "ng"
 25328  062F0H  26478
 25332  062F4H  010002C88H
 25336  062F8H  15
 25340  062FCH  064616552H  "Read"
 25344  06300H  000746E49H  "Int"
 25348  06304H  06900676EH  "ng"
 25352  06308H  26478
 25356  0630CH  010002CCCH
 25360  06310H  16
 25364  06314H  073756C46H  "Flus"
 25368  06318H  074754F68H  "hOut"
 25372  0631CH  069006700H
 25376  06320H  26478
 25380  06324H  010002D28H
 25384  06328H  17
 25388  0632CH  0696E692EH  ".ini"
 25392  06330H  074750074H  "t"
 25396  06334H  069006700H
 25400  06338H  26478
 25404  0633CH  010002D54H
 25408  06340H  0
 25412  06344H  044736552H  "ResD"
 25416  06348H  000617461H  "ata"
 25420  0634CH  0
 25424  06350H  0
 25428  06354H  010002D68H
 25432  06358H  1
 25436  0635CH  0657A6953H  "Size"
 25440  06360H  069747000H
 25444  06364H  000736E6FH  "ons"
 25448  06368H  0
 25452  0636CH  010002D94H
 25456  06370H  2
 25460  06374H  049746547H  "GetI"
 25464  06378H  06900746EH  "nt"
 25468  0637CH  000736E6FH  "ons"
 25472  06380H  0
 25476  06384H  010002DA0H
 25480  06388H  3
 25484  0638CH  042746547H  "GetB"
 25488  06390H  000657479H  "yte"
 25492  06394H  000736E6FH  "ons"
 25496  06398H  0
 25500  0639CH  010002DC4H
 25504  063A0H  4
 25508  063A4H  043746547H  "GetC"
 25512  063A8H  000726168H  "har"
 25516  063ACH  000736E6FH  "ons"
 25520  063B0H  0
 25524  063B4H  010002DE8H
 25528  063B8H  5
 25532  063BCH  049746547H  "GetI"
 25536  063C0H  07241746EH  "ntAr"
 25540  063C4H  000796172H  "ray"
 25544  063C8H  0
 25548  063CCH  010002E0CH
 25552  063D0H  6
 25556  063D4H  052746547H  "GetR"
 25560  063D8H  0006C6165H  "eal"
 25564  063DCH  000796172H  "ray"
 25568  063E0H  0
 25572  063E4H  010002E88H
 25576  063E8H  7
 25580  063ECH  052746547H  "GetR"
 25584  063F0H  0416C6165H  "ealA"
 25588  063F4H  079617272H  "rray"
 25592  063F8H  000000000H
 25596  063FCH  010002EACH
 25600  06400H  8
 25604  06404H  04E746547H  "GetN"
 25608  06408H  000656D61H  "ame"
 25612  0640CH  079617272H  "rray"
 25616  06410H  000000000H
 25620  06414H  010002F28H
 25624  06418H  9
 25628  0641CH  06E756F43H  "Coun"
 25632  06420H  000650074H  "t"
 25636  06424H  079617272H  "rray"
 25640  06428H  000000000H
 25644  0642CH  010002F94H
 25648  06430H  10
 25652  06434H  044746547H  "GetD"
 25656  06438H  063657269H  "irec"
 25660  0643CH  079726F74H  "tory"
 25664  06440H  000000000H
 25668  06444H  010002FE4H
 25672  06448H  11
 25676  0644CH  06E65704FH  "Open"
 25680  06450H  063657200H
 25684  06454H  079726F74H  "tory"
 25688  06458H  000000000H
 25692  0645CH  010003070H
 25696  06460H  12
 25700  06464H  0696E692EH  ".ini"
 25704  06468H  063650074H  "t"
 25708  0646CH  079726F74H  "tory"
 25712  06470H  000000000H
 25716  06474H  01000312CH
 25720  06478H  0
 25724  0647CH  0746E7552H  "Runt"
 25728  06480H  045656D69H  "imeE"
 25732  06484H  0726F7272H  "rror"
 25736  06488H  000754F73H  "sOu"
 25740  0648CH  010003130H
 25744  06490H  1
 25748  06494H  041746E69H  "intA"
 25752  06498H  079617272H  "rray"
 25756  0649CH  068436F54H  "ToCh"
 25760  064A0H  000737261H  "ars"
 25764  064A4H  010003134H
 25768  064A8H  2
 25772  064ACH  04E746547H  "GetN"
 25776  064B0H  000656D61H  "ame"
 25780  064B4H  068436F54H  "ToCh"
 25784  064B8H  000737261H  "ars"
 25788  064BCH  010003168H
 25792  064C0H  3
 25796  064C4H  06E697270H  "prin"
 25800  064C8H  061745374H  "tSta"
 25804  064CCH  072546B63H  "ckTr"
 25808  064D0H  000656361H  "ace"
 25812  064D4H  010003290H
 25816  064D8H  4
 25820  064DCH  04F676572H  "regO"
 25824  064E0H  061007475H  "ut"
 25828  064E4H  072546B63H  "ckTr"
 25832  064E8H  000656361H  "ace"
 25836  064ECH  0100034C4H
 25840  064F0H  5
 25844  064F4H  06E697270H  "prin"
 25848  064F8H  061745374H  "tSta"
 25852  064FCH  064656B63H  "cked"
 25856  06500H  000676552H  "Reg"
 25860  06504H  0100034FCH
 25864  06508H  6
 25868  0650CH  06E697270H  "prin"
 25872  06510H  072754374H  "tCur"
 25876  06514H  0746E6572H  "rent"
 25880  06518H  000676552H  "Reg"
 25884  0651CH  010003630H
 25888  06520H  7
 25892  06524H  06E697250H  "Prin"
 25896  06528H  063784574H  "tExc"
 25900  0652CH  069747065H  "epti"
 25904  06530H  000006E6FH  "on"
 25908  06534H  0100036D8H
 25912  06538H  8
 25916  0653CH  0646E6148H  "Hand"
 25920  06540H  07845656CH  "leEx"
 25924  06544H  074706563H  "cept"
 25928  06548H  0006E6F69H  "ion"
 25932  0654CH  010003900H
 25936  06550H  9
 25940  06554H  057746553H  "SetW"
 25944  06558H  065746972H  "rite"
 25948  0655CH  074700072H  "r"
 25952  06560H  0006E6F69H  "ion"
 25956  06564H  010003934H
 25960  06568H  10
 25964  0656CH  0696E692EH  ".ini"
 25968  06570H  065740074H  "t"
 25972  06574H  074700072H  "r"
 25976  06578H  0006E6F69H  "ion"
 25980  0657CH  01000395CH
 25984  06580H  0
 25988  06584H  054524155H  "UART"
 25992  06588H  000766564H  "dev"
 25996  0658CH  0
 26000  06590H  0
 26004  06594H  010003960H
 26008  06598H  1
 26012  0659CH  074696E49H  "Init"
 26016  065A0H  000004F00H
 26020  065A4H  0
 26024  065A8H  0
 26028  065ACH  01000398CH
 26032  065B0H  2
 26036  065B4H  0666E6F43H  "Conf"
 26040  065B8H  072756769H  "igur"
 26044  065BCH  000000065H  "e"
 26048  065C0H  0
 26052  065C4H  010003A6CH
 26056  065C8H  3
 26060  065CCH  062616E45H  "Enab"
 26064  065D0H  07200656CH  "le"
 26068  065D4H  101
 26072  065D8H  0
 26076  065DCH  010003C40H
 26080  065E0H  4
 26084  065E4H  061736944H  "Disa"
 26088  065E8H  000656C62H  "ble"
 26092  065ECH  101
 26096  065F0H  0
 26100  065F4H  010003C64H
 26104  065F8H  5
 26108  065FCH  067616C46H  "Flag"
 26112  06600H  000650073H  "s"
 26116  06604H  101
 26120  06608H  0
 26124  0660CH  010003C88H
 26128  06610H  6
 26132  06614H  042746547H  "GetB"
 26136  06618H  043657361H  "aseC"
 26140  0661CH  000006766H  "fg"
 26144  06620H  0
 26148  06624H  010003C9CH
 26152  06628H  7
 26156  0662CH  043746547H  "GetC"
 26160  06630H  065727275H  "urre"
 26164  06634H  06643746EH  "ntCf"
 26168  06638H  000000067H  "g"
 26172  0663CH  010003CB8H
 26176  06640H  8
 26180  06644H  046746553H  "SetF"
 26184  06648H  04C6F6669H  "ifoL"
 26188  0664CH  066006C76H  "vl"
 26192  06650H  103
 26196  06654H  010003D10H
 26200  06658H  9
 26204  0665CH  062616E45H  "Enab"
 26208  06660H  06E49656CH  "leIn"
 26212  06664H  066000074H  "t"
 26216  06668H  103
 26220  0666CH  010003D50H
 26224  06670H  10
 26228  06674H  061736944H  "Disa"
 26232  06678H  049656C62H  "bleI"
 26236  0667CH  06600746EH  "nt"
 26240  06680H  103
 26244  06684H  010003D64H
 26248  06688H  11
 26252  0668CH  045746547H  "GetE"
 26256  06690H  06C62616EH  "nabl"
 26260  06694H  06E496465H  "edIn"
 26264  06698H  000000074H  "t"
 26268  0669CH  010003D78H
 26272  066A0H  12
 26276  066A4H  049746547H  "GetI"
 26280  066A8H  07453746EH  "ntSt"
 26284  066ACH  073757461H  "atus"
 26288  066B0H  000000000H
 26292  066B4H  010003D88H
 26296  066B8H  13
 26300  066BCH  061656C43H  "Clea"
 26304  066C0H  0746E4972H  "rInt"
 26308  066C4H  073757400H
 26312  066C8H  0
 26316  066CCH  010003D98H
 26320  066D0H  14
 26324  066D4H  0696E692EH  ".ini"
 26328  066D8H  0746E0074H  "t"
 26332  066DCH  073757400H
 26336  066E0H  0
 26340  066E4H  010003DACH
 26344  066E8H  0
 26348  066ECH  06D726554H  "Term"
 26352  066F0H  06C616E69H  "inal"
 26356  066F4H  000000073H  "s"
 26360  066F8H  0
 26364  066FCH  010003DB0H
 26368  06700H  1
 26372  06704H  074696E49H  "Init"
 26376  06708H  054524155H  "UART"
 26380  0670CH  000000000H
 26384  06710H  0
 26388  06714H  010003DB4H
 26392  06718H  2
 26396  0671CH  06E65704FH  "Open"
 26400  06720H  054524100H
 26404  06724H  0
 26408  06728H  0
 26412  0672CH  010003E04H
 26416  06730H  3
 26420  06734H  0736F6C43H  "Clos"
 26424  06738H  054520065H  "e"
 26428  0673CH  0
 26432  06740H  0
 26436  06744H  010003EF4H
 26440  06748H  4
 26444  0674CH  06E65704FH  "Open"
 26448  06750H  000727245H  "Err"
 26452  06754H  0
 26456  06758H  0
 26460  0675CH  010003F2CH
 26464  06760H  5
 26468  06764H  0696E692EH  ".ini"
 26472  06768H  000720074H  "t"
 26476  0676CH  0
 26480  06770H  0
 26484  06774H  010003FE8H
 26488  06778H  0
 26492  0677CH  00074754FH  "Out"
 26496  06780H  0
 26500  06784H  0
 26504  06788H  0
 26508  0678CH  01000401CH
 26512  06790H  1
 26516  06794H  06E65704FH  "Open"
 26520  06798H  000000000H
 26524  0679CH  0
 26528  067A0H  0
 26532  067A4H  010004020H
 26536  067A8H  2
 26540  067ACH  072616843H  "Char"
 26544  067B0H  000000000H
 26548  067B4H  0
 26552  067B8H  0
 26556  067BCH  01000404CH
 26560  067C0H  3
 26564  067C4H  069727453H  "Stri"
 26568  067C8H  00000676EH  "ng"
 26572  067CCH  0
 26576  067D0H  0
 26580  067D4H  010004080H
 26584  067D8H  4
 26588  067DCH  069006E4CH  "Ln"
 26592  067E0H  26478
 26596  067E4H  0
 26600  067E8H  0
 26604  067ECH  0100040B4H
 26608  067F0H  5
 26612  067F4H  000746E49H  "Int"
 26616  067F8H  26478
 26620  067FCH  0
 26624  06800H  0
 26628  06804H  0100040E4H
 26632  06808H  6
 26636  0680CH  000786548H  "Hex"
 26640  06810H  26478
 26644  06814H  0
 26648  06818H  0
 26652  0681CH  010004118H
 26656  06820H  7
 26660  06824H  0006E6942H  "Bin"
 26664  06828H  26478
 26668  0682CH  0
 26672  06830H  0
 26676  06834H  01000414CH
 26680  06838H  8
 26684  0683CH  073756C46H  "Flus"
 26688  06840H  000000068H  "h"
 26692  06844H  0
 26696  06848H  0
 26700  0684CH  010004180H
 26704  06850H  9
 26708  06854H  0696E692EH  ".ini"
 26712  06858H  000000074H  "t"
 26716  0685CH  0
 26720  06860H  0
 26724  06864H  0100041B0H
 26728  06868H  0
 26732  0686CH  28233
 26736  06870H  0
 26740  06874H  0
 26744  06878H  0
 26748  0687CH  0100041C4H
 26752  06880H  1
 26756  06884H  06E65704FH  "Open"
 26760  06888H  000000000H
 26764  0688CH  0
 26768  06890H  0
 26772  06894H  0100041C8H
 26776  06898H  2
 26780  0689CH  069727453H  "Stri"
 26784  068A0H  00000676EH  "ng"
 26788  068A4H  0
 26792  068A8H  0
 26796  068ACH  0100041F4H
 26800  068B0H  3
 26804  068B4H  000746E49H  "Int"
 26808  068B8H  26478
 26812  068BCH  0
 26816  068C0H  0
 26820  068C4H  01000422CH
 26824  068C8H  4
 26828  068CCH  0696E692EH  ".ini"
 26832  068D0H  000000074H  "t"
 26836  068D4H  0
 26840  068D8H  0
 26844  068DCH  010004260H
 26848  068E0H  0
 26852  068E4H  054524155H  "UART"
 26856  068E8H  000727473H  "str"
 26860  068ECH  0
 26864  068F0H  0
 26868  068F4H  010004274H
 26872  068F8H  1
 26876  068FCH  043747550H  "PutC"
 26880  06900H  000726168H  "har"
 26884  06904H  0
 26888  06908H  0
 26892  0690CH  010004278H
 26896  06910H  2
 26900  06914H  053747550H  "PutS"
 26904  06918H  06E697274H  "trin"
 26908  0691CH  000000067H  "g"
 26912  06920H  0
 26916  06924H  0100042B0H
 26920  06928H  3
 26924  0692CH  043746547H  "GetC"
 26928  06930H  000726168H  "har"
 26932  06934H  103
 26936  06938H  0
 26940  0693CH  010004324H
 26944  06940H  4
 26948  06944H  053746547H  "GetS"
 26952  06948H  06E697274H  "trin"
 26956  0694CH  000000067H  "g"
 26960  06950H  0
 26964  06954H  01000435CH
 26968  06958H  5
 26972  0695CH  069766544H  "Devi"
 26976  06960H  074536563H  "ceSt"
 26980  06964H  073757461H  "atus"
 26984  06968H  000000000H
 26988  0696CH  010004434H
 26992  06970H  6
 26996  06974H  0696E692EH  ".ini"
 27000  06978H  074530074H  "t"
 27004  0697CH  073757461H  "atus"
 27008  06980H  000000000H
 27012  06984H  010004464H
 27016  06988H  0
 27020  0698CH  06E69614DH  "Main"
 27024  06990H  000000000H
 27028  06994H  0
 27032  06998H  0
 27036  0699CH  010004468H
 27040  069A0H  1
 27044  069A4H  0666E6F63H  "conf"
 27048  069A8H  069506769H  "igPi"
 27052  069ACH  07200736EH  "ns"
 27056  069B0H  000754F73H  "sOu"
 27060  069B4H  01000446CH
 27064  069B8H  2
 27068  069BCH  074696E69H  "init"
 27072  069C0H  069506700H
 27076  069C4H  07200736EH  "ns"
 27080  069C8H  000754F73H  "sOu"
 27084  069CCH  01000448CH
 27088  069D0H  3
 27092  069D4H  0696E692EH  ".ini"
 27096  069D8H  069500074H  "t"
 27100  069DCH  07200736EH  "ns"
 27104  069E0H  000754F73H  "sOu"
 27108  069E4H  01000458CH
 27112  069E8H  0
 27116  069ECH  06F726F43H  "Coro"
 27120  069F0H  06E697475H  "utin"
 27124  069F4H  000007365H  "es"
 27128  069F8H  0
 27132  069FCH  010004598H
 27136  06A00H  1
 27140  06A04H  065736552H  "Rese"
 27144  06A08H  000000074H  "t"
 27148  06A0CH  0
 27152  06A10H  0
 27156  06A14H  0100045B0H
 27160  06A18H  2
 27164  06A1CH  06F6C6C41H  "Allo"
 27168  06A20H  065746163H  "cate"
 27172  06A24H  000000000H
 27176  06A28H  0
 27180  06A2CH  01000461CH
 27184  06A30H  3
 27188  06A34H  074696E49H  "Init"
 27192  06A38H  065746100H
 27196  06A3CH  0
 27200  06A40H  0
 27204  06A44H  01000463CH
 27208  06A48H  4
 27212  06A4CH  06E617254H  "Tran"
 27216  06A50H  072656673H  "sfer"
 27220  06A54H  000000000H
 27224  06A58H  0
 27228  06A5CH  010004660H
 27232  06A60H  5
 27236  06A64H  0696E692EH  ".ini"
 27240  06A68H  072650074H  "t"
 27244  06A6CH  0
 27248  06A70H  0
 27252  06A74H  010004674H
 27256  06A78H  0
 27260  06A7CH  054737953H  "SysT"
 27264  06A80H  0006B6369H  "ick"
 27268  06A84H  0
 27272  06A88H  0
 27276  06A8CH  010004678H
 27280  06A90H  1
 27284  06A94H  06B636954H  "Tick"
 27288  06A98H  000000000H
 27292  06A9CH  0
 27296  06AA0H  0
 27300  06AA4H  01000467CH
 27304  06AA8H  2
 27308  06AACH  062616E45H  "Enab"
 27312  06AB0H  00000656CH  "le"
 27316  06AB4H  0
 27320  06AB8H  0
 27324  06ABCH  010004694H
 27328  06AC0H  3
 27332  06AC4H  074696E49H  "Init"
 27336  06AC8H  000006500H
 27340  06ACCH  0
 27344  06AD0H  0
 27348  06AD4H  0100046A4H
 27352  06AD8H  4
 27356  06ADCH  0696E692EH  ".ini"
 27360  06AE0H  000000074H  "t"
 27364  06AE4H  0
 27368  06AE8H  0
 27372  06AECH  0100046CCH
 27376  06AF0H  0
 27380  06AF4H  06E72654BH  "Kern"
 27384  06AF8H  000006C65H  "el"
 27388  06AFCH  0
 27392  06B00H  0
 27396  06B04H  0100046D0H
 27400  06B08H  1
 27404  06B0CH  0746F6C73H  "slot"
 27408  06B10H  000006E49H  "In"
 27412  06B14H  29541
 27416  06B18H  0
 27420  06B1CH  0100046FCH
 27424  06B20H  2
 27428  06B24H  06F6C6C41H  "Allo"
 27432  06B28H  065746163H  "cate"
 27436  06B2CH  000007300H
 27440  06B30H  0
 27444  06B34H  01000477CH
 27448  06B38H  3
 27452  06B3CH  06C616552H  "Real"
 27456  06B40H  061636F6CH  "loca"
 27460  06B44H  000006574H  "te"
 27464  06B48H  0
 27468  06B4CH  010004850H
 27472  06B50H  4
 27476  06B54H  062616E45H  "Enab"
 27480  06B58H  06100656CH  "le"
 27484  06B5CH  25972
 27488  06B60H  0
 27492  06B64H  010004894H
 27496  06B68H  5
 27500  06B6CH  050746553H  "SetP"
 27504  06B70H  0006F6972H  "rio"
 27508  06B74H  25972
 27512  06B78H  0
 27516  06B7CH  0100048ACH
 27520  06B80H  6
 27524  06B84H  050746553H  "SetP"
 27528  06B88H  06F697265H  "erio"
 27532  06B8CH  000000064H  "d"
 27536  06B90H  0
 27540  06B94H  0100048B8H
 27544  06B98H  7
 27548  06B9CH  07478654EH  "Next"
 27552  06BA0H  06F697200H
 27556  06BA4H  100
 27560  06BA8H  0
 27564  06BACH  0100048CCH
 27568  06BB0H  8
 27572  06BB4H  07478654EH  "Next"
 27576  06BB8H  075657551H  "Queu"
 27580  06BBCH  000006465H  "ed"
 27584  06BC0H  0
 27588  06BC4H  010004908H
 27592  06BC8H  9
 27596  06BCCH  070737553H  "Susp"
 27600  06BD0H  04D646E65H  "endM"
 27604  06BD4H  000000065H  "e"
 27608  06BD8H  0
 27612  06BDCH  010004934H
 27616  06BE0H  10
 27620  06BE4H  0616C6544H  "Dela"
 27624  06BE8H  000654D79H  "yMe"
 27628  06BECH  101
 27632  06BF0H  0
 27636  06BF4H  010004978H
 27640  06BF8H  11
 27644  06BFCH  072617453H  "Star"
 27648  06C00H  06D695474H  "tTim"
 27652  06C04H  074756F65H  "eout"
 27656  06C08H  000000000H
 27660  06C0CH  0100049BCH
 27664  06C10H  12
 27668  06C14H  0636E6143H  "Canc"
 27672  06C18H  069546C65H  "elTi"
 27676  06C1CH  0756F656DH  "meou"
 27680  06C20H  000000074H  "t"
 27684  06C24H  0100049ECH
 27688  06C28H  13
 27692  06C2CH  069617741H  "Awai"
 27696  06C30H  076654474H  "tDev"
 27700  06C34H  046656369H  "iceF"
 27704  06C38H  00067616CH  "lag"
 27708  06C3CH  0100049FCH
 27712  06C40H  14
 27716  06C44H  0636E6143H  "Canc"
 27720  06C48H  077416C65H  "elAw"
 27724  06C4CH  044746961H  "aitD"
 27728  06C50H  000697665H  "evi"
 27732  06C54H  010004A50H
 27736  06C58H  15
 27740  06C5CH  067697254H  "Trig"
 27744  06C60H  000726567H  "ger"
 27748  06C64H  044746961H  "aitD"
 27752  06C68H  000697665H  "evi"
 27756  06C6CH  010004A84H
 27760  06C70H  16
 27764  06C74H  06E616843H  "Chan"
 27768  06C78H  072506567H  "gePr"
 27772  06C7CH  044006F69H  "io"
 27776  06C80H  000697665H  "evi"
 27780  06C84H  010004AB0H
 27784  06C88H  17
 27788  06C8CH  06E616843H  "Chan"
 27792  06C90H  065506567H  "gePe"
 27796  06C94H  0646F6972H  "riod"
 27800  06C98H  000697600H
 27804  06C9CH  010004AE0H
 27808  06CA0H  18
 27812  06CA4H  06E007443H  "Ct"
 27816  06CA8H  065506567H  "gePe"
 27820  06CACH  0646F6972H  "riod"
 27824  06CB0H  000697600H
 27828  06CB4H  010004B1CH
 27832  06CB8H  19
 27836  06CBCH  000646954H  "Tid"
 27840  06CC0H  065506567H  "gePe"
 27844  06CC4H  0646F6972H  "riod"
 27848  06CC8H  000697600H
 27852  06CCCH  010004B48H
 27856  06CD0H  20
 27860  06CD4H  06F697250H  "Prio"
 27864  06CD8H  065506500H
 27868  06CDCH  0646F6972H  "riod"
 27872  06CE0H  000697600H
 27876  06CE4H  010004B74H
 27880  06CE8H  21
 27884  06CECH  0706F6F6CH  "loop"
 27888  06CF0H  065500063H  "c"
 27892  06CF4H  0646F6972H  "riod"
 27896  06CF8H  000697600H
 27900  06CFCH  010004B80H
 27904  06D00H  22
 27908  06D04H  0006E7552H  "Run"
 27912  06D08H  065500063H  "c"
 27916  06D0CH  0646F6972H  "riod"
 27920  06D10H  000697600H
 27924  06D14H  010004D88H
 27928  06D18H  23
 27932  06D1CH  074736E49H  "Inst"
 27936  06D20H  0006C6C61H  "all"
 27940  06D24H  0646F6972H  "riod"
 27944  06D28H  000697600H
 27948  06D2CH  010004DECH
 27952  06D30H  24
 27956  06D34H  0696E692EH  ".ini"
 27960  06D38H  0006C0074H  "t"
 27964  06D3CH  0646F6972H  "riod"
 27968  06D40H  000697600H
 27972  06D44H  010004FB4H
 27976  06D48H  0
 27980  06D4CH  06544454CH  "LEDe"
 27984  06D50H  000007478H  "xt"
 27988  06D54H  0
 27992  06D58H  0
 27996  06D5CH  010004FE4H
 28000  06D60H  1
 28004  06D64H  04C746553H  "SetL"
 28008  06D68H  069426465H  "edBi"
 28012  06D6CH  000007374H  "ts"
 28016  06D70H  0
 28020  06D74H  010004FE8H
 28024  06D78H  2
 28028  06D7CH  056746553H  "SetV"
 28032  06D80H  065756C61H  "alue"
 28036  06D84H  000007300H
 28040  06D88H  0
 28044  06D8CH  010005088H
 28048  06D90H  3
 28052  06D94H  074696E69H  "init"
 28056  06D98H  065756C00H
 28060  06D9CH  29440
 28064  06DA0H  0
 28068  06DA4H  01000509CH
 28072  06DA8H  4
 28076  06DACH  0696E692EH  ".ini"
 28080  06DB0H  065750074H  "t"
 28084  06DB4H  29440
 28088  06DB8H  0
 28092  06DBCH  010005144H
 28096  06DC0H  0
 28100  06DC4H  065637845H  "Exce"
 28104  06DC8H  06F697470H  "ptio"
 28108  06DCCH  00000736EH  "ns"
 28112  06DD0H  0
 28116  06DD4H  010005150H
 28120  06DD8H  1
 28124  06DDCH  062616E45H  "Enab"
 28128  06DE0H  06E49656CH  "leIn"
 28132  06DE4H  000000074H  "t"
 28136  06DE8H  0
 28140  06DECH  010005154H
 28144  06DF0H  2
 28148  06DF4H  045746547H  "GetE"
 28152  06DF8H  06C62616EH  "nabl"
 28156  06DFCH  06E496465H  "edIn"
 28160  06E00H  000000074H  "t"
 28164  06E04H  010005164H
 28168  06E08H  3
 28172  06E0CH  061736944H  "Disa"
 28176  06E10H  049656C62H  "bleI"
 28180  06E14H  06E00746EH  "nt"
 28184  06E18H  116
 28188  06E1CH  010005178H
 28192  06E20H  4
 28196  06E24H  050746553H  "SetP"
 28200  06E28H  069646E65H  "endi"
 28204  06E2CH  06E49676EH  "ngIn"
 28208  06E30H  000000074H  "t"
 28212  06E34H  010005188H
 28216  06E38H  5
 28220  06E3CH  050746547H  "GetP"
 28224  06E40H  069646E65H  "endi"
 28228  06E44H  06E49676EH  "ngIn"
 28232  06E48H  000000074H  "t"
 28236  06E4CH  010005198H
 28240  06E50H  6
 28244  06E54H  061656C43H  "Clea"
 28248  06E58H  06E655072H  "rPen"
 28252  06E5CH  0676E6964H  "ding"
 28256  06E60H  000746E49H  "Int"
 28260  06E64H  0100051ACH
 28264  06E68H  7
 28268  06E6CH  049746553H  "SetI"
 28272  06E70H  07250746EH  "ntPr"
 28276  06E74H  067006F69H  "io"
 28280  06E78H  000746E49H  "Int"
 28284  06E7CH  0100051BCH
 28288  06E80H  8
 28292  06E84H  049746547H  "GetI"
 28296  06E88H  07250746EH  "ntPr"
 28300  06E8CH  067006F69H  "io"
 28304  06E90H  000746E49H  "Int"
 28308  06E94H  0100051F4H
 28312  06E98H  9
 28316  06E9CH  074736E49H  "Inst"
 28320  06EA0H  0496C6C61H  "allI"
 28324  06EA4H  06148746EH  "ntHa"
 28328  06EA8H  0006C646EH  "ndl"
 28332  06EACH  010005214H
 28336  06EB0H  10
 28340  06EB4H  053746553H  "SetS"
 28344  06EB8H  078457379H  "ysEx"
 28348  06EBCH  069725063H  "cPri"
 28352  06EC0H  0006C006FH  "o"
 28356  06EC4H  010005240H
 28360  06EC8H  11
 28364  06ECCH  053746547H  "GetS"
 28368  06ED0H  078457379H  "ysEx"
 28372  06ED4H  069725063H  "cPri"
 28376  06ED8H  0006C006FH  "o"
 28380  06EDCH  01000528CH
 28384  06EE0H  12
 28388  06EE4H  074736E49H  "Inst"
 28392  06EE8H  0456C6C61H  "allE"
 28396  06EECH  061486378H  "xcHa"
 28400  06EF0H  0006C646EH  "ndl"
 28404  06EF4H  0100052C0H
 28408  06EF8H  13
 28412  06EFCH  04E746553H  "SetN"
 28416  06F00H  04500494DH  "MI"
 28420  06F04H  061486378H  "xcHa"
 28424  06F08H  0006C646EH  "ndl"
 28428  06F0CH  0100052E8H
 28432  06F10H  14
 28436  06F14H  0696E692EH  ".ini"
 28440  06F18H  045000074H  "t"
 28444  06F1CH  061486378H  "xcHa"
 28448  06F20H  0006C646EH  "ndl"
 28452  06F24H  01000533CH
 28456  06F28H  0
 28460  06F2CH  0656D6954H  "Time"
 28464  06F30H  000007372H  "rs"
 28468  06F34H  0
 28472  06F38H  0
 28476  06F3CH  010005340H
 28480  06F40H  1
 28484  06F44H  054746547H  "GetT"
 28488  06F48H  000656D69H  "ime"
 28492  06F4CH  29550
 28496  06F50H  0
 28500  06F54H  010005344H
 28504  06F58H  2
 28508  06F5CH  054746547H  "GetT"
 28512  06F60H  04C656D69H  "imeL"
 28516  06F64H  000007300H
 28520  06F68H  0
 28524  06F6CH  010005394H
 28528  06F70H  3
 28532  06F74H  074736E49H  "Inst"
 28536  06F78H  0416C6C61H  "allA"
 28540  06F7CH  06D72616CH  "larm"
 28544  06F80H  000746E49H  "Int"
 28548  06F84H  0100053A8H
 28552  06F88H  4
 28556  06F8CH  041746553H  "SetA"
 28560  06F90H  06D72616CH  "larm"
 28564  06F94H  050746E49H  "IntP"
 28568  06F98H  0006F6972H  "rio"
 28572  06F9CH  0100053BCH
 28576  06FA0H  5
 28580  06FA4H  062616E45H  "Enab"
 28584  06FA8H  06C41656CH  "leAl"
 28588  06FACH  0496D7261H  "armI"
 28592  06FB0H  00000746EH  "nt"
 28596  06FB4H  0100053D0H
 28600  06FB8H  6
 28604  06FBCH  073616544H  "Deas"
 28608  06FC0H  074726573H  "sert"
 28612  06FC4H  072616C41H  "Alar"
 28616  06FC8H  0006E496DH  "mIn"
 28620  06FCCH  0100053E8H
 28624  06FD0H  7
 28628  06FD4H  054746553H  "SetT"
 28632  06FD8H  000656D69H  "ime"
 28636  06FDCH  072616C41H  "Alar"
 28640  06FE0H  0006E496DH  "mIn"
 28644  06FE4H  010005400H
 28648  06FE8H  8
 28652  06FECH  0696E692EH  ".ini"
 28656  06FF0H  000650074H  "t"
 28660  06FF4H  072616C41H  "Alar"
 28664  06FF8H  0006E496DH  "mIn"
 28668  06FFCH  01000541CH
 28672  07000H  0
 28676  07004H  075626544H  "Debu"
 28680  07008H  061764567H  "gEva"
 28684  0700CH  0706D496CH  "lImp"
 28688  07010H  000000000H
 28692  07014H  010005420H
 28696  07018H  1
 28700  0701CH  0696E692EH  ".ini"
 28704  07020H  000000074H  "t"
 28708  07024H  0
 28712  07028H  0
 28716  0702CH  010005438H
 28720  07030H  0
 28724  07034H  075626544H  "Debu"
 28728  07038H  061764567H  "gEva"
 28732  0703CH  00000006CH  "l"
 28736  07040H  0
 28740  07044H  010005448H
 28744  07048H  1
 28748  0704CH  074697277H  "writ"
 28752  07050H  072685465H  "eThr"
 28756  07054H  049646165H  "eadI"
 28760  07058H  0006F666EH  "nfo"
 28764  0705CH  010005488H
 28768  07060H  2
 28772  07064H  074736574H  "test"
 28776  07068H  065707954H  "Type"
 28780  0706CH  049646100H
 28784  07070H  0006F666EH  "nfo"
 28788  07074H  0100054D0H
 28792  07078H  3
 28796  0707CH  000633074H  "t0c"
 28800  07080H  065707954H  "Type"
 28804  07084H  049646100H
 28808  07088H  0006F666EH  "nfo"
 28812  0708CH  0100054ECH
 28816  07090H  4
 28820  07094H  000633174H  "t1c"
 28824  07098H  065707954H  "Type"
 28828  0709CH  049646100H
 28832  070A0H  0006F666EH  "nfo"
 28836  070A4H  010005568H
 28840  070A8H  5
 28844  070ACH  0006E7572H  "run"
 28848  070B0H  065707954H  "Type"
 28852  070B4H  049646100H
 28856  070B8H  0006F666EH  "nfo"
 28860  070BCH  0100055D8H
 28864  070C0H  6
 28868  070C4H  0696E692EH  ".ini"
 28872  070C8H  065700074H  "t"
 28876  070CCH  049646100H
 28880  070D0H  0006F666EH  "nfo"
 28884  070D4H  010005688H
