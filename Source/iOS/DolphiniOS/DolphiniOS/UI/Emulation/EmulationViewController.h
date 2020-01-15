// Copyright 2019 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <MetalKit/MetalKit.h>

#import <UIKit/UIKit.h>

#import "DolphiniOS-Swift.h"

#import "EAGLView.h"

#import "UICommon/GameFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmulationViewController : UIViewController
{
  @public std::vector<std::pair<int, TCView*>> m_controllers;
}

@property (weak, nonatomic) IBOutlet MTKView* m_metal_view;
@property (weak, nonatomic) IBOutlet EAGLView* m_eagl_view;

@property (weak, nonatomic) IBOutlet TCView* m_gc_pad;
@property (weak, nonatomic) IBOutlet TCView* m_wii_normal_pad;
@property (weak, nonatomic) IBOutlet TCView* m_wii_sideways_pad;
@property (weak, nonatomic) IBOutlet TCView* m_wii_classic_pad;

@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer* m_edge_pan_recognizer;

@property(nonatomic) UICommon::GameFile* m_game_file;
@property(nonatomic) UIView* m_renderer_view;
@property(nonatomic) int m_ts_active_port;
@property(weak, nonatomic) TCView* m_ts_active_view;

- (void)PopulatePortDictionary;
- (void)ChangeVisibleTouchControllerToPort:(int)port;

@end

NS_ASSUME_NONNULL_END
