//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<connectivity_state_plus/ConnectivityStatePlusPlugin.h>)
#import <connectivity_state_plus/ConnectivityStatePlusPlugin.h>
#else
@import connectivity_state_plus;
#endif

#if __has_include(<integration_test/IntegrationTestPlugin.h>)
#import <integration_test/IntegrationTestPlugin.h>
#else
@import integration_test;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [ConnectivityStatePlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"ConnectivityStatePlusPlugin"]];
  [IntegrationTestPlugin registerWithRegistrar:[registry registrarForPlugin:@"IntegrationTestPlugin"]];
}

@end
