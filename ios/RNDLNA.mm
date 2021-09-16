// RNDLNA.m

#import "RNDLNA.h"
#import <objc/runtime.h>
//#if !TARGET_IPHONE_SIMULATOR
#if !TARGET_IPHONE_SIMULATOR
#include <Platinum/Platinum.h>
#include "Platinum/PltMediaRenderer.h"
#endif

@implementation RNDLNA
{
#if !TARGET_IPHONE_SIMULATOR
    PLT_UPnP *upnp;
    PLT_MediaRenderer *renderer;
    PLT_MediaRendererDelegateMy delegateCPP;
#endif
}

RCT_EXPORT_MODULE()

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

-(id)init
{
    if (self = [super init]) {
#if !TARGET_IPHONE_SIMULATOR
        // Set up Neptune logging
        NPT_LogManager::GetDefault().Configure("plist:.level=INFO;.handlers=ConsoleHandler;.ConsoleHandler.outputs=2;"
                                               ".ConsoleHandler.colors=false;.ConsoleHandler.filter=59");
        upnp = new PLT_UPnP();
#endif
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"DlnaStateChange",@"DlnaMediaInfo"];
}

RCT_EXPORT_METHOD(startDLNAService:(NSString *)serverName)
{
#if !TARGET_IPHONE_SIMULATOR
    const char * serverNameChar = [serverName UTF8String];
    NSString * uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    const char * uuidChar = [uuid UTF8String];
    renderer = new PLT_MediaRenderer(serverNameChar, false, uuidChar);
    renderer->SetByeByeFirst(false);
    delegateCPP.owner = self;
    renderer->SetDelegate(&delegateCPP);
    PLT_DeviceHostReference device(renderer);
    upnp->AddDevice(device);
    if (!upnp->IsRunning()) {
        upnp->Start();
        [self sendEventWithName:@"DlnaStateChange" body:@{@"state":@"RUNNING"}];
        NSLog(@"UPnP Service is starting!");
    } else {
        upnp->Stop();
        upnp->Start();
        [self sendEventWithName:@"DlnaStateChange" body:@{@"state":@"RUNNING"}];
        NSLog(@"UPnP Service is starting!");
    }
#endif
}

RCT_EXPORT_METHOD(stopDLNAService)
{
#if !TARGET_IPHONE_SIMULATOR
    if (upnp->IsRunning() && upnp != NULL) {
        upnp->Stop();
        [self sendEventWithName:@"DlnaStateChange" body:@{@"state":@"STOPPING"}];
        NSLog(@"UPnP Service is stop!");
    }
#endif
}

RCT_EXPORT_METHOD(getAllApps:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSArray * array = [options allKeys];
    NSMutableDictionary *apps = [[NSMutableDictionary alloc] init];
    for (NSString * key in array)
    {
        NSString * value = options[key];
        BOOL isHave = [self isInstalled:key];
        if (isHave) {
            [apps setObject:key forKey:value];
        }
    }
    resolve(apps);
}

RCT_EXPORT_METHOD(startApp:(NSString *)bundleID)
{
    Class lsawsc = objc_getClass("LSApplicationWorkspace");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    NSObject* workspace = [lsawsc performSelector:NSSelectorFromString(@"defaultWorkspace")];
    // iOS6 没有defaultWorkspace
    if ([workspace respondsToSelector:NSSelectorFromString(@"openApplicationWithBundleID:")])
    {
        [workspace performSelector:NSSelectorFromString(@"openApplicationWithBundleID:")withObject:bundleID];
#pragma clang diagnostic pop
    }
}

- (BOOL)isInstalled:(NSString *)bundleId {
    NSBundle *container = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/MobileContainerManager.framework"];
    if ([container load]) {
        Class appContainer = NSClassFromString(@"MCMAppContainer");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        id container = [appContainer performSelector:@selector(containerWithIdentifier:error:) withObject:bundleId withObject:nil];
#pragma clang diagnostic pop
        if (container) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}

#if !TARGET_IPHONE_SIMULATOR
#pragma mark - MediaRendererDelegate

-(void)OnGetCurrentConnectionInfo:(PLT_ActionReference*)action
{
    
}

// AVTransport
-(void) OnNext:(PLT_ActionReference*)action
{
    
}

-(void) OnPause:(PLT_ActionReference*)action
{

}

-(void) OnPlay:(PLT_ActionReference*)action
{
    
}

-(void) OnPrevious:(PLT_ActionReference*)action
{
    
}

-(void) OnSeek:(PLT_ActionReference*)action
{
    
}

-(void) OnStop:(PLT_ActionReference*)action
{
    
}

-(void) OnSetAVTransportURI:(PLT_ActionReference*)action
{
    NPT_String currentURI;
    (*action)->GetArgumentValue("CurrentURI", currentURI);
    NSString *url = [NSString stringWithUTF8String:currentURI];
//    NSLog(@"======OnSetAVTransportURI===\n===%@", url);
    NPT_String currentURIMetaData;
    (*action)->GetArgumentValue("CurrentURIMetaData", currentURIMetaData);
//    NSString *mediaInfo = [NSString stringWithUTF8String:currentURIMetaData];
    // <DIDL-Lite xmlns
//    NSLog(@"======currentURIMetaData===\n===%@", mediaInfo);
    PLT_MediaObjectListReference medias;
    PLT_Didl::FromDidl(currentURIMetaData, medias);
    if (medias.IsNull()) {
        return;
    }
    int count = medias->GetItemCount();
    if (count == 0) {
        return;
    }
    PLT_MediaObject * media = *medias->GetFirstItem();
    NSString *title = [NSString stringWithUTF8String:media->m_Title];
    [self sendEventWithName:@"DlnaMediaInfo" body:@{@"url":url,@"title":title}];
}

-(void) OnSetPlayMode:(PLT_ActionReference*)action
{

}

// RenderingControl
-(void) OnSetVolume:(PLT_ActionReference*)action
{
    
}

-(void) OnSetVolumeDB:(PLT_ActionReference*)action
{
    
}

-(void) OnGetVolumeDBRange:(PLT_ActionReference*)action
{
  
}

-(void) OnSetMute:(PLT_ActionReference*)action
{
    
}
#endif
@end
