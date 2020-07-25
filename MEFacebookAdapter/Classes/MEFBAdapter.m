//
//  MEFBAdapter.m
//  MEAdvSDK
//
//  Created by 卢镝 on 2020/6/2.
//

#import "MEFBAdapter.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>

@interface MEFBAdapter ()  <FBInterstitialAdDelegate, FBRewardedVideoAdDelegate>

///插屏广告对象
@property (nonatomic, strong) FBInterstitialAd *interstitialAd;
///激励视频广告对象
@property (nonatomic, strong) FBRewardedVideoAd *rewardedAd;

/// 是否展示误点按钮
@property (nonatomic, assign) BOOL showFunnyBtn;
/// 是否需要展示
@property (nonatomic, assign) BOOL needShow;

@end

@implementation MEFBAdapter

+ (instancetype)sharedInstance {
    
    static MEFBAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MEFBAdapter alloc] init];
    });
    return sharedInstance;;
}

+ (void)launchAdPlatformWithAppid:(NSString *)appid {
    // 初始化facebook的SDK
    [FBAudienceNetworkAds initializeWithSettings:nil completionHandler:^(FBAdInitResults * _Nonnull results) {
        if (results.success) {
            DLog(@"%@",results.message);
        }
    }];
}

- (NSString *)networkName {
    return @"fb";
}

/// 获取广告平台类型
- (MEAdAgentType)platformType{
    return MEAdAgentTypeFacebook;
}

// MARK: - 插屏广告
- (BOOL)showInterstitialViewWithPosid:(NSString *)posid showFunnyBtn:(BOOL)showFunnyBtn {
    self.posid = posid;
    self.showFunnyBtn = showFunnyBtn;
    
    if (![self topVC]) {
        return NO;
    }
    
    #warning 暂用showFunnyBtn 代替,表示只 load 不展示
    if (showFunnyBtn == YES) {
        self.needShow = NO;
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:posid];
        self.interstitialAd.delegate = self;
        [self.interstitialAd loadAd];
        return YES;
    }
    
    if (!self.interstitialAd && !self.interstitialAd.isAdValid) {
        self.needShow = YES;
        self.interstitialAd = [[FBInterstitialAd alloc] initWithPlacementID:posid];
        self.interstitialAd.delegate = self;
        [self.interstitialAd loadAd];
    } else {
        self.needShow = NO;
        if (self.interstitialAd.isAdValid) {
            [self.interstitialAd showAdFromRootViewController:[self topVC]];
        }else{
            self.needShow = YES;
            [self.interstitialAd loadAd];
        }
    }
    
    return YES;
}

- (void)stopInterstitialWithPosid:(NSString *)posid {
    self.needShow = NO;
}

//MARK: FBInterstitialAdDelegate

- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"Ad is loaded and ready to be displayed");
    if (self.needShow) {
        if (interstitialAd && interstitialAd.isAdValid) {
            // You can now display the full screen ad using this code:
            [interstitialAd showAdFromRootViewController:[self topVC]];
            
            if (self.interstitialDelegate && [self.interstitialDelegate respondsToSelector:@selector(adapterInterstitialLoadSuccess:)]) {
                [self.interstitialDelegate adapterInterstitialLoadSuccess:self];
            }
            
            // 上报日志
            MEAdLogModel *model = [MEAdLogModel new];
            model.event = AdLogEventType_Load;
            model.st_t = AdLogAdType_Interstitial;
            model.so_t = self.sortType;
            model.posid = self.sceneId;
            model.network = self.networkName;
            model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
            // 先保存到数据库
            [MEAdLogModel saveLogModelToRealm:model];
            // 立即上传
            [MEAdLogModel uploadImmediately];
        }
    }
}

- (void)interstitialAdWillLogImpression:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"The user sees the add");
    // Use this function as indication for a user's impression on the ad.
    
    if (self.interstitialDelegate && [self.interstitialDelegate respondsToSelector:@selector(adapterInterstitialShowSuccess:)]) {
        [self.interstitialDelegate adapterInterstitialShowSuccess:self];
    }
    
    // 上报日志
    MEAdLogModel *model = [MEAdLogModel new];
    model.event = AdLogEventType_Show;
    model.st_t = AdLogAdType_Interstitial;
    model.so_t = self.sortType;
    model.posid = self.sceneId;
    model.network = self.networkName;
    model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
    // 先保存到数据库
    [MEAdLogModel saveLogModelToRealm:model];
    // 立即上传
    [MEAdLogModel uploadImmediately];
    
