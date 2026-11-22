v {xschem version=3.4.4 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {Compute cell (cim_cell): 1-bit weight, AND with activation x, switched 4-unit MIM capacitor} -260 -190 0 0 0.5 0.5 {}
C {devices/ipin.sym} -320 -40 0 0 {name=p1 lab=d}
C {devices/ipin.sym} -320 0 0 0 {name=p2 lab=wr}
C {devices/ipin.sym} -320 40 0 0 {name=p3 lab=wrb}
C {devices/ipin.sym} -320 80 0 0 {name=p4 lab=x}
C {devices/ipin.sym} -320 120 0 0 {name=p5 lab=sam}
C {devices/ipin.sym} -320 160 0 0 {name=p6 lab=samb}
C {devices/ipin.sym} -320 200 0 0 {name=p7 lab=shr}
C {devices/ipin.sym} -320 240 0 0 {name=p8 lab=shrb}
C {devices/opin.sym} -320 280 0 0 {name=p9 lab=q}
C {devices/iopin.sym} -320 320 0 0 {name=p10 lab=bus}
C {devices/iopin.sym} -320 360 0 0 {name=p11 lab=vp}
C {devices/iopin.sym} -320 400 0 0 {name=p12 lab=vn}
C {sky130_fd_pr/nfet_01v8.sym} 100 100 0 1 {name=Mwrn L=0.5 W=0.55 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_01v8.sym} 340 100 0 0 {name=Mwrp L=0.5 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 80 70 80 40 {}
N 80 40 360 40 {}
N 360 40 360 70 {}
N 80 130 80 160 {}
N 80 160 360 160 {}
N 360 160 360 130 {}
N 220 40 220 20 {}
C {devices/lab_pin.sym} 220 20 1 0 {name=l13 sig_type=std_logic lab=d}
N 220 160 220 180 {}
C {devices/lab_pin.sym} 220 180 3 0 {name=l14 sig_type=std_logic lab=hold}
N 120 100 140 100 {}
C {devices/lab_pin.sym} 140 100 0 1 {name=l15 sig_type=std_logic lab=wr}
N 320 100 300 100 {}
C {devices/lab_pin.sym} 300 100 0 0 {name=l16 sig_type=std_logic lab=wrb}
N 80 100 20 100 {}
C {devices/lab_pin.sym} 20 100 0 0 {name=l17 sig_type=std_logic lab=vn}
N 360 100 420 100 {}
C {devices/lab_pin.sym} 420 100 0 1 {name=l18 sig_type=std_logic lab=vp}
C {sky130_fd_pr/nfet_01v8.sym} 600 100 0 1 {name=Mfbn L=0.5 W=0.55 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_01v8.sym} 840 100 0 0 {name=Mfbp L=0.5 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 580 70 580 40 {}
N 580 40 860 40 {}
N 860 40 860 70 {}
N 580 130 580 160 {}
N 580 160 860 160 {}
N 860 160 860 130 {}
N 720 40 720 20 {}
C {devices/lab_pin.sym} 720 20 1 0 {name=l19 sig_type=std_logic lab=qs}
N 720 160 720 180 {}
C {devices/lab_pin.sym} 720 180 3 0 {name=l20 sig_type=std_logic lab=hold}
N 620 100 640 100 {}
C {devices/lab_pin.sym} 640 100 0 1 {name=l21 sig_type=std_logic lab=wrb}
N 820 100 800 100 {}
C {devices/lab_pin.sym} 800 100 0 0 {name=l22 sig_type=std_logic lab=wr}
N 580 100 520 100 {}
C {devices/lab_pin.sym} 520 100 0 0 {name=l23 sig_type=std_logic lab=vn}
N 860 100 920 100 {}
C {devices/lab_pin.sym} 920 100 0 1 {name=l24 sig_type=std_logic lab=vp}
C {sky130_fd_pr/pfet_01v8.sym} 1120 40 0 0 {name=Ml1p L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 1120 160 0 0 {name=Ml1n L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1140 70 1140 130 {}
N 1100 40 1080 40 {}
N 1080 40 1080 160 {}
N 1080 160 1100 160 {}
N 1080 100 1050 100 {}
C {devices/lab_pin.sym} 1050 100 0 0 {name=l25 sig_type=std_logic lab=hold}
N 1140 100 1190 100 {}
C {devices/lab_pin.sym} 1190 100 0 1 {name=l26 sig_type=std_logic lab=qb}
N 1140 10 1140 -10 {}
C {devices/lab_pin.sym} 1140 -10 1 0 {name=l27 sig_type=std_logic lab=vp}
N 1140 190 1140 210 {}
C {devices/lab_pin.sym} 1140 210 3 0 {name=l28 sig_type=std_logic lab=vn}
N 1140 40 1200 40 {}
C {devices/lab_pin.sym} 1200 40 0 1 {name=l29 sig_type=std_logic lab=vp}
N 1140 160 1200 160 {}
C {devices/lab_pin.sym} 1200 160 0 1 {name=l30 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 1400 40 0 0 {name=Ml2p L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 1400 160 0 0 {name=Ml2n L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1420 70 1420 130 {}
N 1380 40 1360 40 {}
N 1360 40 1360 160 {}
N 1360 160 1380 160 {}
N 1360 100 1330 100 {}
C {devices/lab_pin.sym} 1330 100 0 0 {name=l31 sig_type=std_logic lab=qb}
N 1420 100 1470 100 {}
C {devices/lab_pin.sym} 1470 100 0 1 {name=l32 sig_type=std_logic lab=qs}
N 1420 10 1420 -10 {}
C {devices/lab_pin.sym} 1420 -10 1 0 {name=l33 sig_type=std_logic lab=vp}
N 1420 190 1420 210 {}
C {devices/lab_pin.sym} 1420 210 3 0 {name=l34 sig_type=std_logic lab=vn}
N 1420 40 1480 40 {}
C {devices/lab_pin.sym} 1480 40 0 1 {name=l35 sig_type=std_logic lab=vp}
N 1420 160 1480 160 {}
C {devices/lab_pin.sym} 1480 160 0 1 {name=l36 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 1680 40 0 0 {name=Mr1p L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 1680 160 0 0 {name=Mr1n L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1700 70 1700 130 {}
N 1660 40 1640 40 {}
N 1640 40 1640 160 {}
N 1640 160 1660 160 {}
N 1640 100 1610 100 {}
C {devices/lab_pin.sym} 1610 100 0 0 {name=l37 sig_type=std_logic lab=qs}
N 1700 100 1750 100 {}
C {devices/lab_pin.sym} 1750 100 0 1 {name=l38 sig_type=std_logic lab=nbuf}
N 1700 10 1700 -10 {}
C {devices/lab_pin.sym} 1700 -10 1 0 {name=l39 sig_type=std_logic lab=vp}
N 1700 190 1700 210 {}
C {devices/lab_pin.sym} 1700 210 3 0 {name=l40 sig_type=std_logic lab=vn}
N 1700 40 1760 40 {}
C {devices/lab_pin.sym} 1760 40 0 1 {name=l41 sig_type=std_logic lab=vp}
N 1700 160 1760 160 {}
C {devices/lab_pin.sym} 1760 160 0 1 {name=l42 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 1960 40 0 0 {name=Mr2p L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 1960 160 0 0 {name=Mr2n L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1980 70 1980 130 {}
N 1940 40 1920 40 {}
N 1920 40 1920 160 {}
N 1920 160 1940 160 {}
N 1920 100 1890 100 {}
C {devices/lab_pin.sym} 1890 100 0 0 {name=l43 sig_type=std_logic lab=nbuf}
N 1980 100 2030 100 {}
C {devices/lab_pin.sym} 2030 100 0 1 {name=l44 sig_type=std_logic lab=q}
N 1980 10 1980 -10 {}
C {devices/lab_pin.sym} 1980 -10 1 0 {name=l45 sig_type=std_logic lab=vp}
N 1980 190 1980 210 {}
C {devices/lab_pin.sym} 1980 210 3 0 {name=l46 sig_type=std_logic lab=vn}
N 1980 40 2040 40 {}
C {devices/lab_pin.sym} 2040 40 0 1 {name=l47 sig_type=std_logic lab=vp}
N 1980 160 2040 160 {}
C {devices/lab_pin.sym} 2040 160 0 1 {name=l48 sig_type=std_logic lab=vn}
T {write TG (open while wr = 1)} 30 -90 0 0 0.3 0.3 {}
T {keeper TG (closes the loop while wr = 0)} 520 -90 0 0 0.3 0.3 {}
T {storage latch (hold / qb / qs)} 1060 -90 0 0 0.3 0.3 {}
T {read-back buffer: q = stored bit} 1620 -90 0 0 0.3 0.3 {}
C {sky130_fd_pr/pfet_01v8.sym} 100 620 0 0 {name=Mnd_pa L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_01v8.sym} 340 620 0 0 {name=Mnd_pb L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 220 770 0 0 {name=Mnd_na L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 220 880 0 0 {name=Mnd_nb L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 120 590 120 560 {}
N 120 560 360 560 {}
N 360 560 360 590 {}
N 240 560 240 540 {}
C {devices/lab_pin.sym} 240 540 1 0 {name=l49 sig_type=std_logic lab=vp}
N 120 650 120 680 {}
N 120 680 240 680 {}
N 240 680 360 680 {}
N 360 680 360 650 {}
N 360 680 480 680 {}
N 240 680 240 740 {}
N 240 800 240 850 {}
N 240 910 240 930 {}
C {devices/lab_pin.sym} 240 930 3 0 {name=l50 sig_type=std_logic lab=vn}
N 80 620 60 620 {}
C {devices/lab_pin.sym} 60 620 0 0 {name=l51 sig_type=std_logic lab=x}
N 320 620 300 620 {}
C {devices/lab_pin.sym} 300 620 0 0 {name=l52 sig_type=std_logic lab=q}
N 200 770 160 770 {}
C {devices/lab_pin.sym} 160 770 0 0 {name=l53 sig_type=std_logic lab=x}
N 200 880 160 880 {}
C {devices/lab_pin.sym} 160 880 0 0 {name=l54 sig_type=std_logic lab=q}
N 120 620 180 620 {}
C {devices/lab_pin.sym} 180 620 0 1 {name=l55 sig_type=std_logic lab=vp}
N 360 620 420 620 {}
C {devices/lab_pin.sym} 420 620 0 1 {name=l56 sig_type=std_logic lab=vp}
N 240 770 300 770 {}
C {devices/lab_pin.sym} 300 770 0 1 {name=l57 sig_type=std_logic lab=vn}
N 240 880 300 880 {}
C {devices/lab_pin.sym} 300 880 0 1 {name=l58 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 550 620 0 0 {name=Mandp L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 550 740 0 0 {name=Mandn L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 570 650 570 710 {}
N 530 620 510 620 {}
N 510 620 510 740 {}
N 510 740 530 740 {}
N 510 680 480 680 {}
C {devices/lab_pin.sym} 480 680 0 0 {name=l59 sig_type=std_logic lab=nand}
N 570 680 620 680 {}
C {devices/lab_pin.sym} 620 680 0 1 {name=l60 sig_type=std_logic lab=prod}
N 570 590 570 570 {}
C {devices/lab_pin.sym} 570 570 1 0 {name=l61 sig_type=std_logic lab=vp}
N 570 770 570 790 {}
C {devices/lab_pin.sym} 570 790 3 0 {name=l62 sig_type=std_logic lab=vn}
N 570 620 630 620 {}
C {devices/lab_pin.sym} 630 620 0 1 {name=l63 sig_type=std_logic lab=vp}
N 570 740 630 740 {}
C {devices/lab_pin.sym} 630 740 0 1 {name=l64 sig_type=std_logic lab=vn}
C {sky130_fd_pr/nfet_01v8.sym} 1000 680 0 1 {name=Msamn L=0.5 W=0.55 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_01v8.sym} 1240 680 0 0 {name=Msamp L=0.5 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 980 650 980 620 {}
N 980 620 1260 620 {}
N 1260 620 1260 650 {}
N 980 710 980 740 {}
N 980 740 1260 740 {}
N 1260 740 1260 710 {}
N 1120 620 1120 600 {}
C {devices/lab_pin.sym} 1120 600 1 0 {name=l65 sig_type=std_logic lab=prod}
N 1120 740 1120 760 {}
C {devices/lab_pin.sym} 1120 760 3 0 {name=l66 sig_type=std_logic lab=plate}
N 1020 680 1040 680 {}
C {devices/lab_pin.sym} 1040 680 0 1 {name=l67 sig_type=std_logic lab=sam}
N 1220 680 1200 680 {}
C {devices/lab_pin.sym} 1200 680 0 0 {name=l68 sig_type=std_logic lab=samb}
N 980 680 920 680 {}
C {devices/lab_pin.sym} 920 680 0 0 {name=l69 sig_type=std_logic lab=vn}
N 1260 680 1320 680 {}
C {devices/lab_pin.sym} 1320 680 0 1 {name=l70 sig_type=std_logic lab=vp}
C {sky130_fd_pr/nfet_01v8_lvt.sym} 1500 680 0 1 {name=Mshrn L=0.5 W=0.55 nf=1 mult=1 model=nfet_01v8_lvt spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_01v8_lvt.sym} 1740 680 0 0 {name=Mshrp L=0.5 W=1 nf=1 mult=1 model=pfet_01v8_lvt spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1480 650 1480 620 {}
N 1480 620 1760 620 {}
N 1760 620 1760 650 {}
N 1480 710 1480 740 {}
N 1480 740 1760 740 {}
N 1760 740 1760 710 {}
N 1620 620 1620 600 {}
C {devices/lab_pin.sym} 1620 600 1 0 {name=l71 sig_type=std_logic lab=plate}
N 1620 740 1620 760 {}
C {devices/lab_pin.sym} 1620 760 3 0 {name=l72 sig_type=std_logic lab=bus}
N 1520 680 1540 680 {}
C {devices/lab_pin.sym} 1540 680 0 1 {name=l73 sig_type=std_logic lab=shr}
N 1720 680 1700 680 {}
C {devices/lab_pin.sym} 1700 680 0 0 {name=l74 sig_type=std_logic lab=shrb}
N 1480 680 1420 680 {}
C {devices/lab_pin.sym} 1420 680 0 0 {name=l75 sig_type=std_logic lab=vn}
N 1760 680 1820 680 {}
C {devices/lab_pin.sym} 1820 680 0 1 {name=l76 sig_type=std_logic lab=vp}
C {sky130_fd_pr/cap_mim_m3_1.sym} 2000 680 0 0 {name=Cunit model=cap_mim_m3_1 W=5 L=5 MF=4 spiceprefix=X}
N 2000 650 2000 630 {}
C {devices/lab_pin.sym} 2000 630 1 0 {name=l77 sig_type=std_logic lab=plate}
N 2000 710 2000 730 {}
C {devices/lab_pin.sym} 2000 730 3 0 {name=l78 sig_type=std_logic lab=vn}
T {AND: NAND2 + inverter, prod = x AND q} 30 470 0 0 0.3 0.3 {}
T {sample TG (prod onto plate)} 930 470 0 0 0.3 0.3 {}
T {share TG, low-Vt (plate onto column bus)} 1420 470 0 0 0.3 0.3 {}
T {unit capacitor: 4 x MIM 5 um x 5 um} 1900 470 0 0 0.3 0.3 {}
