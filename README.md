# Mašīnorientētā programmēšana (MOP)

LU DF bakalaura studiju kurss [DatZ4017](https://luis.lu.lv/pls/pub/kursi.kurss_dati?l=1&p_kods=2DAT4074), [meklēt eStudijās](http://estudijas.lu.lv/course/search.php?search=DatZ4017).

- **Pasniedzējs**: Leo Seļāvo
- **Komunikācija ar pasniedzēju**: kursa forums, e-pasts vai iepriekš saskaņota klātienes tikšanās.

### Kursa mērķis

Kursa mērķis ir iepazīstināt ar zema līmeņa programmēšanu Asemblerā, lietojot ARM platformu kā izstrādes vidi. Kursā tiek skaidrots, kā darbojas procesors un cita aparatūra, kā veidot saskarni starp Asembleru un augstāka līmeņa programmām, t.sk. C valodu.

[Kursa atsauksmes](http://selavo.lv/wiki/index.php/MOP-m_kursa_atsauksmes_2013 "MOP-m kursa atsauksmes 2013").

### Vērtējums

Gala vērtējums kursā veidosies no sekojošiem faktoriem:

- **Dalība kursā**: jautājumi, atbildes, diskusijas.
- **15%** - mazie kontroldarbi (Q: 1+3+3+8)
- **35%** - mājas darbi (HW: 15+20)
- **25%** - semestra vidus kontroldarbs (MT1)
- **25%** - eksāmens (EX). Eksāmena forma: kursa projekts vai rakstisks.

Lai saņemtu sekmīgu vērtējumu, jāsavāc vismaz 40% kopā par visiem kursa darbiem un jānoliek eksāmens ar vērtējumu vismaz 40%.

### Akadēmiskā goda sistēma

[Akadēmiskā goda sistēma](http://selavo.lv/wiki/index.php/Akad%C4%93misk%C4%81_goda_sist%C4%93ma) - noteikumi, kuriem studentiem jāpiekrīt, lai varētu piedalīties kursā.

### Pārbaudījumi

Tipiskas kļūdas pārbaudījumu laikā:

- Izvadīt tikai rezultātu (piem., "17" nevis "summa=17").
- Uzdevumu iesniedzamo direktoriju vārdi ir "case sensitive".
- Programmas jātestē uz kursa servera.
- Kompilējot programmas, jālieto XScale arhitektūra.

### Mazie kontroldarbi (Q1, Q2, Q3)

- **Q1**: Skaitļu formāti un pārveidošana (decimālā, heksadecimālā, oktālā, binārā).
- **Q2**: Skaitļi ar zīmi, divnieka papildkodā, to pārveidošana.
- **Q3**: Asemblera pirmkoda lasīšana un izpratne.

### Mājas darbi

- **HW0**: Pieslēgties kursa serverim, izveidot direktoriju `md0` un failu `out.txt`.
- **[HW1: Aritmētiskās progresijas summa](http://selavo.lv/wiki/index.php/LU-MOP-MD1)**
- **[HW2: Matricu reizināšana](http://selavo.lv/wiki/index.php/LU-MOP-MD2)**

### Kursa projekts

- [Grafiskā bibliotēka](http://selavo.lv/wiki/index.php/LU-MOP-KP).

### Literatūra

#### Makefile

- [A simple Makefile tutorial](https://www.cs.colby.edu/maxwell/courses/tutorials/maketutor/)
- [Embedded Programming using the GNU Toolchain](http://www.bravegnu.org/gnu-eprog/)
- [GNU Make rokasgrāmata](https://www.gnu.org/software/make/manual/)

#### GDB

- [GDB getting started tutorial](https://developers.redhat.com/blog/2021/04/30/the-gdb-developers-gnu-debugger-tutorial-part-1-getting-started-with-the-debugger)
- [GDB pamācība](https://www.cs.umd.edu/~srhuang/teaching/cmsc212/gdb-tutorial-handout.pdf)
- [GDB komandu īsais apraksts](http://web.cecs.pdx.edu/~jrb/cs201/lectures/handouts/gdbcomm.txt)
- [GDB rokasgrāmata](http://www.gnu.org/software/gdb/documentation/)

#### Asemblers

- [The "gas" manual](http://sourceware.org/binutils/docs/as/index.html)
- [ARM assembler in Raspberry Pi](https://thinkingeek.com/arm-assembler-raspberry-pi/)
- [ARM Assembly Language Programming (AALP)](http://www.peter-cockerell.net/aalp/html/frames.html)

#### ARM

- [ARM instruction set quick reference](http://pages.cs.wisc.edu/~markhill/restricted/arm_isa_quick_reference.pdf)
- [A32 instruction summary](https://developer.arm.com/documentation/100076/0100/a32-t32-instruction-set-reference/a32-and-t32-instructions/a32-and-t32-instruction-summary?lang=en)
- [Application Binary Interface (ABI)](https://developer.arm.com/architectures/system-architectures/software-standards/abi)
- [ARM A32 instruction set](https://developer.arm.com/architectures/instruction-sets/base-isas/a32)
- [ARM Architecture Reference Manual (PDF)](http://www.altera.com/literature/third-party/archives/ddi0100e_arm_arm.pdf)

#### Xscale

- [Intel XScale Microarchitecture Assembly Language Quick Reference Card](http://download.intel.com/design/intelxscale/27347302.pdf)

### Grāmatas un citi resursi

- Patterson and Hennessy, Computer Organization and Design, 4th Edition [@Amazon](http://www.amazon.com/Computer-Organization-Design-Fourth-Architecture/dp/0123744938)
- "Building Embedded Linux Systems" O'Reilly Media, 2008, ISBN 0596529686

### Pamācības

- [Kā uzstādīt ARM qemu un gdb](http://selavo.lv/wiki/index.php/Arm-linux-gnueabi-gcc_un_qemu-arm)
- [Kā lietot atkļūmotāju gdb ar qemu](http://selavo.lv/wiki/index.php/GDB_ar_QUEMU)

### Saites

- [Noderīgas Linux komandas](http://selavo.lv/wiki/index.php/Linux_komandas)
- [Easy 6502](https://skilldrick.github.io/easy6502/) assembly tutorial
- [The ARM Architecture](http://www.arm.com/files/pdf/ARM_Arch_A8.pdf)
- [Introduction to ARM](http://www.davespace.co.uk/arm/introduction-to-arm/index.html)
- [Linaro](http://www.linaro.org/) - Open source software for ARM SoCs.
- [Goldbolt.org](https://godbolt.org/) - Compiler explorer

### Dažādi

- [Pentium FOOF bug](https://en.wikipedia.org/wiki/Pentium_F00F_bug)
- [Spēļu programmēšana 8 bitu arhitektūrā](https://youtu.be/TPbroUDHG0s)

### Atziņas

- [Teach yourself programming in 10 years](http://norvig.com/21-days.html) by Peter Norvig
- [Should I learn assembly language to program a microcontroller?](https://qr.ae/pGBj0b) - Answer on Quora by software R&D professional with 40 years of experience.

