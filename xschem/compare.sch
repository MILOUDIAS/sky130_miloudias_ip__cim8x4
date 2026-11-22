v {xschem version=3.4.4 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {Clocked comparator (compare): sum vs. replica reference, decision = 1 when sig > ref} -260 -190 0 0 0.5 0.5 {}
C {devices/ipin.sym} -200 -80 0 0 {name=p1 lab=sig}
C {devices/ipin.sym} -200 -40 0 0 {name=p2 lab=ref}
C {devices/ipin.sym} -200 0 0 0 {name=p3 lab=ev}
C {devices/opin.sym} -200 40 0 0 {name=p4 lab=decision}
C {devices/iopin.sym} -200 80 0 0 {name=p5 lab=vp}
C {devices/iopin.sym} -200 120 0 0 {name=p6 lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 300 0 0 0 {name=Mpl L=0.3 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_01v8.sym} 560 0 0 1 {name=Mpr L=0.3 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 300 120 0 0 {name=Mnl L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 560 120 0 1 {name=Mnr L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8_lvt.sym} 300 240 0 0 {name=Mis L=0.35 W=4 nf=1 mult=1 model=nfet_01v8_lvt spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8_lvt.sym} 560 240 0 1 {name=Mir L=0.35 W=4 nf=1 mult=1 model=nfet_01v8_lvt spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 410 350 0 0 {name=Mtail L=0.4 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 320 -30 320 -60 {}
N 540 -30 540 -60 {}
N 320 -60 540 -60 {}
C {devices/lab_pin.sym} 430 -60 1 0 {name=l7 sig_type=std_logic lab=vp}
N 320 30 320 90 {lab=ol}
N 540 30 540 90 {lab=oright}
N 320 150 320 210 {lab=ml}
N 540 150 540 210 {lab=mr}
N 320 270 320 300 {lab=tail}
N 320 300 540 300 {lab=tail}
N 540 300 540 270 {lab=tail}
N 430 320 430 300 {}
N 430 380 430 410 {}
C {devices/lab_pin.sym} 430 410 3 0 {name=l8 sig_type=std_logic lab=vn}
N 280 0 260 0 {}
N 260 0 260 120 {}
N 260 120 280 120 {}
N 260 60 540 60 {}
N 580 0 600 0 {}
N 600 0 600 120 {}
N 600 120 580 120 {}
N 600 80 320 80 {}
N 280 240 240 240 {}
C {devices/lab_pin.sym} 240 240 0 0 {name=l9 sig_type=std_logic lab=sig}
N 580 240 620 240 {}
C {devices/lab_pin.sym} 620 240 0 1 {name=l10 sig_type=std_logic lab=ref}
N 390 350 350 350 {}
C {devices/lab_pin.sym} 350 350 0 0 {name=l11 sig_type=std_logic lab=ev}
C {devices/lab_pin.sym} 320 50 0 0 {name=l12 sig_type=std_logic lab=ol}
C {devices/lab_pin.sym} 540 40 0 1 {name=l13 sig_type=std_logic lab=oright}
C {devices/lab_pin.sym} 320 180 0 0 {name=l14 sig_type=std_logic lab=ml}
C {devices/lab_pin.sym} 540 180 0 1 {name=l15 sig_type=std_logic lab=mr}
N 320 0 380 0 {}
C {devices/lab_pin.sym} 380 0 0 1 {name=l16 sig_type=std_logic lab=vp}
N 320 120 380 120 {}
C {devices/lab_pin.sym} 380 120 0 1 {name=l17 sig_type=std_logic lab=vn}
N 320 240 380 240 {}
C {devices/lab_pin.sym} 380 240 0 1 {name=l18 sig_type=std_logic lab=vn}
N 540 0 480 0 {}
C {devices/lab_pin.sym} 480 0 0 0 {name=l19 sig_type=std_logic lab=vp}
N 540 120 480 120 {}
C {devices/lab_pin.sym} 480 120 0 0 {name=l20 sig_type=std_logic lab=vn}
N 540 240 480 240 {}
C {devices/lab_pin.sym} 480 240 0 0 {name=l21 sig_type=std_logic lab=vn}
N 430 350 490 350 {}
C {devices/lab_pin.sym} 490 350 0 1 {name=l22 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 20 0 0 0 {name=Mrl L=0.15 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 40 -30 40 -50 {}
C {devices/lab_pin.sym} 40 -50 1 0 {name=l23 sig_type=std_logic lab=vp}
N 40 30 40 50 {}
C {devices/lab_pin.sym} 40 50 3 0 {name=l24 sig_type=std_logic lab=ol}
N 0 0 -20 0 {}
C {devices/lab_pin.sym} -20 0 0 0 {name=l25 sig_type=std_logic lab=ev}
N 40 0 100 0 {}
C {devices/lab_pin.sym} 100 0 0 1 {name=l26 sig_type=std_logic lab=vp}
C {sky130_fd_pr/pfet_01v8.sym} 20 240 0 0 {name=Mrml L=0.15 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 40 210 40 190 {}
C {devices/lab_pin.sym} 40 190 1 0 {name=l27 sig_type=std_logic lab=vp}
N 40 270 40 290 {}
C {devices/lab_pin.sym} 40 290 3 0 {name=l28 sig_type=std_logic lab=ml}
N 0 240 -20 240 {}
C {devices/lab_pin.sym} -20 240 0 0 {name=l29 sig_type=std_logic lab=ev}
N 40 240 100 240 {}
C {devices/lab_pin.sym} 100 240 0 1 {name=l30 sig_type=std_logic lab=vp}
C {sky130_fd_pr/pfet_01v8.sym} 840 0 0 1 {name=Mrr L=0.15 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 820 -30 820 -50 {}
C {devices/lab_pin.sym} 820 -50 1 0 {name=l31 sig_type=std_logic lab=vp}
N 820 30 820 50 {}
C {devices/lab_pin.sym} 820 50 3 0 {name=l32 sig_type=std_logic lab=oright}
N 860 0 880 0 {}
C {devices/lab_pin.sym} 880 0 0 1 {name=l33 sig_type=std_logic lab=ev}
N 820 0 760 0 {}
C {devices/lab_pin.sym} 760 0 0 0 {name=l34 sig_type=std_logic lab=vp}
C {sky130_fd_pr/pfet_01v8.sym} 840 240 0 1 {name=Mrmr L=0.15 W=1 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 820 210 820 190 {}
C {devices/lab_pin.sym} 820 190 1 0 {name=l35 sig_type=std_logic lab=vp}
N 820 270 820 290 {}
C {devices/lab_pin.sym} 820 290 3 0 {name=l36 sig_type=std_logic lab=mr}
N 860 240 880 240 {}
C {devices/lab_pin.sym} 880 240 0 1 {name=l37 sig_type=std_logic lab=ev}
N 820 240 760 240 {}
C {devices/lab_pin.sym} 760 240 0 0 {name=l38 sig_type=std_logic lab=vp}
T {precharge (ev low)} -40 -120 0 0 0.3 0.3 {}
T {precharge (ev low)} 760 -120 0 0 0.3 0.3 {}
C {sky130_fd_pr/cap_mim_m3_1.sym} 120 420 0 0 {name=Colcap model=cap_mim_m3_1 W=2 L=2 MF=1 spiceprefix=X}
N 120 390 120 370 {}
C {devices/lab_pin.sym} 120 370 1 0 {name=l39 sig_type=std_logic lab=ol}
N 120 450 120 470 {}
C {devices/lab_pin.sym} 120 470 3 0 {name=l40 sig_type=std_logic lab=vn}
C {sky130_fd_pr/cap_mim_m3_1.sym} 740 420 0 0 {name=Corcap model=cap_mim_m3_1 W=2 L=2 MF=1 spiceprefix=X}
N 740 390 740 370 {}
C {devices/lab_pin.sym} 740 370 1 0 {name=l41 sig_type=std_logic lab=oright}
N 740 450 740 470 {}
C {devices/lab_pin.sym} 740 470 3 0 {name=l42 sig_type=std_logic lab=vn}
T {MIM load on ol} 60 500 0 0 0.3 0.3 {}
T {MIM load on oright} 680 500 0 0 0.3 0.3 {}
C {sky130_fd_pr/pfet_01v8.sym} 1120 0 0 0 {name=Mbufp L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 1120 120 0 0 {name=Mbufn L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1140 30 1140 90 {}
N 1100 0 1080 0 {}
N 1080 0 1080 120 {}
N 1080 120 1100 120 {}
N 1080 60 1050 60 {}
C {devices/lab_pin.sym} 1050 60 0 0 {name=l43 sig_type=std_logic lab=ol}
N 1140 60 1190 60 {}
C {devices/lab_pin.sym} 1190 60 0 1 {name=l44 sig_type=std_logic lab=decision}
N 1140 -30 1140 -50 {}
C {devices/lab_pin.sym} 1140 -50 1 0 {name=l45 sig_type=std_logic lab=vp}
N 1140 150 1140 170 {}
C {devices/lab_pin.sym} 1140 170 3 0 {name=l46 sig_type=std_logic lab=vn}
N 1140 0 1200 0 {}
C {devices/lab_pin.sym} 1200 0 0 1 {name=l47 sig_type=std_logic lab=vp}
N 1140 120 1200 120 {}
C {devices/lab_pin.sym} 1200 120 0 1 {name=l48 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 1120 360 0 0 {name=Mdmyp L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 1120 480 0 0 {name=Mdmyn L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1140 390 1140 450 {}
N 1100 360 1080 360 {}
N 1080 360 1080 480 {}
N 1080 480 1100 480 {}
N 1080 420 1050 420 {}
C {devices/lab_pin.sym} 1050 420 0 0 {name=l49 sig_type=std_logic lab=oright}
N 1140 420 1190 420 {}
C {devices/lab_pin.sym} 1190 420 0 1 {name=l50 sig_type=std_logic lab=dummy}
N 1140 330 1140 310 {}
C {devices/lab_pin.sym} 1140 310 1 0 {name=l51 sig_type=std_logic lab=vp}
N 1140 510 1140 530 {}
C {devices/lab_pin.sym} 1140 530 3 0 {name=l52 sig_type=std_logic lab=vn}
N 1140 360 1200 360 {}
C {devices/lab_pin.sym} 1200 360 0 1 {name=l53 sig_type=std_logic lab=vp}
N 1140 480 1200 480 {}
C {devices/lab_pin.sym} 1200 480 0 1 {name=l54 sig_type=std_logic lab=vn}
T {output buffer} 1060 -120 0 0 0.3 0.3 {}
T {dummy load (balances ol and oright)} 1060 240 0 0 0.3 0.3 {}
