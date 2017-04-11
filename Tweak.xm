#import <objc/runtime.h>

@interface MPUTransportControlsView : UIView
-(void)setShowAccessoryButtons:(BOOL)arg1 ;
-(void)setAvailableControls:(int)arg1 ;
@property (nonatomic,readonly) int style;
-(id)_createTransportButtonWithStyle:(int)arg1 ;
-(void)_layoutButton:(id)arg1 withNewFrame:(CGRect)arg2 inExpandedTouchRect:(CGRect)arg3 ;
-(void)_setImage:(id)arg1 forButton:(id)arg2 ;
@property (assign,nonatomic) unsigned repeatType;
@property (assign,nonatomic) unsigned shuffleType;
-(void)_updateTransportControlHighlightedStates;
-(void)_updateTransportControlButtons;
@end

@interface _MPUSystemMediaControlsView : UIView
@property (nonatomic,retain) MPUTransportControlsView * transportControlsView;
@end

@interface SBApplication: NSObject
-(NSString*)bundleIdentifier;
@end

@interface SBMediaController : NSObject
+(id)sharedInstance;
-(BOOL)toggleRepeat;
-(BOOL)toggleShuffle;
-(int)shuffleMode;
-(int)repeatMode;
-(BOOL)isPlaying;
- (SBApplication*)nowPlayingApplication;
@end

NSObject * repeatObject = [NSObject new];
NSObject * shuffleObject = [NSObject new];

%hook MPUTransportControlsView

-(void)_updateTransportControlButtons {
	%orig;
	UIButton * repeatButton = objc_getAssociatedObject(repeatObject,(__bridge void*)self);
	if(repeatButton) {
		int rMode = [[%c(SBMediaController) sharedInstance] repeatMode];
		if(rMode == 1)
			[self _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Repeat-One.png"] forButton:repeatButton];
		else if(rMode == 2)
			[self _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Repeat-All.png"] forButton:repeatButton];
		else
			[self _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Repeat.png"] forButton:repeatButton];
	}

	UIButton * shuffleButton = objc_getAssociatedObject(shuffleObject,(__bridge void*)self);
	if(shuffleButton) {
		if([[%c(SBMediaController) sharedInstance] shuffleMode] == 0)
			[self _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Shuffle-Off.png"] forButton:shuffleButton];
		else
			[self _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Shuffle.png"] forButton:shuffleButton];
	}
}

%end

%hook _MPUSystemMediaControlsView

-(void)layoutSubviews {
	%orig;

	MPUTransportControlsView * controlsView = self.transportControlsView;

	CGFloat offset = 5;
	if(controlsView.style == 2)
		offset = 22;

	UIButton * shuffleButton = objc_getAssociatedObject(shuffleObject,(__bridge void*)controlsView);
	if(!shuffleButton) {
		shuffleButton = [controlsView _createTransportButtonWithStyle:controlsView.style];
		[shuffleButton addTarget:self action:@selector(toggleShuffle) forControlEvents:UIControlEventTouchUpInside];
		[controlsView _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Shuffle.png"] forButton:shuffleButton];
		objc_setAssociatedObject(shuffleObject,(__bridge void*)controlsView,shuffleButton,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	CGRect frame = CGRectMake(controlsView.frame.origin.x+controlsView.frame.size.width+7,controlsView.frame.origin.y + offset,40,30);
	[controlsView _layoutButton:shuffleButton withNewFrame:frame inExpandedTouchRect:frame];

	if(![shuffleButton isDescendantOfView:self])
		[self addSubview:shuffleButton];

	UIButton * repeatButton = objc_getAssociatedObject(repeatObject,(__bridge void*)controlsView);
	if(!repeatButton) {
		repeatButton = [controlsView _createTransportButtonWithStyle:controlsView.style];
		[repeatButton addTarget:self action:@selector(toggleRepeat) forControlEvents:UIControlEventTouchUpInside];
		[controlsView _setImage:[UIImage imageWithContentsOfFile:@"/System/Library/PrivateFrameworks/MediaPlayerUI.framework/Repeat.png"] forButton:repeatButton];
		objc_setAssociatedObject(repeatObject,(__bridge void*)controlsView,repeatButton,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}

	CGRect frame2 = CGRectMake(controlsView.frame.origin.x-40-7,controlsView.frame.origin.y + offset,40,30);
	[controlsView _layoutButton:repeatButton withNewFrame:frame2 inExpandedTouchRect:frame2];

	if(![repeatButton isDescendantOfView:self])
		[self addSubview:repeatButton];

	if(![[[[%c(SBMediaController) sharedInstance] nowPlayingApplication] bundleIdentifier] isEqualToString:@"com.apple.Music"]) {
		shuffleButton.hidden = YES;
		repeatButton.hidden = YES;
	}
	else {
		shuffleButton.hidden = NO;
		repeatButton.hidden = NO;
	}

	[controlsView _updateTransportControlButtons];
}

%new

-(void) toggleRepeat {
	[[%c(SBMediaController) sharedInstance] toggleRepeat];
	[self performSelector:@selector(layoutSubviews) withObject:nil afterDelay:0.2];
}

%new

-(void) toggleShuffle {
	[[%c(SBMediaController) sharedInstance] toggleShuffle];
	[self performSelector:@selector(layoutSubviews) withObject:nil afterDelay:0.2];
}

%end
