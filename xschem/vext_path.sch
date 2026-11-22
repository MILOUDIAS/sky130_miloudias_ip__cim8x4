v {xschem version=3.4.4 file_version=1.2}
G {}
K {}
V {}
S {}
E {}
T {VEXT test-input path (vext_path): pad switch, clamps and per-column reference switch} -260 -190 0 0 0.5 0.5 {}
C {devices/ipin.sym} -320 -40 0 0 {name=p1 lab=vext}
C {devices/ipin.sym} -320 0 0 0 {name=p2 lab=vsel}
C {devices/ipin.sym} -320 40 0 0 {name=p3 lab=vg}
C {devices/iopin.sym} -320 80 0 0 {name=p4 lab=ref}
C {devices/iopin.sym} -320 120 0 0 {name=p5 lab=sum}
C {devices/iopin.sym} -320 160 0 0 {name=p6 lab=vpa}
C {devices/iopin.sym} -320 200 0 0 {name=p7 lab=vp}
C {devices/iopin.sym} -320 240 0 0 {name=p8 lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 100 110 0 0 {name=Mls1ip L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 100 230 0 0 {name=Mls1in L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 120 140 120 200 {}
N 80 110 60 110 {}
N 60 110 60 230 {}
N 60 230 80 230 {}
N 60 170 30 170 {}
C {devices/lab_pin.sym} 30 170 0 0 {name=l9 sig_type=std_logic lab=vsel}
N 120 170 170 170 {}
C {devices/lab_pin.sym} 170 170 0 1 {name=l10 sig_type=std_logic lab=vsel_b}
N 120 80 120 60 {}
C {devices/lab_pin.sym} 120 60 1 0 {name=l11 sig_type=std_logic lab=vp}
N 120 260 120 280 {}
C {devices/lab_pin.sym} 120 280 3 0 {name=l12 sig_type=std_logic lab=vn}
N 120 110 180 110 {}
C {devices/lab_pin.sym} 180 110 0 1 {name=l13 sig_type=std_logic lab=vp}
N 120 230 180 230 {}
C {devices/lab_pin.sym} 180 230 0 1 {name=l14 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 420 100 0 0 {name=Mls1p1 L=1 W=0.42 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 720 100 0 1 {name=Mls1p2 L=1 W=0.42 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 420 240 0 0 {name=Mls1n1 L=0.5 W=2 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 720 240 0 1 {name=Mls1n2 L=0.5 W=2 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 440 70 440 40 {}
N 440 40 700 40 {}
N 700 40 700 70 {}
N 570 40 570 20 {}
C {devices/lab_pin.sym} 570 20 1 0 {name=l15 sig_type=std_logic lab=vpa}
N 440 270 440 300 {}
N 440 300 700 300 {}
N 700 300 700 270 {}
N 570 300 570 320 {}
C {devices/lab_pin.sym} 570 320 3 0 {name=l16 sig_type=std_logic lab=vn}
N 440 130 440 210 {}
N 700 130 700 210 {}
N 400 100 320 100 {}
N 320 100 320 170 {}
N 320 170 700 170 {}
N 740 100 840 100 {}
N 840 100 840 190 {}
N 840 190 440 190 {}
C {devices/lab_pin.sym} 440 145 0 0 {name=l17 sig_type=std_logic lab=vsel_hb}
C {devices/lab_pin.sym} 700 145 0 1 {name=l18 sig_type=std_logic lab=vsel_h}
N 400 240 360 240 {}
C {devices/lab_pin.sym} 360 240 0 0 {name=l19 sig_type=std_logic lab=vsel}
N 740 240 780 240 {}
C {devices/lab_pin.sym} 780 240 0 1 {name=l20 sig_type=std_logic lab=vsel_b}
N 440 100 500 100 {}
C {devices/lab_pin.sym} 500 100 0 1 {name=l21 sig_type=std_logic lab=vpa}
N 700 100 640 100 {}
C {devices/lab_pin.sym} 640 100 0 0 {name=l22 sig_type=std_logic lab=vpa}
N 440 240 500 240 {}
C {devices/lab_pin.sym} 500 240 0 1 {name=l23 sig_type=std_logic lab=vn}
N 700 240 640 240 {}
C {devices/lab_pin.sym} 640 240 0 0 {name=l24 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_01v8.sym} 100 570 0 0 {name=Mls2ip L=0.15 W=2 nf=1 mult=1 model=pfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_01v8.sym} 100 690 0 0 {name=Mls2in L=0.15 W=1 nf=1 mult=1 model=nfet_01v8 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 120 600 120 660 {}
N 80 570 60 570 {}
N 60 570 60 690 {}
N 60 690 80 690 {}
N 60 630 30 630 {}
C {devices/lab_pin.sym} 30 630 0 0 {name=l25 sig_type=std_logic lab=vg}
N 120 630 170 630 {}
C {devices/lab_pin.sym} 170 630 0 1 {name=l26 sig_type=std_logic lab=vg_b}
N 120 540 120 520 {}
C {devices/lab_pin.sym} 120 520 1 0 {name=l27 sig_type=std_logic lab=vp}
N 120 720 120 740 {}
C {devices/lab_pin.sym} 120 740 3 0 {name=l28 sig_type=std_logic lab=vn}
N 120 570 180 570 {}
C {devices/lab_pin.sym} 180 570 0 1 {name=l29 sig_type=std_logic lab=vp}
N 120 690 180 690 {}
C {devices/lab_pin.sym} 180 690 0 1 {name=l30 sig_type=std_logic lab=vn}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 420 560 0 0 {name=Mls2p1 L=1 W=0.42 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 720 560 0 1 {name=Mls2p2 L=1 W=0.42 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 420 700 0 0 {name=Mls2n1 L=0.5 W=2 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 720 700 0 1 {name=Mls2n2 L=0.5 W=2 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 440 530 440 500 {}
N 440 500 700 500 {}
N 700 500 700 530 {}
N 570 500 570 480 {}
C {devices/lab_pin.sym} 570 480 1 0 {name=l31 sig_type=std_logic lab=vpa}
N 440 730 440 760 {}
N 440 760 700 760 {}
N 700 760 700 730 {}
N 570 760 570 780 {}
C {devices/lab_pin.sym} 570 780 3 0 {name=l32 sig_type=std_logic lab=vn}
N 440 590 440 670 {}
N 700 590 700 670 {}
N 400 560 320 560 {}
N 320 560 320 630 {}
N 320 630 700 630 {}
N 740 560 840 560 {}
N 840 560 840 650 {}
N 840 650 440 650 {}
C {devices/lab_pin.sym} 440 605 0 0 {name=l33 sig_type=std_logic lab=vg_hb}
C {devices/lab_pin.sym} 700 605 0 1 {name=l34 sig_type=std_logic lab=vg_h}
N 400 700 360 700 {}
C {devices/lab_pin.sym} 360 700 0 0 {name=l35 sig_type=std_logic lab=vg}
N 740 700 780 700 {}
C {devices/lab_pin.sym} 780 700 0 1 {name=l36 sig_type=std_logic lab=vg_b}
N 440 560 500 560 {}
C {devices/lab_pin.sym} 500 560 0 1 {name=l37 sig_type=std_logic lab=vpa}
N 700 560 640 560 {}
C {devices/lab_pin.sym} 640 560 0 0 {name=l38 sig_type=std_logic lab=vpa}
N 440 700 500 700 {}
C {devices/lab_pin.sym} 500 700 0 1 {name=l39 sig_type=std_logic lab=vn}
N 700 700 640 700 {}
C {devices/lab_pin.sym} 640 700 0 0 {name=l40 sig_type=std_logic lab=vn}
T {level shifter: vsel (1.8 V) to vsel_h / vsel_hb (VDDA 3.3 V)} 30 -90 0 0 0.3 0.3 {}
T {level shifter: vg to vg_h (vg_hb unused)} 30 370 0 0 0.3 0.3 {}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 1200 100 0 1 {name=Mpadn L=0.5 W=10 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
C {sky130_fd_pr/pfet_g5v0d10v5.sym} 1440 100 0 0 {name=Mpadp L=0.5 W=10 nf=1 mult=1 model=pfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1180 70 1180 40 {}
N 1180 40 1460 40 {}
N 1460 40 1460 70 {}
N 1180 130 1180 160 {}
N 1180 160 1460 160 {}
N 1460 160 1460 130 {}
N 1320 40 1320 20 {}
C {devices/lab_pin.sym} 1320 20 1 0 {name=l41 sig_type=std_logic lab=vext}
N 1220 100 1240 100 {}
C {devices/lab_pin.sym} 1240 100 0 1 {name=l42 sig_type=std_logic lab=vsel_h}
N 1420 100 1400 100 {}
C {devices/lab_pin.sym} 1400 100 0 0 {name=l43 sig_type=std_logic lab=vsel_hb}
N 1180 100 1120 100 {}
C {devices/lab_pin.sym} 1120 100 0 0 {name=l44 sig_type=std_logic lab=vn}
N 1460 100 1520 100 {}
C {devices/lab_pin.sym} 1520 100 0 1 {name=l45 sig_type=std_logic lab=vpa}
C {sky130_fd_pr/res_high_po_0p35.sym} 1320 260 0 0 {name=Rser W=0.35 L=1 model=res_high_po_0p35 spiceprefix=X mult=1}
N 1320 160 1320 230 {}
N 1300 260 1260 260 {}
C {devices/lab_pin.sym} 1260 260 0 0 {name=l46 sig_type=std_logic lab=vn}
N 1320 290 1320 370 {}
N 1320 370 1460 370 {}
N 1460 370 1580 370 {}
N 1580 370 1840 370 {}
C {sky130_fd_pr/diode.sym} 1460 340 0 0 {name=Dclamp_p model=diode_pd2nw_05v5 area="4e12 pj=8e6"}
C {sky130_fd_pr/diode.sym} 1580 400 0 0 {name=Dclamp_n model=diode_pw2nd_05v5 area="4e12 pj=8e6"}
N 1460 310 1460 290 {}
C {devices/lab_pin.sym} 1460 290 1 0 {name=l47 sig_type=std_logic lab=vp}
N 1580 430 1580 450 {}
C {devices/lab_pin.sym} 1580 450 3 0 {name=l48 sig_type=std_logic lab=vn}
C {devices/lab_pin.sym} 1320 330 0 0 {name=l49 sig_type=std_logic lab=vxi}
T {pad switch: 5 V TG, on while vsel = 1} 1130 -90 0 0 0.3 0.3 {}
T {series R (res_high_po_0p35)} 1360 220 0 0 0.3 0.3 {}
T {clamps to vp / vn} 1430 490 0 0 0.3 0.3 {}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 1820 400 0 0 {name=Mvx_ref L=0.5 W=4 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 1800 400 1760 400 {}
C {devices/lab_pin.sym} 1760 400 0 0 {name=l50 sig_type=std_logic lab=vg_h}
N 1840 430 1840 450 {}
C {devices/lab_pin.sym} 1840 450 3 0 {name=l51 sig_type=std_logic lab=ref}
N 1840 400 1900 400 {}
C {devices/lab_pin.sym} 1900 400 0 1 {name=l52 sig_type=std_logic lab=vn}
C {sky130_fd_pr/nfet_g5v0d10v5.sym} 2120 400 0 0 {name=Mvx_sum L=0.5 W=4 nf=1 mult=1 model=nfet_g5v0d10v5 spiceprefix=X ad="'int((nf+1)/2) * W/nf * 0.29'" pd="'2*int((nf+1)/2) * (W/nf + 0.29)'" as="'int((nf+2)/2) * W/nf * 0.29'" ps="'2*int((nf+2)/2) * (W/nf + 0.29)'" nrd=0 nrs=0 sa=0 sb=0 sd=0}
N 2140 370 2140 350 {}
C {devices/lab_pin.sym} 2140 350 1 0 {name=l53 sig_type=std_logic lab=vn}
N 2100 400 2060 400 {}
C {devices/lab_pin.sym} 2060 400 0 0 {name=l54 sig_type=std_logic lab=vn}
N 2140 430 2140 450 {}
C {devices/lab_pin.sym} 2140 450 3 0 {name=l55 sig_type=std_logic lab=sum}
N 2140 400 2200 400 {}
C {devices/lab_pin.sym} 2200 400 0 1 {name=l56 sig_type=std_logic lab=vn}
T {reference switch (one per column)} 1740 510 0 0 0.3 0.3 {}
T {dummy on sum (always off)} 2040 510 0 0 0.3 0.3 {}
