ARCHS = armv7 armv7s arm64
TARGET = iPhone:7.1
ADDITIONAL_CFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = CCShuffle
CCShuffle_FILES = Tweak.xm
CCShuffle_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
