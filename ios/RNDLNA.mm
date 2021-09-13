// RNDLNA.m

#import "RNDLNA.h"
#include <Platinum/Platinum.h>
#include "Platinum/PltMediaRenderer.h"

@implementation RNDLNA
{
    PLT_UPnP *upnp;
    PLT_MediaRenderer *renderer;
    PLT_MediaRendererDelegateMy delegateCPP;
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
}

RCT_EXPORT_METHOD(stopDLNAService)
{
    if (upnp->IsRunning() && upnp != NULL) {
        upnp->Stop();
        [self sendEventWithName:@"DlnaStateChange" body:@{@"state":@"STOPPING"}];
        NSLog(@"UPnP Service is stop!");
    }
}

-(void)reset
{
    self.album_art_uri=nil;
    self.artist=nil;
    self.album=nil;
    self.currentURI=nil;
    self.currTitle=nil;
}

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
    [self reset];
    NPT_String currentURI;
    (*action)->GetArgumentValue("CurrentURI", currentURI);
    self.currentURI = [NSURL URLWithString:[NSString stringWithUTF8String:currentURI]];
    NPT_String currentURIMetaData;
    (*action)->GetArgumentValue("CurrentURIMetaData", currentURIMetaData);
    PLT_MediaObjectListReference medias;
    PLT_Didl::FromDidl(currentURIMetaData, medias);
    if (!medias.IsNull()) {
        int count = medias->GetItemCount();
        if (count > 0){
            PLT_MediaObject * media = *medias->GetFirstItem();
            self.currTitle = [NSString stringWithUTF8String: media->m_Title ];
            if( media->m_ObjectClass.type.Compare("object.item.videoItem",true) == 0 ){
                self.mediaType = mediaType_video;
            }else if(media->m_ObjectClass.type.Compare("object.item.imageItem.photo",true) == 0 ){
                self.mediaType = mediaType_photo;
            }else if(media->m_ObjectClass.type.Compare("object.item.audioItem.musicTrack",true) == 0 ||
                        media->m_ObjectClass.type.Compare("object.item.audioItem.audioBroadcast",true) == 0){
                self.mediaType = mediaType_music;
                // get album art icon uri
                auto album_arts = media->m_ExtraInfo.album_arts;
                int count = album_arts.GetItemCount();
                if (count > 0) {
                    auto beg = album_arts.GetFirstItem();
                    PLT_AlbumArtInfo album_art = *beg;
                    
                    self.album_art_uri = [NSString stringWithUTF8String:album_art.uri];
                }
                // get artist
                auto artists = media->m_People.artists;
                if (artists.GetItemCount() > 0) {
                    auto beg = artists.GetFirstItem();
                    PLT_PersonRole role = *beg;
                    self.artist = [NSString stringWithUTF8String: role.name];
                }
                // get album info.
                self.album = [NSString stringWithUTF8String:media->m_Affiliation.album];
            }else{
                self.mediaType = mediaType_unsupport;
                // Tread `rmvb` as video.
                for (int i = 0; i < media->m_Resources.GetItemCount(); i++) {
                    PLT_MediaItemResource *r = media->m_Resources.GetItem(i);
                    NPT_String contentType = r->m_ProtocolInfo.GetContentType();
                    if (contentType.Compare("application/vnd.rn-realmedia-vbr",true) == 0) {
                        self.mediaType = mediaType_video;
                        break;
                    }
                }
            }
        }
    }
    if (self.mediaType == mediaType_music) {
        // mediaType_music
    }else if(self.mediaType == mediaType_photo){
                // mediaType_photo
    }else if(self.mediaType == mediaType_video){
        // mediaType_video
    }else{
        NSLog(@"Not supported media type!");
    }
    [self sendEventWithName:@"DlnaMediaInfo" body:@{@"url":self.currentURI,@"title":self.currTitle,@"mediaType":@(self.mediaType),@"albumArtURI":self.album_art_uri}];
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

@end