//    UIViewController *vc = [self topVC];
//    if (vc.view.subviews.count && self.showFunnyBtn == YES) {
//        UIView *view = vc.view.subviews[0];
//        CGRect frame = view.frame;
//        CGFloat buttonWidth = 22.f;
//        self.funnyButton = [[MEFunnyButton alloc] initWithFrame:CGRectMake(view.frame.size.width-buttonWidth-5.f, view.frame.size.height-buttonWidth-10, buttonWidth, buttonWidth)];
//        [view addSubview:self.funnyButton];
//    }
}

- (void)interstitialAdDidClick:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"The user clicked on the ad and will be taken to its destination");
    // Use this function as indication for a user's click on the ad.
    if (self.interstitialDelegate && [self.interstitialDelegate respondsToSelector:@selector(adapterInterstitialClicked:)]) {
        [self.interstitialDelegate adapterInterstitialClicked:self];
    }
    
    // 上报日志
    MEAdLogModel *model = [MEAdLogModel new];
    model.event = AdLogEventType_Click;
    model.st_t = AdLogAdType_Interstitial;
    model.so_t = self.sortType;
    model.posid = self.sceneId;
    model.network = self.networkName;
    model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
    // 先保存到数据库
    [MEAdLogModel saveLogModelToRealm:model];
    // 立即上传
    [MEAdLogModel uploadImmediately];
}

- (void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"The user clicked on the close button, the ad is just about to close");
    // Consider to add code here to resume your app's flow
    if (self.interstitialDelegate && [self.interstitialDelegate respondsToSelector:@selector(adapterInterstitialDismiss:)]) {
        [self.interstitialDelegate adapterInterstitialDismiss:self];
    }
}

- (void)interstitialAdDidClose:(FBInterstitialAd *)interstitialAd
{
    NSLog(@"Interstitial had been closed");
    // Consider to add code here to resume your app's flow
    if (self.interstitialDelegate && [self.interstitialDelegate respondsToSelector:@selector(adapterInterstitialCloseFinished:)]) {
        [self.interstitialDelegate adapterInterstitialCloseFinished:self];
    }
    
    self.needShow = NO;
    // 广告预加载
    [self.interstitialAd loadAd];
    [self.funnyButton removeFromSuperview];
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd didFailWithError:(NSError *)error
{
    NSLog(@"Ad failed to load");
    if (self.needShow) {
        if (self.interstitialDelegate && [self.interstitialDelegate respondsToSelector:@selector(adapter:interstitialLoadFailure:)]) {
            [self.interstitialDelegate adapter:self interstitialLoadFailure:error];
        }
    }
    
    // 上报日志
    MEAdLogModel *model = [MEAdLogModel new];
    model.event = AdLogEventType_Fault;
    model.st_t = AdLogAdType_Interstitial;
    model.so_t = self.sortType;
    model.posid = self.sceneId;
    model.network = self.networkName;
    model.type = AdLogFaultType_Normal;
    model.code = error.code;
    if (error.localizedDescription != nil || error.localizedDescription.length > 0) {
        model.msg = error.localizedDescription;
    }
    model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
    // 先保存到数据库
    [MEAdLogModel saveLogModelToRealm:model];
    // 立即上传
    [MEAdLogModel uploadImmediately];
}

// MARK: - 激励视频
- (BOOL)showRewardVideoWithPosid:(NSString *)posid {
    self.posid = posid;
    
    if (![self topVC]) {
        return NO;
    }
    
    if (self.isTheVideoPlaying == YES) {
        // 若当前有视频正在播放,则此次激励视频不播放
        return YES;
    }

    if (!self.rewardedAd || self.rewardedAd.isAdValid == NO) {
        self.rewardedAd = nil;
        self.needShow = YES;
        self.rewardedAd = [[FBRewardedVideoAd alloc] initWithPlacementID:posid];
        self.rewardedAd.delegate = self;
        [self.rewardedAd loadAd];
    } else {
        self.needShow = NO;
        if (self.rewardedAd.isAdValid) {
            [self.rewardedAd showAdFromRootViewController:[self topVC]];
        }
    }
    
    return YES;
}

/// 结束当前视频
- (void)stopCurrentVideo {
    self.needShow = NO;
    if (self.rewardedAd.adValid) {
        UIViewController *topVC = [self topVC];
        [topVC dismissViewControllerAnimated:YES completion:nil];
//        self.rewardVideoAd = nil;
    }
}

//MARK: FBRewardedVideoAdDelegate

- (void)rewardedVideoAd:(FBRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error
{
    NSLog(@"Rewarded video ad failed to load");
    if (self.needShow) {
        if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(adapter:videoShowFailure:)]) {
            [self.videoDelegate adapter:self videoShowFailure:error];
        }
    }
    
    // 上报日志
    MEAdLogModel *model = [MEAdLogModel new];
    model.event = AdLogEventType_Fault;
    model.st_t = AdLogAdType_RewardVideo;
    model.so_t = self.sortType;
    model.posid = self.sceneId;
    model.network = self.networkName;
    model.type = AdLogFaultType_Render;
    model.code = error.code;
    if (error.localizedDescription != nil || error.localizedDescription.length > 0) {
        model.msg = error.localizedDescription;
    }
    model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
    // 先保存到数据库
    [MEAdLogModel saveLogModelToRealm:model];
    // 立即上传
    [MEAdLogModel uploadImmediately];
}

