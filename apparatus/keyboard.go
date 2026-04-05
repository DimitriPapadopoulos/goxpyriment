// Copyright (2026) Christophe Pallier <christophe@pallier.org>
// Co-authored by Claude Sonnet 4.6
// Distributed under the GNU General Public License v3.

package apparatus

import (
	"time"

	"github.com/Zyko0/go-sdl3/sdl"
)

// Keyboard provides blocking and non‑blocking helpers around SDL's keyboard
// events, mirroring the high‑level API of Expyriment.
type Keyboard struct {
	// PollKeys is injected by the control layer to avoid direct SDL polling
	// that discards non-keyboard events. It returns (firstKey, quitRequested).
	PollKeys func() (sdl.Keycode, bool)

	// PollKeysWithTS is like PollKeys but also returns the SDL3 event timestamp
	// (nanoseconds, same clock as sdl.TicksNS()). Injected by the control layer
	// alongside PollKeys; used by GetKeyEventRT.
	PollKeysWithTS func() (sdl.Keycode, uint64, bool)
}

// waitSDLKeyEvent is the shared fallback SDL event loop used by WaitKeys and
// GetKeyEventTS when no injected callback is available. It blocks until a
// matching key, ESC, quit, or timeout.
//
// Return values:
//   - (keycode, ts, nil)       — a key in keys was pressed (or any key if keys==nil)
//   - (K_ESCAPE, ts, EndLoop)  — ESC was pressed
//   - (0, 0, EndLoop)          — window-close quit event
//   - (0, 0, nil)              — timeout
//
// The hardware event timestamp ts is always populated when a key is returned.
func waitSDLKeyEvent(keys []sdl.Keycode, start uint64, timeoutMS int) (sdl.Keycode, uint64, error) {
	for {
		var event sdl.Event
		var hasEvent bool

		if timeoutMS < 0 {
			if sdl.WaitEvent(&event) == nil {
				hasEvent = true
			}
		} else {
			elapsed := int(sdl.Ticks() - start)
			remaining := timeoutMS - elapsed
			if remaining <= 0 {
				return 0, 0, nil
			}
			if sdl.WaitEventTimeout(&event, int32(remaining)) {
				hasEvent = true
			} else {
				if int(sdl.Ticks()-start) >= timeoutMS {
					return 0, 0, nil
				}
				continue
			}
		}

		if !hasEvent {
			continue
		}

		switch event.Type {
		case sdl.EVENT_QUIT:
			return 0, 0, sdl.EndLoop
		case sdl.EVENT_KEY_DOWN:
			ke := event.KeyboardEvent()
			keycode, ts := ke.Key, ke.Timestamp
			if keycode == sdl.K_ESCAPE {
				return sdl.K_ESCAPE, ts, sdl.EndLoop
			}
			if keys == nil {
				return keycode, ts, nil
			}
			for _, kc := range keys {
				if keycode == kc {
					return keycode, ts, nil
				}
			}
		}
	}
}

// Wait blocks until any key is pressed and returns its SDL keycode.
// If the ESC key or a quit event is received, it returns sdl.EndLoop.
func (k *Keyboard) Wait() (sdl.Keycode, error) {
	return k.WaitKeys(nil, -1)
}

// WaitKeys blocks until one of the specified keys is pressed or a timeout
// occurs.
//
//   - If keys is nil, any key will trigger a return.
//   - If timeoutMS is -1, it waits indefinitely.
//   - On timeout, it returns keycode 0 and nil error.
//   - On ESC or quit, it returns sdl.EndLoop.
func (k *Keyboard) WaitKeys(keys []sdl.Keycode, timeoutMS int) (sdl.Keycode, error) {
	start := sdl.Ticks()

	// Injected path: use the control-layer callback to avoid discarding
	// non-keyboard events while draining the SDL queue.
	if k.PollKeys != nil {
		for {
			if timeoutMS >= 0 {
				if int(sdl.Ticks()-start) >= timeoutMS {
					return 0, nil
				}
			}

			keycode, quit := k.PollKeys()
			if quit {
				return 0, sdl.EndLoop
			}
			if keycode != 0 {
				if keycode == sdl.K_ESCAPE {
					return sdl.K_ESCAPE, sdl.EndLoop
				}
				if keys == nil {
					return keycode, nil
				}
				for _, kc := range keys {
					if keycode == kc {
						return keycode, nil
					}
				}
			}

			time.Sleep(1 * time.Millisecond)
		}
	}

	// Fallback: direct SDL event polling when no callback is injected.
	key, _, err := waitSDLKeyEvent(keys, start, timeoutMS)
	return key, err
}

