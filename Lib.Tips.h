//
//  Lib.Tips.h
//  Lib.Tips Dynamic Library
//
//  Created on macOS
//

#ifndef LibTips_h
#define LibTips_h

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface LibTipsLibrary : NSObject

+ (void)load;
+ (void)initialize;
+ (void)showWelcomeDialog;
+ (void)showForceWelcomeDialog;

@end

#endif /* LibTips_h */