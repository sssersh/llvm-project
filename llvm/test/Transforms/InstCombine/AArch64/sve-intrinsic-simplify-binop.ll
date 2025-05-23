; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S -passes=instcombine < %s | FileCheck %s

target triple = "aarch64-unknown-linux-gnu"

; The follow tests verify the mechanics of simplification. The operation is not
; important beyond being commutative with a known identity value.

define <vscale x 4 x i32> @commute_constant_to_rhs(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @commute_constant_to_rhs(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[R:%.*]] = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1> [[PG]], <vscale x 4 x i32> [[A]], <vscale x 4 x i32> splat (i32 303))
; CHECK-NEXT:    ret <vscale x 4 x i32> [[R]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> splat (i32 303), <vscale x 4 x i32> %a)
  ret <vscale x 4 x i32> %r
}

; Inactive lanes are important, which make the operation non-commutative.
define <vscale x 4 x i32> @cannot_commute_constant_to_rhs(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @cannot_commute_constant_to_rhs(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[R:%.*]] = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1> [[PG]], <vscale x 4 x i32> splat (i32 303), <vscale x 4 x i32> [[A]])
; CHECK-NEXT:    ret <vscale x 4 x i32> [[R]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> splat (i32 303), <vscale x 4 x i32> %a)
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @idempotent_mul(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @idempotent_mul(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    ret <vscale x 4 x i32> [[A]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a, <vscale x 4 x i32> splat (i32 1))
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @idempotent_mul_ops_reverse(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @idempotent_mul_ops_reverse(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[R:%.*]] = select <vscale x 4 x i1> [[PG]], <vscale x 4 x i32> [[A]], <vscale x 4 x i32> splat (i32 1)
; CHECK-NEXT:    ret <vscale x 4 x i32> [[R]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> splat (i32 1), <vscale x 4 x i32> %a)
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @idempotent_mul_u(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @idempotent_mul_u(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    ret <vscale x 4 x i32> [[A]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a, <vscale x 4 x i32> splat (i32 1))
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @idempotent_mul_u_ops_reverse(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @idempotent_mul_u_ops_reverse(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    ret <vscale x 4 x i32> [[A]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> splat (i32 1), <vscale x 4 x i32> %a)
  ret <vscale x 4 x i32> %r
}

; Show that we only need to know the active lanes are constant.
; TODO: We can do better here because we can use %a directly as part of the
; select because we know only its inactive lanes will be used.
define <vscale x 4 x i32> @constant_mul_after_striping_inactive_lanes(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a, <vscale x 4 x i32> %b) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @constant_mul_after_striping_inactive_lanes(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]], <vscale x 4 x i32> [[B:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[A_DUP:%.*]] = call <vscale x 4 x i32> @llvm.aarch64.sve.dup.nxv4i32(<vscale x 4 x i32> [[A]], <vscale x 4 x i1> [[PG]], i32 3)
; CHECK-NEXT:    [[R:%.*]] = select <vscale x 4 x i1> [[PG]], <vscale x 4 x i32> splat (i32 6), <vscale x 4 x i32> [[A_DUP]]
; CHECK-NEXT:    ret <vscale x 4 x i32> [[R]]
;
  %a.dup = call <vscale x 4 x i32> @llvm.aarch64.sve.dup.nxv4i32(<vscale x 4 x i32> %a, <vscale x 4 x i1> %pg, i32 3)
  %b.dup = call <vscale x 4 x i32> @llvm.aarch64.sve.dup.nxv4i32(<vscale x 4 x i32> %b, <vscale x 4 x i1> %pg, i32 2)
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a.dup, <vscale x 4 x i32> %b.dup)
  ret <vscale x 4 x i32> %r
}

; Show that we only need to know the active lanes are constant.
define <vscale x 4 x i32> @constant_mul_u_after_striping_inactive_lanes(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a, <vscale x 4 x i32> %b) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @constant_mul_u_after_striping_inactive_lanes(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]], <vscale x 4 x i32> [[A:%.*]], <vscale x 4 x i32> [[B:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    ret <vscale x 4 x i32> splat (i32 6)
;
  %a.dup = call <vscale x 4 x i32> @llvm.aarch64.sve.dup.nxv4i32(<vscale x 4 x i32> %a, <vscale x 4 x i1> %pg, i32 3)
  %b.dup = call <vscale x 4 x i32> @llvm.aarch64.sve.dup.nxv4i32(<vscale x 4 x i32> %b, <vscale x 4 x i1> %pg, i32 2)
  %3 = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> %a.dup, <vscale x 4 x i32> %b.dup)
  ret <vscale x 4 x i32> %3
}

; The follow tests demonstrate the operations for which hooks are in place to
; enable simplification. Given the simplications themselves are common code, it
; is assumed they are already well tested elsewhere.

define <vscale x 4 x float> @constant_fmul(<vscale x 4 x i1> %pg) #0 {
; CHECK-LABEL: define <vscale x 4 x float> @constant_fmul(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[R:%.*]] = select <vscale x 4 x i1> [[PG]], <vscale x 4 x float> splat (float 4.200000e+01), <vscale x 4 x float> splat (float 7.000000e+00)
; CHECK-NEXT:    ret <vscale x 4 x float> [[R]]
;
  %r = call <vscale x 4 x float> @llvm.aarch64.sve.fmul.nxv4f32(<vscale x 4 x i1> %pg, <vscale x 4 x float> splat (float 7.0), <vscale x 4 x float> splat (float 6.0))
  ret <vscale x 4 x float> %r
}

define <vscale x 4 x float> @constant_fmul_u(<vscale x 4 x i1> %pg) #0 {
; CHECK-LABEL: define <vscale x 4 x float> @constant_fmul_u(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    ret <vscale x 4 x float> splat (float 4.200000e+01)
;
  %r = call <vscale x 4 x float> @llvm.aarch64.sve.fmul.u.nxv4f32(<vscale x 4 x i1> %pg, <vscale x 4 x float> splat (float 7.0), <vscale x 4 x float> splat (float 6.0))
  ret <vscale x 4 x float> %r
}

define <vscale x 4 x i32> @constant_mul(<vscale x 4 x i1> %pg) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @constant_mul(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[R:%.*]] = select <vscale x 4 x i1> [[PG]], <vscale x 4 x i32> splat (i32 21), <vscale x 4 x i32> splat (i32 7)
; CHECK-NEXT:    ret <vscale x 4 x i32> [[R]]
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> splat (i32 7), <vscale x 4 x i32> splat (i32 3))
  ret <vscale x 4 x i32> %r
}

define <vscale x 4 x i32> @constant_mul_u(<vscale x 4 x i1> %pg) #0 {
; CHECK-LABEL: define <vscale x 4 x i32> @constant_mul_u(
; CHECK-SAME: <vscale x 4 x i1> [[PG:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    ret <vscale x 4 x i32> splat (i32 21)
;
  %r = call <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1> %pg, <vscale x 4 x i32> splat (i32 7), <vscale x 4 x i32> splat (i32 3))
  ret <vscale x 4 x i32> %r
}


; repeat only the constant fold tests for fmul(.u)

declare <vscale x 4 x i32> @llvm.aarch64.sve.dup.nxv4i32(<vscale x 4 x i32>, <vscale x 4 x i1>, i32)

declare <vscale x 4 x i32> @llvm.aarch64.sve.mul.nxv4i32(<vscale x 4 x i1>, <vscale x 4 x i32>, <vscale x 4 x i32>)

declare <vscale x 4 x i32> @llvm.aarch64.sve.mul.u.nxv4i32(<vscale x 4 x i1>, <vscale x 4 x i32>, <vscale x 4 x i32>)

attributes #0 = { "target-features"="+sve" }
