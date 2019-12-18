// Copyright 2019 Dolphin Emulator Project
// Licensed under GPLv2+
// Refer to the license.txt file included.

import Foundation
import MetalKit
import UIKit

class EmulationViewController: UIViewController, UIGestureRecognizerDelegate
{
  @objc public var softwareFile: String = ""
  @objc public var softwareName: String = ""
  @objc public var isWii: Bool = false
  
  let controller_setup_queue = DispatchQueue(label: "org.dolphin-emu.ios.tscon-setup-queue")
  
  @IBOutlet weak var m_metal_view: MTKView!
  @IBOutlet weak var m_eagl_view: EAGLView!
  @IBOutlet weak var m_gc_pad_view: TCGameCubePad!
  @IBOutlet weak var m_wii_pad_view: TCWiiPad!
  
  required init?(coder: NSCoder)
  {
    super.init(coder: coder)
  }
  
  override func viewDidLoad()
  {
    self.navigationItem.title = self.softwareName;
    
    var renderer_view: UIView
    if (MainiOS.getGfxBackend() == "Vulkan")
    {
      renderer_view = m_metal_view
    }
    else
    {
      renderer_view = m_eagl_view
    }
    
    renderer_view.isHidden = false
    
    if (self.isWii)
    {
      m_wii_pad_view.isUserInteractionEnabled = true
      m_wii_pad_view.isHidden = false
    }
    else
    {
      m_gc_pad_view.isUserInteractionEnabled = true
      m_gc_pad_view.isHidden = false
    }
    
    setupTapGestureRecognizer(m_wii_pad_view)
    setupTapGestureRecognizer(m_gc_pad_view)
    
    let has_seen_alert = UserDefaults.standard.bool(forKey: "seen_double_tap_two_fingers_alert")
    if (!has_seen_alert)
    {
      let alert = UIAlertController(title: "Note", message: "Double tap the screen with two fingers fast to reveal the top bar.", preferredStyle: .alert)
      
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        UserDefaults.standard.set(true, forKey: "seen_double_tap_two_fingers_alert")
      }))
      
      self.present(alert, animated: true, completion: nil)
    }
    else
    {
      self.navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    if (self.isWii)
    {
      self.setupWiimotePointer()
      TCDeviceMotion.shared.registerMotionHandlers()
    }
    
    let queue = DispatchQueue(label: "org.dolphin-emu.ios.emulation-queue")
    queue.async
    {
      MainiOS.startEmulation(withFile: self.softwareFile, viewController: self, view: renderer_view)
      
      if (self.isWii)
      {
        TCDeviceMotion.shared.stopMotionUpdates()
      }
      
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: "toSoftwareTable", sender: nil)
      }
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
  {
    super.viewWillTransition(to: size, with: coordinator)
    
    // Perform an "animation" alongside the transition and tell Dolphin that
    // the window has resized after it is finished
    coordinator.animate(alongsideTransition: nil, completion: { _ in
      if (self.isWii)
      {
        self.setupWiimotePointer()
        TCDeviceMotion.shared.statusBarOrientationChanged()
      }
      
      MainiOS.windowResized()
    })
  }
  
  func setupWiimotePointer()
  {
    controller_setup_queue.async
    {
      let target_rectangle = MainiOS.getRenderTargetRectangle()
      
      // Wait for the target rectangle to be set
      while (true)
      {
        let new_rect = MainiOS.getRenderTargetRectangle()
        if (new_rect.size != target_rectangle.size)
        {
          break;
        }
      }
      
      // Set the Wiimote pointer values
      DispatchQueue.main.sync
      {
        self.m_wii_pad_view.recalculatePointerValues()
      }
    }
  }
  
  func setupTapGestureRecognizer(_ view: TCView)
  {
    // Add a gesture recognizer for two finger double tapping
    let tap_recognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap_recognizer.numberOfTapsRequired = 2
    tap_recognizer.numberOfTouchesRequired = 2
    tap_recognizer.delegate = self
    
    view.real_view!.addGestureRecognizer(tap_recognizer)
  }
  
  @IBAction func doubleTapped(_ sender: UITapGestureRecognizer)
  {
    // Ignore double taps on things that can be tapped
    if (sender.view != nil)
    {
      let hit_view = sender.view!.hitTest(sender.location(in: sender.view), with: nil)
      if (hit_view != sender.view)
      {
        return
      }
    }
    
    let is_hidden = self.navigationController!.isNavigationBarHidden
    if (!is_hidden)
    {
      self.additionalSafeAreaInsets.top = 0
    }
    else
    {
      // This inset undoes any changes the navigation bar made to the safe area
      self.additionalSafeAreaInsets.top = -(self.navigationController!.navigationBar.bounds.height)
    }
    
    self.navigationController!.setNavigationBarHidden(!is_hidden, animated: true)
    
  }
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    if (gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer)
    {
      return true
    }
    
    return false
  }
  
  @IBAction func exitButtonPressed(_ sender: Any)
  {
    let alert = UIAlertController(title: "Stop Emulation", message: "Do you really want to stop the emulation? All unsaved data will be lost.", preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
      MainiOS.stopEmulation()
    }))
    
    self.present(alert, animated: true, completion: nil)
  }
  
}
