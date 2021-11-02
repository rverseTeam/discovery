.arm.little
.open "code.bin","code_patched.bin",0x100000

load_cave_pem equ 0x1E3210
browser_cave_pem_string equ 0x1E3468

mount_content_cfa equ 0x1D7CF4
unmount_romfs equ 0x1D8058

mount_archives equ 0x1D7FD4
unmount_archives equ 0x1D80C8
mount_sd equ 0x1B2B20
unmount_archive equ 0x232748
sdmc_string equ 0x1D819C
discovery_string equ 0x15748C

add_default_cert_cave equ 0x176F28
add_default_cert_cave_end equ 0x176F90

// patch type to 1 (sdmc) instead of 5 (content:)
.org load_cave_pem + 0x14
mov r2, #1
.org browser_cave_pem_string
.ascii "3ds/rev.pem",0

.org discovery_string
.ascii "https://discovery.rverse.ml/miiverse/xml",0

// mount sdmc
.org mount_archives + 0x24
b mount_hook
// unmount sdmc
.org unmount_archives + 0x24
b unmount_hook

//sizeof max 26 instructions
//r0, r1, r4, r8
.org add_default_cert_cave

LDR r0, =0x00240082         // httpC:AddRootCA
MRC p15, 0, r4, c13, c0, 3  // TLS
LDR r1, [r5, #0xC]          // load HTTPC handle
LDR r8, [r5, #0x14]         // load httpC handle
STR r0, [r4, #0x80]!        // store cmdhdr in cmdbuf[0]
STR r1, [r4, #4]            // store HTTPC handle in cmdbuf[1]
MOV r0, r8                  // move httpC handle to r0 for SVC SendSyncRequest
LDR r8, =der_cert_end-der_cert_start
LDR r1, =der_cert_start
STR r8, [r4, #8]            // store cert size in cmdbuf[2]
STR r1, [r4, #16]           // store cert bufptr in cmdbuf[4]
MOV r8, r8, LSL #4          // size <<= 4
ORR r8, r8, #0xA            // size |= 0xA
STR r8, [r4, #12]           // store translate header in cmdbuf[3]
SWI 0x32                    // finally do the request
NOP                         // do whatever
B add_default_cert_cave_end // jump past the pool
.pool
NOP
NOP
NOP
// so much NOP

.org 0x3F79B0
der_cert_start:
.incbin "rootca.der"
der_cert_end:

.org 0x38E000 - 0x3D0
mount_hook:
stmfd sp!, {lr}
bl mount_content_cfa
ldr r0, =sdmc_string
ldmfd sp!, {lr}
b mount_sd

unmount_hook:
stmfd sp!, {lr}
bl unmount_romfs
ldr r0, =sdmc_string
ldmfd sp!, {lr}
b unmount_archive
.pool

.close
