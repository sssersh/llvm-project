; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py UTC_ARGS: --version 5
; RUN: llc < %s -mtriple loongarch32 -mattr +d | FileCheck %s -check-prefixes=CHECK-32
; RUN: llc < %s -mtriple loongarch64 -mattr +d | FileCheck %s -check-prefixes=CHECK-64

declare dso_local void @main()

define dso_local void @naked() naked "frame-pointer"="all" {
; CHECK-32-LABEL: naked:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    bl main
;
; CHECK-64-LABEL: naked:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    pcaddu18i $ra, %call36(main)
; CHECK-64-NEXT:    jirl $ra, $ra, 0
  call void @main()
  unreachable
}

define dso_local void @normal() "frame-pointer"="all" {
; CHECK-32-LABEL: normal:
; CHECK-32:       # %bb.0:
; CHECK-32-NEXT:    addi.w $sp, $sp, -16
; CHECK-32-NEXT:    .cfi_def_cfa_offset 16
; CHECK-32-NEXT:    st.w $ra, $sp, 12 # 4-byte Folded Spill
; CHECK-32-NEXT:    st.w $fp, $sp, 8 # 4-byte Folded Spill
; CHECK-32-NEXT:    .cfi_offset 1, -4
; CHECK-32-NEXT:    .cfi_offset 22, -8
; CHECK-32-NEXT:    addi.w $fp, $sp, 16
; CHECK-32-NEXT:    .cfi_def_cfa 22, 0
; CHECK-32-NEXT:    bl main
;
; CHECK-64-LABEL: normal:
; CHECK-64:       # %bb.0:
; CHECK-64-NEXT:    addi.d $sp, $sp, -16
; CHECK-64-NEXT:    .cfi_def_cfa_offset 16
; CHECK-64-NEXT:    st.d $ra, $sp, 8 # 8-byte Folded Spill
; CHECK-64-NEXT:    st.d $fp, $sp, 0 # 8-byte Folded Spill
; CHECK-64-NEXT:    .cfi_offset 1, -8
; CHECK-64-NEXT:    .cfi_offset 22, -16
; CHECK-64-NEXT:    addi.d $fp, $sp, 16
; CHECK-64-NEXT:    .cfi_def_cfa 22, 0
; CHECK-64-NEXT:    pcaddu18i $ra, %call36(main)
; CHECK-64-NEXT:    jirl $ra, $ra, 0
  call void @main()
  unreachable
}