// Check polls for keyboard events without blocking and returns the first key
// pressed since the last call (or 0 if none). ESC or a quit event yields
// sdl.EndLoop.
func (k *Keyboard) Check() (sdl.Keycode, error) {
	var event sdl.Event
	for sdl.PollEvent(&event) {
		if event.Type == sdl.EVENT_KEY_DOWN {
			keycode := event.KeyboardEvent().Key
			if keycode == sdl.K_ESCAPE {
				return 0, sdl.EndLoop
			}
			return keycode, nil
		}
		if event.Type == sdl.EVENT_QUIT {
			return 0, sdl.EndLoop
		}
	}
	return 0, nil
}

// WaitKey blocks until the given key is pressed and returns an error only on
// ESC / window close. It is a convenience wrapper around WaitKeys for the
// common "wait for SPACE to continue" pattern.
func (k *Keyboard) WaitKey(key sdl.Keycode) error {
	_, err := k.WaitKeys([]sdl.Keycode{key}, -1)
	return err
}

// WaitKeysRT blocks until one of the specified keys is pressed (or a timeout
// occurs) and also returns the reaction time in milliseconds measured from
// the moment WaitKeysRT was called.
//
// The RT is a wall-clock elapsed time (sdl.Ticks delta), NOT a hardware event
// timestamp. For stimulus-onset-locked RT with nanosecond precision, use
// GetKeyEventTS instead, which returns the SDL3 KeyboardEvent.Timestamp
// directly and can be subtracted from a Screen.FlipTS() onset value.
//
// This bundles the common three-line pattern:
//
//	startTime := clock.GetTime()
//	key, err := kb.WaitKeys(keys, timeout)
//	rt := clock.GetTime() - startTime
func (k *Keyboard) WaitKeysRT(keys []sdl.Keycode, timeoutMS int) (sdl.Keycode, int64, error) {
	start := sdl.Ticks()
	key, err := k.WaitKeys(keys, timeoutMS)
	rt := int64(sdl.Ticks() - start)
	return key, rt, err
}

// GetKeyEventTS waits for one of the specified keys (or any key if keys is
// nil) and returns the keycode and SDL3 event timestamp in nanoseconds (same
// reference clock as sdl.TicksNS() and Screen.FlipTS()).
//
// Unlike WaitKeysRT — which measures elapsed time from the function call —
// the returned timestamp comes directly from the SDL3 KeyboardEvent.Timestamp
// field, which is set at hardware-interrupt time. This makes it suitable for
// computing reaction times relative to a stimulus onset captured with
// Screen.FlipTS():
//
//	onset, _ := screen.FlipTS()
//	key, keyTS, _ := kb.GetKeyEventTS(keys, -1)
//	rtNS := int64(keyTS - onset)
//
// If an event matching keys is already in the SDL queue, it is returned
// immediately without blocking. Pass timeoutMS = -1 for no timeout.
// On timeout, returns (0, 0, nil). On ESC or quit, returns sdl.EndLoop.
//
// Use GetKeyEventsTS to retrieve all events that arrived, not just the first.
func (k *Keyboard) GetKeyEventTS(keys []sdl.Keycode, timeoutMS int) (sdl.Keycode, uint64, error) {
	start := sdl.Ticks()

	// Injected path: use the control-layer callback which carries the SDL3
	// hardware event timestamp.
	if k.PollKeysWithTS != nil {
		for {
			if timeoutMS >= 0 {
				if int(sdl.Ticks()-start) >= timeoutMS {
					return 0, 0, nil
				}
			}
			keycode, ts, quit := k.PollKeysWithTS()
			if quit {
				return 0, 0, sdl.EndLoop
			}
			if keycode != 0 {
				if keycode == sdl.K_ESCAPE {
					return sdl.K_ESCAPE, ts, sdl.EndLoop
				}
				if keys == nil {
					return keycode, ts, nil
				}
				for _, kc := range keys {
					if keycode == kc {
						return keycode, ts, nil
					}
				}
			}
			time.Sleep(1 * time.Millisecond)
		}
	}

	// Fallback: direct SDL event polling when no callback is injected.
	return waitSDLKeyEvent(keys, start, timeoutMS)
}

