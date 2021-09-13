// RNDLNA.m

#import "RNDLNA.h"
#include <Platinum/Platinum.h>
#include "Platinum/PltMediaRenderer.h"

@implementation RNDLNA
{
    PLT_UPnP *upnp;
    PLT_MediaRenderer *renderer;
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
        // Set up Neptune logging
        NPT_LogManager::GetDefault().Configure("plist:.level=FINE;.handlers=ConsoleHandler;.ConsoleHandler.colors=off;.ConsoleHandler.filter=63");
        
        upnp = new PLT_UPnP();
        
        // Set up device
//        NSString *serverName = [UIDevice currentDevice].name;
//        connect = new PLT_MediaConnect([serverName UTF8String]);
//        connect->SetByeByeFirst(false);
//
//        NSLog(@"FILEPATH:%@", [UpnpServer filePath]);
//        delegate = new PLT_FileMediaConnectDelegate("/", [[UpnpServer filePath] UTF8String]);
//        connect->SetDelegate((PLT_MediaServerDelegate *)delegate.AsPointer());
//
//        // Set up UPnP server
//        PLT_DeviceHostReference device(connect);
//        upnp->AddDevice(device);
    }
    return self;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"DlnaStateChange",@"DlnaMediaInfo"];
}

RCT_EXPORT_METHOD(startDLNAService:(NSString *)serverName)
{
    const char * serverNameChar = [serverName UTF8String];
    NSString * uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    const char * uuidChar = [uuid UTF8String];
    renderer = new PLT_MediaRenderer(serverNameChar, false, uuidChar);
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
}

RCT_EXPORT_METHOD(stopDLNAService)
{
    if (upnp->IsRunning() && upnp != NULL) {
        upnp->Stop();
        [self sendEventWithName:@"DlnaStateChange" body:@{@"state":@"STOPPING"}];
        NSLog(@"UPnP Service is stop!");
    }
}

@end
