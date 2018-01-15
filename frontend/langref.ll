; ModuleID = '<string>'
source_filename = "<string>"
target triple = "x86_64-unknown-linux-gnu"

@counter = internal global i32 0
@.str.0 = unnamed_addr constant [14 x i8] c"argv[%d]: %s\0A\00"

declare i32 @printf(i8*, ...)

define i32 @get_counter() {
entry:
  %counter = load i32, i32* @counter
  %.2 = add i32 %counter, 1
  store i32 %.2, i32* @counter
  %counter.1 = load i32, i32* @counter
  ret i32 %counter.1
}

define void @foo(i32 %param.len) {
entry:
  %len = alloca i32
  store i32 %param.len, i32* %len
  %len.1 = load i32, i32* %len
  %arr = alloca i32, i32 %len.1
  %.4 = bitcast i32* %arr to i8*
  %nbytes = mul i32 %len.1, 4
  call void @llvm.memset.p0i8.i32(i8* %.4, i8 0, i32 %nbytes, i32 4, i1 false)
  %i = alloca i32
  store i32 0, i32* %i
  %_end = alloca i32
  %len.2 = load i32, i32* %len
  store i32 %len.2, i32* %_end
  br label %entry.while

entry.while:                                      ; preds = %entry.do, %entry
  %i.1 = load i32, i32* %i
  %_end.1 = load i32, i32* %_end
  %.9 = icmp slt i32 %i.1, %_end.1
  br i1 %.9, label %entry.do, label %entry.endwhile

entry.do:                                         ; preds = %entry.while
  %i.2 = load i32, i32* %i
  %arr.idx = getelementptr i32, i32* %arr, i32 %i.2
  %i.3 = load i32, i32* %i
  store i32 %i.3, i32* %arr.idx
  %i.4 = load i32, i32* %i
  %.12 = add i32 %i.4, 1
  store i32 %.12, i32* %i
  br label %entry.while

entry.endwhile:                                   ; preds = %entry.while
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memset.p0i8.i32(i8* nocapture writeonly, i8, i32, i32, i1) #0

define i32 @main(i32 %param.argc, i8** %argv) {
entry:
  %argc = alloca i32
  store i32 %param.argc, i32* %argc
  %i = alloca i32
  store i32 0, i32* %i
  %_end = alloca i32
  %argc.1 = load i32, i32* %argc
  store i32 %argc.1, i32* %_end
  br label %entry.while

entry.while:                                      ; preds = %entry.do, %entry
  %i.1 = load i32, i32* %i
  %_end.1 = load i32, i32* %_end
  %.8 = icmp slt i32 %i.1, %_end.1
  br i1 %.8, label %entry.do, label %entry.endwhile

entry.do:                                         ; preds = %entry.while
  %.str.0 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.0, i32 0, i32 0
  %i.2 = load i32, i32* %i
  %i.3 = load i32, i32* %i
  %argv.ptr = getelementptr i8*, i8** %argv, i32 %i.3
  %argv.idx = load i8*, i8** %argv.ptr
  %.10 = call i32 (i8*, ...) @printf(i8* %.str.0, i32 %i.2, i8* %argv.idx)
  %i.4 = load i32, i32* %i
  %.11 = add i32 %i.4, 1
  store i32 %.11, i32* %i
  br label %entry.while

entry.endwhile:                                   ; preds = %entry.while
  call void @foo(i32 10)
  ret i32 0
}

attributes #0 = { argmemonly nounwind }
