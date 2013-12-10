//
//  MBProgressHUD+GEStyle.m
//  Grouvent
//
//  Created by Blankwonder on 11/17/12.
//  Copyright (c) 2012 Suixing Tech. All rights reserved.
//

#import "MBProgressHUD+GEStyle.h"

@implementation MBProgressHUD (GEStyle)

- (void)setSuccessStyle {
    self.customView = [[UIImageView alloc] initWithImage:[UIImage imageResourceNamed:@"hud_success"]];
    self.mode = MBProgressHUDModeCustomView;
}

- (void)setFailStyle {
    self.customView = [[UIImageView alloc] initWithImage:[UIImage imageResourceNamed:@"hud_fail"]];;
    self.mode = MBProgressHUDModeCustomView;
}

@end
