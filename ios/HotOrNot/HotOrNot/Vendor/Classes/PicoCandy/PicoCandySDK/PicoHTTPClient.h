//
//  PicoHTTPClient.h
//  PicoCandySDK
//
//  Created by PicoCandy Pte Ltd on 8/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wafer/PCWafer.h"
#import "PicoUser.h"

typedef enum {
    kPicoHTTPClientUnknownError,
    kPicoHTTPClientServerError,
    kPicoHTTPClientBadServerResponse,
    kPicoHTTPClientDisconnected,
    kPicoHTTPClientBadURL,
    kPicoHTTPClientUnsupportedURL,
    kPicoHTTPClientUnauthorized,
    kPicoHTTPClientMaintenanceMode,
    kPicoHTTPClientTimeoutError
} kPicoHTTPClientError;

typedef enum {
    /* Success codes */
    kPicoHTTPStatusOK                   = 200,
    kPicoHTTPStatusCreated              = 201,
    kPicoHTTPStatusAccepted             = 202,
    /* Client-side errors */
    kPicoHTTPStatusRequestTimeout       = 408,
    /* Server-side errors */
    kPicoHTTPStatusInternalServerError  = 500,
    kPicoHTTPStatusBadGateway           = 502,
    kPicoHTTPStatusServiceUnavailable   = 503,
    kPicoHTTPStatusGatewayTimeout       = 504,
} kPicoHTTPStatusCode;

typedef void (^PicoHTTPClientAuthenticateSuccess)(PicoUser *user);
typedef void (^PicoHTTPClientAuthenticateFailure)(kPicoHTTPClientError errorType);

@protocol PicoHTTPClientDelegate <NSObject>

-(void)httpClientReceivedSuccessStatusCode:(id)client;
-(void)httpClientReceivedMaintenanceModeStatusCode:(id)client;

@end

@interface PicoHTTPClient : NSObject

@property (nonatomic, readonly) BOOL authenticated;
@property (nonatomic, readonly) PCWaferClient *waferClient;
@property (nonatomic, strong) NSString *storeId;
@property (nonatomic, strong) id<PicoHTTPClientDelegate> delegate;

+(PicoHTTPClient *)sharedClient;

/**
 * Authenticates app with App Id and Secret Key
 * @param appId Identifier that identifies your app
 * @param secretKey Your app's secret key
 */
-(void)authenticateWithAppId:(NSString *)appId secretKey: (NSString *)secretKey
                     success:(PicoHTTPClientAuthenticateSuccess)success failure:(PicoHTTPClientAuthenticateFailure)fail;

-(void)removeAuthentication;

-(void)makeAPICallWithURLFragments:(NSArray *)fragments
                             using:(kWaferClientRequestMethodType)method
                    withParameters:(NSDictionary *)params
                       jsonEnabled:(BOOL)json
                           success:(WaferClientRequestSuccess)success
                              fail:(WaferClientRequestFailure)failure;

-(void)makeAPICallTo:(NSString *)endPoint
               using:(kWaferClientRequestMethodType)method
      withParameters:(NSDictionary *)params
         jsonEnabled:(BOOL)json
             success:(WaferClientRequestSuccess)success
                fail:(WaferClientRequestFailure)failure;

-(id)responseObjectFromOperation:(PCWafer_AFHTTPRequestOperation *)operation;

-(NSString *)serverAPIPath;

@end
