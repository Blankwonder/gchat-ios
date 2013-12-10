//
//  KDXDebugger.h
//  koudaixiang
//
//  Created by Liu Yachen on 3/22/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define KDXLog(...) _KDXLog(__VA_ARGS__) 
#   define KDXClassLog(...) _KDXLog(NSStringFromClass([self class]), __VA_ARGS__)
#else
#   define KDXLog(...) do{}while(0)
#   define KDXClassLog(...) do{}while(0)
#endif

void _KDXLog(NSString *module, NSString *format, ...);



void KDXHandleException(NSException* exception);
void KDXSignalHandler(int signal);

void KDXDebuggerSetLogPath(NSString *path);
void KDXDebuggerInstallUncaughtExceptionHandler(void);

void KDXPrintCallStack(void);