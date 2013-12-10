//
//  KDXUIDebugger.m
//  koudaixiang
//
//  Created by Blankwonder on 8/19/12.
//
//

#import "KDXUIDebugger.h"

const char kIndentChar = '-';

void _KDXUIDebuggerPrintSubviews(UIView *view, int indent);

void KDXUIDebuggerPrintSubviews(UIView *view) {
    _KDXUIDebuggerPrintSubviews(view, 0);
}

void _KDXUIDebuggerPrintSubviews(UIView *view, int indent) {
    char *indentCStr = malloc(sizeof(char) * (indent + 1));
    for (int i = 0; i < indent; i++) {
        indentCStr[i] = kIndentChar;
    }
    indentCStr[indent] = '\0';
    NSString *indentStr = [NSString stringWithUTF8String:indentCStr];
    free(indentCStr);
    for (UIView *subview in view.subviews) {
        NSLog(@"%@%@: %@", indentStr, NSStringFromClass([subview class]), NSStringFromCGRect(subview.frame));
        _KDXUIDebuggerPrintSubviews(subview, indent + 1);
    }
}