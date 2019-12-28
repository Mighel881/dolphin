// Copyright 2019 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

#import <UIKit/UIKit.h>

#import "InputCommon/ControllerEmu/ControlGroup/ControlGroup.h"
#import "InputCommon/ControllerEmu/ControllerEmu.h"

NS_ASSUME_NONNULL_BEGIN

@interface ControllerGroupViewController : UITableViewController
{
  dispatch_block_t m_input_wait_block;
}

@property(nonatomic) ControllerEmu::EmulatedController* m_controller;
@property(nonatomic) ControllerEmu::ControlGroup* m_control_group;
@property(nonatomic) bool m_is_wii;
@property(nonatomic) bool m_need_indicator;
@property(nonatomic) bool m_need_calibration;

@property (weak, nonatomic) IBOutlet UIBarButtonItem* m_cancel_item;
@property (weak, nonatomic) IBOutlet UIBarButtonItem* m_clear_item;

@end

NS_ASSUME_NONNULL_END
