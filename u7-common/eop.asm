%macro eopProc 3
	%define %%eopSegmentName %1
	%define %%length %2
	%define %%procName %3
	
	%assign %%eopNumber %%eopSegmentName %+ _nextEopNumber
	
	%assign %%off_start %%eopSegmentName %+ _nextEopStart
	%assign %%off_end   %%off_start + %%length
	
	%define %%addr_start seg_ %+ %%eopSegmentName, %%off_start
	%define %%addr_end   seg_ %+ %%eopSegmentName, %%off_end
	
	defineAddress %%addr_start, %%eopSegmentName %+ _ %+ %%procName
	defineAddress %%addr_end,   %%eopSegmentName %+ _ %+ %%procName %+ _end
	
	defineAddress %%addr_start, %%eopSegmentName %+ _ %+ %%eopNumber
	defineAddress %%addr_end,   %%eopSegmentName %+ _ %+ %%eopNumber %+ _end
	
	defineAddress %%addr_start, eop_ %+ %%procName
	defineAddress %%addr_end,   eop_ %+ %%procName %+ _end
	
	%assign eopNumber_%[%%procName] %%eopNumber
	%define eopSegmentName_%[%%procName] %%eopSegmentName
	
	%assign %[%%eopSegmentName]_nextEopStart  %%off_end
	%assign %[%%eopSegmentName]_nextEopNumber %%eopNumber + 1
%endmacro

%define varArgsEopArg(eopName, argCount) \
		((eopNumber_ %+ eopName) << 8) + argCount

%macro callVarArgsEop 3
	%define %%procName %1
	%define %%argCount %2
	%define %%callMethod %3
	
	%xdefine %%eopSegment eopSegmentName_ %+ %%procName
	
	push varArgsEopArg(%%procName, %%argCount)
	%%callMethod %%eopSegment %+ _entry_varArgsDispatcher
	pop cx
%endmacro

%macro callVarArgsEopFromLoadModule 2
	callVarArgsEop %1, %2, callFromLoadModule
%endmacro
		
%macro callVarArgsEopFromOverlay 2
	callVarArgsEop %1, %2, callFromOverlay
%endmacro
		
%define byteArgEopArg(eopName, byteArg) \
		((eopNumber_ %+ eopName) << 8) + byteArg

%macro callByteArgEop 3
	%define %%procName %1
	%define %%byteArg %2
	%define %%callMethod %3
	
	%xdefine %%eopSegment eopSegmentName_ %+ %%procName
	
	push byteArgEopArg(%%procName, %%byteArg)
	%%callMethod %%eopSegment %+ _entry_byteArgDispatcher
	pop cx
%endmacro

%macro callByteArgEopFromLoadModule 2
	callByteArgEop %1, %2, callFromLoadModule
%endmacro

%macro callByteArgEopFromOverlay 2
	callByteArgEop %1, %2, callFromOverlay
%endmacro
