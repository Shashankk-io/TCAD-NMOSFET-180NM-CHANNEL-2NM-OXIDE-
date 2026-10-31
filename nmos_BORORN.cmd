set Psub  3e18       ;# substrate Boron doping (cm-3)
set tox   2.0        ;# gate oxide thickness (nm)
set Dsd   5e15       ;# S/D Phosphorus dose (cm-2)
set Esd   0.125      ;# S/D implant energy (keV)  
set tdiff 0.125      ;# S/D anneal time (s)       
math coord.ucs
line x location= 0.0    spacing= 10.0<nm>  tag= SiTop
line x location= 50.0<nm> spacing= 50.0<nm>
line x location= 0.5<um>  spacing= 100.0<nm> tag= SiBottom
line y location= 0.0    spacing= 100.0<nm> tag= Mid
line y location= 0.80<um> spacing= 100.0<nm> tag= Right
region Silicon xlo= SiTop xhi= SiBottom ylo= Mid yhi= Right
init concentration= ${Psub}<cm-3> field= Boron
AdvancedCalibration
pdbSet Grid NativeLayerThickness 1e-7
pdbSet Oxide Grid perp.add.dist 1e-7
deposit material= {Oxide}       type= anisotropic thickness= ${tox}<nm>
deposit material= {PolySilicon} type= anisotropic time= 0.125 rate= {0.18}
mask name= gate_mask left= -1 right= 90<nm>
etch material= {PolySilicon} type= anisotropic time= 0.125 rate= {0.2} mask= gate_mask
etch material= {Oxide}       type= anisotropic time= 1     rate= {0.1}
struct tdr= nmos_1
refinebox Silicon min= {0.0 0.0} max= {0.2 0.8} xrefine= {0.05 0.05 0.05} yrefine= {0.005 0.005 0.005} add
refinebox Silicon min= {0.0 0.0} max= {0.01 0.2} xrefine= {0.001 0.002 0.005} yrefine= {0.005 0.005 0.005} add
grid remesh
implant Arsenic dose= ${Dsd}<cm-2> energy= ${Esd}<keV> tilt= 7<degree> rotation= 0<degree>
diffuse temperature= 1050<C> time= ${tdiff}<s>
struct tdr= nmos_2
deposit material= {Nitride} type= isotropic  time= 0.125 rate= {0.06}
etch    material= {Nitride} type= anisotropic time= 0.125 rate= {0.084}
struct tdr= nmos_3
deposit material= {Aluminum} type= isotropic time= 1 rate= {0.03}
mask name= contacts_mask left= 0.14<um> right= 0.7<um>
etch material= {Aluminum} type= anisotropic time= 1 rate= {0.25} mask= contacts_mask
struct tdr= nmos_4
transform reflect left
contact name= "body"   bottom Silicon
contact name= "source" box Aluminum    xlo= -0.04 xhi= 0.04 ylo= -0.8 yhi= -0.14
contact name= "drain"  box Aluminum    xlo= -0.04 xhi= 0.04 ylo=  0.14 yhi= 0.8
contact name= "gate"   box PolySilicon xlo= -0.3  xhi= 0.04 ylo= -0.6 yhi= 0.6
struct tdr= nmos_final ; # writes nmos_final_fps.tdr
exit
