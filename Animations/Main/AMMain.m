//
//  AMMain.m
//  Animations
//
//  Created by Illya Bakurov on 12/4/15.
//  Copyright © 2015 IB. All rights reserved.
//

#import "AMMain.h"
#import <POP/POP.h>

@interface AMMain ()

@property (strong, nonatomic) IBOutlet UIButton *appleMap;
@property (strong, nonatomic) IBOutlet UIButton *googleMap;
@property (strong, nonatomic) IBOutlet UILabel *pickYourMapLbl;
@property (strong, nonatomic) IBOutlet UIImageView *background;

@property (nonatomic) CGRect rectWithOriginalFrameOfAppleMapIcon;
@property (nonatomic) CGRect rectWithOriginalFrameOfGoogleMapIcon;

@end

@implementation AMMain

#pragma mark - Initialization

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    //Taking initial frame of the buttons and saving it locally, baceuse we want the effect of appearance from the bottom of the view, so we are going to relocate them under the bottom of the view.
    CGRect frameForAppleMapIcon = self.appleMap.frame;
    self.rectWithOriginalFrameOfAppleMapIcon = frameForAppleMapIcon;
    
    //Relocating the button under the bottom of the view
    frameForAppleMapIcon.origin.y = self.view.frame.size.height + frameForAppleMapIcon.size.height;
    [self.appleMap setFrame:frameForAppleMapIcon];
    
    //The exact same thing here as the above one
    CGRect frameForGoogleMapIcon = self.googleMap.frame;
    self.rectWithOriginalFrameOfGoogleMapIcon = frameForGoogleMapIcon;
    
    frameForGoogleMapIcon.origin.y = self.view.frame.size.height + frameForGoogleMapIcon.size.height;
    [self.googleMap setFrame:frameForGoogleMapIcon];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Giving a chance for the Image and Blur on the background fully appear, before animation of the appearing of the button starts
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self makeIconsAppear];
        });
    });
}

#pragma mark - Actions

- (IBAction)appleMapChosen:(UIButton *)sender {
    [self scaleAndRotateIcon:sender];
}

- (IBAction)googleMapChosen:(UIButton *)sender {
    [self scaleAndRotateIcon:sender];
}

#pragma mark - POP Animation

//Animation of the buttons on the appear of the View
- (void)makeIconsAppear {
    //Simple fadeout animation using POPS SPring animation
    POPSpringAnimation * appleAnimFadeOut = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    appleAnimFadeOut.springBounciness = 11.0f;
    appleAnimFadeOut.springSpeed = 2.0f;
    appleAnimFadeOut.toValue = [NSValue valueWithCGRect:self.rectWithOriginalFrameOfAppleMapIcon];
    
    //Once the first icon strated to animate, we are animating the second one, so that it look slike they are racing each other.
    [appleAnimFadeOut setAnimationDidStartBlock:^(POPAnimation * anim) {
        POPSpringAnimation * googleAnimFadeOut = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        googleAnimFadeOut.springBounciness = 16.0f;
        googleAnimFadeOut.springSpeed = 5.0f;
        googleAnimFadeOut.toValue = [NSValue valueWithCGRect:self.rectWithOriginalFrameOfGoogleMapIcon];
        
        [googleAnimFadeOut setCompletionBlock:^(POPAnimation * anim, BOOL finished) {
        }];
        
        [self.googleMap pop_addAnimation:googleAnimFadeOut forKey:@"FadeOutGoogle"];
    }];
    
    [self.appleMap pop_addAnimation:appleAnimFadeOut forKey:@"FadeOutApple"];
    
}

//Animation of Buttons One they are pressed
- (void)scaleAndRotateIcon:(UIButton *)sender {
    //Not to touch the same button twice
    self.view.userInteractionEnabled = NO;
    
    
    //Scaling up
    POPSpringAnimation * animScale = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    animScale.springBounciness = 10.0f;
    animScale.springSpeed = 5.0f;
    animScale.toValue = [NSValue valueWithCGPoint:CGPointMake(1.3, 1.3)];
    
    //Roatting
    POPSpringAnimation * animRotate = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
    animRotate.springBounciness = 10.0f;
    animRotate.springSpeed = 5.0f;
    animRotate.toValue = @(2*M_PI);
    
    [animRotate setAnimationDidReachToValueBlock:^(POPAnimation * anim) {
        //Scaling back down
        POPSpringAnimation * animScaleBack = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
        animScaleBack.springBounciness = 10.0f;
        animScaleBack.springSpeed = 5.0f;
        animScaleBack.toValue = [NSValue valueWithCGPoint:CGPointMake(1, 1)];
        
        [animScaleBack setCompletionBlock:^(POPAnimation * anim, BOOL finished) {
            self.view.userInteractionEnabled = YES;
        }];
        
        [sender.layer pop_addAnimation:animScaleBack forKey:@"ScaleBack"];
        
    }];
    
    [sender.layer pop_addAnimation:animScale forKey:@"Scale"];
    [sender.layer pop_addAnimation:animRotate forKey:@"Rotate"];
}

@end
