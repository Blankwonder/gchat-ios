//
//  KDXDebugger.c
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "KDXLogger.h"
#include <execinfo.h>

static NSString *logFilePath;
static NSFileHandle *LogFileHandle = nil;
static NSDateFormatter *DateFormatter = nil;
static NSUncaughtExceptionHandler *oldHandler = nil;

void KDXDebuggerSetLogPath(NSString *path) {
    logFilePath = [path copy];
}

void _KDXLog(NSString *module, NSString *format, ...)
{
    if (LogFileHandle == nil && logFilePath != nil) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        NSString *path = [logFilePath stringByAppendingPathComponent:[dateStr stringByAppendingString:@".log"]];
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        LogFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
    }
    
    if (!DateFormatter) {
        DateFormatter = [[NSDateFormatter alloc] init];
        [DateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
    }
    
    va_list ap;
    va_start(ap, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:ap];
    NSString *log;
    NSString *dateStr = [DateFormatter stringFromDate:[NSDate date]];
    if ([NSThread isMainThread]) {
        log = [[NSString alloc] initWithFormat:@"%@  [%@] %@\n", dateStr, module, message];
    } else {
        log = [[NSString alloc] initWithFormat:@"%@ *[%@] %@\n", dateStr, module, message];
    }
    
    fputs(log.UTF8String, stderr);
    
    if (LogFileHandle) {
        NSData *logFileLine = [log dataUsingEncoding:NSUTF8StringEncoding];
        @synchronized(LogFileHandle) {
            [LogFileHandle writeData:logFileLine];
            [LogFileHandle synchronizeFile];
        }
    }
}

void KDXDebuggerInstallUncaughtExceptionHandler(void)
{
    oldHandler = NSGetUncaughtExceptionHandler();
	NSSetUncaughtExceptionHandler(&KDXHandleException);
}

void KDXHandleException(NSException* exception)
{
    KDXLog(@"KDXLogger", @"Uncaught Exception, description:%@, call stack:%@", exception.description, [exception callStackSymbols]);
    if (oldHandler) {
        oldHandler(exception);
    }
}

void KDXPrintCallStack(void)
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (int  i = 0; i < frames; i++)
    {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    KDXLog(@"KDXLogger", @"Call stack:%@", backtrace);
}