- (void)rewardedVideoAdDidLoad:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Video ad is loaded and ready to be displayed");
    if (self.needShow) {
        self.isTheVideoPlaying = YES;
        if (self.rewardedAd && self.rewardedAd.isAdValid) {
            [self.rewardedAd showAdFromRootViewController:[self topVC]];
            
            // 上报日志
            MEAdLogModel *model = [MEAdLogModel new];
            model.event = AdLogEventType_Load;
            model.st_t = AdLogAdType_RewardVideo;
            model.so_t = self.sortType;
            model.posid = self.sceneId;
            model.network = self.networkName;
            model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
            // 先保存到数据库
            [MEAdLogModel saveLogModelToRealm:model];
            // 立即上传
            [MEAdLogModel uploadImmediately];
        }
    }
}

- (void)rewardedVideoAdDidClick:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Video ad clicked");
    if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(adapterVideoClicked:)]) {
        [self.videoDelegate adapterVideoClicked:self];
    }
    
    // 上报日志
    MEAdLogModel *model = [MEAdLogModel new];
    model.event = AdLogEventType_Click;
    model.st_t = AdLogAdType_RewardVideo;
    model.so_t = self.sortType;
    model.posid = self.sceneId;
    model.network = self.networkName;
    model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
    // 先保存到数据库
    [MEAdLogModel saveLogModelToRealm:model];
    // 立即上传
    [MEAdLogModel uploadImmediately];
}

- (void)rewardedVideoAdVideoComplete:(FBRewardedVideoAd *)rewardedVideoAd;
{
    NSLog(@"Rewarded Video ad video complete - this is called after a full video view, before the ad end card is shown. You can use this event to initialize your reward");
    if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(adapterVideoFinishPlay:)]) {
        [self.videoDelegate adapterVideoFinishPlay:self];
    }
}

- (void)rewardedVideoAdWillClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"The user clicked on the close button, the ad is just about to close");
    if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(adapterVideoClose:)]) {
        [self.videoDelegate adapterVideoClose:self];
    }
    self.isTheVideoPlaying = NO;
    self.needShow = NO;
    // 预加载
    [self.rewardedAd loadAd];
}

- (void)rewardedVideoAdDidClose:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded Video ad closed - this can be triggered by closing the application, or closing the video end card");
}

- (void)rewardedVideoAdWillLogImpression:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded Video impression is being captured");
    if (self.videoDelegate && [self.videoDelegate respondsToSelector:@selector(adapterVideoShowSuccess:)]) {
        [self.videoDelegate adapterVideoShowSuccess:self];
    }
    
    // 上报日志
    MEAdLogModel *model = [MEAdLogModel new];
    model.event = AdLogEventType_Show;
    model.st_t = AdLogAdType_RewardVideo;
    model.so_t = self.sortType;
    model.posid = self.sceneId;
    model.network = self.networkName;
    model.tk = [self stringMD5:[NSString stringWithFormat:@"%@%ld%@%ld", model.posid, model.so_t, @"mobi", (long)([[NSDate date] timeIntervalSince1970]*1000)]];
    // 先保存到数据库
    [MEAdLogModel saveLogModelToRealm:model];
    // 立即上传
    [MEAdLogModel uploadImmediately];
}

- (void)rewardedVideoAdServerRewardDidSucceed:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video ad validated by server");
}

- (void)rewardedVideoAdServerRewardDidFail:(FBRewardedVideoAd *)rewardedVideoAd
{
    NSLog(@"Rewarded video ad not validated, or no response from server");
}

@end
