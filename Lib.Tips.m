//
//  LibTips.m
//  LibTips Dynamic Library
//
//  Created on macOS
//

#import "Lib.Tips.h"
#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>

@implementation LibTipsLibrary

// 获取当前动态库的文件名
+ (NSString *)getCurrentDylibName {
    Dl_info info;
    if (dladdr([self class], &info) && info.dli_fname) {
        NSString *fullPath = [NSString stringWithUTF8String:info.dli_fname];
        return [fullPath lastPathComponent];
    }
    return @"未知动态库";
}

// 动态库加载时自动调用
+ (void)load {
    // 在主线程延迟执行，确保应用程序完全启动
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self showForceWelcomeDialog];
    });
}

// 类初始化时调用
+ (void)initialize {
    if (self == [LibTipsLibrary class]) {
        // 初始化代码
    }
}

// 显示欢迎弹窗
+ (void)showWelcomeDialog {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *dylibName = [self getCurrentDylibName];
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"🎉 LibTips 动态库注入成功！"];
        [alert setInformativeText:[NSString stringWithFormat:@"这是通过动态库注入显示的自定义弹窗。\n\n动态库文件：%@\n加载时间：成功", dylibName]];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert addButtonWithTitle:@"太棒了！"];
        [alert addButtonWithTitle:@"关闭"];
        
        // 设置图标
        NSImage *icon = [NSImage imageNamed:NSImageNameInfo];
        [alert setIcon:icon];
        
        [alert runModal];
    });
}

// 强制显示弹窗（确保在所有情况下都能显示）
+ (void)showForceWelcomeDialog {
    // 确保在主线程执行
    if ([NSThread isMainThread]) {
        [self performForceDialog];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self performForceDialog];
        });
    }
}

// 执行强制弹窗显示
+ (void)performForceDialog {
    @try {
        NSString *dylibName = [self getCurrentDylibName];
        
        // 创建弹窗
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"🚀 LibTips 动态库加载成功"];
        [alert setInformativeText:[NSString stringWithFormat:@"恭喜！动态库已成功注入到当前应用程序中。\n\n✅ 文件名：%@\n✅ 注入方式：DYLD_TIPS 环境变量\n✅ 状态：运行正常\n\n这个弹窗证明了动态库注入功能正常工作。", dylibName]];
        [alert setAlertStyle:NSAlertStyleInformational];
        
        // 添加按钮
        [alert addButtonWithTitle:@"知道了"];
        [alert addButtonWithTitle:@"查看详情"];
        
        // 设置图标
        NSImage *icon = [NSImage imageNamed:NSImageNameApplicationIcon];
        if (!icon) {
            icon = [NSImage imageNamed:NSImageNameInfo];
        }
        [alert setIcon:icon];
        
        // 显示弹窗
        NSModalResponse response = [alert runModal];
        
        if (response == NSAlertSecondButtonReturn) {
            [self showDetailInfo];
        }
        
    } @catch (NSException *exception) {
        // 备用通知方式
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LibTipsLoadedNotification" 
                                                            object:nil 
                                                          userInfo:@{@"message": @"LibTips 动态库加载成功"}];
    }
}

// 显示详细信息
+ (void)showDetailInfo {
    NSString *dylibName = [self getCurrentDylibName];
    NSAlert *detailAlert = [[NSAlert alloc] init];
    [detailAlert setMessageText:@"🔍 LibTips 动态库详细信息"];
    [detailAlert setInformativeText:[NSString stringWithFormat:@"动态库信息：\n• 文件名：%@\n• 版本：1.0.0\n• 架构：x86_64\n• 注入方式：DYLD_TIPS 环境变量\n• 加载时间：应用启动时\n• 状态：正常运行\n\n这个动态库演示了如何在 macOS 应用程序中注入自定义代码。", dylibName]];
    [detailAlert setAlertStyle:NSAlertStyleInformational];
    [detailAlert addButtonWithTitle:@"明白了"];
    [detailAlert runModal];
}

@end