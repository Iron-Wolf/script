#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Description
-----------
Intercepts a mouse device and implements "auto-scroll" behavior
using side buttons.


Tldr
----
Launch with :
  sudo ./mouseRemap_linux.py

Requirements:
    sudo apt install python3-evdev python3-uinput


Debug commands
--------------
This script work ONLY on Wayland.
To sse if this is your case, use this :
    echo $XDG_SESSION_TYPE

To find/test the scancodes and mouse name :
    sudo python3 -m evdev.evtest
    sudo python3 -m evdev.evtest /dev/input/event4


Appendix
--------
Help diagram for MOUSE_MAPPING variable :

           b5
           b4
           b2
        b1  │  b3
         │  │  │
         v  v  v
        ┌──┬┬──┐
        │  ││  │
        ├──┴┴──┤      < A super nice top
  b9─> ┌┤      │      < view of a mouse
       └┤      │
  b8─> ┌┤      │
       └┤      │
        └──────┘

b1 : main button
b2 : scroll wheel press
b3 : secondary button
b4 : scroll wheel up
b5 : scroll wheel down
b6 : ??
b7 : ??
b8 : side-back
b9 : side-forward
"""

import evdev
import uinput
import threading
import time
import errno
from typing import Optional, Callable, Dict, List, Tuple, Any


# ---------------- Configuration ---------------- #
MOUSE_NAME = "USB Optical Mouse"   # Change this to match your mouse name
SCAN_INTERVAL = 2.0                # Seconds between reconnection attempts
AUTO_SCROLL_STEP = 10              # Delay steps before continuous scroll starts
AUTO_SCROLL_INTERVAL = 0.03        # Interval between scroll events (seconds)
# ------------------------------------------------ #

# global event to stop all loop
stop_event: threading.Event = threading.Event()


# ---------------- Functions ---------------- #
"""
Find and return the mouse input device matching MOUSE_NAME.
"""
def get_mouse_device() -> Optional[evdev.InputDevice]:
    for path in evdev.list_devices():
        dev = evdev.InputDevice(path)
        if MOUSE_NAME.lower() in dev.name.lower():
            return dev
    return None


"""
Create a virtual mouse device compatible with the real one.
"""
def create_uinput_device(caps: Dict[int, Any]) -> uinput.Device:
    # handle only a subset of key code
    valid_types: set[int] = {
        evdev.ecodes.EV_KEY, 
        evdev.ecodes.EV_REL, 
        evdev.ecodes.EV_ABS
    }
    events: List[Tuple[int, int]] = []
    for etype, ecodes in caps.items():
        if etype not in valid_types:
            continue
        if isinstance(ecodes, list):
            for code in ecodes:
                events.append((etype, code))
        elif isinstance(ecodes, dict):
            for code in ecodes.keys():
                events.append((etype, code))
    return uinput.Device(events, name="Mouse (filtered)")


def auto_scroll(ui: uinput.Device,
                code: int,
                direction: int,
                hold_check: Callable[[], bool]) -> None:
    # first scroll
    ui.emit(code, direction)
    
    # Loop to "pause" the script before auto scoll.
    for _ in range(AUTO_SCROLL_STEP):
        if not hold_check():
            return
        time.sleep(0.02)
    
    # repeat scroll while the button is held down
    while hold_check():
        ui.emit(code, direction)
        time.sleep(AUTO_SCROLL_INTERVAL)


"""
Handle mouse button key events :
    - BTN_SIDE  : triggers scroll up
    - BTN_EXTRA : triggers scroll down
"""
def handle_key_event(ui: uinput.Device,
                    key_event: evdev.events.KeyEvent,
                    side_pressed_ref: List[bool],
                    extra_pressed_ref: List[bool]) -> None:
    keycode: str = key_event.keycode
    keystate: int = key_event.keystate

    if keycode == "BTN_SIDE":
        if keystate == key_event.key_down:
            side_pressed_ref[0] = True
            threading.Thread(
                target=auto_scroll,
                args=(ui, uinput.REL_WHEEL, -1, lambda: side_pressed_ref[0]),
                daemon=True
            ).start()
        elif keystate == key_event.key_up:
            side_pressed_ref[0] = False

    elif keycode == "BTN_EXTRA":
        if keystate == key_event.key_down:
            extra_pressed_ref[0] = True
            threading.Thread(
                target=auto_scroll,
                args=(ui, uinput.REL_WHEEL, 1, lambda: extra_pressed_ref[0]),
                daemon=True
            ).start()
        elif keystate == key_event.key_up:
            extra_pressed_ref[0] = False


"""
Route events to appropriate handlers (this script or the System).
"""
def process_event(ui: uinput.Device,
                event: evdev.InputEvent,
                side_pressed_ref: List[bool],
                extra_pressed_ref: List[bool]) -> None:
    if event.type == evdev.ecodes.EV_KEY:
        key_event: evdev.events.KeyEvent = evdev.categorize(event)
        if key_event.keycode == "BTN_SIDE" or key_event.keycode == "BTN_EXTRA":
            # handle the event
            handle_key_event(ui, key_event, side_pressed_ref, extra_pressed_ref)
        else:
            ui.emit((event.type, event.code), event.value)
    else:
        # pass-through the event to the System
        ui.emit((event.type, event.code), event.value)


"""
Main processing loop for a single mouse device.
Reads input events, processes them, and handles disconnection.
"""
def handle_mouse_device(dev: evdev.InputDevice) -> None:
    caps: Dict[int, Any] = dev.capabilities(absinfo=False)
    ui: uinput.Device = create_uinput_device(caps)
    side_pressed: List[bool] = [False]  # mutable reference
    extra_pressed: List[bool] = [False]  # mutable reference

    try:
        for event in dev.read_loop():
            if stop_event.is_set():
                break
            process_event(ui, event, side_pressed, extra_pressed)
    except OSError as e:
        if e.errno == errno.ENODEV:
            print("⚠️  Mouse disconnected, waiting to reconnect...")
            time.sleep(SCAN_INTERVAL)
        else:
            raise


"""
Continuously try to detect and process the target mouse device.
"""
def mouse_loop() -> None:
    while not stop_event.is_set():
        dev: Optional[evdev.InputDevice] = get_mouse_device()
        if not dev:
            print("⚠️  No mouse detected, retrying...")
            time.sleep(SCAN_INTERVAL)
            continue

        print(f"✅ Mouse detected: {dev.name} ({dev.path})")

        try:
            dev.grab()
            print("🔒 Mouse successfully grabbed (exclusive access).")
        except OSError as e:
            print(f"⚠️  Unable to grab device: {e}")

        handle_mouse_device(dev)


# ------------------- Main Entry ------------------- #

def main() -> None:
    t: threading.Thread = threading.Thread(target=mouse_loop, daemon=True)
    t.start()

    try:
        input("Press Enter to exit...\n")
    except KeyboardInterrupt:
        pass

    stop_event.set()
    print("🛑 Stopping...")


if __name__ == "__main__":
    main()