// GetKeyEventsTS waits for one or more matching key events and returns ALL
// that are available, ordered by hardware timestamp (earliest first).
//
// It blocks until at least one matching event arrives (like GetKeyEventTS),
// then non-blockingly drains any additional key events already in the SDL
// queue. This is useful for detecting simultaneous or near-simultaneous
// presses. In the common case only one event is returned.
//
// Pass timeoutMS = -1 for no timeout. On timeout, returns (nil, nil).
// On ESC or quit, returns sdl.EndLoop (with any events collected so far).
func (k *Keyboard) GetKeyEventsTS(keys []sdl.Keycode, timeoutMS int) ([]InputEvent, error) {
	firstKey, firstTS, err := k.GetKeyEventTS(keys, timeoutMS)
	if err != nil {
		return nil, err
	}
	if firstKey == 0 {
		return nil, nil // timeout
	}

	first := InputEvent{Device: DeviceKeyboard, Key: firstKey, TimestampNS: firstTS}

	// Non-blockingly drain any additional key events already in the queue.
	rest, quit := drainMatchingKeyEvents(keys)
	all := append([]InputEvent{first}, rest...)

	// Sort by hardware timestamp (typically already in order).
	for i := 1; i < len(all); i++ {
		for j := i; j > 0 && all[j].TimestampNS < all[j-1].TimestampNS; j-- {
			all[j], all[j-1] = all[j-1], all[j]
		}
	}

	if quit {
		return all, sdl.EndLoop
	}
	return all, nil
}

// drainMatchingKeyEvents non-blockingly reads all currently queued key events
// and returns those matching keys (any key if keys is nil), plus whether a
// quit or ESC event was encountered.
func drainMatchingKeyEvents(keys []sdl.Keycode) ([]InputEvent, bool) {
	var events []InputEvent
	var ev sdl.Event
	for sdl.PollEvent(&ev) {
		switch ev.Type {
		case sdl.EVENT_QUIT:
			return events, true
		case sdl.EVENT_KEY_DOWN:
			ke := ev.KeyboardEvent()
			if ke.Key == sdl.K_ESCAPE {
				return events, true
			}
			matched := keys == nil
			if !matched {
				for _, kc := range keys {
					if ke.Key == kc {
						matched = true
						break
					}
				}
			}
			if matched {
				events = append(events, InputEvent{
					Device:      DeviceKeyboard,
					Key:         ke.Key,
					TimestampNS: ke.Timestamp,
				})
			}
		}
	}
	return events, false
}

// Clear drains the entire SDL event queue — keyboard, mouse, gamepad, and all
// other event types — because SDL uses a single shared queue. Call it before
// a new trial to discard stale presses from any device. Do not call it after
// ShowTS/FlipTS: the participant may have already responded and the event
// would be silently discarded before GetKeyEventTS can read it.
func (k *Keyboard) Clear() {
	var event sdl.Event
	for sdl.PollEvent(&event) {
		// Just drain the queue
	}
}
